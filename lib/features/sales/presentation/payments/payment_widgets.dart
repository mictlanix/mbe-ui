import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// [amount] in its own currency, e.g. `$1,250.00 MXN` (spec 054 FR-016, R9).
/// The display formatter carries one configured symbol, so the ISO code is
/// what tells a dollar payment from a peso one.
String paymentAmountLabel(
  AppFormatters fmt,
  String amount,
  Currency currency,
) => '${fmt.display.currency(amount)} ${currencyCodeLabel(currency)}';

/// Verified / unverified chip (FR-017). The colour mapping stays here, in the
/// caller's file, per `StatusChip`'s own convention.
class PaymentVerifiedChip extends StatelessWidget {
  const PaymentVerifiedChip({super.key, required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<bool>(
      key: Key(verified ? 'payment_chip_verified' : 'payment_chip_unverified'),
      value: verified,
      label: verified ? l10n.paymentVerified : l10n.paymentUnverified,
      colors: (scheme) => verified
          ? (scheme.primaryContainer, scheme.onPrimaryContainer)
          : (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    );
  }
}

/// "Revertida" chip on a reversed application (FR-014).
class PaymentReversedChip extends StatelessWidget {
  const PaymentReversedChip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<String>(
      key: const Key('payment_chip_reversed'),
      value: 'reversed',
      label: l10n.paymentApplicationReversed,
      colors: (scheme) => (scheme.errorContainer, scheme.onErrorContainer),
    );
  }
}

/// A customer's name for [customerId], resolved once per distinct id by
/// `customerDisplayNameProvider` (research R2). While it loads the cell shows
/// "…"; if the lookup fails — a deleted customer, or a user without Customers
/// read — it falls back to the number, so one failed name never blanks a row
/// (FR-018).
class PaymentCustomerName extends ConsumerWidget {
  const PaymentCustomerName({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(customerDisplayNameProvider(customerId));
    final text = name.when(
      data: (value) => value ?? '#$customerId',
      loading: () => '…',
      error: (_, _) => '#$customerId',
    );
    return Tooltip(
      message: text,
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}

/// The payment's method, with the option's name appended when it has one —
/// `Tarjeta de crédito · 3 MSI`. A removed option falls back to its number.
class PaymentMethodText extends ConsumerWidget {
  const PaymentMethodText({super.key, required this.payment});

  final CustomerPayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final method = paymentMethodLabel(l10n, payment.methodCode);
    final optionId = payment.paymentOptionId;
    final option = optionId == null
        ? null
        : ref.watch(paymentMethodOptionNameProvider(optionId)).value ??
              '#$optionId';
    final text = option == null ? method : '$method · $option';
    return Tooltip(
      message: text,
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}
