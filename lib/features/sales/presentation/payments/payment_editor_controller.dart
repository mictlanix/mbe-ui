import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_controller.dart';

part 'payment_editor_controller.g.dart';

/// The back office's two writes on an existing payment (spec 059 R3):
/// reversing one of its applications and applying its unapplied money to an
/// order.
///
/// Not `PaymentController`: that one is the register's, and its reverse
/// refreshes the register's sale and tracks under the register's write scope.
/// Here a write refreshes what the back office is showing instead — the
/// payment, its applications, the Pagos list, the order's payments and the
/// order itself, whose paid status the write may have changed.
///
/// Both mutations answer the [AppError] the server refused with, or `null`
/// when it went through, rather than throwing: the dialog that asked shows the
/// refusal where the user is looking. Either way what was on screen is
/// invalidated, because a refusal means the screen was out of date (an order
/// settled, a payment applied elsewhere) and the fresh read is what the user
/// needs next (FR-009).
///
/// Keep-alive because a write outlives the dialog that started it: the
/// provider must not dispose between the request and its refresh.
@Riverpod(keepAlive: true)
class PaymentEditor extends _$PaymentEditor {
  @override
  void build() {}

  /// `POST /customer-payments/{paymentId}/applications/{applicationId}/reverse`.
  /// [reason] is sent as given: the caller trims it and requires it non-empty.
  Future<AppError?> reverse({
    required int paymentId,
    required int applicationId,
    required int saleId,
    required String reason,
  }) => _run(
    paymentId: paymentId,
    saleId: saleId,
    write: () => ref
        .read(customerPaymentRepositoryProvider)
        .reverseApplication(
          customerPaymentId: paymentId,
          applicationId: applicationId,
          reason: reason,
        ),
  );

  /// `POST /customer-payments/{paymentId}/applications`. No change is given
  /// back from the back office (FR-008); that stays a register action.
  Future<AppError?> apply({
    required int paymentId,
    required int saleId,
    required String amount,
  }) => _run(
    paymentId: paymentId,
    saleId: saleId,
    write: () => ref
        .read(customerPaymentRepositoryProvider)
        .applyPayment(
          customerPaymentId: paymentId,
          salesOrder: saleId,
          amount: amount,
        ),
  );

  Future<AppError?> _run({
    required int paymentId,
    required int saleId,
    required Future<void> Function() write,
  }) async {
    AppError? refusal;
    try {
      await write();
    } on AppError catch (e) {
      refusal = e;
    }
    ref.invalidate(paymentDetailProvider(paymentId));
    ref.invalidate(paymentApplicationsProvider(paymentId));
    ref.invalidate(paymentsListControllerProvider);
    ref.invalidate(orderPaymentsControllerProvider(saleId));
    ref.invalidate(orderEditorControllerProvider(saleId));
    return refusal;
  }
}
