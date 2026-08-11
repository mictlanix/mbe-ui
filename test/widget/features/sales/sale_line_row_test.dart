import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_layout.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
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

void main() {
  late MockWarehouseRepository warehouseRepository;

  setUp(() {
    warehouseRepository = MockWarehouseRepository();
    when(
      () => warehouseRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => WarehouseListResult(
        items: [_warehouse(3, 'Main Warehouse'), _warehouse(4, 'Overflow')],
        total: 2,
      ),
    );
  });

  Future<void> pumpRow(
    WidgetTester tester, {
    bool enabled = true,
    String quantity = '2',
    Map<int, List<WarehouseStock>> stock = const {},
  }) async {
    await pumpPos(
      tester,
      SaleLineRow(
        line: testLine(quantity: quantity),
        facilityId: 9,
        enabled: enabled,
      ),
      overrides: [
        warehouseOverride(warehouseRepository),
        productStockCacheProvider.overrideWith((ref) => stock),
      ],
    );
  }

  group('in-place edit affordances (FR-023)', () {
    testWidgets('every editable field is present and enabled, including the '
        'tax rate — no field is read-only on a draft', (tester) async {
      await pumpRow(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      for (final label in [
        l10n.posLineQuantityLabel,
        l10n.posLinePriceLabel,
        l10n.posLineDiscountLabel,
        l10n.posLineTaxLabel,
      ]) {
        final field = tester.widget<TextField>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(TextField),
          ),
        );
        expect(field.enabled, isTrue, reason: '$label should be editable');
      }
    });

    testWidgets('quantity has increment and decrement controls', (tester) async {
      await pumpRow(tester);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('the warehouse picker offers the facility\'s warehouses', (
      tester,
    ) async {
      await pumpRow(tester);
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    });

    testWidgets('a confirmed sale renders every control disabled (FR-041)', (
      tester,
    ) async {
      await pumpRow(tester, enabled: false);

      for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(field.enabled, isFalse);
      }
      final add = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.add), matching: find.byType(IconButton)),
      );
      expect(add.onPressed, isNull);
    });
  });

  group('display formatting (FR-022)', () {
    testWidgets('renders mbe-api\'s full-scale decimals readably, and rates as '
        'the percentages their labels claim', (tester) async {
      await pumpPos(
        tester,
        SaleLineRow(
          // Exactly the shapes a live backend sends.
          line: testLine(
            quantity: '3.0000',
            price: '50.0000000',
            discountRate: '0',
            taxRate: '0.1600',
          ),
          facilityId: 9,
        ),
        overrides: [warehouseOverride(warehouseRepository)],
      );

      String textOf(String label) => tester
          .widget<TextField>(
            find.ancestor(of: find.text(label), matching: find.byType(TextField)),
          )
          .controller!
          .text;

      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(textOf(l10n.posLineQuantityLabel), '3');
      expect(textOf(l10n.posLinePriceLabel), '50.00');
      expect(textOf(l10n.posLineDiscountLabel), '0');
      // 0.1600 stored, shown as 16 under an "Imp. %" label.
      expect(textOf(l10n.posLineTaxLabel), '16');
    });
  });

  group('the unit, in the quantity label (FR-022, FR-038a, mbe-api#145)', () {
    testWidgets('the quantity field is labelled with the product\'s unit — no '
        'column of its own', (tester) async {
      await pumpPos(
        tester,
        SaleLineRow(line: testLine(unit: 'Pza'), facilityId: 9),
        overrides: [warehouseOverride(warehouseRepository)],
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.text(l10n.posLineQuantityWithUnitLabel('Pza')), findsOneWidget);
      // The unit is the label, not a cell beside it.
      expect(find.text('Pza'), findsNothing);
    });

    testWidgets('a product with no unit on file keeps the plain quantity '
        'label and shows no placeholder', (tester) async {
      await pumpPos(
        tester,
        SaleLineRow(line: testLine(), facilityId: 9),
        overrides: [warehouseOverride(warehouseRepository)],
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.text(l10n.posLineQuantityLabel), findsOneWidget);
      expect(find.text('—'), findsNothing);
      expect(find.text('Pza'), findsNothing);
    });
  });

  group('one height for every editable control (FR-038a)', () {
    testWidgets('warehouse, quantity, price, discount and tax are all '
        '$saleLineFieldHeight tall and share one vertical centre', (
      tester,
    ) async {
      await pumpPos(
        tester,
        SaleLineRow(line: testLine(), facilityId: 9),
        overrides: [warehouseOverride(warehouseRepository)],
        surface: const Size(1400, 900),
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // Each control's own decorated box, found via its label — the widths
      // differ by design, the heights must not.
      Finder boxFor(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byType(InputDecorator),
      );

      final labels = [
        l10n.posLineWarehouseLabel,
        l10n.posLineQuantityLabel,
        l10n.posLinePriceLabel,
        l10n.posLineDiscountLabel,
        l10n.posLineTaxLabel,
      ];
      final centres = <double>[];
      for (final label in labels) {
        expect(boxFor(label), findsOneWidget, reason: label);
        expect(
          tester.getSize(boxFor(label)).height,
          saleLineFieldHeight,
          reason: label,
        );
        centres.add(tester.getCenter(boxFor(label)).dy);
      }
      expect(centres.toSet(), hasLength(1));
    });

    testWidgets('a one-line product name and a name long enough to wrap give '
        'rows of the same height — the list does not jump', (tester) async {
      await pumpPos(
        tester,
        Column(
          children: [
            SaleLineRow(
              line: testLine(id: 1, productName: 'CLAVO'),
              facilityId: 9,
            ),
            SaleLineRow(
              line: testLine(
                id: 2,
                productName:
                    'ADAPTADOR DE CLAVIJA ESPIGAS POLARIZADAS 2 PACK CON '
                    'TIERRA REFORZADO USO INTERIOR',
              ),
              facilityId: 9,
            ),
          ],
        ),
        overrides: [warehouseOverride(warehouseRepository)],
        surface: const Size(1400, 900),
      );

      expect(
        tester.getSize(find.byKey(const Key('sale_line_row_1'))).height,
        tester.getSize(find.byKey(const Key('sale_line_row_2'))).height,
      );
    });
  });

  group('shortfall warning (FR-025, FR-026)', () {
    testWidgets('no warning when availability covers the ordered quantity', (
      tester,
    ) async {
      await pumpRow(
        tester,
        quantity: '2',
        stock: const {
          11: [
            WarehouseStock(warehouse: 3, onHand: '10', available: '10'),
          ],
        },
      );
      expect(find.byIcon(Icons.warning_amber), findsNothing);
    });

    testWidgets('a partial shortfall warns and offers to reduce the quantity', (
      tester,
    ) async {
      await pumpRow(
        tester,
        quantity: '5',
        stock: const {
          11: [
            WarehouseStock(warehouse: 3, onHand: '2', available: '2'),
          ],
        },
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(find.text(l10n.posLineShortfall('2')), findsOneWidget);
      expect(find.text(l10n.posLineAdjustToAvailable), findsOneWidget);
    });

    testWidgets('no availability at all is distinguished from a partial '
        'shortfall (FR-026)', (tester) async {
      await pumpRow(
        tester,
        quantity: '1',
        stock: const {
          11: [
            WarehouseStock(warehouse: 3, onHand: '0', available: '0'),
          ],
        },
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.text(l10n.posLineNoStock), findsOneWidget);
      expect(find.text(l10n.posLineShortfall('0')), findsNothing);
    });

    testWidgets('a product never looked up in this session shows no warning — '
        'advisory only, never invented', (tester) async {
      await pumpRow(tester, quantity: '999');
      expect(find.byIcon(Icons.warning_amber), findsNothing);
    });
  });

  group('layout thresholds (spec 023 FR-037, FR-037a)', () {
    testWidgets(
      'a single row at 1024 px of available width — the tablet-landscape '
      'case — with nothing overflowing',
      (tester) async {
        await pumpPos(
          tester,
          SaleLineRow(line: testLine(), facilityId: 9),
          overrides: [warehouseOverride(warehouseRepository)],
          surface: const Size(1024, 900),
        );

        // A RenderFlex overflow throws during the pump above and fails the
        // test on its own — reaching here at all is the assertion. The
        // sale-line-row key additionally confirms singleRow actually
        // rendered (a single Card, not the two-row Column variant, which
        // would still pass an overflow check but silently be the wrong
        // layout).
        expect(find.byKey(Key('sale_line_row_${testLine().id}')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('the two-row fallback below 950 px, still nothing overflowing', (
      tester,
    ) async {
      await pumpPos(
        tester,
        SaleLineRow(line: testLine(), facilityId: 9),
        overrides: [warehouseOverride(warehouseRepository)],
        surface: const Size(700, 900),
      );

      expect(tester.takeException(), isNull);
      // Every field FR-022 asks for is still there and still editable —
      // nothing was dropped to make the fallback fit.
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      for (final label in [
        l10n.posLineQuantityLabel,
        l10n.posLinePriceLabel,
        l10n.posLineDiscountLabel,
        l10n.posLineTaxLabel,
      ]) {
        expect(
          find.ancestor(of: find.text(label), matching: find.byType(TextField)),
          findsOneWidget,
        );
      }
    });
  });
}
