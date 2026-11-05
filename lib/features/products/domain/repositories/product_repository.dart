import '../../../../core/error/result.dart';
import '../../../../core/network/api_response.dart';
import '../entities/category.dart';
import '../entities/new_product.dart';
import '../entities/product.dart';

abstract interface class ProductRepository {
  /// `GET /categories` — the whole list, unpaginated and alphabetical.
  Future<Result<List<Category>>> categories();

  /// `GET /products`.
  Future<Result<Paginated<Product>>> products({
    int page,
    int perPage,
    int? categoryId,
  });

  /// `GET /products/{id}` — the only endpoint that carries availability.
  Future<Result<Product>> product(int id);

  /// Availability for a set of products, keyed by product id.
  ///
  /// An N+1 by necessity: the list endpoint carries no quantity and `GetStock`
  /// takes one product at a time, so a page of rows costs a detail call per
  /// row. Measured at about 0.5s for fifteen products issued together, which
  /// is why the table renders first and these arrive after, rather than the
  /// whole page waiting on them. It collapses to nothing extra the day the
  /// list endpoint includes `available_quantity`.
  ///
  /// Products whose call fails are simply absent from the map, so one bad
  /// response leaves the other rows with their real quantities.
  Future<Result<Map<int, Availability>>> availabilityFor(List<int> productIds);

  /// `POST /products` as multipart. Admin only.
  Future<Result<Product>> create(NewProduct draft);
}
