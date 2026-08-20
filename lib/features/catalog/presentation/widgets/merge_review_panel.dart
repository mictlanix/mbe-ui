import 'package:flutter/material.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The kept/deleted panel pair at the top of the merge review step
/// (specs/016-product-merge-review FR-002, FR-003), with the swap control
/// between them (FR-004).
///
/// Side by side from the Expanded tier up, stacked below it (FR-012) — the
/// two records are meant to be read against each other, which a narrow
/// two-column layout defeats.
class MergeReviewPanels extends StatelessWidget {
  const MergeReviewPanels({
    super.key,
    required this.kept,
    required this.deleted,
    required this.onSwap,
  });

  final Product kept;
  final Product deleted;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keptPanel = _MergeReviewPanel(
      key: const Key('merge_kept_panel'),
      product: kept,
      role: _PanelRole.kept,
    );
    final deletedPanel = _MergeReviewPanel(
      key: const Key('merge_deleted_panel'),
      product: deleted,
      role: _PanelRole.deleted,
    );
    final swapButton = IconButton.outlined(
      key: const Key('merge_swap_button'),
      icon: const Icon(Icons.swap_horiz),
      tooltip: l10n.mergeSwapTooltip,
      onPressed: onSwap,
    );

    if (LayoutBreakpoints.isCompact(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          keptPanel,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(child: swapButton),
          ),
          deletedPanel,
        ],
      );
    }

    // IntrinsicHeight so both panels share the taller one's height — a
    // side-by-side comparison with ragged box heights reads as though the
    // two records carry different amounts of information. It is also load
    // bearing: `stretch` inside the screen's scroll view has no bounded
    // height to stretch against, and throws "BoxConstraints forces an
    // infinite height" without this.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: keptPanel),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: swapButton),
          ),
          Expanded(child: deletedPanel),
        ],
      ),
    );
  }
}

enum _PanelRole { kept, deleted }

class _MergeReviewPanel extends StatelessWidget {
  const _MergeReviewPanel({
    super.key,
    required this.product,
    required this.role,
  });

  final Product product;
  final _PanelRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDeleted = role == _PanelRole.deleted;

    // Three redundant signals carry "kept" vs "deleted": an icon, a text
    // label, and the container colour. Colour alone would fail a
    // colour-blind or greyscale reading of the most consequential
    // distinction on the screen (FR-002, SC-001).
    final (border, background, foreground, icon, label) = isDeleted
        ? (
            scheme.error,
            scheme.errorContainer,
            scheme.onErrorContainer,
            Icons.cancel_outlined,
            l10n.mergeDeletedLabel,
          )
        : (
            scheme.primary,
            scheme.primaryContainer,
            scheme.onPrimaryContainer,
            Icons.check_circle_outline,
            l10n.mergeKeptLabel,
          );

    // `Container` rather than `DecoratedBox`: it insets the child by the
    // border's width, and `clipBehavior` clips the child to the corner
    // radius. A DecoratedBox does neither — its child paints over the border
    // and past the rounded corners, which is exactly what the full-bleed
    // header below would do.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: background,
              // Outer radius minus the border width, so the header's curve
              // sits concentric with the border instead of cutting it.
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Text(
                  'ID ${product.productId}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                ProductPhoto(photoUrl: product.photo, size: 72),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          // The record about to stop existing reads as
                          // struck through, so it cannot be mistaken for the
                          // survivor at a glance (FR-002).
                          decoration: isDeleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: scheme.error,
                          decorationThickness: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _identifiers(l10n, product),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatusBadge(status: product.status),
                          _Badge(text: product.unitOfMeasurementName),
                          _Badge(
                            text:
                                '${l10n.mergeFieldTaxRate}: ${product.taxRate}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Code, model, and SKU for the panel's secondary line, each prefixed with
/// its field name and blanks skipped rather than rendering empty separators.
///
/// Kept in step with the picker's suggestion subtitle in
/// `merge_products_screen.dart`, which labels the same three fields the same
/// way. These fields are very often identical to each other in this catalog
/// (`292699 · 292699 · 292699`), so an unlabelled list cannot show *which*
/// identifier differs between the two products — the sort of distinction this
/// screen exists to surface.
String _identifiers(AppLocalizations l10n, Product product) {
  final parts = [
    '${l10n.mergeFieldCode}: ${product.code}',
    if (product.model case final model? when model.isNotEmpty)
      '${l10n.mergeFieldModel}: $model',
    if (product.sku case final sku? when sku.isNotEmpty)
      '${l10n.mergeFieldSku}: $sku',
  ];
  return parts.join(' · ');
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EntityStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _Badge(text: entityStatusLabel(l10n, status));
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
