import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_children.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_children_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/facility_child_row.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/facility_child_section.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The view/edit/create callbacks one child type (warehouses, points of
/// sale, cash drawers) needs from [FacilityCard]. `onEdit`/`onCreate` are
/// `null` when the current user lacks the corresponding privilege — hidden,
/// never disabled (FR-028).
class FacilityChildActions {
  const FacilityChildActions({
    required this.onView,
    this.onEdit,
    this.onCreate,
  });

  final void Function(int id) onView;
  final void Function(int id)? onEdit;
  final VoidCallback? onCreate;
}

/// One expandable facility card in the nested hierarchy
/// (018-nested-facility-management FR-005–FR-011, FR-020).
///
/// The chevron (`facility_card_toggle_<id>`) and the rest of the header are
/// two independent tap targets: the chevron only expands/collapses this
/// card, while the header body opens the facility read-only (FR-024) — so
/// neither gesture ever fights the other for a tap.
class FacilityCard extends ConsumerWidget {
  const FacilityCard({
    super.key,
    required this.facility,
    required this.expanded,
    required this.onToggle,
    required this.onView,
    this.onEdit,
    required this.warehouseActions,
    required this.pointSaleActions,
    required this.cashDrawerActions,
  });

  final FacilityListItem facility;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final FacilityChildActions warehouseActions;
  final FacilityChildActions pointSaleActions;
  final FacilityChildActions cashDrawerActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isStore = facility.type == FacilityType.store;

    final childrenAsync = ref.watch(
      facilityChildrenControllerProvider(facility.facilityId, facility.type),
    );
    final children = childrenAsync.valueOrNull;

    return Card(
      key: Key('facility_card_${facility.facilityId}'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            facility: facility,
            expanded: expanded,
            onToggle: onToggle,
            onView: onView,
            onEdit: onEdit,
            isStore: isStore,
            children: children,
            hasError: childrenAsync.hasError,
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 20, 20),
              child: childrenAsync.when(
                data: (data) => _ExpandedBody(
                  facility: facility,
                  data: data,
                  isStore: isStore,
                  warehouseActions: warehouseActions,
                  pointSaleActions: pointSaleActions,
                  cashDrawerActions: cashDrawerActions,
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ErrorBanner(
                        error: error is AppError
                            ? error
                            : const AppError.server(),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        key: Key(
                          'facility_children_retry_${facility.facilityId}',
                        ),
                        onPressed: () => ref.invalidate(
                          facilityChildrenControllerProvider(
                            facility.facilityId,
                            facility.type,
                          ),
                        ),
                        child: Text(l10n.retryButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.facility,
    required this.expanded,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
    required this.isStore,
    required this.children,
    required this.hasError,
  });

  final FacilityListItem facility;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final bool isStore;
  final FacilityChildren? children;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isCompact = LayoutBreakpoints.isCompact(context);
    final typeIcon = isStore ? Icons.storefront_outlined : Icons.factory_outlined;
    final typeLabel = isStore
        ? l10n.facilityTypeStore
        : l10n.facilityTypeProductionSite;

    final toggleButton = IconButton(
      key: Key('facility_card_toggle_${facility.facilityId}'),
      icon: Icon(expanded ? Icons.expand_more : Icons.chevron_right),
      tooltip: expanded ? l10n.facilitiesCollapseAll : l10n.facilitiesExpandAll,
      onPressed: onToggle,
    );

    final editButton = onEdit == null
        ? null
        : IconButton(
            key: Key('facility_edit_${facility.facilityId}'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editActionTooltip,
            onPressed: onEdit,
          );

    final iconTile = Container(
      width: isCompact ? 40 : 42,
      height: isCompact ? 40 : 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(typeIcon, color: scheme.onPrimaryContainer, size: 22),
    );

    final nameRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Tooltip(
            message: facility.name,
            child: Text(
              facility.name,
              style: theme.textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 10),
        FacilityCodeChip(code: facility.code),
      ],
    );

    final typeRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(typeIcon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          typeLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    final countsRow = _CountsRow(
      isStore: isStore,
      children: children,
      hasError: hasError,
    );

    final statusIndicator = isCompact
        ? FacilityStatusDot(status: facility.status)
        : EntityStatusCell(status: facility.status);

    final tapArea = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onView,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: isCompact
            // Wrapped metadata, dot status, trailing chevron (contracts
            // §6): the mock's mobile card wraps name/code/counts onto their
            // own lines rather than the wide tier's single fixed row.
            ? Row(
                children: [
                  iconTile,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [nameRow, typeRow, countsRow],
                    ),
                  ),
                  const SizedBox(width: 10),
                  statusIndicator,
                ],
              )
            : Row(
                children: [
                  iconTile,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [nameRow, const SizedBox(height: 3), typeRow],
                    ),
                  ),
                  const SizedBox(width: 12),
                  countsRow,
                  const SizedBox(width: 16),
                  statusIndicator,
                ],
              ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: isCompact
            ? [Expanded(child: tapArea), toggleButton, ?editButton]
            : [toggleButton, Expanded(child: tapArea), ?editButton],
      ),
    );
  }
}

/// Warehouse / points-of-sale / cash-drawer counts on the collapsed header
/// (FR-006). Never renders `0` while the data is still loading or failed
/// (contracts/ui-contracts.md §5) — a wrong count is worse than no count on
/// a screen whose purpose is spotting misconfiguration.
class _CountsRow extends StatelessWidget {
  const _CountsRow({
    required this.isStore,
    required this.children,
    required this.hasError,
  });

  final bool isStore;
  final FacilityChildren? children;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountBadge(
          icon: Icons.warehouse_outlined,
          count: children?.warehouseCount,
          hasError: hasError,
          readable: children?.warehousesReadable ?? true,
        ),
        if (isStore) ...[
          const SizedBox(width: 14),
          _CountBadge(
            icon: Icons.point_of_sale_outlined,
            count: children?.pointSaleCount,
            hasError: hasError,
            readable: children?.pointsOfSaleReadable ?? true,
          ),
          const SizedBox(width: 14),
          _CountBadge(
            icon: Icons.account_balance_wallet_outlined,
            count: children?.cashDrawerCount,
            hasError: hasError,
            readable: children?.cashDrawersReadable ?? true,
          ),
        ],
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.icon,
    required this.count,
    required this.hasError,
    required this.readable,
  });

  final IconData icon;
  final int? count;
  final bool hasError;
  final bool readable;

  @override
  Widget build(BuildContext context) {
    // A section the user cannot read contributes no count at all (FR-029).
    if (!readable) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        if (hasError)
          Icon(Icons.error_outline, size: 14, color: scheme.error)
        else if (count == null)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          )
        else
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({
    required this.facility,
    required this.data,
    required this.isStore,
    required this.warehouseActions,
    required this.pointSaleActions,
    required this.cashDrawerActions,
  });

  final FacilityListItem facility;
  final FacilityChildren data;
  final bool isStore;
  final FacilityChildActions warehouseActions;
  final FacilityChildActions pointSaleActions;
  final FacilityChildActions cashDrawerActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isCompact = LayoutBreakpoints.isCompact(context);
    final id = facility.facilityId;

    // Typed as FacilityChildSection, not Widget, so its `createAction`
    // getter is still reachable below (T047, contracts §6): on the compact
    // tier every section's create action is collected into one chip row at
    // the end of the card instead of sitting in each section's own header.
    final sections = <FacilityChildSection>[];

    if (data.warehousesReadable) {
      sections.add(
        FacilityChildSection(
          sectionKey: Key('facility_section_warehouses_$id'),
          label: l10n.warehousesMenuTitle,
          count: data.warehouseCount,
          emptyMessage: l10n.noWarehousesInFacility,
          createLabel: l10n.newWarehouseInFacility,
          onCreate: warehouseActions.onCreate,
          createKey: Key('facility_create_warehouse_$id'),
          showCreateInHeader: !isCompact,
          children: [
            for (final warehouse in data.warehouses)
              WarehouseChildRow(
                key: ValueKey('warehouse_${warehouse.warehouseId}'),
                warehouse: warehouse,
                onTap: () => warehouseActions.onView(warehouse.warehouseId),
                onEdit: warehouseActions.onEdit == null
                    ? null
                    : () => warehouseActions.onEdit!(warehouse.warehouseId),
              ),
          ],
        ),
      );
    }

    if (isStore) {
      if (data.pointsOfSaleReadable) {
        sections.add(
          FacilityChildSection(
            sectionKey: Key('facility_section_points_of_sale_$id'),
            label: l10n.pointsOfSaleMenuTitle,
            count: data.pointSaleCount,
            emptyMessage: l10n.noPointsOfSaleInFacility,
            createLabel: l10n.newPointSaleInFacility,
            onCreate: pointSaleActions.onCreate,
            createKey: Key('facility_create_point_sale_$id'),
            showCreateInHeader: !isCompact,
            children: [
              for (final pointSale in data.pointsOfSale)
                PointSaleChildRow(
                  key: ValueKey('point_sale_${pointSale.pointSaleId}'),
                  pointSale: pointSale,
                  isCrossFacility: data.isCrossFacility(pointSale),
                  onTap: () => pointSaleActions.onView(pointSale.pointSaleId),
                  onEdit: pointSaleActions.onEdit == null
                      ? null
                      : () => pointSaleActions.onEdit!(pointSale.pointSaleId),
                ),
            ],
          ),
        );
      }

      if (data.cashDrawersReadable) {
        sections.add(
          FacilityChildSection(
            sectionKey: Key('facility_section_cash_drawers_$id'),
            label: l10n.cashDrawersMenuTitle,
            count: data.cashDrawerCount,
            emptyMessage: l10n.noCashDrawersInFacility,
            createLabel: l10n.newCashDrawerInFacility,
            onCreate: cashDrawerActions.onCreate,
            createKey: Key('facility_create_cash_drawer_$id'),
            showCreateInHeader: !isCompact,
            children: [
              for (final cashDrawer in data.cashDrawers)
                CashDrawerChildRow(
                  key: ValueKey('cash_drawer_${cashDrawer.cashDrawerId}'),
                  cashDrawer: cashDrawer,
                  onTap: () => cashDrawerActions.onView(
                    cashDrawer.cashDrawerId,
                  ),
                  onEdit: cashDrawerActions.onEdit == null
                      ? null
                      : () =>
                            cashDrawerActions.onEdit!(cashDrawer.cashDrawerId),
                ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[section, const SizedBox(height: 18)],
        if (!isStore)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.productionSiteChildrenNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (isCompact)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in sections.map((s) => s.createAction))
                  ?action,
              ],
            ),
          ),
      ],
    );
  }
}
