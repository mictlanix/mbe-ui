import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

/// The counter-sale journey (US1) driven at 390 px — a phone at the counter.
/// Every control FR-022/FR-028/FR-042 asks for stays reachable by vertical
/// scroll alone, and nothing forces the page sideways (SC-007, FR-053).
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockWarehouseRepository warehouses;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockPaymentMethodOptionRepository paymentOptions;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    warehouses = MockWarehouseRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    paymentOptions = MockPaymentMethodOptionRepository();

    when(
      () => warehouses.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const WarehouseListResult(
        items: [
          Warehouse(
            warehouseId: 3,
            code: 'ALM',
            name: 'Almacén principal',
            facilityId: 9,
            facilityName: 'Matriz',
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
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
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    when(
      () => payments.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => []);
    when(
      () => paymentOptions.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const PaymentMethodOptionPage(items: [], total: 0),
    );
  });

  Future<void> pumpCapture(
    WidgetTester tester, {
    required Sale sale,
    Size surface = phoneSurface,
  }) async {
    when(() => salesOrders.open()).thenAnswer((_) async => sale);
    await pumpPos(
      tester,
      CaptureStep(sale: sale),
      surface: surface,
      overrides: [
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
      ],
    );
  }

  group('the Venta step on a phone (FR-053)', () {
    testWidgets('lines render as stacked cards, not wide rows', (tester) async {
      await pumpCapture(
        tester,
        sale: testSale(lines: [testLine(id: 5), testLine(id: 6)]),
      );

      expect(find.byType(SaleLineCard), findsWidgets);
      expect(find.byType(SaleLineRow), findsNothing);
      expectNoHorizontalScroll(tester);
    });

    testWidgets('the same sale keeps the wide rows above the breakpoint', (
      tester,
    ) async {
      await pumpCapture(
        tester,
        sale: testSale(lines: [testLine()]),
        surface: const Size(1200, 2400),
      );

      expect(find.byType(SaleLineRow), findsOneWidget);
      expect(find.byType(SaleLineCard), findsNothing);
    });

    testWidgets('every field of a line is still editable — nothing is dropped '
        'to make it fit (FR-022)', (tester) async {
      await pumpCapture(tester, sale: testSale(lines: [testLine(unit: 'Pza')]));

      final card = find.byType(SaleLineCard);
      for (final label in [
        l10n.posLineQuantityLabel,
        l10n.posLinePriceLabel,
        l10n.posLineDiscountLabel,
        l10n.posLineTaxLabel,
        l10n.posLineWarehouseLabel,
      ]) {
        expect(
          find.descendant(of: card, matching: find.text(label)),
          findsOneWidget,
          reason: '$label should be present on the compact card',
        );
      }
      // The unit is inline on the quantity field rather than a column of its
      // own, but it is still shown.
      expect(find.descendant(of: card, matching: find.text('Pza')), findsOneWidget);
    });

    testWidgets('the totals and the primary action stay put while the lines '
        'scroll past them (FR-053)', (tester) async {
      await pumpCapture(
        tester,
        sale: testSale(
          lines: [for (var i = 0; i < 8; i++) testLine(id: i + 1)],
        ),
      );

      final action = find.byKey(const Key('pos_continue_to_payment'));
      // Scoped to the footer: every line here also totals $116.00
      // (testLine()'s own default), which would otherwise collide with the
      // grand total's bare figure now that it no longer reads "Total: …".
      final totals = find.descendant(
        of: find.byKey(const Key('pos_totals_footer')),
        matching: find.text(r'$116.00'),
      );
      final actionBefore = tester.getTopLeft(action);
      expect(totals, findsOneWidget);

      await tester.drag(find.byType(SaleLineCard).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(action),
        actionBefore,
        reason: 'the pinned action does not move when the lines scroll',
      );
      expect(totals, findsOneWidget);
      expectNoHorizontalScroll(tester);
    });

    testWidgets('the customer area, mode selector and product search are all '
        'reachable by scrolling down', (tester) async {
      await pumpCapture(
        tester,
        sale: testSale(
          lines: [for (var i = 0; i < 8; i++) testLine(id: i + 1)],
        ),
      );

      // The customer band shows facts by default now, not the picker —
      // spec 023's redesign (customer_bar_test.dart covers the picker
      // itself, reached via Buscar).
      expect(find.byKey(const Key('pos_customer_facts')), findsOneWidget);
      expect(find.text(l10n.posFulfillmentCounter), findsOneWidget);
      expect(find.byType(ProductSearchField), findsOneWidget);

      // …and they scroll away rather than crowding the lines out.
      await tester.drag(find.byType(SaleLineCard).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.byType(SaleLineCard), findsWidgets);
      expectNoHorizontalScroll(tester);
    });
  });

  group('the Cobro step on a phone', () {
    Future<void> pumpPayment(WidgetTester tester, {String balance = '116.00'}) {
      return pumpPos(
        tester,
        PaymentStep(
          sale: testSale(status: SaleStatus.completed, balance: balance),
          onClose: () {},
        ),
        surface: phoneSurface,
        overrides: [
          customerPaymentOverride(payments),
          paymentMethodOptionRepositoryProvider.overrideWithValue(paymentOptions),
        ],
      );
    }

    testWidgets('amount entry, the quick amounts, the method chips and the '
        'number pad are all reachable by vertical scroll alone', (tester) async {
      await pumpPayment(tester);

      expect(find.byKey(const Key('payment_amount_field')), findsOneWidget);
      expect(find.text(l10n.posQuickAmountRemaining), findsOneWidget);
      expect(
        find.byKey(Key('payment_method_${PaymentMethod.cash.code}')),
        findsOneWidget,
      );
      expectNoHorizontalScroll(tester);

      await tester.dragUntilVisible(
        find.byKey(const Key('payment_close_button')),
        find.byType(ListView),
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('payment_close_button')), findsOneWidget);
      expectNoHorizontalScroll(tester);
    });

    testWidgets('the total/paid/balance summary fits without overflowing', (
      tester,
    ) async {
      // Amounts wide enough to crowd a three-column row at 390 px.
      await pumpPayment(tester, balance: '1234567.89');
      expect(find.text(l10n.posPaymentBalance), findsOneWidget);
      expectNoHorizontalScroll(tester);
    });
  });
}
