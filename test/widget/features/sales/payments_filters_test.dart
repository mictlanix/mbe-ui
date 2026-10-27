import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

CashSession _session(int id) => CashSession(
  cashSessionId: id,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashDrawerFacilityId: 9,
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 5, 9),
  openingAmount: '500',
);

/// Spec 054 FR-006, FR-006a, FR-007, FR-008: every facet of the Pagos filter
/// drawer writes the address and returns to the first page.
void main() {
  late PaymentsMocks mocks;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    mocks = PaymentsMocks();
    // A full page of a 100-row result, so a `page=3` address is a real page.
    stubPayments(mocks.payments, [
      for (var i = 1; i <= 20; i++) testPayment(id: i),
    ], total: 100);
  });

  /// Pumps the list on page 4 (`page=4` in the address) — so a facet that
  /// forgot to reset the page shows up as a surviving `page` parameter.
  Future<GoRouter> pumpOnPage4(
    WidgetTester tester, {
    String extraQuery = '',
    bool pos = false,
  }) async {
    final (router, _) = await pumpPayments(
      tester,
      mocks,
      user: paymentsUser(pos: pos),
      initialLocation: '/sales/payments?page=4$extraQuery',
    );
    return router;
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('payments_filter_button')));
    await tester.pumpAndSettle();
  }

  Map<String, String> params(GoRouter router) =>
      router.state.uri.queryParameters;

  group('facets write the address and reset the page', () {
    testWidgets('customer', (tester) async {
      when(
        () => mocks.customers.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          priceList: any(named: 'priceList'),
          salesperson: any(named: 'salesperson'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => CustomerPage(
          items: [
            CustomerListItem(
              customerId: 12,
              code: 'C-12',
              name: 'Ferretería Sol',
              creditLimit: '0',
              creditDays: 0,
              priceList: const PriceListRef(id: 1, name: 'General'),
              status: EntityStatus.active,
            ),
          ],
          total: 1,
        ),
      );
      final router = await pumpOnPage4(tester);
      expect(params(router)['page'], '4');
      await openSheet(tester);

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('payments_filter_customer')),
          matching: find.byType(TextFormField),
        ),
        'Sol',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-12 — Ferretería Sol'));
      await tester.pumpAndSettle();

      expect(params(router)['customer'], '12');
      expect(params(router).containsKey('page'), isFalse);
    });

    testWidgets('date range (from and to)', (tester) async {
      final router = await pumpOnPage4(tester);
      await openSheet(tester);

      await tester.tap(find.byKey(const Key('date_range_filter_chip')));
      await tester.pumpAndSettle();
      final dialog = find.byType(DateRangePickerDialog);
      expect(dialog, findsOneWidget);

      // Days 1 and 2 of the current month are never after today, which the
      // picker would reject (a one-day range if today is the 1st).
      final now = DateTime.now();
      final endDay = now.day >= 2 ? 2 : 1;
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('1')).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('$endDay')).first,
      );
      await tester.pumpAndSettle();
      final save = MaterialLocalizations.of(
        tester.element(dialog),
      ).saveButtonLabel;
      await tester.tap(find.text(save));
      await tester.pumpAndSettle();

      String ymd(int day) =>
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';
      expect(params(router)['date-from'], ymd(1));
      expect(params(router)['date-to'], ymd(endDay));
      expect(params(router).containsKey('page'), isFalse);
    });

    testWidgets('clearing the date range removes both facets and resets the '
        'page', (tester) async {
      final router = await pumpOnPage4(
        tester,
        extraQuery: '&date-from=2026-08-01&date-to=2026-08-05',
      );
      await openSheet(tester);

      // The chip's own dismiss icon (shown only for a set range).
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('date_range_filter_chip')),
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pumpAndSettle();

      expect(params(router).containsKey('date-from'), isFalse);
      expect(params(router).containsKey('date-to'), isFalse);
      expect(params(router).containsKey('page'), isFalse);
    });

    testWidgets('the date chip reads "any date" with no range', (tester) async {
      await pumpOnPage4(tester);
      await openSheet(tester);

      expect(find.text(l10n.dateRangeFilterAny), findsOneWidget);
    });

    testWidgets('method', (tester) async {
      final router = await pumpOnPage4(tester);
      await openSheet(tester);

      await tester.tap(find.byKey(const Key('payments_filter_method_null')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(paymentMethodLabel(l10n, PaymentMethod.creditCard.code)).last,
      );
      await tester.pumpAndSettle();

      expect(params(router)['method'], '${PaymentMethod.creditCard.code}');
      expect(params(router).containsKey('page'), isFalse);
    });

    testWidgets('verified yes and no', (tester) async {
      final router = await pumpOnPage4(tester);
      await openSheet(tester);

      await tester.tap(find.byKey(const Key('payments_filter_verified_yes')));
      await tester.pumpAndSettle();
      expect(params(router)['verified'], 'true');
      expect(params(router).containsKey('page'), isFalse);

      await tester.tap(find.byKey(const Key('payments_filter_verified_no')));
      await tester.pumpAndSettle();
      expect(params(router)['verified'], 'false');
    });

    testWidgets('cash session', (tester) async {
      when(
        () => mocks.cashSessions.list(
          facilityId: any(named: 'facilityId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => CashSessionListResult(items: [_session(77)], total: 1),
      );
      final router = await pumpOnPage4(tester, pos: true);
      await openSheet(tester);

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('payments_filter_cash_session')),
          matching: find.byType(TextFormField),
        ),
        'ana',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('#77 · Ana López'));
      await tester.pumpAndSettle();

      expect(params(router)['cash-session'], '77');
      expect(params(router).containsKey('page'), isFalse);
      verify(
        () => mocks.cashSessions.list(facilityId: 9, limit: 20),
      ).called(greaterThan(0));
    });
  });

  group('verified is tri-state (FR-007)', () {
    bool selected(WidgetTester tester, String key) => tester
        .widget<ChoiceChip>(find.byKey(Key('payments_filter_verified_$key')))
        .selected;

    testWidgets('"Todos" is selected by default', (tester) async {
      await pumpOnPage4(tester);
      await openSheet(tester);

      expect(selected(tester, 'any'), isTrue);
      expect(selected(tester, 'yes'), isFalse);
      expect(selected(tester, 'no'), isFalse);
      expect(find.text(l10n.paymentsVerifiedAny), findsOneWidget);
    });

    testWidgets('verified=true selects only "Verificados"', (tester) async {
      await pumpOnPage4(tester, extraQuery: '&verified=true');
      await openSheet(tester);

      expect(selected(tester, 'any'), isFalse);
      expect(selected(tester, 'yes'), isTrue);
      expect(selected(tester, 'no'), isFalse);
    });

    testWidgets('verified=false selects only "Sin verificar"', (tester) async {
      await pumpOnPage4(tester, extraQuery: '&verified=false');
      await openSheet(tester);

      expect(selected(tester, 'any'), isFalse);
      expect(selected(tester, 'yes'), isFalse);
      expect(selected(tester, 'no'), isTrue);
    });

    testWidgets('"Todos" removes the facet again', (tester) async {
      final router = await pumpOnPage4(tester, extraQuery: '&verified=true');
      await openSheet(tester);

      await tester.tap(find.byKey(const Key('payments_filter_verified_any')));
      await tester.pumpAndSettle();

      expect(params(router).containsKey('verified'), isFalse);
      expect(selected(tester, 'any'), isTrue);
    });

    testWidgets('the request carries verified=false, not "any"', (
      tester,
    ) async {
      await pumpOnPage4(tester, extraQuery: '&verified=false');

      verify(
        () => mocks.payments.list(
          facilityId: 9,
          customerId: null,
          cashSessionId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: null,
          verified: false,
          skip: any(named: 'skip'),
          limit: 20,
        ),
      ).called(greaterThan(0));
    });
  });

  group('cash-session facet gating (FR-006a)', () {
    testWidgets('is absent without POS read', (tester) async {
      await pumpOnPage4(tester, pos: false);
      await openSheet(tester);

      expect(find.byKey(const Key('payments_filter_customer')), findsOneWidget);
      expect(
        find.byKey(const Key('payments_filter_cash_session')),
        findsNothing,
      );
    });

    testWidgets('is present with POS read', (tester) async {
      await pumpOnPage4(tester, pos: true);
      await openSheet(tester);

      expect(
        find.byKey(const Key('payments_filter_cash_session')),
        findsOneWidget,
      );
    });

    testWidgets('a cold link with cash-session=<id> shows its label once '
        'resolved', (tester) async {
      when(
        () => mocks.cashSessions.get(cashSessionId: 77),
      ).thenAnswer((_) async => _session(77));
      await pumpOnPage4(tester, pos: true, extraQuery: '&cash-session=77');
      await openSheet(tester);

      expect(find.text('#77 · Ana López · 2026-08-05'), findsOneWidget);
    });
  });

  group('badge and clear-all', () {
    Badge badge(WidgetTester tester) => tester.widget<Badge>(
      find.ancestor(
        of: find.byKey(const Key('payments_filter_button')),
        matching: find.byType(Badge),
      ),
    );

    testWidgets('the badge is hidden with no filters', (tester) async {
      await pumpOnPage4(tester);

      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('the badge counts active filters, a date range as one', (
      tester,
    ) async {
      await pumpOnPage4(
        tester,
        extraQuery:
            '&customer=7&verified=false&method=1'
            '&date-from=2026-08-01&date-to=2026-08-05&cash-session=77',
      );

      expect(badge(tester).isLabelVisible, isTrue);
      expect((badge(tester).label as Text).data, '5');
    });

    testWidgets('clear-all removes every facet and the page', (tester) async {
      final router = await pumpOnPage4(
        tester,
        extraQuery:
            '&customer=7&verified=false&method=1'
            '&date-from=2026-08-01&date-to=2026-08-05',
      );
      await openSheet(tester);

      await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
      await tester.pumpAndSettle();

      expect(params(router), isEmpty);
      expect(router.state.uri.path, '/sales/payments');
      expect(badge(tester).isLabelVisible, isFalse);
    });
  });

  group('all-facilities scope drawer (US3, FR-012)', () {
    setUp(() {
      stubSearch(mocks.payments, [testPayment()]);
    });

    Future<GoRouter> pumpAll(WidgetTester tester, {String extra = ''}) async {
      final (router, _) = await pumpPayments(
        tester,
        mocks,
        // POS read too, to prove the cash-session facet is hidden by scope,
        // not merely by missing rights.
        user: paymentsUser(editor: true, pos: true),
        initialLocation: '/sales/payments?scope=all$extra',
      );
      return router;
    }

    testWidgets('shows only the Cliente and Fecha facets', (tester) async {
      await pumpAll(tester);
      await openSheet(tester);

      expect(find.byKey(const Key('payments_filter_customer')), findsOneWidget);
      expect(find.byKey(const Key('date_range_filter_chip')), findsOneWidget);
      // The facility-only facets are hidden in this scope (FR-012) — the
      // cash-session picker even for a user with POS read, because the
      // endpoint has no such filters and a facet set there would filter
      // nothing.
      expect(find.byType(DropdownButtonFormField<int?>), findsNothing);
      expect(
        find.byKey(const Key('payments_filter_verified_any')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('payments_filter_verified_yes')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('payments_filter_verified_no')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('payments_filter_cash_session')),
        findsNothing,
      );
    });

    testWidgets('the facility scope still shows all facets for the same '
        'user', (tester) async {
      stubPayments(mocks.payments, [testPayment()]);
      await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true, pos: true),
      );
      await openSheet(tester);

      expect(find.byType(DropdownButtonFormField<int?>), findsOneWidget);
      expect(
        find.byKey(const Key('payments_filter_verified_any')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('payments_filter_cash_session')),
        findsOneWidget,
      );
    });

    testWidgets('a facet change keeps scope=all and resets the page', (
      tester,
    ) async {
      final router = await pumpAll(
        tester,
        extra: '&page=4&date-from=2026-08-01&date-to=2026-08-05',
      );
      await openSheet(tester);

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('date_range_filter_chip')),
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {'scope': 'all'});
    });

    testWidgets('clear-all keeps scope=all, drops customer, dates and the '
        'search', (tester) async {
      final router = await pumpAll(
        tester,
        extra: '&search=REF&customer=7&date-from=2026-08-01&date-to=2026-08-05',
      );
      await openSheet(tester);

      await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {'scope': 'all'});
    });

    testWidgets('the badge counts customer and dates but not the search', (
      tester,
    ) async {
      await pumpAll(
        tester,
        extra:
            '&search=REF&customer=7&date-from=2026-08-01&date-to=2026-08-05'
            '&verified=true&method=1',
      );

      final badge = tester.widget<Badge>(
        find.ancestor(
          of: find.byKey(const Key('payments_filter_button')),
          matching: find.byType(Badge),
        ),
      );
      expect((badge.label as Text).data, '2');
    });
  });
}
