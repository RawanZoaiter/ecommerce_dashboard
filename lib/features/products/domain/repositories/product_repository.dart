import '../../../../core/error/result.dart';
import '../../../../core/network/api_response.dart';
import '../entities/category.dart';
import '../entities/new_product.dart';
import '../entities/product.dart';

abstract interface class ProductRepository {
  /// `GET /categories` — the whole list, unpaginated and alphabetical.
  Future<Result<List<Category>>> categories();

  /// `GET /products`.
  ///
  /// [search] has no server support yet; the live implementation will have to
  /// ignore it until `?search=` is added, and say so rather than filtering a
  /// single page client-side and calling it a search.
  Future<Result<Paginated<Product>>> products({
    int page,
    int perPage,
    int? categoryId,
    String? search,
  });

  /// `GET /products/{id}` — the only endpoint that carries availability.
  Future<Result<Product>> product(int id);

  /// `POST /products` as multipart. Admin only.
  Future<Result<Product>> create(NewProduct draft);
}
