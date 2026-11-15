import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';

part 'delivery_order_actions.g.dart';

/// Every write on a delivery order (spec 061 R6): header and line edits on a
/// draft, and the status actions.
///
/// Each method answers the [AppError] the server refused with, or `null` when
/// it went through, rather than throwing: the dialog that asked shows the
/// refusal where the user is looking. A [NetworkError] means the request may
/// or may not have landed (a lost connection or a timeout with no response):
/// the dialog shows it as an unknown result (`deliveryOrderActionUnknown`),
/// not as a refusal.
///
/// The order (with its events) is always invalidated, so the detail screen
/// refetches what the server now holds (FR-023): the new order is never taken
/// from the write's response. The list and the approval queue are invalidated
/// too unless the server refused, since only then is it known that nothing
/// changed. Every write refreshes the queue, not only approve and reject: a
/// cancel of an order waiting for approval takes it out of the queue too
/// (spec 062 R6).
///
/// [approve] and [reject] (spec 062) also answer the status the server put
/// the order in, taken from the write's response and used only to word the
/// confirmation message.
///
/// Keep-alive because a write outlives the dialog that started it: the
/// provider must not dispose between the request and its refresh.
@Riverpod(keepAlive: true)
class DeliveryOrderActions extends _$DeliveryOrderActions {
  @override
  void build() {}

  /// `POST /delivery-orders/{id}/confirm`.
  Future<AppError?> confirm(int id) =>
      _run(id, (repository) => repository.confirm(id));

  /// `POST /delivery-orders/{id}/cancel`. [reason] is sent as given: the
  /// dialog trims it and requires it non-empty.
  Future<AppError?> cancel(int id, {required String reason}) =>
      _run(id, (repository) => repository.cancel(id: id, reason: reason));

  /// `POST /delivery-orders/{id}/requeue`.
  Future<AppError?> requeue(int id) =>
      _run(id, (repository) => repository.requeue(id));

  /// `POST /delivery-orders/approval/{id}/approve`. Answers the status the
  /// server moved the order to: En preparación for a delivery, Aprobada for a
  /// pickup (spec 062 FR-009).
  Future<ApprovalOutcome> approve(int id) =>
      _runForStatus(id, (repository) => repository.approve(id));

  /// `POST /delivery-orders/approval/{id}/reject`. [reason] is sent as given:
  /// the dialog trims it and requires it non-empty. The order goes back to
  /// Borrador (spec 062 FR-012).
  Future<ApprovalOutcome> reject(int id, {required String reason}) =>
      _runForStatus(
        id,
        (repository) => repository.reject(id: id, reason: reason),
      );

  /// `POST /delivery-orders/{id}/ready-for-pickup`.
  Future<AppError?> markReady(int id) =>
      _run(id, (repository) => repository.markReadyForPickup(id));

  /// `POST /delivery-orders/{id}/pickup`, with the photo's bytes.
  Future<AppError?> confirmPickup(
    int id, {
    required String receiverName,
    required String receiverIdShown,
    required Uint8List bytes,
    required String filename,
  }) => _run(
    id,
    (repository) => repository.confirmPickup(
      id: id,
      receiverName: receiverName,
      receiverIdShown: receiverIdShown,
      bytes: bytes,
      filename: filename,
    ),
  );

  /// `PUT /delivery-orders/{id}`. A null field is left as it is.
  Future<AppError?> updateHeader(
    int id, {
    int? priority,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  }) => _run(
    id,
    (repository) => repository.updateHeader(
      id: id,
      priority: priority,
      shipTo: shipTo,
      contact: contact,
      date: date,
      comment: comment,
    ),
  );

  /// `POST /delivery-orders/{id}/lines`.
  Future<AppError?> addLine(
    int id, {
    required int salesOrderDetail,
    required Decimal quantity,
  }) => _run(
    id,
    (repository) => repository.addLine(
      id: id,
      salesOrderDetail: salesOrderDetail,
      quantity: quantity.toString(),
    ),
  );

  /// `PUT /delivery-orders/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(
    int id, {
    required int lineId,
    required Decimal quantity,
  }) => _run(
    id,
    (repository) => repository.updateLine(
      id: id,
      lineId: lineId,
      quantity: quantity.toString(),
    ),
  );

  /// `DELETE /delivery-orders/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, {required int lineId}) =>
      _run(id, (repository) => repository.removeLine(id: id, lineId: lineId));

  Future<AppError?> _run(
    int id,
    Future<Object?> Function(DeliveryOrderAdminRepository repository) write,
  ) async => (await _runForStatus(id, (repository) async {
    await write(repository);
    return null;
  })).error;

  /// The one write path: runs [write], then refreshes what it may have
  /// changed. [write] answers the order the server returned, or `null` for the
  /// writes whose response nobody reads.
  Future<ApprovalOutcome> _runForStatus(
    int id,
    Future<DeliveryOrder?> Function(DeliveryOrderAdminRepository repository)
    write,
  ) async {
    AppError? error;
    DeliveryOrderStatus? status;
    try {
      status = (await write(
        ref.read(deliveryOrderAdminRepositoryProvider),
      ))?.status;
    } on AppError catch (e) {
      error = e;
    }
    ref.invalidate(deliveryOrderDetailControllerProvider(id));
    if (error == null || error is NetworkError) {
      ref.invalidate(deliveryOrdersListControllerProvider);
      ref.invalidate(deliveryOrderApprovalQueueControllerProvider);
    }
    return (error: error, status: status);
  }
}

/// What `approve` and `reject` answer: `error` is the refusal (or a
/// [NetworkError] for an unknown result), `status` is the order's new status
/// when the server accepted.
typedef ApprovalOutcome = ({AppError? error, DeliveryOrderStatus? status});
