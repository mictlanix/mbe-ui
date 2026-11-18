import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';

part 'fiscal_documents_filter.freezed.dart';

/// The "Facturas" list's addressable view state (spec 066 data-model §6).
/// Every field lives in the URL, so Back from a document returns to the same
/// page and filters. URL keys: `search`, `status`, `type`, `issuer`, `from`, `to`,
/// `page`.
@freezed
abstract class FiscalDocumentsFilter with _$FiscalDocumentsFilter {
  const FiscalDocumentsFilter._();

  const factory FiscalDocumentsFilter({
    /// Folio, UUID, or recipient RFC or name; `null` when empty.
    String? search,
    FiscalDocumentStatus? status,

    /// The document type code. A code the app doesn't know still applies.
    int? kind,
    String? issuerRfc,

    /// Both ends or neither: a half-open or reversed range is dropped.
    DateTime? from,
    DateTime? to,
    @Default(0) int pageIndex,
  }) = _FiscalDocumentsFilter;

  factory FiscalDocumentsFilter.fromQuery(ListQuery query) {
    var from = parsePaymentsDateFacet(query.facet('from'));
    var to = parsePaymentsDateFacet(query.facet('to'));
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final search = query.search.trim();
    final statusWire = query.facet('status');
    final issuer = query.facet('issuer')?.trim();
    return FiscalDocumentsFilter(
      search: search.isEmpty ? null : search,
      status: FiscalDocumentStatus.fromWire(statusWire),
      kind: int.tryParse(query.facet('type') ?? ''),
      issuerRfc: issuer == null || issuer.isEmpty ? null : issuer,
      from: from,
      to: to,
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query, facets in their canonical order.
  ListQuery toQuery() => ListQuery(search: search ?? '', pageIndex: pageIndex)
      .withFacet('status', status?.wireName)
      .withFacet('type', kind?.toString())
      .withFacet('issuer', issuerRfc)
      .withFacet('from', from == null ? null : encodePaymentsDateFacet(from!))
      .withFacet('to', to == null ? null : encodePaymentsDateFacet(to!));

  /// What the drawer badge counts: one per facet in use, the date range as
  /// one. Not the search box, nor the page.
  int get activeFilterCount =>
      (status != null ? 1 : 0) +
      (kind != null ? 1 : 0) +
      (issuerRfc != null ? 1 : 0) +
      (from != null ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0 || search != null;

  /// "Limpiar": every facet emptied, the search box kept, back to page 1.
  FiscalDocumentsFilter cleared() => FiscalDocumentsFilter(search: search);
}
