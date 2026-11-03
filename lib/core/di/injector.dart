import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/mock_dashboard_repository.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/inventory/data/repositories/mock_inventory_repository.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/notifications/data/repositories/mock_notification_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/orders/data/repositories/mock_order_repository.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/products/data/repositories/mock_product_repository.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/users/data/repositories/mock_user_repository.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final GetIt sl = GetIt.instance;

/// Builds the object graph.
///
/// This is the seam the whole mock/live decision runs through: screens depend
/// on repository interfaces, so swapping the bindings here moves the entire
/// dashboard onto the real API without touching a widget.
Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<TokenStorage>(
      () => AppConfig.usesMockData
          ? InMemoryTokenStorage()
          : const SecureTokenStorage(FlutterSecureStorage()),
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        tokenStorage: sl<TokenStorage>(),
        onSessionExpired: () => sl<TokenStorage>().clear(),
      ),
    );

  if (AppConfig.usesMockData) {
    _registerMockRepositories();
    return;
  }

  // Deliberately loud rather than silently falling back to sample data: the
  // remote data sources are not written yet, so flipping USE_LIVE_API must
  // fail where it can be seen. Each remote implementation registers here,
  // against the same interfaces the mocks already satisfy.
  throw UnimplementedError(
    'Live repositories are not implemented yet. The API layer under '
    'core/network is ready; register remote repositories here and remove '
    'this guard.',
  );
}

void _registerMockRepositories() {
  sl
    ..registerLazySingleton<AuthRepository>(MockAuthRepository.new)
    ..registerLazySingleton<ProductRepository>(MockProductRepository.new)
    ..registerLazySingleton<OrderRepository>(MockOrderRepository.new)
    ..registerLazySingleton<DashboardRepository>(MockDashboardRepository.new)
    ..registerLazySingleton<InventoryRepository>(MockInventoryRepository.new)
    ..registerLazySingleton<UserRepository>(MockUserRepository.new)
    ..registerLazySingleton<NotificationRepository>(
      MockNotificationRepository.new,
    );
}
