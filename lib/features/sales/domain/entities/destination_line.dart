import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

part 'destination_line.freezed.dart';

/// One sale line's share of a destination (data-model.md §5.1) — the link
/// back to the sale line ([salesOrderDetail]) plus the quantity this
/// destination takes.
///
/// The wire record also carries `committedQuantity`, `deliveredQuantity`,
/// `openQuantity` and `returnedQuantity` — the logistics module's fulfilment
/// progress. None are mapped: a destination created by the POS is always
/// `draft`, where they are either zero or equal to [quantity], and the
/// distribution panel reconciles against the *sale*, never against delivery
/// progress.
@freezed
class DestinationLine with _$DestinationLine {
  const factory DestinationLine({
    required int id,
    int? salesOrderDetail,
    required int product,
    required String productCode,
    required String productName,
    required String quantity,
    int? warehouse,
  }) = _DestinationLine;

  factory DestinationLine.fromResponse(api.DeliveryOrderLineResponse r) =>
      DestinationLine(
        id: r.deliveryOrderDetailId,
        salesOrderDetail: r.salesOrderDetail,
        product: r.product,
        productCode: r.productCode,
        productName: r.productName,
        quantity: r.quantity,
        warehouse: r.warehouse,
      );
}
