import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Asks why an application is being reversed, naming what is being reversed
/// (spec 059 C4). One dialog for the register, Pagos and Pedidos.
///
/// The reason is mandatory (1–500 characters, per the API contract), so
/// confirm stays disabled until the trimmed text is not empty (FR-002).
/// [amount] is the application's amount already formatted for display, and
/// [orderId] the order it was applied to.
///
/// Returns the trimmed reason, or `null` when the user cancels.
///
/// With [submit] the dialog runs the reversal itself: confirm calls it behind
/// a busy flag, a returned [AppError] shows in the dialog, which stays open,
/// and `null` closes it with the reason. Without [submit] (the register) it
/// returns the reason on confirm and the caller does the work.
Future<String?> showReversalReasonDialog(
  BuildContext context, {
  required String amount,
  required int orderId,
  bool orderHasRefunds = false,
  Future<AppError?> Function(String reason)? submit,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _ReversalReasonDialog(
      amount: amount,
      orderId: orderId,
      orderHasRefunds: orderHasRefunds,
      submit: submit,
    ),
  );
}

class _ReversalReasonDialog extends StatefulWidget {
  const _ReversalReasonDialog({
    required this.amount,
    required this.orderId,
    required this.orderHasRefunds,
    required this.submit,
  });

  final String amount;
  final int orderId;
  final bool orderHasRefunds;
  final Future<AppError?> Function(String reason)? submit;

  @override
  State<_ReversalReasonDialog> createState() => _ReversalReasonDialogState();
}

class _ReversalReasonDialogState extends State<_ReversalReasonDialog> {
  final _controller = TextEditingController();
  bool _busy = false;
  AppError? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final reason = _controller.text.trim();
    if (reason.isEmpty || _busy) return;
    final submit = widget.submit;
    if (submit == null) {
      Navigator.of(context).pop(reason);
      return;
    }
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await submit(reason);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(reason);
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    return ResponsiveDialog(
      key: const Key('reversal_reason_dialog'),
      title: l10n.paymentReverseTitle,
      maxWidth: 440,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.paymentReverseSubject(widget.amount, '${widget.orderId}'),
            key: const Key('reversal_subject'),
          ),
          if (widget.orderHasRefunds)
            Container(
              key: const Key('reversal_refund_warning'),
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: theme.shapes.smRadius,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.sm,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  Expanded(
                    child: Text(
                      l10n.paymentReverseRefundWarning,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          TextField(
            key: const Key('reversal_reason_field'),
            controller: _controller,
            autofocus: true,
            enabled: !_busy,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: l10n.paymentReverseReasonLabel,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) ErrorBanner(error: _error!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('reversal_reason_confirm'),
        label: l10n.paymentReverseConfirm,
        busy: _busy,
        onPressed: _controller.text.trim().isEmpty ? null : _confirm,
      ),
    );
  }
}
