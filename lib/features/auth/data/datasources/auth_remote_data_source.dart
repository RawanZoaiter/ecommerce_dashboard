import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/remote_support.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// `POST /auth/login`. Returns the user and the token pair together, the way
  /// the API does.
  Future<({User user, AuthTokens tokens})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = envelopeObject(response);
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const FormatException('Login response has no "user" object.');
    }

    return (user: UserModel.fromJson(user), tokens: AuthTokens.fromJson(data));
  }

  /// `GET /auth/user-info`.
  Future<User> currentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.userInfo,
    );
    return UserModel.fromJson(envelopeObject(response));
  }

  /// `POST /auth/logout`. Sends the refresh token too, so both halves of the
  /// pair are invalidated rather than leaving a usable refresh token behind.
  Future<void> logout({String? refreshToken}) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.logout,
      data: refreshToken == null ? null : {'refresh_token': refreshToken},
    );
  }
}
