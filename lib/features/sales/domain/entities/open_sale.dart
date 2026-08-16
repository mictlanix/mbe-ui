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

    /// Who the sale is for. Carried because [customerName] is **not** the
    /// customer's name: mbe's data dictionary calls that column "Override
    /// customer name on docs", and mbe-api sets it only from what a client
    /// sends — so it is null on every ordinary sale, walk-in ones included.
    /// The name a list shows has to be resolved from this id, exactly as
    /// `CustomerBar` already does on the sale itself (FR-023).
    required int customer,

    /// The per-document name override, or `null` — see [customer].
    String? customerName,
    required String total,
    required String balance,
    required SaleStatus status,
    required DateTime date,
  }) = _OpenSale;

  factory OpenSale.fromResponse(api.SalesOrderSummary r) => OpenSale(
    id: r.salesOrderId,
    serial: r.serial,
    customer: r.customer,
    customerName: r.customerName,
    total: r.total,
    balance: r.balance,
    status: SaleStatus.fromApi(r.status),
    date: r.date,
  );
}
