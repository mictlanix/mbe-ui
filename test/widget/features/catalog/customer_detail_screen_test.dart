import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

const _editor = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 15)],
);

const _customer = Customer(
  customerId: 1,
  code: 'CUST-001',
  name: 'Acme Corp',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  status: EntityStatus.active,
);

/// The customer's full-screen surface (046-catalog-improvements,
/// constitution §VI v1.13.3).
void main() {
  late MockCustomerRepository repository;

  setUp(() {
    repository = MockCustomerRepository();
    when(
      () => repository.get(customerId: 1),
    ).thenAnswer((_) async => _customer);
  });

  Future<GoRouter> pumpAt(WidgetTester tester, String location) async {
    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      initialLocation: '/customers',
      routes: [
        GoRoute(
          path: '/customers',
          builder: (_, _) => const Scaffold(body: Text('customers list')),
        ),
        GoRoute(
          path: '/customers/new',
          builder: (_, _) => const CustomerDetailScreen(),
        ),
        GoRoute(
          path: '/customers/:customerId',
          builder: (_, state) => CustomerDetailScreen(
            customerId: int.parse(state.pathParameters['customerId']!),
            forceReadOnly: state.uri.queryParameters['view'] == 'true',
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          customerRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(token: 't', user: _editor),
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push(location);
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('a row click\'s read-only screen is titled "View", and Edit '
      'opens the same customer editable, titled "Edit"', (tester) async {
    final router = await pumpAt(tester, '/customers/1?view=true');

    expect(find.text('View customer'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('code_field'))).enabled,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('edit_customer_button')));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/customers/1');
    expect(find.text('Edit customer'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('code_field'))).enabled,
      isTrue,
    );
  });

  testWidgets('create mode is titled "New"', (tester) async {
    await pumpAt(tester, '/customers/new');

    expect(find.text('New customer'), findsOneWidget);
  });

  testWidgets('leaving with no edits goes straight back to the list', (
    tester,
  ) async {
    await pumpAt(tester, '/customers/1');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('customers list'), findsOneWidget);
  });

  testWidgets('leaving with unsaved edits asks first; cancelling stays, '
      'discarding leaves (spec 035 FR-032)', (tester) async {
    await pumpAt(tester, '/customers/1');
    await tester.enterText(find.byKey(const Key('zone_field')), 'Norte');
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('record_sheet_discard_dialog')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('record_sheet_discard_cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Edit customer'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record_sheet_discard_confirm')));
    await tester.pumpAndSettle();
    expect(find.text('customers list'), findsOneWidget);
  });
}
