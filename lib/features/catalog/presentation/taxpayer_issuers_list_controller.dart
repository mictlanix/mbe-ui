import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';

part 'taxpayer_issuers_list_controller.freezed.dart';
part 'taxpayer_issuers_list_controller.g.dart';

const _pageSize = 20;

/// The Taxpayer Issuers list screen's addressable view state
/// (017-ui-consistency-filters FR-017): search only — the issuer has no
/// backend facets (contracts/mbe-api-catalogs.md §2). Derived from the
/// route's [ListQuery] — the URL, not a mutable notifier, is the source of
/// truth.
@freezed
class TaxpayerIssuerFilter with _$TaxpayerIssuerFilter {
  const factory TaxpayerIssuerFilter({
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _TaxpayerIssuerFilter;

  factory TaxpayerIssuerFilter.fromQuery(ListQuery query) {
    return TaxpayerIssuerFilter(
      search: query.search,
      pageIndex: query.pageIndex,
    );
  }
}

/// Fetches and holds the Taxpayer Issuers list (FR-010) for the given
/// [TaxpayerIssuerFilter]. Uses the full `TaxpayerIssuer` entity (via
/// [TaxpayerIssuerRepository.listDetail]) so the list can show postal code
/// and fiscal regime alongside RFC and name (FR-010) — distinct from the
/// lightweight `TaxpayerIssuerListItem` the spec-014 facility-form
/// autocomplete uses. A family keyed by the filter value: a different URL
/// is a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class TaxpayerIssuersListController extends _$TaxpayerIssuersListController {
  @override
  Future<CatalogPage<TaxpayerIssuer>> build(TaxpayerIssuerFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<TaxpayerIssuer>> _fetch(
    TaxpayerIssuerFilter filter,
  ) async {
    final result = await ref
        .read(taxpayerIssuerRepositoryProvider)
        .listDetail(
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
