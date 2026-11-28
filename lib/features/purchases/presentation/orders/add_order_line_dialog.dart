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
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The most decimals a quantity takes (FR-015).
const _quantityMaxScale = 4;

/// "Agregar producto" (spec 080 FR-013, FR-014, research R8): pick an active,
/// purchasable product and a quantity, and add it to draft [orderId]. The
/// server fills the warehouse, the price and the tax rate. `true` once added;
/// every refusal (`product.not_purchasable`, the warehouse required or in
/// transit, ...) shows inline, localized from its code, and keeps the dialog
/// open.
///
/// Reachable only with PurchasesOrders (20) update and Products read; the
/// detail screen gates its button.
Future<bool> showAddOrderLineDialog(
  BuildContext context, {
  required int orderId,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _AddLineDialog(orderId: orderId),
    ) ??
    false;

class _AddLineDialog extends ConsumerStatefulWidget {
  const _AddLineDialog({required this.orderId});

  final int orderId;

  @override
  ConsumerState<_AddLineDialog> createState() => _AddLineDialogState();
}

class _AddLineDialogState extends ConsumerState<_AddLineDialog> {
  final _quantity = TextEditingController(text: '1');
  ProductListItem? _product;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Decimal? get _quantityValue {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  /// Greater than 0, with at most 4 decimals (FR-015).
  bool get _validQuantity {
    final value = _quantityValue;
    return value != null &&
        value > Decimal.zero &&
        value.scale <= _quantityMaxScale;
  }

  Future<void> _add() async {
    final product = _product;
    final quantity = _quantityValue;
    if (_busy || product == null || quantity == null || !_validQuantity) {
      return;
    }
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .addLine(
          widget.orderId,
          productId: product.productId,
          quantity: quantity,
        );
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
      key: const Key('add_order_line_dialog'),
      title: l10n.purchaseOrderAddProductTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _product != null || _quantity.text != '1',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<ProductListItem>(
            key: const Key('add_order_line_product'),
            label: l10n.purchaseOrderFieldProduct,
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
          TextField(
            key: const Key('add_order_line_quantity'),
            controller: _quantity,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.purchaseOrderFieldQuantity,
              errorText: _validQuantity
                  ? null
                  : l10n.purchaseOrderQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('add_order_line_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_order_line_submit'),
        label: l10n.purchaseOrderAddAction,
        busy: _busy,
        onPressed: _product == null || !_validQuantity ? null : _add,
      ),
    );
  }
}
