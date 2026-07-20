import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/suppliers_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 15)],
);

const _testSuppliers = [
  Supplier(
    supplierId: 1,
    code: 'SUP-001',
    name: 'Acme Corp',
    creditLimit: '1000.50',
    creditDays: 30,
  ),
  Supplier(
    supplierId: 2,
    code: 'SUP-002',
    name: 'Beta Supplies',
    creditLimit: '0',
    creditDays: 0,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockSupplierRepository repository;

  setUp(() {
    repository = MockSupplierRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<Supplier> suppliers = _testSuppliers,
  }) async {
    when(
      () => repository.listDetailed(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => SupplierPage(items: suppliers, total: suppliers.length),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SuppliersListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows code and name for every supplier', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('SUP-001'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('SUP-002'), findsOneWidget);
    expect(find.text('Beta Supplies'), findsOneWidget);
  });

  testWidgets('search box and pagination are present', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('suppliers_search_field')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
  });

  testWidgets(
    'the Edit row icon is hidden (not disabled) without update privilege '
    '(constitution §VI)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    },
  );

  testWidgets('the Edit row icon appears with update privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
  });

  testWidgets('the Create button is hidden without create privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('new_supplier_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.listDetailed(
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            SupplierPage(items: _testSuppliers, total: _testSuppliers.length),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: SuppliersListScreen()),
          ),
          GoRoute(
            path: '/suppliers/:supplierId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supplierRepositoryProvider.overrideWithValue(repository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
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

      await tester.tap(find.text('Acme Corp'));
      await tester.pumpAndSettle();

      expect(find.text('/suppliers/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, suppliers: const []);

    expect(find.byKey(const Key('suppliers_table')), findsNothing);
  });
}
