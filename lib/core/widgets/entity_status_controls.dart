import 'package:flutter/material.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Shared presentation of [EntityStatus] — the lifecycle state every catalog
/// entity now carries (mbe-api#80/#81). These live in one place so the six
/// status-bearing catalogs (products, customers, employees, users, vehicles,
/// vehicle operators) label and filter status identically, which is the whole
/// point of the API-side unification.

/// Decodes the shared status facet with the entity-lifecycle default (spec
/// 035 FR-001/FR-002/FR-004): the facet absent means [EntityStatus.active] —
/// the applied default, not "no filter" — present as the literal `all` means
/// every state (the user's explicit choice to clear that default), and any
/// other value parses as that [EntityStatus], falling back to the default on
/// an unrecognized one rather than a filter that silently returns nothing.
/// Replaces the identical private `byNameOrNull` extension every
/// status-bearing list controller used to redefine for itself.
EntityStatus? decodeStatusFacet(ListQuery query, {String facetKey = 'status'}) {
  final raw = query.facet(facetKey);
  if (raw == null) return EntityStatus.active;
  if (raw == 'all') return null;
  for (final status in EntityStatus.values) {
    if (status.name == raw) return status;
  }
  return EntityStatus.active;
}

/// Encodes [status] onto [query]'s status facet, the write-side counterpart
/// to [decodeStatusFacet]. `null` (the user's explicit "All" selection)
/// writes the literal `all` rather than clearing the facet, so it stays
/// distinguishable from the default-applied Active state that an absent
/// facet now means — clearing the facet would silently reapply the default
/// instead of honoring "All" (FR-004).
ListQuery encodeStatusFacet(
  ListQuery query,
  EntityStatus? status, {
  String facetKey = 'status',
}) => query.withFacet(facetKey, status?.name ?? 'all');

/// Whether a status-defaulted list's result should read as "your filters
/// hide everything" rather than "this catalog is genuinely empty" (spec 035
/// FR-003/FR-006, Edge Cases) — the value each of the ten status-defaulted
/// list screens MUST pass as `CatalogListStateView.isFiltered` in place of
/// the raw `query.isFiltered`.
///
/// `ListQuery.isFiltered` alone is wrong here: it is `true` whenever
/// [query]'s raw `facets` map is non-empty, but writing the literal
/// `status=all` (the user's explicit "show every state") *does* put a key
/// in that map even though it means the opposite of "narrowed" — that
/// combination previously read as "filtered" and showed the wrong empty
/// state. This excludes [facetKey] from the raw check and instead asks
/// whether the *decoded* [status] (from [decodeStatusFacet]) narrows to
/// anything less than every state.
bool isFilteredBeyondStatusDefault(
  ListQuery query,
  EntityStatus? status, {
  String facetKey = 'status',
}) {
  final otherFacetsPresent = query.facets.keys.any((key) => key != facetKey);
  return query.search.isNotEmpty || otherFacetsPresent || status != null;
}

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
    final label = entityStatusLabel(l10n, status);

    if (status == EntityStatus.active) return Text(label);

    return StatusChip<EntityStatus>(
      key: Key('status_badge_${status.name}'),
      value: status,
      label: label,
      colors: (scheme) => switch (status) {
        EntityStatus.inactive => (
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
        // Archived is a deliberate, non-error end state — tone it down.
        _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      },
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
