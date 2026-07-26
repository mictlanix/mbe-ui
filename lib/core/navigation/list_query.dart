import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

part 'list_query.freezed.dart';

/// Reserved query parameter names — never usable as a facet key.
const _reservedParamNames = {'search', 'page', 'view'};

/// The addressable state of a list screen (017-ui-consistency-filters
/// contracts/list-query.md): search text, current page, and every facet
/// selection, decoded from and encoded to a route's query string.
///
/// [ListQuery] is deliberately generic and facet-value-type-agnostic — it
/// carries raw strings. Typed interpretation (an `EntityStatus`, an `int` FK
/// id, a tri-state `bool`) happens per entity in that screen's own
/// `XFilter.fromQuery(ListQuery)` (data-model.md §2), which is also where a
/// single-valued facet takes the first of a repeated key and an unparseable
/// value degrades to absent (contracts/list-query.md §5) — this type only
/// guarantees the *decode* never throws, not that every value is meaningful.
@freezed
class ListQuery with _$ListQuery {
  const factory ListQuery({
    @Default('') String search,
    @Default(0) int pageIndex,
    @Default(<String, List<String>>{}) Map<String, List<String>> facets,
  }) = _ListQuery;

  /// Decodes [uri]'s query string. Total — never throws, per
  /// contracts/list-query.md §5: an unparseable `page` becomes page 1 (index
  /// 0), and every other query parameter is captured into [facets] verbatim
  /// (a caller reading only the keys it recognizes is how an unknown
  /// parameter ends up ignored).
  factory ListQuery.fromUri(Uri uri) {
    final params = uri.queryParametersAll;

    final searchValues = params['search'];
    final search = (searchValues != null && searchValues.isNotEmpty)
        ? searchValues.first
        : '';

    var pageIndex = 0;
    final pageValues = params['page'];
    if (pageValues != null && pageValues.isNotEmpty) {
      final parsed = int.tryParse(pageValues.first);
      if (parsed != null && parsed > 0) pageIndex = parsed - 1;
    }

    final facets = <String, List<String>>{
      for (final entry in params.entries)
        if (!_reservedParamNames.contains(entry.key) && entry.value.isNotEmpty)
          entry.key: entry.value,
    };

    return ListQuery(search: search, pageIndex: pageIndex, facets: facets);
  }
}

/// Derived state and encoding — kept as an extension rather than in the
/// `@freezed` class body, matching this codebase's existing convention for
/// custom members on a freezed value (see `WarehouseFilterBadge`).
extension ListQueryX on ListQuery {
  /// Whether any search term or facet is applied — the signal that
  /// distinguishes an empty catalog from an over-filtered one (FR-028),
  /// without any extra state.
  bool get isFiltered => search.isNotEmpty || facets.isNotEmpty;

  /// A default query — unfiltered, first page — encodes to a bare path with
  /// no query string (FR-020).
  bool get isDefault => !isFiltered && pageIndex == 0;

  /// The first value of facet [key], or `null` if absent — for a
  /// single-valued facet, where a repeated key takes the first value
  /// (contracts/list-query.md §5).
  String? facet(String key) {
    final values = facets[key];
    return (values != null && values.isNotEmpty) ? values.first : null;
  }

  /// All values of facet [key] — for a multi-valued facet (e.g. products'
  /// `label`).
  List<String> facetValues(String key) => facets[key] ?? const [];

  /// Returns a copy with single-valued facet [key] set to [value], or
  /// removed when [value] is `null`/empty. Reassigning an existing key
  /// preserves its position in the encoded order; a genuinely new key is
  /// appended — Dart's `Map` preserves insertion order, so a screen that
  /// always sets its facets in the same sequence gets a stable, canonical
  /// URL (contracts/list-query.md §4) without tracking order separately.
  ListQuery withFacet(String key, String? value) {
    final next = Map<String, List<String>>.from(facets);
    if (value == null || value.isEmpty) {
      next.remove(key);
    } else {
      next[key] = [value];
    }
    return copyWith(facets: next);
  }

  /// Returns a copy with multi-valued facet [key] set to [values], or
  /// removed when [values] is empty (e.g. products' `label`).
  ListQuery withFacetValues(String key, List<String> values) {
    final next = Map<String, List<String>>.from(facets);
    if (values.isEmpty) {
      next.remove(key);
    } else {
      next[key] = values;
    }
    return copyWith(facets: next);
  }

  /// Encodes this query onto [path]. Deterministic: `search`, then `page`,
  /// then facets in [facets]' own iteration order — callers MUST insert
  /// facets in the canonical per-screen order (contracts/list-query.md §4)
  /// for the encoded URL to be byte-identical across equivalent views.
  /// Default values are omitted (FR-020).
  Uri toUri(String path) {
    final query = <String, dynamic>{};
    if (search.isNotEmpty) query['search'] = search;
    if (pageIndex > 0) query['page'] = '${pageIndex + 1}';
    for (final entry in facets.entries) {
      if (entry.value.isEmpty) continue;
      query[entry.key] = entry.value.length == 1
          ? entry.value.single
          : entry.value;
    }
    if (query.isEmpty) return Uri.parse(path);
    return Uri(path: path, queryParameters: query);
  }
}

/// Rebuilds [builder] with the [ListQuery] decoded from the **current**
/// route location, live.
///
/// A catalog filter sheet (`showCatalogFilterSheet`) is pushed onto the
/// *root* Navigator, separate from the routed list screen that opened it
/// (`core/widgets/catalog_filter_sheet.dart`). If that sheet's content took
/// its `ListQuery` as a plain constructor parameter, it would be frozen at
/// whatever the URL was the moment the sheet opened — Flutter has no
/// mechanism to push a new value into an already-built widget's final
/// field. A second filter change made without closing the sheet would then
/// be computed from that stale, pre-first-change value: the list itself
/// (which *is* part of the routed subtree and does get a fresh `query`)
/// would end up right, but the sheet's own controls would silently fail to
/// show the first change and could compute the second change incorrectly.
///
/// `GoRouter.of(context)` and [ListenableBuilder] both operate on the
/// Element tree, not Navigator boundaries, so this works regardless of
/// which Navigator [builder]'s `context` happens to be hosted by.
class CurrentListQueryBuilder extends StatelessWidget {
  const CurrentListQueryBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ListQuery query) builder;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) => builder(
        context,
        ListQuery.fromUri(router.routerDelegate.currentConfiguration.uri),
      ),
    );
  }
}
