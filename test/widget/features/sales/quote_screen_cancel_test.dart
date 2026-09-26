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
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

class MockCustomerRepository extends Mock implements CustomerRepository {}

const _updaterUser = User(
  userId: 'quote-updater',
  email: 'quote-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesQuotes, rawValue: 4)],
);

const _readOnlyUser = User(
  userId: 'quote-reader',
  email: 'quote-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesQuotes, rawValue: 1)],
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// Spec 040 FR-032: cancel is offered on a draft or a confirmed quote,
/// never on an already-cancelled one, always behind an explicit
/// confirmation dialog, and a server refusal leaves the quote untouched
/// with the reason on screen — mirrors `order_workspace_cancel_test.dart`'s
/// own shape, widened for the one difference FR-032 states explicitly: a
/// *confirmed* quote is cancellable too, not only a draft.
void main() {
  late MockSalesQuoteRepository salesQuotes;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesQuotes = MockSalesQuoteRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
  });

  Future<void> pumpQuote(WidgetTester tester, {User? user}) async {
    await pumpQuotesRouted(
      tester,
      initialLocation: '/sales/quotes/30',
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user ?? _updaterUser),
          ),
        ),
        salesQuoteOverride(salesQuotes),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
      ],
    );
  }

  Sale quote({SaleStatus status = SaleStatus.draft}) =>
      testQuote(id: 30, customer: 7, status: status);

  final cancelAction = find.byKey(const Key('sales_quote_cancel_button'));

  testWidgets('the cancel action is absent without update rights', (
    tester,
  ) async {
    when(() => salesQuotes.getById(quoteId: 30)).thenAnswer((_) async => quote());

    await pumpQuote(tester, user: _readOnlyUser);

    expect(cancelAction, findsNothing);
  });

  testWidgets('offered on a draft', (tester) async {
    when(() => salesQuotes.getById(quoteId: 30)).thenAnswer((_) async => quote());

    await pumpQuote(tester);

    expect(cancelAction, findsOneWidget);
  });

  testWidgets('offered on a confirmed quote too (FR-032)', (tester) async {
    when(
      () => salesQuotes.getById(quoteId: 30),
    ).thenAnswer((_) async => quote(status: SaleStatus.completed));

    await pumpQuote(tester);

    expect(cancelAction, findsOneWidget);
  });

  testWidgets('an already-cancelled quote offers no destructive action', (
    tester,
  ) async {
    when(
      () => salesQuotes.getById(quoteId: 30),
    ).thenAnswer((_) async => quote(status: SaleStatus.cancelled));

    await pumpQuote(tester);

    expect(cancelAction, findsNothing);
  });

  testWidgets('cancelling requires an explicit confirmation dialog', (
    tester,
  ) async {
    when(() => salesQuotes.getById(quoteId: 30)).thenAnswer((_) async => quote());

    await pumpQuote(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();

    expect(find.text(l10n.salesQuoteCancelDialogTitle), findsOneWidget);
    verifyNever(() => salesQuotes.cancel(quoteId: any(named: 'quoteId')));
  });

  testWidgets('dismissing the dialog cancels nothing', (tester) async {
    when(() => salesQuotes.getById(quoteId: 30)).thenAnswer((_) async => quote());

    await pumpQuote(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.salesQuoteCancelDialogKeepEditing));
    await tester.pumpAndSettle();

    verifyNever(() => salesQuotes.cancel(quoteId: any(named: 'quoteId')));
    expect(cancelAction, findsOneWidget);
  });

  testWidgets('confirming the dialog cancels the quote and withdraws the '
      'action', (tester) async {
    when(
      () => salesQuotes.getById(quoteId: 30),
    ).thenAnswer((_) async => quote());
    when(
      () => salesQuotes.cancel(quoteId: 30),
    ).thenAnswer((_) async => quote(status: SaleStatus.cancelled));

    await pumpQuote(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('sales_quote_cancel_confirm_button')),
    );
    await tester.pumpAndSettle();

    verify(() => salesQuotes.cancel(quoteId: 30)).called(1);
    expect(cancelAction, findsNothing);
  });

  testWidgets('a refused cancel keeps the quote untouched with the reason '
      'shown', (tester) async {
    when(() => salesQuotes.getById(quoteId: 30)).thenAnswer((_) async => quote());
    when(() => salesQuotes.cancel(quoteId: 30)).thenThrow(
      const AppError.server(message: 'A cancelled quote cannot be cancelled again'),
    );

    await pumpQuote(tester);
    await tester.tap(cancelAction);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('sales_quote_cancel_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('A cancelled quote cannot be cancelled again'),
      findsOneWidget,
    );
    expect(
      cancelAction,
      findsOneWidget,
      reason: 'the quote is still a draft — cancel is still offered',
    );
  });
}
