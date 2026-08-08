import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/core/widgets/number_pad.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Amount entry for a tender: a text field, the shared [NumberPad], and
/// quick-amount chips — "Restante" (the whole outstanding balance), the
/// round notes above it, and "Mitad" (FR-043).
class PaymentAmountField extends ConsumerStatefulWidget {
  const PaymentAmountField({super.key, required this.balance, this.enabled = true});

  final String balance;
  final bool enabled;

  @override
  ConsumerState<PaymentAmountField> createState() => _PaymentAmountFieldState();
}

class _PaymentAmountFieldState extends ConsumerState<PaymentAmountField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      ref.read(paymentControllerProvider.notifier).setAmount(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _quickAmount(String amount) {
    _controller.text = amount;
  }

  /// The round cash notes that exceed the balance — what a cashier is
  /// actually handed. Chips for notes at or below the balance would only
  /// ever produce a partial payment the "Restante" chip covers better.
  List<String> get _noteChips {
    const notes = ['50', '100', '200', '500', '1000'];
    return [
      for (final note in notes)
        if (compareAmounts(note, widget.balance) > 0) note,
    ].take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(paymentControllerProvider);
    // Keep the field in step when the controller resets the draft after a
    // successful tender.
    if (draft.amount.isEmpty && _controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.clear());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('payment_amount_field'),
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.posAmountLabel, prefixText: r'$ '),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: Text(l10n.posQuickAmountRemaining),
              onPressed: widget.enabled ? () => _quickAmount(widget.balance) : null,
            ),
            for (final note in _noteChips)
              ActionChip(
                label: Text(MoneyFormatters.currency(note)),
                onPressed: widget.enabled ? () => _quickAmount(note) : null,
              ),
            ActionChip(
              label: Text(l10n.posQuickAmountHalf),
              onPressed: widget.enabled
                  ? () => _quickAmount(halveAmount(widget.balance))
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        NumberPad(controller: _controller, enabled: widget.enabled),
      ],
    );
  }
}
