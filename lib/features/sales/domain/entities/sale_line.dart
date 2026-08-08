import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

part 'sale_line.freezed.dart';

/// The short label for a SAT unit of measurement: its symbol when it has
/// one, otherwise its full name. Shared by [SaleLine] and
/// `ProductLookupResult`, which map the same expanded record (mbe-api#145).
String? unitLabelOf(api.SatUnitOfMeasurementResponse? unit) {
  if (unit == null) return null;
  final symbol = unit.symbol;
  return (symbol != null && symbol.isNotEmpty) ? symbol : unit.name;
}

/// One product on the sale (data-model.md §2), mapped from
/// `SalesOrderLineResponse`. Every field the cashier can touch is editable
/// in place — quantity, price, discount rate, tax rate and warehouse
/// (FR-023, resolved 2026-08-05: mbe-api#135 shipped a writable line tax
/// rate, so nothing here is read-only).
@freezed
class SaleLine with _$SaleLine {
  const factory SaleLine({
    required int id,
    required int product,
    required String productCode,
    required String productName,
    // The SAT unit's symbol when it has one ("Pza"), else its name
    // ("Pieza") — mbe-api#145. Null for a product with no unit on file.
    String? unit,
    required String quantity,
    required String cost,
    required String price,
    required String discountRate,
    required String taxRate,
    required bool taxIncluded,
    int? warehouse,
    String? comment,
    required String subtotal,
    required String taxTotal,
    required String total,
    // Joined from the most recent product-lookup response for the line's
    // chosen warehouse, not stored on the line itself (data-model.md §2) —
    // advisory only; the authoritative check happens at confirmation
    // (FR-025, FR-026).
    String? availability,
  }) = _SaleLine;

  factory SaleLine.fromResponse(api.SalesOrderLineResponse r) => SaleLine(
    id: r.salesOrderDetailId,
    product: r.product,
    productCode: r.productCode,
    productName: r.productName,
    unit: unitLabelOf(r.unitOfMeasurement),
    quantity: r.quantity,
    cost: r.cost,
    price: r.price,
    discountRate: r.discountRate,
    taxRate: r.taxRate,
    taxIncluded: r.taxIncluded,
    warehouse: r.warehouse,
    comment: r.comment,
    subtotal: r.subtotal,
    taxTotal: r.taxTotal,
    total: r.total,
  );
}
