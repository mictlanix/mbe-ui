import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 070 US2 (T019), US4 (T027) and US5 (T030): the count detail screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
  });

  setUp(() => h = InventoryHarness());

  String title(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(of: find.byType(AppBar), matching: find.byType(Text)),
      )
      .data!;

  /// The text the screen shows for [error]: its code, localized.
  String localized(AppError error) =>
      error.localizedMessage(l10n, h.container.read(formattersProvider))!;

  final completed = aCount(
    serial: 77,
    status: InventoryDocumentStatus.completed,
    lines: [
      aCompletedCountLine(quantity: '8', quantityOnHand: '10'),
      aCompletedCountLine(
        id: 1201,
        productId: 8,
        productCode: 'B-220',
        quantity: '12',
        quantityOnHand: '10',
      ),
      aCompletedCountLine(
        id: 1202,
        productId: 9,
        productCode: 'C-310',
        quantity: '4',
        quantityOnHand: '4',
      ),
    ],
  );

  /// [n] blind lines, coded L-0001 onward.
  List<InventoryCountLine> manyLines(int n) => [
    for (var i = 1; i <= n; i++)
      aCountLine(
        id: 5000 + i,
        productId: 5000 + i,
        productCode: 'L-${'$i'.padLeft(4, '0')}',
        productName: 'Producto $i',
        quantity: '$i',
      ),
  ];

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(
      find.descendant(
        of: key('count_lines_search'),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  Future<void> nextPage(WidgetTester tester) async {
    final next = find.descendant(
      of: key('inventory_count_lines_table'),
      matching: find.byIcon(Icons.chevron_right),
    );
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
  }

  group('a draft', () {
    testWidgets('is titled "Conteo · Borrador #id" with no folio, and shows '
        'its facts, lines and the actions with full rights', (tester) async {
      await h.pumpCount(tester, aCount(comment: 'Pasillo 3'));

      expect(title(tester), l10n.inventoryCountTitleDraft('412'));
      expect(title(tester), 'Conteo · Borrador #412');
      expect(
        tester.widget<RecordIdText>(key('inventory_count_serial')).text,
        '—',
      );
      expect(find.text('Almacén 3'), findsOneWidget);
      expect(find.text('Sucursal 2'), findsOneWidget);
      expect(find.text('Pasillo 3'), findsOneWidget);
      expect(find.text(l10n.inventoryCountFactLines), findsOneWidget);
      expect(tester.widget<Text>(key('inventory_count_line_count')).data, '1');
      expect(find.text('Empleado 5'), findsNWidgets(2));
      expect(find.text('A-100'), findsOneWidget);
      expect(find.text('Tornillo 1/4 caja'), findsOneWidget);
      expect(
        tester.widget<Text>(key('inventory_count_line_quantity_1200')).data,
        '8',
      );
      expect(key('inventory_count_line_edit_1200'), findsOneWidget);
      expect(key('inventory_count_line_remove_1200'), findsOneWidget);
      expect(key('inventory_count_add_product'), findsOneWidget);
      expect(key('inventory_count_confirm'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is blind: no Esperado or Diferencia column and no on-hand '
        'figure anywhere, even if the server sent one (SC-003)', (
      tester,
    ) async {
      // A leaked figure must still not reach the screen.
      final leaky = aCountLine().copyWith(
        quantityOnHand: Decimal.parse('999'),
        difference: Decimal.parse('-991'),
      );
      await h.pumpCount(tester, aCount(lines: [leaky]));

      expect(find.text(l10n.inventoryCountLineColExpected), findsNothing);
      expect(find.text(l10n.inventoryCountLineColDifference), findsNothing);
      expect(key('inventory_count_line_expected_1200'), findsNothing);
      expect(key('inventory_count_line_difference_1200'), findsNothing);
      expect(find.textContaining('999'), findsNothing);
      expect(find.textContaining('991'), findsNothing);
    });

    testWidgets('with no lines shows the empty-draft text', (tester) async {
      await h.pumpCount(tester, aCount(lines: const []));

      expect(
        find.text(
          'Registra lo que contaste. Las existencias esperadas se muestran '
          'al confirmar.',
        ),
        findsOneWidget,
      );
      expect(key('inventory_count_lines_table'), findsNothing);
    });

    testWidgets('Agregar producto needs Products read', (tester) async {
      await h.pumpCount(
        tester,
        aCount(),
        who: InventoryHarness.countUser(productsRead: false),
      );

      expect(key('inventory_count_add_product'), findsNothing);
      expect(key('inventory_count_confirm'), findsOneWidget);
    });

    testWidgets('a read-only user sees no actions and no line icons', (
      tester,
    ) async {
      await h.pumpCount(
        tester,
        aCount(),
        who: InventoryHarness.countUser(counts: 2),
      );

      expect(key('inventory_count_actions'), findsNothing);
      expect(key('inventory_count_confirm'), findsNothing);
      expect(key('inventory_count_add_product'), findsNothing);
      expect(key('inventory_count_line_edit_1200'), findsNothing);
      expect(key('inventory_count_line_remove_1200'), findsNothing);
    });
  });

  testWidgets('a completed count shows its folio, Esperado and a signed '
      'Diferencia, and no edit action', (tester) async {
    await h.pumpCount(tester, completed);

    expect(title(tester), 'Conteo 77');
    expect(
      tester.widget<RecordIdText>(key('inventory_count_serial')).text,
      '77',
    );
    expect(find.text(l10n.inventoryCountStatusCompleted), findsOneWidget);
    expect(find.text(l10n.inventoryCountLineColExpected), findsOneWidget);
    expect(find.text(l10n.inventoryCountLineColDifference), findsOneWidget);
    String text(String k) => tester.widget<Text>(key(k)).data!;
    expect(text('inventory_count_line_expected_1200'), '10');
    expect(text('inventory_count_line_difference_1200'), '-2');
    expect(text('inventory_count_line_difference_1201'), '+2');
    expect(text('inventory_count_line_difference_1202'), '0');
    expect(key('inventory_count_actions'), findsNothing);
    expect(key('inventory_count_line_edit_1200'), findsNothing);
  });

  testWidgets('a cancelled count keeps the draft title and has no actions', (
    tester,
  ) async {
    await h.pumpCount(
      tester,
      aCount(status: InventoryDocumentStatus.cancelled),
    );

    expect(title(tester), l10n.inventoryCountTitleDraft('412'));
    expect(find.text(l10n.inventoryCountStatusCancelled), findsOneWidget);
    expect(find.text(l10n.inventoryCountLineColExpected), findsNothing);
    expect(key('inventory_count_actions'), findsNothing);
    expect(key('inventory_count_line_edit_1200'), findsNothing);
  });

  group('lines', () {
    final lines = [
      aCountLine(),
      aCountLine(
        id: 1201,
        productId: 8,
        productCode: 'B-220',
        productName: 'Taquete 5/16',
      ),
    ];

    testWidgets('the search narrows the table by code, ignoring case', (
      tester,
    ) async {
      await h.pumpCount(tester, aCount(lines: lines));

      await search(tester, 'b-2');

      expect(find.text('B-220'), findsOneWidget);
      expect(find.text('A-100'), findsNothing);
    });

    testWidgets('the search narrows the table by name', (tester) async {
      await h.pumpCount(tester, aCount(lines: lines));

      await search(tester, 'TORNILLO');

      expect(find.text('A-100'), findsOneWidget);
      expect(find.text('B-220'), findsNothing);
    });

    testWidgets('250 lines show 100 at a time, the pager moves, and a '
        'search returns to page 1', (tester) async {
      await h.pumpCount(tester, aCount(lines: manyLines(250)));

      expect(find.text('L-0001'), findsOneWidget);
      expect(find.text('L-0100'), findsOneWidget);
      expect(find.text('L-0101'), findsNothing);

      await nextPage(tester);
      expect(find.text('L-0001'), findsNothing);
      expect(find.text('L-0101'), findsOneWidget);
      expect(find.text('L-0200'), findsOneWidget);

      await nextPage(tester);
      expect(find.text('L-0201'), findsOneWidget);
      expect(find.text('L-0250'), findsOneWidget);

      // "L-00" matches L-0001 to L-0099: one page, starting at the first.
      await search(tester, 'L-00');
      expect(find.text('L-0001'), findsOneWidget);
      expect(find.text('L-0201'), findsNothing);
    });

    testWidgets('a write keeps the current page', (tester) async {
      final all = manyLines(250);
      final line = all[150];
      when(
        () =>
            h.counts.updateLine(412, line.id, quantity: any(named: 'quantity')),
      ).thenAnswer(
        (_) async => aLinesChange(
          lines: [line.copyWith(quantity: Decimal.zero)],
          lineCount: all.length,
        ),
      );
      await h.pumpCount(tester, aCount(lines: all));
      await nextPage(tester);

      final edit = key('inventory_count_line_edit_${line.id}');
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(key('inventory_count_line_quantity_field'), '0');
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_count_line_quantity_submit'));
      await tester.pumpAndSettle();

      expect(find.text('L-0101'), findsOneWidget);
      expect(
        tester
            .widget<Text>(key('inventory_count_line_quantity_${line.id}'))
            .data,
        '0',
      );
    });
  });

  group('confirm', () {
    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(key('inventory_count_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_count_confirm_submit'));
      await tester.pumpAndSettle();
    }

    void stubConfirm(Future<CountConfirmResult> Function() answer) => when(
      () => h.counts.confirm(
        412,
        includeUncounted: any(named: 'includeUncounted'),
      ),
    ).thenAnswer((_) => answer());

    testWidgets('shows the folio, the differences and the read-only state', (
      tester,
    ) async {
      stubConfirm(
        () async => CountConfirmResult(
          count: completed.copyWith(id: 412),
          warnings: const CountWarnings(),
        ),
      );
      await h.pumpCount(tester, aCount());

      await confirm(tester);

      expect(title(tester), 'Conteo 77');
      expect(find.text(l10n.inventoryCountStatusCompleted), findsOneWidget);
      expect(find.text(l10n.inventoryCountLineColDifference), findsOneWidget);
      expect(key('inventory_count_confirm'), findsNothing);
      expect(key('inventory_count_refusal'), findsNothing);
    });

    testWidgets('no_lines shows in Spanish and the count stays a draft', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodNoLines,
        'inventory_document.no_lines',
        {'resource': 'inventory_count'},
      );
      stubConfirm(() async => throw refusal);
      await h.pumpCount(tester, aCount(lines: const []));

      await confirm(tester);

      expect(key('inventory_count_refusal'), findsOneWidget);
      expect(find.text('El conteo no tiene partidas.'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
      expect(title(tester), l10n.inventoryCountTitleDraft('412'));
      expect(key('inventory_count_confirm'), findsOneWidget);
    });

    testWidgets('lock.busy shows in Spanish and re-fetches the count', (
      tester,
    ) async {
      final refusal = aRefusal(api.ErrorCode.lockPeriodBusy, 'lock.busy', {
        'resource': 'inventory_count',
      });
      stubConfirm(() async => throw refusal);
      await h.pumpCount(tester, aCount());

      await confirm(tester);

      expect(find.text(localized(refusal)), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
      verify(() => h.counts.get(412)).called(2);
      expect(find.text(l10n.inventoryCountStatusDraft), findsOneWidget);
      expect(key('inventory_count_confirm'), findsOneWidget);
    });
  });

  group('confirm warnings (US4)', () {
    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(key('inventory_count_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_count_confirm_submit'));
      await tester.pumpAndSettle();
    }

    void stubConfirm(CountWarnings warnings) =>
        when(
          () => h.counts.confirm(
            412,
            includeUncounted: any(named: 'includeUncounted'),
          ),
        ).thenAnswer(
          (_) async => CountConfirmResult(
            count: completed.copyWith(id: 412),
            warnings: warnings,
          ),
        );

    testWidgets('a confirm with warnings shows the band above the lines, '
        'with both sections, and not as an error', (tester) async {
      stubConfirm(someCountWarnings());
      await h.pumpCount(tester, aCount());

      await confirm(tester);

      expect(key('count_confirm_warnings'), findsOneWidget);
      expect(
        find.text('A-100  contado 2 · apartado 5 · disponible -3'),
        findsOneWidget,
      );
      expect(find.text('B-200  conteo 57'), findsOneWidget);
      expect(
        tester.getTopLeft(key('count_confirm_warnings')).dy,
        lessThan(tester.getTopLeft(key('inventory_count_lines')).dy),
      );
      expect(key('inventory_count_refusal'), findsNothing);
      expect(find.byType(ErrorBanner), findsNothing);
    });

    testWidgets('a confirm with no warnings shows no band', (tester) async {
      stubConfirm(const CountWarnings());
      await h.pumpCount(tester, aCount());

      await confirm(tester);

      expect(title(tester), 'Conteo 77');
      expect(key('count_confirm_warnings'), findsNothing);
    });

    testWidgets('✕ dismisses the band', (tester) async {
      stubConfirm(someCountWarnings());
      await h.pumpCount(tester, aCount());
      await confirm(tester);

      await tester.tap(key('count_confirm_warnings_close'));
      await tester.pumpAndSettle();

      expect(key('count_confirm_warnings'), findsNothing);
    });

    testWidgets('the band survives a reload inside the screen', (tester) async {
      stubConfirm(someCountWarnings());
      await h.pumpCount(tester, aCount());
      await confirm(tester);
      h.stubCount(completed.copyWith(id: 412));

      await h.container
          .read(inventoryCountDetailControllerProvider(412).notifier)
          .refresh();
      await tester.pumpAndSettle();

      expect(key('count_confirm_warnings'), findsOneWidget);
    });

    testWidgets('the band is gone after leaving and reopening the count', (
      tester,
    ) async {
      stubConfirm(someCountWarnings());
      final router = await h.pumpCount(tester, aCount());
      await confirm(tester);
      expect(key('count_confirm_warnings'), findsOneWidget);
      h.stubCount(completed.copyWith(id: 412));

      router.go(inventoryCountsPath);
      await tester.pumpAndSettle();
      router.go('$inventoryCountsPath/412');
      await tester.pumpAndSettle();

      expect(title(tester), 'Conteo 77');
      expect(key('count_confirm_warnings'), findsNothing);
    });
  });

  testWidgets('Confirmar and Cancelar are disabled while a confirm is in '
      'flight, so it is sent once', (tester) async {
    final answer = Completer<CountConfirmResult>();
    when(
      () => h.counts.confirm(
        412,
        includeUncounted: any(named: 'includeUncounted'),
      ),
    ).thenAnswer((_) => answer.future);
    await h.pumpCount(tester, aCount());

    await tester.tap(key('inventory_count_confirm'));
    await tester.pumpAndSettle();
    await tester.tap(key('inventory_count_confirm_submit'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(key('inventory_count_confirm')).onPressed,
      isNull,
    );
    expect(
      tester.widget<OutlinedButton>(key('inventory_count_cancel')).onPressed,
      isNull,
    );
    await tester.tap(key('inventory_count_confirm'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(key('inventory_count_confirm_dialog'), findsNothing);

    answer.complete(
      CountConfirmResult(
        count: completed.copyWith(id: 412),
        warnings: const CountWarnings(),
      ),
    );
    await tester.pumpAndSettle();

    verify(
      () => h.counts.confirm(
        412,
        includeUncounted: any(named: 'includeUncounted'),
      ),
    ).called(1);
    expect(title(tester), 'Conteo 77');
  });

  group('Editar encabezado and Cancelar (US5)', () {
    testWidgets('a draft shows them first in the action area: Cancelar, '
        'Editar encabezado, Pegar lista, Agregar producto, Confirmar', (
      tester,
    ) async {
      await h.pumpCount(tester, aCount());

      expect(find.text(l10n.inventoryCountActionCancel), findsOneWidget);
      expect(find.text(l10n.inventoryCountActionEditHeader), findsOneWidget);
      double left(String k) => tester.getTopLeft(key(k)).dx;
      expect(
        left('inventory_count_cancel'),
        lessThan(left('inventory_count_edit_header')),
      );
      expect(
        left('inventory_count_edit_header'),
        lessThan(left('inventory_count_paste')),
      );
      expect(
        left('inventory_count_paste'),
        lessThan(left('inventory_count_add_product')),
      );
      expect(
        left('inventory_count_add_product'),
        lessThan(left('inventory_count_confirm')),
      );
    });

    testWidgets('Cancelar is in the error tone', (tester) async {
      await h.pumpCount(tester, aCount());

      final button = tester.widget<OutlinedButton>(
        key('inventory_count_cancel'),
      );
      final error = Theme.of(
        tester.element(key('inventory_count_cancel')),
      ).colorScheme.error;
      expect(button.style!.foregroundColor!.resolve({}), error);
    });

    testWidgets('both are absent on a completed count', (tester) async {
      await h.pumpCount(tester, completed);

      expect(key('inventory_count_cancel'), findsNothing);
      expect(key('inventory_count_edit_header'), findsNothing);
    });

    testWidgets('both are absent on a cancelled count', (tester) async {
      await h.pumpCount(
        tester,
        aCount(status: InventoryDocumentStatus.cancelled),
      );

      expect(key('inventory_count_cancel'), findsNothing);
      expect(key('inventory_count_edit_header'), findsNothing);
    });

    testWidgets('Cancelar needs delete on 74', (tester) async {
      await h.pumpCount(
        tester,
        aCount(),
        // create, read and update; no delete.
        who: InventoryHarness.countUser(counts: 7),
      );

      expect(key('inventory_count_cancel'), findsNothing);
      expect(key('inventory_count_edit_header'), findsOneWidget);
    });

    testWidgets('Editar encabezado needs update on 74', (tester) async {
      await h.pumpCount(
        tester,
        aCount(),
        // create, read and delete; no update.
        who: InventoryHarness.countUser(counts: 11),
      );

      expect(key('inventory_count_edit_header'), findsNothing);
      expect(key('inventory_count_cancel'), findsOneWidget);
    });
  });

  group('quick entry and Pegar lista (US3)', () {
    testWidgets('a draft shows Captura rápida between the facts and the '
        'lines, and Pegar lista right before Agregar producto', (tester) async {
      await h.pumpCount(tester, aCount());

      expect(key('count_quick_entry'), findsOneWidget);
      double top(String k) => tester.getTopLeft(key(k)).dy;
      expect(top('inventory_count_facts'), lessThan(top('count_quick_entry')));
      expect(top('count_quick_entry'), lessThan(top('inventory_count_lines')));

      final paste = key('inventory_count_paste');
      expect(paste, findsOneWidget);
      expect(find.text(l10n.inventoryCountActionPaste), findsOneWidget);
      expect(
        tester.getTopLeft(paste).dx,
        lessThan(tester.getTopLeft(key('inventory_count_add_product')).dx),
      );
    });

    testWidgets('Pegar lista opens the paste dialog', (tester) async {
      await h.pumpCount(tester, aCount());

      await tester.tap(key('inventory_count_paste'));
      await tester.pumpAndSettle();

      expect(key('count_paste_dialog'), findsOneWidget);
      expect(
        tester.widget<Text>(key('responsive_dialog_title')).data,
        l10n.inventoryCountDialogPasteTitle,
      );
    });

    testWidgets('Pegar lista does not need Products read', (tester) async {
      await h.pumpCount(
        tester,
        aCount(),
        who: InventoryHarness.countUser(productsRead: false),
      );

      expect(key('inventory_count_paste'), findsOneWidget);
      expect(key('count_quick_entry'), findsOneWidget);
    });

    testWidgets('both are absent for a read-only user', (tester) async {
      await h.pumpCount(
        tester,
        aCount(),
        who: InventoryHarness.countUser(counts: 2),
      );

      expect(key('inventory_count_paste'), findsNothing);
      expect(key('count_quick_entry'), findsNothing);
    });

    testWidgets('both are absent on a completed count', (tester) async {
      await h.pumpCount(tester, completed);
      expect(key('inventory_count_paste'), findsNothing);
      expect(key('count_quick_entry'), findsNothing);
    });

    testWidgets('both are absent on a cancelled count', (tester) async {
      await h.pumpCount(
        tester,
        aCount(status: InventoryDocumentStatus.cancelled),
      );
      expect(key('inventory_count_paste'), findsNothing);
      expect(key('count_quick_entry'), findsNothing);
    });
  });

  group('load', () {
    testWidgets('a missing count shows the not-found view', (tester) async {
      when(
        () => h.counts.get(9),
      ).thenAnswer((_) async => throw const AppError.notFound());
      h.serveCounts(const []);
      await h.pumpCounts(tester, location: '/inventory/counts/9');

      expect(key('inventory_count_not_found'), findsOneWidget);
    });

    testWidgets('a failed load offers retry', (tester) async {
      var fail = true;
      when(() => h.counts.get(412)).thenAnswer((_) async {
        if (fail) throw const AppError.network();
        return aCount();
      });
      h.serveCounts(const []);
      await h.pumpCounts(tester, location: '/inventory/counts/412');

      expect(key('inventory_count_load_failed'), findsOneWidget);
      fail = false;
      await tester.tap(key('inventory_count_retry_button'));
      await tester.pumpAndSettle();
      expect(key('inventory_count_confirm'), findsOneWidget);
    });
  });
}
