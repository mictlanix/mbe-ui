import 'package:flutter/material.dart';
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
import 'package:mbe_ui/features/sales/presentation/orders/order_header_panel.dart';
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
  shipping: false,
  shippingRequiredDocument: false,
  status: EntityStatus.active,
);

const _toggle = Key('sales_order_more_details_toggle');
const _cancel = Key('sales_order_cancel_button');

/// The seven fields spec 032 FR-004 puts behind the disclosure that carry a
/// key of their own. (Contact, delivery details and exchange rate are
/// keyless read-only/picker fields, covered through their labels below.)
const _disclosed = [
  Key('sales_order_priority_field'),
  Key('sales_order_currency_field'),
  Key('sales_order_recipient_field'),
  Key('sales_order_comment_field'),
];

/// Spec 032: the order header reshaped into a fact strip plus four
/// always-relevant fields, with the rest behind one disclosure — and cancel
/// moved out of its own band into the totals bar.
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
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(id: 42, serial: 1001, lines: [testLine()]),
    );
  });

  Future<void> pumpOrder(WidgetTester tester) async {
    await pumpPos(
      tester,
      const OrderScreen(orderId: 42),
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: _updaterUser),
          ),
        ),
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
      ],
    );
    await tester.pumpAndSettle();
  }

  group('the fact strip (US1, FR-002)', () {
    testWidgets('carries reference, status, date and balance as plain '
        'labelled values, not as input controls', (tester) async {
      await pumpOrder(tester);

      // Scoped to the panel: `CustomerBar` carries a "Saldo" of its own —
      // the *customer's* balance, a different figure on the same screen.
      Finder inPanel(String text) => find.descendant(
        of: find.byType(OrderHeaderPanel),
        matching: find.text(text),
      );

      for (final label in [
        l10n.salesOrderReferenceLabel,
        l10n.salesOrderStatusLabel,
        l10n.salesOrderDateLabel,
        l10n.salesOrdersColumnBalance,
      ]) {
        expect(
          inPanel(label.toUpperCase()),
          findsOneWidget,
          reason: '$label should read as a fact-strip label',
        );
        expect(
          inPanel(label),
          findsNothing,
          reason: '$label should no longer be an InputDecoration label',
        );
      }

      expect(inPanel('1001'), findsOneWidget);
      expect(inPanel(posSaleStatusLabelForTest(l10n)), findsOneWidget);
    });
  });

  group('the disclosure (US2, FR-003–FR-006)', () {
    testWidgets('is closed on arrival, with the four always-relevant fields '
        'shown', (tester) async {
      await pumpOrder(tester);

      expect(find.text(l10n.salesOrderDueDateLabel), findsOneWidget);
      expect(find.text(l10n.salesOrderPromiseDateLabel), findsOneWidget);
      expect(find.text(l10n.salesOrderPaymentTermsLabel), findsOneWidget);
      expect(find.byKey(const Key('sales_order_salesperson_field')), findsOneWidget);

      for (final key in _disclosed) {
        expect(find.byKey(key), findsNothing, reason: '$key should be collapsed');
      }
      expect(find.text(l10n.salesOrderContactLabel), findsNothing);
      expect(find.text(l10n.salesOrderShipToLabel), findsNothing);
      expect(find.text(l10n.salesOrderExchangeRateLabel), findsNothing);
      expect(find.text(l10n.salesOrderMoreDetails), findsOneWidget);
    });

    testWidgets('opens and closes, naming where it will take you', (
      tester,
    ) async {
      await pumpOrder(tester);

      await tester.tap(find.byKey(_toggle));
      await tester.pumpAndSettle();

      for (final key in _disclosed) {
        expect(find.byKey(key), findsOneWidget, reason: '$key should be revealed');
      }
      expect(find.text(l10n.salesOrderContactLabel), findsOneWidget);
      expect(find.text(l10n.salesOrderShipToLabel), findsOneWidget);
      expect(find.text(l10n.salesOrderExchangeRateLabel), findsOneWidget);
      expect(find.text(l10n.salesOrderFewerDetails), findsOneWidget);
      expect(find.text(l10n.salesOrderMoreDetails), findsNothing);

      await tester.tap(find.byKey(_toggle));
      await tester.pumpAndSettle();

      expect(find.byKey(_disclosed.first), findsNothing);
      expect(find.text(l10n.salesOrderMoreDetails), findsOneWidget);
    });
  });

  group('the cancel action (US3, FR-013, FR-014)', () {
    testWidgets('rides inside the totals bar, not in a band of its own', (
      tester,
    ) async {
      await pumpOrder(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('pos_totals_footer')),
          matching: find.byKey(_cancel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('pos_totals_footer')),
          matching: find.byKey(const Key('sales_order_confirm_button')),
        ),
        findsOneWidget,
      );
    });
  });
}

/// `posSaleStatusLabel` for the draft `testSale` these tests use — spelled
/// out here rather than importing the widget file for one switch arm.
String posSaleStatusLabelForTest(AppLocalizations l10n) => l10n.posSaleStatusDraft;
