import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verification_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_controller.dart';

part 'payment_verification_controller.g.dart';

/// The two writes of payment verification (spec 060 R4): verifying a payment
/// and rejecting it. Shared by the queue's row icons and the Pagos payment
/// view, so both refresh the same things.
///
/// Both answer the [AppError] the server refused with, or `null` when it went
/// through, rather than throwing: the dialog that asked shows the refusal
/// where the user is looking. Either way what was on screen is invalidated.
/// A refusal means the screen was out of date (someone else verified the
/// payment first), and a lost connection means the outcome is unknown; the
/// fresh read is what the user needs next in both cases.
///
/// Keep-alive because a write outlives the dialog that started it: the
/// provider must not dispose between the request and its refresh.
@Riverpod(keepAlive: true)
class PaymentVerification extends _$PaymentVerification {
  @override
  void build() {}

  /// `POST /customer-payments/{paymentId}/verify`. Irreversible.
  Future<AppError?> verify({required int paymentId}) => _run(
    paymentId: paymentId,
    write: () => ref
        .read(customerPaymentRepositoryProvider)
        .verify(customerPaymentId: paymentId),
  );

  /// `POST /customer-payments/{paymentId}/reject`. [reason] is sent as given:
  /// the dialog trims it and requires it non-empty. A rejection changes
  /// nothing the queue can read, so the payment stays listed.
  Future<AppError?> reject({required int paymentId, required String reason}) =>
      _run(
        paymentId: paymentId,
        write: () => ref
            .read(customerPaymentRepositoryProvider)
            .reject(customerPaymentId: paymentId, reason: reason),
      );

  Future<AppError?> _run({
    required int paymentId,
    required Future<Object?> Function() write,
  }) async {
    AppError? refusal;
    try {
      await write();
    } on AppError catch (e) {
      refusal = e;
    }
    ref.invalidate(verificationQueueControllerProvider);
    ref.invalidate(paymentDetailProvider(paymentId));
    ref.invalidate(paymentsListControllerProvider);
    return refusal;
  }
}
