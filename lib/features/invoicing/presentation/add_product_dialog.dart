import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Adds a manual product line to draft [documentId] (spec 066 C11). Picking a
/// product adds it at quantity 1 and the customer's price-list price.
///
/// `product_unpriced` (the product isn't on the customer's price list) stays
/// inline so another product can be picked; any other refusal closes the
/// dialog and is answered to the caller to show. `null` when the user backed
/// out.
Future<FiscalDocumentActionResult?> showAddInvoiceProductDialog(
  BuildContext context, {
  required int documentId,
}) => showDialog<FiscalDocumentActionResult>(
  context: context,
  builder: (_) => _AddProductDialog(documentId: documentId),
);

class _AddProductDialog extends ConsumerStatefulWidget {
  const _AddProductDialog({required this.documentId});

  final int documentId;

  @override
  ConsumerState<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<_AddProductDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _add(ProductListItem product) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .addProduct(widget.documentId, product.productId);
    if (!mounted) return;
    if (error?.problem?.code ==
        api.ErrorCode.fiscalDocumentPeriodProductUnpriced) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('add_invoice_product_dialog'),
      title: l10n.fiscalDocumentAddProductTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<ProductListItem>(
            key: const Key('add_invoice_product_field'),
            label: l10n.fiscalDocumentAddProductPicker,
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
                    limit: 10,
                  );
              return result.items;
            },
            onSelected: _add,
            optionImageUrl: (p) => p.photo,
            optionSubtitle: (p) => p.code,
          ),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
        ],
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_invoice_product_close'),
        label: l10n.cancelButton,
        busy: _busy,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
    );
  }
}
