import 'dart:typed_data';

import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';

/// One page of the delivery orders list, with the total behind the filter.
class DeliveryOrderPage {
  const DeliveryOrderPage({required this.items, required this.total});

  final List<DeliveryOrderSummary> items;
  final int total;
}

/// Back-office delivery orders (spec 061 R2), over the same generated
/// `DeliveryOrdersApi` as the POS `DeliveryOrderRepository`.
abstract class DeliveryOrderAdminRepository {
  /// `GET /delivery-orders?status=&customer=&facility=&fulfillment_type=
  /// &sales_order=&date_from=&date_to=&search=&skip=&limit=`. Never sends
  /// `mine`.
  Future<DeliveryOrderPage> list({
    DeliveryOrderStatus? status,
    int? customer,
    int? facility,
    FulfillmentType? type,
    int? salesOrder,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /delivery-orders/{id}`.
  Future<DeliveryOrder> getById(int id);

  /// `GET /delivery-orders/{id}/events` — the status history.
  Future<List<DeliveryOrderEvent>> events(int id);

  /// `GET /delivery-orders/{id}/proof`.
  Future<ProofOfDelivery> proof(int id);

  /// `GET /delivery-orders/{id}/proof-image` — PNG bytes. A body that is not
  /// a PNG is refused as a server error.
  Future<Uint8List> proofImage(int id);

  /// `PUT /delivery-orders/{id}` — header edits on a draft. A null field is
  /// left unchanged: the server ignores nulls, so nothing can be cleared.
  Future<DeliveryOrder> updateHeader({
    required int id,
    int? priority,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  });

  /// `POST /delivery-orders/{id}/lines`.
  Future<DeliveryOrder> addLine({
    required int id,
    required int salesOrderDetail,
    required String quantity,
  });

  /// `PUT /delivery-orders/{id}/lines/{lineId}`.
  Future<DeliveryOrder> updateLine({
    required int id,
    required int lineId,
    required String quantity,
  });

  /// `DELETE /delivery-orders/{id}/lines/{lineId}`.
  Future<DeliveryOrder> removeLine({required int id, required int lineId});

  /// `POST /delivery-orders/{id}/confirm`.
  Future<DeliveryOrder> confirm(int id);

  /// `POST /delivery-orders/{id}/cancel`.
  Future<DeliveryOrder> cancel({required int id, required String reason});

  /// `POST /delivery-orders/{id}/requeue`.
  Future<DeliveryOrder> requeue(int id);

  /// `POST /delivery-orders/{id}/ready-for-pickup`.
  Future<DeliveryOrder> markReadyForPickup(int id);

  /// `POST /delivery-orders/{id}/pickup` — multipart: receiver name, the ID
  /// the receiver showed, and the image.
  Future<DeliveryOrder> confirmPickup({
    required int id,
    required String receiverName,
    required String receiverIdShown,
    required Uint8List bytes,
    required String filename,
  });
}
