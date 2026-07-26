/// The shared page-state shape every catalog's list controller produces
/// (constitution §VI — pagination MUST be implemented once in
/// `core/widgets/`, not per screen; data-model.md "CatalogPage`<T>`").
///
/// This is a data shape, not a render widget: [DataTableView] consumes it
/// via its `pagination` parameter and renders the actual page-navigation
/// UI through `data_table_2`'s `PaginatedDataTable2` footer
/// (research.md §1/§2).
class CatalogPage<T> {
  const CatalogPage({
    required this.items,
    required this.total,
    required this.pageIndex,
    required this.pageSize,
  });

  /// The current page's rows.
  final List<T> items;

  /// Total rows matching the active filter, from the API's
  /// `ListResponse.total`.
  final int total;

  /// 0-based; drives `skip = pageIndex * pageSize`.
  final int pageIndex;

  /// Fixed at 20 across catalogs (matches the existing Products page size).
  final int pageSize;
}

/// Fetches [pageIndex] via [fetch]; if that page comes back empty despite a
/// non-zero known total, refetches the nearest valid (last) page instead of
/// surfacing an empty view (017-ui-consistency-filters FR-026) — the address
/// named a page beyond the result set (e.g. a bookmark taken before items on
/// later pages were deleted, or `?page=999` typed by hand). A page that is
/// merely empty because [total] itself is 0 (no matches at all) is left
/// alone — that is `ListPresentationState.empty`/`filteredEmpty`, not a
/// clamping case.
Future<CatalogPage<T>> fetchClampedPage<T>({
  required int pageIndex,
  required int pageSize,
  required Future<CatalogPage<T>> Function(int pageIndex) fetch,
}) async {
  final page = await fetch(pageIndex);
  if (page.items.isNotEmpty || page.total == 0 || pageIndex == 0) {
    return page;
  }
  final lastPageIndex = (page.total - 1) ~/ pageSize;
  if (lastPageIndex == pageIndex) return page;
  return fetch(lastPageIndex);
}
