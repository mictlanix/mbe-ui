import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One compared attribute: its label, both sides' rendered values, and
/// whether they differ.
typedef MergeComparisonRow = ({
  String label,
  String kept,
  String deleted,
  bool differs,
});

/// Builds the compared rows for [kept] versus [deleted]
/// (specs/016-product-merge-review FR-005).
///
/// Values are compared as rendered strings: the operator is deciding based on
/// what the screen shows, so "differs" must mean "these two cells read
/// differently", not "these two objects are unequal underneath".
List<MergeComparisonRow> buildComparisonRows(
  AppLocalizations l10n,
  Product kept,
  Product deleted,
) {
  MergeComparisonRow row(String label, String Function(Product) value) {
    final a = value(kept);
    final b = value(deleted);
    return (label: label, kept: a, deleted: b, differs: a != b);
  }

  String orDash(String? value) =>
      (value == null || value.isEmpty) ? '—' : value;

  return [
    row(l10n.mergeFieldId, (p) => '${p.productId}'),
    row(l10n.mergeFieldCode, (p) => p.code),
    row(l10n.mergeFieldSku, (p) => orDash(p.sku)),
    row(l10n.mergeFieldModel, (p) => orDash(p.model)),
    row(l10n.mergeFieldBrand, (p) => orDash(p.brand)),
    row(l10n.mergeFieldUom, (p) => p.unitOfMeasurementName),
    row(l10n.mergeFieldTaxRate, (p) => p.taxRate),
    row(l10n.mergeFieldStatus, (p) => entityStatusLabel(l10n, p.status)),
  ];
}

/// Field-by-field comparison of the two products, flagging every row whose
/// values differ (FR-005).
///
/// Rows are laid out with a persistent header naming the kept and deleted
/// columns rather than per-row labels, so column attribution survives
/// scrolling; nothing scrolls horizontally at any width (constitution §VI).
class MergeComparisonTable extends StatelessWidget {
  const MergeComparisonTable({
    super.key,
    required this.kept,
    required this.deleted,
  });

  final Product kept;
  final Product deleted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rows = buildComparisonRows(l10n, kept, deleted);
    final compact = LayoutBreakpoints.isCompact(context);

    // Container, not DecoratedBox — see merge_review_panel.dart: the child
    // must be inset by the border and clipped to the radius, or the header
    // and the tinted diff rows paint over both.
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.mergeComparisonTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${rows.where((r) => r.differs).length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.mergeDiffBadge.toLowerCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _HeaderRow(compact: compact),
          // Row keys are per-field because sibling keys must be unique;
          // "which rows differ" is asserted via the DIFFERS badge below,
          // which repeats across rows but never among siblings.
          for (final (index, row) in rows.indexed)
            _ValueRow(
              key: Key('merge_row_${row.label}'),
              row: row,
              compact: compact,
              isLast: index == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          if (!compact)
            Expanded(
              flex: 2,
              child: Text(l10n.mergeComparisonFieldHeader, style: style),
            ),
          Expanded(
            flex: 3,
            child: Text(
              l10n.mergeKeptLabel,
              style: style?.copyWith(color: theme.brandInk.primary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              l10n.mergeDeletedLabel,
              style: style?.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatefulWidget {
  const _ValueRow({
    super.key,
    required this.row,
    required this.compact,
    required this.isLast,
  });

  final MergeComparisonRow row;
  final bool compact;
  final bool isLast;

  @override
  State<_ValueRow> createState() => _ValueRowState();
}

class _ValueRowState extends State<_ValueRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final compact = widget.compact;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // The "differs" tint is deliberately a third colour, distinct from the
    // kept/deleted panel colours — a flagged row means "these two values are
    // not the same", never "this side wins".
    final base = row.differs
        ? scheme.tertiaryContainer.withValues(alpha: 0.35)
        : null;

    // Hover is a state layer *over* the diff tint rather than a replacement,
    // so hovering a flagged row never reads as un-flagging it. 0.08 is the
    // Material 3 hover state-layer opacity, matching what `DataTable2` gives
    // the shared list tables for free (constitution §VI).
    final highlight = _hovered
        ? Color.alphaBlend(
            scheme.onSurface.withValues(alpha: 0.08),
            base ?? Colors.transparent,
          )
        : base;

    final label = Row(
      spacing: 6,
      children: [
        Flexible(
          child: Text(
            row.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (row.differs)
          Container(
            key: const Key('merge_diff_badge'),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              l10n.mergeDiffBadge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
      ],
    );

    final values = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(row.kept, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: Text(
            row.deleted,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );

    return MouseRegion(
      // Pointer-only by construction, so touch tiers are unaffected. The row
      // isn't tappable, so this is a scanning aid — it ties a field label to
      // its two values across the width of the table — not an affordance,
      // hence no ink ripple or click cursor.
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: highlight,
          border: widget.isLast
              ? null
              : Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: compact
            // Stacked at compact width: the label (and its DIFFERS badge) on
            // its own line above the two values, so both value columns stay
            // wide enough to read without horizontal scrolling.
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [label, values],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: label),
                  Expanded(flex: 6, child: values),
                ],
              ),
      ),
    );
  }
}
