import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_controller.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_filter.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_controller.dart';

import 'fiscal_document_fixtures.dart';

class MockFiscalDocumentRepository extends Mock
    implements FiscalDocumentRepository {}

void main() {
  late MockFiscalDocumentRepository repository;
  late int detailLoads;
  late int listLoads;

  setUpAll(() {
    registerFallbackValue(const InvoiceHeaderPatch());
    registerFallbackValue(const InvoiceLinePatch());
    registerFallbackValue(InvoiceRelationType.substitution);
    registerFallbackValue(const NewInvoice(customerId: 1, recipientRfc: 'X'));
  });

  setUp(() {
    repository = MockFiscalDocumentRepository();
    detailLoads = 0;
    listLoads = 0;
    when(() => repository.getById(any())).thenAnswer((_) async {
      detailLoads++;
      return aDocument();
    });
    when(
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
    ).thenAnswer((_) async {
      listLoads++;
      return const FiscalDocumentPage(items: [], total: 0);
    });
  });

  /// A container with the detail and a list page already loaded and watched,
  /// so an invalidation shows as a second load.
  Future<ProviderContainer> container() async {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        fiscalDocumentRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    c.listen(fiscalDocumentDetailProvider(7), (_, _) {});
    c.listen(
      fiscalDocumentsListControllerProvider(const FiscalDocumentsFilter()),
      (_, _) {},
    );
    await c.read(fiscalDocumentDetailProvider(7).future);
    await c.read(
      fiscalDocumentsListControllerProvider(
        const FiscalDocumentsFilter(),
      ).future,
    );
    return c;
  }

  FiscalDocumentActions actions(ProviderContainer c) =>
      c.read(fiscalDocumentActionsProvider.notifier);

  Future<void> settle(ProviderContainer c) async {
    await c.read(fiscalDocumentDetailProvider(7).future);
    await c.read(
      fiscalDocumentsListControllerProvider(
        const FiscalDocumentsFilter(),
      ).future,
    );
  }

  test('each action calls its repository method', () async {
    final c = await container();
    for (final m in <Future<Object?> Function()>[
      () => repository.updateHeader(7, any()),
      () => repository.addSalesOrder(7, 55),
      () => repository.addProduct(7, 3),
      () => repository.updateLine(7, 10, any()),
      () => repository.removeLine(7, 10),
      () => repository.addRelation(7, 99, InvoiceRelationType.substitution),
      () => repository.removeRelation(7, 3),
      () => repository.confirm(7),
      () => repository.reopen(7),
    ]) {
      when(m).thenAnswer((_) async => aDocument());
    }
    final a = actions(c);

    expect(await a.updateHeader(7, const InvoiceHeaderPatch()), isNull);
    expect(await a.addSalesOrder(7, 55), isNull);
    expect(await a.addProduct(7, 3), isNull);
    expect(await a.updateLine(7, 10, const InvoiceLinePatch()), isNull);
    expect(await a.removeLine(7, 10), isNull);
    expect(
      await a.addRelation(7, 99, InvoiceRelationType.substitution),
      isNull,
    );
    expect(await a.removeRelation(7, 3), isNull);
    expect(await a.confirm(7), isNull);
    expect(await a.reopen(7), isNull);

    verify(() => repository.addSalesOrder(7, 55)).called(1);
    verify(() => repository.confirm(7)).called(1);
    verify(() => repository.reopen(7)).called(1);
    verify(() => repository.removeRelation(7, 3)).called(1);
  });

  test('a success reloads the detail and the list', () async {
    final c = await container();
    when(() => repository.confirm(7)).thenAnswer((_) async => aDocument());

    await actions(c).confirm(7);
    await settle(c);

    expect(detailLoads, 2);
    expect(listLoads, 2);
  });

  test(
    'a refusal passes its code through and reloads only the detail',
    () async {
      final c = await container();
      when(() => repository.confirm(7)).thenThrow(const AppError.server());

      final error = await actions(c).confirm(7);
      await settle(c);

      expect(error, isA<ServerError>());
      expect(detailLoads, 2);
      expect(listLoads, 1);
    },
  );

  test('an unknown result (lost connection) reloads both and is a '
      'NetworkError', () async {
    final c = await container();
    when(() => repository.confirm(7)).thenThrow(const AppError.network());

    final error = await actions(c).confirm(7);
    await settle(c);

    expect(error, isA<NetworkError>());
    expect(detailLoads, 2);
    expect(listLoads, 2);
  });

  test('create answers the new id and reloads the list', () async {
    final c = await container();
    when(
      () => repository.create(any()),
    ).thenAnswer((_) async => aDocument(id: 21));

    final result = await actions(
      c,
    ).create(const NewInvoice(customerId: 4, recipientRfc: 'XEXX010101000'));
    await settle(c);

    expect(result.id, 21);
    expect(result.error, isNull);
    expect(listLoads, 2);
  });

  test('a refused create answers the error and no id', () async {
    final c = await container();
    when(() => repository.create(any())).thenThrow(const AppError.server());

    final result = await actions(
      c,
    ).create(const NewInvoice(customerId: 4, recipientRfc: 'X'));

    expect(result.id, isNull);
    expect(result.error, isA<ServerError>());
    expect(listLoads, 1);
  });
}
