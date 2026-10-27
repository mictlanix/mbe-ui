import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/warehouse_picker_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

Warehouse _warehouse(int id, String name) => Warehouse(
  warehouseId: id,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'WH-$id',
  name: name,
  status: EntityStatus.active,
);

/// spec 047 US4 (C5): the warehouse pop-up.
void main() {
  const longName = 'Almacén central de materiales de construcción y acabados';
  final warehouses = [
    _warehouse(3, 'Principal'),
    _warehouse(4, longName),
    _warehouse(5, 'Sin datos'),
    _warehouse(6, 'Agotado'),
  ];
  const stock = ProductStock(
    warehouses: [
      WarehouseStock(warehouse: 3, onHand: '10', available: '10'),
      WarehouseStock(warehouse: 4, onHand: '2', available: '2'),
      WarehouseStock(warehouse: 6, onHand: '0', available: '0'),
    ],
  );

  Future<ValueNotifier<Object?>> openPicker(
    WidgetTester tester, {
    ProductStock? productStock = stock,
    Size surface = const Size(1200, 2400),
    int? selected = 3,
    List<Warehouse>? localWarehouses,
  }) async {
    final result = ValueNotifier<Object?>('unset');
    await pumpPos(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => result.value = await showWarehousePicker(
            context,
            facilityId: 9,
            warehouses: localWarehouses ?? warehouses,
            selected: selected,
            stock: productStock,
            quantity: Decimal.fromInt(5),
            productName: 'Widget',
          ),
          child: const Text('open'),
        ),
      ),
      surface: surface,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('rows show the full name, stock, unknown and the warnings', (
    tester,
  ) async {
    await openPicker(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.byKey(const Key('warehouse_picker_dialog')), findsOneWidget);
    expect(find.text(longName), findsOneWidget);
    expect(find.text('Widget · 5'), findsOneWidget);
    // Enough for 5: the figure. Short: "only N left". Unknown. Exhausted.
    expect(find.text('10'), findsOneWidget);
    expect(find.text(l10n.posLineWarehouseStockShort('2')), findsOneWidget);
    expect(find.text(l10n.posLineWarehouseStockUnknown), findsOneWidget);
    expect(find.text(l10n.posLineWarehouseStockNone), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber), findsNWidgets(2));
  });

  testWidgets('the current warehouse shows the check', (tester) async {
    await openPicker(tester);

    expect(
      find.descendant(
        of: find.byKey(const Key('warehouse_option_3')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('picking a row returns its id', (tester) async {
    final result = await openPicker(tester);

    await tester.tap(find.byKey(const Key('warehouse_option_4')));
    await tester.pumpAndSettle();

    expect(result.value, 4);
    expect(find.byKey(const Key('warehouse_picker_dialog')), findsNothing);
  });

  testWidgets('cancel returns null', (tester) async {
    final result = await openPicker(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    await tester.tap(find.text(l10n.cancelButton));
    await tester.pumpAndSettle();

    expect(result.value, isNull);
  });

  testWidgets(
    'a product that is not stock-tracked says any warehouse is valid',
    (tester) async {
      await openPicker(
        tester,
        productStock: const ProductStock(stockRequired: false),
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.text(l10n.posWarehousePickerNotTracked), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsNothing);
    },
  );

  testWidgets('at 390 px there is no horizontal scroll or overflow', (
    tester,
  ) async {
    await openPicker(tester, surface: phoneSurface);

    expect(find.text(longName), findsOneWidget);
    expectNoHorizontalScroll(tester);
    expect(tester.takeException(), isNull);
  });

  group('other facilities (spec 048 US3)', () {
    const other = ProductStock(
      warehouses: [
        WarehouseStock(
          warehouse: 3,
          onHand: '10',
          available: '10',
          facilityId: 9,
        ),
        WarehouseStock(
          warehouse: 20,
          warehouseName: 'Bodega Norte',
          facilityId: 2,
          facilityName: 'Norte',
          onHand: '8',
          available: '8',
        ),
        WarehouseStock(
          warehouse: 21,
          warehouseName: 'Vacia',
          facilityId: 2,
          facilityName: 'Norte',
          onHand: '0',
          available: '0',
        ),
      ],
    );

    testWidgets(
      'lists them below the local rows, grouped, and a tap pops the id',
      (tester) async {
        final result = await openPicker(tester, productStock: other);
        final l10n = await AppLocalizations.delegate.load(const Locale('es'));

        expect(
          find.byKey(const Key('warehouse_other_facilities')),
          findsOneWidget,
        );
        expect(
          find.text(l10n.posWarehousePickerOtherFacilities),
          findsOneWidget,
        );
        expect(find.text('Norte'), findsOneWidget);
        expect(find.byKey(const Key('warehouse_other_20')), findsOneWidget);
        // Nothing available and not the current one: not offered.
        expect(find.byKey(const Key('warehouse_other_21')), findsNothing);

        await tester.tap(find.byKey(const Key('warehouse_other_20')));
        await tester.pumpAndSettle();
        expect(result.value, 20);
      },
    );

    testWidgets('a current warehouse in another facility is selected', (
      tester,
    ) async {
      await openPicker(tester, productStock: other, selected: 21);

      expect(
        find.descendant(
          of: find.byKey(const Key('warehouse_other_21')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a current warehouse in neither list is a selected #id row', (
      tester,
    ) async {
      await openPicker(tester, productStock: other, selected: 99);

      expect(find.text('#99'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('warehouse_other_99')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    for (final (label, productStock) in [
      ('a non-stockable product', const ProductStock(stockable: false)),
      ('an uncached product', null),
    ]) {
      testWidgets('$label booked elsewhere still shows its warehouse (#182)', (
        tester,
      ) async {
        await openPicker(tester, productStock: productStock, selected: 77);

        expect(
          find.byKey(const Key('warehouse_other_facilities')),
          findsOneWidget,
        );
        expect(find.text('#77'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('warehouse_other_77')),
            matching: find.byIcon(Icons.check),
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('says so when nothing is available elsewhere', (tester) async {
      await openPicker(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.text(l10n.posWarehousePickerOtherNone), findsOneWidget);
    });

    testWidgets('a non-stockable product shows no other rows', (tester) async {
      await openPicker(
        tester,
        productStock: const ProductStock(
          stockable: false,
          warehouses: [
            WarehouseStock(
              warehouse: 20,
              facilityId: 2,
              facilityName: 'Norte',
              onHand: '8',
              available: '8',
            ),
          ],
        ),
      );

      expect(find.byKey(const Key('warehouse_other_facilities')), findsNothing);
      expect(find.byKey(const Key('warehouse_other_20')), findsNothing);
    });

    testWidgets('a stockable product that needs no check still shows them', (
      tester,
    ) async {
      await openPicker(
        tester,
        productStock: const ProductStock(
          stockRequired: false,
          warehouses: [
            WarehouseStock(
              warehouse: 20,
              warehouseName: 'Bodega Norte',
              facilityId: 2,
              facilityName: 'Norte',
              onHand: '8',
              available: '8',
            ),
          ],
        ),
      );

      expect(find.byKey(const Key('warehouse_other_20')), findsOneWidget);
    });

    testWidgets('a long list scrolls at 390 px', (tester) async {
      await openPicker(
        tester,
        surface: phoneSurface,
        productStock: ProductStock(
          warehouses: [
            for (var i = 0; i < 12; i++)
              WarehouseStock(
                warehouse: 100 + i,
                warehouseName: 'Almacén número $i de la sucursal',
                facilityId: 2 + i % 3,
                facilityName: 'Sucursal ${i % 3}',
                onHand: '8',
                available: '8',
              ),
          ],
        ),
      );

      expect(
        find.byKey(const Key('warehouse_other_facilities')),
        findsOneWidget,
      );
      expectNoHorizontalScroll(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
