import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/approval_queue_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/approval_selection.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/bulk_approve_result_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_availability.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/request_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const purchaseRequestApprovalPath = '/purchases/request-approval';

/// Aprobación de solicitudes: every facility's submitted requests, oldest
/// first, for a supervisor to approve one by one or several at once (spec
/// 079 US2, contracts/ui-contract.md "Aprobación de solicitudes"). Gated by
/// PurchaseRequestApproval (SystemObject 96) read.
///
/// The filter row has no search (the endpoint has none). Its one facet,
/// Sucursal, lives in the filter drawer (§VI), which needs Facilities read.
/// Approving (the checkbox column, the row ✓ and "Aprobar seleccionadas")
/// needs 96 update; opening a row needs PurchaseRequest (86) read.
/// Rejecting happens on the detail (Clarification 1).
class PurchaseRequestApprovalScreen extends ConsumerStatefulWidget {
  const PurchaseRequestApprovalScreen({super.key, required this.query});

  final ListQuery query;

  @override
  ConsumerState<PurchaseRequestApprovalScreen> createState() =>
      _PurchaseRequestApprovalScreenState();
}

class _PurchaseRequestApprovalScreenState
    extends ConsumerState<PurchaseRequestApprovalScreen> {
  /// A bulk approval is in flight: its button is disabled meanwhile.
  bool _approving = false;

  ApprovalQueueFilter get _filter =>
      ApprovalQueueFilter.fromQuery(widget.query);

  /// Approves [r] after its prompt and says so (FR-021). The queue reloads by
  /// itself: the write invalidates it.
  Future<void> _approve(PurchaseRequestSummary r) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final folio = r.serial == null
        ? l10n.purchaseRequestDraftFolio('${r.id}')
        : '${r.serial}';
    final approved = await showApproveRequestDialog(context, (
      id: r.id,
      serial: r.serial,
      facilityId: r.facilityId,
      warehouseId: r.warehouseId,
      lineCount: r.lineCount,
    ));
    if (!approved) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.purchaseRequestApprovedSnack(folio))),
    );
  }

  /// Approves the selection in one call (FR-023): a SnackBar when every one
  /// went through, the result dialog when any was refused. The queue reloads
  /// and the selection clears either way.
  Future<void> _approveSelected(List<PurchaseRequestSummary> pageRows) async {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.read(formattersProvider);
    final messenger = ScaffoldMessenger.of(context);
    final selection = ref.read(approvalSelectionProvider(_filter));
    // Kept by id before the call: the reloaded queue no longer holds the
    // approved requests.
    final requests = {
      for (final r in pageRows)
        if (selection.contains(r.id)) r.id: r,
    };
    setState(() => _approving = true);
    final (:error, :outcomes) = await ref
        .read(purchaseRequestActionsProvider.notifier)
        .approveMany(requests.keys.toList());
    if (!mounted) return;
    setState(() => _approving = false);
    ref.read(approvalSelectionProvider(_filter).notifier).clear();

    if (error != null || outcomes == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error?.userMessage(l10n, fmt) ?? l10n.errorServerGeneric,
          ),
        ),
      );
      return;
    }
    if (outcomes.every((o) => o.approved)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.purchaseRequestBulkApprovedSnack(
              fmt.display.count(outcomes.length),
            ),
          ),
        ),
      );
      return;
    }
    await showBulkApproveResultDialog(
      context,
      outcomes: outcomes,
      requests: requests,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final auth = ref.watch(authProvider).value;
    final userFacilityId = auth is AuthAuthenticated
        ? auth.user.settings?.facilityId
        : null;
    // What the user may do with a row (data-model "Action availability").
    PurchaseRequestAvailability can(PurchaseRequestSummary r) =>
        PurchaseRequestAvailability(
          status: r.status,
          facilityId: r.facilityId,
          access: access,
          userFacilityId: userFacilityId,
        );
    // PurchaseRequest (86) read opens a row's detail
    // (`PurchaseRequestAvailability.canOpenFromQueue`, the same for every
    // row).
    final canOpen = access.can(SystemObject.purchaseRequest, AccessRight.read);
    // PurchaseRequestApproval (96) update: the checkbox column, the row ✓
    // and "Aprobar seleccionadas" (FR-021, FR-023, FR-025).
    final canDecide = access.can(
      SystemObject.purchaseRequestApproval,
      AccessRight.update,
    );
    // Facilities read: the Sucursal facet. Without it there is no facet, so
    // the filters button is left out.
    final canPickFacility = access.can(
      SystemObject.facilities,
      AccessRight.read,
    );
    final filter = _filter;
    final pageAsync = ref.watch(approvalQueueControllerProvider(filter));
    final selection = ref.watch(approvalSelectionProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final pageRows = pageAsync.value?.items ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          // No search: `/purchase-requests/approval-queue` has none.
          actions: [
            if (canPickFacility)
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.activeFilterCount > 0,
                child: IconButton.outlined(
                  key: const Key('purchase_request_approval_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(purchaseRequestApprovalPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _ApprovalFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            // The one disabled control: present because the user can act,
            // disabled until something is selected (FR-023).
            if (canDecide)
              FilledButton.icon(
                key: const Key('purchase_request_approve_selected'),
                onPressed: selection.isEmpty || _approving
                    ? null
                    : () => _approveSelected(pageRows),
                icon: const Icon(Icons.check),
                label: Text(
                  l10n.purchaseRequestApproveSelected(
                    fmt.display.count(selection.length),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<PurchaseRequestSummary>(
            state: pageAsync,
            isFiltered: filter.facilityId != null,
            emptyMessage: l10n.purchaseRequestQueueEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(purchaseRequestApprovalPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(approvalQueueControllerProvider(filter)),
            onData: (page) => DataTableView<PurchaseRequestSummary>(
              key: const Key('purchase_request_approval_table'),
              columns: [
                if (canDecide)
                  _checkboxColumn(
                    filter: filter,
                    selection: selection,
                    selectable: [
                      for (final r in page.items)
                        if (can(r).canApproveFromQueue) r.id,
                    ],
                  ),
                DataTableColumn(
                  label: l10n.purchaseRequestColFolio,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, r) => RecordIdText(
                    r.serial == null
                        ? l10n.purchaseRequestDraftFolio('${r.id}')
                        : '${r.serial}',
                    key: Key('purchase_request_folio_${r.id}'),
                    textAlign: TextAlign.end,
                  ),
                ),
                DataTableColumn(
                  label: l10n.purchaseRequestColFacility,
                  size: ColumnSize.M,
                  cellBuilder: (context, r) {
                    final facilityId = r.facilityId;
                    return facilityId == null
                        ? const SizedBox.shrink()
                        : InventoryFacilityName(facilityId: facilityId);
                  },
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.purchaseRequestColWarehouse,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) =>
                        InventoryWarehouseName(warehouseId: r.warehouseId),
                  ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.purchaseRequestColCreator,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) =>
                        InventoryEmployeeName(employeeId: r.creatorId),
                  ),
                if (!compact)
                  DataTableColumn.timestamp(
                    label: l10n.purchaseRequestColDate,
                    size: ColumnSize.S,
                    text: (r) => fmt.display.dateTime(r.date),
                  ),
                DataTableColumn(
                  label: l10n.purchaseRequestColLines,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, r) => Text(
                    fmt.display.count(r.lineCount),
                    key: Key('purchase_request_lines_${r.id}'),
                  ),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.purchaseRequestColComment,
                    size: ColumnSize.L,
                    cellBuilder: (context, r) {
                      final comment = r.comment ?? '';
                      return Tooltip(
                        message: comment,
                        child: Text(
                          comment,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (index) => context.go(
                widget.query
                    .copyWith(pageIndex: index)
                    .toUri(purchaseRequestApprovalPath)
                    .toString(),
              ),
              // PurchaseRequest (86) read opens the detail; push, so back
              // returns to the queue (FR-020). Without it rows don't respond
              // (Clarification 1).
              onRowTap: canOpen
                  ? (r) => context.push('$purchaseRequestsPath/${r.id}')
                  : null,
              // The row's one icon is ✓ "Aprobar" (96 update). There is no
              // row ✕: rejecting needs the detail.
              rowActionsBuilder: canDecide
                  ? (context, r) => can(r).canApproveFromQueue
                        ? buildCatalogRowActions(
                            editTooltip: l10n.editActionTooltip,
                            primaryAction: CatalogRowAction(
                              key: Key('purchase_request_approve_${r.id}'),
                              icon: Icons.check_circle_outline,
                              tooltip: l10n.purchaseRequestApprove,
                              onPressed: () => _approve(r),
                            ),
                          )
                        : const []
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// The leading checkbox column (research R10): a live checkbox per row,
  /// bound to the selection, and a tristate select-all for the page in the
  /// header. The row tap opens the detail, so each checkbox handles its own
  /// tap.
  DataTableColumn<PurchaseRequestSummary> _checkboxColumn({
    required ApprovalQueueFilter filter,
    required Set<int> selection,
    required List<int> selectable,
  }) {
    final notifier = ref.read(approvalSelectionProvider(filter).notifier);
    final all = selectable.isNotEmpty && selectable.every(selection.contains);
    return DataTableColumn(
      label: '',
      fixedWidth: 48,
      header: Checkbox(
        key: const Key('purchase_request_select_all'),
        tristate: true,
        value: all ? true : (selection.isEmpty ? false : null),
        onChanged: selectable.isEmpty
            ? null
            : (_) => all ? notifier.clear() : notifier.selectAll(selectable),
      ),
      cellBuilder: (context, r) => selectable.contains(r.id)
          ? Checkbox(
              key: Key('purchase_request_select_${r.id}'),
              value: selection.contains(r.id),
              onChanged: (_) => notifier.toggle(r.id),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// The drawer's one facet, Sucursal (shown only with Facilities read). A
/// change writes the address and returns to the first page.
class _ApprovalFiltersPanel extends ConsumerWidget {
  const _ApprovalFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ApprovalQueueFilter.fromQuery(query);
    final facilityId = filter.facilityId;
    final facilityName = facilityId == null
        ? null
        : ref.watch(facilityDisplayNameProvider(facilityId)).value;

    return CatalogEntityPicker<FacilityListItem>(
      key: const Key('purchase_request_approval_filter_facility'),
      label: l10n.purchaseRequestFacetFacility,
      displayStringForOption: (f) => f.name,
      optionsBuilder: (search) async {
        final result = await ref
            .read(facilityRepositoryProvider)
            .list(search: search.isEmpty ? null : search);
        return result.items;
      },
      onSelected: (f) => context.go(
        query
            .withFacet('facility', '${f.facilityId}')
            .copyWith(pageIndex: 0)
            .toUri(purchaseRequestApprovalPath)
            .toString(),
      ),
      initialDisplayText: facilityId == null
          ? null
          : (facilityName ?? '$facilityId'),
    );
  }
}
