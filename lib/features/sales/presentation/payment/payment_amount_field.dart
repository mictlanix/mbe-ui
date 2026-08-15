import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The tender amount's headline display (spec 025 contracts/payment-surface
/// .md §3, research R4): the visually dominant element of the capture pane —
/// right-aligned, tabular figures, the sale's currency beside it — while
/// remaining a real, focusable, typable field. [NumberPad] and a physical
/// keyboard stay two paths to the same [controller], neither privileged.
///
/// Takes its [controller] from the outside rather than creating its own: the
/// keypad now sits beside the payment methods, not nested inside this
/// widget (contract §3), so whoever lays those two out —
/// `PaymentCapturePane` — owns the one controller both this field and
/// `NumberPad` edit, and seeds it from the draft so a keyed amount survives
/// the pane being torn down and rebuilt across a layout-shape change
/// (research R5).
class PaymentAmountField extends StatelessWidget {
  const PaymentAmountField({
    super.key,
    required this.controller,
    required this.currency,
    this.enabled = true,
  });

  final TextEditingController controller;
  final Currency currency;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final typeRoles = theme.typeRoles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.posAmountLabel.toUpperCase(),
          style: typeRoles.metricLabel.copyWith(
            letterSpacing: 0.8,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.xxs),
        TextField(
          key: const Key('payment_amount_field'),
          controller: controller,
          enabled: enabled,
          textAlign: TextAlign.end,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: typeRoles.heroHeading.copyWith(
            fontFamily: TypeRoles.monoFamily,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            filled: true,
            prefixText: '${currency.name.toUpperCase()}  ',
          ),
        ),
      ],
    );
  }
}
