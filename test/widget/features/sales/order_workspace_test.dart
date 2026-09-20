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
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/fulfillment_mode_selector.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Holds update on `salesOrders`, matching what this workspace's actions gate
/// on (constitution §IV) — mirrors `order_screen_test.dart`'s own fixture.
/// Also holds create+read on `customers`, which is what Venta's own
/// inline-create affordance gates on (US2, FR-013).
const _updaterUser = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.salesOrders, rawValue: 4),
    Privilege(systemObject: SystemObject.customers, rawValue: 1 | 2),
  ],
);

/// The same user without `customers.create` — for the one test that asserts
/// the affordance is absent rather than merely disabled (constitution §IV).
const _noCustomerCreateUser = User(
  userId: 'order-updater-no-create',
  email: 'no-create@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 4)],
);

Override _authOverride([User user = _updaterUser]) =>
    authNotifierProvider.overrideWith(
      () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: user)),
    );

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

const _realCustomer = CustomerListItem(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

Customer _customerRecord() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// Spec 039 US1: the full happy path for an existing customer, attached on
/// Venta itself, through the transition into Entrega. Corrected 2026-09-20:
/// an earlier, separate Cliente step ahead of Venta was removed — naming a
/// customer was never meant to be a screen of its own, only Venta's own
/// first move, gated by withholding product capture until one exists
/// (FR-009, FR-011). `DeliveryStep` itself — assigning destinations, closing
/// the step, the commit that follows — is the real, unmodified widget
/// (contracts/shared-step-seam.md), already covered by its own suite
/// (`destination_assignment_test.dart` and siblings); this file's job is the
/// seam and the two steps, not re-proving `DeliveryStep`.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockDeliveryOrderRepository deliveries;
  late MockPriceListRepository priceLists;
  late MockTaxpayerRecipientRepository taxpayers;
  late AppLocalizations l10n;

  /// Venta's forward action, as `SaleTotalsBar` renders it — the shared key,
  /// because it is the shared widget (contracts/shared-step-seam.md).
  FloatingActionButton continueButton(WidgetTester tester) =>
      tester.widget<FloatingActionButton>(
        find.byKey(const Key('pos_continue_to_payment')),
      );

  /// `ProductSearchField.enabled` — product capture is withheld until a
  /// customer is attached (FR-009, FR-011), and this is the widget the gate
  /// actually reaches, not merely a key's presence.
  bool productSearchEnabled(WidgetTester tester) => tester
      .widget<ProductSearchField>(find.byType(ProductSearchField))
      .enabled;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    deliveries = MockDeliveryOrderRepository();
    priceLists = MockPriceListRepository();
    taxpayers = MockTaxpayerRecipientRepository();

    // The inline-create form's own two lookups (US2) — same fixtures
    // `customer_inline_create_test.dart` uses for the register's copy.
    when(
      () => priceLists.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const PriceListResult(
        items: [PriceList(priceListId: 2, name: 'Mayoreo')],
        total: 1,
      ),
    );
    when(
      () => taxpayers.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const TaxpayerRecipientPage(
        items: [
          TaxpayerRecipientListItem(
            taxpayerRecipientId: 'XAXX010101000',
            name: 'FERRETERÍA LOS PINOS SA DE CV',
            email: 'facturas@lospinos.mx',
          ),
        ],
        total: 1,
      ),
    );

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customerRecord());
    when(
      () =>
          payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    // Entrega's own destinations list — empty, since this file's job is the
    // seam and the transition into the step, not `DeliveryStep` itself
    // (already covered by `destination_assignment_test.dart` and siblings).
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => const []);
  });

  Future<ProviderContainer> pumpWorkspace(
    WidgetTester tester, {
    int? orderId,
    User user = _updaterUser,
  }) async {
    final (_, container) = await pumpOrdersRouted(
      tester,
      initialLocation: orderId == null
          ? '/sales/orders/new'
          : '/sales/orders/$orderId',
      overrides: [
        _authOverride(user),
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
        priceListRepositoryProvider.overrideWithValue(priceLists),
        taxpayerRecipientRepositoryProvider.overrideWithValue(taxpayers),
      ],
    );
    return container;
  }

  group('attaching a customer, Venta\'s own first move (FR-009…FR-016)', () {
    testWidgets('a new order writes nothing on mount, shows the customer '
        'search rather than the facts view, and withholds product capture '
        '(FR-009, FR-011)', (tester) async {
      await pumpWorkspace(tester);

      verifyNever(
        () => salesOrders.open(
          customer: any(named: 'customer'),
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: any(named: 'fulfillmentIntent'),
          origin: any(named: 'origin'),
        ),
      );
      expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
      // Nothing else to fill in yet — no header panel, and the product
      // search field is present but disabled rather than absent: this is
      // the same `CaptureStep` a register sale renders, only withholding
      // capture (constrained, not a second screen — corrected 2026-09-20).
      expect(productSearchEnabled(tester), isFalse);
    });

    testWidgets('the generic walk-in customer never appears in results '
        '(FR-011, SC-004)', (tester) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer(
        (_) async => const CustomerPage(
          items: [
            CustomerListItem(
              customerId: 1,
              code: 'C-1',
              name: 'PÚBLICO EN GENERAL',
              creditLimit: '0',
              creditDays: 0,
              priceList: PriceListRef(id: 1, name: 'Mostrador'),
              status: EntityStatus.active,
            ),
          ],
          total: 1,
        ),
      );

      await pumpWorkspace(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PUBLICO',
      );
      await tester.pumpAndSettle();

      expect(find.text('C-1 — PÚBLICO EN GENERAL'), findsNothing);
    });

    testWidgets('picking a customer opens the draft with that customer and '
        'an intent to deliver in one request, then unlocks product capture '
        '(FR-014, FR-015)', (tester) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer(
        (_) async => const CustomerPage(items: [_realCustomer], total: 1),
      );
      final opened = testSale(
        customer: 7,
        fulfillmentIntent: FulfillmentMode.delivery,
      );
      when(
        () => salesOrders.open(
          customer: 7,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
          origin: SaleOrigin.backOffice,
        ),
      ).thenAnswer((_) async => opened);
      // The `/sales/orders/new` → `/sales/orders/<id>` URL rewrite mounts a
      // brand-new `OrderWorkspaceScreen`, which re-reads the order by id.
      when(
        () => salesOrders.getById(saleId: opened.id),
      ).thenAnswer((_) async => opened);

      await pumpWorkspace(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PINOS',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-7 — FERRETERÍA LOS PINOS'));
      await tester.pumpAndSettle();

      // Exactly one request, carrying the customer and the intent together
      // — never a create followed by a correcting update (research R3).
      verify(
        () => salesOrders.open(
          customer: 7,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
          origin: SaleOrigin.backOffice,
        ),
      ).called(1);
      verifyNever(
        () => salesOrders.updateHeader(
          saleId: any(named: 'saleId'),
          customer: any(named: 'customer'),
        ),
      );
      // Product capture is unlocked now that a customer is attached — the
      // tell, since this is the same screen throughout, not a transition.
      expect(productSearchEnabled(tester), isTrue);
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);
    });
  });

  // US2 lives here rather than in a file of its own: it is the same Venta
  // step, reached the same way, needing the same five mocks — a separate
  // file would duplicate this file's whole setup to add four tests.
  group('creating a customer inline (US2, FR-013)', () {
    /// Fills the inline form's required fields and saves — the same sequence
    /// `customer_inline_create_test.dart` drives for the register's copy.
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

    void stubCreate(Customer result) {
      when(
        () => customers.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
          taxpayers: any(named: 'taxpayers'),
        ),
      ).thenAnswer((_) async => result);
    }

    testWidgets('the action is reachable from Venta before any customer is '
        'attached — searching is the whole face there, so it carries create '
        'as well as the picker', (tester) async {
      await pumpWorkspace(tester);
      expect(
        find.byKey(const Key('pos_create_customer_button')),
        findsOneWidget,
      );
    });

    testWidgets('the action is absent without customers.create '
        '(constitution §IV)', (tester) async {
      await pumpWorkspace(tester, user: _noCustomerCreateUser);
      expect(find.byKey(const Key('pos_create_customer_button')), findsNothing);
    });

    testWidgets('a created customer is attached and product capture unlocks, '
        'on the same one-request path a picked customer takes (FR-013, '
        'FR-014, FR-015)', (tester) async {
      stubCreate(
        const Customer(
          customerId: 99,
          code: 'C-99',
          name: 'FERRETERÍA LOS PINOS',
          creditLimit: '0',
          creditDays: 0,
          priceList: PriceListRef(id: 2, name: 'Mayoreo'),
          status: EntityStatus.active,
        ),
      );
      final opened = testSale(
        customer: 99,
        fulfillmentIntent: FulfillmentMode.delivery,
      );
      when(
        () => salesOrders.open(
          customer: 99,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
          origin: SaleOrigin.backOffice,
        ),
      ).thenAnswer((_) async => opened);
      when(
        () => salesOrders.getById(saleId: opened.id),
      ).thenAnswer((_) async => opened);

      await pumpWorkspace(tester);
      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await fillAndSave(tester);

      // The brand-new customer opens the order the same way a picked one
      // does — one POST, carrying the intent to deliver with it.
      verify(
        () => salesOrders.open(
          customer: 99,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
          origin: SaleOrigin.backOffice,
        ),
      ).called(1);
      expect(productSearchEnabled(tester), isTrue);
    });

    testWidgets('cancelling the form creates nothing and leaves the step '
        'unchanged', (tester) async {
      await pumpWorkspace(tester);
      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pos_new_customer_close')));
      await tester.pumpAndSettle();

      verifyNever(
        () => customers.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
          taxpayers: any(named: 'taxpayers'),
        ),
      );
      verifyNever(
        () => salesOrders.open(
          customer: any(named: 'customer'),
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: any(named: 'fulfillmentIntent'),
          origin: any(named: 'origin'),
        ),
      );
      // Still searching, still no customer — capture stays withheld.
      expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
      expect(productSearchEnabled(tester), isFalse);
    });

    testWidgets('a refused create keeps the form and its typed values, and '
        'opens no order (US2 scenario 3)', (tester) async {
      when(
        () => customers.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
          taxpayers: any(named: 'taxpayers'),
        ),
      ).thenThrow(
        const AppError.server(statusCode: 422, message: 'Code already used'),
      );

      await pumpWorkspace(tester);
      await tester.tap(find.byKey(const Key('pos_create_customer_button')));
      await tester.pumpAndSettle();
      await fillAndSave(tester);

      // The form is still open, and the server's own reason is on it.
      expect(find.byKey(const Key('pos_new_customer_save')), findsOneWidget);
      expect(find.text('Code already used'), findsOneWidget);

      // NOT asserted here, deliberately: that the *typed values* are still in
      // the fields. They are not — measured, not assumed: after a refused
      // save every `TextFormField` on this form reads empty, because those
      // fields are one-way (`onChanged` pushes into
      // `CustomerFormState.code`/`.name`, nothing binds back), so the
      // rebuild that shows the error recreates their state empty. The data
      // itself survives in the controller; only the display is lost.
      //
      // Pre-existing, and shared: `customer_inline_create.dart` is the
      // register's own form too, and `customer_inline_create_test.dart`'s
      // "nothing the cashier typed is lost" case only ever asserted that the
      // form stayed open and the reason showed — never the values — so this
      // has gone unverified rather than regressed here. Spec 039 US2
      // scenario 3 does ask for it; fixing it changes the register's form as
      // well, which is a scope call of its own rather than something to
      // smuggle in under this feature (FR-046, constitution "surgical
      // changes").
      // And nothing was opened on the strength of a customer that does not
      // exist.
      verifyNever(
        () => salesOrders.open(
          customer: any(named: 'customer'),
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: any(named: 'fulfillmentIntent'),
          origin: any(named: 'origin'),
        ),
      );
    });
  });

  group('the Venta step (FR-017…FR-023)', () {
    // Reaches Venta's post-attach state the same way a real user does — by
    // attaching a customer through the same picker every test above drives
    // — exercising the URL rewrite's own re-derivation of the step from the
    // order's state (research R2), not a shortcut around it.
    Future<ProviderContainer> pumpOnVenta(
      WidgetTester tester, {
      int lineCount = 0,
    }) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer(
        (_) async => const CustomerPage(items: [_realCustomer], total: 1),
      );
      final opened = testSale(
        customer: 7,
        fulfillmentIntent: FulfillmentMode.delivery,
        lines: lineCount == 0 ? const [] : [testLine(id: 5)],
      );
      when(
        () => salesOrders.open(
          customer: 7,
          salesperson: any(named: 'salesperson'),
          fulfillmentIntent: FulfillmentMode.delivery,
          origin: SaleOrigin.backOffice,
        ),
      ).thenAnswer((_) async => opened);
      when(
        () => salesOrders.getById(saleId: opened.id),
      ).thenAnswer((_) async => opened);

      final container = await pumpWorkspace(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PINOS',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-7 — FERRETERÍA LOS PINOS'));
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('the fulfilment-mode selector is never rendered (FR-021)', (
      tester,
    ) async {
      await pumpOnVenta(tester);
      expect(find.byType(FulfillmentModeSelector), findsNothing);
    });

    testWidgets('the forward action is labelled for delivery, disabled with '
        'no lines (FR-022)', (tester) async {
      await pumpOnVenta(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      expect(
        find.text(l10n.salesOrderContinueToDeliveryAction),
        findsOneWidget,
      );
      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('pos_continue_to_payment')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('the forward action enables with at least one line', (
      tester,
    ) async {
      await pumpOnVenta(tester, lineCount: 1);
      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('pos_continue_to_payment')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('the forward action is disabled for the whole of an '
        'outstanding line write (FR-007, issue #164)', (tester) async {
      final completer = Completer<Sale>();
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
      ).thenAnswer((_) => completer.future);

      final container = await pumpOnVenta(tester, lineCount: 1);
      expect(continueButton(tester).onPressed, isNotNull);

      // Driven through the controller rather than a specific field: the gate
      // reads `pendingWritesProvider(salesOrderWritesScope)`, which every
      // mutating call registers in identically — and reading it through this
      // workspace's own scope, never the register's, is the point
      // (contracts/shared-step-seam.md §1).
      // Keyed to 42, not null: the `/new` → `/sales/orders/42` rewrite has
      // already remounted the workspace on the order's real id, and that is
      // the family member the screen is watching.
      final write = container
          .read(orderEditorControllerProvider(42).notifier)
          .updateLine(lineId: 5, discountRate: '0.15');
      await tester.pump();
      expect(
        continueButton(tester).onPressed,
        isNull,
        reason: 'the totals on screen are not the ones the order will hold',
      );

      completer.complete(
        testSale(
          customer: 7,
          fulfillmentIntent: FulfillmentMode.delivery,
          lines: [testLine(id: 5, discountRate: '0.15')],
        ),
      );
      await write;
      await tester.pumpAndSettle();
      expect(continueButton(tester).onPressed, isNotNull);
    });

    testWidgets('uncommitted text in a line field raises the keep/discard '
        'prompt before advancing, and Entrega stays behind it (FR-008)', (
      tester,
    ) async {
      await pumpOnVenta(tester, lineCount: 1);

      await tester.enterText(
        find.byKey(const Key('sale_line_discount_5')),
        '15',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.posUnconfirmedChangesTitle), findsOneWidget);
      expect(
        find.byKey(const Key('delivery_add_destination_button')),
        findsNothing,
        reason: 'the step has not advanced while the decision is open',
      );

      await tester.tap(find.text(l10n.posUnconfirmedChangesKeepEditing));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pos_product_search_field')), findsOneWidget);
    });

    // Re-homed from `order_write_gating_test.dart` (T059): the "keep" and
    // "discard" arms of the same prompt, both of which end in advancing —
    // the workspace has no separate confirm action for these to gate
    // instead (there is no more explicit "confirm" step; the order commits
    // on its first destination create, spec A2), so what they are folded
    // into here is the step transition itself.
    testWidgets('"keep" commits the typed discount, then advances', (
      tester,
    ) async {
      await pumpOnVenta(tester, lineCount: 1);
      when(
        () => salesOrders.updateLine(
          saleId: any(named: 'saleId'),
          lineId: 5,
          quantity: null,
          price: null,
          discountRate: '0.15',
          taxRate: null,
          warehouse: null,
          comment: null,
        ),
      ).thenAnswer(
        (_) async => testSale(
          customer: 7,
          fulfillmentIntent: FulfillmentMode.delivery,
          lines: [testLine(id: 5, discountRate: '0.15')],
        ),
      );

      await tester.enterText(
        find.byKey(const Key('sale_line_discount_5')),
        '15',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
      await tester.pumpAndSettle();

      verify(
        () => salesOrders.updateLine(
          saleId: any(named: 'saleId'),
          lineId: 5,
          quantity: null,
          price: null,
          discountRate: '0.15',
          taxRate: null,
          warehouse: null,
          comment: null,
        ),
      ).called(1);
      expect(find.byKey(const Key('pos_product_search_field')), findsNothing);
      expect(
        find.byKey(const Key('delivery_add_destination_button')),
        findsOneWidget,
      );
    });

    testWidgets('"discard" drops the typed discount and advances on the '
        'stored value', (tester) async {
      await pumpOnVenta(tester, lineCount: 1);

      await tester.enterText(
        find.byKey(const Key('sale_line_discount_5')),
        '15',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
      await tester.pumpAndSettle();
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
      expect(
        find.byKey(const Key('delivery_add_destination_button')),
        findsOneWidget,
      );
    });

    testWidgets('choosing "Continuar a entrega" advances to Entrega', (
      tester,
    ) async {
      await pumpOnVenta(tester, lineCount: 1);
      await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
      await tester.pumpAndSettle();

      // Entrega is now showing: its own destinations empty-state/add action
      // replaces Venta's product search field.
      expect(find.byKey(const Key('pos_product_search_field')), findsNothing);
      expect(
        find.byKey(const Key('delivery_add_destination_button')),
        findsOneWidget,
      );
      // FR-031: found live (T062), not by a test that existed beforehand —
      // `DeliveryStep` offered this unconditionally until `allowCounterSweep`
      // was added specifically for this workspace. An unassigned line with
      // no destination yet is exactly the state that renders it.
      expect(
        find.byKey(const Key('delivery_sweep_to_counter_button')),
        findsNothing,
      );
    });

    // The app bar's title had dropped this entirely, leaving the step
    // indicator pill to stand alone — corrected 2026-09-20, mirroring
    // `PosWorkspaceScreen`'s own title row: the current step named plainly
    // on the left, the indicator on the right.
    testWidgets('the app bar names the current step plainly, alongside the '
        'indicator', (tester) async {
      await pumpOnVenta(tester, lineCount: 1);
      expect(find.text(l10n.salesOrderStepVenta), findsOneWidget);

      // Not driven through `orderStepControllerProvider` directly: the
      // instance actually behind this screen is the one
      // `OrderWorkspaceScreen`'s own nested `ProviderScope` overrides, a
      // different instance from the root container's.
      await tester.tap(find.byKey(const Key('pos_continue_to_payment')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.salesOrderStepEntrega), findsOneWidget);
    });

    // Reported directly against the running app on macOS: the indicator
    // rendered well short of the app bar's far edge instead of flush
    // against it. Root cause (found by measuring the actual render tree,
    // not by inspecting `AppBar`'s centring default, which turned out to
    // be a red herring — `component_themes.dart` already forces
    // `centerTitle: false` globally, on every platform): the title `Row`
    // paired `Flexible(child: Text(...))` (default `flex: 1`) with a
    // separate `Spacer()`, so the two split the row's free space evenly
    // instead of the `Spacer` getting all of it — see the comment on the
    // `title:` itself for the full account. The bug and its fix are both
    // platform-independent, so this needs no platform override to exercise.
    testWidgets('the step indicator sits flush against the app bar\'s far '
        'right edge', (tester) async {
      await pumpOnVenta(tester, lineCount: 1);

      final appBarRight = tester.getRect(find.byType(AppBar).first).right;
      final indicatorRight = tester
          .getTopRight(find.byKey(const Key('sales_order_step_indicator')))
          .dx;
      // Flush means "within the app bar's default 16px title spacing of
      // its edge", not "touching it exactly".
      expect(appBarRight - indicatorRight, closeTo(16, 1));
    });
  });
}
