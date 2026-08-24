import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';

part 'payment_controller.g.dart';

/// The tender being composed on the payment step — never the applied
/// payments themselves, which live server-side and are read back through
/// `orderPaymentsControllerProvider`.
class PaymentDraft {
  const PaymentDraft({
    this.amount = '',
    this.methodCode,
    this.paymentCharge,
    this.reference,
    this.requiresReference = false,
    this.submitting = false,
    this.error,
  });

  final String amount;
  final int? methodCode;
  final int? paymentCharge;
  final String? reference;
  final bool requiresReference;
  final bool submitting;
  final AppError? error;

  /// FR-046: a tender needs an amount, a method, and — when the chosen
  /// option says so (`PaymentMethodOption.requiresReference`) — a reference.
  bool get isSubmittable =>
      !submitting &&
      methodCode != null &&
      amount.isNotEmpty &&
      compareAmounts(amount, '0') > 0 &&
      (!requiresReference || (reference?.isNotEmpty ?? false));

  PaymentDraft copyWith({
    String? amount,
    int? methodCode,
    int? paymentCharge,
    String? reference,
    bool? requiresReference,
    bool? submitting,
    AppError? error,
    bool clearError = false,
  }) => PaymentDraft(
    amount: amount ?? this.amount,
    methodCode: methodCode ?? this.methodCode,
    paymentCharge: paymentCharge ?? this.paymentCharge,
    reference: reference ?? this.reference,
    requiresReference: requiresReference ?? this.requiresReference,
    submitting: submitting ?? this.submitting,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Amount entry, method selection, reference, and the create-then-apply
/// sequence (contracts/mbe-api-pos.md §3). After each successful
/// application it refreshes `PosSaleController` — applying a payment changes
/// `Sale.balance` through a *different* repository, so nothing updates it
/// automatically (contracts/pos-screen.md §3–§4) — and invalidates
/// `orderPaymentsControllerProvider` so the applied-payments panel follows.
@riverpod
class PaymentController extends _$PaymentController {
  @override
  PaymentDraft build() => const PaymentDraft();

  void setAmount(String amount) {
    state = state.copyWith(amount: amount, clearError: true);
  }

  void selectMethod({
    required int methodCode,
    int? paymentCharge,
    bool requiresReference = false,
  }) {
    state = state.copyWith(
      methodCode: methodCode,
      paymentCharge: paymentCharge,
      requiresReference: requiresReference,
      clearError: true,
    );
  }

  void setReference(String reference) {
    state = state.copyWith(reference: reference, clearError: true);
  }

  /// FR-047: the excess over the sale's balance, handed back rather than
  /// applied. Zero when the tender is at or under the balance.
  String changeFor(String balance) {
    if (state.amount.isEmpty) return '0';
    if (compareAmounts(state.amount, balance) <= 0) return '0';
    return subtractAmounts(state.amount, balance);
  }

  /// Registers this call in [pendingWritesProvider] for the whole of
  /// [action] — including [action]'s own state-publishing, which must
  /// happen *before* [action] returns so the count only reaches zero once
  /// the balance a gated step reads is already the sale's own (spec 031
  /// FR-003, research R6). [submit] and [reverse] both route through this.
  Future<T> _tracked<T>(Future<T> Function() action) =>
      ref.read(pendingWritesProvider(posWritesScope).notifier).track(action);

  /// Records the tender and applies it to [sale], then refreshes the sale
  /// and the applied-payments panel. Returns `true` when it went through;
  /// on refusal the draft is kept (contracts/pos-screen.md §6) and the
  /// reason is on `state.error`.
  Future<bool> submit(Sale sale) async {
    final draft = state;
    if (!draft.isSubmittable) return false;

    state = draft.copyWith(submitting: true, clearError: true);
    try {
      return await _tracked(() async {
        final repository = ref.read(customerPaymentRepositoryProvider);
        final change = changeFor(sale.balance);
        final applied = isZeroAmount(change) ? draft.amount : sale.balance;

        final paymentId = await repository.createPayment(
          customer: sale.customer,
          amount: draft.amount,
          method: draft.methodCode!,
          currency: sale.currency,
          paymentCharge: draft.paymentCharge,
          reference: draft.reference,
        );
        await repository.applyPayment(
          customerPaymentId: paymentId,
          salesOrder: sale.id,
          amount: applied,
          amountChange: isZeroAmount(change) ? null : change,
        );

        await ref.read(posSaleControllerProvider.notifier).refresh();
        ref.invalidate(orderPaymentsControllerProvider(sale.id));

        // Cleared for the next tender — a partial payment leaves a balance
        // the cashier goes straight on to collect.
        state = const PaymentDraft();
        return true;
      });
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }

  Future<void> reverse({
    required int saleId,
    required int customerPaymentId,
    required int applicationId,
    required String reason,
  }) => _tracked(() async {
    await ref
        .read(customerPaymentRepositoryProvider)
        .reverseApplication(
          customerPaymentId: customerPaymentId,
          applicationId: applicationId,
          reason: reason,
        );
    await ref.read(posSaleControllerProvider.notifier).refresh();
    ref.invalidate(orderPaymentsControllerProvider(saleId));
  });
}
