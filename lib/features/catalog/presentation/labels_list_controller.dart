import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';

part 'labels_list_controller.freezed.dart';
part 'labels_list_controller.g.dart';

const _pageSize = 20;

/// The Labels list screen's addressable view state
/// (017-ui-consistency-filters FR-017): search only — the list endpoint
/// exposes no facets beyond `search` (plan.md Constitution Check note on
/// §VI). Derived from the route's [ListQuery] — the URL, not a mutable
/// notifier, is the source of truth.
@freezed
class LabelFilter with _$LabelFilter {
  const factory LabelFilter({
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _LabelFilter;

  factory LabelFilter.fromQuery(ListQuery query) {
    return LabelFilter(search: query.search, pageIndex: query.pageIndex);
  }
}

/// Fetches and holds the Labels list (FR-001) for the given [LabelFilter]. A
/// family keyed by the filter value: a different URL is a different
/// provider instance, and `ref.invalidate` after a mutation re-fetches the
/// *same* page rather than resetting to page 0 (FR-025, research §3).
@riverpod
class LabelsListController extends _$LabelsListController {
  @override
  Future<CatalogPage<Label>> build(LabelFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<Label>> _fetch(LabelFilter filter) async {
    final result = await ref
        .read(labelRepositoryProvider)
        .listDetailed(
          search: filter.search.isEmpty ? null : filter.search,
          skip: filter.pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
    );
  }
}
