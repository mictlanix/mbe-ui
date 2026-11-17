import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_dialogs.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Agregar producto" (spec 070 FR-008 to FR-011): pick an active,
/// stockable product and the counted quantity, then set it on draft
/// [countId]. A product already on the count has its quantity replaced, not
/// added to, and the dialog says so before the write ([lines] are the
/// count's current lines). `true` once set; every refusal shows inline and
/// keeps the dialog open.
///
/// Reachable only with Products read; the detail screen gates its button.
Future<bool> showAddCountLineDialog(
  BuildContext context, {
  required int countId,
  required List<InventoryCountLine> lines,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _AddLineDialog(countId: countId, lines: lines),
    ) ??
    false;

class _AddLineDialog extends ConsumerStatefulWidget {
  const _AddLineDialog({required this.countId, required this.lines});

  final int countId;
  final List<InventoryCountLine> lines;

  @override
  ConsumerState<_AddLineDialog> createState() => _AddLineDialogState();
}

class _AddLineDialogState extends ConsumerState<_AddLineDialog> {
  final _quantity = TextEditingController();
  ProductListItem? _product;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() => _product != null || _quantity.text.isNotEmpty;

  Decimal? get _value => parseCountedQuantity(ref, _quantity.text);

  bool get _canRecord => !_busy && _product != null && _value != null;

  /// The line [product] already has on the count, if any (FR-009).
  InventoryCountLine? _existing(ProductListItem? product) {
    if (product == null) return null;
    for (final line in widget.lines) {
      if (line.productId == product.productId) return line;
    }
    return null;
  }

  Future<void> _record() async {
    final product = _product;
    final value = _value;
    if (!_canRecord || product == null || value == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryCountActionsProvider.notifier)
        .setLines(widget.countId, [
          CountLineInput.byProduct(
            productId: product.productId,
            quantity: value,
          ),
        ]);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = countLineRefusal(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final existing = _existing(_product);

    return ResponsiveDialog(
      key: const Key('add_count_line_dialog'),
      title: l10n.inventoryCountDialogAddTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<ProductListItem>(
            key: const Key('add_count_line_product'),
            label: l10n.inventoryCountFieldProduct,
            enabled: !_busy,
            autofocus: true,
            displayStringForOption: (p) => p.name,
            optionsBuilder: (query) async {
              final trimmed = query.trim();
              if (trimmed.isEmpty) return const [];
              final result = await ref
                  .read(productRepositoryProvider)
                  .list(
                    search: trimmed,
                    status: EntityStatus.active,
                    stockable: true,
                    limit: 10,
                  );
              return result.items;
            },
            onSelected: (p) => setState(() {
              _product = p;
              _refusal = null;
            }),
            // Remounts on a pick, so the chosen name stays in the field.
            initialDisplayText: _product?.name,
            optionImageUrl: (p) => p.photo,
            optionSubtitle: (p) => p.code,
          ),
          TextField(
            key: const Key('add_count_line_quantity'),
            controller: _quantity,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.inventoryCountFieldCounted,
              errorText: _quantity.text.isEmpty || _value != null
                  ? null
                  : l10n.inventoryCountQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _record(),
          ),
          if (existing != null)
            Row(
              key: const Key('add_count_line_replace_note'),
              spacing: spacing.sm,
              children: [
                const Icon(Icons.info_outline),
                Expanded(
                  child: Text(
                    l10n.inventoryCountReplaceNote(
                      fmt.display.quantity(existing.quantity.toString()),
                    ),
                  ),
                ),
              ],
            ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('add_count_line_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_count_line_submit'),
        label: l10n.inventoryCountDialogRecord,
        busy: _busy,
        onPressed: _canRecord ? _record : null,
      ),
    );
  }
}
