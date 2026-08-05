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
    String? customerName,
    required String total,
    required String balance,
    required SaleStatus status,
    required DateTime date,
  }) = _OpenSale;

  factory OpenSale.fromResponse(api.SalesOrderSummary r) => OpenSale(
    id: r.salesOrderId,
    serial: r.serial,
    customerName: r.customerName,
    total: r.total,
    balance: r.balance,
    status: SaleStatus.fromApi(r.status),
    date: r.date,
  );
}
