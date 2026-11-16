import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest note a receipt takes.
const _commentMaxLength = 500;

/// "Editar encabezado" (spec 067 US3, FR-006, FR-016, FR-017): change draft
/// [receipt]'s warehouse or notes. `true` once saved; every refusal (such as
/// `warehouse.in_transit_location`) stays inline and keeps the dialog open.
///
/// Only the changed fields are sent; clearing the notes is sent as
/// `clearComment` (research R8). The detail screen gates the button on
/// InventoryReceipts (15) update and a draft.
Future<bool> showReceiptHeaderDialog(
  BuildContext context,
  InventoryReceipt receipt,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _HeaderDialog(receipt: receipt),
    ) ??
    false;

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.receipt});

  final InventoryReceipt receipt;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late final String _initialComment = widget.receipt.comment ?? '';
  late final _comment = TextEditingController(text: _initialComment);

  /// The warehouse the user picked; `null` keeps the receipt's.
  Warehouse? _picked;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// The new warehouse, when it differs from the receipt's.
  int? get _warehouseChange {
    final picked = _picked?.warehouseId;
    return picked == null || picked == widget.receipt.warehouseId
        ? null
        : picked;
  }

  bool get _commentChanged => _comment.text.trim() != _initialComment.trim();

  bool _hasUnsavedChanges() => _warehouseChange != null || _commentChanged;

  bool get _canSave =>
      !_busy &&
      _hasUnsavedChanges() &&
      _comment.text.length <= _commentMaxLength;

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final comment = _comment.text.trim();
    final error = await ref
        .read(inventoryReceiptActionsProvider.notifier)
        .updateHeader(
          widget.receipt.id,
          warehouseId: _warehouseChange,
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
    final receipt = widget.receipt;
    // Warehouses (4) read: the picker searches that catalog (FR-016). A
    // purchase-order receipt's warehouse is fixed (FR-006).
    final canPick =
        !receipt.isLinked &&
        ref
            .watch(accessControlProvider)
            .can(SystemObject.warehouses, AccessRight.read);

    return ResponsiveDialog(
      key: const Key('receipt_header_dialog'),
      title: l10n.inventoryReceiptEditHeaderTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (canPick)
            _WarehousePicker(
              receipt: receipt,
              picked: _picked,
              enabled: !_busy,
              onSelected: (w) => setState(() {
                _picked = w;
                _refusal = null;
              }),
            )
          else
            CompactField(
              key: const Key('receipt_header_warehouse_text'),
              label: l10n.inventoryReceiptFieldWarehouse,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: spacing.sm,
                children: [
                  Flexible(
                    child: InventoryWarehouseName(
                      warehouseId: receipt.warehouseId,
                    ),
                  ),
                  if (receipt.isLinked)
                    Text('(${l10n.inventoryReceiptWarehouseFixed})'),
                ],
              ),
            ),
          TextField(
            key: const Key('receipt_header_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            maxLength: _commentMaxLength,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Guardar" stays disabled.
            maxLengthEnforcement: MaxLengthEnforcement.none,
            decoration: InputDecoration(
              labelText: l10n.inventoryReceiptFieldComment,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('receipt_header_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('receipt_header_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}

/// The warehouse picker over the user's own-facility warehouses (an
/// administrator's: every one), starting on the receipt's.
class _WarehousePicker extends ConsumerWidget {
  const _WarehousePicker({
    required this.receipt,
    required this.picked,
    required this.enabled,
    required this.onSelected,
  });

  final InventoryReceipt receipt;
  final Warehouse? picked;
  final bool enabled;
  final ValueChanged<Warehouse> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scope = ref.watch(inventoryWarehouseScopeProvider);
    final current =
        ref.watch(warehouseDisplayNameProvider(receipt.warehouseId)).value ??
        '#${receipt.warehouseId}';
    return CatalogEntityPicker<Warehouse>(
      key: const Key('receipt_header_warehouse'),
      label: l10n.inventoryReceiptFieldWarehouse,
      enabled: enabled,
      displayStringForOption: (w) => w.name,
      optionSubtitle: (w) => w.facilityName,
      optionsBuilder: (search) => inventoryWarehouseOptions(
        ref.read(warehouseRepositoryProvider),
        scope,
        search,
      ),
      onSelected: onSelected,
      // The pick, once there is one: the current name may resolve after it
      // and must not replace it.
      initialDisplayText: picked?.name ?? current,
    );
  }
}
