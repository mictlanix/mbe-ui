import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/applied_payments_panel.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_amount_field.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_method_grid.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Cobro step (contracts/pos-screen.md §3): tender amount, method,
/// reference and the applied payments. The close action is gated on a zero
/// balance, or on credit terms (FR-049, FR-051) — the same guard
/// `PosStepController.canLeavePayment` owns, asked here rather than
/// duplicated.
class PaymentStep extends ConsumerWidget {
  const PaymentStep({super.key, required this.sale, required this.onClose});

  final Sale sale;

  /// Invoked once the balance gate opens and the cashier closes the step —
  /// the host decides what follows (a delivery step, or a finished sale).
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(paymentControllerProvider);
    final notifier = ref.read(paymentControllerProvider.notifier);
    final stepNotifier = ref.read(posStepControllerProvider.notifier);
    final change = notifier.changeFor(sale.balance);
    final canClose = stepNotifier.canLeavePayment(
      balance: sale.balance,
      isCreditTerms: sale.paymentTerms == PaymentTerms.netD,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // FR-042: total, paid and balance, all read from the sale.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            // A `Wrap` rather than a `Row`: three currency figures side by
            // side overflow a phone (US5, SC-007), and large amounts overflow
            // even a wide one. This reads as a spaced row wherever it fits
            // and folds onto a second line where it does not — no figure is
            // ever truncated.
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 16,
              runSpacing: 12,
              children: [
                _figure(context, l10n.posPaymentTotal, sale.total),
                _figure(context, l10n.posPaymentPaid, subtractAmounts(sale.total, sale.balance)),
                _figure(context, l10n.posPaymentBalance, sale.balance, emphasize: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (draft.error != null) ...[
          ErrorBanner(error: draft.error!),
          const SizedBox(height: 12),
        ],
        PaymentMethodGrid(facilityId: sale.facility, enabled: !draft.submitting),
        const SizedBox(height: 12),
        if (draft.requiresReference)
          TextField(
            key: const Key('payment_reference_field'),
            enabled: !draft.submitting,
            decoration: InputDecoration(labelText: l10n.posPaymentReferenceLabel),
            onChanged: notifier.setReference,
          ),
        const SizedBox(height: 12),
        PaymentAmountField(balance: sale.balance, enabled: !draft.submitting),
        if (!isZeroAmount(change))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.posPaymentChange(MoneyFormatters.currency(change)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            key: const Key('payment_submit_button'),
            onPressed: draft.isSubmittable ? () => notifier.submit(sale) : null,
            child: draft.submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.posApplyPayment),
          ),
        ),
        const Divider(height: 32),
        Text(l10n.posAppliedPaymentsTitle, style: Theme.of(context).textTheme.titleSmall),
        AppliedPaymentsPanel(saleId: sale.id, enabled: !draft.submitting),
        const SizedBox(height: 16),
        FilledButton.tonal(
          key: const Key('payment_close_button'),
          onPressed: canClose ? onClose : null,
          child: Text(l10n.posContinue),
        ),
      ],
    );
  }

  Widget _figure(
    BuildContext context,
    String label,
    String amount, {
    bool emphasize = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Text(
          MoneyFormatters.currency(amount),
          style: emphasize ? theme.textTheme.titleLarge : theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
