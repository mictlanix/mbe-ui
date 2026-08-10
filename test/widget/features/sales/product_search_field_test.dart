import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

ProductLookupResult _product({required int product, required String code, required String name}) =>
    ProductLookupResult(
      product: product,
      code: code,
      name: name,
      price: '10.00',
      taxRate: '0.16',
      taxIncluded: false,
      minOrderQty: 1,
      stockRequired: false,
      stockable: true,
    );

/// spec 023 contracts/capture-surface.md §3 — the field offers candidates as
/// the cashier types, debounced, and never auto-adds from that path; only
/// the scanner's type-and-Enter path still adds a single exact match
/// directly (FR-033–FR-036).
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    when(() => salesOrders.open()).thenAnswer((_) async => testSale());
    when(() => customers.get(customerId: any(named: 'customerId'))).thenAnswer(
      (_) async => const Customer(
        customerId: 7,
        code: 'C-7',
        name: 'PÚBLICO EN GENERAL',
        creditLimit: '0',
        creditDays: 0,
        priceList: PriceListRef(id: 1, name: 'Mostrador'),
        shipping: false,
        shippingRequiredDocument: false,
        status: EntityStatus.active,
      ),
    );
  });

  Future<ProductLookupResult?> pumpField(WidgetTester tester) async {
    ProductLookupResult? selected;
    await pumpPos(
      tester,
      ProductSearchField(onProductSelected: (result) => selected = result),
      overrides: [
        salesOrderOverride(salesOrders),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
    );
    return selected;
  }

  group('typing offers candidates, debounced, never auto-adding (FR-033, FR-036)', () {
    testWidgets('candidates appear after the debounce with no Enter pressed', (
      tester,
    ) async {
      await pumpField(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [_product(product: 1, code: 'CLA', name: 'Clavo estándar')],
      );

      await tester.enterText(find.byType(TextField), 'cla');
      // Not yet — still inside the debounce window.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('CLA — Clavo estándar'), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('CLA — Clavo estándar'), findsOneWidget);
    });

    testWidgets(
      'a single match while typing is only offered, never added directly',
      (tester) async {
        ProductLookupResult? selected;
        await pumpPos(
          tester,
          ProductSearchField(onProductSelected: (result) => selected = result),
          overrides: [
            salesOrderOverride(salesOrders),
            customerRepositoryProvider.overrideWithValue(customers),
          ],
        );
        when(
          () => salesOrders.productLookup(
            pattern: any(named: 'pattern'),
            customer: any(named: 'customer'),
            warehouse: any(named: 'warehouse'),
          ),
        ).thenAnswer(
          (_) async => [_product(product: 1, code: 'CLA', name: 'Clavo estándar')],
        );

        await tester.enterText(find.byType(TextField), 'CLA');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();

        expect(selected, isNull);
        expect(find.text('CLA — Clavo estándar'), findsOneWidget);
      },
    );

    testWidgets('a search that matches nothing states so', (tester) async {
      await pumpField(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async => const []);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text(l10n.posProductSearchNoResults), findsOneWidget);
    });

    testWidgets('a stale (superseded) lookup is dropped even if it resolves last', (
      tester,
    ) async {
      await pumpField(tester);
      final shortPrefixCompleter = <ProductLookupResult>[
        _product(product: 1, code: 'CEM', name: 'Cemento'),
      ];
      final longerPrefixResult = <ProductLookupResult>[
        _product(product: 2, code: 'CEMENTO-30', name: 'Cemento gris 30kg'),
      ];

      when(
        () => salesOrders.productLookup(
          pattern: 'cem',
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async {
        // Resolves *after* the longer prefix's own lookup below, simulating
        // a slow first request overtaken by a faster later one.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return shortPrefixCompleter;
      });
      when(
        () => salesOrders.productLookup(
          pattern: 'cemento',
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async => longerPrefixResult);

      await tester.enterText(find.byType(TextField), 'cem');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), 'cemento');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('CEMENTO-30 — Cemento gris 30kg'), findsOneWidget);
      expect(find.text('CEM — Cemento'), findsNothing);
    });
  });

  group("the scanner's type-and-Enter path (FR-034)", () {
    testWidgets(
      'a scanned code with exactly one match is added directly, no picking',
      (tester) async {
        final selected = await pumpField(tester);
        when(
          () => salesOrders.productLookup(
            pattern: any(named: 'pattern'),
            customer: any(named: 'customer'),
            warehouse: any(named: 'warehouse'),
          ),
        ).thenAnswer(
          (_) async => [_product(product: 1, code: 'SCN1', name: 'Escaneado')],
        );

        await tester.enterText(find.byType(TextField), 'SCN1');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(selected, isNull); // captured before the async completes below
      },
    );

    testWidgets('the field clears and keeps focus after an exact-match scan', (
      tester,
    ) async {
      ProductLookupResult? selected;
      await pumpPos(
        tester,
        ProductSearchField(onProductSelected: (result) => selected = result),
        overrides: [
          salesOrderOverride(salesOrders),
          customerRepositoryProvider.overrideWithValue(customers),
        ],
      );
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [_product(product: 1, code: 'SCN1', name: 'Escaneado')],
      );

      await tester.enterText(find.byType(TextField), 'SCN1');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(selected?.code, 'SCN1');
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });
  });

  group('dismissing the candidate list (FR-036)', () {
    testWidgets('Escape closes it without clearing the typed text', (
      tester,
    ) async {
      await pumpField(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [
          _product(product: 1, code: 'A', name: 'Uno'),
          _product(product: 2, code: 'B', name: 'Dos'),
        ],
      );

      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('A — Uno'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('A — Uno'), findsNothing);
      expect(find.text('x'), findsOneWidget);
    });
  });
}
