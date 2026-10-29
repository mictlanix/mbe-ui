import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Asks how the customer gets [total] back (spec 057 contracts C5). Returns
/// the chosen [RefundPayout], or `null` when backed out. No option is
/// preselected (FR-008), so confirm stays disabled until one is picked.
Future<RefundPayout?> showRefundConfirmDialog(
  BuildContext context, {
  required String total,
}) => showResponsiveDialog<RefundPayout>(
  context,
  builder: (_) => RefundConfirmDialog(total: total),
);

class RefundConfirmDialog extends ConsumerStatefulWidget {
  const RefundConfirmDialog({super.key, required this.total});

  /// The refund's total, as the server holds it.
  final String total;

  @override
  ConsumerState<RefundConfirmDialog> createState() =>
      _RefundConfirmDialogState();
}

class _RefundConfirmDialogState extends ConsumerState<RefundConfirmDialog> {
  RefundPayout? _payout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final payout = _payout;
    return ResponsiveDialog(
      key: const Key('refund_confirm_dialog'),
      title: l10n.refundConfirmAction,
      primaryAction: ResponsiveDialogAction(
        key: const Key('refund_confirm_submit'),
        label: l10n.refundConfirmSubmit,
        onPressed: payout == null
            ? null
            : () => Navigator.of(context).pop(payout),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.refundConfirmBack,
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.refundConfirmDialogTotal(fmt.display.currency(widget.total)),
          ),
          RadioGroup<RefundPayout>(
            groupValue: payout,
            onChanged: (value) => setState(() => _payout = value),
            child: Column(
              children: [
                RadioListTile<RefundPayout>(
                  key: const Key('refund_payout_cash'),
                  value: RefundPayout.cash,
                  title: Text(l10n.refundPayoutCash),
                ),
                RadioListTile<RefundPayout>(
                  key: const Key('refund_payout_credit_note'),
                  value: RefundPayout.creditNote,
                  title: Text(l10n.refundPayoutCreditNote),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
