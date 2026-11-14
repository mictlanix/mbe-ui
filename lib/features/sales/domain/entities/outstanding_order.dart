import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'outstanding_order.freezed.dart';

/// A completed, uncancelled, unpaid order a payment can still be applied to,
/// mapped from `OutstandingOrderResponse` (spec 059 data-model.md).
///
/// [id] is the order number the app labels orders with (`#id`); [serial] is the
/// facility's folio, which an order may not have. Amounts stay as the API's
/// strings: arithmetic goes through `money.dart`.
@freezed
abstract class OutstandingOrder with _$OutstandingOrder {
  const factory OutstandingOrder({
    required int id,
    int? serial,
    required DateTime date,
    required DateTime dueDate,
    required Currency currency,
    required String total,
    required String balance,
  }) = _OutstandingOrder;

  factory OutstandingOrder.fromResponse(api.OutstandingOrderResponse r) =>
      OutstandingOrder(
        id: r.salesOrderId,
        serial: r.serial,
        date: r.date,
        dueDate: r.dueDate,
        currency: currencyFromApi(r.currency),
        total: r.total,
        balance: r.balance,
      );
}

/// One page of [OutstandingOrder]s and how many match in all.
class OutstandingOrderPage {
  const OutstandingOrderPage({required this.items, required this.total});

  final List<OutstandingOrder> items;
  final int total;
}
