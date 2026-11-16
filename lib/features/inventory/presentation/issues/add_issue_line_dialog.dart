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
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Agregar producto" (spec 068 FR-008, FR-009, research R3): pick an
/// active, stockable product and the quantity received, then add it to draft
/// [issueId]. A product already on the issue is merged into its line by
/// the server, and the screen shows the issue it returns. `true` once
/// added; every refusal shows inline and keeps the dialog open.
///
/// Reachable only with Products read; the detail screen gates its button.
Future<bool> showAddIssueLineDialog(
  BuildContext context, {
  required int issueId,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _AddLineDialog(issueId: issueId),
    ) ??
    false;

class _AddLineDialog extends ConsumerStatefulWidget {
  const _AddLineDialog({required this.issueId});

  final int issueId;

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

  Decimal? get _value {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  bool get _validQuantity => (_value ?? Decimal.zero) > Decimal.zero;

  bool get _canAdd => !_busy && _product != null && _validQuantity;

  Future<void> _add() async {
    final product = _product;
    final value = _value;
    if (!_canAdd || product == null || value == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryIssueActionsProvider.notifier)
        .addLine(widget.issueId, productId: product.productId, quantity: value);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('add_issue_line_dialog'),
      title: l10n.inventoryIssueAddProductTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<ProductListItem>(
            key: const Key('add_issue_line_product'),
            label: l10n.inventoryIssueFieldProduct,
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
            key: const Key('add_issue_line_quantity'),
            controller: _quantity,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.inventoryIssueFieldQuantity,
              errorText: _quantity.text.isEmpty || _validQuantity
                  ? null
                  : l10n.inventoryIssueQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _add(),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('add_issue_line_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_issue_line_submit'),
        label: l10n.inventoryIssueAddProductSubmit,
        busy: _busy,
        onPressed: _canAdd ? _add : null,
      ),
    );
  }
}
