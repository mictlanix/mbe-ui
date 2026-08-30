import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Resolves a delete-preview category's `table.column` key to a display
/// label (specs/034-price-list-retirement-ui FR-005, research.md R6).
///
/// mbe-api derives the category set from its own mapped metadata, so a new
/// foreign key to `price_list` starts appearing here with no mbe-ui change.
/// Known tables get a translated label; anything else is humanized from the
/// key rather than dropped — a category the UI silently omitted would
/// understate the blast radius, which is the opposite of what this summary
/// is for.
///
/// Deliberately a private copy of
/// `merge_related_records_summary.dart`'s `mergeCategoryLabel` rather than a
/// shared import: the two tables (`product_price`/`customer` here,
/// `sales_order_detail`/etc. there) don't overlap, and reaching from
/// `features/pricing/presentation/` into `features/catalog/presentation/`
/// is cross-feature presentation coupling the layering rule doesn't
/// sanction (research.md R6). Worth unifying if a third caller appears.
String priceListDeleteCategoryLabel(
  AppLocalizations l10n,
  PriceListDeleteCategory category,
) {
  return switch (category.table) {
    'product_price' => l10n.priceListDeleteCategoryProductPrice,
    'customer' => l10n.priceListDeleteCategoryCustomer,
    final table => _humanizeCategoryKey(table),
  };
}

/// `sales_order` → `Sales order`. Deliberately readable-but-obviously-generic,
/// so an unlabelled category is visibly a gap in the translations rather
/// than looking like a deliberate name.
String _humanizeCategoryKey(String table) {
  final words = table.split('_').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return table;
  final joined = words.join(' ');
  return joined[0].toUpperCase() + joined.substring(1);
}

/// The blast-radius breakdown shown before a price list retirement — every
/// category attached to the list, with its count and its fate: destroyed,
/// moved to the replacement, or blocking the deletion outright
/// (specs/034-price-list-retirement-ui FR-002, FR-003, FR-005).
///
/// Built independently of `MergeRelatedRecordsSummary` rather than
/// generalized from it (research.md R5): this panel has a third fate merge
/// has no concept of, and a row that navigates. Worth unifying if a third
/// such panel appears.
class PriceListDeleteSummary extends ConsumerWidget {
  const PriceListDeleteSummary({
    super.key,
    required this.preview,
    this.onViewCustomers,
  });

  final PriceListDeletePreview preview;

  /// Navigates to the customers list filtered to this price list (FR-006).
  /// `null` omits the affordance — not expected in practice, since every
  /// caller wires it, but keeps the widget testable without a router.
  final VoidCallback? onViewCustomers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = ref.watch(formattersProvider);

    return Container(
      key: const Key('price_list_delete_summary'),
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
              l10n.priceListDeleteRelatedTitle,
              style: theme.textTheme.titleSmall,
            ),
          ),
          for (final (index, category) in preview.categories.indexed)
            _CategoryRow(
              category: category,
              fmt: fmt,
              // The total footer below already draws a top border, so the
              // last category row skips its own to avoid a doubled rule.
              isLast: index == preview.categories.length - 1,
              onViewCustomers: category.fate == PriceListDeleteFate.moved
                  ? onViewCustomers
                  : null,
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
                    l10n.priceListDeleteTotalLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  // The server's own total, not a client-side re-sum, so the
                  // figure always agrees with what the backend counted
                  // (SC-005).
                  key: const Key('price_list_delete_total'),
                  fmt.display.count(preview.total),
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
  const _CategoryRow({
    required this.category,
    required this.fmt,
    required this.isLast,
    required this.onViewCustomers,
  });

  final PriceListDeleteCategory category;
  final AppFormatters fmt;
  final bool isLast;
  final VoidCallback? onViewCustomers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (noteText, noteColor) = switch (category.fate) {
      PriceListDeleteFate.destroyed => (
        l10n.priceListDeleteFateDestroyed,
        scheme.error,
      ),
      PriceListDeleteFate.moved => (
        l10n.priceListDeleteFateMoved,
        scheme.onSurfaceVariant,
      ),
      PriceListDeleteFate.blocking => (
        l10n.priceListDeleteFateBlocking,
        scheme.error,
      ),
    };

    return Container(
      key: Key('price_list_delete_row_${category.key}'),
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
                  priceListDeleteCategoryLabel(l10n, category),
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '($noteText)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: noteColor,
                  ),
                ),
                if (onViewCustomers != null)
                  InkWell(
                    key: const Key('price_list_delete_customers_link'),
                    onTap: onViewCustomers,
                    child: Text(
                      l10n.priceListDeleteViewCustomers,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            fmt.display.count(category.count),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
