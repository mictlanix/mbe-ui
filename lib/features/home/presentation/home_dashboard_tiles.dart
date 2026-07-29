import 'package:flutter/material.dart';

/// A single Home dashboard indicator tile (icon + value + label). Static
/// placeholder data (spec 019 FR-016) — matches the brand guide's own
/// example content verbatim; not backed by a live query. Wiring this to
/// real mbe-api data is explicitly out of scope for spec 019 and will be
/// scoped as a separate feature once that data source exists.
class DashboardIndicatorTile {
  const DashboardIndicatorTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

const _tiles = [
  DashboardIndicatorTile(
    icon: Icons.point_of_sale,
    value: r'$184,320',
    label: 'Ventas de hoy',
  ),
  DashboardIndicatorTile(
    icon: Icons.sell,
    value: '3',
    label: 'Listas por autorizar',
  ),
  DashboardIndicatorTile(
    icon: Icons.inventory_2,
    value: '21,542',
    label: 'Productos activos',
  ),
  DashboardIndicatorTile(
    icon: Icons.apartment,
    value: '9 / 14',
    label: 'Instalaciones activas',
  ),
];

/// Renders the four static indicator tiles from [_tiles] in a wrapping row
/// (spec 019 FR-015/016; data-model.md § Static Home content). Each tile
/// sizes to its own content (no fixed aspect ratio), so it never overflows
/// regardless of viewport width — narrower viewports simply wrap tiles onto
/// additional rows.
class HomeDashboardTiles extends StatelessWidget {
  const HomeDashboardTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      key: const Key('home_dashboard_tiles'),
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final tile in _tiles)
          Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tile.icon, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  tile.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tile.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
