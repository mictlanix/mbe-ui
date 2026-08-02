import 'package:flutter/material.dart';

/// A single Home recent-activity line (icon + description + timestamp).
/// Static placeholder data (spec 019 FR-016) — matches the brand guide's
/// own example content verbatim; not backed by a live query. Wiring this to
/// real mbe-api data is explicitly out of scope for spec 019 and will be
/// scoped as a separate feature once that data source exists.
class ActivityFeedEntry {
  const ActivityFeedEntry({
    required this.icon,
    required this.text,
    required this.time,
  });

  final IconData icon;
  final String text;
  final String time;
}

const _entries = [
  ActivityFeedEntry(
    icon: Icons.sell,
    text: 'Lista de precios «Mayoreo Q3» enviada a autorización',
    time: '08:42',
  ),
  ActivityFeedEntry(
    icon: Icons.inventory_2,
    text: '38 productos GREENFIELD actualizados por importación',
    time: '08:15',
  ),
  ActivityFeedEntry(
    icon: Icons.point_of_sale,
    text: 'Corte de caja CMC3 cerrado',
    time: 'Ayer 21:10',
  ),
  ActivityFeedEntry(
    icon: Icons.badge,
    text: 'Alta de empleado: J. Domínguez · CMHU',
    time: 'Ayer 17:55',
  ),
];

/// Renders the four static recent-activity entries from [_entries] as a
/// list panel (spec 019 FR-015/016; data-model.md § Static Home content).
class HomeActivityFeed extends StatelessWidget {
  const HomeActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('home_activity_feed'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _entries.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(
                        top: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
              ),
              child: Row(
                children: [
                  Icon(
                    _entries[i].icon,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _entries[i].text,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _entries[i].time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'RobotoMono',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
