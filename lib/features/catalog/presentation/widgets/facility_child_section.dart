import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';

/// One labeled section (Warehouses / Points of Sale / Cash Drawers) inside
/// an expanded facility card (FR-007). Shows a header with the section's
/// name and count, a create action (hidden when [onCreate] is `null` —
/// FR-028), a connector line down the left indicating hierarchy, and either
/// [children] or [emptyMessage] (FR-010). All color from the theme
/// (FR-030).
///
/// [showCreateInHeader] is `false` on the compact tier, where create actions
/// are grouped into a chip row at the end of the card instead
/// (018-nested-facility-management contracts/ui-contracts.md §6) — the
/// section still reports [onCreate]/[createLabel] via [createAction] so the
/// card can build that chip.
class FacilityChildSection extends StatelessWidget {
  const FacilityChildSection({
    super.key,
    required this.sectionKey,
    required this.label,
    required this.count,
    required this.emptyMessage,
    required this.children,
    this.createLabel,
    this.onCreate,
    this.createKey,
    this.showCreateInHeader = true,
  });

  final Key sectionKey;
  final String label;
  final int count;
  final String emptyMessage;
  final List<Widget> children;
  final String? createLabel;
  final VoidCallback? onCreate;
  final Key? createKey;
  final bool showCreateInHeader;

  /// The create action for this section, or `null` if the current user
  /// lacks the create privilege — exposed so a compact-tier card can collect
  /// every section's action into one chip row (T047).
  Widget? get createAction {
    if (createLabel == null || onCreate == null) return null;
    return OutlinedButton.icon(
      key: createKey,
      onPressed: onCreate,
      icon: const Icon(Icons.add, size: 16),
      label: Text(createLabel!),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final action = showCreateInHeader ? createAction : null;

    return Container(
      key: sectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: TypeRoles.monoFamily,
                  color: scheme.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: scheme.outlineVariant)),
              if (action != null) ...[const SizedBox(width: 12), action],
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children.isEmpty
                      ? [_EmptyPlaceholder(message: emptyMessage)]
                      : [
                          for (final child in children) ...[
                            child,
                            const SizedBox(height: 8),
                          ],
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

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
