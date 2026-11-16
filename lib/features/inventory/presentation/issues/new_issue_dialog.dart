import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The longest note an issue takes.
const _commentMaxLength = 500;

/// "Nueva entrada" (spec 068 FR-005, research R4 and R5): pick the warehouse
/// and write an optional note, then start a draft. Answers the new issue's
/// id for the caller to open, or `null` when the user backed out. Every
/// refusal (such as `warehouse.in_transit_location`) stays inline.
///
/// Reachable only with InventoryIssues (16) create and Warehouses (4)
/// read; the list screen gates its button.
Future<int?> showNewIssueDialog(BuildContext context) =>
    showResponsiveDialog<int>(context, builder: (_) => const _NewIssueDialog());

class _NewIssueDialog extends ConsumerStatefulWidget {
  const _NewIssueDialog();

  @override
  ConsumerState<_NewIssueDialog> createState() => _NewIssueDialogState();
}

class _NewIssueDialogState extends ConsumerState<_NewIssueDialog> {
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

  /// The starting warehouse alone isn't a change (FR-005).
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
        .read(inventoryIssueActionsProvider.notifier)
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
      key: const Key('new_inventory_issue_dialog'),
      title: l10n.inventoryIssueNewTitle,
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (scope.noFacility)
            Text(
              l10n.inventoryDocumentNoFacility,
              key: const Key('new_inventory_issue_no_facility'),
            ),
          CatalogEntityPicker<Warehouse>(
            key: const Key('new_inventory_issue_warehouse'),
            label: l10n.inventoryIssueFieldWarehouse,
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
            key: const Key('new_inventory_issue_comment'),
            controller: _comment,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            maxLength: _commentMaxLength,
            // Over-long text stays visible with the counter in error, rather
            // than being cut silently, and "Crear" stays disabled.
            maxLengthEnforcement: MaxLengthEnforcement.none,
            decoration: InputDecoration(
              labelText: l10n.inventoryIssueFieldComment,
              hintText: l10n.inventoryIssueFieldCommentHint,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('new_inventory_issue_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('new_inventory_issue_submit'),
        label: l10n.inventoryIssueNewSubmit,
        busy: _busy,
        onPressed: warehouseId == null || commentTooLong
            ? null
            : () => _create(warehouseId),
      ),
    );
  }
}
