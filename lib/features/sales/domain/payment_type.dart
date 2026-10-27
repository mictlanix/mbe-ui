import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// What a customer payment record represents — mbe-api's `PaymentType`
/// (`customer_payment.payment_type`; spec 054 data-model.md §3).
///
/// The generated `api.PaymentType` is an `EnumClass` named `number0`…`number5`
/// after the wire values, so [fromApi] parses the number back out, the same
/// way `paymentMethodCodeFromApi` does for the payment method.
enum PaymentType {
  na(0),
  immediate(1),
  creditPayment(2),
  paymentInAdvance(3),
  creditNote(4),
  expense(5);

  const PaymentType(this.code);

  final int code;

  /// A code outside the six this client knows is a contract break, not a
  /// value to render blank: it surfaces as [AppError.server] so the screen
  /// shows its error state (spec 054 data-model.md §1).
  static PaymentType fromApi(api.PaymentType value) {
    final code = int.tryParse(value.name.replaceFirst('number', ''));
    for (final type in PaymentType.values) {
      if (type.code == code) return type;
    }
    throw const AppError.server();
  }
}

/// [type]'s label in the legacy system's own words (FR-017).
String paymentTypeLabel(AppLocalizations l10n, PaymentType type) =>
    switch (type) {
      PaymentType.na => l10n.paymentTypeNa,
      PaymentType.immediate => l10n.paymentTypeImmediate,
      PaymentType.creditPayment => l10n.paymentTypeCreditPayment,
      PaymentType.paymentInAdvance => l10n.paymentTypePaymentInAdvance,
      PaymentType.creditNote => l10n.paymentTypeCreditNote,
      PaymentType.expense => l10n.paymentTypeExpense,
    };
