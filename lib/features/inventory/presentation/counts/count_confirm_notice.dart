import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

part 'count_confirm_notice.g.dart';

// The warnings a confirm returns (spec 070 FR-013, research R9). The server
// stores none, so they live only in this screen-session state. The text is
// built from the warnings' fields, never from server prose (§III).

/// Count [countId]'s confirm warnings on show, empty when hidden. Mirrors
/// 067's `ReceiptCostNotice`: a reload inside the screen keeps them, and
/// being autodispose, they clear when the user leaves the count.
@riverpod
class CountConfirmNotice extends _$CountConfirmNotice {
  @override
  CountWarnings build(int countId) => const CountWarnings();

  /// After a confirm that returned warnings.
  void show(CountWarnings warnings) => state = warnings;

  /// From the band's ✕.
  void dismiss() => state = const CountWarnings();
}

/// A warning-toned band (not an `ErrorBanner`: the count is already posted)
/// with the two optional sections, and a ✕ that calls [onClose]. Nothing
/// when [warnings] is empty.
class CountWarningsBand extends ConsumerWidget {
  const CountWarningsBand({
    super.key,
    required this.warnings,
    required this.onClose,
  });

  final CountWarnings warnings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    // The warning tone, as 067's `ReceiptOverReceiptBand`.
    final color = theme.colorScheme.onTertiaryContainer;
    final style = TextStyle(color: color);

    Widget item(String text) => Padding(
      padding: EdgeInsetsDirectional.only(start: spacing.md),
      child: Text(text, style: style),
    );

    return Material(
      key: const Key('count_confirm_warnings'),
      color: theme.colorScheme.tertiaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: spacing.md,
          top: spacing.xs,
          bottom: spacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Padding(
              padding: EdgeInsets.only(top: spacing.sm),
              child: Icon(Icons.warning_amber_outlined, color: color),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: spacing.xs,
                  children: [
                    Text(
                      l10n.inventoryCountWarningsTitle,
                      style: theme.textTheme.titleSmall?.copyWith(color: color),
                    ),
                    if (warnings.negativeAvailable.isNotEmpty) ...[
                      Text(
                        l10n.inventoryCountWarningsNegativeHeading,
                        style: style,
                      ),
                      for (final w in warnings.negativeAvailable)
                        item(
                          l10n.inventoryCountWarningsNegativeLine(
                            w.productCode,
                            fmt.display.quantity(w.counted.toString()),
                            fmt.display.quantity(w.reserved.toString()),
                            fmt.display.quantity(w.available.toString()),
                          ),
                        ),
                    ],
                    if (warnings.correctedByOtherCounts.isNotEmpty) ...[
                      Text(
                        l10n.inventoryCountWarningsCorrectedHeading,
                        style: style,
                      ),
                      // The other count's folio as plain text (wireframe
                      // question 6); it is confirmed, so a missing serial
                      // shouldn't happen and falls back to its draft folio.
                      for (final w in warnings.correctedByOtherCounts)
                        item(
                          w.otherCountSerial == null
                              ? '${w.productCode}  '
                                    '${l10n.inventoryCountDraftFolio('${w.otherCountId}')}'
                              : l10n.inventoryCountWarningsCorrectedLine(
                                  w.productCode,
                                  '${w.otherCountSerial}',
                                ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              key: const Key('count_confirm_warnings_close'),
              icon: Icon(Icons.close, color: color),
              tooltip: l10n.inventoryCountWarningsDismiss,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
