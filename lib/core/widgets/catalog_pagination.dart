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
