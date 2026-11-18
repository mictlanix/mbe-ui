import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';

part 'product_stock_controller.g.dart';

/// The facility a warehouse belongs to.
typedef WarehouseFacility = ({int facilityId, String facilityName});

/// What the product view shows (spec 071 research R6): the product's stock,
/// its code and name for the title, and the facility of each listed
/// warehouse.
class ProductStockView {
  const ProductStockView({
    required this.stock,
    required this.code,
    required this.name,
    required this.facilities,
  });

  final ProductStock stock;
  final String code;
  final String name;

  /// Keyed by warehouse id. A warehouse whose lookup failed is absent.
  final Map<int, WarehouseFacility> facilities;
}

/// One product's stock in every warehouse, keyed by product id (spec 071
/// US2). A failed stock load keeps the repository's `AppError` (a missing
/// product is a `NotFound`). The name and facility lookups never fail the
/// view: they only label it.
@riverpod
class ProductStockController extends _$ProductStockController {
  @override
  Future<ProductStockView> build(int productId) async {
    final products = ref.watch(productRepositoryProvider);
    final warehouses = ref.watch(warehouseRepositoryProvider);
    final stock = await ref.watch(stockRepositoryProvider).product(productId);

    // `ProductStock` carries no name, so it comes from the catalog. A
    // stock-only supervisor may lack Products read: then the server's row
    // names stand in, or the id.
    var code = '#$productId';
    var name = '';
    try {
      final product = await products.get(productId: productId);
      code = product.code;
      name = product.name;
    } catch (_) {
      if (stock.warehouses.isNotEmpty) {
        code = stock.warehouses.first.productCode;
        name = stock.warehouses.first.productName;
      }
    }

    // `StockRow` carries only the warehouse id: resolve each distinct
    // warehouse once for its facility.
    final ids = {for (final row in stock.warehouses) row.warehouseId};
    Future<(int, WarehouseFacility)?> facilityOf(int id) async {
      try {
        final w = await warehouses.get(warehouseId: id);
        return (id, (facilityId: w.facilityId, facilityName: w.facilityName));
      } catch (_) {
        return null;
      }
    }

    final resolved = await Future.wait(ids.map(facilityOf));

    return ProductStockView(
      stock: stock,
      code: code,
      name: name,
      facilities: {
        for (final entry in resolved)
          if (entry != null) entry.$1: entry.$2,
      },
    );
  }
}
