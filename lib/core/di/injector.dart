import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/orders/data/datasources/order_remote_data_source.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final GetIt sl = GetIt.instance;

/// Builds the object graph.
///
/// Screens depend on the repository interfaces in `domain/`, never on Dio or
/// on a data source, so this file is the only place that knows how a
/// repository is actually fulfilled.
Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<TokenStorage>(
      () => const SecureTokenStorage(FlutterSecureStorage()),
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        tokenStorage: sl<TokenStorage>(),
        onSessionExpired: () => sl<TokenStorage>().clear(),
      ),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(sl<ApiClient>().dio),
    )
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSource(sl<ApiClient>().dio),
    )
    ..registerLazySingleton<OrderRemoteDataSource>(
      () => OrderRemoteDataSource(sl<ApiClient>().dio),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<TokenStorage>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
    )
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(sl<OrderRemoteDataSource>()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        sl<OrderRemoteDataSource>(),
        sl<ProductRemoteDataSource>(),
      ),
    );
}
