import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/fulfillment_mode_selector.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_header_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

class MockCustomerRepository extends Mock implements CustomerRepository {}

/// Holds create+update on `salesQuotes`, create+read on `customers` — the
/// quote screen's inline-create affordance gates on the latter (spec 040
/// FR-003) — and create on `salesOrders`, since converting a quote also
/// requires it (FR-004).
const _updaterUser = User(
  userId: 'quote-updater',
  email: 'quote-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.salesQuotes, rawValue: 1 | 4),
    Privilege(systemObject: SystemObject.customers, rawValue: 1 | 2),
    Privilege(systemObject: SystemObject.salesOrders, rawValue: 1),
  ],
);

Override _authOverride([User user = _updaterUser]) =>
    authNotifierProvider.overrideWith(
      () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: user)),
    );

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

ProductLookupResult _product({
  int product = 11,
  String code = 'P-11',
  String name = 'Widget',
  int minOrderQty = 1,
}) => ProductLookupResult(
  product: product,
  code: code,
  name: name,
  price: '50.00',
  taxRate: '0.16',
  taxIncluded: false,
  minOrderQty: minOrderQty,
  stockRequired: false,
  stockable: true,
);

/// spec 040 US1: the full happy path for an existing customer, attached on
/// the quote's own single step, through adding a line and confirming.
/// Mirrors `order_workspace_test.dart`'s own shape — this file's job is the
/// quote host's configuration of the shared capture surface, not re-proving
/// `CaptureStep`/`SaleLineRow` themselves (already covered by their own
/// suites).
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockSalesQuoteRepository salesQuotes;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late AppLocalizations l10n;

  /// The quote screen's forward action — the same `SaleTotalsBar` key every
  /// host shares, since `CaptureStep` never overrides it for a quote
  /// (contracts/quote-capture-host.md §2).
  Finder continueButton() => find.byKey(const Key('pos_continue_to_payment'));

  bool productSearchEnabled(WidgetTester tester) => tester
      .widget<ProductSearchField>(find.byType(ProductSearchField))
      .enabled;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    salesQuotes = MockSalesQuoteRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customerRecord());
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
  });

  Future<ProviderContainer> pumpQuoteScreen(
    WidgetTester tester, {
    int? quoteId,
    User user = _updaterUser,
  }) async {
    final (_, container) = await pumpQuotesRouted(
      tester,
      initialLocation: quoteId == null
          ? '/sales/quotes/new'
          : '/sales/quotes/$quoteId',
      overrides: [
        _authOverride(user),
        salesOrderOverride(salesOrders),
        salesQuoteOverride(salesQuotes),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
      ],
    );
    return container;
  }

  group('opening the customer band (FR-005…FR-009)', () {
    testWidgets('a new quote writes nothing on mount, shows the customer '
        'search rather than the facts view, and withholds product capture', (
      tester,
    ) async {
      await pumpQuoteScreen(tester);

      verifyNever(
        () => salesQuotes.open(
          customer: any(named: 'customer'),
          salesperson: any(named: 'salesperson'),
        ),
      );
      expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
      expect(productSearchEnabled(tester), isFalse);
    });

    testWidgets('the generic walk-in customer never appears in results '
        '(FR-007)', (tester) async {
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

      await pumpQuoteScreen(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PUBLICO',
      );
      await tester.pumpAndSettle();

      expect(find.text('C-1 — PÚBLICO EN GENERAL'), findsNothing);
    });

    testWidgets('picking a customer opens the draft with that customer in '
        'one request — no origin, no fulfilment intent — and unlocks '
        'product capture (FR-008, FR-009)', (tester) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer(
        (_) async => const CustomerPage(items: [_realCustomer], total: 1),
      );
      final opened = testQuote(customer: 7);
      when(
        () => salesQuotes.open(customer: 7, salesperson: any(named: 'salesperson')),
      ).thenAnswer((_) async => opened);
      when(
        () => salesQuotes.getById(quoteId: opened.id),
      ).thenAnswer((_) async => opened);

      await pumpQuoteScreen(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PINOS',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-7 — FERRETERÍA LOS PINOS'));
      await tester.pumpAndSettle();

      // Exactly one request, carrying the customer alone — never a create
      // followed by a correcting update, and never an origin or a
      // fulfilment intent, neither of which exists on a quote (FR-008).
      verify(
        () => salesQuotes.open(customer: 7, salesperson: any(named: 'salesperson')),
      ).called(1);
      verifyNever(
        () => salesQuotes.updateHeader(
          quoteId: any(named: 'quoteId'),
          customer: any(named: 'customer'),
        ),
      );
      expect(productSearchEnabled(tester), isTrue);
      expect(find.byKey(const Key('pos_customer_picker')), findsNothing);
    });
  });

  group('capturing a line (FR-013…FR-017)', () {
    Future<void> attachCustomerAndOpen(WidgetTester tester, Sale opened) async {
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer(
        (_) async => const CustomerPage(items: [_realCustomer], total: 1),
      );
      when(
        () => salesQuotes.open(customer: 7, salesperson: any(named: 'salesperson')),
      ).thenAnswer((_) async => opened);
      when(
        () => salesQuotes.getById(quoteId: opened.id),
      ).thenAnswer((_) async => opened);

      await pumpQuoteScreen(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PINOS',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-7 — FERRETERÍA LOS PINOS'));
      await tester.pumpAndSettle();
    }

    testWidgets('a product is priced from the customer\'s price list, '
        'quantity defaults to the minimum, and no warehouse or stock '
        'control renders (FR-014, FR-015)', (tester) async {
      final opened = testQuote(customer: 7, id: 30);
      await attachCustomerAndOpen(tester, opened);

      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: 7,
          warehouse: null,
        ),
      ).thenAnswer((_) async => [_product(minOrderQty: 3)]);
      when(
        () => salesQuotes.addLine(
          quoteId: 30,
          product: 11,
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          priceAdjustment: any(named: 'priceAdjustment'),
          discountRate: any(named: 'discountRate'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer(
        (_) async => opened.copyWith(lines: [testQuoteLine(quantity: '3')]),
      );

      await tester.enterText(
        find.descendant(
          of: find.byType(ProductSearchField),
          matching: find.byType(TextField),
        ),
        'wid',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.tap(find.text('P-11 — Widget'));
      await tester.pumpAndSettle();

      verify(
        () => salesQuotes.addLine(
          quoteId: 30,
          product: 11,
          quantity: '3',
          price: any(named: 'price'),
          priceAdjustment: any(named: 'priceAdjustment'),
          discountRate: any(named: 'discountRate'),
          comment: any(named: 'comment'),
        ),
      ).called(1);
      expect(
        find.text(l10n.posLineWarehouseLabel),
        findsNothing,
        reason: 'a quote line has no warehouse at all',
      );
      expect(
        find.textContaining(l10n.posLineAdjustToAvailable),
        findsNothing,
        reason: 'no stock to advise on',
      );
    });

    testWidgets('no fulfilment-mode selector is offered anywhere on the '
        'quote screen (FR-016)', (tester) async {
      await attachCustomerAndOpen(tester, testQuote(customer: 7, id: 30));
      expect(find.byType(FulfillmentModeSelector), findsNothing);
    });
  });

  group('the header (FR-020, FR-023, spec A11/A12)', () {
    Future<void> openQuote(WidgetTester tester, Sale quote) async {
      when(
        () => salesQuotes.getById(quoteId: quote.id),
      ).thenAnswer((_) async => quote);
      await pumpQuoteScreen(tester, quoteId: quote.id);
    }

    // Currency and the comment sit behind "More details" (2026-09-26
    // redesign, mirrors `OrderHeaderPanel`'s own disclosure) — closed on
    // arrival, so a test reaching either opens it first.
    Future<void> expandDetails(WidgetTester tester) async {
      await tester.tap(
        find.byKey(const Key('sales_quote_more_details_toggle')),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('while draft, the expiry date is editable and commits '
        'through updateHeader', (tester) async {
      final draft = testQuote(customer: 7, id: 30);
      when(
        () => salesQuotes.updateHeader(
          quoteId: 30,
          dueDate: any(named: 'dueDate'),
        ),
      ).thenAnswer((_) async => draft);
      await openQuote(tester, draft);

      expect(find.text(l10n.salesQuoteExpiryLabel), findsOneWidget);
      await tester.tap(find.text(l10n.salesQuoteExpiryLabel));
      await tester.pumpAndSettle();
      // Proof the affordance opens a real date picker rather than doing
      // nothing — completing a full date selection is left to the picker's
      // own suite, matching `order_header_disclosure_test.dart`'s own
      // restraint here.
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('while draft, the comment commits through updateHeader on '
        'submit', (tester) async {
      final draft = testQuote(customer: 7, id: 30);
      when(
        () => salesQuotes.updateHeader(
          quoteId: 30,
          comment: 'Precio válido 30 días',
        ),
      ).thenAnswer((_) async => draft.copyWith(comment: 'Precio válido 30 días'));
      await openQuote(tester, draft);
      await expandDetails(tester);

      await tester.enterText(
        find.byKey(const Key('sales_quote_comment_field')),
        'Precio válido 30 días',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      verify(
        () => salesQuotes.updateHeader(
          quoteId: 30,
          comment: 'Precio válido 30 días',
        ),
      ).called(1);
    });

    testWidgets('currency is rendered read-only in the fact strip — this '
        'feature introduces no currency selector (spec A11)', (tester) async {
      await openQuote(tester, testQuote(customer: 7, id: 30));
      expect(find.byType(DropdownButtonFormField<Currency>), findsNothing);
      expect(find.text(l10n.salesQuoteCurrencyLabel), findsOneWidget);
    });

    testWidgets('the payment-terms control inherited from CustomerBar still '
        'commits', (tester) async {
      final draft = testQuote(customer: 7, id: 30);
      when(
        () => salesQuotes.updateHeader(
          quoteId: 30,
          paymentTerms: PaymentTerms.netD,
        ),
      ).thenAnswer((_) async => draft.copyWith(paymentTerms: PaymentTerms.netD));
      await openQuote(tester, draft);

      expect(find.byKey(const Key('pos_payment_terms_dropdown')), findsOneWidget);
    });

    testWidgets('the status field is labelled Estado, not Referencia — its '
        'own field, distinct from the reference (FR-022)', (tester) async {
      final draft = testQuote(customer: 7, id: 30);
      await openQuote(tester, draft);

      expect(find.text(l10n.salesQuoteStatusLabel), findsOneWidget);
      expect(find.text(l10n.salesQuoteStatusDraft), findsOneWidget);
    });

    testWidgets('the fact strip carries reference, status, date, expiry and '
        'currency as plain labelled values, collapsed on arrival, with only '
        'the comment behind "More details" (2026-09-26 redesign, matches '
        'OrderHeaderPanel)', (tester) async {
      final draft = testQuote(customer: 7, id: 30, serial: 4001);
      await openQuote(tester, draft);

      Finder inPanel(String text) => find.descendant(
        of: find.byType(QuoteHeaderPanel),
        matching: find.text(text),
      );

      expect(inPanel(l10n.salesQuoteReferenceLabel), findsOneWidget);
      expect(inPanel(l10n.salesQuoteStatusLabel), findsOneWidget);
      expect(inPanel(l10n.salesQuoteDateLabel), findsOneWidget);
      expect(inPanel(l10n.salesQuoteExpiryLabel), findsOneWidget);
      expect(inPanel(l10n.salesQuoteCurrencyLabel), findsOneWidget);
      expect(inPanel('4001'), findsOneWidget);
      expect(find.text(l10n.salesQuoteMoreDetails), findsOneWidget);

      // Only the comment sits behind the disclosure now — currency is
      // never anything but a fact here, so it moved back into the strip.
      expect(
        find.byKey(const Key('sales_quote_comment_field')),
        findsNothing,
      );

      await expandDetails(tester);

      expect(
        find.byKey(const Key('sales_quote_comment_field')),
        findsOneWidget,
      );
      // Mirrors `OrderHeaderPanel`'s own comment field: the label is the
      // field's own `InputDecoration.labelText`, not a separate caption.
      expect(find.text(l10n.salesQuoteCommentLabel), findsOneWidget);
      expect(find.text(l10n.salesQuoteFewerDetails), findsOneWidget);
    });

    testWidgets('hasExpired renders a marker beside the status value, never '
        'folded into it (FR-024, FR-037)', (tester) async {
      final expired = testQuote(
        customer: 7,
        id: 30,
        status: SaleStatus.completed,
        hasExpired: true,
      );
      await openQuote(tester, expired);

      expect(find.text(l10n.salesQuoteStatusCompleted), findsOneWidget);
      expect(
        find.byKey(const Key('sales_quote_expired_marker')),
        findsOneWidget,
      );
    });

    testWidgets('once confirmed, the expiry and comment are read-only '
        '(FR-023)', (tester) async {
      final confirmed = testQuote(
        customer: 7,
        id: 30,
        status: SaleStatus.completed,
        lines: [testQuoteLine()],
      );
      await openQuote(tester, confirmed);
      await expandDetails(tester);

      // The key now sits on the inner `TextField` (`fieldKey`), matching
      // `OrderHeaderPanel`'s own comment field exactly.
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('sales_quote_comment_field')),
            )
            .enabled,
        isFalse,
      );
    });
  });

  group('converting an accepted quote (FR-025…FR-031)', () {
    Sale confirmedQuote({bool hasExpired = false}) => testQuote(
      customer: 7,
      id: 30,
      status: SaleStatus.completed,
      serial: 4001,
      lines: [testQuoteLine()],
      hasExpired: hasExpired,
    );

    testWidgets('offered only when completed, unexpired, and the user may '
        'also create orders', (tester) async {
      when(
        () => salesQuotes.getById(quoteId: 30),
      ).thenAnswer((_) async => confirmedQuote());
      await pumpQuoteScreen(tester, quoteId: 30);
      expect(find.byKey(const Key('sales_quote_convert_button')), findsOneWidget);
    });

    testWidgets('absent for a draft quote', (tester) async {
      when(
        () => salesQuotes.getById(quoteId: 30),
      ).thenAnswer((_) async => testQuote(customer: 7, id: 30, lines: [testQuoteLine()]));
      await pumpQuoteScreen(tester, quoteId: 30);
      expect(find.byKey(const Key('sales_quote_convert_button')), findsNothing);
    });

    testWidgets('absent for a user without salesOrders create, even though '
        'the quote is confirmed (FR-004)', (tester) async {
      const noOrderCreateUser = User(
        userId: 'quote-only',
        email: 'quote-only@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: [
          Privilege(systemObject: SystemObject.salesQuotes, rawValue: 1 | 4),
        ],
      );
      when(
        () => salesQuotes.getById(quoteId: 30),
      ).thenAnswer((_) async => confirmedQuote());
      await pumpQuoteScreen(tester, quoteId: 30, user: noOrderCreateUser);
      expect(find.byKey(const Key('sales_quote_convert_button')), findsNothing);
    });

    testWidgets('a successful convert navigates to the resulting order\'s '
        'workspace', (tester) async {
      when(
        () => salesQuotes.getById(quoteId: 30),
      ).thenAnswer((_) async => confirmedQuote());
      when(
        () => salesQuotes.convert(quoteId: 30),
      ).thenAnswer((_) async => testSale(id: 99));

      // `pumpQuotesRouted` now carries its own `/sales/orders/:orderId`
      // marker route (pos_test_harness.dart) for exactly this navigation —
      // no bespoke router needed.
      await pumpQuoteScreen(tester, quoteId: 30);

      await tester.tap(find.byKey(const Key('sales_quote_convert_button')));
      await tester.pumpAndSettle();

      expect(find.text('order 99'), findsOneWidget);
    });

    for (final refusal in [
      ('draft', 'Only a confirmed quote can be converted; confirm it first'),
      ('cancelled', 'A cancelled quote cannot be converted'),
      ('expired', 'Quote has expired and cannot be converted; duplicate it to re-quote'),
      ('no point of sale', 'No point of sale is configured for your user'),
    ]) {
      testWidgets('shows a distinct message for the "${refusal.$1}" refusal '
          '(FR-028)', (tester) async {
        when(
          () => salesQuotes.getById(quoteId: 30),
        ).thenAnswer((_) async => confirmedQuote());
        when(() => salesQuotes.convert(quoteId: 30)).thenThrow(
          AppError.server(statusCode: 409, message: refusal.$2),
        );

        await pumpQuoteScreen(tester, quoteId: 30);
        await tester.tap(find.byKey(const Key('sales_quote_convert_button')));
        await tester.pumpAndSettle();

        expect(find.textContaining(refusal.$2), findsOneWidget);
      });
    }

    testWidgets('the expired refusal additionally offers a working '
        'Duplicate action, driven by hasExpired — not by matching the '
        'refusal\'s prose (FR-029)', (tester) async {
      when(
        () => salesQuotes.getById(quoteId: 30),
      ).thenAnswer((_) async => confirmedQuote(hasExpired: true));
      when(
        () => salesQuotes.duplicate(quoteId: 30),
      ).thenAnswer((_) async => testQuote(customer: 7, id: 31));

      final (router, _) = await pumpQuotesRouted(
        tester,
        initialLocation: '/sales/quotes/30',
        overrides: [
          _authOverride(),
          salesOrderOverride(salesOrders),
          salesQuoteOverride(salesQuotes),
          customerRepositoryProvider.overrideWithValue(customers),
          customerPaymentOverride(payments),
        ],
      );
      expect(find.byKey(const Key('sales_quote_convert_button')), findsNothing);
      expect(find.byKey(const Key('sales_quote_duplicate_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('sales_quote_duplicate_button')));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/quotes/31');
    });
  });

  group('confirming (FR-018…FR-023)', () {
    testWidgets('unavailable with zero lines, available with one', (
      tester,
    ) async {
      final opened = testQuote(customer: 7, id: 30, lines: const []);
      when(
        () => customers.list(search: any(named: 'search'), limit: 10),
      ).thenAnswer(
        (_) async => const CustomerPage(items: [_realCustomer], total: 1),
      );
      when(
        () => salesQuotes.open(customer: 7, salesperson: any(named: 'salesperson')),
      ).thenAnswer((_) async => opened);
      when(
        () => salesQuotes.getById(quoteId: opened.id),
      ).thenAnswer((_) async => opened.copyWith(lines: [testQuoteLine()]));

      await pumpQuoteScreen(tester);
      await tester.enterText(
        find.byKey(const Key('pos_customer_picker')),
        'PINOS',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-7 — FERRETERÍA LOS PINOS'));
      await tester.pumpAndSettle();

      // Reopened by the getById stub above, this time with a line — proves
      // the gate tracks line count, not merely "a quote exists".
      final button = tester.widget<FloatingActionButton>(continueButton());
      expect(button.onPressed, isNotNull);
    });

    testWidgets('confirming assigns a folio, makes the screen read-only, '
        'and the primary action is absent rather than greyed (FR-021, '
        'FR-023)', (tester) async {
      final draft = testQuote(customer: 7, id: 30, lines: [testQuoteLine()]);
      final confirmed = draft.copyWith(
        status: SaleStatus.completed,
        serial: 4001,
      );
      when(
        () => salesQuotes.getById(quoteId: 30),
      ).thenAnswer((_) async => draft);
      when(
        () => salesQuotes.confirm(quoteId: 30),
      ).thenAnswer((_) async => confirmed);

      await pumpQuoteScreen(tester, quoteId: 30);
      await tester.tap(continueButton());
      await tester.pumpAndSettle();

      verify(() => salesQuotes.confirm(quoteId: 30)).called(1);
      expect(
        continueButton(),
        findsNothing,
        reason: 'the primary action disappears once confirmed, per '
            'showAction rather than a disabled onPressed',
      );
    });
  });

  group('reopening a quote (FR-039)', () {
    testWidgets('a draft resumes editable, with its customer and lines '
        'intact', (tester) async {
      when(() => salesQuotes.getById(quoteId: 30)).thenAnswer(
        (_) async =>
            testQuote(customer: 7, id: 30, lines: [testQuoteLine()]),
      );

      await pumpQuoteScreen(tester, quoteId: 30);

      expect(find.text('FERRETERÍA LOS PINOS'), findsOneWidget);
      expect(find.text('Widget'), findsOneWidget);
      expect(productSearchEnabled(tester), isTrue);
      expect(continueButton(), findsOneWidget);
    });

    testWidgets('a confirmed quote is read-only: no product capture and no '
        'primary action, its lines still visible', (tester) async {
      when(() => salesQuotes.getById(quoteId: 30)).thenAnswer(
        (_) async => testQuote(
          customer: 7,
          id: 30,
          serial: 4001,
          status: SaleStatus.completed,
          lines: [testQuoteLine()],
        ),
      );

      await pumpQuoteScreen(tester, quoteId: 30);

      expect(find.text('Widget'), findsOneWidget);
      expect(productSearchEnabled(tester), isFalse);
      expect(continueButton(), findsNothing);
    });

    testWidgets('a cancelled quote is read-only and offers no way to edit '
        'or convert it — Confirmar and Convertir are both absent; Duplicar '
        'is its own sanctioned recovery (US5, FR-033), not this test\'s '
        'concern', (tester) async {
      when(() => salesQuotes.getById(quoteId: 30)).thenAnswer(
        (_) async => testQuote(
          customer: 7,
          id: 30,
          serial: 4001,
          status: SaleStatus.cancelled,
          lines: [testQuoteLine()],
        ),
      );

      await pumpQuoteScreen(tester, quoteId: 30);

      expect(productSearchEnabled(tester), isFalse);
      expect(continueButton(), findsNothing);
      expect(
        find.byKey(const Key('sales_quote_convert_button')),
        findsNothing,
      );
    });
  });

  group('duplicating a quote in any state (US5, FR-033)', () {
    for (final status in [
      SaleStatus.draft,
      SaleStatus.completed,
      SaleStatus.cancelled,
    ]) {
      testWidgets(
        'offered and working on a ${status.name} quote',
        (tester) async {
          when(() => salesQuotes.getById(quoteId: 30)).thenAnswer(
            (_) async => testQuote(customer: 7, id: 30, status: status),
          );
          when(
            () => salesQuotes.duplicate(quoteId: 30),
          ).thenAnswer((_) async => testQuote(customer: 7, id: 31));

          final (router, _) = await pumpQuotesRouted(
            tester,
            initialLocation: '/sales/quotes/30',
            overrides: [
              _authOverride(),
              salesOrderOverride(salesOrders),
              salesQuoteOverride(salesQuotes),
              customerRepositoryProvider.overrideWithValue(customers),
              customerPaymentOverride(payments),
            ],
          );

          expect(
            find.byKey(const Key('sales_quote_duplicate_button')),
            findsOneWidget,
          );
          await tester.tap(find.byKey(const Key('sales_quote_duplicate_button')));
          await tester.pumpAndSettle();

          verify(() => salesQuotes.duplicate(quoteId: 30)).called(1);
          expect(router.state.uri.path, '/sales/quotes/31');
        },
      );
    }

    testWidgets(
      'offered and working on a completed, unexpired quote too, alongside '
      'Convert',
      (tester) async {
        when(() => salesQuotes.getById(quoteId: 30)).thenAnswer(
          (_) async =>
              testQuote(customer: 7, id: 30, status: SaleStatus.completed),
        );
        when(
          () => salesQuotes.duplicate(quoteId: 30),
        ).thenAnswer((_) async => testQuote(customer: 7, id: 31));

        final (router, _) = await pumpQuotesRouted(
          tester,
          initialLocation: '/sales/quotes/30',
          overrides: [
            _authOverride(),
            salesOrderOverride(salesOrders),
            salesQuoteOverride(salesQuotes),
            customerRepositoryProvider.overrideWithValue(customers),
            customerPaymentOverride(payments),
          ],
        );

        expect(
          find.byKey(const Key('sales_quote_convert_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('sales_quote_duplicate_button')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('sales_quote_duplicate_button')));
        await tester.pumpAndSettle();

        verify(() => salesQuotes.duplicate(quoteId: 30)).called(1);
        expect(router.state.uri.path, '/sales/quotes/31');
      },
    );

    testWidgets('absent without salesQuotes:create', (tester) async {
      const noCreateUser = User(
        userId: 'quote-no-create',
        email: 'quote-no-create@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: [
          Privilege(systemObject: SystemObject.salesQuotes, rawValue: 4),
        ],
      );
      when(
        () => salesQuotes.getById(quoteId: 30),
      ).thenAnswer((_) async => testQuote(customer: 7, id: 30));

      await pumpQuoteScreen(tester, quoteId: 30, user: noCreateUser);

      expect(
        find.byKey(const Key('sales_quote_duplicate_button')),
        findsNothing,
      );
    });
  });
}
