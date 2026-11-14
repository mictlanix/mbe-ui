import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart'
    show emptyValuePlaceholder;
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Verifies [payment] after a confirmation (spec 060 C5, FR-006 to FR-008).
/// Returns `true` once the server accepted, so the caller can say so; `false`
/// when the user backed out or the server refused.
///
/// Shared by the queue's row icon and the Pagos payment view.
Future<bool> showVerifyPaymentDialog(
  BuildContext context,
  CustomerPayment payment,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => _VerifyPaymentDialog(payment: payment),
    ) ??
    false;

class _VerifyPaymentDialog extends ConsumerStatefulWidget {
  const _VerifyPaymentDialog({required this.payment});

  final CustomerPayment payment;

  @override
  ConsumerState<_VerifyPaymentDialog> createState() =>
      _VerifyPaymentDialogState();
}

class _VerifyPaymentDialogState extends ConsumerState<_VerifyPaymentDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _confirm() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(paymentVerificationProvider.notifier)
        .verify(paymentId: widget.payment.customerPaymentId);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final refusal = _refusal;

    return ResponsiveDialog(
      key: const Key('verify_payment_dialog'),
      title: l10n.paymentVerifyTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          PaymentFacts(payment: widget.payment),
          Text(l10n.paymentVerifyIrreversible),
          if (refusal != null)
            // A lost connection leaves the outcome unknown: say that, rather
            // than claiming it failed. Anything else is the server's refusal
            // (an already-verified payment has its own message).
            refusal is NetworkError
                ? FormErrorBanner(
                    key: const Key('verify_payment_unknown'),
                    headline: l10n.paymentVerifyUnknown,
                  )
                : ErrorBanner(
                    key: const Key('verify_payment_refusal'),
                    error: refusal,
                  ),
        ],
      ),
      // After a refusal there is nothing left to confirm: the queue has
      // already been reloaded, so the only way on is to close.
      secondaryAction: refusal != null
          ? null
          : ResponsiveDialogAction(
              label: l10n.cancelButton,
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            ),
      primaryAction: refusal != null
          ? ResponsiveDialogAction(
              key: const Key('verify_payment_close'),
              label: MaterialLocalizations.of(context).closeButtonLabel,
              onPressed: () => Navigator.of(context).pop(false),
            )
          : ResponsiveDialogAction(
              key: const Key('verify_payment_confirm'),
              label: l10n.paymentVerifyAction,
              busy: _busy,
              onPressed: _busy ? null : _confirm,
            ),
    );
  }
}

/// The facts a supervisor checks against the bank statement before verifying
/// or rejecting: folio, customer, amount and reference (spec 060 FR-007,
/// FR-010). Shared by both dialogs.
class PaymentFacts extends ConsumerWidget {
  const PaymentFacts({super.key, required this.payment});

  final CustomerPayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);

    Widget fact(String label, Widget value) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(child: value),
      ],
    );

    return Column(
      key: Key('payment_facts_${payment.customerPaymentId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        fact(l10n.paymentsColumnFolio, Text('${payment.customerPaymentId}')),
        fact(
          l10n.paymentsColumnCustomer,
          PaymentCustomerName(
            customerId: payment.customerId,
            name: payment.customerName,
          ),
        ),
        fact(
          l10n.paymentsColumnAmount,
          Text(paymentAmountLabel(fmt, payment.amount, payment.currency)),
        ),
        fact(
          l10n.paymentsColumnReference,
          Text(payment.reference ?? emptyValuePlaceholder),
        ),
      ],
    );
  }
}
