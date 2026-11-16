import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_controller.dart';

import 'fiscal_document_fixtures.dart';

class MockFiscalDocumentRepository extends Mock
    implements FiscalDocumentRepository {}

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

  test('loads the document by id', () async {
    when(() => repository.getById(7)).thenAnswer((_) async => aDocument(id: 7));

    final doc = await container().read(fiscalDocumentDetailProvider(7).future);

    expect(doc.id, 7);
    expect(doc.status, FiscalDocumentStatus.draft);
  });

  test('a not-found error surfaces as such', () async {
    when(() => repository.getById(9)).thenThrow(const AppError.notFound());

    await expectLater(
      container().read(fiscalDocumentDetailProvider(9).future),
      throwsA(isA<NotFoundError>()),
    );
  });
}
