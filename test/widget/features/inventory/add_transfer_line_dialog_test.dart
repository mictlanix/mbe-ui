import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

const _tornillo = ProductListItem(
  productId: 7,
  code: 'A-100',
  name: 'Tornillo 1/4 caja',
  unitOfMeasurementCode: 'H87',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  status: EntityStatus.active,
);

/// Spec 069 US2 (T018): "Agregar producto", opened from a draft's detail.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = InventoryHarness();
    when(
      () => h.products.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const ProductListResult(items: [_tornillo], total: 1),
    );
  });

  Future<void> open(WidgetTester tester) async {
    await h.pumpTransfer(tester, aTransfer(lines: const []));
    await tester.tap(key('inventory_transfer_add_product'));
    await tester.pumpAndSettle();
  }

  Future<void> pickTornillo(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: key('add_transfer_line_product'),
        matching: find.byType(TextField),
      ),
      'torn',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tornillo 1/4 caja').last);
    await tester.pumpAndSettle();
  }

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('add_transfer_line_submit'));

  testWidgets('the picker asks for active, stockable products', (tester) async {
    await open(tester);
    await pickTornillo(tester);

    verify(
      () => h.products.list(
        search: 'torn',
        status: EntityStatus.active,
        stockable: true,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('a quantity of 0 can\'t be submitted', (tester) async {
    await open(tester);
    await pickTornillo(tester);

    await tester.enterText(key('add_transfer_line_quantity'), '0');
    await tester.pumpAndSettle();

    expect(find.text(l10n.inventoryTransferQuantityInvalid), findsOneWidget);
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('adds the product and quantity, then closes', (tester) async {
    when(
      () => h.transfers.addLine(
        412,
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async => aTransfer(lines: [aTransferLine(quantity: '3')]));
    await open(tester);
    await pickTornillo(tester);

    await tester.enterText(key('add_transfer_line_quantity'), '3');
    await tester.pumpAndSettle();
    await tester.tap(key('add_transfer_line_submit'));
    await tester.pumpAndSettle();

    verify(
      () =>
          h.transfers.addLine(412, productId: 7, quantity: Decimal.fromInt(3)),
    ).called(1);
    expect(key('add_transfer_line_dialog'), findsNothing);
    expect(find.text('Tornillo 1/4 caja'), findsOneWidget);
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.transfers.addLine(
        412,
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.productPeriodNotStockable,
        'product.not_stockable',
        {'product_code': 'A-100'},
      ),
    );
    await open(tester);
    await pickTornillo(tester);

    await tester.enterText(key('add_transfer_line_quantity'), '3');
    await tester.pumpAndSettle();
    await tester.tap(key('add_transfer_line_submit'));
    await tester.pumpAndSettle();

    expect(key('add_transfer_line_dialog'), findsOneWidget);
    expect(key('add_transfer_line_refusal'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
  });
}
