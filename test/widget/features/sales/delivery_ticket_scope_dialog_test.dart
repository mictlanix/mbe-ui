import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_ticket_scope_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Spec 064 US3, contracts U5: the warehouse chooser a multi-warehouse
/// order's "Ver ticket" opens first.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  const warehouses = [
    Warehouse(
      warehouseId: 3,
      facilityId: 1,
      facilityName: 'Centro',
      code: 'B1',
      name: 'Bodega 1',
      status: EntityStatus.active,
    ),
    Warehouse(
      warehouseId: 5,
      facilityId: 1,
      facilityName: 'Centro',
      code: 'P1',
      name: 'Patio',
      status: EntityStatus.active,
    ),
  ];

  /// Pumps a button that opens the chooser and records what it resolved to.
  Future<({List<DeliveryTicketScope?> results})> pump(
    WidgetTester tester, {
    bool namesReadable = true,
    Size surface = const Size(1400, 1000),
    List<int> ids = const [3, 5],
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final results = <DeliveryTicketScope?>[];
    await tester.pumpWidget(
      ProviderScope(
        // No retry, so a refused catalog read settles as an error.
        retry: (_, _) => null,
        overrides: [
          facilityWarehousesControllerProvider.overrideWith(
            (ref, facilityId) async => namesReadable
                ? warehouses
                : throw const AppError.server(statusCode: 403),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: const Key('open'),
                onPressed: () async => results.add(
                  await showDeliveryTicketScopeDialog(
                    context,
                    facilityId: 1,
                    warehouseIds: ids,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    return (results: results);
  }

  Finder key(String k) => find.byKey(Key(k));

  bool selected(WidgetTester tester, String k) {
    final tile = tester.widget<RadioListTile<int?>>(key(k));
    final group = RadioGroup.maybeOf<int?>(tester.element(key(k)));
    return tile.value == group?.groupValue;
  }

  testWidgets('lists "Todos los almacenes" first and selected, then each '
      'warehouse by name', (tester) async {
    await pump(tester);

    expect(find.text(l10n.deliveryTicketScopeTitle), findsOneWidget);
    expect(find.text(l10n.deliveryTicketScopeAll), findsOneWidget);
    expect(find.text('Bodega 1'), findsOneWidget);
    expect(find.text('Patio'), findsOneWidget);
    expect(
      tester.getTopLeft(key('delivery_ticket_scope_all')).dy,
      lessThan(tester.getTopLeft(key('delivery_ticket_scope_3')).dy),
    );
    expect(
      tester.getTopLeft(key('delivery_ticket_scope_3')).dy,
      lessThan(tester.getTopLeft(key('delivery_ticket_scope_5')).dy),
    );
    expect(selected(tester, 'delivery_ticket_scope_all'), isTrue);
    expect(selected(tester, 'delivery_ticket_scope_3'), isFalse);
  });

  testWidgets('lists only the warehouses it is given', (tester) async {
    await pump(tester, ids: const [5, 3]);

    expect(key('delivery_ticket_scope_3'), findsOneWidget);
    expect(key('delivery_ticket_scope_5'), findsOneWidget);
    expect(key('delivery_ticket_scope_9'), findsNothing);
    // First-appearance order is the caller's: 5 before 3.
    expect(
      tester.getTopLeft(key('delivery_ticket_scope_5')).dy,
      lessThan(tester.getTopLeft(key('delivery_ticket_scope_3')).dy),
    );
  });

  testWidgets('a warehouse whose name can\'t be read shows its number', (
    tester,
  ) async {
    await pump(tester, namesReadable: false);

    expect(find.text('#3'), findsOneWidget);
    expect(find.text('#5'), findsOneWidget);
  });

  testWidgets('confirming with nothing picked resolves to every line', (
    tester,
  ) async {
    final run = await pump(tester);

    await tester.tap(key('delivery_ticket_scope_confirm'));
    await tester.pumpAndSettle();

    expect(run.results, hasLength(1));
    expect(run.results.single!.warehouseId, isNull);
    expect(run.results.single!.warehouseName, isNull);
    expect(key('delivery_ticket_scope_dialog'), findsNothing);
  });

  testWidgets('confirming a warehouse resolves to it, with its name', (
    tester,
  ) async {
    final run = await pump(tester);

    await tester.tap(key('delivery_ticket_scope_5'));
    await tester.pump();
    expect(selected(tester, 'delivery_ticket_scope_5'), isTrue);
    expect(selected(tester, 'delivery_ticket_scope_all'), isFalse);
    await tester.tap(key('delivery_ticket_scope_confirm'));
    await tester.pumpAndSettle();

    expect(run.results.single!.warehouseId, 5);
    expect(run.results.single!.warehouseName, 'Patio');
  });

  testWidgets('an unreadable name resolves to its number', (tester) async {
    final run = await pump(tester, namesReadable: false);

    await tester.tap(key('delivery_ticket_scope_3'));
    await tester.pump();
    await tester.tap(key('delivery_ticket_scope_confirm'));
    await tester.pumpAndSettle();

    expect(run.results.single!.warehouseId, 3);
    expect(run.results.single!.warehouseName, '#3');
  });

  testWidgets('"Cancelar" resolves to null', (tester) async {
    final run = await pump(tester);

    await tester.tap(key('delivery_ticket_scope_cancel'));
    await tester.pumpAndSettle();

    expect(run.results, [null]);
  });

  testWidgets('a tap on the barrier resolves to null', (tester) async {
    final run = await pump(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(run.results, [null]);
    expect(key('delivery_ticket_scope_dialog'), findsNothing);
  });

  testWidgets('fits a phone-sized surface with no overflow', (tester) async {
    await pump(tester, surface: const Size(400, 900));

    expect(tester.takeException(), isNull);
    expect(key('delivery_ticket_scope_confirm'), findsOneWidget);
    expect(find.text('Bodega 1'), findsOneWidget);
  });
}
