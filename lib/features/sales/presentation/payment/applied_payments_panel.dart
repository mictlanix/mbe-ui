import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/reversal_reason_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';

/// What has already been applied to this sale (FR-048): method, amount,
/// reference and validation state, each reversible with a mandatory reason.
/// Reads `orderPaymentsControllerProvider` — the sale's own listing, not
/// session state, so a resumed sale shows its full history including
/// reversals (research.md §11).
class AppliedPaymentsPanel extends ConsumerWidget {
  const AppliedPaymentsPanel({
    super.key,
    required this.saleId,
    this.enabled = true,
    this.showChangeAndDate = false,
    this.onReverse,
    this.onOpenPayment,
  });

  final int saleId;
  final bool enabled;

  /// spec 048 FR-011: the read-only sale detail also shows the change given
  /// and the date of each payment. `false` keeps the Cobro rail as it was.
  final bool showChangeAndDate;

  /// spec 059 C7: when set, a tap on a row's reverse icon calls this and does
  /// nothing else — the host runs the whole reversal (dialog, write, refresh)
  /// against its own screen's state. `null` keeps the register's own path:
  /// the shared dialog, then `PaymentController.reverse`.
  final void Function(SalePayment payment)? onReverse;

  /// spec 059 C7: when set, each row links to its payment's own view. The
  /// register shows no link.
  final void Function(int customerPaymentId)? onOpenPayment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final payments = ref.watch(orderPaymentsControllerProvider(saleId));
    final fmt = ref.watch(formattersProvider);

    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final typeRoles = theme.typeRoles;

    return payments.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Text(l10n.posNoAppliedPayments),
            ),
          );
        }
        return ListView.separated(
          // `shrinkWrap` so this list is safe in both homes it renders in:
          // an `Expanded` rail at the two-pane tier (a bounded height, where
          // this still scrolls independently once content exceeds it) and a
          // plain item inside the step's own outer `ListView` below that
          // tier (an unbounded height, where a plain `ListView` here would
          // throw rather than let the outer list carry the scroll).
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
          itemCount: list.length,
          separatorBuilder: (context, index) => SizedBox(height: spacing.xs),
          itemBuilder: (context, index) {
            final payment = list[index];
            final isCreditNote = payment.type == PaymentType.creditNote;
            return Container(
              key: Key('applied_payment_${payment.id}'),
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                // A step *above* the rail this list lives in, as in the mock
                // (`#16161C` cards on a `#131319` rail) — `sunken` put them
                // below it instead, which reads as a well cut into the rail
                // rather than a card resting on it.
                color: theme.elevations.engaged.surfaceColor,
                borderRadius: theme.shapes.mdRadius,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.elevations.engaged.surfaceColor,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    child: Icon(
                      isCreditNote
                          ? Icons.receipt_long_outlined
                          : paymentMethodIcon(payment.methodCode),
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fmt.display.currency(payment.amount),
                          style: typeRoles.money.copyWith(
                            decoration: payment.cancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          [
                            // spec 056 FR-009: a redemption's method reads
                            // "N/A", so it leads with its type and ticket
                            // number, the number printed on the paper note.
                            if (isCreditNote) ...[
                              paymentTypeLabel(l10n, payment.type),
                              l10n.appliedPaymentCreditNoteNumber(
                                payment.customerPayment,
                              ),
                            ] else
                              paymentMethodLabel(l10n, payment.methodCode),
                            if (payment.reference != null)
                              l10n.posPaymentReferenceValue(payment.reference!),
                            if (payment.isPendingValidation)
                              l10n.posPaymentPendingValidation,
                            if (payment.cancelled) l10n.posPaymentCancelled,
                          ].join(' · '),
                          style: typeRoles.metricLabel,
                        ),
                        if (showChangeAndDate) ...[
                          if (!isZeroAmount(payment.changeAmount))
                            Text(
                              '${l10n.posPaymentChangeLabel}: ${fmt.display.currency(payment.changeAmount)}',
                              style: typeRoles.metricLabel,
                            ),
                          Text(
                            '${l10n.posPaymentDateLabel}: ${fmt.display.dateTime(payment.paymentDate)}',
                            style: typeRoles.metricLabel,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onOpenPayment != null)
                    IconButton(
                      key: Key(
                        'applied_payment_open_${payment.customerPayment}',
                      ),
                      icon: const Icon(Icons.open_in_new),
                      tooltip: l10n.salesOrderPaymentOpenTooltip,
                      onPressed: () => onOpenPayment!(payment.customerPayment),
                    ),
                  if (enabled && !payment.cancelled)
                    IconButton(
                      icon: const Icon(Icons.undo),
                      tooltip: l10n.posReverseAction,
                      onPressed: () => onReverse != null
                          ? onReverse!(payment)
                          : _confirmReversal(context, ref, payment),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Text(l10n.posAppliedPaymentsLoadError),
      ),
    );
  }

  Future<void> _confirmReversal(
    BuildContext context,
    WidgetRef ref,
    SalePayment payment,
  ) async {
    final reason = await showReversalReasonDialog(
      context,
      amount: ref.read(formattersProvider).display.currency(payment.amount),
      orderId: saleId,
    );
    if (reason == null) return;
    await ref
        .read(paymentControllerProvider.notifier)
        .reverse(
          saleId: saleId,
          customerPaymentId: payment.customerPayment,
          applicationId: payment.id,
          reason: reason,
        );
  }
}
