import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';

part 'labels_list_controller.g.dart';

const _pageSize = 20;

/// Holds the current search text for the Labels catalog screen (FR-001,
/// FR-002).
@riverpod
class LabelSearchController extends _$LabelSearchController {
  @override
  String build() => '';

  void searchChanged(String value) => state = value;
}

/// Fetches and holds the Labels list (FR-001), re-fetching page 0 whenever
/// the search text changes.
@riverpod
class LabelsListController extends _$LabelsListController {
  @override
  Future<CatalogPage<Label>> build() {
    final search = ref.watch(labelSearchControllerProvider);
    return _fetch(search, pageIndex: 0);
  }

  Future<CatalogPage<Label>> _fetch(
    String search, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(labelRepositoryProvider)
        .listDetailed(
          search: search.isEmpty ? null : search,
          skip: pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }

  /// Fetches [pageIndex] and replaces the current page with it.
  Future<void> goToPage(int pageIndex) async {
    final search = ref.read(labelSearchControllerProvider);
    state = const AsyncLoading<CatalogPage<Label>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(search, pageIndex: pageIndex));
  }
}
