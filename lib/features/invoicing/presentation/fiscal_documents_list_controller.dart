import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_filter.dart';

part 'fiscal_documents_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Facturas" page (spec 066 research R4): server
/// paging, newest first, filtered by the URL facets. The server doesn't scope
/// this list by facility, so there is no facility handling here.
@riverpod
class FiscalDocumentsListController extends _$FiscalDocumentsListController {
  @override
  Future<CatalogPage<FiscalDocumentSummary>> build(
    FiscalDocumentsFilter filter,
  ) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter, pageIndex),
    );
  }

  Future<CatalogPage<FiscalDocumentSummary>> _fetch(
    FiscalDocumentsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(fiscalDocumentRepositoryProvider)
        .list(
          search: filter.search,
          issuer: filter.issuerRfc,
          type: filter.kind,
          status: filter.status,
          dateFrom: filter.from,
          dateTo: filter.to,
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
