import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'open_sale.freezed.dart';

/// One row in the open-sales selector (data-model.md §8), from
/// `GET /sales-orders?point_sale=<id>` (resolved, research.md §5 — scoped
/// to the cashier's own register, not the whole facility).
@freezed
class OpenSale with _$OpenSale {
  const factory OpenSale({
    required int id,
    int? serial,

    /// The per-document name **override** — mbe's data dictionary calls this
    /// column "Override customer name on docs", and mbe-api sets it only
    /// from what a client sends. `null` on every ordinary sale, walk-in ones
    /// included, which is why it is not the name a row shows on its own
    /// (mictlanix/mbe-api#172).
    String? customerName,

    /// The customer's own name, joined from the sale's customer by mbe-api
    /// (mictlanix/mbe-api#173). This is what a row displays when the sale
    /// carries no override — and it is why nothing here has to resolve a
    /// customer per row any more.
    ///
    /// Nullable because the field is optional in the schema: a deployment
    /// running an mbe-api older than #173 simply omits it, and the row falls
    /// back to the override and then to a dash rather than breaking.
    String? customerDisplayName,
    required String total,
    required String balance,
    required SaleStatus status,
    required DateTime date,
  }) = _OpenSale;

  factory OpenSale.fromResponse(api.SalesOrderSummary r) => OpenSale(
    id: r.salesOrderId,
    serial: r.serial,
    customerName: r.customerName,
    customerDisplayName: r.customerDisplayName,
    total: r.total,
    balance: r.balance,
    status: SaleStatus.fromApi(r.status),
    date: r.date,
  );
}

/// What a list row calls the customer of [sale].
///
/// The **override wins**: a sale carrying `customerName` is one whose
/// document deliberately names someone other than the customer on file
/// ("Override customer name on docs"), and a list that quietly showed the
/// customer record instead would be contradicting the document it is
/// summarizing. Every ordinary sale has no override, so in practice this
/// resolves to [OpenSale.customerDisplayName] — the name mbe-api now joins
/// in per page (mictlanix/mbe-api#173).
///
/// Falls through to a dash only when neither is known, which now means an
/// mbe-api older than #173 *and* no override.
String posSaleCustomerLabel(OpenSale sale) {
  final override = sale.customerName;
  if (override != null && override.isNotEmpty) return override;
  final resolved = sale.customerDisplayName;
  if (resolved != null && resolved.isNotEmpty) return resolved;
  return '—';
}
