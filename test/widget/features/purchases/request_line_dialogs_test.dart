import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_request_fixtures.dart';
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

/// Spec 079 US1 (T015, T019): "Agregar producto" and "Editar partida",
/// opened from a draft's detail.
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

  group('Agregar producto', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpRequest(tester, aRequest(lines: const []));
      await tester.tap(key('purchase_request_add_product'));
      await tester.pumpAndSettle();
    }

    Future<void> pickTornillo(WidgetTester tester) async {
      await tester.enterText(
        find.descendant(
          of: key('add_request_line_product'),
          matching: find.byType(TextField),
        ),
        'torn',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tornillo 1/4 caja').last);
      await tester.pumpAndSettle();
    }

    testWidgets('asks only for an active, purchasable product', (tester) async {
      await open(tester);

      final dialog = key('add_request_line_dialog');
      expect(
        find.descendant(of: dialog, matching: find.byType(TextField)),
        findsOneWidget,
      );
      await pickTornillo(tester);
      verify(
        () => h.products.list(
          search: 'torn',
          status: EntityStatus.active,
          purchasable: true,
          limit: 10,
        ),
      ).called(greaterThan(0));
    });

    testWidgets('adds the product, then closes and shows the new line', (
      tester,
    ) async {
      when(
        () => h.requests.addLine(212, productId: 7),
      ).thenAnswer((_) async => aRequest(lines: [aRequestLine()]));
      await open(tester);
      await pickTornillo(tester);

      await tester.tap(key('add_request_line_submit'));
      await tester.pumpAndSettle();

      verify(() => h.requests.addLine(212, productId: 7)).called(1);
      expect(key('add_request_line_dialog'), findsNothing);
      expect(key('purchase_request_line_quantity_900'), findsOneWidget);
    });

    testWidgets('a product.not_purchasable refusal shows in Spanish and keeps '
        'the dialog open', (tester) async {
      when(() => h.requests.addLine(212, productId: 7)).thenAnswer(
        (_) async => throw aRefusal(
          api.ErrorCode.productPeriodNotPurchasable,
          'product.not_purchasable',
          {'product_code': 'A-100'},
        ),
      );
      await open(tester);
      await pickTornillo(tester);

      await tester.tap(key('add_request_line_submit'));
      await tester.pumpAndSettle();

      expect(key('add_request_line_dialog'), findsOneWidget);
      expect(key('add_request_line_refusal'), findsOneWidget);
      expect(
        find.textContaining(l10n.apiErrorProductNotPurchasable('A-100')),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  });

  group('Editar partida', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpRequest(
        tester,
        aRequest(lines: [aRequestLine(quantity: '5', minOrderQty: 12)]),
      );
      await tester.tap(key('purchase_request_line_edit_900'));
      await tester.pumpAndSettle();
    }

    FilledButton save(WidgetTester tester) =>
        tester.widget<FilledButton>(key('request_line_submit'));

    testWidgets('is prefilled and shows the "mínimo" helper', (tester) async {
      await open(tester);

      expect(key('request_line_dialog'), findsOneWidget);
      expect(find.text('Tornillo 1/4 caja'), findsWidgets);
      expect(
        find.text(l10n.purchaseRequestQuantityMinimum('12')),
        findsOneWidget,
      );
      // Nothing changed yet.
      expect(save(tester).onPressed, isNull);
    });

    for (final bad in ['0', '-1', '1.234']) {
      testWidgets('refuses a quantity of $bad', (tester) async {
        await open(tester);

        await tester.enterText(key('request_line_quantity'), bad);
        await tester.pumpAndSettle();

        expect(find.text(l10n.purchaseRequestQuantityInvalid), findsOneWidget);
        expect(save(tester).onPressed, isNull);
      });
    }

    testWidgets('accepts two decimals', (tester) async {
      await open(tester);

      await tester.enterText(key('request_line_quantity'), '1.25');
      await tester.pumpAndSettle();

      expect(find.text(l10n.purchaseRequestQuantityInvalid), findsNothing);
      expect(save(tester).onPressed, isNotNull);
    });

    testWidgets('sends only the changed quantity', (tester) async {
      when(
        () => h.requests.updateLine(
          212,
          900,
          quantity: any(named: 'quantity'),
          productName: any(named: 'productName'),
          warehouseId: any(named: 'warehouseId'),
        ),
      ).thenAnswer(
        (_) async =>
            aRequest(lines: [aRequestLine(quantity: '12', minOrderQty: 12)]),
      );
      await open(tester);

      await tester.enterText(key('request_line_quantity'), '12');
      await tester.pumpAndSettle();
      await tester.tap(key('request_line_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.requests.updateLine(212, 900, quantity: Decimal.fromInt(12)),
      ).called(1);
      expect(key('request_line_dialog'), findsNothing);
    });

    testWidgets('sends only the changed name', (tester) async {
      when(
        () => h.requests.updateLine(
          212,
          900,
          quantity: any(named: 'quantity'),
          productName: any(named: 'productName'),
          warehouseId: any(named: 'warehouseId'),
        ),
      ).thenAnswer((_) async => aRequest());
      await open(tester);

      await tester.enterText(key('request_line_name'), 'Tornillo fino');
      await tester.pumpAndSettle();
      await tester.tap(key('request_line_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.requests.updateLine(212, 900, productName: 'Tornillo fino'),
      ).called(1);
    });

    testWidgets('sends only the changed destination, offering every '
        'warehouse', (tester) async {
      h.serveWarehouses([aWarehouse(8, facilityId: 9)]);
      when(
        () => h.requests.updateLine(
          212,
          900,
          quantity: any(named: 'quantity'),
          productName: any(named: 'productName'),
          warehouseId: any(named: 'warehouseId'),
        ),
      ).thenAnswer((_) async => aRequest());
      await open(tester);

      await tester.enterText(
        find.descendant(
          of: key('request_line_destination'),
          matching: find.byType(TextField),
        ),
        'Alm',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Almacén 8').last);
      await tester.pumpAndSettle();
      await tester.tap(key('request_line_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.warehouses.list(
          search: 'Alm',
          facilityId: null,
          status: EntityStatus.active,
          limit: 10,
        ),
      ).called(greaterThan(0));
      verify(() => h.requests.updateLine(212, 900, warehouseId: 8)).called(1);
    });
  });
}
