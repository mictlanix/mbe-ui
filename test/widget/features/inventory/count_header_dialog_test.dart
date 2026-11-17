import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 070 US5 (T030), FR-006: "Editar encabezado", opened from a draft's
/// detail screen. The warehouse goes only when changed; the comment always
/// goes (contracts/repository.md), `null` when cleared.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = InventoryHarness();
    h.serveWarehouses([aWarehouse(3), aWarehouse(4, facilityId: 9)]);
  });

  void answerUpdate([InventoryCount? result]) => when(
    () => h.counts.updateHeader(
      412,
      warehouseId: any(named: 'warehouseId'),
      comment: any(named: 'comment'),
    ),
  ).thenAnswer((_) async => result ?? aCount());

  Future<void> open(
    WidgetTester tester, {
    InventoryCount? count,
    User? who,
  }) async {
    await h.pumpCount(tester, count ?? aCount(comment: 'Pasillo 3'), who: who);
    await tester.tap(key('inventory_count_edit_header'));
    await tester.pumpAndSettle();
  }

  Finder warehouseField() => find.descendant(
    of: key('inventory_count_header_warehouse'),
    matching: find.byType(TextField),
  );

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('inventory_count_header_submit'));

  Future<void> save(WidgetTester tester) async {
    await tester.tap(key('inventory_count_header_submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the count\'s warehouse and comment, and unchanged '
      'can\'t be saved', (tester) async {
    await open(tester);

    expect(key('inventory_count_header_dialog'), findsOneWidget);
    expect(
      tester.widget<Text>(key('responsive_dialog_title')).data,
      l10n.inventoryCountDialogEditTitle,
    );
    expect(
      find.descendant(
        of: key('inventory_count_header_dialog'),
        matching: find.text(l10n.inventoryCountFieldComment),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(warehouseField()).controller!.text,
      'Almacén 3',
    );
    expect(
      tester
          .widget<TextField>(key('inventory_count_header_comment'))
          .controller!
          .text,
      'Pasillo 3',
    );
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('a changed comment is sent without the warehouse', (
    tester,
  ) async {
    answerUpdate(aCount(comment: 'Pasillo 4'));
    await open(tester);

    await tester.enterText(key('inventory_count_header_comment'), 'Pasillo 4');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.counts.updateHeader(412, warehouseId: null, comment: 'Pasillo 4'),
    ).called(1);
    expect(key('inventory_count_header_dialog'), findsNothing);
    expect(find.text('Pasillo 4'), findsOneWidget);
  });

  testWidgets('a changed warehouse is sent, and the unchanged comment is '
      'kept rather than cleared', (tester) async {
    answerUpdate(aCount(warehouseId: 4, comment: 'Pasillo 3'));
    await open(tester);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.counts.updateHeader(412, warehouseId: 4, comment: 'Pasillo 3'),
    ).called(1);
    expect(find.text('Almacén 4'), findsOneWidget);
  });

  testWidgets('a cleared comment is sent as null, which the repository '
      'sends as ""', (tester) async {
    answerUpdate();
    await open(tester);

    await tester.enterText(key('inventory_count_header_comment'), '');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.counts.updateHeader(412, warehouseId: null, comment: null),
    ).called(1);
  });

  testWidgets('a comment over 500 characters can\'t be saved', (tester) async {
    await open(tester);

    await tester.enterText(key('inventory_count_header_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('inventory_count_header_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('without Warehouses (4) read the warehouse is text and the '
      'comment can still be saved', (tester) async {
    answerUpdate();
    await open(tester, who: InventoryHarness.countUser(warehousesRead: false));

    expect(key('inventory_count_header_warehouse'), findsNothing);
    expect(key('inventory_count_header_warehouse_text'), findsOneWidget);
    expect(find.text('Almacén 3'), findsWidgets);

    await tester.enterText(key('inventory_count_header_comment'), 'Nota');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.counts.updateHeader(412, warehouseId: null, comment: 'Nota'),
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
      () => h.counts.updateHeader(
        412,
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
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

    expect(key('inventory_count_header_dialog'), findsOneWidget);
    expect(key('inventory_count_header_refusal'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
    expect(submit(tester).onPressed, isNotNull);
  });
}
