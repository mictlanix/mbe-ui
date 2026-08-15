import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The money block and the step's exit action, read together (spec 025
/// contracts/payment-surface.md §6): total, paid, remaining and change as one
/// block, "Continuar" directly beneath it, and — while the exit is gated — a
/// line naming what would open it. One widget, used both at the rail's foot
/// (>= large tier) and as the pinned compact footer band, so the two shapes
/// read the same figures the same way rather than risking a second copy
/// drifting from the first (research R13).
///
/// Watches [paymentControllerProvider] (not merely reads it) so the change
/// row tracks the amount as it is keyed — the same live figure the step
/// showed today under the amount field, now a permanent row rather than one
/// that appears only on an over-tender (FR-022).
class PaymentSummaryPanel extends ConsumerWidget {
  const PaymentSummaryPanel({
    super.key,
    required this.sale,
    required this.onClose,
  });

  final Sale sale;

  /// Invoked once the balance gate opens and the cashier presses "Continuar"
  /// — the host decides what follows, exactly as before this feature.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final typeRoles = theme.typeRoles;

    // Watched so the change row is live; read for the gate, which depends
    // only on the sale's own balance and terms, not on draft state.
    ref.watch(paymentControllerProvider);
    final change = ref.read(paymentControllerProvider.notifier).changeFor(sale.balance);
    final canClose = ref
        .read(posStepControllerProvider.notifier)
        .canLeavePayment(
          balance: sale.balance,
          isCreditTerms: sale.paymentTerms == PaymentTerms.netD,
        );
    final paid = subtractAmounts(sale.total, sale.balance);
    final balanceOutstanding = !isZeroAmount(sale.balance);

    return Container(
      key: const Key('payment_summary_panel'),
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.elevations.raised.surfaceColor,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(context, l10n.posPaymentTotal, sale.total),
          SizedBox(height: spacing.xs),
          _row(context, l10n.posPaymentPaid, paid),
          SizedBox(height: spacing.xs),
          _row(
            context,
            l10n.posPaymentBalance,
            sale.balance,
            // The same figure the mock draws in amber — here, as everywhere
            // else in this design system, emphasis is a bolder/larger role
            // rather than a literal color (SC-006).
            figureStyle: balanceOutstanding ? typeRoles.metricValue : typeRoles.money,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ),
          _row(
            context,
            l10n.posPaymentChangeLabel,
            change,
            figureStyle: typeRoles.metricValue,
          ),
          SizedBox(height: spacing.sm),
          FilledButton.tonal(
            key: const Key('payment_close_button'),
            onPressed: canClose ? onClose : null,
            child: Text(l10n.posContinue),
          ),
          if (!canClose && balanceOutstanding) ...[
            SizedBox(height: spacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: spacing.xxs),
                Flexible(
                  child: Text(
                    l10n.posPaymentGateHint,
                    textAlign: TextAlign.center,
                    style: typeRoles.metricLabel.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String amount, {
    TextStyle? figureStyle,
  }) {
    final theme = Theme.of(context);
    final typeRoles = theme.typeRoles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: typeRoles.metricLabel),
        SizedBox(width: theme.spacing.sm),
        // `Expanded` rather than a bare `Text` beside the label: an extreme
        // figure (SC-005) gets the row's remaining width and wraps onto a
        // second line rather than overflowing it — this is a monetary
        // amount, so it wraps instead of being ellipsized (constitution §VI).
        Expanded(
          child: Text(
            MoneyFormatters.currency(amount),
            textAlign: TextAlign.end,
            style: figureStyle ?? typeRoles.money,
          ),
        ),
      ],
    );
  }
}
