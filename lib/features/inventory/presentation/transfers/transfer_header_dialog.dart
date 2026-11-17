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
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest note a transfer takes.
const _commentMaxLength = 500;

/// "Editar encabezado" (spec 069 FR-006): change draft [transfer]'s origin,
/// destination or notes. `true` once saved; every refusal (such as
/// `inventory_transfer.same_warehouse` or `warehouse.in_transit_location`)
/// stays inline and keeps the dialog open.
///
/// Only the changed fields are sent; clearing the notes is sent as
/// `clearComment`, which the repository sends as `""`. Changing the origin
/// moves the draft to that warehouse's facility. The detail screen gates the
/// button on InventoryTransfers (17) update and a draft; a warehouse picker
/// needs Warehouses (4) read, otherwise the name is shown as text.
Future<bool> showTransferHeaderDialog(
  BuildContext context,
  InventoryTransfer transfer,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _HeaderDialog(transfer: transfer),
    ) ??
    false;

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.transfer});

  final InventoryTransfer transfer;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late final String _initialComment = widget.transfer.comment ?? '';
  late final _comment = TextEditingController(text: _initialComment);

  /// The warehouses the user picked; `null` keeps the transfer's.
  Warehouse? _source;
  Warehouse? _destination;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// [picked]'s id, when it differs from [current].
  int? _change(Warehouse? picked, int current) {
    final id = picked?.warehouseId;
    return id == null || id == current ? null : id;
  }

  int? get _sourceChange => _change(_source, widget.transfer.warehouseId);
  int? get _destinationChange =>
      _change(_destination, widget.transfer.warehouseToId);

  bool get _commentChanged => _comment.text.trim() != _initialComment.trim();

  bool _hasUnsavedChanges() =>
      _sourceChange != null || _destinationChange != null || _commentChanged;

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
        .read(inventoryTransferActionsProvider.notifier)
        .updateHeader(
          widget.transfer.id,
          warehouseId: _sourceChange,
          warehouseToId: _destinationChange,
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
    final transfer = widget.transfer;
    final scope = ref.watch(inventoryWarehouseScopeProvider);
    // Warehouses (4) read: the pickers search that catalog.
    final canPick = ref
        .watch(accessControlProvider)
        .can(SystemObject.warehouses, AccessRight.read);
    String name(int id) =>
        ref.watch(warehouseDisplayNameProvider(id)).value ?? '#$id';

    return ResponsiveDialog(
      key: const Key('inventory_transfer_header_dialog'),
      title: l10n.inventoryTransferEditHeaderTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (canPick) ...[
            // A non-administrator's own-facility warehouses; an
            // administrator's: every one.
            CatalogEntityPicker<Warehouse>(
              key: const Key('inventory_transfer_header_source'),
              label: l10n.inventoryTransferFieldSource,
              enabled: !_busy,
              displayStringForOption: (w) => w.name,
              optionSubtitle: (w) => w.facilityName,
              optionsBuilder: (search) => inventoryWarehouseOptions(
                ref.read(warehouseRepositoryProvider),
                scope,
                search,
              ),
              onSelected: (w) => setState(() {
                _source = w;
                _refusal = null;
              }),
              // The pick, once there is one: the current name may resolve
              // after it and must not replace it.
              initialDisplayText: _source?.name ?? name(transfer.warehouseId),
            ),
            // Every warehouse, whatever the user's facility.
            CatalogEntityPicker<Warehouse>(
              key: const Key('inventory_transfer_header_destination'),
              label: l10n.inventoryTransferFieldDestination,
              enabled: !_busy,
              displayStringForOption: (w) => w.name,
              optionSubtitle: (w) => w.facilityName,
              optionsBuilder: (search) => inventoryFilterWarehouseOptions(
                ref.read(warehouseRepositoryProvider),
                search,
              ),
              onSelected: (w) => setState(() {
                _destination = w;
                _refusal = null;
              }),
              initialDisplayText:
                  _destination?.name ?? name(transfer.warehouseToId),
            ),
          ] else ...[
            CompactField(
              key: const Key('inventory_transfer_header_source_text'),
              label: l10n.inventoryTransferFieldSource,
              child: InventoryWarehouseName(warehouseId: transfer.warehouseId),
            ),
            CompactField(
              key: const Key('inventory_transfer_header_destination_text'),
              label: l10n.inventoryTransferFieldDestination,
              child: InventoryWarehouseName(
                warehouseId: transfer.warehouseToId,
              ),
            ),
          ],
          TextField(
            key: const Key('inventory_transfer_header_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            maxLength: _commentMaxLength,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Guardar" stays disabled.
            maxLengthEnforcement: MaxLengthEnforcement.none,
            decoration: InputDecoration(
              labelText: l10n.inventoryTransferFieldNotes,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('inventory_transfer_header_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_transfer_header_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
