import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_delivery_field.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest note an order takes (FR-011).
const _commentMaxLength = 500;

/// "Nueva orden de compra" (spec 080 FR-010, research R6): pick the supplier,
/// optionally the estimated receipt date (today or later) and a note, then
/// start a draft and open it. Every refusal stays inline, localized from its
/// code, and keeps the dialog open.
///
/// Reachable only with PurchasesOrders (20) create and Suppliers (3) read;
/// the list screen gates its button.
Future<void> showNewOrderDialog(BuildContext context) async {
  final id = await showResponsiveDialog<int>(
    context,
    builder: (_) => const _NewOrderDialog(),
  );
  if (id != null && context.mounted) {
    context.push('$purchaseOrdersPath/$id');
  }
}

class _NewOrderDialog extends ConsumerStatefulWidget {
  const _NewOrderDialog();

  @override
  ConsumerState<_NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends ConsumerState<_NewOrderDialog> {
  final _comment = TextEditingController();
  SupplierListItem? _supplier;
  DateTime? _delivery;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() =>
      _supplier != null || _delivery != null || _comment.text.isNotEmpty;

  Future<void> _create(int supplierId) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final comment = _comment.text.trim();
    final result = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .create(
          supplierId: supplierId,
          estimatedReceiptDate: _delivery,
          comment: comment.isEmpty ? null : comment,
        );
    if (!mounted) return;
    final error = result.error;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop(result.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final supplier = _supplier;
    final commentLength = _comment.text.trim().length;
    final commentTooLong = commentLength > _commentMaxLength;

    return ResponsiveDialog(
      key: const Key('new_purchase_order_dialog'),
      title: l10n.purchaseOrderNewTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<SupplierListItem>(
            key: const Key('new_purchase_order_supplier'),
            label: l10n.purchaseOrderFieldSupplier,
            enabled: !_busy,
            displayStringForOption: (s) => '${s.code} — ${s.name}',
            optionsBuilder: (search) async {
              final result = await ref
                  .read(supplierRepositoryProvider)
                  .list(search: search.isEmpty ? null : search);
              return result.items;
            },
            onSelected: (s) => setState(() {
              _supplier = s;
              _refusal = null;
            }),
            initialDisplayText: supplier == null
                ? null
                : '${supplier.code} — ${supplier.name}',
          ),
          OrderDeliveryField(
            key: const Key('new_purchase_order_delivery'),
            clearKey: const Key('new_purchase_order_delivery_clear'),
            value: _delivery,
            enabled: !_busy,
            onChanged: (d) => setState(() => _delivery = d),
          ),
          TextField(
            key: const Key('new_purchase_order_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Crear" stays disabled. The
            // counter counts the trimmed text, which is what is sent.
            decoration: InputDecoration(
              labelText: l10n.purchaseOrderFieldNotes,
              counterText: '$commentLength/$_commentMaxLength',
              errorText: commentTooLong ? '' : null,
              counterStyle: commentTooLong
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('new_purchase_order_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('new_purchase_order_submit'),
        label: l10n.purchaseOrderCreateAction,
        busy: _busy,
        onPressed: supplier == null || commentTooLong
            ? null
            : () => _create(supplier.supplierId),
      ),
    );
  }
}
