import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

/// An administrator, so `can(customers, create)` is true without spelling out
/// a privilege bitmask; the privilege-less case uses an unauthenticated state.
const _cashier = User(
  userId: 'cajero',
  email: 'cajero@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

Customer _customer({
  int id = 7,
  String name = 'PÚBLICO EN GENERAL',
  String priceList = 'Mostrador',
}) => Customer(
  customerId: id,
  code: 'C-$id',
  name: name,
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: priceList),
  shipping: false,
  shippingRequiredDocument: false,
  status: EntityStatus.active,
);

void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockPriceListRepository priceLists;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    priceLists = MockPriceListRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    when(
      () => priceLists.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const PriceListResult(
        items: [
          PriceList(
            priceListId: 2,
            name: 'Mayoreo',
            highProfitMargin: '0.30',
            lowProfitMargin: '0.10',
          ),
        ],
        total: 1,
      ),
    );
  });

  /// Pumps the capture step, which hosts the customer bar and therefore the
  /// create-customer affordance. Driven from `PosSaleController` the way
  /// `PosScreen` drives it, so the sale the server returns after a header
  /// update actually reaches the step.
  Future<void> pumpCapture(
    WidgetTester tester, {
    required Sale sale,
    bool canCreateCustomers = true,
  }) async {
    when(() => salesOrders.open()).thenAnswer((_) async => sale);

    await pumpPos(
      tester,
      Consumer(
        builder: (context, ref, _) => ref
            .watch(posSaleControllerProvider)
            .when(
              data: (value) => CaptureStep(sale: value),
              loading: () => const SizedBox.shrink(),
              error: (error, _) => Text('$error'),
            ),
      ),
      overrides: [
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentRepositoryProvider.overrideWithValue(payments),
        priceListRepositoryProvider.overrideWithValue(priceLists),
        accessControlProvider.overrideWithValue(
          AccessControlService(
            canCreateCustomers
                ? const AuthState.authenticated(token: 't', user: _cashier)
                : const AuthState.unauthenticated(),
          ),
        ),
      ],
    );
  }

  /// Fills the inline form's required fields and saves.
  Future<void> fillAndSave(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('pos_new_customer_code')),
      'C-99',
    );
    await tester.enterText(
      find.byKey(const Key('pos_new_customer_name')),
      'FERRETERÍA LOS PINOS',
    );
    await tester.tap(find.byKey(const Key('pos_new_customer_price_list')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('pos_new_customer_price_list')),
        matching: find.byType(TextField),
      ),
      'May',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mayoreo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pos_new_customer_save')));
    await tester.pumpAndSettle();
  }

  group('creating a customer from the sale (US4)', () {
    testWidgets('the new customer is attached to the sale on save (FR-014)', (
      tester,
    ) async {
      final sale = testSale(lines: [testLine()]);
      when(
        () => customers.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          shipping: any(named: 'shipping'),
          shippingRequiredDocument: any(named: 'shippingRequiredDocument'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => _customer(id: 99, name: 'FERRETERÍA LOS PINOS'));
      when(
        () => salesOrders.updateHeader(
          saleId: any(named: 'saleId'),
          customer: any(named: 'customer'),
          paymentTerms: any(named: 'paymentTerms'),
        ),
      ).thenAnswer((_) async => sale);

      await pumpCapture(tester, sale: sale);
      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await fillAndSave(tester);

      final created = verify(
        () => customers.create(
          code: captureAny(named: 'code'),
          name: captureAny(named: 'name'),
          priceList: captureAny(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          shipping: any(named: 'shipping'),
          shippingRequiredDocument: any(named: 'shippingRequiredDocument'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
        ),
      ).captured;
      expect(created, ['C-99', 'FERRETERÍA LOS PINOS', 2]);

      verify(
        () => salesOrders.updateHeader(saleId: 42, customer: 99),
      ).called(1);
    });

    testWidgets('the sale then shows whatever the server returned — re-priced '
        'lines and totals included (FR-015)', (tester) async {
      final before = testSale(lines: [testLine(price: '50.00')]);
      // The server re-prices against the new customer's list and returns the
      // whole sale; nothing here interprets it.
      final after = testSale(
        lines: [testLine(price: '45.00')],
        total: '104.40',
      );
      when(
        () => customers.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          shipping: any(named: 'shipping'),
          shippingRequiredDocument: any(named: 'shippingRequiredDocument'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => _customer(id: 99, priceList: 'Mayoreo'));
      when(
        () => salesOrders.updateHeader(
          saleId: any(named: 'saleId'),
          customer: any(named: 'customer'),
          paymentTerms: any(named: 'paymentTerms'),
        ),
      ).thenAnswer((_) async => after);
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => after);

      await pumpCapture(tester, sale: before);
      expect(find.text(l10n.posTotalsTotal(r'$116.00')), findsOneWidget);

      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await fillAndSave(tester);

      expect(find.text(l10n.posTotalsTotal(r'$104.40')), findsOneWidget);
      expect(find.text(l10n.posTotalsTotal(r'$116.00')), findsNothing);
    });

    testWidgets('a failed save keeps the form open with the reason, so nothing '
        'the cashier typed is lost', (tester) async {
      when(
        () => customers.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          shipping: any(named: 'shipping'),
          shippingRequiredDocument: any(named: 'shippingRequiredDocument'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(
        const AppError.server(statusCode: 409, message: 'Código duplicado'),
      );

      await pumpCapture(tester, sale: testSale());
      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await fillAndSave(tester);

      expect(find.byKey(const Key('pos_new_customer_save')), findsOneWidget);
      expect(find.text('Código duplicado'), findsOneWidget);
      verifyNever(
        () => salesOrders.updateHeader(
          saleId: any(named: 'saleId'),
          customer: any(named: 'customer'),
        ),
      );
    });

    testWidgets('saving with nothing filled in reports the missing fields '
        'rather than closing', (tester) async {
      await pumpCapture(tester, sale: testSale());
      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pos_new_customer_save')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.customerCodeRequiredError), findsOneWidget);
      expect(find.text(l10n.customerNameRequiredError), findsOneWidget);
      expect(find.byKey(const Key('pos_new_customer_save')), findsOneWidget);
    });

    testWidgets('a cashier without the customers create privilege is not '
        'offered it at all', (tester) async {
      await pumpCapture(
        tester,
        sale: testSale(),
        canCreateCustomers: false,
      );
      expect(find.byKey(const Key('pos_create_customer_button')), findsNothing);
    });
  });
}
