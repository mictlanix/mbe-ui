import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/number_pad.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_amount_field.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_method_grid.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The tender-capture half of the payment step (spec 025 contracts/
/// payment-surface.md §3): the headline amount, the quick-amount chips, the
/// payment methods beside the keypad. There is no apply button: tapping a
/// method applies the payment (spec 047 US5), and a method that needs a
/// reference asks for it in a dialog.
///
/// Owns the single [TextEditingController] the amount field and [NumberPad]
/// both edit — they used to be nested in one widget and could share it
/// privately, but the keypad now sits beside [PaymentMethodGrid] instead
/// (the mock's own arrangement), so whoever lays those two out has to be the
/// one holding the controller. Seeded from the draft on construction so a
/// keyed amount survives this pane being torn down and rebuilt when
/// `PaymentStep` switches between its one-column and two-pane shapes
/// (research R5) — the same hazard the amount field itself used to guard
/// against, now guarded here because this is the widget that actually gets
/// remounted across that switch.
class PaymentCapturePane extends ConsumerStatefulWidget {
  const PaymentCapturePane({
    super.key,
    required this.sale,
    required this.enabled,
  });

  final Sale sale;
  final bool enabled;

  @override
  ConsumerState<PaymentCapturePane> createState() => _PaymentCapturePaneState();
}

class _PaymentCapturePaneState extends ConsumerState<PaymentCapturePane> {
  late final _amountController = TextEditingController(
    text: ref.read(paymentControllerProvider).amount,
  );

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      ref
          .read(paymentControllerProvider.notifier)
          .setAmount(_amountController.text);
    });
    // FR-016: open with the balance already keyed. Deferred — a provider
    // must not change while the tree is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(paymentControllerProvider.notifier)
          .prefillAmount(widget.sale.balanceOrZero);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Routes every quick-amount insertion through the shared formatting
  // surface (contracts/app-settings-additions.md C3, spec 036 FR-026)
  // instead of setting the raw computed string straight into the field —
  // the same raw-seed bypass US8 found in the pricing grid's editable
  // cell, here in the "Restante" chip's `sale.balance` (a raw
  // `Numeric(18,4)` wire value like `150.0000`).
  void _quickAmount(String amount) {
    _amountController.text = ref.read(formattersProvider).field.price(amount);
  }

  /// The round cash notes that exceed the balance — what a cashier is
  /// actually handed. Chips for notes at or below the balance would only
  /// ever produce a partial payment the "Restante" chip covers better.
  List<String> _noteChips(String balance) {
    const notes = ['50', '100', '200', '500', '1000'];
    return [
      for (final note in notes)
        if (compareAmounts(note, balance) > 0) note,
    ].take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final sale = widget.sale;
    final enabled = widget.enabled;
    final fmt = ref.watch(formattersProvider);

    // Keep the field in step when the controller sets the amount itself — the
    // pre-fill, and the new balance after a successful tender.
    ref.listen(paymentControllerProvider.select((draft) => draft.amount), (
      _,
      amount,
    ) {
      if (amount == _amountController.text) return;
      _amountController.text = amount.isEmpty ? '' : fmt.field.price(amount);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentAmountField(
          controller: _amountController,
          currency: ref.watch(multiCurrencyEnabledProvider)
              ? sale.currency
              : null,
          enabled: enabled,
        ),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.xs,
          children: [
            ActionChip(
              label: Text(l10n.posQuickAmountRemaining),
              onPressed: enabled
                  ? () => _quickAmount(sale.balanceOrZero)
                  : null,
            ),
            for (final note in _noteChips(sale.balanceOrZero))
              ActionChip(
                label: Text(fmt.display.currency(note)),
                onPressed: enabled ? () => _quickAmount(note) : null,
              ),
            ActionChip(
              label: Text(l10n.posQuickAmountHalf),
              onPressed: enabled
                  ? () => _quickAmount(halveAmount(sale.balanceOrZero))
                  : null,
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        // Methods beside the keypad once the pane is wide enough to hold a
        // two-column tile grid and the keypad's own fixed width side by
        // side; stacked otherwise (research R2 — a pane-width decision, not
        // a window-width one, since the rail already claims part of the
        // window at the widths where this matters).
        LayoutBuilder(
          builder: (context, constraints) {
            final methods = PaymentMethodGrid(
              sale: sale,
              facilityId: sale.facility,
              enabled: enabled,
            );
            final keypad = NumberPad(
              controller: _amountController,
              enabled: enabled,
            );
            if (constraints.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: methods),
                  SizedBox(width: spacing.lg),
                  keypad,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                methods,
                SizedBox(height: spacing.md),
                keypad,
              ],
            );
          },
        ),
      ],
    );
  }
}
