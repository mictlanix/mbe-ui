import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_filter.dart';

void main() {
  ListQuery q(String qs) => ListQuery.fromUri(Uri.parse('/x?$qs'));

  test('round-trips every facet through the URL', () {
    final filter = FiscalDocumentsFilter(
      search: 'GR4776',
      status: FiscalDocumentStatus.issued,
      kind: 100,
      issuerRfc: 'XAXX010101000',
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 16),
      pageIndex: 2,
    );
    final back = FiscalDocumentsFilter.fromQuery(
      ListQuery.fromUri(filter.toQuery().toUri('/x')),
    );
    expect(back, filter);
  });

  test('an unknown status is ignored; an unknown type code still applies', () {
    final f = FiscalDocumentsFilter.fromQuery(q('status=weird&type=7'));
    expect(f.status, isNull);
    expect(f.kind, 7);
    expect(FiscalDocumentsFilter.fromQuery(q('type=abc')).kind, isNull);
  });

  test('a one-ended or reversed date range is dropped', () {
    expect(FiscalDocumentsFilter.fromQuery(q('from=2026-11-01')).from, isNull);
    final f = FiscalDocumentsFilter.fromQuery(
      q('from=2026-11-10&to=2026-11-01'),
    );
    expect(f.from, isNull);
    expect(f.to, isNull);
  });

  test('the date range counts once; search and page do not count', () {
    final f = FiscalDocumentsFilter(
      search: 'x',
      pageIndex: 3,
      status: FiscalDocumentStatus.draft,
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 2),
    );
    expect(f.activeFilterCount, 2);
    expect(const FiscalDocumentsFilter(search: 'x').activeFilterCount, 0);
    expect(const FiscalDocumentsFilter(search: 'x').isNarrowed, isTrue);
    expect(const FiscalDocumentsFilter().isNarrowed, isFalse);
  });

  test('cleared keeps the search and returns to the first page', () {
    final f = FiscalDocumentsFilter(
      search: 'GR',
      kind: 0,
      status: FiscalDocumentStatus.sealed,
      pageIndex: 4,
    ).cleared();
    expect(f.search, 'GR');
    expect(f.activeFilterCount, 0);
    expect(f.pageIndex, 0);
  });
}
