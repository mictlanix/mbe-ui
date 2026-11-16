import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_batch_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batch_dialog_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batches_controller.dart';

class MockTaxpayerBatchRepository extends Mock
    implements TaxpayerBatchRepository {}

const _rfc = 'XAXX010101000';

const _savedDraft = TaxpayerBatchDraft(
  series: 'A',
  kind: FiscalDocumentKind.invoice,
  template: TaxpayerBatchTemplate(name: 'Factura'),
);

TaxpayerBatch _existing({
  bool inUse = false,
  String series = 'A',
  int typeCode = 0,
  List<TaxpayerBatchAccount> accounts = const [],
}) => TaxpayerBatch(
  taxpayerBatchId: 7,
  taxpayer: _rfc,
  series: series,
  typeCode: typeCode,
  kind: FiscalDocumentKind.fromCode(typeCode),
  template: TaxpayerBatchTemplate(
    name: 'Factura',
    logo: 'logo.png',
    headerHeight: 2,
    footerHeight: 12,
    accounts: accounts,
  ),
  inUse: inUse,
);

AppError _refusal(
  api.ErrorCode code,
  String codeName,
  Map<String, Object?> params, {
  int status = 409,
}) {
  final problem = ApiProblem(codeName: codeName, code: code, params: params);
  return status == 404
      ? AppError.notFound('not found', problem)
      : AppError.server(
          statusCode: status,
          message: 'refused',
          problem: problem,
        );
}

void main() {
  late MockTaxpayerBatchRepository repository;
  late ProviderContainer container;
  var listLoads = 0;

  setUpAll(() => registerFallbackValue(_savedDraft));

  setUp(() {
    repository = MockTaxpayerBatchRepository();
    listLoads = 0;
    when(() => repository.listForIssuer(any())).thenAnswer((_) async {
      listLoads++;
      return const <TaxpayerBatch>[];
    });
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        taxpayerBatchRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  /// The controller for [existing] in [mode], kept alive for the test.
  ({
    TaxpayerBatchDialogController notifier,
    TaxpayerBatchDialogState Function() state,
  })
  open({TaxpayerBatch? existing, RecordFormMode? mode}) {
    final startMode =
        mode ??
        (existing == null ? RecordFormMode.create : RecordFormMode.edit);
    final provider = taxpayerBatchDialogControllerProvider(
      _rfc,
      existing,
      startMode,
    );
    container.listen(provider, (_, _) {});
    // The list provider the dialog refreshes, kept alive to count reloads.
    container.listen(taxpayerBatchesControllerProvider(_rfc), (_, _) {});
    return (
      notifier: container.read(provider.notifier),
      state: () => container.read(provider),
    );
  }

  group('create', () {
    test('starts blank with the API defaults for the heights', () {
      final c = open();

      expect(c.state().mode, RecordFormMode.create);
      expect(c.state().series, '');
      expect(c.state().kind, isNull);
      expect(c.state().headerHeight, '0');
      expect(c.state().footerHeight, '15');
      expect(c.state().locked, isFalse);
    });

    test(
      'says what is missing, and sends nothing, on the first save',
      () async {
        final c = open();

        await c.notifier.submit();

        expect(c.state().submitted, isTrue);
        expect(c.state().clientErrors, {
          'batch': TaxpayerBatchFieldError.required,
          'type': TaxpayerBatchFieldError.required,
          'name': TaxpayerBatchFieldError.required,
        });
        verifyNever(() => repository.create(any(), any()));
        expect(c.state().done, isFalse);
      },
    );

    test('a series of only spaces is blank', () {
      final c = open();
      c.notifier.seriesChanged('   ');

      expect(c.state().clientErrors['batch'], TaxpayerBatchFieldError.required);
    });

    test('an eleven-character series, or a 51-character name, is too long', () {
      final c = open();
      c.notifier
        ..seriesChanged('ABCDEFGHIJK')
        ..templateNameChanged('N' * 51);

      expect(c.state().clientErrors['batch'], TaxpayerBatchFieldError.tooLong);
      expect(c.state().clientErrors['name'], TaxpayerBatchFieldError.tooLong);

      c.notifier
        ..seriesChanged('ABCDEFGHIJ')
        ..templateNameChanged('N' * 50);
      expect(c.state().clientErrors.containsKey('batch'), isFalse);
      expect(c.state().clientErrors.containsKey('name'), isFalse);
    });

    test('a height that is not a whole number of 0 or more is invalid', () {
      final c = open();
      for (final bad in ['', '-1', '1.5', 'abc']) {
        c.notifier
          ..headerHeightChanged(bad)
          ..footerHeightChanged(bad);
        expect(
          c.state().clientErrors['header_height'],
          TaxpayerBatchFieldError.invalid,
          reason: "'$bad'",
        );
        expect(
          c.state().clientErrors['footer_height'],
          TaxpayerBatchFieldError.invalid,
          reason: "'$bad'",
        );
      }
      c.notifier
        ..headerHeightChanged('0')
        ..footerHeightChanged('40');
      expect(c.state().clientErrors.containsKey('header_height'), isFalse);
      expect(c.state().clientErrors.containsKey('footer_height'), isFalse);
    });

    test('saves a trimmed series, drops a blank account, keeps the rest in '
        'order, refreshes the list and finishes', () async {
      when(
        () => repository.create(any(), any()),
      ).thenAnswer((_) async => _existing());
      final c = open();
      c.notifier
        ..seriesChanged('  FAC  ')
        ..kindChanged(FiscalDocumentKind.creditNote)
        ..templateNameChanged(' Nota ')
        ..logoChanged('   ')
        ..headerHeightChanged('4')
        ..footerHeightChanged('18')
        ..accountAdded()
        ..accountAdded()
        ..accountAdded()
        ..accountChanged(0, const TaxpayerBatchAccount(bank: ' First '))
        ..accountChanged(2, const TaxpayerBatchAccount(clabe: ' 012 '));
      final before = listLoads;

      await c.notifier.submit();

      final draft =
          verify(() => repository.create(_rfc, captureAny())).captured.single
              as TaxpayerBatchDraft;
      expect(draft.series, 'FAC');
      expect(draft.kind, FiscalDocumentKind.creditNote);
      expect(draft.template.name, 'Nota');
      expect(draft.template.logo, isNull);
      expect(draft.template.headerHeight, 4);
      expect(draft.template.footerHeight, 18);
      expect(draft.template.accounts, [
        const TaxpayerBatchAccount(bank: 'First'),
        const TaxpayerBatchAccount(clabe: '012'),
      ]);
      expect(c.state().done, isTrue);
      expect(c.state().submitting, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(listLoads, greaterThan(before));
    });

    test('adds, removes and moves accounts, and does nothing past either '
        'end', () {
      final c = open();
      c.notifier
        ..accountAdded()
        ..accountAdded()
        ..accountAdded()
        ..accountChanged(0, const TaxpayerBatchAccount(bank: 'one'))
        ..accountChanged(1, const TaxpayerBatchAccount(bank: 'two'))
        ..accountChanged(2, const TaxpayerBatchAccount(bank: 'three'));
      List<String> banks() => [for (final a in c.state().accounts) a.bank];

      c.notifier.accountMoved(0, -1);
      expect(banks(), ['one', 'two', 'three']);
      c.notifier.accountMoved(2, 1);
      expect(banks(), ['one', 'two', 'three']);

      c.notifier.accountMoved(0, 1);
      expect(banks(), ['two', 'one', 'three']);
      c.notifier.accountMoved(2, -1);
      expect(banks(), ['two', 'three', 'one']);

      c.notifier.accountRemoved(1);
      expect(banks(), ['two', 'one']);
      expect(c.state().accountIds.length, 2);
      expect(c.state().accountIds.toSet().length, 2);

      c.notifier.accountRemoved(9);
      expect(banks(), ['two', 'one']);
    });

    test(
      'a duplicate series lands on the series field and keeps the input',
      () async {
        when(() => repository.create(any(), any())).thenAnswer(
          (_) async => throw _refusal(
            api.ErrorCode.resourcePeriodAlreadyExists,
            'resource.already_exists',
            {'resource': 'taxpayer_batch', 'field': 'batch'},
          ),
        );
        final c = open();
        c.notifier
          ..seriesChanged('A')
          ..kindChanged(FiscalDocumentKind.invoice)
          ..templateNameChanged('Factura');

        await c.notifier.submit();

        expect(c.state().serverErrors, {'batch': taxpayerBatchDuplicateSeries});
        expect(c.state().series, 'A');
        expect(c.state().templateName, 'Factura');
        expect(c.state().done, isFalse);
        expect(c.state().submitting, isFalse);
        expect(c.state().error, TaxpayerBatchDialogErrorCode.saveFailed);

        // Editing the series drops the refusal that no longer applies.
        c.notifier.seriesChanged('B');
        expect(c.state().serverErrors, isEmpty);
        expect(c.state().error, isNull);
      },
    );

    test('an issuer that no longer exists closes the dialog', () async {
      when(() => repository.create(any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.resourcePeriodNotFound,
          'resource.not_found',
          {'resource': 'taxpayer_issuer', 'id': _rfc},
          status: 404,
        ),
      );
      final c = open();
      c.notifier
        ..seriesChanged('A')
        ..kindChanged(FiscalDocumentKind.invoice)
        ..templateNameChanged('Factura');

      await c.notifier.submit();

      expect(c.state().issuerGone, isTrue);
      expect(c.state().done, isFalse);
    });

    test('any other refusal keeps the error for the banner', () async {
      when(
        () => repository.create(any(), any()),
      ).thenAnswer((_) async => throw const AppError.network());
      final c = open();
      c.notifier
        ..seriesChanged('A')
        ..kindChanged(FiscalDocumentKind.invoice)
        ..templateNameChanged('Factura');

      await c.notifier.submit();

      expect(c.state().error, TaxpayerBatchDialogErrorCode.saveFailed);
      expect(c.state().errorCause, isA<NetworkError>());
      expect(c.state().series, 'A');
    });

    test('a second save while one is in flight is ignored', () async {
      final gate = Completer<TaxpayerBatch>();
      when(
        () => repository.create(any(), any()),
      ).thenAnswer((_) => gate.future);
      final c = open();
      c.notifier
        ..seriesChanged('A')
        ..kindChanged(FiscalDocumentKind.invoice)
        ..templateNameChanged('Factura');

      final first = c.notifier.submit();
      await c.notifier.submit();
      gate.complete(_existing());
      await first;

      verify(() => repository.create(any(), any())).called(1);
    });
  });

  group('edit', () {
    test(
      'seeds the draft from the series, and an unused one is not locked',
      () {
        final c = open(
          existing: _existing(
            accounts: const [TaxpayerBatchAccount(bank: 'BBVA')],
          ),
        );

        expect(c.state().mode, RecordFormMode.edit);
        expect(c.state().series, 'A');
        expect(c.state().kind, FiscalDocumentKind.invoice);
        expect(c.state().templateName, 'Factura');
        expect(c.state().logo, 'logo.png');
        expect(c.state().headerHeight, '2');
        expect(c.state().footerHeight, '12');
        expect(c.state().accounts.single.bank, 'BBVA');
        expect(c.state().locked, isFalse);
      },
    );

    test('a read-only series switches to edit in place, and only once', () {
      final c = open(existing: _existing(), mode: RecordFormMode.view);

      expect(c.state().mode, RecordFormMode.view);
      c.notifier.switchToEdit();
      expect(c.state().mode, RecordFormMode.edit);
    });

    test('a read-only series never saves', () async {
      final c = open(existing: _existing(), mode: RecordFormMode.view);

      await c.notifier.submit();

      verifyNever(() => repository.update(any(), any(), any()));
    });

    test('an unused series sends everything it was changed to', () async {
      when(
        () => repository.update(any(), any(), any()),
      ).thenAnswer((_) async => _existing(series: 'B', typeCode: 100));
      final c = open(existing: _existing());
      c.notifier
        ..seriesChanged('B')
        ..kindChanged(FiscalDocumentKind.creditNote)
        ..templateNameChanged('Nota');

      await c.notifier.submit();

      final captured =
          verify(() => repository.update(_rfc, 7, captureAny())).captured.single
              as TaxpayerBatchDraft;
      expect(captured.series, 'B');
      expect(captured.kind, FiscalDocumentKind.creditNote);
      expect(captured.template.name, 'Nota');
      expect(c.state().done, isTrue);
    });

    test('a locked series sends its own series and kind with the changed '
        'template, and is not validated on them', () async {
      when(
        () => repository.update(any(), any(), any()),
      ).thenAnswer((_) async => _existing(inUse: true));
      final c = open(existing: _existing(inUse: true));
      expect(c.state().locked, isTrue);
      // Even if something blanked the series, a locked save sends the stored
      // one.
      c.notifier
        ..seriesChanged('')
        ..headerHeightChanged('9');
      expect(c.state().clientErrors.containsKey('batch'), isFalse);

      await c.notifier.submit();

      final captured =
          verify(() => repository.update(_rfc, 7, captureAny())).captured.single
              as TaxpayerBatchDraft;
      expect(captured.series, 'A');
      expect(captured.kind, FiscalDocumentKind.invoice);
      expect(captured.template.headerHeight, 9);
    });

    test('a series that became in use locks, resets series and kind, keeps '
        'the template edits and refreshes the list', () async {
      when(() => repository.update(any(), any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.taxpayerBatchPeriodInUse,
          'taxpayer_batch.in_use',
          {'action': 'update'},
        ),
      );
      final c = open(existing: _existing());
      c.notifier
        ..seriesChanged('Z')
        ..kindChanged(FiscalDocumentKind.creditNote)
        ..templateNameChanged('Edited name')
        ..headerHeightChanged('8');
      final before = listLoads;

      await c.notifier.submit();

      expect(c.state().locked, isTrue);
      expect(c.state().series, 'A');
      expect(c.state().kind, FiscalDocumentKind.invoice);
      expect(c.state().templateName, 'Edited name');
      expect(c.state().headerHeight, '8');
      expect(c.state().error, TaxpayerBatchDialogErrorCode.saveFailed);
      expect(c.state().done, isFalse);
      expect(c.state().submitting, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(listLoads, greaterThan(before));

      // The template edits can now be saved.
      when(
        () => repository.update(any(), any(), any()),
      ).thenAnswer((_) async => _existing(inUse: true));
      await c.notifier.submit();
      final sent =
          verify(() => repository.update(_rfc, 7, captureAny())).captured.last
              as TaxpayerBatchDraft;
      expect(sent.series, 'A');
      expect(sent.template.name, 'Edited name');
      expect(c.state().done, isTrue);
    });

    test('a series removed by someone else refreshes the list and shows the '
        'refusal', () async {
      when(() => repository.update(any(), any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.resourcePeriodNotFound,
          'resource.not_found',
          {'resource': 'taxpayer_batch', 'id': 7},
          status: 404,
        ),
      );
      final c = open(existing: _existing());
      final before = listLoads;

      await c.notifier.submit();

      expect(c.state().error, TaxpayerBatchDialogErrorCode.saveFailed);
      expect(c.state().errorCause, isA<NotFoundError>());
      expect(c.state().issuerGone, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(listLoads, greaterThan(before));
    });

    test('renaming to a series the issuer already has lands on the series '
        'field', () async {
      when(() => repository.update(any(), any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.resourcePeriodAlreadyExists,
          'resource.already_exists',
          {'resource': 'taxpayer_batch', 'field': 'batch'},
        ),
      );
      final c = open(existing: _existing());
      c.notifier.seriesChanged('B');

      await c.notifier.submit();

      expect(c.state().serverErrors, {'batch': taxpayerBatchDuplicateSeries});
    });

    test('a series with a type this app does not know needs a type picked '
        'before it can be saved', () async {
      final c = open(existing: _existing(typeCode: 7));
      expect(c.state().kind, isNull);

      await c.notifier.submit();

      expect(c.state().clientErrors['type'], TaxpayerBatchFieldError.required);
      verifyNever(() => repository.update(any(), any(), any()));

      c.notifier.kindChanged(FiscalDocumentKind.expense);
      expect(c.state().clientErrors.containsKey('type'), isFalse);
    });

    test('a field refusal from the server is kept per field', () async {
      when(() => repository.update(any(), any(), any())).thenAnswer(
        (_) async => throw AppError.validation([
          const FieldError(
            loc: ['body', 'batch'],
            msg: 'The series cannot be blank',
            type: 'taxpayer_batch_series_blank',
          ),
          const FieldError(
            loc: ['body', 'template', 'name'],
            msg: 'String should have at least 1 character',
            type: 'string_too_short',
          ),
        ]),
      );
      final c = open(existing: _existing());

      await c.notifier.submit();

      expect(c.state().serverErrors['batch'], 'taxpayer_batch_series_blank');
      expect(
        c.state().serverErrors['name'],
        'String should have at least 1 character',
      );
    });
  });

  group('delete', () {
    test('deletes the series, refreshes the list and finishes', () async {
      when(() => repository.delete(any(), any())).thenAnswer((_) async {});
      final c = open(existing: _existing());
      final before = listLoads;

      await c.notifier.delete();

      verify(() => repository.delete(_rfc, 7)).called(1);
      expect(c.state().done, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(listLoads, greaterThan(before));
    });

    test('a series that cannot be deleted because it became in use locks, '
        'refreshes the list and shows the refusal', () async {
      when(() => repository.delete(any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.taxpayerBatchPeriodInUse,
          'taxpayer_batch.in_use',
          {'action': 'delete'},
        ),
      );
      final c = open(existing: _existing());
      final before = listLoads;

      await c.notifier.delete();

      expect(c.state().locked, isTrue);
      expect(c.state().error, TaxpayerBatchDialogErrorCode.deleteFailed);
      expect(c.state().errorCause, isA<ServerError>());
      expect(c.state().done, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(listLoads, greaterThan(before));
    });

    test('a series already removed refreshes the list and shows the '
        'refusal', () async {
      when(() => repository.delete(any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.resourcePeriodNotFound,
          'resource.not_found',
          {'resource': 'taxpayer_batch', 'id': 7},
          status: 404,
        ),
      );
      final c = open(existing: _existing());

      await c.notifier.delete();

      expect(c.state().error, TaxpayerBatchDialogErrorCode.deleteFailed);
      expect(c.state().done, isFalse);
    });

    test('there is nothing to delete on an add', () async {
      final c = open();

      await c.notifier.delete();

      verifyNever(() => repository.delete(any(), any()));
    });

    test('a second delete while one is in flight is ignored', () async {
      final gate = Completer<void>();
      when(
        () => repository.delete(any(), any()),
      ).thenAnswer((_) => gate.future);
      final c = open(existing: _existing());

      final first = c.notifier.delete();
      await c.notifier.delete();
      gate.complete();
      await first;

      verify(() => repository.delete(any(), any())).called(1);
    });
  });
}
