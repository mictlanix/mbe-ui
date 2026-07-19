import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';

part 'suppliers_list_controller.g.dart';

const _pageSize = 20;

/// Holds the current search text for the Suppliers catalog screen (FR-001,
/// FR-002).
@riverpod
class SupplierSearchController extends _$SupplierSearchController {
  @override
  String build() => '';

  void searchChanged(String value) => state = value;
}

/// Fetches and holds the Suppliers list (FR-001), re-fetching page 0
/// whenever the search text changes. Mirrors `PriceListsListController`'s
/// `CatalogPage<T>` pagination pattern.
@riverpod
class SuppliersListController extends _$SuppliersListController {
  @override
  Future<CatalogPage<Supplier>> build() {
    final search = ref.watch(supplierSearchControllerProvider);
    return _fetch(search, pageIndex: 0);
  }

  Future<CatalogPage<Supplier>> _fetch(
    String search, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(supplierRepositoryProvider)
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
    final search = ref.read(supplierSearchControllerProvider);
    state = const AsyncLoading<CatalogPage<Supplier>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(search, pageIndex: pageIndex));
  }
}
