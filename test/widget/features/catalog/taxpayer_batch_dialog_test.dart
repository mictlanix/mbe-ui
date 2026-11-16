import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'taxpayer_batch_widget_harness.dart';

const _tall = Size(1000, 1600);

const _accounts = [
  TaxpayerBatchAccount(
    bank: 'BBVA',
    account: '0123456789',
    clabe: '012180001234567891',
    currency: 'MXN',
  ),
  TaxpayerBatchAccount(bank: 'Banorte', currency: 'USD'),
];

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
  late AppLocalizations l10n;

  setUpAll(() async {
    registerFallbackValue(
      const TaxpayerBatchDraft(
        series: 'A',
        kind: FiscalDocumentKind.invoice,
        template: TaxpayerBatchTemplate(name: 'x'),
      ),
    );
    l10n = await englishStrings();
  });

  setUp(() {
    repository = MockTaxpayerBatchRepository();
  });

  /// Pumps the section over [batches], then opens the series with [open].
  Future<void> pumpAndOpen(
    WidgetTester tester, {
    required List<TaxpayerBatch> batches,
    required dynamic user,
    Future<void> Function()? open,
    bool readOnly = false,
    Size size = _tall,
  }) async {
    when(
      () => repository.listForIssuer(batchRfc),
    ).thenAnswer((_) async => batches);
    await pumpBatchesSection(
      tester,
      repository: repository,
      signedInAs: user,
      readOnly: readOnly,
      size: size,
    );
    await open?.call();
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.enterText(finder, text);
    await tester.pump();
  }

  Future<void> pickKind(
    WidgetTester tester,
    FiscalDocumentKind kind,
    String label,
  ) async {
    final finder = find.byKey(const Key('taxpayer_batch_type_field'));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  TextField fieldOf(WidgetTester tester, String key) =>
      tester.widget<TextField>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextField),
        ),
      );

  group('view (a row tap)', () {
    testWidgets('shows the series read-only, with its accounts in order', (
      tester,
    ) async {
      await pumpAndOpen(
        tester,
        batches: [
          aBatch(
            series: 'FAC',
            logo: 'logo.png',
            headerHeight: 3,
            footerHeight: 20,
            accounts: _accounts,
          ),
        ],
        user: fullUser,
        open: () async => tester.tap(find.text('FAC')),
      );

      expect(find.text(l10n.taxpayerBatchDialogViewTitle), findsOneWidget);
      expect(fieldOf(tester, 'taxpayer_batch_series_field').readOnly, isTrue);
      expect(find.widgetWithText(TextFormField, 'FAC'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'logo.png'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '20'), findsOneWidget);
      expect(
        find.byKey(const Key('taxpayer_batch_account_summary_0')),
        findsOneWidget,
      );
      final first = tester.getTopLeft(
        find.byKey(const Key('taxpayer_batch_account_summary_0')),
      );
      final second = tester.getTopLeft(
        find.byKey(const Key('taxpayer_batch_account_summary_1')),
      );
      expect(second.dy, greaterThan(first.dy));
      expect(
        find.text('BBVA · 0123456789 · CLABE 012180001234567891 · MXN'),
        findsOneWidget,
      );
      // Read-only: no Save, no account editor.
      expect(find.byKey(const Key('taxpayer_batch_save_button')), findsNothing);
      expect(
        find.byKey(const Key('add_taxpayer_batch_account_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('taxpayer_batch_delete_button')),
        findsNothing,
      );
    });

    testWidgets('a series with no accounts says so', (tester) async {
      await pumpAndOpen(
        tester,
        batches: [aBatch(series: 'FAC')],
        user: fullUser,
        open: () async => tester.tap(find.text('FAC')),
      );

      expect(
        find.byKey(const Key('taxpayer_batch_no_accounts')),
        findsOneWidget,
      );
      expect(find.text(l10n.taxpayerBatchNoAccounts), findsOneWidget);
    });

    testWidgets('an updater can switch to editing in place', (tester) async {
      await pumpAndOpen(
        tester,
        batches: [aBatch(series: 'FAC')],
        user: fullUser,
        open: () async => tester.tap(find.text('FAC')),
      );

      expect(
        find.byKey(const Key('taxpayer_batch_edit_button')),
        findsOneWidget,
      );
      await tapKey(tester, 'taxpayer_batch_edit_button');

      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchDialogViewTitle), findsNothing);
      expect(
        find.byKey(const Key('taxpayer_batch_save_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('taxpayer_batch_edit_button')), findsNothing);
      expect(fieldOf(tester, 'taxpayer_batch_series_field').readOnly, isFalse);
    });

    testWidgets('a reader only closes', (tester) async {
      await pumpAndOpen(
        tester,
        batches: [aBatch(series: 'FAC')],
        user: readUser,
        open: () async => tester.tap(find.text('FAC')),
      );

      expect(find.byKey(const Key('taxpayer_batch_edit_button')), findsNothing);
      expect(
        find.byKey(const Key('taxpayer_batch_close_button')),
        findsOneWidget,
      );

      await tapKey(tester, 'taxpayer_batch_close_button');

      expect(find.text(l10n.taxpayerBatchDialogViewTitle), findsNothing);
    });

    testWidgets('a read-only render of the issuer offers no Editar even to an '
        'updater', (tester) async {
      await pumpAndOpen(
        tester,
        batches: [aBatch(series: 'FAC')],
        user: fullUser,
        readOnly: true,
        open: () async => tester.tap(find.text('FAC')),
      );

      expect(find.byKey(const Key('taxpayer_batch_edit_button')), findsNothing);
      expect(
        find.byKey(const Key('taxpayer_batch_close_button')),
        findsOneWidget,
      );
    });

    testWidgets('an in-use series shows its lock and has no delete', (
      tester,
    ) async {
      await pumpAndOpen(
        tester,
        batches: [aBatch(series: 'FAC', inUse: true)],
        user: fullUser,
        open: () async => tester.tap(find.text('FAC')),
      );

      expect(
        find.byKey(const Key('taxpayer_batch_in_use_note')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('taxpayer_batch_delete_button')),
        findsNothing,
      );
    });
  });

  group('create (Nuevo)', () {
    Future<void> openCreate(
      WidgetTester tester, {
      List<TaxpayerBatch>? batches,
    }) => pumpAndOpen(
      tester,
      batches: batches ?? [aBatch()],
      user: fullUser,
      open: () async =>
          tester.tap(find.byKey(const Key('add_taxpayer_batch_button'))),
    );

    Future<void> fillBasics(
      WidgetTester tester, {
      String series = 'FAC',
    }) async {
      await enter(tester, 'taxpayer_batch_series_field', series);
      await pickKind(
        tester,
        FiscalDocumentKind.invoice,
        l10n.fiscalDocumentKindInvoice,
      );
      await enter(tester, 'taxpayer_batch_template_name_field', 'Factura');
    }

    testWidgets('opens blank with the default heights and no delete', (
      tester,
    ) async {
      await openCreate(tester);

      expect(find.text(l10n.taxpayerBatchDialogCreateTitle), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '0'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '15'), findsOneWidget);
      expect(
        find.byKey(const Key('taxpayer_batch_delete_button')),
        findsNothing,
      );
      expect(find.byKey(const Key('taxpayer_batch_in_use_note')), findsNothing);
    });

    testWidgets('saving a blank form flags the fields and sends nothing', (
      tester,
    ) async {
      await openCreate(tester);

      await tapKey(tester, 'taxpayer_batch_save_button');

      expect(find.text(l10n.taxpayerBatchSeriesRequiredError), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchTypeRequiredError), findsOneWidget);
      expect(
        find.text(l10n.taxpayerBatchTemplateNameRequiredError),
        findsOneWidget,
      );
      verifyNever(() => repository.create(any(), any()));
      expect(find.text(l10n.taxpayerBatchDialogCreateTitle), findsOneWidget);
    });

    testWidgets('a too-long series and a bad height are flagged', (
      tester,
    ) async {
      await openCreate(tester);
      await fillBasics(tester, series: 'ABCDEFGHIJK');
      await enter(tester, 'taxpayer_batch_footer_height_field', '');

      await tapKey(tester, 'taxpayer_batch_save_button');

      expect(find.text(l10n.taxpayerBatchSeriesTooLongError), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchHeightInvalidError), findsOneWidget);
      verifyNever(() => repository.create(any(), any()));
    });

    testWidgets('saves a series with accounts: two added, one removed', (
      tester,
    ) async {
      when(
        () => repository.create(any(), any()),
      ).thenAnswer((_) async => aBatch(series: 'FAC'));
      await openCreate(tester);
      await fillBasics(tester);
      await tapKey(tester, 'add_taxpayer_batch_account_button');
      await tapKey(tester, 'add_taxpayer_batch_account_button');
      await enter(tester, 'taxpayer_batch_account_bank_0', 'First');
      await enter(tester, 'taxpayer_batch_account_bank_1', 'Second');
      await tapKey(tester, 'remove_account_0');

      await tapKey(tester, 'taxpayer_batch_save_button');

      final draft =
          verify(
                () => repository.create(batchRfc, captureAny()),
              ).captured.single
              as TaxpayerBatchDraft;
      expect(draft.series, 'FAC');
      expect(draft.kind, FiscalDocumentKind.invoice);
      expect(draft.template.name, 'Factura');
      expect([for (final a in draft.template.accounts) a.bank], ['Second']);
      // The dialog closes once saved.
      expect(find.text(l10n.taxpayerBatchDialogCreateTitle), findsNothing);
    });

    testWidgets('moving an account changes the order that is sent', (
      tester,
    ) async {
      when(
        () => repository.create(any(), any()),
      ).thenAnswer((_) async => aBatch(series: 'FAC'));
      await openCreate(tester);
      await fillBasics(tester);
      await tapKey(tester, 'add_taxpayer_batch_account_button');
      await tapKey(tester, 'add_taxpayer_batch_account_button');
      await enter(tester, 'taxpayer_batch_account_bank_0', 'First');
      await enter(tester, 'taxpayer_batch_account_bank_1', 'Second');
      // The first row has no "up" and the last has no "down".
      expect(find.byKey(const Key('move_account_up_0')), findsNothing);
      expect(find.byKey(const Key('move_account_down_1')), findsNothing);

      await tapKey(tester, 'move_account_down_0');
      await tapKey(tester, 'taxpayer_batch_save_button');

      final draft =
          verify(
                () => repository.create(batchRfc, captureAny()),
              ).captured.single
              as TaxpayerBatchDraft;
      expect(
        [for (final a in draft.template.accounts) a.bank],
        ['Second', 'First'],
      );
    });

    testWidgets('a duplicate series is flagged under the series field and the '
        'typed values stay', (tester) async {
      when(() => repository.create(any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.resourcePeriodAlreadyExists,
          'resource.already_exists',
          {'resource': 'taxpayer_batch', 'field': 'batch'},
        ),
      );
      await openCreate(tester);
      await fillBasics(tester, series: 'A');

      await tapKey(tester, 'taxpayer_batch_save_button');

      final duplicate = l10n.apiErrorResourceAlreadyExists(
        'feminine',
        l10n.apiResourceTaxpayerBatch(1),
      );
      expect(find.text(duplicate), findsWidgets);
      expect(
        find.byKey(const Key('taxpayer_batch_error_banner')),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'A'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Factura'), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchDialogCreateTitle), findsOneWidget);
    });

    testWidgets('any other refusal shows the banner and keeps the form', (
      tester,
    ) async {
      when(
        () => repository.create(any(), any()),
      ).thenAnswer((_) async => throw const AppError.network());
      await openCreate(tester);
      await fillBasics(tester);

      await tapKey(tester, 'taxpayer_batch_save_button');

      expect(find.text(l10n.taxpayerBatchSaveFailed), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'FAC'), findsOneWidget);
    });

    testWidgets('Cancelar closes without a call', (tester) async {
      await openCreate(tester);
      await fillBasics(tester);

      await tapKey(tester, 'taxpayer_batch_cancel_button');

      expect(find.text(l10n.taxpayerBatchDialogCreateTitle), findsNothing);
      verifyNever(() => repository.create(any(), any()));
    });

    testWidgets('on a compact screen the dialog fills the screen and keeps '
        'Save', (tester) async {
      await pumpAndOpen(
        tester,
        batches: [aBatch()],
        user: fullUser,
        size: const Size(400, 900),
        open: () async =>
            tester.tap(find.byKey(const Key('add_taxpayer_batch_button'))),
      );

      expect(find.byType(Dialog), findsOneWidget);
      expect(
        tester.widget<Dialog>(find.byType(Dialog)).insetPadding,
        EdgeInsets.zero,
      );
      expect(
        find.byKey(const Key('taxpayer_batch_save_button')),
        findsOneWidget,
      );
    });
  });

  group('edit and the in-use lock', () {
    Future<void> openEdit(
      WidgetTester tester,
      TaxpayerBatch batch, {
      dynamic user,
    }) => pumpAndOpen(
      tester,
      batches: [batch],
      user: user ?? fullUser,
      open: () async => tester.tap(
        find.byKey(Key('edit_taxpayer_batch_${batch.taxpayerBatchId}')),
      ),
    );

    testWidgets('an unused series has every field editable', (tester) async {
      await openEdit(tester, aBatch(series: 'FAC', accounts: _accounts));

      expect(find.byKey(const Key('taxpayer_batch_in_use_note')), findsNothing);
      expect(
        fieldOf(tester, 'taxpayer_batch_series_field').enabled,
        isNot(false),
      );
      expect(fieldOf(tester, 'taxpayer_batch_series_field').readOnly, isFalse);
      expect(
        tester
            .widget<DropdownButtonFormField<FiscalDocumentKind>>(
              find.byKey(const Key('taxpayer_batch_type_field')),
            )
            .onChanged,
        isNotNull,
      );
      expect(
        find.byKey(const Key('add_taxpayer_batch_account_button')),
        findsOneWidget,
      );
    });

    testWidgets('an in-use series shows the lock up front: series and type '
        'are read-only, the template is not', (tester) async {
      await openEdit(tester, aBatch(series: 'FAC', inUse: true));

      expect(
        find.byKey(const Key('taxpayer_batch_in_use_note')),
        findsOneWidget,
      );
      expect(find.text(l10n.taxpayerBatchInUseNote), findsOneWidget);
      expect(fieldOf(tester, 'taxpayer_batch_series_field').enabled, isFalse);
      expect(
        tester
            .widget<DropdownButtonFormField<FiscalDocumentKind>>(
              find.byKey(const Key('taxpayer_batch_type_field')),
            )
            .onChanged,
        isNull,
      );
      expect(
        fieldOf(tester, 'taxpayer_batch_template_name_field').enabled,
        isNot(false),
      );
      expect(
        find.byKey(const Key('taxpayer_batch_delete_button')),
        findsNothing,
      );
    });

    testWidgets('a template change on an in-use series saves with the stored '
        'series and kind', (tester) async {
      when(
        () => repository.update(any(), any(), any()),
      ).thenAnswer((_) async => aBatch(series: 'FAC', inUse: true));
      await openEdit(tester, aBatch(series: 'FAC', typeCode: 100, inUse: true));
      await enter(tester, 'taxpayer_batch_header_height_field', '9');

      await tapKey(tester, 'taxpayer_batch_save_button');

      final draft =
          verify(
                () => repository.update(batchRfc, 1, captureAny()),
              ).captured.single
              as TaxpayerBatchDraft;
      expect(draft.series, 'FAC');
      expect(draft.kind, FiscalDocumentKind.creditNote);
      expect(draft.template.headerHeight, 9);
      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsNothing);
    });

    testWidgets('a series that became in use while open locks, keeps the '
        'template edits and shows why', (tester) async {
      when(() => repository.update(any(), any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.taxpayerBatchPeriodInUse,
          'taxpayer_batch.in_use',
          {'action': 'update'},
        ),
      );
      await openEdit(tester, aBatch(series: 'FAC'));
      await enter(tester, 'taxpayer_batch_series_field', 'ZZ');
      await enter(tester, 'taxpayer_batch_template_name_field', 'Mi edición');

      await tapKey(tester, 'taxpayer_batch_save_button');

      expect(
        find.byKey(const Key('taxpayer_batch_in_use_note')),
        findsOneWidget,
      );
      expect(find.text(l10n.taxpayerBatchSaveFailed), findsOneWidget);
      expect(find.text(l10n.apiErrorTaxpayerBatchInUseUpdate), findsWidgets);
      expect(fieldOf(tester, 'taxpayer_batch_series_field').enabled, isFalse);
      // The series is back to what is stored, and the template edit stays.
      expect(find.widgetWithText(TextFormField, 'FAC'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'ZZ'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Mi edición'), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsOneWidget);
    });
  });

  group('delete', () {
    Future<void> openEdit(WidgetTester tester, {dynamic user}) => pumpAndOpen(
      tester,
      batches: [aBatch(series: 'FAC', typeCode: 100)],
      user: user ?? fullUser,
      open: () async =>
          tester.tap(find.byKey(const Key('edit_taxpayer_batch_1'))),
    );

    testWidgets('an unused series can be deleted after a confirmation that '
        'names it', (tester) async {
      when(() => repository.delete(any(), any())).thenAnswer((_) async {});
      await openEdit(tester);

      await tapKey(tester, 'taxpayer_batch_delete_button');

      expect(find.text(l10n.taxpayerBatchDeleteTitle), findsOneWidget);
      expect(
        find.text(
          l10n.taxpayerBatchDeleteMessage(
            'FAC',
            l10n.fiscalDocumentKindCreditNote,
          ),
        ),
        findsOneWidget,
      );
      verifyNever(() => repository.delete(any(), any()));

      await tapKey(tester, 'confirm_delete_taxpayer_batch_button');

      verify(() => repository.delete(batchRfc, 1)).called(1);
      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsNothing);
    });

    testWidgets('cancelling the confirmation leaves the series alone', (
      tester,
    ) async {
      await openEdit(tester);

      await tapKey(tester, 'taxpayer_batch_delete_button');
      await tester.tap(find.text(l10n.cancelButton).last);
      await tester.pumpAndSettle();

      verifyNever(() => repository.delete(any(), any()));
      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsOneWidget);
    });

    testWidgets('without the delete right there is no Eliminar', (
      tester,
    ) async {
      // create + read + update = 7, no delete.
      await openEdit(tester, user: taxpayersUser(7));

      expect(
        find.byKey(const Key('taxpayer_batch_delete_button')),
        findsNothing,
      );
    });

    testWidgets('a series that became in use is refused, locked and says '
        'why', (tester) async {
      when(() => repository.delete(any(), any())).thenAnswer(
        (_) async => throw _refusal(
          api.ErrorCode.taxpayerBatchPeriodInUse,
          'taxpayer_batch.in_use',
          {'action': 'delete'},
        ),
      );
      await openEdit(tester);

      await tapKey(tester, 'taxpayer_batch_delete_button');
      await tapKey(tester, 'confirm_delete_taxpayer_batch_button');

      expect(find.text(l10n.taxpayerBatchDeleteFailed), findsOneWidget);
      expect(find.text(l10n.apiErrorTaxpayerBatchInUseDelete), findsWidgets);
      expect(
        find.byKey(const Key('taxpayer_batch_in_use_note')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('taxpayer_batch_delete_button')),
        findsNothing,
      );
      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsOneWidget);
    });
  });
}
