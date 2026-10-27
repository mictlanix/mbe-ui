import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/repositories/credit_note_repository.dart';
import 'package:mbe_ui/features/sales/presentation/credit_notes/credit_notes_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCreditNoteRepository extends Mock implements CreditNoteRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Spec 056 US3: the "Notas de crédito" list — columns and figures as the
/// server sent them, no search box, the drawer's two facets, its states, and
/// what a row tap and the origin link need.
void main() {
  late MockCreditNoteRepository repository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => repository = MockCreditNoteRepository());

  CreditNote note(
    int id, {
    String issued = '27.00',
    String remaining = '3.00',
    int customer = 7,
  }) => CreditNote(
    id: id,
    customerId: customer,
    salesOrderId: 3000 + id,
    customerRefundId: 4000 + id,
    customerPaymentId: 5000 + id,
    issued: issued,
    remaining: remaining,
    date: DateTime(2026, 9, 29, 12, 55),
  );

  void serve(List<CreditNote> notes, {int? total}) {
    when(
      () => repository.list(
        customerId: any(named: 'customerId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          CreditNoteListResult(items: notes, total: total ?? notes.length),
    );
    when(
      () => repository.listForCustomer(any()),
    ).thenAnswer((_) async => notes);
  }

  User user({bool creditRead = true, bool paymentsRead = true}) => User(
    userId: 'u',
    email: 'u@example.com',
    administrator: false,
    status: EntityStatus.active,
    sessionVersion: 1,
    privileges: [
      if (creditRead)
        const Privilege(systemObject: SystemObject.creditPayments, rawValue: 2),
      if (paymentsRead)
        const Privilege(
          systemObject: SystemObject.customerPayments,
          rawValue: 2,
        ),
    ],
  );

  Future<GoRouter> pumpList(
    WidgetTester tester, {
    User? who,
    String location = '/sales/credit-notes',
    bool ordersOpenable = false,
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: who ?? user()),
          ),
        ),
        creditNoteRepositoryProvider.overrideWithValue(repository),
        customerDisplayNameProvider.overrideWith(
          (ref, id) async => 'Cliente $id',
        ),
        orderLinkTargetProvider.overrideWith(
          (ref, id) async => ordersOpenable ? '/sales/orders/$id' : null,
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/sales/credit-notes',
          builder: (context, state) => Scaffold(
            body: CreditNotesListScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
        GoRoute(
          path: '/sales/payments/:paymentId',
          builder: (context, state) => Scaffold(
            body: Text('payment-${state.pathParameters['paymentId']}'),
          ),
        ),
        GoRoute(
          path: '/sales/orders/:id',
          builder: (context, state) =>
              Scaffold(body: Text('order-${state.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('shows the five columns, with the figures exactly as sent', (
    tester,
  ) async {
    serve([
      note(1, issued: '1025.00', remaining: '1025.00'),
      // A legacy note as mbe-api reports it today (mbe-api#277): nothing
      // issued, nothing left. Shown as-is, not "corrected".
      note(2, issued: '0.000000', remaining: '0'),
    ]);
    await pumpList(tester);

    for (final header in [
      l10n.creditNotesColumnDate,
      l10n.creditNotesColumnCustomer,
      l10n.creditNotesColumnOrigin,
      l10n.creditNotesColumnIssued,
      l10n.creditNotesColumnRemaining,
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('Cliente 7'), findsNWidgets(2));
    expect(find.text('\$1,025.00'), findsNWidgets(2));
    expect(find.text('\$0.00'), findsNWidgets(2));
    expect(find.text(l10n.creditNotesOrigin(4001, 3001)), findsOneWidget);
    expect(find.text(l10n.creditNotesOrigin(4002, 3002)), findsOneWidget);
  });

  testWidgets('amounts and origin are never ellipsized', (tester) async {
    serve([note(1, issued: '1234567.89', remaining: '1234567.89')]);
    await pumpList(tester);

    for (final text in [
      find.text('\$1,234,567.89'),
      find.text(l10n.creditNotesOrigin(4001, 3001)),
    ]) {
      for (final widget in tester.widgetList<Text>(text)) {
        expect(widget.overflow, isNot(TextOverflow.ellipsis));
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('has no search box: the endpoint has no free-text search', (
    tester,
  ) async {
    serve([note(1)]);
    await pumpList(tester);

    expect(find.byType(CatalogSearchBar), findsNothing);
    expect(find.byKey(const Key('credit_notes_filter_button')), findsOneWidget);
  });

  testWidgets('the drawer offers the customer and the balance switch', (
    tester,
  ) async {
    serve([note(1)]);
    await pumpList(tester);

    await tester.tap(find.byKey(const Key('credit_notes_filter_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('credit_notes_customer_filter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('credit_notes_open_only_filter')),
      findsOneWidget,
    );
    expect(find.text(l10n.creditNotesOpenOnlyFilter), findsOneWidget);
  });

  testWidgets('turning the balance switch on writes it to the address', (
    tester,
  ) async {
    serve([note(1)]);
    final router = await pumpList(tester);

    await tester.tap(find.byKey(const Key('credit_notes_filter_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('credit_notes_open_only_filter')));
    await tester.pumpAndSettle();

    expect(router.state.uri.queryParameters['open'], '1');
  });

  testWidgets('shows the empty state when there are no notes', (tester) async {
    serve(const []);
    await pumpList(tester);

    expect(find.text(l10n.creditNotesEmpty), findsOneWidget);
  });

  testWidgets('shows the filtered-empty state, with a way to clear it', (
    tester,
  ) async {
    serve(const []);
    await pumpList(tester, location: '/sales/credit-notes?open=1');

    expect(find.text(l10n.creditNotesEmpty), findsNothing);
    expect(find.text(l10n.clearFiltersButton), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    when(
      () => repository.list(
        customerId: any(named: 'customerId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const AppError.network());
    await pumpList(tester);

    expect(find.text(l10n.retryButton), findsOneWidget);
  });

  testWidgets('a 403 says so, with nothing to retry', (tester) async {
    when(
      () => repository.list(
        customerId: any(named: 'customerId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const AppError.server(statusCode: 403));
    await pumpList(tester);

    expect(find.byKey(const Key('credit_notes_forbidden')), findsOneWidget);
    expect(find.text(l10n.retryButton), findsNothing);
  });

  group('a row', () {
    testWidgets('opens the backing payment with customer-payments read', (
      tester,
    ) async {
      serve([note(1)]);
      final router = await pumpList(tester);

      await tester.tap(find.text('Cliente 7'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/payments/5001');
    });

    testWidgets('is not tappable without customer-payments read (FR-012)', (
      tester,
    ) async {
      serve([note(1)]);
      final router = await pumpList(tester, who: user(paymentsRead: false));

      await tester.tap(find.text('Cliente 7'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/credit-notes');
    });
  });

  group('the origin\'s order', () {
    testWidgets('is a link when the user can open it', (tester) async {
      serve([note(1)]);
      final router = await pumpList(tester, ordersOpenable: true);

      final link = find.byKey(const Key('credit_note_order_link_3001'));
      expect(link, findsOneWidget);
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/orders/3001');
    });

    testWidgets('is plain text when the user cannot', (tester) async {
      serve([note(1)]);
      await pumpList(tester);

      expect(
        find.byKey(const Key('credit_note_order_link_3001')),
        findsNothing,
      );
      expect(find.text(l10n.creditNotesOrigin(4001, 3001)), findsOneWidget);
    });
  });
}
