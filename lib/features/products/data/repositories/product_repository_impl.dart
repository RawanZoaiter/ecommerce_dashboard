import '../../../../core/config/app_config.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/remote_support.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/new_product.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl with RemoteSupport implements ProductRepository {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Result<List<Category>>> categories() => guard(_remote.categories);

  @override
  Future<Result<Paginated<Product>>> products({
    int page = 1,
    int perPage = AppConfig.defaultPerPage,
    int? categoryId,
  }) {
    return guard(
      () => _remote.products(
        page: page,
        perPage: perPage,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Future<Result<Product>> product(int id) {
    // `inventoryReachable` is deliberately not passed: a null quantity means
    // either the inventory service is down or the product has no stock row,
    // and nothing the API exposes today separates the two. Until /app-status
    // reports inventory health, null stays honestly "unknown" instead of
    // being guessed at.
    return guard(() => _remote.product(id));
  }

  @override
  Future<Result<Map<int, Availability>>> availabilityFor(List<int> productIds) {
    return guard(() async {
      // Issued together, not one after another: sequentially this page costs
      // around 2.8s, in parallel about 0.5s.
      final results = await Future.wait(
        productIds.map((id) async {
          try {
            final product = await _remote.product(id);
            return MapEntry(id, product.availability);
          } catch (_) {
            // One product failing must not blank the whole column, so it is
            // dropped and its cell keeps showing "unknown".
            return null;
          }
        }),
      );

      return {
        for (final entry in results)
          if (entry != null) entry.key: entry.value,
      };
    });
  }

  @override
  Future<Result<ProductCreation>> create(NewProduct draft) =>
      guard(() => _remote.create(draft));
}
