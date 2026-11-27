import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/purchases/domain/below_minimum.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "{code}: {quantity} es menos que el mínimo de compra ({minimum}).", for
/// the band and the submit prompt.
String belowMinimumText(
  AppLocalizations l10n,
  AppFormatters fmt,
  BelowMinimum entry,
) => l10n.purchaseRequestBelowMinimum(
  entry.productCode,
  fmt.display.quantity(entry.quantity.toString()),
  fmt.display.count(entry.minimum),
);

/// A warning-toned band listing one line per [belowMinimum] entry (spec 079
/// FR-013, research R7), in the look of 067's over-receipt band. Computed by
/// the UI; the server's English `warnings` are never shown. Never blocking.
/// Nothing when the list is empty.
class RequestMinimumBand extends ConsumerWidget {
  const RequestMinimumBand({super.key, required this.belowMinimum});

  final List<BelowMinimum> belowMinimum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (belowMinimum.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final color = theme.colorScheme.onTertiaryContainer;
    return Material(
      key: const Key('request_minimum_band'),
      color: theme.colorScheme.tertiaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Icon(Icons.warning_amber_outlined, color: color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.xs,
                children: [
                  for (final entry in belowMinimum)
                    Text(
                      belowMinimumText(l10n, fmt, entry),
                      style: TextStyle(color: color),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
