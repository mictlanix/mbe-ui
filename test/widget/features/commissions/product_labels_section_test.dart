import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

const _wide = Size(2200, 1000);
const _path = '/commissions/settings?section=products';

class _MockProducts extends Mock implements ProductRepository {}

const _tornillo = ProductListItem(
  productId: 7,
  code: 'T-7',
  name: 'Tornillo suelto',
  unitOfMeasurementCode: 'H87',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  status: EntityStatus.active,
);

CommissionProductLabel _row(int product, int label) => CommissionProductLabel(
  productId: product,
  productCode: 'P-$product',
  productName: 'Producto $product',
  labelId: label,
);

void main() {
  late CommissionHarness h;
  late _MockProducts products;

  setUpAll(() => registerFallbackValue(EntityStatus.active));

  setUp(() {
    h = CommissionHarness();
    products = _MockProducts();
    when(() => h.repo.listLabels()).thenAnswer(
      (_) async => [
        CommissionLabel(id: 3, name: 'Premium', rate: d('0.05')),
        CommissionLabel(id: 4, name: 'Basica', rate: d('0.01')),
      ],
    );
    when(() => h.repo.listParticipations()).thenAnswer((_) async => []);
    when(() => h.repo.listAgents()).thenAnswer((_) async => []);
    when(
      () => h.repo.listProductLabels(
        labelId: any(named: 'labelId'),
        productId: any(named: 'productId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CommissionProductLabelPage(
        items: [
          _row(1, 3),
          _row(2, 4),
          for (var i = 3; i <= 20; i++) _row(i, 3),
        ],
        total: 45,
      ),
    );
    when(
      () => products.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const ProductListResult(items: [_tornillo], total: 1),
    );
  });

  Future<void> pump(WidgetTester tester, {int commissions = 15}) => h.pump(
    tester,
    who: CommissionHarness.user(commissions: commissions),
    location: _path,
    surface: _wide,
    extraOverrides: [productRepositoryProvider.overrideWithValue(products)],
  );

  Future<void> pickProduct(WidgetTester tester, Finder picker) async {
    await tester.enterText(
      find.descendant(of: picker, matching: find.byType(TextField)),
      'torn',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tornillo suelto').last);
    await tester.pumpAndSettle();
  }

  Future<void> pickLabel(
    WidgetTester tester,
    Finder dropdown,
    String name,
  ) async {
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  void verifyList({int? label, int? product, required int skip}) => verify(
    () => h.repo.listProductLabels(
      labelId: label,
      productId: product,
      skip: skip,
      limit: 20,
    ),
  ).called(1);

  testWidgets('a row shows code, product and the label by name', (
    tester,
  ) async {
    await pump(tester);

    expect(key('commission_product_labels_table'), findsOneWidget);
    expect(find.text('P-1'), findsOneWidget);
    expect(find.text('Producto 1'), findsOneWidget);
    expect(find.text('Premium'), findsWidgets);
    expect(find.text('Basica'), findsOneWidget);
    expect(key('commission_product_label_edit_1'), findsOneWidget);
    // No search box: the endpoint has none.
    expect(find.byType(SearchBar), findsNothing);
    verifyList(skip: 0);
  });

  testWidgets('paging asks the server for the next 20', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    verifyList(skip: 20);
  });

  testWidgets('the Etiqueta and Producto facets filter on the server', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(key('commission_products_filter_button'));
    await tester.pumpAndSettle();
    await pickLabel(tester, key('commission_products_label_filter'), 'Premium');
    verifyList(label: 3, skip: 0);

    await pickProduct(tester, key('commission_products_product_filter'));
    verifyList(label: 3, product: 7, skip: 0);
  });

  testWidgets('"+ Asignar etiqueta" labels a product that has none', (
    tester,
  ) async {
    when(
      () => h.repo.setProductLabel(7, 3),
    ).thenAnswer((_) async => _row(7, 3));
    await pump(tester);

    await tester.tap(key('commission_assign_label_button'));
    await tester.pumpAndSettle();
    expect(key('commission_product_label_note'), findsOneWidget);
    expect(key('commission_product_label_remove'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(key('commission_product_label_submit'))
          .onPressed,
      isNull,
    );
    await pickProduct(tester, key('commission_product_label_product'));
    await pickLabel(tester, key('commission_product_label_label'), 'Premium');
    await tester.tap(key('commission_product_label_submit'));
    await tester.pumpAndSettle();

    verify(() => h.repo.setProductLabel(7, 3)).called(1);
    expect(key('commission_product_label_dialog'), findsNothing);
    // The page is read again.
    verify(
      () => h.repo.listProductLabels(
        labelId: null,
        productId: null,
        skip: 0,
        limit: 20,
      ),
    ).called(2);
  });

  testWidgets('✎ changes the label of a fixed product', (tester) async {
    when(
      () => h.repo.setProductLabel(1, 4),
    ).thenAnswer((_) async => _row(1, 4));
    await pump(tester);

    await tester.tap(key('commission_product_label_edit_1'));
    await tester.pumpAndSettle();
    final product = tester.widget<TextField>(
      find.descendant(
        of: key('commission_product_label_product'),
        matching: find.byType(TextField),
      ),
    );
    expect(product.enabled, isFalse);
    await pickLabel(tester, key('commission_product_label_label'), 'Basica');
    await tester.tap(key('commission_product_label_submit'));
    await tester.pumpAndSettle();

    verify(() => h.repo.setProductLabel(1, 4)).called(1);
  });

  testWidgets('"Quitar etiqueta" removes it', (tester) async {
    when(() => h.repo.removeProductLabel(1)).thenAnswer((_) async {});
    await pump(tester);

    await tester.tap(key('commission_product_label_edit_1'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_product_label_remove'));
    await tester.pumpAndSettle();

    verify(() => h.repo.removeProductLabel(1)).called(1);
    expect(key('commission_product_label_dialog'), findsNothing);
  });

  testWidgets('a refusal stays in the dialog, in our words', (tester) async {
    when(
      () => h.repo.removeProductLabel(1),
    ).thenThrow(aRefusal(api.ErrorCode.authPeriodForbidden, 'auth.forbidden'));
    await pump(tester);

    await tester.tap(key('commission_product_label_edit_1'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_product_label_remove'));
    await tester.pumpAndSettle();

    expect(key('commission_product_label_dialog'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
  });

  testWidgets('Read-only sees the list with no assign and no edit', (
    tester,
  ) async {
    await pump(tester, commissions: 2);

    expect(find.text('Producto 1'), findsOneWidget);
    expect(key('commission_assign_label_button'), findsNothing);
    expect(key('commission_product_label_edit_1'), findsNothing);
  });

  testWidgets('a Create-only user sees no "+ Asignar etiqueta" (it is a PUT)', (
    tester,
  ) async {
    await pump(tester, commissions: 3);

    expect(key('commission_assign_label_button'), findsNothing);
    expect(key('commission_product_label_edit_1'), findsNothing);
  });

  testWidgets('without Delete the dialog has no "Quitar etiqueta"', (
    tester,
  ) async {
    await pump(tester, commissions: 6);

    await tester.tap(key('commission_product_label_edit_1'));
    await tester.pumpAndSettle();

    expect(key('commission_product_label_submit'), findsOneWidget);
    expect(key('commission_product_label_remove'), findsNothing);
  });
}
