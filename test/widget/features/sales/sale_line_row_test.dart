import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_layout.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../golden/golden_harness.dart';
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
    testWidgets('quantity and discount are editable on a draft', (tester) async {
      await pumpRow(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      for (final label in [
        l10n.posLineQuantityLabel,
        l10n.posLineDiscountLabel,
      ]) {
        final field = tester.widget<TextField>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(TextField),
          ),
        );
        expect(field.enabled, isTrue, reason: '$label should be editable');
        expect(field.readOnly, isFalse, reason: '$label should be editable');
      }
    });

    testWidgets('the price is shown but never typed over (FR-038c)', (
      tester,
    ) async {
      await pumpRow(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      final price = tester.widget<TextField>(
        find.ancestor(
          of: find.text(l10n.posLinePriceLabel),
          matching: find.byType(TextField),
        ),
      );
      expect(price.readOnly, isTrue);
      // Not merely read-only: it is out of the tab order too, so tabbing
      // through the band never lands on a field that cannot be edited.
      expect(price.canRequestFocus, isFalse);
      expect(price.controller!.text, '50.00');
    });

    testWidgets('the tax rate is chosen from the product\'s rate or none, not '
        'typed (FR-038b)', (tester) async {
      await pumpRow(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // No free-text tax field survives.
      expect(
        find.ancestor(
          of: find.text(l10n.posLineTaxLabel),
          matching: find.byType(TextField),
        ),
        findsNothing,
      );

      expect(find.byKey(const Key('pos_line_tax_rate_picker')), findsOneWidget);
      final picker = tester.widget<DropdownButton<Decimal>>(
        find.byType(DropdownButton<Decimal>),
      );
      // The line carries 0.16 and nothing is cached for its product, so its own
      // rate stands in for the product's — 16 % or nothing, and it starts at 16.
      expect(
        picker.items!.map((item) => item.value).toList(),
        [Decimal.zero, Decimal.parse('0.16')],
      );
      expect(picker.value, Decimal.parse('0.16'));
    });

    testWidgets('the product table\'s own rate is what the picker offers once '
        'the product has been looked up (FR-038b)', (tester) async {
      await pumpPos(
        tester,
        // A line someone already zeroed, whose product looked up at 8 %.
        SaleLineRow(line: testLine(taxRate: '0'), facilityId: 9),
        overrides: [
          warehouseOverride(warehouseRepository),
          productTaxRateCacheProvider.overrideWith(
            (ref) => {11: '0.0800'},
          ),
        ],
      );

      final picker = tester.widget<DropdownButton<Decimal>>(
        find.byType(DropdownButton<Decimal>),
      );
      expect(
        picker.items!.map((item) => item.value).toList(),
        [Decimal.zero, Decimal.parse('0.08')],
      );
      // Rendering it does not rewrite the line: it still reads zero.
      expect(picker.value, Decimal.zero);
    });

    testWidgets('choosing a rate sends it; a refused change leaves the '
        'picker showing the rate the line still has', (tester) async {
      final salesOrder = MockSalesOrderRepository();
      when(() => salesOrder.open()).thenAnswer((_) async => testSale());
      when(
        () => salesOrder.updateLine(
          saleId: any(named: 'saleId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          discountRate: any(named: 'discountRate'),
          taxRate: any(named: 'taxRate'),
          warehouse: any(named: 'warehouse'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(const AppError.server());

      final container = await pumpPos(
        tester,
        // The row itself only ever *reads* the sale controller, so something in
        // the tree has to watch it or the autodispose notifier — and the sale
        // it holds — is gone again before the edit lands.
        Consumer(
          builder: (context, ref, _) {
            ref.watch(posSaleControllerProvider);
            return SaleLineRow(line: testLine(), facilityId: 9);
          },
        ),
        overrides: [
          warehouseOverride(warehouseRepository),
          salesOrderOverride(salesOrder),
        ],
        surface: const Size(1400, 900),
      );
      // The row edits whatever sale the controller holds; without one, the
      // edit never reaches the repository at all.
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();

      // Driven through the button's own callback rather than by opening the
      // menu and tapping: the row renders a '0' in the discount field too, so
      // a text tap picks between two identical labels by tree order.
      tester
          .widget<DropdownButton<Decimal>>(find.byType(DropdownButton<Decimal>))
          .onChanged!(Decimal.zero);
      await tester.pumpAndSettle();

      verify(
        () => salesOrder.updateLine(
          saleId: any(named: 'saleId'),
          lineId: 5,
          quantity: null,
          price: null,
          discountRate: null,
          taxRate: '0',
          warehouse: null,
          comment: null,
        ),
      ).called(1);

      // Refused, so the line is still at 16 % — and so is the picker, which is
      // what the rejection counter behind both pickers' keys buys.
      final picker = tester.widget<DropdownButton<Decimal>>(
        find.byType(DropdownButton<Decimal>),
      );
      expect(picker.value, Decimal.parse('0.16'));
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
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      for (final label in [
        l10n.posLineQuantityLabel,
        l10n.posLineDiscountLabel,
      ]) {
        final field = tester.widget<TextField>(
          find.ancestor(of: find.text(label), matching: find.byType(TextField)),
        );
        expect(field.enabled, isFalse, reason: label);
      }
      // Both pickers refuse a change too.
      expect(
        tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>)).onChanged,
        isNull,
      );
      expect(
        tester
            .widget<DropdownButton<Decimal>>(find.byType(DropdownButton<Decimal>))
            .onChanged,
        isNull,
      );
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
      // 0.1600 stored, offered as a two-decimal percentage — a picker item now
      // rather than a field's text.
      expect(find.text('16.00 %'), findsOneWidget);
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

  // Pumped against the **real app theme** rather than the bare `MaterialApp`
  // the rest of this file uses: the padding that equalises a dropdown against a
  // text field is derived from the body role's line height, so it is the app's
  // own type scale this has to hold under, not the framework's default.
  group('one box height, one baseline, under the real theme (FR-038a)', () {
    setUpAll(loadGoldenFonts);

    testWidgets('every control in the band is $saleLineFieldHeight tall and '
        'every value in it — the line total included — sits on one baseline', (
      tester,
    ) async {
      await pumpGoldenScenario(
        tester,
        SaleLineRow(line: testLine(unit: 'kg'), facilityId: 9),
        brightness: Brightness.dark,
        width: 1440,
        overrides: [warehouseOverride(warehouseRepository)],
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      for (final label in [
        l10n.posLineWarehouseLabel,
        l10n.posLineQuantityWithUnitLabel('kg'),
        l10n.posLinePriceLabel,
        l10n.posLineDiscountLabel,
        l10n.posLineTaxLabel,
      ]) {
        expect(
          tester
              .getSize(
                find.ancestor(
                  of: find.text(label),
                  matching: find.byType(InputDecorator),
                ),
              )
              .height,
          saleLineFieldHeight,
          reason: label,
        );
      }

      // One line box for every value, so one baseline: the two dropdowns, the
      // three text fields and the line total. Compared as rects rather than
      // baselines because `getRect` on the `Text` is the line box itself —
      // equal tops and equal heights *is* an equal baseline.
      final boxes = {
        for (final value in [
          'Main Warehouse', // the warehouse picker's selected item
          '2', // quantity
          '50.00', // price
          '0', // discount
          '16.00 %', // tax
          r'$116.00', // the line total
        ])
          value: tester.getRect(find.text(value).first),
      };
      expect(
        boxes.values.map((r) => (r.top, r.height)).toSet(),
        hasLength(1),
        reason: boxes.toString(),
      );
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
      // Every field FR-022 asks for is still there, in the same form it takes
      // in the single row — nothing was dropped to make the fallback fit, and
      // nothing became free-text that is a picker above.
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      for (final label in [
        l10n.posLineQuantityLabel,
        l10n.posLinePriceLabel,
        l10n.posLineDiscountLabel,
      ]) {
        expect(
          find.ancestor(of: find.text(label), matching: find.byType(TextField)),
          findsOneWidget,
          reason: label,
        );
      }
      expect(find.byKey(const Key('pos_line_tax_rate_picker')), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsOneWidget);
    });
  });
}
