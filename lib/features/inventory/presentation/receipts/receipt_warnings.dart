import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/inventory/domain/over_receipt.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

part 'receipt_warnings.g.dart';

// The receipt's non-blocking warnings (spec 067 FR-015, FR-015a, research
// R6). Feature-local: no shared warning widget exists (wireframes Open
// Question 1). The server's `warnings[]` text is never shown.

/// "Se recibió de más {code}: {excess} (recibido {received} de {ordered}
/// ordenado)", for the band and the confirm prompt.
String overReceiptText(
  AppLocalizations l10n,
  AppFormatters fmt,
  OverReceipt over,
) => l10n.inventoryReceiptOverReceipt(
  over.productCode,
  fmt.display.quantity(over.excess.toString()),
  fmt.display.quantity(over.received.toString()),
  fmt.display.quantity(over.ordered.toString()),
);

/// A warning-toned band listing one line per [overReceipts] entry; nothing
/// when there is none.
class ReceiptOverReceiptBand extends ConsumerWidget {
  const ReceiptOverReceiptBand({super.key, required this.overReceipts});

  final List<OverReceipt> overReceipts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (overReceipts.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final color = theme.colorScheme.onTertiaryContainer;
    return Material(
      key: const Key('receipt_over_receipt_band'),
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
                  for (final over in overReceipts)
                    Text(
                      overReceiptText(l10n, fmt, over),
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

/// An info-toned band saying the costs were updated with exceptions, with a
/// close button that calls [onClose].
class ReceiptCostNoticeBand extends StatelessWidget {
  const ReceiptCostNoticeBand({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final color = theme.colorScheme.onSecondaryContainer;
    return Material(
      key: const Key('receipt_cost_notice_band'),
      color: theme.colorScheme.secondaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: spacing.md,
          top: spacing.xs,
          bottom: spacing.xs,
        ),
        child: Row(
          spacing: spacing.sm,
          children: [
            Icon(Icons.info_outline, color: color),
            Expanded(
              child: Text(
                l10n.inventoryReceiptCostNotice,
                style: TextStyle(color: color),
              ),
            ),
            IconButton(
              key: const Key('receipt_cost_notice_close'),
              icon: Icon(Icons.close, color: color),
              tooltip: l10n.inventoryReceiptCostNoticeClose,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

/// Whether receipt [receiptId]'s cost notice is showing (FR-015a). A later
/// GET doesn't repeat the cost warnings, so this local state holds it until
/// the clerk closes the band; being autodispose, it clears when the user
/// leaves the receipt.
@riverpod
class ReceiptCostNotice extends _$ReceiptCostNotice {
  @override
  bool build(int receiptId) => false;

  /// After a confirm or cancel reports `hasUnmappedWarnings`.
  void show() => state = true;

  /// From the band's close button.
  void dismiss() => state = false;
}
