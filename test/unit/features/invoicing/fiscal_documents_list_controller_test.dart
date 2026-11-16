import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_filter.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_controller.dart';

class MockFiscalDocumentRepository extends Mock
    implements FiscalDocumentRepository {}

FiscalDocumentSummary _doc(int id) => FiscalDocumentSummary(
  id: id,
  typeCode: 0,
  version: '4.0',
  issuerRfc: 'XAXX010101000',
  status: FiscalDocumentStatus.issued,
);

void main() {
  late MockFiscalDocumentRepository repository;

  setUp(() => repository = MockFiscalDocumentRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        fiscalDocumentRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<FiscalDocumentPage>> whenList() => when(
    () => repository.list(
      search: any(named: 'search'),
      issuer: any(named: 'issuer'),
      type: any(named: 'type'),
      status: any(named: 'status'),
      dateFrom: any(named: 'dateFrom'),
      dateTo: any(named: 'dateTo'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  void serve(List<FiscalDocumentSummary> docs) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, docs.length);
      return FiscalDocumentPage(
        items: skip >= docs.length ? const [] : docs.sublist(skip, end),
        total: docs.length,
      );
    });
  }

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) _doc(i)]);
    final filter = FiscalDocumentsFilter(
      search: 'GR4776',
      status: FiscalDocumentStatus.issued,
      kind: 100,
      issuerRfc: 'XAXX010101000',
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 30),
      pageIndex: 1,
    );

    final page = await container().read(
      fiscalDocumentsListControllerProvider(filter).future,
    );

    expect(page.items, hasLength(20));
    expect(page.total, 50);
    expect(page.pageIndex, 1);
    verify(
      () => repository.list(
        search: 'GR4776',
        issuer: 'XAXX010101000',
        type: 100,
        status: FiscalDocumentStatus.issued,
        dateFrom: DateTime(2026, 11, 1),
        dateTo: DateTime(2026, 11, 30),
        skip: 20,
        limit: 20,
      ),
    ).called(1);
  });

  test('a page emptied by its last row going is clamped to the last page '
      'that has rows', () async {
    serve([for (var i = 20; i >= 1; i--) _doc(i)]);

    final page = await container().read(
      fiscalDocumentsListControllerProvider(
        const FiscalDocumentsFilter(pageIndex: 1),
      ).future,
    );

    expect(page.pageIndex, 0);
    expect(page.items, hasLength(20));
  });

  test('a repository error surfaces as the provider error', () async {
    whenList().thenThrow(const AppError.server(statusCode: 500));

    await expectLater(
      container().read(
        fiscalDocumentsListControllerProvider(
          const FiscalDocumentsFilter(),
        ).future,
      ),
      throwsA(isA<ServerError>()),
    );
  });
}
