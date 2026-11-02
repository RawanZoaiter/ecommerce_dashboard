import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/mock/mock_seed.dart';
import '../../../../core/mock/mock_support.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/new_product.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// Sample-data implementation of [ProductRepository].
///
/// Created products are kept in memory for the session so the "add product"
/// flow can be walked end to end, including the fact that a new product starts
/// with no stock record and therefore cannot be ordered.
class MockProductRepository with MockSupport implements ProductRepository {
  final List<Product> _products = [...MockSeed.products];

  @override
  Future<Result<List<Category>>> categories() async {
    await settle();
    return const Ok(MockSeed.categories);
  }

  @override
  Future<Result<Paginated<Product>>> products({
    int page = 1,
    int perPage = 15,
    int? categoryId,
    String? search,
  }) async {
    await settle();

    var filtered = _products.toList()
      ..sort((a, b) => b.id.compareTo(a.id)); // newest first, like the API

    if (categoryId != null) {
      filtered = filtered
          .where((product) => product.category.id == categoryId)
          .toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      filtered = filtered
          .where((product) => product.name.toLowerCase().contains(query))
          .toList();
    }

    // The list endpoint carries no quantity, so rows must not pretend to know
    // one. Dropping it here keeps the mock honest about what the real list
    // response actually contains.
    final withoutQuantity = filtered
        .map(
          (product) =>
              product.copyWith(availability: const AvailabilityUnknown()),
        )
        .toList();

    return Ok(paginate(withoutQuantity, page: page, perPage: perPage));
  }

  @override
  Future<Result<Product>> product(int id) async {
    await settle();
    final match = _products.where((product) => product.id == id).firstOrNull;
    return match == null ? const Err(NotFoundFailure()) : Ok(match);
  }

  @override
  Future<Result<Product>> create(NewProduct draft) async {
    await settle();

    final nextId =
        _products.map((product) => product.id).reduce((a, b) => a > b ? a : b) +
        1;

    final created = Product(
      id: nextId,
      name: draft.name,
      description: draft.description,
      price: draft.price,
      category: MockSeed.categories.firstWhere(
        (category) => category.id == draft.categoryId,
      ),
      imageUrl: '',
      createdAt: DateTime.now(),
      // POST /products does not create a stock record, so the product really
      // does land unorderable. The UI warns about this rather than hiding it.
      availability: const NoStockRecord(),
    );

    _products.add(created);
    return Ok(created);
  }
}
