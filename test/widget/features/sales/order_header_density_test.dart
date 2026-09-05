import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_header_panel.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_screen.dart';

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
  name: 'GRUPO INDUSTRIAL DEL NORTE SA DE CV',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

const _toggle = Key('sales_order_more_details_toggle');

/// spec 037 US4: the header panel's density, measured rather than eyeballed.
///
/// Constitution §VI requires a non-trivial control band to assert its real
/// insets and baselines with tests, not by inspection — and spec 027's T031 is
/// the cautionary precedent for measuring against a bare `MaterialApp` instead
/// of the app's own theme, which made a layout "fix" that was really a testing
/// artifact. `pumpPos` supplies the real theme, so every measurement here is
/// taken through it.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;

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

  Future<void> pumpOrder(WidgetTester tester, {Size? surface}) async {
    await pumpPos(
      tester,
      const OrderScreen(orderId: 42),
      surface: surface ?? const Size(1440, 2400),
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

  group('the converted fields (FR-016, FR-016a)', () {
    testWidgets('every field but the comment is a CompactField — one '
        'unconverted box would pin its whole row (research R5)', (
      tester,
    ) async {
      await pumpOrder(tester);

      Finder fields() => find.descendant(
        of: find.byType(OrderHeaderPanel),
        matching: find.byType(CompactField),
      );

      // Collapsed: the six on the header row — reference, status, date, due
      // date, promise date, salesperson (FR-016b).
      expect(fields(), findsNWidgets(6));

      await tester.tap(find.byKey(_toggle));
      await tester.pumpAndSettle();

      // Expanded: those six plus priority, currency, exchange rate, tax id,
      // delivery details and contact. The comment is the deliberate exception
      // (FR-016a) — genuinely typed into, so it keeps its text field.
      expect(fields(), findsNWidgets(12));
      expect(
        find.descendant(
          of: find.byType(OrderHeaderPanel),
          matching: find.byKey(const Key('sales_order_comment_field')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the panel is materially shorter expanded than the boxed '
        'layout it replaces (SC-004)', (tester) async {
      await pumpOrder(tester);
      await tester.tap(find.byKey(_toggle));
      await tester.pumpAndSettle();

      final height = tester.getSize(find.byType(OrderHeaderPanel)).height;

      // The pre-feature panel rendered ten boxed fields: a fact strip plus a
      // three-field row, then seven more behind the disclosure, each field a
      // ~56px Material box on its own grid run. Even at three columns that is
      // well over 400px; the converted panel puts six fields on one line and
      // caption-over-value everywhere. 400 is a deliberately loose ceiling —
      // it fails on a regression to boxes, not on a few px of drift.
      expect(
        height,
        lessThan(400),
        reason: 'expanded panel should be materially shorter than the boxed layout',
      );
    });
  });

  group('the compact field shape (constitution §VI)', () {
    testWidgets('caption sits directly above its value, with symmetric '
        'vertical padding inside the card', (tester) async {
      await pumpOrder(tester);

      final theme = Theme.of(tester.element(find.byType(OrderHeaderPanel)));
      final cardPadding = theme.spacing.cardPadding;

      final panelTop = tester.getTopLeft(find.byType(OrderHeaderPanel)).dy;
      final panelBottom = tester.getBottomLeft(find.byType(OrderHeaderPanel)).dy;

      // The first caption and the disclosure control bound the row; the card's
      // own padding must be the same above and below it.
      final firstField = find
          .descendant(
            of: find.byType(OrderHeaderPanel),
            matching: find.byType(CompactField),
          )
          .first;
      final fieldTop = tester.getTopLeft(firstField).dy;
      final toggleBottom = tester.getBottomLeft(find.byKey(_toggle)).dy;

      expect(
        fieldTop - panelTop,
        closeTo(cardPadding, 1),
        reason: 'top inset should be the card padding token',
      );
      expect(
        panelBottom - toggleBottom,
        closeTo(cardPadding, 1),
        reason: 'bottom inset should match the top — symmetric (§VI)',
      );
    });

    testWidgets('the caption is above the value, not beside it', (tester) async {
      await pumpOrder(tester);

      final field = find
          .descendant(
            of: find.byType(OrderHeaderPanel),
            matching: find.byType(CompactField),
          )
          .first;
      final caption = find.descendant(of: field, matching: find.byType(Text)).first;

      expect(
        tester.getTopLeft(caption).dy,
        lessThan(tester.getBottomLeft(field).dy),
      );
      // Caption and value share the field's left edge — a caption-over-value
      // shape, not a label/value pair on one line.
      expect(
        tester.getTopLeft(caption).dx,
        closeTo(tester.getTopLeft(field).dx, 1),
      );
    });
  });
}
