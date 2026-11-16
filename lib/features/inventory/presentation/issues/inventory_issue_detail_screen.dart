import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/add_issue_line_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issues_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/issue_dialogs.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/issue_header_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One warehouse issue (spec 068 contracts/ui-contract.md "Detail screen"):
/// the header facts, the lines and the action area.
///
/// A full screen with its own address, because an issue owns lines (§VI
/// document reading). `AppBar.actions` stays empty; every action is in the
/// body. A draft is edited in place; any other issue is read-only.
class InventoryIssueDetailScreen extends ConsumerWidget {
  /// [issueId] is `null` for an address whose id isn't a number, which shows
  /// the not-found state instead of throwing.
  const InventoryIssueDetailScreen({super.key, required this.issueId});

  final int? issueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = issueId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navInventoryIssues)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(inventoryIssueDetailControllerProvider(id));
    final issue = detail.value;

    return Scaffold(
      appBar: AppBar(
        // A draft has no folio yet.
        title: Text(
          issue == null
              ? l10n.navInventoryIssues
              : issue.serial == null
              ? l10n.inventoryIssueTitleDraft('${issue.id}')
              : l10n.inventoryIssueTitle('${issue.serial}'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () =>
                    ref.invalidate(inventoryIssueDetailControllerProvider(id)),
              ),
        data: (issue) => _IssueBody(issue: issue),
      ),
    );
  }
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(inventoryIssuesPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('inventory_issue_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('inventory_issue_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.inventoryIssueBackToList),
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('inventory_issue_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('inventory_issue_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.inventoryIssueBackToList),
              ),
              FilledButton(
                key: const Key('inventory_issue_retry_button'),
                onPressed: onRetry,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The loaded issue, as a column of sections: facts, lines, refusal, action
/// area.
///
/// Stateful so a refusal survives the reload a write triggers: every write
/// goes through `InventoryIssueActions`, which puts the returned issue into
/// the detail provider, so this body is rebuilt with it.
class _IssueBody extends ConsumerStatefulWidget {
  const _IssueBody({required this.issue});

  final InventoryIssue issue;

  @override
  ConsumerState<_IssueBody> createState() => _IssueBodyState();
}

class _IssueBodyState extends ConsumerState<_IssueBody> {
  /// The last action's refusal, shown above the action area.
  AppError? _actionError;

  InventoryIssue get _issue => widget.issue;

  Future<void> _confirm() async {
    setState(() => _actionError = null);
    final result = await showConfirmIssueDialog(context, _issue);
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  /// "Producto: {code}" for an `inventory_document.insufficient_stock`
  /// refusal, whose params name the product only by id (research R5). The
  /// shared message stays generic; this enrichment is the screen's.
  // simplified: the lookup covers only this issue's lines, which is every
  // product a confirm refusal can name (the server sums the issue's own
  // lines); should another action raise it for a product not on the issue,
  // the code falls back to "#{id}".
  String? _refusalProductCode(AppError error) {
    final problem = error.problem;
    if (problem?.code !=
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock) {
      return null;
    }
    final productId = problem!.intParam('product_id');
    if (productId == null) return null;
    for (final line in _issue.lines) {
      if (line.productId == productId) {
        return line.productCode ?? '#$productId';
      }
    }
    return '#$productId';
  }

  Future<void> _editHeader() async {
    setState(() => _actionError = null);
    await showIssueHeaderDialog(context, _issue);
  }

  Future<void> _cancel() async {
    setState(() => _actionError = null);
    final result = await showCancelIssueDialog(context, _issue);
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  Future<void> _addProduct() async {
    setState(() => _actionError = null);
    await showAddIssueLineDialog(context, issueId: _issue.id);
  }

  Future<void> _editLine(InventoryIssueLine line) async {
    setState(() => _actionError = null);
    await showIssueLineQuantityDialog(context, issueId: _issue.id, line: line);
  }

  Future<void> _removeLine(InventoryIssueLine line) async {
    setState(() => _actionError = null);
    await showRemoveIssueLineDialog(context, issueId: _issue.id, line: line);
  }

  /// The action area, left to right (ui-contract "Action area"): Cancelar,
  /// Editar encabezado, Agregar producto, Confirmar. Each follows data-model
  /// "Action availability" and is absent, never disabled, without its right:
  /// a `null` callback builds nothing.
  List<Widget> _actionButtons({
    required bool canEdit,
    required bool canReadProducts,
    VoidCallback? onCancel,
    VoidCallback? onEditHeader,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final error = Theme.of(context).colorScheme.error;
    return [
      // InventoryIssues (16) delete, on any issue not yet cancelled.
      if (onCancel != null)
        OutlinedButton(
          key: const Key('inventory_issue_cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: error,
            side: BorderSide(color: error),
          ),
          onPressed: onCancel,
          child: Text(l10n.inventoryIssueCancel),
        ),
      // InventoryIssues (16) update on a draft.
      if (onEditHeader != null)
        OutlinedButton(
          key: const Key('inventory_issue_edit_header'),
          onPressed: onEditHeader,
          child: Text(l10n.inventoryIssueEditHeader),
        ),
      // InventoryIssues (16) update on a draft, plus Products read for the
      // picker.
      if (canEdit && canReadProducts)
        OutlinedButton.icon(
          key: const Key('inventory_issue_add_product'),
          onPressed: _addProduct,
          icon: Icon(CatalogAction.create.icon),
          label: Text(l10n.inventoryIssueAddProduct),
        ),
      // InventoryIssues (16) update on a draft.
      if (canEdit)
        FilledButton(
          key: const Key('inventory_issue_confirm'),
          onPressed: _confirm,
          child: Text(l10n.inventoryIssueConfirm),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final issue = _issue;
    // InventoryIssues (16) update: lines and header are editable only on a
    // draft.
    final canEdit =
        issue.isDraft &&
        access.can(SystemObject.inventoryIssues, AccessRight.update);
    final buttons = _actionButtons(
      canEdit: canEdit,
      canReadProducts: access.can(SystemObject.products, AccessRight.read),
      // InventoryIssues (16) delete, on a draft or completed issue.
      onCancel:
          issue.status != InventoryDocumentStatus.cancelled &&
              access.can(SystemObject.inventoryIssues, AccessRight.delete)
          ? _cancel
          : null,
      onEditHeader: canEdit ? _editHeader : null,
    );
    final actionError = _actionError;
    final refusalProduct = actionError == null
        ? null
        : _refusalProductCode(actionError);
    // The issue's own warehouse is the only one a confirm checks (R5).
    final refusalWarehouse = refusalProduct == null
        ? null
        : ref.watch(warehouseDisplayNameProvider(issue.warehouseId)).value ??
              '#${issue.warehouseId}';

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          _HeaderFacts(issue: issue),
          _LinesSection(
            issue: issue,
            onEditLine: canEdit ? _editLine : null,
            onRemoveLine: canEdit ? _removeLine : null,
          ),
          if (actionError != null)
            Column(
              key: const Key('inventory_issue_refusal'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing.xs,
              children: [
                ErrorBanner(error: actionError),
                if (refusalProduct != null && refusalWarehouse != null)
                  Text(
                    l10n.inventoryIssueRefusalProductWarehouse(
                      refusalProduct,
                      refusalWarehouse,
                    ),
                    key: const Key('inventory_issue_refusal_product'),
                  ),
              ],
            ),
          if (buttons.isNotEmpty)
            Align(
              key: const Key('inventory_issue_actions'),
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: buttons,
              ),
            ),
        ],
      ),
    );
  }
}

/// The header: Estado, Folio, Almacén and Sucursal on one strip (plus the
/// supplier return when there is one), then the reason and who created and
/// last changed it.
class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.issue});

  final InventoryIssue issue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final comment = issue.comment;
    final supplierReturnId = issue.supplierReturnId;

    Widget byAt(int employeeId, DateTime at) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: InventoryEmployeeName(employeeId: employeeId)),
        Text(' · ${fmt.display.dateTime(at)}'),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        FactStripRow(
          key: const Key('inventory_issue_facts'),
          facts: [
            CompactField(
              label: l10n.inventoryIssueFactStatus,
              child: InventoryDocumentStatusChip(status: issue.status),
            ),
            CompactField(
              label: l10n.inventoryIssueFactFolio,
              child: Text(
                issue.serial == null
                    ? emptyValuePlaceholder
                    : '${issue.serial}',
                key: const Key('inventory_issue_serial'),
              ),
            ),
            CompactField(
              label: l10n.inventoryIssueFactWarehouse,
              child: InventoryWarehouseName(warehouseId: issue.warehouseId),
            ),
            CompactField(
              label: l10n.inventoryIssueFactFacility,
              child: InventoryFacilityName(facilityId: issue.facilityId),
            ),
          ],
          trailing: const SizedBox.shrink(),
        ),
        ResponsiveFormGrid(
          key: const Key('inventory_issue_detail_band'),
          spacing: spacing.fieldGapHorizontal,
          alignment: AlignmentDirectional.centerStart.resolve(
            Directionality.of(context),
          ),
          children: [
            // Legacy link only: plain text, never a link (research R7).
            if (supplierReturnId != null)
              FormGridChild(
                Text(
                  l10n.inventoryIssueFactSupplierReturn('$supplierReturnId'),
                  key: const Key('inventory_issue_supplier_return'),
                ),
              ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryIssueFactComment,
                child: Text(
                  comment == null || comment.isEmpty
                      ? emptyValuePlaceholder
                      : comment,
                  key: const Key('inventory_issue_comment'),
                ),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryIssueFactCreatedBy,
                child: byAt(issue.creatorId, issue.createdAt),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryIssueFactModifiedBy,
                child: byAt(issue.updaterId, issue.modifiedAt),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The lines: Código, Producto, Cantidad. On an editable draft each row has
/// ✎ (quantity) and 🗑 (remove).
class _LinesSection extends ConsumerWidget {
  const _LinesSection({
    required this.issue,
    this.onEditLine,
    this.onRemoveLine,
  });

  final InventoryIssue issue;

  /// Each `null` hides its row icon.
  final void Function(InventoryIssueLine line)? onEditLine;
  final void Function(InventoryIssueLine line)? onRemoveLine;

  /// ✎ and 🗑 for [line], or none when the lines aren't editable.
  List<Widget> _lineActions(AppLocalizations l10n, InventoryIssueLine line) {
    final onEdit = onEditLine;
    final onRemove = onRemoveLine;
    if (onEdit == null || onRemove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.inventoryIssueLineEditTooltip,
      editKey: Key('inventory_issue_line_edit_${line.id}'),
      onEdit: () => onEdit(line),
      extraActions: [
        CatalogRowAction(
          key: Key('inventory_issue_line_remove_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.inventoryIssueLineRemoveTooltip,
          onPressed: () => onRemove(line),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final lines = issue.lines;

    return Column(
      key: const Key('inventory_issue_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(l10n.inventoryIssueLinesTitle, style: theme.textTheme.titleMedium),
        if (lines.isEmpty && issue.isDraft)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.lg),
              child: Text(
                l10n.inventoryIssueLinesEmpty,
                key: const Key('inventory_issue_lines_empty'),
              ),
            ),
          )
        else
          DataTableView<InventoryIssueLine>(
            key: const Key('inventory_issue_lines_table'),
            shrinkWrap: true,
            margin: EdgeInsets.zero,
            rows: lines,
            rowActionsBuilder: onEditLine == null
                ? null
                : (context, line) => _lineActions(l10n, line),
            columns: [
              DataTableColumn.text(
                label: l10n.inventoryIssueLineColCode,
                size: ColumnSize.S,
                text: (line) => line.productCode ?? emptyValuePlaceholder,
              ),
              DataTableColumn.text(
                label: l10n.inventoryIssueLineColProduct,
                size: ColumnSize.L,
                text: (line) => line.productName ?? emptyValuePlaceholder,
              ),
              DataTableColumn(
                label: l10n.inventoryIssueLineColQuantity,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) => Text(
                  fmt.display.quantity(line.quantity.toString()),
                  key: Key('inventory_issue_line_quantity_${line.id}'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
