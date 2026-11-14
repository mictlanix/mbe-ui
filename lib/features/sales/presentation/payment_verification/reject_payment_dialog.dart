import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verify_payment_dialog.dart'
    show PaymentFacts;
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The server's limit on a rejection's reason (`RejectionRequest`).
const _maxReasonLength = 500;

/// Rejects [payment] with a reason (spec 060 C6, FR-009 to FR-012). Returns
/// `true` once the server recorded it, so the caller can say so; `false` when
/// the user backed out or the server refused.
///
/// A rejection only records the reason and who gave it: the payment stays
/// unverified and stays in the queue, and nothing the app can read shows it
/// was rejected (FR-012). The dialog says so before the user confirms.
///
/// Shared by the queue's row icon and the Pagos payment view.
Future<bool> showRejectPaymentDialog(
  BuildContext context,
  CustomerPayment payment,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => _RejectPaymentDialog(payment: payment),
    ) ??
    false;

class _RejectPaymentDialog extends ConsumerStatefulWidget {
  const _RejectPaymentDialog({required this.payment});

  final CustomerPayment payment;

  @override
  ConsumerState<_RejectPaymentDialog> createState() =>
      _RejectPaymentDialogState();
}

class _RejectPaymentDialogState extends ConsumerState<_RejectPaymentDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  /// The reason as the server gets it: trimmed, and never empty (FR-010).
  String get _trimmed => _reason.text.trim();

  bool get _canConfirm => !_busy && _trimmed.isNotEmpty;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(paymentVerificationProvider.notifier)
        .reject(paymentId: widget.payment.customerPaymentId, reason: _trimmed);
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
      key: const Key('reject_payment_dialog'),
      title: l10n.paymentRejectTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          PaymentFacts(payment: widget.payment),
          TextField(
            key: const Key('reject_reason_field'),
            controller: _reason,
            enabled: !_busy && refusal == null,
            minLines: 2,
            maxLines: 4,
            maxLength: _maxReasonLength,
            decoration: InputDecoration(
              labelText: '${l10n.paymentRejectReasonLabel} *',
            ),
            onChanged: (_) => setState(() {}),
          ),
          Text(l10n.paymentRejectNote),
          if (refusal != null)
            // A lost connection leaves the outcome unknown: say that, rather
            // than claiming it failed.
            refusal is NetworkError
                ? FormErrorBanner(
                    key: const Key('reject_payment_unknown'),
                    headline: l10n.paymentRejectUnknown,
                  )
                : ErrorBanner(
                    key: const Key('reject_payment_refusal'),
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
              key: const Key('reject_payment_close'),
              label: MaterialLocalizations.of(context).closeButtonLabel,
              onPressed: () => Navigator.of(context).pop(false),
            )
          : ResponsiveDialogAction(
              key: const Key('reject_payment_confirm'),
              label: l10n.paymentRejectAction,
              busy: _busy,
              onPressed: _canConfirm ? _confirm : null,
            ),
    );
  }
}
