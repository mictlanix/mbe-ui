import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_line_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US5 (T031), FR-015 and research R8: "Editar partida", opened
/// from a draft order line's ✎, and its IVA options.
void main() {
  Decimal d(String s) => Decimal.parse(s);

  group('taxRateOptions', () {
    for (final (current, expected) in [
      ('0.16', ['0', '0.08', '0.16']),
      ('0.08', ['0', '0.08', '0.16']),
      ('0', ['0', '0.08', '0.16']),
      ('0.10', ['0', '0.08', '0.1', '0.16']),
    ]) {
      test('for $current', () {
        expect(taxRateOptions(d(current)), [for (final e in expected) d(e)]);
      });
    }
  });

  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() => h = PurchasesHarness());

  final buyer = PurchasesHarness.user(requestRights: 0, orderRights: 15);

  Future<void> open(WidgetTester tester, {PurchaseOrderLine? line}) async {
    await h.pumpOrder(
      tester,
      anOrder(lines: [line ?? anOrderLine()]),
      who: buyer,
    );
    await tester.tap(key('purchase_order_line_edit_900'));
    await tester.pumpAndSettle();
  }

  void answerUpdate(PurchaseOrder result) => when(
    () => h.orders.updateLine(
      any(),
      any(),
      quantity: any(named: 'quantity'),
      warehouseId: any(named: 'warehouseId'),
      price: any(named: 'price'),
      taxRate: any(named: 'taxRate'),
    ),
  ).thenAnswer((_) async => result);

  String fieldText(WidgetTester tester, String k) =>
      tester.widget<TextField>(key(k)).controller!.text;

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('order_line_submit'));

  Future<void> save(WidgetTester tester) async {
    await tester.tap(key('order_line_submit'));
    await tester.pumpAndSettle();
  }

  Future<void> pickTax(WidgetTester tester, String label) async {
    await tester.tap(key('order_line_tax'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.purchaseOrderTaxRateOption(label)).last);
    await tester.pumpAndSettle();
  }

  testWidgets('is prefilled, and Guardar waits for a change', (tester) async {
    await open(tester);

    expect(key('order_line_dialog'), findsOneWidget);
    expect(find.text('A-100 Tornillo 1/4 caja'), findsOneWidget);
    expect(
      find.descendant(
        of: key('order_line_warehouse'),
        matching: find.text('Almacén 3'),
      ),
      findsOneWidget,
    );
    expect(fieldText(tester, 'order_line_quantity'), '8');
    expect(fieldText(tester, 'order_line_price'), '125.00');
    expect(find.text(l10n.purchaseOrderFieldPriceHelper), findsOneWidget);
    expect(
      find.descendant(
        of: key('order_line_tax'),
        matching: find.text(l10n.purchaseOrderTaxRateOption('16')),
      ),
      findsOneWidget,
    );
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('shows an unrounded price in full and never sends it back '
      'untouched', (tester) async {
    answerUpdate(anOrder());
    await open(tester, line: anOrderLine(price: '25.8333333'));

    expect(fieldText(tester, 'order_line_price'), '25.8333333');

    await tester.enterText(key('order_line_quantity'), '12');
    await tester.pumpAndSettle();
    await save(tester);

    verify(() => h.orders.updateLine(310, 900, quantity: d('12'))).called(1);
  });

  for (final bad in ['0', '1.23456', 'abc']) {
    testWidgets('refuses a quantity of $bad', (tester) async {
      await open(tester);

      await tester.enterText(key('order_line_quantity'), bad);
      await tester.pumpAndSettle();

      expect(find.text(l10n.purchaseOrderQuantityInvalid), findsOneWidget);
      expect(submit(tester).onPressed, isNull);
    });
  }

  for (final bad in ['-1', '1.12345678']) {
    testWidgets('refuses a price of $bad', (tester) async {
      await open(tester);

      await tester.enterText(key('order_line_price'), bad);
      await tester.pumpAndSettle();

      expect(find.text(l10n.purchaseOrderPriceInvalid), findsOneWidget);
      expect(submit(tester).onPressed, isNull);
    });
  }

  testWidgets('accepts a price of 0 and one with 7 decimals', (tester) async {
    await open(tester);

    for (final good in ['0', '1.1234567']) {
      await tester.enterText(key('order_line_price'), good);
      await tester.pumpAndSettle();
      expect(find.text(l10n.purchaseOrderPriceInvalid), findsNothing);
      expect(submit(tester).onPressed, isNotNull);
    }
  });

  testWidgets('sends only the changed price', (tester) async {
    answerUpdate(anOrder());
    await open(tester);

    await tester.enterText(key('order_line_price'), '130.5');
    await tester.pumpAndSettle();
    await save(tester);

    verify(() => h.orders.updateLine(310, 900, price: d('130.5'))).called(1);
    expect(key('order_line_dialog'), findsNothing);
  });

  testWidgets('sends only the changed IVA', (tester) async {
    answerUpdate(anOrder());
    await open(tester);

    await pickTax(tester, '8');
    await save(tester);

    verify(() => h.orders.updateLine(310, 900, taxRate: d('0.08'))).called(1);
  });

  testWidgets('offers an odd current rate alongside the standard ones', (
    tester,
  ) async {
    await open(tester, line: anOrderLine(taxRate: '0.10'));

    await tester.tap(key('order_line_tax'));
    await tester.pumpAndSettle();

    for (final rate in ['0', '0.08', '0.1', '0.16']) {
      expect(key('order_line_tax_$rate'), findsWidgets);
    }
  });

  testWidgets('sends only the changed warehouse, offering every one', (
    tester,
  ) async {
    h.serveWarehouses([aWarehouse(8, facilityId: 9)]);
    answerUpdate(anOrder());
    await open(tester);

    await tester.enterText(
      find.descendant(
        of: key('order_line_warehouse'),
        matching: find.byType(TextField),
      ),
      'Alm',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 8').last);
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: null,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
    verify(() => h.orders.updateLine(310, 900, warehouseId: 8)).called(1);
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.orders.updateLine(
        any(),
        any(),
        quantity: any(named: 'quantity'),
        warehouseId: any(named: 'warehouseId'),
        price: any(named: 'price'),
        taxRate: any(named: 'taxRate'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.warehousePeriodInTransitLocation,
        'warehouse.in_transit_location',
      ),
    );
    await open(tester);

    await tester.enterText(key('order_line_quantity'), '10');
    await tester.pumpAndSettle();
    await save(tester);

    expect(key('order_line_dialog'), findsOneWidget);
    expect(
      find.descendant(
        of: key('order_line_refusal'),
        matching: find.text(l10n.apiErrorWarehouseInTransitLocation),
      ),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
  });
}
