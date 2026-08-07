import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One already-created destination (FR-029): where it goes, who receives it,
/// when, and how much it takes.
///
/// The counter-pickup remainder is rendered too but has no address to show
/// and cannot be edited — it is the sweep, not a destination the cashier
/// composed.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    this.onRemove,
    this.enabled = true,
  });

  final Destination destination;
  final VoidCallback? onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      key: Key('destination_card_${destination.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          destination.isCounterPickup
              ? Icons.store_outlined
              : Icons.local_shipping_outlined,
        ),
        title: Text(
          destination.isCounterPickup
              ? l10n.posCounterPickupRemainder
              : destination.addressSummary ?? l10n.posDeliveryAddressPending,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (destination.contactName != null)
              Text(
                [
                  destination.contactName!,
                  if (destination.contactPhone != null) destination.contactPhone!,
                ].join(' · '),
              ),
            if (destination.date != null)
              Text(MoneyFormatters.date(destination.date!)),
            Text(
              l10n.posDestinationCounts(
                destination.lineCount,
                formatQuantity(destination.unitCount),
              ),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        trailing: (enabled && onRemove != null)
            ? IconButton(
                key: Key('destination_remove_${destination.id}'),
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.posRemoveDestination,
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}
