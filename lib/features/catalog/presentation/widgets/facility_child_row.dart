import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A monospace code chip, shared by every row (and the facility card header)
/// in the nested hierarchy (018-nested-facility-management contracts/
/// ui-contracts.md §1). All color from the theme (FR-030).
class FacilityCodeChip extends StatelessWidget {
  const FacilityCodeChip({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontFamily: TypeRoles.monoFamily,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A colored status dot, used in place of [EntityStatusCell]'s badge on the
/// compact tier (contracts/ui-contracts.md §6). Shares [EntityStatusCell]'s
/// active/inactive/archived color intent but as a compact indicator rather
/// than a labeled chip — all color from the theme (FR-030).
class FacilityStatusDot extends StatelessWidget {
  const FacilityStatusDot({super.key, required this.status});

  final EntityStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = switch (status) {
      EntityStatus.active => theme.brandInk.primary,
      EntityStatus.inactive => scheme.error,
      EntityStatus.archived => scheme.outline,
    };
    return Container(
      key: Key('status_dot_${status.name}'),
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// One warehouse row in a facility's Warehouses section (FR-008).
class WarehouseChildRow extends StatelessWidget {
  const WarehouseChildRow({
    super.key,
    required this.warehouse,
    required this.onTap,
    this.onEdit,
  });

  final Warehouse warehouse;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _ChildRowShell(
      key: Key('warehouse_row_${warehouse.warehouseId}'),
      icon: Icons.warehouse_outlined,
      iconColor: scheme.tertiary,
      name: warehouse.name,
      code: warehouse.code,
      status: warehouse.status,
      onTap: onTap,
      onEdit: onEdit,
    );
  }
}

/// One point-of-sale row in a facility's Points of Sale section. Names the
/// warehouse it draws stock from and, when that warehouse belongs to a
/// different facility, shows a badge (FR-009) — a legacy-data affordance,
/// since mbe-api rejects that combination on write (research §3).
class PointSaleChildRow extends StatelessWidget {
  const PointSaleChildRow({
    super.key,
    required this.pointSale,
    required this.isCrossFacility,
    required this.onTap,
    this.onEdit,
  });

  final PointSale pointSale;
  final bool isCrossFacility;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return _ChildRowShell(
      key: Key('point_sale_row_${pointSale.pointSaleId}'),
      icon: Icons.point_of_sale_outlined,
      iconColor: theme.brandInk.primary,
      name: pointSale.name,
      code: pointSale.code,
      status: pointSale.status,
      onTap: onTap,
      onEdit: onEdit,
      extraMeta: [
        Tooltip(
          message: pointSale.warehouseDisplayName(l10n.unknownWarehouseLabel),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  pointSale.warehouseDisplayName(l10n.unknownWarehouseLabel),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (isCrossFacility)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link, size: 14, color: scheme.onTertiaryContainer),
                const SizedBox(width: 4),
                Text(
                  l10n.pointSaleForeignFacilityBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One cash-drawer row in a facility's Cash Drawers section (FR-008).
class CashDrawerChildRow extends StatelessWidget {
  const CashDrawerChildRow({
    super.key,
    required this.cashDrawer,
    required this.onTap,
    this.onEdit,
  });

  final CashDrawer cashDrawer;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _ChildRowShell(
      key: Key('cash_drawer_row_${cashDrawer.cashDrawerId}'),
      icon: Icons.account_balance_wallet_outlined,
      iconColor: scheme.secondary,
      name: cashDrawer.name,
      code: cashDrawer.code,
      status: cashDrawer.status,
      onTap: onTap,
      onEdit: onEdit,
    );
  }
}

/// Shared row layout: type icon, name, code chip, optional extra metadata
/// (POS only), status, and the shared Edit affordance (constitution §VI —
/// one fixed icon, hidden rather than disabled when [onEdit] is `null`).
/// Tapping anywhere but the edit icon opens the record read-only (FR-024).
class _ChildRowShell extends StatelessWidget {
  const _ChildRowShell({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.code,
    required this.status,
    required this.onTap,
    this.onEdit,
    this.extraMeta = const [],
  });

  final IconData icon;
  final Color iconColor;
  final String name;
  final String code;
  final EntityStatus status;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final List<Widget> extraMeta;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isCompact = LayoutBreakpoints.isCompact(context);

    final statusIndicator = isCompact
        ? FacilityStatusDot(status: status)
        : EntityStatusCell(status: status);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: isCompact
                    // Wrapped metadata on the compact tier (contracts §6):
                    // name, code and any extra meta (e.g. a POS row's
                    // warehouse) flow onto their own lines instead of being
                    // squeezed into one row and ellipsized on a narrow
                    // screen.
                    ? Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          Text(name, style: theme.textTheme.bodyMedium),
                          FacilityCodeChip(code: code),
                          ...extraMeta,
                        ],
                      )
                    : Row(
                        children: [
                          Flexible(
                            child: Tooltip(
                              message: name,
                              child: Text(
                                name,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FacilityCodeChip(code: code),
                          const Spacer(),
                          for (final meta in extraMeta) ...[
                            meta,
                            const SizedBox(width: 12),
                          ],
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              statusIndicator,
              ...buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
