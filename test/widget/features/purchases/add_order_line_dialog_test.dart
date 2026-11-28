import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

const _tornillo = ProductListItem(
  productId: 7,
  code: 'A-100',
  name: 'Tornillo 1/4 caja',
  unitOfMeasurementCode: 'H87',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  status: EntityStatus.active,
);

/// Spec 080 US2 (T019), FR-013–FR-015 and research R8: "Agregar producto",
/// opened from a draft order's detail.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = PurchasesHarness();
    when(
      () => h.products.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        purchasable: any(named: 'purchasable'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const ProductListResult(items: [_tornillo], total: 1),
    );
  });

  final buyer = PurchasesHarness.user(requestRights: 0, orderRights: 15);

  Future<void> open(WidgetTester tester) async {
    await h.pumpOrder(tester, anOrder(lines: const []), who: buyer);
    await tester.tap(key('purchase_order_add_product'));
    await tester.pumpAndSettle();
  }

  Future<void> pickTornillo(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: key('add_order_line_product'),
        matching: find.byType(TextField),
      ),
      'torn',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tornillo 1/4 caja').last);
    await tester.pumpAndSettle();
  }

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('add_order_line_submit'));

  testWidgets('offers only active, purchasable products', (tester) async {
    await open(tester);

    expect(key('add_order_line_dialog'), findsOneWidget);
    expect(submit(tester).onPressed, isNull);
    await pickTornillo(tester);

    verify(
      () => h.products.list(
        search: 'torn',
        status: EntityStatus.active,
        purchasable: true,
        limit: 10,
      ),
    ).called(greaterThan(0));
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('the quantity starts at 1 and must be above 0 with at most 4 '
      'decimals', (tester) async {
    await open(tester);
    await pickTornillo(tester);

    final quantity = key('add_order_line_quantity');
    expect(tester.widget<TextField>(quantity).controller!.text, '1');

    for (final bad in ['0', '1.23456', 'abc']) {
      await tester.enterText(quantity, bad);
      await tester.pumpAndSettle();
      expect(submit(tester).onPressed, isNull, reason: bad);
      expect(find.text(l10n.purchaseOrderQuantityInvalid), findsOneWidget);
    }

    await tester.enterText(quantity, '1.2345');
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
    expect(find.text(l10n.purchaseOrderQuantityInvalid), findsNothing);
  });

  testWidgets('adds the product with its quantity, then closes and shows '
      'the new line', (tester) async {
    when(
      () => h.orders.addLine(
        310,
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async => anOrder(lines: [anOrderLine(quantity: '12')]));
    await open(tester);
    await pickTornillo(tester);

    await tester.enterText(key('add_order_line_quantity'), '12');
    await tester.pumpAndSettle();
    await tester.tap(key('add_order_line_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.orders.addLine(310, productId: 7, quantity: Decimal.fromInt(12)),
    ).called(1);
    expect(key('add_order_line_dialog'), findsNothing);
    expect(key('purchase_order_lines_table'), findsOneWidget);
    expect(
      tester.widget<Text>(key('purchase_order_line_quantity_900')).data,
      '12',
    );
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.orders.addLine(
        310,
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.productPeriodNotPurchasable,
        'product.not_purchasable',
        {'product_code': 'A-100'},
      ),
    );
    await open(tester);
    await pickTornillo(tester);

    await tester.tap(key('add_order_line_submit'));
    await tester.pumpAndSettle();

    expect(key('add_order_line_dialog'), findsOneWidget);
    expect(key('add_order_line_refusal'), findsOneWidget);
    expect(find.text(l10n.apiErrorProductNotPurchasable('A-100')), findsOne);
    expect(find.text('SERVER TEXT'), findsNothing);
  });
}
