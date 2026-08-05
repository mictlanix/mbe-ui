import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';

/// What has already been applied to this sale (FR-048): method, amount,
/// reference and validation state, each reversible with a mandatory reason.
/// Reads `orderPaymentsControllerProvider` — the sale's own listing, not
/// session state, so a resumed sale shows its full history including
/// reversals (research.md §11).
class AppliedPaymentsPanel extends ConsumerWidget {
  const AppliedPaymentsPanel({super.key, required this.saleId, this.enabled = true});

  final int saleId;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final payments = ref.watch(orderPaymentsControllerProvider(saleId));

    return payments.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(l10n.posNoAppliedPayments),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final payment in list)
              ListTile(
                key: Key('applied_payment_${payment.id}'),
                dense: true,
                title: Text(paymentMethodLabel(l10n, payment.methodCode)),
                subtitle: Text(
                  [
                    if (payment.reference != null) l10n.posPaymentReferenceValue(payment.reference!),
                    if (payment.isPendingValidation) l10n.posPaymentPendingValidation,
                    if (payment.cancelled) l10n.posPaymentCancelled,
                  ].join(' · '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      MoneyFormatters.currency(payment.amount),
                      style: payment.cancelled
                          ? const TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ),
                    if (enabled && !payment.cancelled)
                      IconButton(
                        icon: const Icon(Icons.undo),
                        tooltip: l10n.posReverseAction,
                        onPressed: () => _confirmReversal(context, ref, payment),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => const Padding(
        padding: EdgeInsets.all(8),
        child: Text('No se pudieron cargar los pagos aplicados'),
      ),
    );
  }

  Future<void> _confirmReversal(
    BuildContext context,
    WidgetRef ref,
    SalePayment payment,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _ReversalReasonDialog(),
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

/// FR-048: the reason is mandatory (1–500 chars, per the API contract), so
/// the dialog cannot be confirmed empty.
class _ReversalReasonDialog extends StatefulWidget {
  const _ReversalReasonDialog();

  @override
  State<_ReversalReasonDialog> createState() => _ReversalReasonDialogState();
}

class _ReversalReasonDialogState extends State<_ReversalReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Revertir pago'),
      content: TextField(
        key: const Key('reversal_reason_field'),
        controller: _controller,
        autofocus: true,
        maxLength: 500,
        decoration: const InputDecoration(labelText: 'Motivo'),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('reversal_confirm_button'),
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Revertir'),
        ),
      ],
    );
  }
}
