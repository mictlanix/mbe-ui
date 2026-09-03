import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_confirm.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';
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
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final typeRoles = theme.typeRoles;

    // Watched so the change row is live; read for the gate, which depends
    // only on the sale's own balance and terms, not on draft state.
    ref.watch(paymentControllerProvider);
    final change = ref.read(paymentControllerProvider.notifier).changeFor(sale.balance);
    // spec 031 FR-007: additional to the balance/terms gate below, not
    // instead of it — a payment (or a reversal) still applying must not let
    // the cashier continue on a balance that is about to change.
    final writesPending = ref.watch(pendingWritesProvider(posWritesScope)) > 0;
    final canClose =
        !writesPending &&
        ref
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
          _row(context, fmt, l10n.posPaymentTotal, sale.total),
          SizedBox(height: spacing.xs),
          _row(context, fmt, l10n.posPaymentPaid, paid),
          SizedBox(height: spacing.xs),
          _row(
            context,
            fmt,
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
            fmt,
            l10n.posPaymentChangeLabel,
            change,
            figureStyle: typeRoles.metricValue,
          ),
          SizedBox(height: spacing.sm),
          // The same footer action `SaleTotalsBar` carries on the capture
          // step: an extended FAB with the direction stated after the label,
          // stretched by the column it sits in.
          //
          // A FAB keeps its own fill when `onPressed` is null, so the gated
          // state is spelled out here — without it the button would look
          // pressable while the balance is still outstanding, which the
          // `FilledButton.tonal` this replaces got for free.
          FloatingActionButton.extended(
            key: const Key('payment_close_button'),
            onPressed: canClose ? () => _handleClose(ref) : null,
            backgroundColor: canClose
                ? null
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor: canClose
                ? null
                : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.posContinue),
                SizedBox(width: spacing.xs),
                const Icon(Icons.arrow_forward),
              ],
            ),
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

  /// spec 036 FR-008/R1: leaving Cobro on credit terms with no cash ever
  /// tendered is the one path that reaches here without `PaymentController
  /// .submit` having already confirmed the sale — so this confirms it here,
  /// immediately before actually leaving. A no-op once already confirmed
  /// (the ordinary case: a payment already ran `confirm()`). On failure the
  /// error is routed to Venta's banner and this step is not left.
  Future<void> _handleClose(WidgetRef ref) async {
    try {
      await confirmBeforePayableAction(ref.read, sale);
    } on AppError {
      return;
    }
    onClose();
  }

  Widget _row(
    BuildContext context,
    AppFormatters fmt,
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
            fmt.display.currency(amount),
            textAlign: TextAlign.end,
            style: figureStyle ?? typeRoles.money,
          ),
        ),
      ],
    );
  }
}
