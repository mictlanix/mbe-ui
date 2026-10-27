import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_access.dart';
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

/// Whether "Ver ticket" is offered for [payment] (spec 055 FR-001, FR-002,
/// FR-005): only the types the server renders a ticket for, and only to a user
/// who can read Customer Payments. One rule for the list row and the payment
/// view, so the two never disagree.
bool canShowPaymentTicket(
  AccessControlService access,
  CustomerPayment payment,
) =>
    payment.type.hasTicket &&
    canOpenDocument(access, DocumentKind.customerPaymentTicket);

/// The ticket of [payment], titled by its number (spec 055 R4).
DocumentRef paymentTicketRef(AppLocalizations l10n, CustomerPayment payment) =>
    DocumentRef(
      kind: DocumentKind.customerPaymentTicket,
      recordId: payment.customerPaymentId,
      title: l10n.documentPaymentTicketTitle(payment.customerPaymentId),
    );

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

/// The verified state as an icon, for the list column (spec 055): a filled
/// badge in the primary colour when verified, a greyed outline circle when
/// not. Unlike [PaymentVerifiedChip] it fits any column width, whatever the
/// label's length or language. The label is still there for a pointer
/// (tooltip) and a screen reader (semantics).
class PaymentVerifiedIcon extends StatelessWidget {
  const PaymentVerifiedIcon({super.key, required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final label = verified ? l10n.paymentVerified : l10n.paymentUnverified;
    return Tooltip(
      message: label,
      child: Icon(
        verified ? Icons.verified : Icons.circle_outlined,
        key: Key(
          verified ? 'payment_icon_verified' : 'payment_icon_unverified',
        ),
        color: verified
            ? scheme.primary
            : scheme.onSurfaceVariant.withValues(alpha: 0.5),
        semanticLabel: label,
      ),
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

/// A customer's name for a payment: the [name] the server sent with it when
/// there is one (spec 055 R2, mbe-api#270), so a page of rows makes no
/// per-customer request at all.
///
/// Only a payment that arrives with no name — its customer row is missing —
/// falls back to `customerDisplayNameProvider`, resolved once per distinct id
/// (spec 054 research R2). While that loads the cell shows "…"; if the lookup
/// fails it falls back to the number, so one failed name never blanks a row
/// (spec 054 FR-018).
class PaymentCustomerName extends ConsumerWidget {
  const PaymentCustomerName({super.key, required this.customerId, this.name});

  final int customerId;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projected = name;
    final String text;
    if (projected != null) {
      text = projected;
    } else {
      text = ref
          .watch(customerDisplayNameProvider(customerId))
          .when(
            data: (value) => value ?? '#$customerId',
            loading: () => '…',
            error: (_, _) => '#$customerId',
          );
    }
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
