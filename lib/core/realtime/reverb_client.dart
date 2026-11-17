import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A message pushed by the server on a channel (for example `NewOrderPlaced`).
class ReverbEvent {
  const ReverbEvent({
    required this.channel,
    required this.name,
    required this.data,
  });

  final String channel;
  final String name;

  /// The decoded JSON payload (Laravel's `broadcastWith()`).
  final Map<String, dynamic> data;
}

/// Asks Laravel to sign a subscription to a private channel.
///
/// Implemented by each app with its own HTTP client, so the JWT (and its automatic refresh) is reused:
/// `POST /api/broadcasting/auth` with `socket_id` and `channel_name`. It must return the `auth` string of the
/// response, and throw if the server refuses (403 = the user may not join that channel).
typedef ChannelAuthorizer =
    Future<String> Function(String socketId, String channelName);

/// A small client for the Pusher protocol that Laravel Reverb speaks.
///
/// How a connection works, step by step:
///  1. Open a WebSocket to `ws://host:8081/app/<APP_KEY>`.
///  2. The server answers `pusher:connection_established` with a `socket_id`: the identity of this connection.
///  3. For a PRIVATE channel the client must prove it is allowed in. It sends the socket_id and the channel name
///     to Laravel over normal HTTP (with its JWT); Laravel runs the rule in routes/channels.php and, if the user
///     is allowed, returns a signature (`auth`).
///  4. The client sends `pusher:subscribe` with that signature. Reverb verifies it and starts delivering events.
///  5. Reverb sends `pusher:ping` regularly; the client must answer `pusher:pong` or the connection is closed.
///
/// If the connection drops, the client reconnects with an increasing delay and subscribes again to every channel
/// that still has a listener (the signature depends on the socket_id, so each reconnection is authorised again).
class ReverbClient {
  ReverbClient({
    required this.host,
    required this.port,
    required this.appKey,
    required this.authorizer,
    this.secure = false,
  });

  final String host;
  final int port;
  final String appKey;
  final bool secure;
  final ChannelAuthorizer authorizer;

  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _socketSub;
  String? _socketId;
  bool _connecting = false;
  bool _stopped = true;
  int _attempt = 0;
  Timer? _reconnectTimer;

  final Map<String, StreamController<ReverbEvent>> _channels = {};
  final Set<String> _subscribed = {};

  bool get isConnected => _socketId != null;

  /// Events of the private channel [name] (without the `private-` prefix, e.g. `admin.orders`).
  /// The connection and the subscription are opened when the first listener arrives and closed when the last one
  /// leaves. A refused subscription is reported as an error on the stream.
  Stream<ReverbEvent> private(String name) {
    final channelName = 'private-$name';
    return (_channels[channelName] ??= _newController(channelName)).stream;
  }

  StreamController<ReverbEvent> _newController(String channelName) {
    late final StreamController<ReverbEvent> controller;
    controller = StreamController<ReverbEvent>.broadcast(
      onListen: () {
        _start();
        if (isConnected) _subscribe(channelName);
      },
      onCancel: () {
        // Broadcast controllers call onCancel only when the LAST listener is gone.
        _channels.remove(channelName);
        _unsubscribe(channelName);
        controller.close();
      },
    );
    return controller;
  }

  void _start() {
    if (!_stopped) return;
    _stopped = false;
    _connect();
  }

  Future<void> _connect() async {
    if (_connecting || _stopped) return;
    _connecting = true;

    final uri = Uri(
      scheme: secure ? 'wss' : 'ws',
      host: host,
      port: port,
      path: '/app/$appKey',
      queryParameters: {'protocol': '7', 'client': 'dart', 'version': '1.0'},
    );

    try {
      final socket = WebSocketChannel.connect(uri);
      await socket.ready;
      _socket = socket;
      _socketSub = socket.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (Object error) {
          debugPrint('Reverb socket error: $error');
          _onDisconnected();
        },
      );
    } catch (error) {
      debugPrint('Reverb connection failed: $error');
      _connecting = false;
      _scheduleReconnect();
      return;
    }
    _connecting = false;
  }

  void _onMessage(dynamic raw) {
    final Map<String, dynamic> message;
    try {
      message = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final event = message['event'] as String? ?? '';
    final data = _decodeData(message['data']);

    switch (event) {
      case 'pusher:connection_established':
        _socketId = data['socket_id'] as String?;
        _attempt = 0;
        _subscribed.clear();
        for (final channelName in _channels.keys.toList()) {
          _subscribe(channelName);
        }
      case 'pusher:ping':
        _send({'event': 'pusher:pong', 'data': <String, dynamic>{}});
      case 'pusher:error':
        debugPrint('Reverb error: $data');
      case 'pusher_internal:subscription_succeeded':
        break;
      default:
        final channelName = message['channel'] as String?;
        if (channelName == null || event.startsWith('pusher')) return;
        final controller = _channels[channelName];
        if (controller != null && !controller.isClosed) {
          controller.add(
            ReverbEvent(channel: channelName, name: event, data: data),
          );
        }
    }
  }

  Future<void> _subscribe(String channelName) async {
    final socketId = _socketId;
    if (socketId == null || !_subscribed.add(channelName)) return;

    try {
      final auth = await authorizer(socketId, channelName);
      // The connection may have been replaced while the HTTP call was running.
      if (_socketId != socketId) return;
      _send({
        'event': 'pusher:subscribe',
        'data': {'auth': auth, 'channel': channelName},
      });
    } catch (error) {
      _subscribed.remove(channelName);
      // For example 403: the server refused this user. Tell whoever listens.
      _channels[channelName]?.addError(error);
    }
  }

  void _unsubscribe(String channelName) {
    if (_subscribed.remove(channelName)) {
      _send({
        'event': 'pusher:unsubscribe',
        'data': {'channel': channelName},
      });
    }
    if (_channels.isEmpty) disconnect();
  }

  void _send(Map<String, dynamic> message) {
    try {
      _socket?.sink.add(jsonEncode(message));
    } catch (error) {
      debugPrint('Reverb send failed: $error');
    }
  }

  void _onDisconnected() {
    _socketSub?.cancel();
    _socketSub = null;
    _socket = null;
    _socketId = null;
    _subscribed.clear();
    _connecting = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_stopped || _channels.isEmpty) return;
    _reconnectTimer?.cancel();
    // 1s, 2s, 4s ... capped at 30s.
    final delay = Duration(seconds: min(30, 1 << min(_attempt, 5)));
    _attempt++;
    _reconnectTimer = Timer(delay, _connect);
  }

  /// Closes the connection and forgets every subscription (for example on sign-out).
  void disconnect() {
    _stopped = true;
    _reconnectTimer?.cancel();
    _socketSub?.cancel();
    _socketSub = null;
    _socket?.sink.close();
    _socket = null;
    _socketId = null;
    _subscribed.clear();
    _connecting = false;
    _attempt = 0;
  }

  static Map<String, dynamic> _decodeData(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return <String, dynamic>{};
  }
}
