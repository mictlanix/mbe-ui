import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/customer_bar.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

Customer _customer({String creditLimit = '5000.00', String name = 'PÚBLICO EN GENERAL'}) =>
    Customer(
      customerId: 7,
      code: 'C-7',
      name: name,
      creditLimit: creditLimit,
      creditDays: 30,
      priceList: const PriceListRef(id: 1, name: 'Mostrador'),
      status: EntityStatus.active,
    );

void main() {
  late MockCustomerRepository customerRepository;
  late MockCustomerPaymentRepository paymentRepository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    customerRepository = MockCustomerRepository();
    paymentRepository = MockCustomerPaymentRepository();
    when(
      () => paymentRepository.outstandingBalanceFor(
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => '2091.00');
  });

  Future<void> pumpBar(
    WidgetTester tester, {
    Customer? customer,
    Sale? sale,
  }) async {
    when(
      () => customerRepository.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => customer ?? _customer());

    await pumpPos(
      tester,
      CustomerBar(sale: sale ?? testSale()),
      overrides: [
        customerRepositoryProvider.overrideWithValue(customerRepository),
        customerPaymentRepositoryProvider.overrideWithValue(paymentRepository),
      ],
    );
  }

  group('the facts face, by default (FR-011, FR-022)', () {
    testWidgets('shows the customer name, payment terms and price list', (
      tester,
    ) async {
      await pumpBar(tester);

      expect(find.byKey(const Key('pos_customer_facts')), findsOneWidget);
      expect(find.text('PÚBLICO EN GENERAL'), findsOneWidget);
      expect(find.text('Mostrador'), findsOneWidget);
      expect(find.byKey(const Key('pos_payment_terms_dropdown')), findsOneWidget);
    });

    testWidgets(
      'the resolved customer name is visible even when the sale itself '
      'carries none — the blank-field bug (research R8)',
      (tester) async {
        await pumpBar(
          tester,
          // The walk-in customer on a real sale: `customerName` is null,
          // exactly the case that used to render a blank field.
          sale: testSale(),
          customer: _customer(name: 'PÚBLICO EN GENERAL'),
        );

        expect(find.text('PÚBLICO EN GENERAL'), findsWidgets);
      },
    );

    testWidgets("shows the outstanding balance, summed from the customer's "
        'open orders', (tester) async {
      await pumpBar(tester);
      expect(find.text(r'$2,091.00'), findsOneWidget);
    });

    testWidgets('an unavailable balance leaves the rest of the customer area '
        'intact', (tester) async {
      when(
        () => paymentRepository.outstandingBalanceFor(
          customerId: any(named: 'customerId'),
        ),
      ).thenThrow(Exception('boom'));

      await pumpBar(tester);

      expect(find.text(l10n.posCustomerBalanceLabel), findsNothing);
      expect(find.text('PÚBLICO EN GENERAL'), findsOneWidget);
      expect(find.text('Mostrador'), findsOneWidget);
    });

    testWidgets('a customer whose details cannot be read does not block '
        'capture', (tester) async {
      when(
        () => customerRepository.get(customerId: any(named: 'customerId')),
      ).thenThrow(Exception('boom'));

      await pumpPos(
        tester,
        CustomerBar(sale: testSale()),
        overrides: [
          customerRepositoryProvider.overrideWithValue(customerRepository),
          customerPaymentRepositoryProvider.overrideWithValue(paymentRepository),
        ],
      );

      expect(find.byKey(const Key('pos_customer_facts')), findsOneWidget);
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);
    });

    testWidgets('both actions share the mode selector\'s baseline — one '
        'height for every control in the header row', (tester) async {
      when(
        () => customerRepository.get(customerId: any(named: 'customerId')),
      ).thenAnswer((_) async => _customer());
      await pumpPos(
        tester,
        CustomerBar(sale: testSale()),
        overrides: [
          customerRepositoryProvider.overrideWithValue(customerRepository),
          customerPaymentRepositoryProvider.overrideWithValue(paymentRepository),
          // An administrator short-circuits every privilege check, which is
          // what makes the create action render at all here.
          accessControlProvider.overrideWithValue(
            AccessControlService(
              const AuthState.authenticated(
                token: 't',
                user: User(
                  userId: 'cajero',
                  email: 'cajero@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );

      final search = tester.getSize(
        find.byKey(const Key('pos_customer_search_button')),
      );
      final create = tester.getSize(
        find.byKey(const Key('pos_create_customer_button')),
      );

      // Material's minimum interactive dimension — once the height
      // `SegmentedButton` could not be pushed past, now simply the size the
      // mock gives these two: buttons inside the band, smaller than the band,
      // not peers of the 56 px mode selector beside it.
      expect(search.height, kMinInteractiveDimension);
      expect(create.height, kMinInteractiveDimension);

      // ...and they sit on one line, not offset from each other.
      expect(
        tester.getCenter(find.byKey(const Key('pos_customer_search_button'))).dy,
        tester.getCenter(find.byKey(const Key('pos_create_customer_button'))).dy,
      );
    });
  });

  group('the payment-terms dropdown (FR-028, FR-029, FR-030)', () {
    testWidgets('shows the credit limit as supporting text when the '
        'customer has a credit line', (tester) async {
      await pumpBar(tester, customer: _customer(creditLimit: '5000.00'));

      expect(find.text(r'$5,000.00'), findsOneWidget);
    });

    testWidgets(
      'shows the "no credit line" hint, and Crédito is not selectable, '
      'when the customer has none',
      (tester) async {
        await pumpBar(tester, customer: _customer(creditLimit: '0'));

        expect(find.text(l10n.posCustomerNoCreditHint), findsOneWidget);

        final dropdown = tester.widget<DropdownButton<PaymentTerms>>(
          find.byKey(const Key('pos_payment_terms_dropdown')),
        );
        final creditItem = dropdown.items!.firstWhere(
          (item) => item.value == PaymentTerms.netD,
        );
        expect(creditItem.enabled, isFalse);
      },
    );

    testWidgets('reflects the sale\'s own terms rather than the default', (
      tester,
    ) async {
      await pumpBar(
        tester,
        sale: testSale(paymentTerms: PaymentTerms.netD),
        customer: _customer(creditLimit: '5000.00'),
      );

      final dropdown = tester.widget<DropdownButton<PaymentTerms>>(
        find.byKey(const Key('pos_payment_terms_dropdown')),
      );
      expect(dropdown.value, PaymentTerms.netD);
    });
  });

  group('searching (FR-023, FR-025, FR-026, FR-027)', () {
    testWidgets('Buscar swaps the facts for the customer picker', (
      tester,
    ) async {
      await pumpBar(tester);
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);

      await tester.tap(find.byKey(const Key('pos_customer_search_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pos_customer_facts')), findsNothing);
      expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
    });

    testWidgets('dismissing the search restores the facts, unchanged', (
      tester,
    ) async {
      await pumpBar(tester);
      await tester.tap(find.byKey(const Key('pos_customer_search_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pos_customer_search_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pos_customer_facts')), findsOneWidget);
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);
      expect(find.text('PÚBLICO EN GENERAL'), findsOneWidget);
    });

    testWidgets('picking a customer attaches it and returns to the facts '
        'face', (tester) async {
      when(
        () => customerRepository.list(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => CustomerPage(
          items: [
            const CustomerListItem(
              customerId: 8,
              code: 'C-8',
              name: 'ACME SA DE CV',
              creditLimit: '0',
              creditDays: 0,
              priceList: PriceListRef(id: 1, name: 'Mostrador'),
              status: EntityStatus.active,
            ),
          ],
          total: 1,
        ),
      );

      final sale = testSale();
      await pumpPos(
        tester,
        CustomerBar(sale: sale),
        overrides: [
          customerRepositoryProvider.overrideWithValue(customerRepository),
          customerPaymentRepositoryProvider.overrideWithValue(paymentRepository),
          salesOrderOverride(_updateHeaderStub(sale)),
        ],
      );
      when(
        () => customerRepository.get(customerId: any(named: 'customerId')),
      ).thenAnswer((_) async => _customer());

      await tester.tap(find.byKey(const Key('pos_customer_search_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('pos_customer_picker')), 'ACME');
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-8 — ACME SA DE CV'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pos_customer_facts')), findsOneWidget);
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);
    });

    testWidgets(
      // spec 036 FR-017: selecting a customer with an associated salesperson
      // prefills it in the same write that attaches the customer.
      'picking a customer with an associated salesperson autofills it',
      (tester) async {
        when(
          () => customerRepository.list(
            search: any(named: 'search'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const CustomerPage(
            items: [
              CustomerListItem(
                customerId: 8,
                code: 'C-8',
                name: 'ACME SA DE CV',
                creditLimit: '0',
                creditDays: 0,
                priceList: PriceListRef(id: 1, name: 'Mostrador'),
                salesperson: EmployeeRef(id: 20, name: 'Jane Doe'),
                status: EntityStatus.active,
              ),
            ],
            total: 1,
          ),
        );

        final sale = testSale();
        final salesOrder = _updateHeaderStub(sale, newCustomer: 8);
        await pumpPos(
          tester,
          CustomerBar(sale: sale),
          overrides: [
            customerRepositoryProvider.overrideWithValue(customerRepository),
            customerPaymentRepositoryProvider.overrideWithValue(
              paymentRepository,
            ),
            salesOrderOverride(salesOrder),
          ],
        );
        when(
          () => customerRepository.get(customerId: any(named: 'customerId')),
        ).thenAnswer((_) async => _customer());

        await tester.tap(find.byKey(const Key('pos_customer_search_button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('pos_customer_picker')),
          'ACME',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('C-8 — ACME SA DE CV'));
        await tester.pumpAndSettle();

        verify(
          () => salesOrder.updateHeader(
            saleId: any(named: 'saleId'),
            customer: 8,
            paymentTerms: null,
            currency: any(named: 'currency'),
            shipTo: any(named: 'shipTo'),
            contact: any(named: 'contact'),
            customerName: any(named: 'customerName'),
            salesperson: 20,
            fulfillmentIntent: null,
          ),
        ).called(1);
      },
    );

    testWidgets(
      // spec 036 FR-019: a customer with no associated salesperson leaves
      // the field unchanged, rather than clearing whatever it held.
      'picking a customer with no associated salesperson leaves the field '
      'unchanged',
      (tester) async {
        when(
          () => customerRepository.list(
            search: any(named: 'search'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const CustomerPage(
            items: [
              CustomerListItem(
                customerId: 9,
                code: 'C-9',
                name: 'BETA LLC',
                creditLimit: '0',
                creditDays: 0,
                priceList: PriceListRef(id: 1, name: 'Mostrador'),
                status: EntityStatus.active,
              ),
            ],
            total: 1,
          ),
        );

        final sale = testSale();
        final salesOrder = _updateHeaderStub(sale, newCustomer: 9);
        await pumpPos(
          tester,
          CustomerBar(sale: sale),
          overrides: [
            customerRepositoryProvider.overrideWithValue(customerRepository),
            customerPaymentRepositoryProvider.overrideWithValue(
              paymentRepository,
            ),
            salesOrderOverride(salesOrder),
          ],
        );
        when(
          () => customerRepository.get(customerId: any(named: 'customerId')),
        ).thenAnswer((_) async => _customer());

        await tester.tap(find.byKey(const Key('pos_customer_search_button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('pos_customer_picker')),
          'BETA',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('C-9 — BETA LLC'));
        await tester.pumpAndSettle();

        verify(
          () => salesOrder.updateHeader(
            saleId: any(named: 'saleId'),
            customer: 9,
            paymentTerms: null,
            currency: any(named: 'currency'),
            shipTo: any(named: 'shipTo'),
            contact: any(named: 'contact'),
            customerName: any(named: 'customerName'),
            salesperson: null,
            fulfillmentIntent: null,
          ),
        ).called(1);
      },
    );

    testWidgets(
      // spec 036 FR-016: switching to the generic "Público en General"
      // customer (id 1, matching `posDefaultCustomerId`'s test default) while
      // the sale is in delivery/mixed mode resets it to pickup-only and
      // notifies the user.
      'picking the generic customer while in delivery mode resets to pickup '
      'and notifies the user',
      (tester) async {
        when(
          () => customerRepository.list(
            search: any(named: 'search'),
            limit: any(named: 'limit'),
          ),
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

        final sale = testSale(
          customer: 7,
          fulfillmentIntent: FulfillmentMode.delivery,
        );
        final salesOrder = _updateHeaderStub(sale, newCustomer: 1);
        await pumpPos(
          tester,
          CustomerBar(sale: sale),
          overrides: [
            customerRepositoryProvider.overrideWithValue(customerRepository),
            customerPaymentRepositoryProvider.overrideWithValue(
              paymentRepository,
            ),
            salesOrderOverride(salesOrder),
          ],
        );
        when(
          () => customerRepository.get(customerId: any(named: 'customerId')),
        ).thenAnswer((_) async => _customer());

        await tester.tap(find.byKey(const Key('pos_customer_search_button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('pos_customer_picker')),
          'PUBLICO',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('C-1 — PÚBLICO EN GENERAL'));
        await tester.pumpAndSettle();

        verify(
          () => salesOrder.updateHeader(
            saleId: any(named: 'saleId'),
            customer: 1,
            paymentTerms: null,
            currency: any(named: 'currency'),
            shipTo: any(named: 'shipTo'),
            contact: any(named: 'contact'),
            customerName: any(named: 'customerName'),
            fulfillmentIntent: FulfillmentMode.counterPickup,
          ),
        ).called(1);
        expect(
          find.byKey(const Key('pos_generic_customer_pickup_reset_notice')),
          findsOneWidget,
        );
      },
    );
  });
}

/// A `SalesOrderRepository` stubbed just enough for `updateHeader` to
/// answer with [sale] carrying [newCustomer] — the rest of the interface is
/// never called by this test.
MockSalesOrderRepository _updateHeaderStub(Sale sale, {int newCustomer = 8}) {
  final repository = MockSalesOrderRepository();
  // `PosSaleController.updateHeader` calls `ensureOpen()` first — its own
  // `state` was never seeded by this test, so it opens a sale before
  // updating it, exactly as it would on a register nobody has touched yet.
  when(() => repository.open()).thenAnswer((_) async => sale);
  when(
    () => repository.updateHeader(
      saleId: any(named: 'saleId'),
      customer: any(named: 'customer'),
      paymentTerms: any(named: 'paymentTerms'),
      currency: any(named: 'currency'),
      shipTo: any(named: 'shipTo'),
      contact: any(named: 'contact'),
      customerName: any(named: 'customerName'),
      // spec 036: `CustomerBar._updateHeader` now always passes both of
      // these (as `null` when not applicable) — matched here regardless of
      // value so every existing caller of this stub keeps working.
      salesperson: any(named: 'salesperson'),
      fulfillmentIntent: any(named: 'fulfillmentIntent'),
    ),
  ).thenAnswer(
    (_) async => sale.copyWith(
      customer: newCustomer,
      customerName: newCustomer == 1 ? 'PÚBLICO EN GENERAL' : 'ACME SA DE CV',
    ),
  );
  return repository;
}
