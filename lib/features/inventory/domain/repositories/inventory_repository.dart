import '../../../../core/error/result.dart';
import '../../../../core/network/api_response.dart';
import '../entities/stock_item.dart';

abstract interface class InventoryRepository {
  /// Stock for every product. Needs either `available_quantity` on the product
  /// list endpoint or a dedicated Laravel route; reading it per product from
  /// the details endpoint would be one request per row.
  Future<Result<Paginated<StockItem>>> stock({int page, int perPage});

  /// Sets a product's quantity, creating the record when it has none.
  ///
  /// This is the gap that matters most: a product added through the dashboard
  /// has no stock record, so it cannot be ordered until something writes one.
  Future<Result<StockItem>> setQuantity({
    required int productId,
    required int quantity,
  });
}
