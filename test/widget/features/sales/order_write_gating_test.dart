import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

const _updaterUser = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 4)],
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// The order screen's confirm is a critical action (spec 029 FR-035, FR-036
/// — this feature is spec 031's second adopter, research §R12): unavailable
/// while a write is outstanding, and it resolves unconfirmed typed text
/// before confirming rather than after.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
  });

  void stubUpdateLine(Future<Sale> Function(Invocation) answer) {
    when(
      () => salesOrders.updateLine(
        saleId: any(named: 'saleId'),
        lineId: any(named: 'lineId'),
        quantity: any(named: 'quantity'),
        price: any(named: 'price'),
        discountRate: any(named: 'discountRate'),
        taxRate: any(named: 'taxRate'),
        warehouse: any(named: 'warehouse'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer(answer);
  }

  FloatingActionButton confirmButton(WidgetTester tester) => tester
      .widget<FloatingActionButton>(find.byKey(const Key('sales_order_confirm_button')));

  Future<ProviderContainer> pumpOrder(WidgetTester tester, int orderId) => pumpPos(
    tester,
    OrderScreen(orderId: orderId),
    overrides: [
      authNotifierProvider.overrideWith(
        () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: _updaterUser)),
      ),
      salesOrderOverride(salesOrders),
      warehouseOverride(warehouses),
      customerRepositoryProvider.overrideWithValue(customers),
      customerPaymentOverride(payments),
    ],
    surface: const Size(1400, 900),
  );

  group('outstanding writes (FR-035)', () {
    testWidgets(
      'confirm is disabled while a line write is outstanding, enabled once '
      'settled',
      (tester) async {
        final initial = testSale(id: 42, lines: [testLine(discountRate: '0')]);
        when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => initial);
        final completer = Completer<Sale>();
        stubUpdateLine((_) => completer.future);

        await pumpOrder(tester, 42);
        await tester.pumpAndSettle();
        expect(confirmButton(tester).onPressed, isNotNull);

        await tester.enterText(
          find.byKey(const Key('sale_line_discount_5')),
          '15',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(
          confirmButton(tester).onPressed,
          isNull,
          reason: 'a line write is outstanding — the totals on screen are stale',
        );

        completer.complete(
          testSale(id: 42, lines: [testLine(discountRate: '0.15')]),
        );
        await tester.pumpAndSettle();

        expect(confirmButton(tester).onPressed, isNotNull);
      },
    );
  });

  group('unconfirmed edits (FR-036)', () {
    testWidgets(
      'keep commits the typed discount, then confirms',
      (tester) async {
        final initial = testSale(id: 42, lines: [testLine(discountRate: '0')]);
        when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => initial);
        stubUpdateLine(
          (_) async => testSale(id: 42, lines: [testLine(discountRate: '0.15')]),
        );
        when(() => salesOrders.confirm(saleId: 42)).thenAnswer(
          (_) async => testSale(id: 42, serial: 100, status: SaleStatus.completed),
        );

        await pumpOrder(tester, 42);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('sale_line_discount_5')),
          '15',
        );
        await tester.pump();

        await tester.tap(find.byKey(const Key('sales_order_confirm_button')));
        await tester.pump();

        expect(find.text(l10n.posUnconfirmedChangesTitle), findsOneWidget);

        await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
        await tester.pumpAndSettle();

        verify(
          () => salesOrders.updateLine(
            saleId: 42,
            lineId: 5,
            quantity: null,
            price: null,
            discountRate: '0.15',
            taxRate: null,
            warehouse: null,
            comment: null,
          ),
        ).called(1);
        verify(() => salesOrders.confirm(saleId: 42)).called(1);
      },
    );

    testWidgets(
      'discard drops the typed discount and confirms on the stored value',
      (tester) async {
        final initial = testSale(id: 42, lines: [testLine(discountRate: '0')]);
        when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => initial);
        when(() => salesOrders.confirm(saleId: 42)).thenAnswer(
          (_) async => testSale(id: 42, serial: 100, status: SaleStatus.completed),
        );

        await pumpOrder(tester, 42);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('sale_line_discount_5')),
          '15',
        );
        await tester.pump();

        await tester.tap(find.byKey(const Key('sales_order_confirm_button')));
        await tester.pump();

        await tester.tap(find.text(l10n.posUnconfirmedChangesDiscard));
        await tester.pumpAndSettle();

        verifyNever(
          () => salesOrders.updateLine(
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
        verify(() => salesOrders.confirm(saleId: 42)).called(1);
      },
    );

    testWidgets(
      'keep editing restores the typed text and confirms nothing',
      (tester) async {
        final initial = testSale(id: 42, lines: [testLine(discountRate: '0')]);
        when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => initial);

        await pumpOrder(tester, 42);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('sale_line_discount_5')),
          '15',
        );
        await tester.pump();

        await tester.tap(find.byKey(const Key('sales_order_confirm_button')));
        await tester.pump();

        await tester.tap(find.text(l10n.posUnconfirmedChangesKeepEditing));
        await tester.pumpAndSettle();

        verifyNever(() => salesOrders.confirm(saleId: any(named: 'saleId')));
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('sale_line_discount_5')))
              .controller!
              .text,
          '15',
        );
      },
    );
  });
}
