import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';

import 'taxpayer_batch_widget_harness.dart';

void main() {
  late MockTaxpayerBatchRepository repository;

  setUp(() {
    repository = MockTaxpayerBatchRepository();
  });

  void stubList(List<dynamic> batches) => when(
    () => repository.listForIssuer(batchRfc),
  ).thenAnswer((_) async => List.of(batches.cast()));

  group('states', () {
    testWidgets('shows a spinner while the series load', (tester) async {
      when(() => repository.listForIssuer(batchRfc)).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(seconds: 5));
        return [];
      });
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
        settle: false,
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('add_taxpayer_batch_button')), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('an issuer with no series shows what that means', (
      tester,
    ) async {
      stubList([]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );
      final l10n = await englishStrings();

      expect(find.byKey(const Key('taxpayer_batches_empty')), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchesEmpty), findsOneWidget);
      expect(find.byKey(const Key('taxpayer_batches_table')), findsNothing);
      expect(find.text(l10n.taxpayerBatchesSectionTitle), findsOneWidget);
    });

    testWidgets('a failed load shows the error with a working retry', (
      tester,
    ) async {
      var calls = 0;
      when(() => repository.listForIssuer(batchRfc)).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const AppError.network();
        return [aBatch()];
      });
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );
      final l10n = await englishStrings();

      expect(find.byType(ListFailedView), findsOneWidget);
      // A failed list offers no way to add.
      expect(find.byKey(const Key('add_taxpayer_batch_button')), findsNothing);

      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(find.byType(ListFailedView), findsNothing);
      expect(find.byKey(const Key('taxpayer_batches_table')), findsOneWidget);
    });
  });

  group('rows', () {
    testWidgets('lists the series by type then series, with type names, the '
        'lock only on in-use rows and a count in the title', (tester) async {
      stubList([
        aBatch(id: 1, series: 'P', typeCode: 101, templateName: 'Recibo'),
        aBatch(id: 2, series: 'B', typeCode: 0, templateName: 'Sucursal'),
        aBatch(id: 3, series: 'NC', typeCode: 100, inUse: true),
        aBatch(id: 4, series: 'A', typeCode: 0, inUse: true),
      ]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );
      final l10n = await englishStrings();

      expect(
        find.text(l10n.taxpayerBatchesSectionTitleWithCount(4)),
        findsOneWidget,
      );
      final series = ['A', 'B', 'NC', 'P'];
      final tops = [
        for (final s in series) tester.getTopLeft(find.text(s).first).dy,
      ];
      expect(tops, [...tops]..sort());
      expect(find.text(l10n.fiscalDocumentKindInvoice), findsNWidgets(2));
      expect(find.text(l10n.fiscalDocumentKindCreditNote), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentKindPaymentReceipt), findsOneWidget);
      expect(find.text('Sucursal'), findsOneWidget);
      expect(find.byKey(const Key('taxpayer_batch_in_use_4')), findsOneWidget);
      expect(find.byKey(const Key('taxpayer_batch_in_use_3')), findsOneWidget);
      expect(find.byKey(const Key('taxpayer_batch_in_use_2')), findsNothing);
      expect(find.byKey(const Key('taxpayer_batch_in_use_1')), findsNothing);
    });

    testWidgets('a type the app does not know still shows, last', (
      tester,
    ) async {
      stubList([
        aBatch(id: 1, series: 'X', typeCode: 7),
        aBatch(id: 2, series: 'A', typeCode: 0),
      ]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );
      final l10n = await englishStrings();

      expect(find.text(l10n.fiscalDocumentKindUnknown(7)), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('X')).dy,
        greaterThan(tester.getTopLeft(find.text('A')).dy),
      );
    });

    testWidgets('the template column is dropped on a compact screen', (
      tester,
    ) async {
      stubList([aBatch(templateName: 'Plantilla secreta')]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
        size: const Size(400, 900),
      );
      final l10n = await englishStrings();

      expect(find.text('Plantilla secreta'), findsNothing);
      expect(find.text(l10n.taxpayerBatchColumnTemplate), findsNothing);
      expect(find.text(l10n.taxpayerBatchColumnSeries), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchColumnType), findsOneWidget);
    });

    testWidgets('the template column shows on a wide screen', (tester) async {
      stubList([aBatch(templateName: 'Plantilla visible')]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
        size: const Size(1200, 900),
      );

      expect(find.text('Plantilla visible'), findsOneWidget);
    });
  });

  group('rights', () {
    testWidgets('a user with every right sees Nuevo and an Edit icon per '
        'row, and no row delete', (tester) async {
      stubList([aBatch(id: 1), aBatch(id: 2, series: 'B')]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );

      expect(
        find.byKey(const Key('add_taxpayer_batch_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('edit_taxpayer_batch_1')), findsOneWidget);
      expect(find.byKey(const Key('edit_taxpayer_batch_2')), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('a reader sees the rows and no mutating control', (
      tester,
    ) async {
      stubList([aBatch()]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: readUser,
      );

      expect(find.byKey(const Key('taxpayer_batches_table')), findsOneWidget);
      expect(find.byKey(const Key('add_taxpayer_batch_button')), findsNothing);
      expect(find.byKey(const Key('edit_taxpayer_batch_1')), findsNothing);
    });

    testWidgets('create without update adds but cannot edit a row', (
      tester,
    ) async {
      stubList([aBatch()]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: createReadUser,
      );

      expect(
        find.byKey(const Key('add_taxpayer_batch_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('edit_taxpayer_batch_1')), findsNothing);
    });

    testWidgets('update without create edits a row but cannot add', (
      tester,
    ) async {
      stubList([aBatch()]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: updateReadUser,
      );

      expect(find.byKey(const Key('add_taxpayer_batch_button')), findsNothing);
      expect(find.byKey(const Key('edit_taxpayer_batch_1')), findsOneWidget);
    });

    testWidgets('a read-only render of the issuer hides every control, even '
        'for a user with every right', (tester) async {
      stubList([aBatch()]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
        readOnly: true,
      );

      expect(find.byKey(const Key('taxpayer_batches_table')), findsOneWidget);
      expect(find.byKey(const Key('add_taxpayer_batch_button')), findsNothing);
      expect(find.byKey(const Key('edit_taxpayer_batch_1')), findsNothing);
    });
  });

  group('opening a row', () {
    testWidgets('a row tap opens the series read-only', (tester) async {
      stubList([aBatch(series: 'FAC', templateName: 'Mi plantilla')]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );
      final l10n = await englishStrings();

      await tester.tap(find.text('FAC'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.taxpayerBatchDialogViewTitle), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsNothing);
    });

    testWidgets('the Edit icon opens the series editable', (tester) async {
      stubList([aBatch(series: 'FAC')]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );
      final l10n = await englishStrings();

      await tester.tap(find.byKey(const Key('edit_taxpayer_batch_1')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.taxpayerBatchDialogEditTitle), findsOneWidget);
      expect(find.text(l10n.taxpayerBatchDialogViewTitle), findsNothing);
    });

    testWidgets('Nuevo opens an empty add form', (tester) async {
      stubList([aBatch()]);
      await pumpBatchesSection(
        tester,
        repository: repository,
        signedInAs: fullUser,
      );
      final l10n = await englishStrings();

      await tester.tap(find.byKey(const Key('add_taxpayer_batch_button')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.taxpayerBatchDialogCreateTitle), findsOneWidget);
    });
  });
}
