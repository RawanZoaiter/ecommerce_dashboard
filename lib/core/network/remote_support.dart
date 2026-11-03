import 'package:dio/dio.dart';

import '../error/error_mapper.dart';
import '../error/failure.dart';
import '../error/result.dart';
import 'api_response.dart';

/// Shared plumbing for the remote repositories.
///
/// Every repository method funnels through [guard], so a Dio exception never
/// escapes the data layer: it becomes a typed [Failure] and the cubits keep
/// their single exhaustive switch.
mixin RemoteSupport {
  Future<Result<T>> guard<T>(Future<T> Function() run) async {
    try {
      return Ok(await run());
    } on DioException catch (error) {
      return Err(ErrorMapper.fromDio(error));
    } on FormatException catch (error) {
      // The request succeeded but the body was not the shape we expect.
      return Err(UnknownFailure(debugMessage: error.message));
    } catch (error) {
      return Err(UnknownFailure(debugMessage: error.toString()));
    }
  }
}

/// Pulls `data` out of the standard envelope (guide §3).
///
/// Throws a [FormatException] rather than returning null, so a malformed body
/// is reported as a failure instead of surfacing as an empty screen.
Map<String, dynamic> envelopeObject(Response<dynamic> response) {
  final body = response.data;
  if (body is! Map<String, dynamic>) {
    throw const FormatException('Response body is not a JSON object.');
  }
  final data = body['data'];
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Response "data" is not a JSON object.');
  }
  return data;
}

/// Pulls a `data` array out of the envelope, for the unpaginated lists.
List<Map<String, dynamic>> envelopeList(Response<dynamic> response) {
  final body = response.data;
  if (body is! Map<String, dynamic>) {
    throw const FormatException('Response body is not a JSON object.');
  }
  final data = body['data'];
  if (data is! List) {
    throw const FormatException('Response "data" is not a JSON array.');
  }
  return data.whereType<Map<String, dynamic>>().toList();
}

/// Builds a [Paginated] from a list response's `data` and `meta` blocks.
///
/// `meta` is read rather than inferred: the paginator shows "21-40 of 97",
/// and only the server knows the total.
Paginated<T> envelopePage<T>(
  Response<dynamic> response,
  T Function(Map<String, dynamic> json) parse,
) {
  final body = response.data;
  if (body is! Map<String, dynamic>) {
    throw const FormatException('Response body is not a JSON object.');
  }

  final data = body['data'];
  if (data is! List) {
    throw const FormatException('Response "data" is not a JSON array.');
  }

  final meta = body['meta'];
  return Paginated(
    items: data.whereType<Map<String, dynamic>>().map(parse).toList(),
    meta: meta is Map<String, dynamic>
        ? PageMeta.fromJson(meta)
        : const PageMeta.empty(),
  );
}
