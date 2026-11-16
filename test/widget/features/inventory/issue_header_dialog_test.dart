import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_issue_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 068 US3 (T024), FR-006 and research R6: "Editar encabezado", opened
/// from a draft's detail screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = InventoryHarness();
    h.serveWarehouses([aWarehouse(3), aWarehouse(4)]);
  });

  void answerUpdate([InventoryIssue? result]) => when(
    () => h.issues.updateHeader(
      318,
      warehouseId: any(named: 'warehouseId'),
      comment: any(named: 'comment'),
      clearComment: any(named: 'clearComment'),
    ),
  ).thenAnswer((_) async => result ?? anIssue());

  Future<void> open(
    WidgetTester tester, {
    InventoryIssue? issue,
    User? who,
  }) async {
    await h.pumpIssue(
      tester,
      issue ?? anIssue(comment: 'Merma por humedad'),
      who: who,
    );
    await tester.tap(key('inventory_issue_edit_header'));
    await tester.pumpAndSettle();
  }

  Finder warehouseField() => find.descendant(
    of: key('inventory_issue_header_warehouse'),
    matching: find.byType(TextField),
  );

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('inventory_issue_header_submit'));

  Future<void> save(WidgetTester tester) async {
    await tester.tap(key('inventory_issue_header_submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the issue\'s warehouse and notes, and unchanged '
      'can\'t be saved', (tester) async {
    await open(tester);

    expect(key('inventory_issue_header_dialog'), findsOneWidget);
    expect(
      tester.widget<TextField>(warehouseField()).controller!.text,
      'Almacén 3',
    );
    expect(
      tester
          .widget<TextField>(key('inventory_issue_header_comment'))
          .controller!
          .text,
      'Merma por humedad',
    );
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('only the changed notes are sent', (tester) async {
    answerUpdate(anIssue(comment: 'Consumo interno'));
    await open(tester);

    await tester.enterText(
      key('inventory_issue_header_comment'),
      'Consumo interno',
    );
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.issues.updateHeader(
        318,
        warehouseId: null,
        comment: 'Consumo interno',
        clearComment: false,
      ),
    ).called(1);
    expect(key('inventory_issue_header_dialog'), findsNothing);
    expect(find.text('Consumo interno'), findsOneWidget);
  });

  testWidgets('only the changed warehouse is sent', (tester) async {
    answerUpdate(anIssue(warehouseId: 4, comment: 'Merma por humedad'));
    await open(tester);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.issues.updateHeader(
        318,
        warehouseId: 4,
        comment: null,
        clearComment: false,
      ),
    ).called(1);
    expect(find.text('Almacén 4'), findsOneWidget);
  });

  testWidgets('clearing the notes is sent as clearComment', (tester) async {
    answerUpdate();
    await open(tester);

    await tester.enterText(key('inventory_issue_header_comment'), '');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.issues.updateHeader(
        318,
        warehouseId: null,
        comment: null,
        clearComment: true,
      ),
    ).called(1);
  });

  testWidgets('notes over 500 characters can\'t be saved', (tester) async {
    await open(tester);

    await tester.enterText(key('inventory_issue_header_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('inventory_issue_header_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('without Warehouses (4) read the warehouse is text and the '
      'notes can still be saved', (tester) async {
    answerUpdate();
    await open(tester, who: InventoryHarness.issueUser(warehousesRead: false));

    expect(key('inventory_issue_header_warehouse'), findsNothing);
    expect(key('inventory_issue_header_warehouse_text'), findsOneWidget);
    expect(find.text('Almacén 3'), findsWidgets);

    await tester.enterText(key('inventory_issue_header_comment'), 'Nota');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.issues.updateHeader(
        318,
        warehouseId: null,
        comment: 'Nota',
        clearComment: false,
      ),
    ).called(1);
  });

  testWidgets('a non-administrator\'s picker is limited to their facility', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();

    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: 2,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('an in-transit warehouse refusal stays in the dialog, '
      'localized', (tester) async {
    when(
      () => h.issues.updateHeader(
        318,
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
        clearComment: any(named: 'clearComment'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.warehousePeriodInTransitLocation,
        'warehouse.in_transit_location',
        {'warehouse_id': 4},
      ),
    );
    await open(tester);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
    await save(tester);

    expect(key('inventory_issue_header_dialog'), findsOneWidget);
    expect(key('inventory_issue_header_refusal'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
    expect(l10n.inventoryIssueEditHeaderTitle, isNotEmpty);
  });
}
