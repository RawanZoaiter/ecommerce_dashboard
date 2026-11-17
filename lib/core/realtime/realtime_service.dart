import 'package:dio/dio.dart';

import '../../features/orders/data/models/order_model.dart';
import '../../features/orders/domain/entities/order.dart';
import '../config/app_config.dart';
import '../network/api_endpoints.dart';
import 'reverb_client.dart';

/// The dashboard's live connection to Laravel Reverb (requirement 4).
///
/// Only admins may join the private channel `admin.orders`: Laravel checks the JWT and the role before it signs
/// the subscription, and answers 403 to a customer. The connection opens with the first listener and closes
/// with [disconnect] (sign-out).
class RealtimeService {
  RealtimeService(this._dio);

  final Dio _dio;

  late final ReverbClient _client = ReverbClient(
    host: AppConfig.reverbHost,
    port: AppConfig.reverbPort,
    appKey: AppConfig.reverbAppKey,
    authorizer: _authorize,
  );

  /// Uses the app's own Dio, so the JWT is attached and refreshed exactly like for any other request.
  Future<String> _authorize(String socketId, String channelName) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.broadcastingAuth,
      data: {'socket_id': socketId, 'channel_name': channelName},
    );
    final auth = response.data?['auth'];
    if (auth is! String) {
      throw StateError('Laravel did not sign the subscription');
    }
    return auth;
  }

  /// Every order a customer creates, the moment Laravel saves it (event `NewOrderPlaced`).
  Stream<Order> newOrders() {
    return _client
        .private('admin.orders')
        .where((event) => event.name == 'NewOrderPlaced')
        .map((event) => event.data['order'])
        .where((raw) => raw is Map<String, dynamic>)
        .map((raw) => OrderModel.fromJson(raw as Map<String, dynamic>));
  }

  void disconnect() => _client.disconnect();
}
