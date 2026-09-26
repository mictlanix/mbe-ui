import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

const _updaterUser = User(
  userId: 'quote-updater',
  email: 'quote-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.salesQuotes, rawValue: 1 | 4),
    Privilege(systemObject: SystemObject.customers, rawValue: 1 | 2),
  ],
);

const _noCustomerCreateUser = User(
  userId: 'quote-updater-no-customer-create',
  email: 'quote-updater-no-customer-create@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.salesQuotes, rawValue: 1 | 4),
    Privilege(systemObject: SystemObject.customers, rawValue: 2),
  ],
);

/// spec 040 US4 / FR-010, FR-011: from the quote's own customer band —
/// which opens already searching for a new quote (FR-009) — inline customer
/// creation attaches the new customer the same one-request path a picked
/// one takes, and unlocks product capture; a cancelled or refused form
/// leaves no customer and opens no quote. Mirrors `order_workspace_test.
/// dart`'s own "creating a customer inline" group; per T059, `CustomerBar`'s
/// existing inline-create entry point needs no change for this host — this
/// file is verification only.
void main() {
  late MockSalesQuoteRepository salesQuotes;
  late MockCustomerRepository customers;
  late MockPriceListRepository priceLists;
  late MockTaxpayerRecipientRepository taxpayers;

  bool productSearchEnabled(WidgetTester tester) => tester
      .widget<ProductSearchField>(find.byType(ProductSearchField))
      .enabled;

  setUp(() {
    salesQuotes = MockSalesQuoteRepository();
    customers = MockCustomerRepository();
    priceLists = MockPriceListRepository();
    taxpayers = MockTaxpayerRecipientRepository();

    // The inline-create form's own two lookups (US4) — same fixtures
    // `order_workspace_test.dart`'s own copy of this group uses.
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
    // The customer band's facts view fetches the attached customer's own
    // record by id regardless of how it got attached — picked or created.
    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer(
      (_) async => const Customer(
        customerId: 99,
        code: 'C-99',
        name: 'FERRETERÍA LOS PINOS',
        creditLimit: '0',
        creditDays: 0,
        priceList: PriceListRef(id: 2, name: 'Mayoreo'),
        status: EntityStatus.active,
      ),
    );
  });

  Future<void> pumpQuote(WidgetTester tester, {User? user}) => pumpQuotesRouted(
    tester,
    overrides: [
      authNotifierProvider.overrideWith(
        () => _FixedAuthNotifier(
          AuthState.authenticated(token: 't', user: user ?? _updaterUser),
        ),
      ),
      salesQuoteOverride(salesQuotes),
      customerRepositoryProvider.overrideWithValue(customers),
      priceListRepositoryProvider.overrideWithValue(priceLists),
      taxpayerRecipientRepositoryProvider.overrideWithValue(taxpayers),
    ],
  );

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

  testWidgets('reachable from a new quote before any customer is attached '
      '— searching is the whole face there (FR-009)', (tester) async {
    await pumpQuote(tester);
    expect(find.byKey(const Key('pos_create_customer_button')), findsOneWidget);
  });

  testWidgets('absent without customers:create (constitution §IV)', (
    tester,
  ) async {
    await pumpQuote(tester, user: _noCustomerCreateUser);
    expect(find.byKey(const Key('pos_create_customer_button')), findsNothing);
  });

  testWidgets('a created customer is attached and product capture unlocks, '
      'the same one-request path a picked customer takes (FR-010, FR-011)', (
    tester,
  ) async {
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
    final opened = testQuote(customer: 99);
    when(
      () => salesQuotes.open(customer: 99, salesperson: any(named: 'salesperson')),
    ).thenAnswer((_) async => opened);
    // After opening, `_maybeRewriteUrl` (quote_screen.dart) replaces the
    // route from `/sales/quotes/new` to `/sales/quotes/${opened.id}`, a
    // fresh `QuoteEditorController(opened.id)` instance that re-fetches via
    // `getById` — same as `OrderEditorController`'s own rewrite does.
    when(
      () => salesQuotes.getById(quoteId: opened.id),
    ).thenAnswer((_) async => opened);

    await pumpQuote(tester);
    await tester.tap(find.byKey(const Key('pos_create_customer_button')));
    await tester.pumpAndSettle();
    await fillAndSave(tester);

    verify(
      () => salesQuotes.open(
        customer: 99,
        salesperson: any(named: 'salesperson'),
      ),
    ).called(1);
    expect(productSearchEnabled(tester), isTrue);
  });

  testWidgets('cancelling the form creates nothing and opens no quote', (
    tester,
  ) async {
    await pumpQuote(tester);
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
      () => salesQuotes.open(
        customer: any(named: 'customer'),
        salesperson: any(named: 'salesperson'),
      ),
    );
    expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
    expect(productSearchEnabled(tester), isFalse);
  });

  testWidgets('a refused create keeps the form open with the server\'s '
      'reason, and opens no quote (US4 scenario 3)', (tester) async {
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

    await pumpQuote(tester);
    await tester.tap(find.byKey(const Key('pos_create_customer_button')));
    await tester.pumpAndSettle();
    await fillAndSave(tester);

    expect(find.byKey(const Key('pos_new_customer_save')), findsOneWidget);
    expect(find.text('Code already used'), findsOneWidget);
    verifyNever(
      () => salesQuotes.open(
        customer: any(named: 'customer'),
        salesperson: any(named: 'salesperson'),
      ),
    );
  });
}
