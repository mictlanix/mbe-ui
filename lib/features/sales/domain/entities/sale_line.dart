import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/network/photo_url.dart';

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
    // The product's photo as a fetchable URL — mbe-api#157, which put it on
    // both shapes a till reads so a resumed sale's own lines are not the blank
    // ones. Already resolved through `resolvePhotoUrl`, so a call site hands it
    // straight to `ProductPhoto`. Null for a product with no photo.
    String? photo,
    required String quantity,
    // Nullable since spec 040: absent on a quote line. Has exactly one
    // reader anywhere in `lib/` — this file's own mapping — verified by
    // grep (data-model.md §2).
    String? cost,
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
    // Quote-only (spec 040, data-model.md §2): the quote's absolute per-line
    // markup. Mapped in so the value round-trips, but **read-only in v1**
    // (spec A3) — no shared widget writes it. `null` on an order line, which
    // has no such field.
    String? priceAdjustment,
  }) = _SaleLine;

  factory SaleLine.fromResponse(api.SalesOrderLineResponse r) => SaleLine(
    id: r.salesOrderDetailId,
    product: r.product,
    productCode: r.productCode,
    productName: r.productName,
    unit: unitLabelOf(r.unitOfMeasurement),
    photo: resolvePhotoUrl(r.photo),
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

  /// Maps a quote line onto the same entity an order line uses (spec 040,
  /// data-model.md §2). Leaves `cost`, `unit`, `photo` and `warehouse`
  /// null — none exist on a quote line — and maps `priceAdjustment`, which
  /// no order line has.
  factory SaleLine.fromQuoteLineResponse(api.SalesQuoteLineResponse r) =>
      SaleLine(
        id: r.salesQuoteDetailId,
        product: r.product,
        productCode: r.productCode,
        productName: r.productName,
        quantity: r.quantity,
        price: r.price,
        discountRate: r.discountRate,
        taxRate: r.taxRate,
        taxIncluded: r.taxIncluded,
        comment: r.comment,
        subtotal: r.subtotal,
        taxTotal: r.taxTotal,
        total: r.total,
        priceAdjustment: r.priceAdjustment,
      );
}
