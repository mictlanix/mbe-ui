import 'package:flutter/material.dart';

import 'package:mbe_ui/features/catalog/domain/entities/merge_preview.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Resolves a preview category's `table.column` key to a display label
/// (specs/016-product-merge-review FR-006, Story 5 #3).
///
/// mbe-api derives the category set from its own mapped metadata, so a new
/// foreign key to `product` starts appearing here with no mbe-ui change. Known
/// tables get a translated label; anything else is humanized from the key
/// rather than dropped — a category the UI silently omitted would understate
/// the blast radius, which is the opposite of what this summary is for.
String mergeCategoryLabel(AppLocalizations l10n, MergePreviewCategory category) {
  return switch (category.table) {
    'sales_order_detail' => l10n.mergeCategorySalesOrderDetail,
    'purchase_order_detail' => l10n.mergeCategoryPurchaseOrderDetail,
    'inventory_receipt_detail' => l10n.mergeCategoryInventoryReceiptDetail,
    'inventory_issue_detail' => l10n.mergeCategoryInventoryIssueDetail,
    'inventory_transfer_detail' => l10n.mergeCategoryInventoryTransferDetail,
    'lot_serial_tracking' => l10n.mergeCategoryLotSerialTracking,
    'product_price' => l10n.mergeCategoryProductPrice,
    'product_label' => l10n.mergeCategoryProductLabel,
    'fiscal_document_detail' => l10n.mergeCategoryFiscalDocumentDetail,
    'commission_product' => l10n.mergeCategoryCommissionProduct,
    'customer_discount' => l10n.mergeCategoryCustomerDiscount,
    final table => humanizeCategoryKey(table),
  };
}

/// `inventory_receipt_detail` → `Inventory receipt detail`. Deliberately
/// readable-but-obviously-generic, so an unlabelled category is visibly a
/// gap in the translations rather than looking like a deliberate name.
String humanizeCategoryKey(String table) {
  final words = table.split('_').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return table;
  final joined = words.join(' ');
  return joined[0].toUpperCase() + joined.substring(1);
}

/// The blast-radius summary: what is attached to the product about to be
/// deleted (FR-006).
///
/// Rendered only when the preview resolved — the caller omits this widget
/// entirely on failure, since a missing count must not compete for attention
/// with the destructive decision itself (Story 5 #4).
class MergeRelatedRecordsSummary extends StatelessWidget {
  const MergeRelatedRecordsSummary({super.key, required this.preview});

  final MergePreview preview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (preview.isEmpty) return const SizedBox.shrink();

    // Container, not DecoratedBox — see merge_review_panel.dart: the child
    // must be inset by the border and clipped to the radius, or the header
    // paints over both.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Text(
              l10n.mergeRelatedRecordsTitle,
              style: theme.textTheme.titleSmall,
            ),
          ),
          for (final (index, category) in preview.categories.indexed)
            _CategoryRow(
              category: category,
              // The total footer below already draws a top border, so the
              // last category row skips its own to avoid a doubled rule.
              isLast: index == preview.categories.length - 1,
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.mergeRelatedTotalLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  // The server's own total, not a client-side re-sum, so the
                  // figure always agrees with what the backend counted.
                  key: const Key('merge_related_total'),
                  '${preview.total}',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.isLast});

  final MergePreviewCategory category;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      key: Key('merge_related_row_${category.key}'),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  mergeCategoryLabel(l10n, category),
                  style: theme.textTheme.bodyMedium,
                ),
                // Price rows are counted by the preview but deleted by the
                // merge, so saying nothing here would tell the operator their
                // price list survives when it does not (research.md §4).
                if (category.isDestroyed)
                  Text(
                    '(${l10n.mergeRelatedDestroyedNote})',
                    key: const Key('merge_related_destroyed_note'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${category.count}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
