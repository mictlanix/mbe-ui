import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Agregar producto" (spec 079 FR-010, FR-011, research R6): pick an
/// active, purchasable product and add it to draft [requestId]. The server
/// fills the name, the quantity (the product's minimum, or 1) and the
/// destination (the header's warehouse). `true` once added; every refusal
/// (`product.not_purchasable`, `warehouse.in_transit_location`,
/// `purchase_request.not_draft`, ...) shows inline and keeps the dialog open.
///
/// Reachable only with Products read; the detail screen gates its button.
Future<bool> showAddRequestLineDialog(
  BuildContext context, {
  required int requestId,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _AddLineDialog(requestId: requestId),
    ) ??
    false;

class _AddLineDialog extends ConsumerStatefulWidget {
  const _AddLineDialog({required this.requestId});

  final int requestId;

  @override
  ConsumerState<_AddLineDialog> createState() => _AddLineDialogState();
}

class _AddLineDialogState extends ConsumerState<_AddLineDialog> {
  ProductListItem? _product;
  bool _busy = false;
  AppError? _refusal;

  Future<void> _add() async {
    final product = _product;
    if (_busy || product == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(purchaseRequestActionsProvider.notifier)
        .addLine(widget.requestId, productId: product.productId);
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
      key: const Key('add_request_line_dialog'),
      title: l10n.purchaseRequestAddProductTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _product != null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<ProductListItem>(
            key: const Key('add_request_line_product'),
            label: l10n.purchaseRequestFieldProduct,
            enabled: !_busy,
            // Not after a pick: the picker remounts with the chosen name, and
            // refocusing it would reopen the options over "Agregar".
            autofocus: _product == null,
            displayStringForOption: (p) => p.name,
            optionsBuilder: (query) async {
              final trimmed = query.trim();
              if (trimmed.isEmpty) return const [];
              final result = await ref
                  .read(productRepositoryProvider)
                  .list(
                    search: trimmed,
                    status: EntityStatus.active,
                    purchasable: true,
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
          if (_refusal != null)
            ErrorBanner(
              key: const Key('add_request_line_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_request_line_submit'),
        label: l10n.purchaseRequestAddProductSubmit,
        busy: _busy,
        onPressed: _product == null ? null : _add,
      ),
    );
  }
}
