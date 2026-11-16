import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_issue_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 068 US2 (T021): the issue detail screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() => h = InventoryHarness());

  final completed = anIssue(
    serial: 1043,
    status: InventoryDocumentStatus.completed,
  );

  String title(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(of: find.byType(AppBar), matching: find.byType(Text)),
      )
      .data!;

  /// The text the screen shows for [error]: its code, localized.
  String localized(AppError error) =>
      error.localizedMessage(l10n, h.container.read(formattersProvider))!;

  group('a draft', () {
    testWidgets('is titled "Salida · Borrador #id" with no folio, and shows '
        'its facts, lines and the actions with full rights', (tester) async {
      await h.pumpIssue(tester, anIssue(comment: 'Merma por humedad'));

      expect(title(tester), l10n.inventoryIssueTitleDraft('318'));
      expect(key('inventory_document_status_chip'), findsOneWidget);
      expect(tester.widget<Text>(key('inventory_issue_serial')).data, '—');
      expect(find.text('Almacén 3'), findsOneWidget);
      expect(find.text('Sucursal 2'), findsOneWidget);
      expect(find.text(l10n.inventoryIssueFactComment), findsOneWidget);
      expect(find.text('Merma por humedad'), findsOneWidget);
      expect(find.text('Empleado 5'), findsNWidgets(2));
      expect(key('inventory_issue_supplier_return'), findsNothing);
      expect(find.text('A-100'), findsOneWidget);
      expect(find.text('Tornillo 1/4 caja'), findsOneWidget);
      expect(
        tester.widget<Text>(key('inventory_issue_line_quantity_900')).data,
        '8',
      );
      expect(key('inventory_issue_line_edit_900'), findsOneWidget);
      expect(key('inventory_issue_line_remove_900'), findsOneWidget);
      expect(key('inventory_issue_add_product'), findsOneWidget);
      expect(key('inventory_issue_confirm'), findsOneWidget);
      expect(key('inventory_issue_edit_header'), findsOneWidget);
      expect(key('inventory_issue_cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with no lines says to add the products that leave', (
      tester,
    ) async {
      await h.pumpIssue(tester, anIssue(lines: const []));

      expect(find.text(l10n.inventoryIssueLinesEmpty), findsOneWidget);
    });

    testWidgets('never shows a warning or notice band', (tester) async {
      await h.pumpIssue(tester, anIssue());

      expect(find.textContaining('advertencia'), findsNothing);
      expect(find.textContaining('costo'), findsNothing);
    });

    testWidgets('Agregar producto needs Products read', (tester) async {
      await h.pumpIssue(
        tester,
        anIssue(),
        who: InventoryHarness.issueUser(productsRead: false),
      );

      expect(key('inventory_issue_add_product'), findsNothing);
      expect(key('inventory_issue_confirm'), findsOneWidget);
    });

    testWidgets('a read-only user sees no actions and no line icons', (
      tester,
    ) async {
      await h.pumpIssue(
        tester,
        anIssue(),
        who: InventoryHarness.issueUser(issues: 2),
      );

      expect(key('inventory_issue_actions'), findsNothing);
      expect(key('inventory_issue_line_edit_900'), findsNothing);
      expect(key('inventory_issue_line_remove_900'), findsNothing);
    });
  });

  testWidgets('a confirmed issue is titled with its folio and shows no edit '
      'actions or line icons', (tester) async {
    await h.pumpIssue(tester, completed);

    expect(title(tester), l10n.inventoryIssueTitle('1043'));
    expect(tester.widget<Text>(key('inventory_issue_serial')).data, '1043');
    expect(key('inventory_issue_add_product'), findsNothing);
    expect(key('inventory_issue_confirm'), findsNothing);
    expect(key('inventory_issue_line_edit_900'), findsNothing);
    expect(key('inventory_issue_line_remove_900'), findsNothing);
  });

  testWidgets('"Devolución a proveedor #id" shows only when set', (
    tester,
  ) async {
    await h.pumpIssue(tester, anIssue(supplierReturnId: 77));

    expect(
      tester.widget<Text>(key('inventory_issue_supplier_return')).data,
      l10n.inventoryIssueFactSupplierReturn('77'),
    );
  });

  testWidgets('adding a product already on the issue shows the single '
      'merged line the server returns', (tester) async {
    when(
      () => h.products.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const ProductListResult(
        items: [
          ProductListItem(
            productId: 7,
            code: 'A-100',
            name: 'Tornillo 1/4 caja',
            unitOfMeasurementCode: 'H87',
            unitOfMeasurementName: 'Pieza',
            taxRate: '0.16',
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
    when(
      () =>
          h.issues.addLine(318, productId: 7, quantity: any(named: 'quantity')),
    ).thenAnswer((_) async => anIssue(lines: [anIssueLine(quantity: '11')]));
    await h.pumpIssue(tester, anIssue());

    await tester.tap(key('inventory_issue_add_product'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: key('add_issue_line_product'),
        matching: find.byType(TextField),
      ),
      'torn',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tornillo 1/4 caja').last);
    await tester.pumpAndSettle();
    await tester.enterText(key('add_issue_line_quantity'), '3');
    await tester.pumpAndSettle();
    await tester.tap(key('add_issue_line_submit'));
    await tester.pumpAndSettle();

    expect(find.text('A-100'), findsOneWidget);
    expect(
      tester.widget<Text>(key('inventory_issue_line_quantity_900')).data,
      '11',
    );
  });

  group('confirm', () {
    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(key('inventory_issue_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_issue_confirm_submit'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the folio and the read-only state', (tester) async {
      when(() => h.issues.confirm(318)).thenAnswer((_) async => completed);
      await h.pumpIssue(tester, anIssue());

      await confirm(tester);

      expect(title(tester), l10n.inventoryIssueTitle('1043'));
      expect(tester.widget<Text>(key('inventory_issue_serial')).data, '1043');
      expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
      expect(key('inventory_issue_confirm'), findsNothing);
      expect(key('inventory_issue_line_edit_900'), findsNothing);
      expect(key('inventory_issue_refusal'), findsNothing);
    });

    testWidgets('an empty draft shows "La salida de almacén no tiene '
        'partidas."', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodNoLines,
        'inventory_document.no_lines',
        {'resource': 'inventory_issue'},
      );
      when(() => h.issues.confirm(318)).thenAnswer((_) async => throw refusal);
      await h.pumpIssue(tester, anIssue(lines: const []));

      await confirm(tester);

      expect(key('inventory_issue_refusal'), findsOneWidget);
      expect(
        find.text('La salida de almacén no tiene partidas.'),
        findsOneWidget,
      );
      expect(find.text(localized(refusal)), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
      expect(key('inventory_issue_confirm'), findsOneWidget);
    });

    testWidgets('insufficient_stock shows the Spanish message plus the '
        'product code and warehouse, and the issue stays a draft', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock,
        'inventory_document.insufficient_stock',
        {
          'product_id': 7,
          'warehouse_id': 3,
          'requested': '8',
          'available': '2',
        },
      );
      when(() => h.issues.confirm(318)).thenAnswer((_) async => throw refusal);
      await h.pumpIssue(tester, anIssue());

      await confirm(tester);

      final message = localized(refusal);
      expect(message, contains('8'));
      expect(message, contains('2'));
      expect(find.text(message), findsOneWidget);
      expect(
        find.text(
          l10n.inventoryIssueRefusalProductWarehouse('A-100', 'Almacén 3'),
        ),
        findsOneWidget,
      );
      expect(find.text('Producto: A-100 · Almacén: Almacén 3'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
      expect(title(tester), l10n.inventoryIssueTitleDraft('318'));
      expect(find.text(l10n.inventoryDocumentStatusDraft), findsOneWidget);
      expect(key('inventory_issue_confirm'), findsOneWidget);
    });

    testWidgets('the refusal clears on the next action', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodNoLines,
        'inventory_document.no_lines',
        {'resource': 'inventory_issue'},
      );
      when(() => h.issues.confirm(318)).thenAnswer((_) async => throw refusal);
      await h.pumpIssue(tester, anIssue());
      await confirm(tester);
      expect(key('inventory_issue_refusal'), findsOneWidget);

      await tester.tap(key('inventory_issue_confirm'));
      await tester.pumpAndSettle();

      expect(key('inventory_issue_refusal'), findsNothing);
    });

    testWidgets('lock.busy shows its message and re-fetches the issue', (
      tester,
    ) async {
      final refusal = aRefusal(api.ErrorCode.lockPeriodBusy, 'lock.busy', {
        'resource': 'inventory_issue',
      });
      when(() => h.issues.confirm(318)).thenAnswer((_) async => throw refusal);
      await h.pumpIssue(tester, anIssue());
      // Someone else confirmed it meanwhile: the re-fetch shows that.
      h.stubIssue(completed);

      await confirm(tester);

      expect(find.text(localized(refusal)), findsOneWidget);
      verify(() => h.issues.get(318)).called(2);
      expect(title(tester), l10n.inventoryIssueTitle('1043'));
    });
  });

  group('header (US3)', () {
    testWidgets('Editar encabezado is absent on a completed issue and with '
        'no update on 16', (tester) async {
      await h.pumpIssue(tester, completed);
      expect(key('inventory_issue_edit_header'), findsNothing);
    });

    testWidgets('Editar encabezado is absent without update on 16', (
      tester,
    ) async {
      // 1 | 2 | 8: create, read and delete; no update.
      await h.pumpIssue(
        tester,
        anIssue(),
        who: InventoryHarness.issueUser(issues: 1 | 2 | 8),
      );
      expect(key('inventory_issue_edit_header'), findsNothing);
      expect(key('inventory_issue_cancel'), findsOneWidget);
    });

    testWidgets('saving shows the new notes on the screen', (tester) async {
      when(
        () => h.issues.updateHeader(
          318,
          warehouseId: any(named: 'warehouseId'),
          comment: any(named: 'comment'),
          clearComment: any(named: 'clearComment'),
        ),
      ).thenAnswer((_) async => anIssue(comment: 'Consumo interno'));
      await h.pumpIssue(tester, anIssue(comment: 'Merma'));

      await tester.tap(key('inventory_issue_edit_header'));
      await tester.pumpAndSettle();
      await tester.enterText(
        key('inventory_issue_header_comment'),
        'Consumo interno',
      );
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_issue_header_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_issue_header_dialog'), findsNothing);
      expect(find.text('Consumo interno'), findsOneWidget);
    });
  });

  group('cancel (US4)', () {
    Future<void> cancel(WidgetTester tester) async {
      await tester.tap(key('inventory_issue_cancel'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_issue_cancel_submit'));
      await tester.pumpAndSettle();
    }

    testWidgets('is first in the action area', (tester) async {
      await h.pumpIssue(tester, anIssue());

      final buttons = tester
          .widget<Wrap>(
            find.descendant(
              of: key('inventory_issue_actions'),
              matching: find.byType(Wrap),
            ),
          )
          .children;
      expect(buttons.first.key, const Key('inventory_issue_cancel'));
      expect(buttons[1].key, const Key('inventory_issue_edit_header'));
    });

    testWidgets('a draft shows Cancelada afterwards, with no actions', (
      tester,
    ) async {
      when(() => h.issues.cancel(318)).thenAnswer(
        (_) async => anIssue(status: InventoryDocumentStatus.cancelled),
      );
      await h.pumpIssue(tester, anIssue());

      await cancel(tester);

      verify(() => h.issues.cancel(318)).called(1);
      expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
      expect(key('inventory_issue_actions'), findsNothing);
      expect(key('inventory_issue_cancel'), findsNothing);
    });

    testWidgets('a completed issue can be cancelled', (tester) async {
      when(() => h.issues.cancel(318)).thenAnswer(
        (_) async =>
            anIssue(serial: 1043, status: InventoryDocumentStatus.cancelled),
      );
      await h.pumpIssue(tester, completed);

      await cancel(tester);

      expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
      expect(key('inventory_issue_cancel'), findsNothing);
    });

    testWidgets('is absent without delete on 16', (tester) async {
      await h.pumpIssue(
        tester,
        completed,
        who: InventoryHarness.issueUser(issues: 1 | 2 | 4),
      );
      expect(key('inventory_issue_cancel'), findsNothing);
    });

    testWidgets('is absent on a cancelled issue, which has no actions', (
      tester,
    ) async {
      await h.pumpIssue(
        tester,
        anIssue(serial: 1043, status: InventoryDocumentStatus.cancelled),
      );
      expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
      expect(key('inventory_issue_actions'), findsNothing);
    });

    testWidgets('already_cancelled shows its message and re-fetches', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
        'inventory_document.already_cancelled',
        {'resource': 'inventory_issue'},
      );
      when(() => h.issues.cancel(318)).thenAnswer((_) async => throw refusal);
      await h.pumpIssue(tester, completed);
      h.stubIssue(
        anIssue(serial: 1043, status: InventoryDocumentStatus.cancelled),
      );

      await cancel(tester);

      expect(
        find.text('La salida de almacén ya está cancelada.'),
        findsOneWidget,
      );
      expect(find.text(localized(refusal)), findsOneWidget);
      verify(() => h.issues.get(318)).called(2);
      expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
      expect(key('inventory_issue_cancel'), findsNothing);
    });

    testWidgets('a facility.other_facility refusal shows in Spanish', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.facilityPeriodOtherFacility,
        'facility.other_facility',
        {'resource': 'inventory_issue'},
      );
      when(() => h.issues.cancel(318)).thenAnswer((_) async => throw refusal);
      await h.pumpIssue(tester, anIssue());

      await cancel(tester);

      expect(find.text(localized(refusal)), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  });

  group('load', () {
    testWidgets('a missing issue shows the not-found view', (tester) async {
      when(
        () => h.issues.get(9),
      ).thenAnswer((_) async => throw const AppError.notFound());
      h.serveIssues(const []);
      await h.pumpIssues(tester, location: '/inventory/issues/9');

      expect(key('inventory_issue_not_found'), findsOneWidget);
    });

    testWidgets('a failed load offers retry', (tester) async {
      var fail = true;
      when(() => h.issues.get(318)).thenAnswer((_) async {
        if (fail) throw const AppError.network();
        return anIssue();
      });
      h.serveIssues(const []);
      await h.pumpIssues(tester, location: '/inventory/issues/318');

      expect(key('inventory_issue_load_failed'), findsOneWidget);
      fail = false;
      await tester.tap(key('inventory_issue_retry_button'));
      await tester.pumpAndSettle();
      expect(key('inventory_issue_confirm'), findsOneWidget);
    });
  });
}
