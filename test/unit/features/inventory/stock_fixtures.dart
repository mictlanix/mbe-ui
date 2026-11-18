import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';

/// A stock row for tests; override what the case is about.
StockRow aStockRow({
  int productId = 7,
  String productCode = 'A-100',
  String productName = 'Tornillo 1/4 caja',
  int warehouseId = 3,
  String onHand = '10',
  String reserved = '2',
  String available = '8',
  String incoming = '0',
}) => StockRow(
  productId: productId,
  productCode: productCode,
  productName: productName,
  warehouseId: warehouseId,
  onHand: Decimal.parse(onHand),
  reserved: Decimal.parse(reserved),
  available: Decimal.parse(available),
  incoming: Decimal.parse(incoming),
);

/// A page of stock rows for tests: one row unless overridden.
StockPage aStockPage({List<StockRow>? items, int? total}) {
  final rows = items ?? [aStockRow()];
  return StockPage(items: rows, total: total ?? rows.length);
}

/// An in-transit holding for tests.
InTransitStock anInTransitStock({
  int facilityId = 2,
  int warehouseId = 9,
  String onHand = '4',
}) => InTransitStock(
  facilityId: facilityId,
  warehouseId: warehouseId,
  onHand: Decimal.parse(onHand),
);

/// A product's stock for tests: one warehouse and nothing in transit unless
/// overridden.
ProductStock aProductStock({
  int productId = 7,
  List<StockRow>? warehouses,
  List<InTransitStock> inTransit = const [],
}) => ProductStock(
  productId: productId,
  warehouses: warehouses ?? [aStockRow(productId: productId)],
  inTransit: inTransit,
);
