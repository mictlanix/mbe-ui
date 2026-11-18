import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock.freezed.dart';

/// One product in one warehouse: an Existencias row, and one warehouse of
/// the product view. Quantities come from the server as they are, negatives
/// included.
@freezed
abstract class StockRow with _$StockRow {
  const factory StockRow({
    required int productId,

    /// Empty when the server sends none.
    required String productCode,
    required String productName,
    required int warehouseId,
    required Decimal onHand,
    required Decimal reserved,
    required Decimal available,
    required Decimal incoming,
  }) = _StockRow;
}

/// A page of the Existencias list.
@freezed
abstract class StockPage with _$StockPage {
  const factory StockPage({required List<StockRow> items, required int total}) =
      _StockPage;
}

/// Stock held in an in-transit location (a transfer on its way).
@freezed
abstract class InTransitStock with _$InTransitStock {
  const factory InTransitStock({
    required int facilityId,
    required int warehouseId,
    required Decimal onHand,
  }) = _InTransitStock;
}

/// One product's stock in every warehouse.
@freezed
abstract class ProductStock with _$ProductStock {
  const ProductStock._();

  const factory ProductStock({
    required int productId,
    required List<StockRow> warehouses,
    required List<InTransitStock> inTransit,
  }) = _ProductStock;

  /// The four figures summed over [warehouses]. Only the sums are computed
  /// here; each row's figures are the server's.
  StockTotals get totals {
    var onHand = Decimal.zero;
    var reserved = Decimal.zero;
    var available = Decimal.zero;
    var incoming = Decimal.zero;
    for (final row in warehouses) {
      onHand += row.onHand;
      reserved += row.reserved;
      available += row.available;
      incoming += row.incoming;
    }
    return StockTotals(
      onHand: onHand,
      reserved: reserved,
      available: available,
      incoming: incoming,
    );
  }

  bool get isEmpty => warehouses.isEmpty && inTransit.isEmpty;
}

/// The totals of a product's stock over its warehouses.
@freezed
abstract class StockTotals with _$StockTotals {
  const factory StockTotals({
    required Decimal onHand,
    required Decimal reserved,
    required Decimal available,
    required Decimal incoming,
  }) = _StockTotals;
}
