import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/remote_support.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  const OrderRemoteDataSource(this._dio);

  final Dio _dio;

  /// `GET /orders`. An admin token returns every customer's orders.
  Future<Paginated<Order>> orders({
    required int page,
    required int perPage,
    OrderStatus? status,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.orders,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status.apiValue,
      },
    );
    return envelopePage(response, OrderModel.fromJson);
  }

  /// Reads only `meta.total` for a status, for the dashboard counters.
  ///
  /// `per_page: 1` because the rows are thrown away; the server still reports
  /// the full total, which is the only number needed.
  Future<int> countByStatus(OrderStatus? status) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.orders,
      queryParameters: {
        'page': 1,
        'per_page': 1,
        if (status != null) 'status': status.apiValue,
      },
    );
    return envelopePage(response, OrderModel.fromJson).meta.total;
  }

  /// `GET /orders/{id}`.
  Future<Order> order(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.order(id),
    );
    return OrderModel.fromJson(envelopeObject(response));
  }

  /// `PATCH /orders/{id}/status`. Admin only.
  Future<Order> updateStatus({
    required int id,
    required OrderStatus status,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.orderStatus(id),
      data: {'status': status.apiValue},
    );
    return OrderModel.fromJson(envelopeObject(response));
  }
}
