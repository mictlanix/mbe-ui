import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';

part 'stock_list_controller.freezed.dart';
part 'stock_list_controller.g.dart';

const _pageSize = 50;

/// The Existencias list's addressable view state (spec 071 research R7):
/// the warehouse, the search text, the zero-stock switch and the page, all
/// in the URL as the `warehouse`, `q`, `include_zero` and `page` parameters.
@freezed
abstract class StockQuery with _$StockQuery {
  const StockQuery._();

  const factory StockQuery({
    int? warehouseId,
    @Default('') String q,
    @Default(false) bool includeZero,
    @Default(0) int pageIndex,
  }) = _StockQuery;

  /// A non-numeric `warehouse` is ignored; `include_zero` is on only when it
  /// reads `true`.
  factory StockQuery.fromQuery(ListQuery query) {
    final warehouse = query.facet('warehouse');
    return StockQuery(
      warehouseId: warehouse == null ? null : int.tryParse(warehouse),
      q: query.facet('q') ?? '',
      includeZero: query.facet('include_zero') == 'true',
      pageIndex: query.pageIndex,
    );
  }

  /// This query as a URL query, facets in their canonical order. Defaults
  /// are omitted.
  ListQuery toQuery() => ListQuery(pageIndex: pageIndex)
      .withFacet('warehouse', warehouseId?.toString())
      .withFacet('q', q)
      .withFacet('include_zero', includeZero ? 'true' : null);

  /// A new search, back on page 1.
  StockQuery withSearch(String value) => copyWith(q: value, pageIndex: 0);

  /// The switch flipped, back on page 1.
  StockQuery withIncludeZero(bool value) =>
      copyWith(includeZero: value, pageIndex: 0);

  /// Another warehouse, back on page 1.
  StockQuery withWarehouse(int id) => copyWith(warehouseId: id, pageIndex: 0);

  /// What the filters badge counts: the sheet's facets in use (Almacén and
  /// the switch). The search sits in the bar, not the sheet.
  int get activeFilterCount =>
      (warehouseId != null ? 1 : 0) + (includeZero ? 1 : 0);
}

/// Fetches and holds one Existencias page (spec 071 FR-002–FR-005): server
/// paged, 50 per page, in the server's order (by code). With no warehouse it
/// makes no request and holds an empty page: the screen shows the prompt.
@riverpod
class StockListController extends _$StockListController {
  @override
  Future<CatalogPage<StockRow>> build(StockQuery query) async {
    final warehouseId = query.warehouseId;
    if (warehouseId == null) {
      return const CatalogPage(
        items: [],
        total: 0,
        pageIndex: 0,
        pageSize: _pageSize,
      );
    }
    return fetchClampedPage(
      pageIndex: query.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(query, warehouseId, pageIndex),
    );
  }

  Future<CatalogPage<StockRow>> _fetch(
    StockQuery query,
    int warehouseId,
    int pageIndex,
  ) async {
    final result = await ref
        .read(stockRepositoryProvider)
        .list(
          warehouseId: warehouseId,
          q: query.q,
          includeZero: query.includeZero,
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
}

/// The warehouse Existencias starts on (FR-002, research R7): the user's
/// point-of-sale warehouse, from the same session setting
/// `inventoryStartingWarehouse` reads, but with no facility rule, since
/// stock has no facility scope. `null` when the user has no point of sale or
/// the lookup fails.
@riverpod
Future<int?> stockStartingWarehouse(Ref ref) async {
  final state = ref.watch(authProvider).value;
  final pointSaleId = state is AuthAuthenticated
      ? state.user.settings?.pointSaleId
      : null;
  if (pointSaleId == null) return null;
  try {
    final pointSale = await ref
        .watch(pointSaleRepositoryProvider)
        .get(pointSaleId: pointSaleId);
    return pointSale.warehouseId;
  } catch (_) {
    return null;
  }
}
