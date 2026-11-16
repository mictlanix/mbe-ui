import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

part 'inventory_documents_filter.freezed.dart';

/// The "Entradas de almacén" list's addressable view state (spec 067
/// research R9). Every field lives in the URL, so Back from a receipt returns
/// to the same page and filters. There is no search box: the endpoint has
/// none.
@freezed
abstract class InventoryDocumentsFilter with _$InventoryDocumentsFilter {
  const InventoryDocumentsFilter._();

  const factory InventoryDocumentsFilter({
    InventoryDocumentStatus? status,
    int? warehouseId,
    @Default(0) int pageIndex,
  }) = _InventoryReceiptsFilter;

  /// An unknown `status` or a non-numeric `warehouse` is ignored.
  factory InventoryDocumentsFilter.fromQuery(ListQuery query) {
    final status = query.facet('status');
    final warehouse = query.facet('warehouse');
    return InventoryDocumentsFilter(
      status: InventoryDocumentStatus.values
          .where((s) => s.name == status)
          .firstOrNull,
      warehouseId: warehouse == null ? null : int.tryParse(warehouse),
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query, facets in their canonical order. The
  /// `status` value is the wire value (`draft`, `completed`, `cancelled`).
  ListQuery toQuery() => ListQuery(pageIndex: pageIndex)
      .withFacet('status', status?.name)
      .withFacet('warehouse', warehouseId?.toString());

  /// What the drawer badge counts: one per facet in use, not the page.
  int get activeFilterCount =>
      (status != null ? 1 : 0) + (warehouseId != null ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0;

  /// "Limpiar todo": every facet emptied, back to page 1.
  InventoryDocumentsFilter cleared() => const InventoryDocumentsFilter();
}
