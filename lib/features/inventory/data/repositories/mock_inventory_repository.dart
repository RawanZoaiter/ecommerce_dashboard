import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/mock/mock_seed.dart';
import '../../../../core/mock/mock_support.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/inventory_repository.dart';

/// Sample-data implementation of [InventoryRepository].
///
/// Nothing on the server backs this yet: the quantities belong to the
/// ASP.NET inventory service, and the frontend is not permitted to call it
/// directly. The screen is built so it is ready the day Laravel exposes a
/// stock route of its own.
class MockInventoryRepository with MockSupport implements InventoryRepository {
  final List<StockItem> _stock = [...MockSeed.stock];

  @override
  Future<Result<Paginated<StockItem>>> stock({
    int page = 1,
    int perPage = 15,
  }) async {
    await settle();

    // Products needing attention first: no record, then sold out, then low.
    final sorted = _stock.toList()
      ..sort((a, b) => _urgency(a).compareTo(_urgency(b)));

    return Ok(paginate(sorted, page: page, perPage: perPage));
  }

  @override
  Future<Result<StockItem>> setQuantity({
    required int productId,
    required int quantity,
  }) async {
    await settle();

    final index = _stock.indexWhere((item) => item.productId == productId);
    if (index == -1) return const Err(NotFoundFailure());

    final current = _stock[index];
    final updated = StockItem(
      productId: current.productId,
      productName: current.productName,
      imageUrl: current.imageUrl,
      quantityOnHand: quantity,
      updatedAt: DateTime.now(),
    );
    _stock[index] = updated;
    return Ok(updated);
  }

  int _urgency(StockItem item) {
    if (!item.hasRecord) return 0;
    if (item.isSoldOut) return 1;
    if (item.isLow) return 2;
    return 3;
  }
}
