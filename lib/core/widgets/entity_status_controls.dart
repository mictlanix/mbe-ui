import 'package:flutter/material.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Shared presentation of [EntityStatus] — the lifecycle state every catalog
/// entity now carries (mbe-api#80/#81). These live in one place so the six
/// status-bearing catalogs (products, customers, employees, users, vehicles,
/// vehicle operators) label and filter status identically, which is the whole
/// point of the API-side unification.

/// The localized name of [status], for table cells and dropdown items.
String entityStatusLabel(AppLocalizations l10n, EntityStatus status) =>
    switch (status) {
      EntityStatus.active => l10n.statusActive,
      EntityStatus.inactive => l10n.statusInactive,
      EntityStatus.archived => l10n.statusArchived,
    };

/// A table cell showing an entity's [status]. Non-active states get a tinted
/// chip so they stand out in a list of mostly-active records; active renders
/// as plain text to keep the common case quiet.
class EntityStatusCell extends StatelessWidget {
  const EntityStatusCell({super.key, required this.status});

  final EntityStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final label = entityStatusLabel(l10n, status);

    if (status == EntityStatus.active) return Text(label);

    final (background, foreground) = switch (status) {
      EntityStatus.inactive => (scheme.errorContainer, scheme.onErrorContainer),
      // Archived is a deliberate, non-error end state — tone it down.
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };

    return Chip(
      key: Key('status_badge_${status.name}'),
      label: Text(label),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// The status facet filter: "All" plus one chip per [EntityStatus]. A `null`
/// [value] means "All" and sends no `?status=` param, matching mbe-api's
/// "omit the parameter to get every state" contract.
class EntityStatusFilterChips extends StatelessWidget {
  const EntityStatusFilterChips({
    super.key,
    required this.filterKey,
    required this.value,
    required this.onChanged,
  });

  /// Key prefix so each catalog's chips stay addressable in widget tests,
  /// e.g. `products_filter_status` -> `products_filter_status_active`.
  final String filterKey;
  final EntityStatus? value;
  final ValueChanged<EntityStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          key: Key('${filterKey}_all'),
          label: Text(l10n.statusFilterAll),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final status in EntityStatus.values)
          ChoiceChip(
            key: Key('${filterKey}_${status.name}'),
            label: Text(entityStatusLabel(l10n, status)),
            selected: value == status,
            onSelected: (_) => onChanged(status),
          ),
      ],
    );
  }
}

/// The status form field, offering every state mbe-api accepts. Passing a
/// null [onChanged] renders it read-only, matching the other form fields'
/// view-mode convention.
class EntityStatusFormField extends StatelessWidget {
  const EntityStatusFormField({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final EntityStatus value;
  final ValueChanged<EntityStatus>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<EntityStatus>(
      key: const Key('status_field'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.statusFilterLabel,
        errorText: errorText,
      ),
      items: [
        for (final status in EntityStatus.values)
          DropdownMenuItem(
            value: status,
            child: Text(entityStatusLabel(l10n, status)),
          ),
      ],
      onChanged: onChanged == null
          ? null
          : (status) {
              if (status != null) onChanged!(status);
            },
    );
  }
}
