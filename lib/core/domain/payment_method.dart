import 'package:mbe_ui/l10n/app_localizations.dart';

/// Payment method codes for a Payment Method Option, mirroring mbe-api's
/// authoritative `PaymentMethod` constant (`Model/Constants/PaymentMethod.cs`,
/// documented at `mbe-api/docs/constants.md` §PaymentMethod) — the SAT-aligned
/// *forma de pago* catalog, plus one non-SAT mbe extension.
///
/// Hand-written because `PaymentMethodOptionResponse`/`Create`/`Update` expose
/// `paymentMethod` as a bare `int` with no generated enum and no SAT catalog
/// endpoint to pick from (spec 015 research.md §5) — shape mirrors
/// [FacilityType]/[Gender] in `lib/core/domain/`. Codes are **non-contiguous**
/// (gaps at 7, 9-11, 13-26, ...), so this is an explicit `{code: member}` map,
/// not an ordinal-indexed list.
enum PaymentMethod {
  na(0),
  cash(1),
  check(2),
  eft(3),
  creditCard(4),
  electronicPurse(5),
  electronicMoney(6),
  foodVouchers(8),
  giving(12),
  toTheSatisfactionOfTheCreditor(27),
  debitCard(28),
  serviceCard(29),
  advancePayments(30),
  toBeDefined(99),

  // FIXME(payment-method): non-SAT mbe extension (mbe-api/docs/constants.md
  // §PaymentMethod) — confirm whether to keep this member; isolated on its
  // own line so removing it is a one-line change.
  governmentFunding(1001);

  const PaymentMethod(this.code);

  /// The integer mbe-api serializes this payment method as.
  final int code;

  /// Looks up the [PaymentMethod] whose [code] matches mbe-api's
  /// `payment_method` integer. Returns `null` for an unrecognized code —
  /// callers MUST fall back to rendering the raw code rather than crash,
  /// same posture as [FacilityType.fromValue]/[Gender.fromValue].
  static PaymentMethod? fromCode(int code) {
    for (final method in PaymentMethod.values) {
      if (method.code == code) return method;
    }
    return null;
  }
}

/// [code]'s localized label, falling back to the raw code for an unmapped
/// value — [PaymentMethod.fromCode]'s documented posture.
///
/// Promoted from two byte-identical private copies
/// (`payment_method_option_detail_screen.dart`,
/// `payment_method_options_list_screen.dart`) that had drifted into existing
/// as duplicates rather than a shared function (021-cash-sessions research.md
/// §13) — this feature's session-detail screen needed the same mapping for
/// `payments_by_method`, which would have made a third copy.
String paymentMethodLabel(AppLocalizations l10n, int code) {
  final method = PaymentMethod.fromCode(code);
  if (method == null) return '$code';
  return switch (method) {
    PaymentMethod.na => l10n.paymentMethodNa,
    PaymentMethod.cash => l10n.paymentMethodCash,
    PaymentMethod.check => l10n.paymentMethodCheck,
    PaymentMethod.eft => l10n.paymentMethodEft,
    PaymentMethod.creditCard => l10n.paymentMethodCreditCard,
    PaymentMethod.electronicPurse => l10n.paymentMethodElectronicPurse,
    PaymentMethod.electronicMoney => l10n.paymentMethodElectronicMoney,
    PaymentMethod.foodVouchers => l10n.paymentMethodFoodVouchers,
    PaymentMethod.giving => l10n.paymentMethodGiving,
    PaymentMethod.toTheSatisfactionOfTheCreditor =>
      l10n.paymentMethodCreditorSatisfaction,
    PaymentMethod.debitCard => l10n.paymentMethodDebitCard,
    PaymentMethod.serviceCard => l10n.paymentMethodServiceCard,
    PaymentMethod.advancePayments => l10n.paymentMethodAdvancePayments,
    PaymentMethod.toBeDefined => l10n.paymentMethodToBeDefined,
    PaymentMethod.governmentFunding => l10n.paymentMethodGovernmentFunding,
  };
}
