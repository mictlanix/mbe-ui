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
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest comment a count takes.
const _commentMaxLength = 500;

/// "Editar encabezado" (spec 070 US5, FR-006): change draft [count]'s
/// warehouse or comment. `true` once saved; every refusal (such as
/// `warehouse.in_transit_location`) stays inline and keeps the dialog open.
///
/// The warehouse is sent only when it changed. The comment is always sent,
/// because `updateHeader` always sends it (contracts/repository.md): the
/// current text, or `null` when cleared, which the repository sends as "".
/// The detail screen gates the button on PhysicalCountAdjustment (74)
/// update and a draft.
Future<bool> showCountHeaderDialog(
  BuildContext context,
  InventoryCount count,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _HeaderDialog(count: count),
    ) ??
    false;

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.count});

  final InventoryCount count;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late final String _initialComment = widget.count.comment ?? '';
  late final _comment = TextEditingController(text: _initialComment);

  /// The warehouse the user picked; `null` keeps the count's.
  Warehouse? _picked;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// The new warehouse, when it differs from the count's.
  int? get _warehouseChange {
    final picked = _picked?.warehouseId;
    return picked == null || picked == widget.count.warehouseId ? null : picked;
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
        .read(inventoryCountActionsProvider.notifier)
        .updateHeader(
          widget.count.id,
          warehouseId: _warehouseChange,
          comment: comment.isEmpty ? null : comment,
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
    final count = widget.count;
    // Warehouses (4) read: the picker searches that catalog (FR-006).
    final canPick = ref
        .watch(accessControlProvider)
        .can(SystemObject.warehouses, AccessRight.read);

    return ResponsiveDialog(
      key: const Key('inventory_count_header_dialog'),
      title: l10n.inventoryCountDialogEditTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (canPick)
            _WarehousePicker(
              count: count,
              picked: _picked,
              enabled: !_busy,
              onSelected: (w) => setState(() {
                _picked = w;
                _refusal = null;
              }),
            )
          else
            CompactField(
              key: const Key('inventory_count_header_warehouse_text'),
              label: l10n.inventoryCountFieldWarehouse,
              child: InventoryWarehouseName(warehouseId: count.warehouseId),
            ),
          TextField(
            key: const Key('inventory_count_header_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            maxLength: _commentMaxLength,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Guardar" stays disabled.
            maxLengthEnforcement: MaxLengthEnforcement.none,
            decoration: InputDecoration(
              labelText: l10n.inventoryCountFieldComment,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('inventory_count_header_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_count_header_submit'),
        label: l10n.inventoryCountDialogSave,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}

/// The warehouse picker over the user's own-facility warehouses (an
/// administrator's: every one), starting on the count's.
class _WarehousePicker extends ConsumerWidget {
  const _WarehousePicker({
    required this.count,
    required this.picked,
    required this.enabled,
    required this.onSelected,
  });

  final InventoryCount count;
  final Warehouse? picked;
  final bool enabled;
  final ValueChanged<Warehouse> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scope = ref.watch(inventoryWarehouseScopeProvider);
    final current =
        ref.watch(warehouseDisplayNameProvider(count.warehouseId)).value ??
        '#${count.warehouseId}';
    return CatalogEntityPicker<Warehouse>(
      key: const Key('inventory_count_header_warehouse'),
      label: l10n.inventoryCountFieldWarehouse,
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
