import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_delivery_field.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest note an order takes (FR-011).
const _commentMaxLength = 500;

/// "Editar encabezado" (spec 080 FR-011, research R7): change draft
/// [order]'s supplier, estimated receipt date or notes. `true` once saved;
/// every refusal stays inline, localized from its code, and keeps the dialog
/// open.
///
/// Only the changed fields are sent: the supplier only when another one is
/// picked; clearing the notes sends `clearComment`, clearing the date
/// `clearDate`. The detail screen gates the button on PurchasesOrders (20)
/// update and Suppliers (3) read, on a draft.
Future<bool> showOrderHeaderDialog(
  BuildContext context,
  PurchaseOrder order,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _HeaderDialog(order: order),
    ) ??
    false;

/// [value]'s calendar day: the date is all the order keeps (research R7).
DateTime? _day(DateTime? value) =>
    value == null ? null : DateTime(value.year, value.month, value.day);

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.order});

  final PurchaseOrder order;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late final String _initialComment = widget.order.comment ?? '';
  late final _comment = TextEditingController(text: _initialComment);
  late final DateTime? _initialDelivery = _day(
    widget.order.estimatedReceiptDate,
  );
  late DateTime? _delivery = _initialDelivery;

  /// The supplier the user picked; `null` keeps the order's.
  SupplierListItem? _picked;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// The new supplier, when it differs from the order's.
  int? get _supplierChange {
    final picked = _picked?.supplierId;
    return picked == null || picked == widget.order.supplierId ? null : picked;
  }

  bool get _commentChanged => _comment.text.trim() != _initialComment.trim();

  bool get _deliveryChanged => _delivery != _initialDelivery;

  bool _hasUnsavedChanges() =>
      _supplierChange != null || _commentChanged || _deliveryChanged;

  /// The notes' length as sent: trimmed.
  int get _commentLength => _comment.text.trim().length;

  bool get _commentTooLong => _commentLength > _commentMaxLength;

  bool get _canSave => !_busy && _hasUnsavedChanges() && !_commentTooLong;

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final comment = _comment.text.trim();
    final delivery = _delivery;
    final error = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .updateHeader(
          widget.order.id,
          supplierId: _supplierChange,
          estimatedReceiptDate: _deliveryChanged ? delivery : null,
          clearDate: _deliveryChanged && delivery == null,
          comment: _commentChanged && comment.isNotEmpty ? comment : null,
          clearComment: _commentChanged && comment.isEmpty,
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
    final picked = _picked;

    return ResponsiveDialog(
      key: const Key('purchase_order_header_dialog'),
      title: l10n.purchaseOrderEditHeaderTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          CatalogEntityPicker<SupplierListItem>(
            key: const Key('purchase_order_header_supplier'),
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
              _picked = s;
              _refusal = null;
            }),
            // The order carries the supplier's name only, not its code.
            initialDisplayText: picked == null
                ? widget.order.supplierName
                : '${picked.code} — ${picked.name}',
          ),
          OrderDeliveryField(
            key: const Key('purchase_order_header_delivery'),
            clearKey: const Key('purchase_order_header_delivery_clear'),
            value: _delivery,
            enabled: !_busy,
            onChanged: (d) => setState(() {
              _delivery = d;
              _refusal = null;
            }),
          ),
          TextField(
            key: const Key('purchase_order_header_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Guardar" stays disabled. The
            // counter counts the trimmed text, which is what is sent.
            decoration: InputDecoration(
              labelText: l10n.purchaseOrderFieldNotes,
              counterText: '$_commentLength/$_commentMaxLength',
              errorText: _commentTooLong ? '' : null,
              counterStyle: _commentTooLong
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('purchase_order_header_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('purchase_order_header_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
