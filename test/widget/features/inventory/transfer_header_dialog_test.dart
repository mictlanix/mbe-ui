import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 069 US5 (T027): "Editar encabezado" on a draft.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(EntityStatus.active);
    registerFallbackValue(Decimal.zero);
  });

  setUp(() {
    h = InventoryHarness();
    h.serveWarehouses([aWarehouse(3), aWarehouse(4), aWarehouse(5)]);
  });

  Future<void> open(
    WidgetTester tester, {
    InventoryTransfer? transfer,
    User? who,
  }) async {
    await h.pumpTransfer(
      tester,
      transfer ?? aTransfer(comment: 'Reposición'),
      who: who,
    );
    await tester.tap(key('inventory_transfer_edit_header'));
    await tester.pumpAndSettle();
  }

  Finder field(String k) =>
      find.descendant(of: key(k), matching: find.byType(TextField));

  ButtonStyleButton save(WidgetTester tester) =>
      tester.widget<ButtonStyleButton>(key('inventory_transfer_header_submit'));

  Future<void> pick(WidgetTester tester, String k, String name) async {
    await tester.enterText(field(k), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  void stubUpdate() => when(
    () => h.transfers.updateHeader(
      412,
      warehouseId: any(named: 'warehouseId'),
      warehouseToId: any(named: 'warehouseToId'),
      comment: any(named: 'comment'),
      clearComment: any(named: 'clearComment'),
    ),
  ).thenAnswer((_) async => aTransfer(warehouseId: 5, comment: 'Reposición'));

  testWidgets('starts on the current values and Guardar is off until '
      'something changes', (tester) async {
    await open(tester);

    expect(key('inventory_transfer_header_dialog'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(field('inventory_transfer_header_source'))
          .controller!
          .text,
      'Almacén 3',
    );
    expect(
      tester
          .widget<TextField>(field('inventory_transfer_header_destination'))
          .controller!
          .text,
      'Almacén 4',
    );
    expect(save(tester).onPressed, isNull);
  });

  testWidgets('sends only the changed fields', (tester) async {
    stubUpdate();
    await open(tester);

    await pick(tester, 'inventory_transfer_header_source', 'Almacén 5');
    await tester.tap(key('inventory_transfer_header_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.transfers.updateHeader(
        412,
        warehouseId: 5,
        warehouseToId: null,
        comment: null,
        clearComment: false,
      ),
    ).called(1);
    expect(key('inventory_transfer_header_dialog'), findsNothing);
  });

  testWidgets('cleared notes send clearComment', (tester) async {
    stubUpdate();
    await open(tester);

    await tester.enterText(key('inventory_transfer_header_comment'), '');
    await tester.pumpAndSettle();
    await tester.tap(key('inventory_transfer_header_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.transfers.updateHeader(
        412,
        warehouseId: null,
        warehouseToId: null,
        comment: null,
        clearComment: true,
      ),
    ).called(1);
  });

  testWidgets('notes over 500 characters can\'t be saved', (tester) async {
    await open(tester);

    await tester.enterText(key('inventory_transfer_header_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(save(tester).onPressed, isNull);

    await tester.enterText(key('inventory_transfer_header_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(save(tester).onPressed, isNotNull);
  });

  testWidgets('a non-administrator is offered their own facility\'s origins '
      'but every warehouse as destination', (tester) async {
    await open(tester);

    await tester.enterText(field('inventory_transfer_header_source'), 'Alm');
    await tester.pumpAndSettle();
    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: 2,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));

    await tester.enterText(
      field('inventory_transfer_header_destination'),
      'Des',
    );
    await tester.pumpAndSettle();
    verify(
      () => h.warehouses.list(
        search: 'Des',
        facilityId: null,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('without read on Warehouses the warehouses are plain text', (
    tester,
  ) async {
    await open(
      tester,
      who: InventoryHarness.transferUser(warehousesRead: false),
    );

    expect(key('inventory_transfer_header_source'), findsNothing);
    expect(key('inventory_transfer_header_source_text'), findsOneWidget);
    expect(find.text('Almacén 3'), findsWidgets);
    expect(key('inventory_transfer_header_destination_text'), findsOneWidget);
  });

  for (final (code, name) in [
    (
      api.ErrorCode.inventoryTransferPeriodSameWarehouse,
      'inventory_transfer.same_warehouse',
    ),
    (
      api.ErrorCode.warehousePeriodInTransitLocation,
      'warehouse.in_transit_location',
    ),
  ]) {
    testWidgets('$name stays in the dialog', (tester) async {
      final refusal = aRefusal(code, name);
      when(
        () => h.transfers.updateHeader(
          412,
          warehouseId: any(named: 'warehouseId'),
          warehouseToId: any(named: 'warehouseToId'),
          comment: any(named: 'comment'),
          clearComment: any(named: 'clearComment'),
        ),
      ).thenAnswer((_) async => throw refusal);
      await open(tester);

      await pick(tester, 'inventory_transfer_header_destination', 'Almacén 5');
      await tester.tap(key('inventory_transfer_header_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_transfer_header_dialog'), findsOneWidget);
      expect(
        find.text(
          refusal.localizedMessage(l10n, h.container.read(formattersProvider))!,
        ),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  }

  group('Editar encabezado', () {
    testWidgets('is absent on a dispatched transfer', (tester) async {
      await h.pumpTransfer(
        tester,
        aTransfer(serial: 77, status: InventoryTransferStatus.inTransit),
      );

      expect(key('inventory_transfer_edit_header'), findsNothing);
    });

    testWidgets('is absent for a read-only user', (tester) async {
      await h.pumpTransfer(
        tester,
        aTransfer(),
        who: InventoryHarness.transferUser(transfers: 2),
      );

      expect(key('inventory_transfer_edit_header'), findsNothing);
    });
  });
}
