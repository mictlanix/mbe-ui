import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';

/// Stock levels (spec 071), over the generated `StockApi`. Every method
/// throws `AppError` on failure.
abstract class StockRepository {
  /// `GET /stock?warehouse&q&include_zero&skip&limit`. [q] is sent only when
  /// non-empty; [limit] is at most 500.
  Future<StockPage> list({
    required int warehouseId,
    String q = '',
    required bool includeZero,
    required int skip,
    required int limit,
  });

  /// `GET /stock/products/{product}`: one product in every warehouse.
  Future<ProductStock> product(int productId);
}
