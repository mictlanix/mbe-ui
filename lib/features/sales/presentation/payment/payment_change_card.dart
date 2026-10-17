import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The change owed after a cash overpayment (spec 047 contracts C7). The
/// summary's own "Cambio" row is only a preview while an amount is keyed — it
/// goes back to zero the moment the payment is applied, which is exactly when
/// the cashier must hand the change over. This card outlives the draft and
/// stays until [onDismiss].
class PaymentChangeCard extends ConsumerWidget {
  const PaymentChangeCard({super.key, required this.amount, required this.onDismiss});

  /// The change, as a wire decimal string.
  final String amount;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final onColor = theme.colorScheme.onSecondaryContainer;

    return Container(
      key: const Key('payment_change_card'),
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: theme.shapes.mdRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: onColor),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.posPaymentChangeDue,
                  style: theme.typeRoles.metricLabel.copyWith(color: onColor),
                ),
                Text(
                  fmt.display.currency(amount),
                  style: theme.typeRoles.heroHeading.copyWith(color: onColor),
                ),
              ],
            ),
          ),
          TextButton(
            key: const Key('payment_change_dismiss'),
            onPressed: onDismiss,
            child: Text(l10n.posPaymentDismissChange),
          ),
        ],
      ),
    );
  }
}
