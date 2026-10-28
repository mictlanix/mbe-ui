import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/customer_credit_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_confirm.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';

part 'payment_controller.g.dart';

/// A local, non-API reason a tender was refused (spec 047). Carried beside
/// [PaymentDraft.error], which stays for failures that came back from mbe-api.
///
/// [creditPartlyApplied] is the one that is not a refusal: spending credit
/// notes applied some of them before one failed (spec 056), so it rides with
/// [PaymentDraft.creditApplied] *and* the server's own [PaymentDraft.error].
enum PaymentIssue {
  amountRequired,
  overpayNonCash,
  sessionInvalid,
  creditPartlyApplied,
}

/// Why a credit-note ticket cannot be redeemed on this sale (spec 056
/// FR-006, FR-006a). Kept apart from [PaymentIssue]: only the ticket dialog
/// shows these, so the payment step's own issue switch never has to.
enum CreditNoteRefusal {
  /// No credit note has that number — an unknown payment, a payment of another
  /// type, or one another facility's cashier cannot read (mbe-api#273 answers
  /// all three with a 404, so they cannot be told apart).
  notFound,

  /// The server reports nothing remaining on the note.
  usedUp,

  /// Already applied to this sale.
  alreadyOnSale,

  /// Issued to a different customer than the sale's.
  otherCustomer,
}

/// What [PaymentController.lookupCreditNoteTicket] found: exactly one of
/// [note] and [refusal] is set. [ownerName] accompanies
/// [CreditNoteRefusal.otherCustomer] only.
typedef CreditNoteLookup = ({
  CreditNote? note,
  CreditNoteRefusal? refusal,
  String? ownerName,
});

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
    this.lastChange,
    this.creditApplied,
  });

  final String amount;
  final bool submitting;
  final AppError? error;
  final PaymentIssue? issue;

  /// FR-020: the change owed after the last cash overpayment, kept until the
  /// cashier dismisses it, starts the next tender, or leaves the step. `null`
  /// when none is owed.
  final String? lastChange;

  /// spec 056: the credit applied before a later note failed, for the
  /// [PaymentIssue.creditPartlyApplied] message. `null` otherwise.
  final String? creditApplied;

  PaymentDraft copyWith({
    String? amount,
    bool? submitting,
    AppError? error,
    PaymentIssue? issue,
    String? creditApplied,
    bool clearError = false,
    bool clearLastChange = false,
  }) => PaymentDraft(
    amount: amount ?? this.amount,
    submitting: submitting ?? this.submitting,
    error: clearError ? null : (error ?? this.error),
    issue: clearError ? null : (issue ?? this.issue),
    lastChange: clearLastChange ? null : lastChange,
    creditApplied: clearError ? null : (creditApplied ?? this.creditApplied),
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

  void dismissChange() {
    state = state.copyWith(clearLastChange: true);
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
      final current = await ref.refresh(
        currentSessionControllerProvider.future,
      );
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

    // FR-018/FR-019: only cash may exceed the balance — a card or transfer
    // for more than is owed would book money that was never charged.
    if (methodCode != PaymentMethod.cash.code &&
        compareAmounts(amount, sale.balanceOrZero) > 0) {
      state = state.copyWith(issue: PaymentIssue.overpayNonCash);
      return TenderResult.refused;
    }

    // Held through the session re-read too, so a second tap cannot slip in.
    state = state.copyWith(
      submitting: true,
      clearError: true,
      clearLastChange: true,
    );
    if (!await _sessionIsValid()) {
      state = state.copyWith(
        submitting: false,
        issue: PaymentIssue.sessionInvalid,
      );
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
        final remaining = ref
            .read(posSaleControllerProvider)
            .value
            ?.balanceOrZero;
        state = PaymentDraft(
          amount: remaining == null || isZeroAmount(remaining) ? '' : remaining,
          lastChange: isZeroAmount(change) ? null : change,
        );
        return TenderResult.applied;
      });
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return TenderResult.failed;
    }
  }

  /// Spending credit notes (spec 056 FR-002, research R1/R3): applies each
  /// note's *existing* backing payment to [sale] — oldest first, as ordered by
  /// the caller — instead of creating a payment as [tender] does. The total is
  /// the smallest of [enteredAmount] (when given), the sale's balance and what
  /// the notes hold, and each note contributes no more than its own
  /// `remaining`. There is never change to hand back (FR-003).
  ///
  /// Applications are separate server writes, so they run one at a time and
  /// stop at the first failure: what was applied stays applied (an ordinary
  /// payment the cashier can see), and the draft reports how much. The sale,
  /// its applied payments and the customer's credit are re-read after every
  /// outcome (FR-008).
  Future<TenderResult> tenderCreditNotes(
    Sale sale,
    List<CreditNote> notes, {
    String? enteredAmount,
  }) async {
    if (state.submitting) return TenderResult.ignored;

    var target = sale.balanceOrZero;
    final entered = enteredAmount == null
        ? null
        : tryParseAmount(enteredAmount);
    if (entered != null && compareAmounts(entered, target) < 0) {
      target = entered;
    }
    final held = notes.fold('0', (sum, n) => addAmounts(sum, n.remaining));
    if (compareAmounts(held, target) < 0) target = held;
    if (compareAmounts(target, '0') <= 0) {
      state = state.copyWith(issue: PaymentIssue.amountRequired);
      return TenderResult.refused;
    }

    state = state.copyWith(
      submitting: true,
      clearError: true,
      clearLastChange: true,
    );
    if (!await _sessionIsValid()) {
      state = state.copyWith(
        submitting: false,
        issue: PaymentIssue.sessionInvalid,
      );
      return TenderResult.refused;
    }
    try {
      await confirmBeforePayableAction(ref.read, sale);
    } on AppError {
      state = state.copyWith(submitting: false);
      return TenderResult.failed;
    }

    try {
      return await _tracked(() async {
        final repository = ref.read(customerPaymentRepositoryProvider);
        var left = target;
        var appliedTotal = '0';
        AppError? failure;
        try {
          for (final note in notes) {
            if (compareAmounts(left, '0') <= 0) break;
            final use = compareAmounts(note.remaining, left) < 0
                ? note.remaining
                : left;
            if (compareAmounts(use, '0') <= 0) continue;
            await repository.applyPayment(
              customerPaymentId: note.customerPaymentId,
              salesOrder: sale.id,
              amount: use,
            );
            left = subtractAmounts(left, use);
            appliedTotal = addAmounts(appliedTotal, use);
          }
        } on AppError catch (e) {
          failure = e;
        }

        // FR-008: re-read whatever the outcome, so the balance on screen is
        // never one this call did not read back.
        await ref.read(posSaleControllerProvider.notifier).refresh();
        ref.invalidate(orderPaymentsControllerProvider(sale.id));
        ref.invalidate(customerCreditProvider(sale.id));

        final remaining = ref
            .read(posSaleControllerProvider)
            .value
            ?.balanceOrZero;
        final next = remaining == null || isZeroAmount(remaining)
            ? ''
            : remaining;
        if (failure == null) {
          state = PaymentDraft(amount: next);
          return TenderResult.applied;
        }
        final someApplied = compareAmounts(appliedTotal, '0') > 0;
        state = someApplied
            ? PaymentDraft(
                amount: next,
                error: failure,
                issue: PaymentIssue.creditPartlyApplied,
                creditApplied: appliedTotal,
              )
            : state.copyWith(submitting: false, error: failure);
        return TenderResult.failed;
      });
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return TenderResult.failed;
    }
  }

  /// Finds the credit note a walk-in ticket stands for (spec 056 FR-005,
  /// FR-006, FR-006a, research R4). The ticket number is the note's backing
  /// payment, so the payment is read first — for its type and customer — and
  /// the note second, for the server's own `remaining`.
  ///
  /// Refusals come back as a [CreditNoteLookup], not as errors. Anything else
  /// (a network failure, a 5xx) is an [AppError] for the caller to show.
  Future<CreditNoteLookup> lookupCreditNoteTicket(
    Sale sale,
    int ticketNumber,
  ) async {
    CreditNoteLookup refuse(CreditNoteRefusal why, {String? ownerName}) =>
        (note: null, refusal: why, ownerName: ownerName);

    final CustomerPayment payment;
    try {
      payment = await ref
          .read(customerPaymentRepositoryProvider)
          .get(customerPaymentId: ticketNumber);
    } on NotFoundError {
      return refuse(CreditNoteRefusal.notFound);
    }
    if (payment.type != PaymentType.creditNote) {
      return refuse(CreditNoteRefusal.notFound);
    }

    if (payment.customerId != sale.customer) {
      final name =
          payment.customerName ??
          await ref.read(
            customerDisplayNameProvider(payment.customerId).future,
          );
      return refuse(CreditNoteRefusal.otherCustomer, ownerName: name);
    }

    final applied = await ref.read(
      orderPaymentsControllerProvider(sale.id).future,
    );
    if (applied.any((p) => !p.cancelled && p.customerPayment == ticketNumber)) {
      return refuse(CreditNoteRefusal.alreadyOnSale);
    }

    final note = await ref
        .read(creditNoteRepositoryProvider)
        .findByPayment(ticketNumber);
    if (note == null) return refuse(CreditNoteRefusal.notFound);
    if (!note.isOpen) return refuse(CreditNoteRefusal.usedUp);
    return (note: note, refusal: null, ownerName: null);
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
