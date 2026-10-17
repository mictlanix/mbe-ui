import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_confirm.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';

part 'payment_controller.g.dart';

/// A local, non-API reason a tender was refused (spec 047). Carried beside
/// [PaymentDraft.error], which stays for failures that came back from mbe-api.
enum PaymentIssue { amountRequired, sessionInvalid }

/// What a call to [PaymentController.tender] did.
enum TenderResult {
  /// A tender was already in flight; the tap was dropped (FR-017).
  ignored,

  /// Refused locally; the reason is on `PaymentDraft.issue`. No API call.
  refused,

  /// The method needs a reference — the UI asks for it and calls `tender`
  /// again with it.
  needsReference,

  applied,

  /// mbe-api refused; the reason is on `PaymentDraft.error`.
  failed,
}

/// The tender being composed on the payment step — never the applied
/// payments themselves, which live server-side and are read back through
/// `orderPaymentsControllerProvider`. The method is not part of it: tapping a
/// method tile *is* the tender (spec 047 R7), so the method, charge and
/// reference live only for the length of one `tender` call.
class PaymentDraft {
  const PaymentDraft({
    this.amount = '',
    this.submitting = false,
    this.error,
    this.issue,
  });

  final String amount;
  final bool submitting;
  final AppError? error;
  final PaymentIssue? issue;

  PaymentDraft copyWith({
    String? amount,
    bool? submitting,
    AppError? error,
    PaymentIssue? issue,
    bool clearError = false,
  }) => PaymentDraft(
    amount: amount ?? this.amount,
    submitting: submitting ?? this.submitting,
    error: clearError ? null : (error ?? this.error),
    issue: clearError ? null : (issue ?? this.issue),
  );
}

/// Amount entry and the create-then-apply sequence
/// (contracts/mbe-api-pos.md §3). After each successful
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

  /// FR-016: opens the step with the balance already in the amount field, so
  /// the common case — paying it all — is one tap on a method.
  void prefillAmount(String balance) {
    if (state.amount.isNotEmpty || isZeroAmount(balance)) return;
    state = state.copyWith(amount: balance);
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
  /// FR-003, research R6). [tender] and [reverse] both route through this.
  Future<T> _tracked<T>(Future<T> Function() action) =>
      ref.read(pendingWritesProvider(posWritesScope).notifier).track(action);

  /// spec 047 FR-005 / research R1: the session is re-read, never trusted from
  /// cache, immediately before money is booked — it may have expired or been
  /// closed since the screen rendered. A failed read counts as invalid.
  Future<bool> _sessionIsValid() async {
    try {
      final current = await ref.refresh(currentSessionControllerProvider.future);
      return current.isValid;
    } on Object {
      return false;
    }
  }

  /// Tapping a method tile (spec 047 US5): validates the draft amount, re-reads
  /// the cash session, then records the tender and applies it to [sale],
  /// refreshing the sale and the applied-payments panel. On refusal the draft
  /// is kept (contracts/pos-screen.md §6).
  ///
  /// A method that [requiresReference] returns [TenderResult.needsReference]
  /// until it is called again with a [reference] — nothing is applied without
  /// one.
  Future<TenderResult> tender(
    Sale sale, {
    required int methodCode,
    int? paymentCharge,
    bool requiresReference = false,
    String? reference,
  }) async {
    if (state.submitting) return TenderResult.ignored;

    final amount = state.amount;
    if (amount.isEmpty || compareAmounts(amount, '0') <= 0) {
      state = state.copyWith(issue: PaymentIssue.amountRequired);
      return TenderResult.refused;
    }

    // Held through the session re-read too, so a second tap cannot slip in.
    state = state.copyWith(submitting: true, clearError: true);
    if (!await _sessionIsValid()) {
      state = state.copyWith(submitting: false, issue: PaymentIssue.sessionInvalid);
      return TenderResult.refused;
    }
    if (requiresReference && (reference?.isEmpty ?? true)) {
      state = state.copyWith(submitting: false);
      return TenderResult.needsReference;
    }

    // spec 036 FR-008/R1: the sale is confirmed here, immediately before the
    // first payment — not earlier, at Venta→Cobro. A no-op once already
    // confirmed. A failure is routed to Venta's own banner and this tender
    // aborts without ever setting the payment draft's own error, since the
    // failure is about the sale, not this tender.
    try {
      await confirmBeforePayableAction(ref.read, sale);
    } on AppError {
      state = state.copyWith(submitting: false);
      return TenderResult.failed;
    }

    try {
      return await _tracked(() async {
        final repository = ref.read(customerPaymentRepositoryProvider);
        final change = changeFor(sale.balanceOrZero);
        final applied = isZeroAmount(change) ? amount : sale.balanceOrZero;

        final paymentId = await repository.createPayment(
          customer: sale.customer,
          amount: amount,
          method: methodCode,
          currency: sale.currency,
          paymentCharge: paymentCharge,
          reference: reference,
        );
        await repository.applyPayment(
          customerPaymentId: paymentId,
          salesOrder: sale.id,
          amount: applied,
          amountChange: isZeroAmount(change) ? null : change,
        );

        await ref.read(posSaleControllerProvider.notifier).refresh();
        ref.invalidate(orderPaymentsControllerProvider(sale.id));

        // FR-016: the next tender starts from what is still owed — a partial
        // payment leaves a balance the cashier goes straight on to collect.
        final remaining = ref.read(posSaleControllerProvider).value?.balanceOrZero;
        state = PaymentDraft(
          amount: remaining == null || isZeroAmount(remaining) ? '' : remaining,
        );
        return TenderResult.applied;
      });
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return TenderResult.failed;
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
