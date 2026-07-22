import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';

part 'taxpayer_issuers_list_controller.g.dart';

const _pageSize = 20;

/// Holds the current search text for the Taxpayer Issuers catalog screen
/// (FR-010, FR-031). Search-only — the issuer has no backend facets, so
/// there is no companion filter controller (contracts/mbe-api-catalogs.md §2).
@riverpod
class TaxpayerIssuerSearchController extends _$TaxpayerIssuerSearchController {
  @override
  String build() => '';

  void searchChanged(String value) => state = value;
}

/// Fetches and holds the Taxpayer Issuers list (FR-010), re-fetching page 0
/// whenever the search text changes. Reuses `TaxpayerIssuerListItem`
/// (`{rfc, name}`) for its rows, same as the spec-014 facility-form
/// autocomplete — the catalog's richer columns (postal code, regime) are
/// read via the detail entity on the detail screen only.
@riverpod
class TaxpayerIssuersListController extends _$TaxpayerIssuersListController {
  @override
  Future<CatalogPage<TaxpayerIssuerListItem>> build() {
    final search = ref.watch(taxpayerIssuerSearchControllerProvider);
    return _fetch(search, pageIndex: 0);
  }

  Future<CatalogPage<TaxpayerIssuerListItem>> _fetch(
    String search, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(taxpayerIssuerRepositoryProvider)
        .list(
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
    final search = ref.read(taxpayerIssuerSearchControllerProvider);
    state = const AsyncLoading<CatalogPage<TaxpayerIssuerListItem>>()
        .copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(search, pageIndex: pageIndex));
  }
}
