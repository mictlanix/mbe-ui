import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest note a request takes (FR-007).
const _commentMaxLength = 500;

/// "Nueva solicitud" (spec 079 FR-006, FR-008, research R6): pick the
/// warehouse and write an optional note, then start a draft and open it.
/// Every refusal stays inline and keeps the dialog open.
///
/// Reachable only with PurchaseRequest (86) create and Warehouses (4) read;
/// the list screen gates its button.
Future<void> showNewRequestDialog(BuildContext context) async {
  final id = await showResponsiveDialog<int>(
    context,
    builder: (_) => const _NewRequestDialog(),
  );
  if (id != null && context.mounted) {
    context.push('$purchaseRequestsPath/$id');
  }
}

class _NewRequestDialog extends ConsumerStatefulWidget {
  const _NewRequestDialog();

  @override
  ConsumerState<_NewRequestDialog> createState() => _NewRequestDialogState();
}

class _NewRequestDialogState extends ConsumerState<_NewRequestDialog> {
  final _comment = TextEditingController();

  /// The warehouse the user picked; `null` keeps the starting one.
  Warehouse? _picked;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// The starting warehouse alone isn't a change.
  bool _hasUnsavedChanges() => _picked != null || _comment.text.isNotEmpty;

  Future<void> _create(int warehouseId) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final comment = _comment.text.trim();
    final result = await ref
        .read(purchaseRequestActionsProvider.notifier)
        .create(
          warehouseId: warehouseId,
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
    final scope = ref.watch(inventoryWarehouseScopeProvider);
    final start = ref.watch(inventoryStartingWarehouseProvider).value;
    final startName = start == null
        ? null
        : (ref.watch(warehouseDisplayNameProvider(start)).value ?? '#$start');
    final warehouseId = _picked?.warehouseId ?? start;
    final commentTooLong = _comment.text.length > _commentMaxLength;

    return ResponsiveDialog(
      key: const Key('new_purchase_request_dialog'),
      title: l10n.purchaseRequestNewTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (scope.noFacility)
            Text(
              l10n.purchaseRequestNoFacility,
              key: const Key('new_purchase_request_no_facility'),
            ),
          CatalogEntityPicker<Warehouse>(
            key: const Key('new_purchase_request_warehouse'),
            label: l10n.purchaseRequestFieldWarehouse,
            enabled: !_busy,
            displayStringForOption: (w) => w.name,
            optionSubtitle: (w) => w.facilityName,
            optionsBuilder: (search) => inventoryWarehouseOptions(
              ref.read(warehouseRepositoryProvider),
              scope,
              search,
            ),
            onSelected: (w) => setState(() {
              _picked = w;
              _refusal = null;
            }),
            // The pick, once there is one: the starting name may resolve
            // after it and must not replace it.
            initialDisplayText: _picked?.name ?? startName,
          ),
          TextField(
            key: const Key('new_purchase_request_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            maxLength: _commentMaxLength,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Crear" stays disabled.
            maxLengthEnforcement: MaxLengthEnforcement.none,
            decoration: InputDecoration(
              labelText: l10n.purchaseRequestFieldComment,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('new_purchase_request_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('new_purchase_request_submit'),
        label: l10n.purchaseRequestNewSubmit,
        busy: _busy,
        onPressed: warehouseId == null || commentTooLong
            ? null
            : () => _create(warehouseId),
      ),
    );
  }
}
