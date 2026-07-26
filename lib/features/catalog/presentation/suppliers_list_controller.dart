import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';

part 'suppliers_list_controller.freezed.dart';
part 'suppliers_list_controller.g.dart';

const _pageSize = 20;

/// The Suppliers list screen's addressable view state
/// (017-ui-consistency-filters FR-017): search only. Derived from the
/// route's [ListQuery] — the URL, not a mutable notifier, is the source of
/// truth.
@freezed
class SupplierFilter with _$SupplierFilter {
  const factory SupplierFilter({
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _SupplierFilter;

  factory SupplierFilter.fromQuery(ListQuery query) {
    return SupplierFilter(search: query.search, pageIndex: query.pageIndex);
  }
}

/// Fetches and holds the Suppliers list (FR-001) for the given
/// [SupplierFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class SuppliersListController extends _$SuppliersListController {
  @override
  Future<CatalogPage<Supplier>> build(SupplierFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<Supplier>> _fetch(SupplierFilter filter) async {
    final result = await ref
        .read(supplierRepositoryProvider)
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
