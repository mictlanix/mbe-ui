import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

/// Spec 054 FR-019 and constitution §VI: the Pagos table fits at the Expanded
/// tier with no horizontal scroll — only text columns are ellipsized, amounts
/// and status chips are shown in full — and every screen pumps without an
/// overflow at phone width.
final _editor = User(
  userId: 'editor-1',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: const UserSettings(facilityId: 9),
  privileges: const [
    Privilege(systemObject: SystemObject.customerPayments, rawValue: 2),
    Privilege(systemObject: SystemObject.paymentsEditor, rawValue: 2),
    Privilege(systemObject: SystemObject.pos, rawValue: 2),
  ],
);

/// A row whose every cell is as wide as real data gets: a long reference, a
/// foreign-currency amount in the millions, a long method + option.
final _widest = testPayment(
  id: 1234567,
  amount: '12345678.90',
  unapplied: '12345678.90',
  currency: Currency.usd,
  methodCode: 4,
  paymentOptionId: 3,
  reference: 'SPEI 20261027 0123456789 TRANSFERENCIA INTERBANCARIA',
  type: PaymentType.paymentInAdvance,
);

void stubSearch(MockCustomerPaymentRepository repository) =>
    when(
      () => repository.searchAcrossFacilities(
        customerId: any(named: 'customerId'),
        reference: any(named: 'reference'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CustomerPaymentListResult(items: [_widest], total: 1),
    );

/// The horizontal scroll extents inside the payments table: all (near) zero
/// means nothing scrolls sideways. Layout leaves floating-point dust (about
/// 2e-13), so the tests compare against half a pixel, not exactly zero.
List<double> _horizontalExtents(WidgetTester tester) => tester
    .stateList<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('payments_table')),
        matching: find.byType(Scrollable),
      ),
    )
    .where((s) => s.widget.axis == Axis.horizontal)
    .map((s) => s.position.maxScrollExtent)
    .toList();

void main() {
  late PaymentsMocks mocks;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    mocks = PaymentsMocks();
    stubPayments(mocks.payments, [_widest]);
    stubSearch(mocks.payments);
  });

  testWidgets('Expanded width, facility scope: the table does not scroll '
      'sideways and the amounts are shown in full', (tester) async {
    await pumpPayments(tester, mocks, user: _editor);
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('payments_table')), findsOneWidget);
    expect(_horizontalExtents(tester), everyElement(lessThan(0.5)));
    // Never ellipsized: the amount carries its currency code in full.
    expect(find.text(r'$12,345,678.90 USD'), findsWidgets);
  });

  testWidgets('Expanded width, all-facilities scope (one more column): the '
      'table still does not scroll sideways', (tester) async {
    await pumpPayments(
      tester,
      mocks,
      user: _editor,
      initialLocation: '/sales/payments?scope=all',
    );
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('payments_scope_switch')), findsOneWidget);
    expect(_horizontalExtents(tester), everyElement(lessThan(0.5)));
    expect(find.text(r'$12,345,678.90 USD'), findsWidgets);
  });

  for (final scope in ['', '?scope=all']) {
    testWidgets('phone width$scope: the list pumps with no overflow and keeps '
        'its filter button', (tester) async {
      await pumpPayments(
        tester,
        mocks,
        user: _editor,
        initialLocation: '/sales/payments$scope',
      );
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('payments_filter_button')), findsOneWidget);
      expect(find.byKey(const Key('payments_table')), findsOneWidget);
      // `DataTableView` has no card mode yet, so on a phone the table scrolls
      // sideways instead — and drops no column (wireframe Open Question 3).
      expect(_horizontalExtents(tester).first, greaterThan(0));
      for (final header in [
        l10n.paymentsColumnFolio,
        l10n.paymentsColumnDate,
        l10n.paymentsColumnCustomer,
        l10n.paymentsColumnAmount,
        l10n.paymentsColumnMethod,
        l10n.paymentsColumnReference,
        l10n.paymentsColumnType,
        l10n.paymentsColumnUnapplied,
        l10n.paymentsColumnVerified,
        if (scope.isNotEmpty) l10n.paymentsColumnFacility,
      ]) {
        expect(find.text(header), findsWidgets, reason: header);
      }
    });
  }
}
