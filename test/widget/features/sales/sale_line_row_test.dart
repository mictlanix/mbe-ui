import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
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

    testWidgets('removing a line is marked as destructive — the error colour '
        'the rest of the product gives a delete action', (tester) async {
      await pumpRow(tester);

      final delete = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.delete_outline),
          matching: find.byType(IconButton),
        ),
      );
      final scheme = Theme.of(
        tester.element(find.byType(SaleLineRow)),
      ).colorScheme;
      expect(
        delete.style!.foregroundColor!.resolve(const <WidgetState>{}),
        scheme.error,
      );
      // ...and not while it cannot fire: a disabled control should not
      // advertise danger.
      expect(
        delete.style!.foregroundColor!.resolve(const {WidgetState.disabled}),
        isNot(scheme.error),
      );
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

  group('the shared quantity stepper (spec 030 FR-001…FR-006)', () {
    testWidgets('a burst of taps on + coalesces into one write, with the '
        'field following every tap and no control greyed out mid-burst', (
      tester,
    ) async {
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
      ).thenAnswer((_) async => testSale(lines: [testLine(quantity: '6')]));

      final container = await pumpPos(
        tester,
        Consumer(
          builder: (context, ref, _) {
            ref.watch(posSaleControllerProvider);
            return SaleLineRow(line: testLine(quantity: '1'), facilityId: 9);
          },
        ),
        overrides: [
          warehouseOverride(warehouseRepository),
          salesOrderOverride(salesOrder),
        ],
        surface: const Size(1400, 900),
      );
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();

      final addButton = find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(IconButton),
      );
      final quantityField = find.byKey(const Key('sale_line_quantity_5'));

      for (var i = 0; i < 5; i++) {
        await tester.tap(addButton);
        await tester.pump(); // one frame — no time advances, no debounce fires
        expect(
          tester.widget<TextField>(quantityField).controller!.text,
          '${i + 2}',
          reason: 'the field follows every tap immediately',
        );
        // Every control in the band stays live through the burst (SC-002) —
        // the warehouse picker, in particular, since it is what a cashier
        // reaches for mid-burst.
        expect(
          tester
              .widget<DropdownButtonFormField<int>>(
                find.byType(DropdownButtonFormField<int>),
              )
              .onChanged,
          isNotNull,
        );
      }

      // Nothing sent yet — still inside the debounce window.
      verifyNever(
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
      );

      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      verify(
        () => salesOrder.updateLine(
          saleId: any(named: 'saleId'),
          lineId: 5,
          quantity: '6',
          price: null,
          discountRate: null,
          taxRate: null,
          warehouse: null,
          comment: null,
        ),
      ).called(1);
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

  group('the product thumbnail (FR-040, mbe-api#157)', () {
    testWidgets('renders the line\'s own photo — no second call to fetch it', (
      tester,
    ) async {
      await pumpPos(
        tester,
        SaleLineRow(
          line: testLine(photo: 'https://cdn.example.com/images/p-11.jpg'),
          facilityId: 9,
        ),
        overrides: [warehouseOverride(warehouseRepository)],
      );

      expect(
        tester.widget<ProductPhoto>(find.byType(ProductPhoto)).photoUrl,
        'https://cdn.example.com/images/p-11.jpg',
      );
    });

    testWidgets('a product with no photo still reserves the slot, so rows keep '
        'one height', (tester) async {
      await pumpPos(
        tester,
        SaleLineRow(line: testLine(), facilityId: 9),
        overrides: [warehouseOverride(warehouseRepository)],
      );

      expect(
        tester.widget<ProductPhoto>(find.byType(ProductPhoto)).photoUrl,
        isNull,
      );
      // The placeholder occupies the same box a photo would.
      expect(tester.getSize(find.byType(ProductPhoto)), const Size(40, 40));
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

    testWidgets(
        'every control in the band is '
        '${saleLineFieldHeight(TextScaler.noScaling)} tall and '
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
          saleLineFieldHeight(TextScaler.noScaling),
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
    testWidgets(
        'warehouse, quantity, price, discount and tax are all '
        '${saleLineFieldHeight(TextScaler.noScaling)} tall and share one vertical centre', (
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
          saleLineFieldHeight(TextScaler.noScaling),
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

  group('warehouse picker stock flag (US6, FR-020…FR-022, data-model.md §6)', () {
    testWidgets(
      'opening the picker shows the confirmed quantity for a warehouse with '
      'enough stock — silence there used to be visually identical to '
      '"unknown", defeating the point of having checked (live-testing fix)',
      (tester) async {
        await pumpRow(
          tester,
          quantity: '2',
          stock: const {
            11: [WarehouseStock(warehouse: 3, onHand: '10', available: '10')],
          },
        );

        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await tester.pumpAndSettle();

        // Warehouse 3 ("Main Warehouse") is the one with cached stock (10, ≥
        // the ordered 2) — its own figure is shown, not silence. Warehouse 4
        // ("Overflow") was never looked up, so it is fine for it to still
        // read "unknown" — this test is only about warehouse 3's own case.
        expect(find.text('10'), findsOneWidget);
      },
    );

    testWidgets('the closed display stays name-only even when the selected '
        'warehouse itself is short on stock (research R11)', (tester) async {
      // Warehouse 3 is the line's own selected warehouse (testLine's
      // default), so this also exercises the line-level shortfall warning
      // — a second, independent Icons.warning_amber user — without the
      // picker's own closed display picking up a flag alongside it.
      await pumpRow(
        tester,
        quantity: '5',
        stock: const {
          11: [WarehouseStock(warehouse: 3, onHand: '2', available: '2')],
        },
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.text('Main Warehouse'), findsOneWidget);
      expect(find.text(l10n.posLineWarehouseStockShort('2')), findsNothing);
      expect(find.text(l10n.posLineWarehouseStockNone), findsNothing);
      expect(find.text(l10n.posLineWarehouseStockUnknown), findsNothing);
      // Exactly the shortfall row's own icon — the picker added none.
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('opening the picker flags a warehouse with no cached stock '
        'as unknown, never as silently in stock', (tester) async {
      await pumpRow(
        tester,
        quantity: '2',
        stock: const {
          11: [WarehouseStock(warehouse: 3, onHand: '10', available: '10')],
        },
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      // Warehouse 3 has enough stock (2 ≤ 10): no flag at all.
      expect(find.text(l10n.posLineWarehouseStockShort('10')), findsNothing);
      expect(find.text(l10n.posLineWarehouseStockNone), findsNothing);
      // Warehouse 4 ("Overflow") was never looked up this session.
      expect(find.text(l10n.posLineWarehouseStockUnknown), findsOneWidget);
    });

    testWidgets('opening the picker flags an exhausted warehouse as having '
        'no stock, distinct from a partial shortfall', (tester) async {
      await pumpRow(
        tester,
        quantity: '1',
        stock: const {
          11: [WarehouseStock(warehouse: 4, onHand: '0', available: '0')],
        },
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      expect(find.text(l10n.posLineWarehouseStockNone), findsOneWidget);
      expect(find.text(l10n.posLineWarehouseStockShort('0')), findsNothing);
    });

    testWidgets('a warehouse flagged short is still selectable — the flag is '
        'informational, never a block (FR-022)', (tester) async {
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
      ).thenAnswer((_) async => testSale(lines: [testLine(warehouse: 4)]));

      final container = await pumpPos(
        tester,
        Consumer(
          builder: (context, ref, _) {
            ref.watch(posSaleControllerProvider);
            return SaleLineRow(
              line: testLine(quantity: '5'),
              facilityId: 9,
            );
          },
        ),
        overrides: [
          warehouseOverride(warehouseRepository),
          salesOrderOverride(salesOrder),
          productStockCacheProvider.overrideWith(
            (ref) => const {
              11: [WarehouseStock(warehouse: 4, onHand: '2', available: '2')],
            },
          ),
        ],
        surface: const Size(1400, 900),
      );
      await container.read(posSaleControllerProvider.notifier).ensureOpen();
      await tester.pumpAndSettle();
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      // The flagged warehouse's own wording is on screen before it is
      // chosen — an informed choice, not a guess.
      expect(find.text(l10n.posLineWarehouseStockShort('2')), findsOneWidget);

      await tester.tap(find.text('Overflow').last);
      await tester.pumpAndSettle();

      verify(
        () => salesOrder.updateLine(
          saleId: any(named: 'saleId'),
          lineId: 5,
          quantity: null,
          price: null,
          discountRate: null,
          taxRate: null,
          warehouse: 4,
          comment: null,
        ),
      ).called(1);
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

    testWidgets(
      'a real 1024-px window — through CaptureStep, so the step\'s own '
      'margins count against the budget (FR-037a)',
      (tester) async {
        await pumpPos(
          tester,
          CaptureStep(sale: testSale(lines: [testLine()])),
          overrides: [warehouseOverride(warehouseRepository)],
          surface: const Size(1024, 900),
        );
        expect(tester.takeException(), isNull);
        // Pumping `SaleLineRow` on its own says nothing about the insets the
        // step puts around it: aligning the lines list to `screenMargin` cost
        // a line 24 px, which took the tablet under the then-current
        // threshold and silently dropped it to the two-row fallback — a
        // regression no overflow check could have caught, since the fallback
        // lays out perfectly well.
        //
        // Height is what separates the two: the single row is one band, the
        // fallback stacks a second field row under it. Anything at or above
        // the two combined is the fallback.
        expect(
          tester.getSize(find.byType(SaleLineRow)).height,
          lessThan(
            saleLineRowHeight(TextScaler.noScaling) +
                saleLineFieldHeight(TextScaler.noScaling),
          ),
        );
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
