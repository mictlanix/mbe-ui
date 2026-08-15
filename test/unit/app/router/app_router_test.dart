import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/core/widgets/app_shell.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_profile_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}

class MockLabelRepository extends Mock implements LabelRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

/// Bypasses `AuthNotifier.build()`'s real `TokenStorage`/`AuthRepository`
/// round-trip, resolving directly to a fixed [AuthState] — this test only
/// exercises `_redirect`'s access-control branch, not session restoration.
class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

const _mergeUser = User(
  userId: 'merger',
  email: 'merger@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.productsMerge, rawValue: 1), // create
  ],
);

const _noMergeUser = User(
  userId: 'no-merger',
  email: 'no-merger@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // Holds products/users read but not productsMerge.
  privileges: [
    Privilege(systemObject: SystemObject.products, rawValue: 2),
    Privilege(systemObject: SystemObject.users, rawValue: 2),
  ],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

const _noAccessUser = User(
  userId: 'no-access',
  email: 'no-access@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

/// Administrator flag set — the gate 024-user-profiles' `/user-profiles`
/// route actually checks (research.md §2), independent of any privilege row.
const _administratorUser = User(
  userId: 'administrator',
  email: 'administrator@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

/// Holds read on all five spec 012 catalogs.
const _catalogsReaderUser = User(
  userId: 'catalogs-reader',
  email: 'catalogs-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.suppliers, rawValue: 2),
    Privilege(systemObject: SystemObject.labels, rawValue: 2),
    Privilege(systemObject: SystemObject.employees, rawValue: 2),
    Privilege(systemObject: SystemObject.customers, rawValue: 2),
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 2),
  ],
);

/// Holds read on spec 015's two standalone catalogs (Payment Method Options,
/// Taxpayer Issuers). Certificates has no route/destination of its own
/// (research §9) — reached only through the already-gated issuer detail.
const _fiscalCatalogsReaderUser = User(
  userId: 'fiscal-catalogs-reader',
  email: 'fiscal-catalogs-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 2),
    Privilege(systemObject: SystemObject.taxpayers, rawValue: 2),
  ],
);

/// Holds read on `pos` (44) — the gate for 021-cash-sessions' `/sales/
/// cash-sessions` route (not `cashSessionClose`, which would lock out the
/// cashiers the screen exists for).
const _posReaderUser = User(
  userId: 'pos-reader',
  email: 'pos-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pos, rawValue: 2)],
);

/// Holds read on the three renumbered branches
/// (018-nested-facility-management contracts/routes.md §2:
/// facilities=14, paymentMethodOptions=15, taxpayerIssuers=16).
const _renumberedBranchesReaderUser = User(
  userId: 'renumbered-branches-reader',
  email: 'renumbered-branches-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.facilities, rawValue: 2),
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 2),
    Privilege(systemObject: SystemObject.taxpayers, rawValue: 2),
  ],
);

void main() {
  /// Pumps the real `goRouterProvider` (auth fixed via [_FixedAuthNotifier])
  /// and navigates to [location]. Deliberately uses bounded `pump()` calls
  /// rather than `pumpAndSettle()`: `_redirect` itself is synchronous once
  /// the auth state has resolved (the one `pumpAndSettle` below), so the
  /// redirect decision is available without waiting for a destination
  /// screen's own (unrelated, real-repository-backed) data to load —
  /// avoiding a dependency on mocking every screen's repositories just to
  /// check where the router landed.
  Future<GoRouterTestHandle> pumpAt(
    WidgetTester tester,
    User user,
    String location,
  ) async {
    final productRepository = MockProductRepository();
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        supplier: any(named: 'supplier'),
        labels: any(named: 'labels'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ProductListResult(items: [], total: 0));

    final userRepository = MockUserRepository();
    when(
      () => userRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const UserListResult(items: [], total: 0));

    // 024-user-profiles: the real UserProfilesListScreen (T017 onward)
    // fetches eagerly — added now so this shared file is edited once
    // (021-cash-sessions T016/T017 precedent).
    final userProfileRepository = MockUserProfileRepository();
    when(
      () => userProfileRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const UserProfileListResult(items: [], total: 0));
    when(() => userProfileRepository.get(profileId: any(named: 'profileId')))
        .thenAnswer(
          (_) async => const UserProfile(
            userProfileId: 5,
            name: 'Cashier',
            status: EntityStatus.active,
            privileges: [],
          ),
        );

    final supplierRepository = MockSupplierRepository();
    when(
      () => supplierRepository.listDetailed(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SupplierPage(items: [], total: 0));

    final labelRepository = MockLabelRepository();
    when(
      () => labelRepository.listDetailed(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const LabelPage(items: [], total: 0));

    final employeeRepository = MockEmployeeRepository();
    when(
      () => employeeRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        salesPerson: any(named: 'salesPerson'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const EmployeeListResult(items: [], total: 0));

    final customerRepository = MockCustomerRepository();
    when(
      () => customerRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        priceList: any(named: 'priceList'),
        salesperson: any(named: 'salesperson'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const CustomerPage(items: [], total: 0));

    final taxpayerRecipientRepository = MockTaxpayerRecipientRepository();
    when(
      () => taxpayerRecipientRepository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const TaxpayerRecipientPage(items: [], total: 0));

    final paymentMethodOptionRepository = MockPaymentMethodOptionRepository();
    when(
      () => paymentMethodOptionRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const PaymentMethodOptionPage(items: [], total: 0),
    );

    final taxpayerIssuerRepository = MockTaxpayerIssuerRepository();
    when(
      () => taxpayerIssuerRepository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const TaxpayerIssuerListResult(items: [], total: 0),
    );
    when(
      () => taxpayerIssuerRepository.listDetail(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const TaxpayerIssuerPage(items: [], total: 0));

    final facilityRepository = MockFacilityRepository();
    when(
      () => facilityRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const FacilityListResult(items: [], total: 0));

    // 021-cash-sessions: the real screen (T022 onward) watches
    // currentSessionControllerProvider, which calls getCurrent() eagerly —
    // without this override that spawns a real, unmocked network call whose
    // pending timer trips the leak detector at teardown (contracts/routes.md
    // §4). The current stub screen doesn't call it yet, but the override is
    // added now so this shared file is edited once, not twice.
    final cashSessionRepository = MockCashSessionRepository();
    when(() => cashSessionRepository.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.none),
    );

    // 023-pos-ux-improvements: `PosSalesListScreen` (T026 onward) watches
    // `PosSalesListController`, which calls `listSales` whenever the signed-in
    // user has a register configured. None of the fixture users below do
    // (`User.settings` is unset), so this override is unexercised for now —
    // added here, like `cashSessionRepository` above, so this shared file is
    // edited once rather than twice.
    final salesOrderRepository = MockSalesOrderRepository();
    when(
      () => salesOrderRepository.listSales(
        pointSale: any(named: 'pointSale'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));

    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user),
          ),
        ),
        // Destination screens for the "allowed" cases (/products, /users,
        // /products/merge, and the five spec 012 catalogs) fetch real data
        // eagerly — without these overrides they'd spawn a real, unmocked
        // network call whose pending timer trips flutter_test's leak
        // detector at teardown.
        productRepositoryProvider.overrideWithValue(productRepository),
        allLabelsProvider.overrideWith((_) async => const []),
        userRepositoryProvider.overrideWithValue(userRepository),
        userProfileRepositoryProvider.overrideWithValue(
          userProfileRepository,
        ),
        supplierRepositoryProvider.overrideWithValue(supplierRepository),
        labelRepositoryProvider.overrideWithValue(labelRepository),
        employeeRepositoryProvider.overrideWithValue(employeeRepository),
        customerRepositoryProvider.overrideWithValue(customerRepository),
        taxpayerRecipientRepositoryProvider.overrideWithValue(
          taxpayerRecipientRepository,
        ),
        paymentMethodOptionRepositoryProvider.overrideWithValue(
          paymentMethodOptionRepository,
        ),
        taxpayerIssuerRepositoryProvider.overrideWithValue(
          taxpayerIssuerRepository,
        ),
        facilityRepositoryProvider.overrideWithValue(facilityRepository),
        cashSessionRepositoryProvider.overrideWithValue(cashSessionRepository),
        salesOrderRepositoryProvider.overrideWithValue(salesOrderRepository),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go(location);
    await tester.pump();
    await tester.pump();

    return GoRouterTestHandle(router);
  }

  group(
    '/products/merge — productsMerge/create gate (specs/008-merge-products)',
    () {
      testWidgets('a user with productsMerge/create reaches /products/merge', (
        tester,
      ) async {
        final handle = await pumpAt(tester, _mergeUser, '/products/merge');
        expect(handle.router.state.uri.path, '/products/merge');
      });

      testWidgets(
        'a user without productsMerge/create is redirected to / (FR-012, '
        'deny-by-default)',
        (tester) async {
          final handle = await pumpAt(tester, _noMergeUser, '/products/merge');
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets('a user with no privileges at all is redirected to /', (
        tester,
      ) async {
        final handle = await pumpAt(tester, _noAccessUser, '/products/merge');
        expect(handle.router.state.uri.path, '/');
      });
    },
  );

  group(
    '/user-profiles — administrator gate, not a SystemObject '
    '(024-user-profiles research.md §2)',
    () {
      testWidgets('an administrator reaches /user-profiles', (tester) async {
        final handle = await pumpAt(
          tester,
          _administratorUser,
          '/user-profiles',
        );
        expect(handle.router.state.uri.path, '/user-profiles');
      });

      testWidgets(
        'a non-administrator holding users/read is redirected away from '
        '/user-profiles — the case most easily missed, since gating on '
        'SystemObject.users would let this exact user through',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _noMergeUser,
            '/user-profiles',
          );
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets('a user with no access at all is redirected away from '
          '/user-profiles', (tester) async {
        final handle = await pumpAt(tester, _noAccessUser, '/user-profiles');
        expect(handle.router.state.uri.path, '/');
      });

      testWidgets(
        'an administrator reaches /user-profiles/new',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _administratorUser,
            '/user-profiles/new',
          );
          expect(handle.router.state.uri.path, '/user-profiles/new');
        },
      );

      testWidgets(
        'a non-administrator is redirected away from /user-profiles/new',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _noMergeUser,
            '/user-profiles/new',
          );
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets(
        'an administrator reaches /user-profiles/:profileId',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _administratorUser,
            '/user-profiles/5',
          );
          expect(handle.router.state.uri.path, '/user-profiles/5');
        },
      );

      testWidgets(
        'a non-administrator is redirected away from '
        '/user-profiles/:profileId, not just the list route',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _noMergeUser,
            '/user-profiles/5',
          );
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets(
        'activates shell branch NavBranch.userProfiles (19) — the only '
        'guard against a silent branch-index mismatch',
        (tester) async {
          await pumpAt(tester, _administratorUser, '/user-profiles');
          final shell = tester.widget<AppShell>(find.byType(AppShell));
          expect(shell.navigationShell.currentIndex, NavBranch.userProfiles);
        },
      );
    },
  );

  group(
    'regression: existing routes still gate on Read (post-T023 refactor)',
    () {
      testWidgets('a read-only user still reaches /products', (tester) async {
        final handle = await pumpAt(tester, _readOnlyUser, '/products');
        expect(handle.router.state.uri.path, '/products');
      });

      testWidgets(
        'a user without products/read is redirected away from /products',
        (tester) async {
          final handle = await pumpAt(tester, _noAccessUser, '/products');
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets('a user with users/read still reaches /users', (
        tester,
      ) async {
        final handle = await pumpAt(tester, _noMergeUser, '/users');
        expect(handle.router.state.uri.path, '/users');
      });

      testWidgets('a user without users/read is redirected away from /users', (
        tester,
      ) async {
        final handle = await pumpAt(tester, _noAccessUser, '/users');
        expect(handle.router.state.uri.path, '/');
      });
    },
  );

  group(
    'spec 012 catalogs — Suppliers/Labels/Employees/Customers/Taxpayer '
    'Recipients each gate on their own SystemObject/read (FR-007, SC-006)',
    () {
      for (final route in [
        '/suppliers',
        '/labels',
        '/employees',
        '/customers',
        '/taxpayer-recipients',
      ]) {
        testWidgets('a user with read on $route reaches it', (tester) async {
          final handle = await pumpAt(tester, _catalogsReaderUser, route);
          expect(handle.router.state.uri.path, route);
        });

        testWidgets('a user without read is redirected away from $route', (
          tester,
        ) async {
          final handle = await pumpAt(tester, _noAccessUser, route);
          expect(handle.router.state.uri.path, '/');
        });
      }
    },
  );

  group(
    'spec 015 fiscal catalogs — Payment Method Options/Taxpayer Issuers each '
    'gate on their own SystemObject/read (FR-009, FR-018, SC-007)',
    () {
      for (final route in ['/payment-method-options', '/taxpayer-issuers']) {
        testWidgets('a user with read on $route reaches it', (tester) async {
          final handle = await pumpAt(tester, _fiscalCatalogsReaderUser, route);
          expect(handle.router.state.uri.path, route);
        });

        testWidgets('a user without read is redirected away from $route', (
          tester,
        ) async {
          final handle = await pumpAt(tester, _noAccessUser, route);
          expect(handle.router.state.uri.path, '/');
        });
      }

      // Taxpayer Certificates has no route of its own — it is a child
      // section of the Taxpayer Issuer detail (research §9), so there is
      // nothing to gate independently here; its RBAC is exercised by the
      // Certificates section's own widget tests instead.
    },
  );

  group(
    '021-cash-sessions — /sales/cash-sessions gates on pos/read (FR-036, '
    'contracts/routes.md §2)',
    () {
      testWidgets('a user with pos:read reaches /sales/cash-sessions', (
        tester,
      ) async {
        final handle = await pumpAt(
          tester,
          _posReaderUser,
          '/sales/cash-sessions',
        );
        expect(handle.router.state.uri.path, '/sales/cash-sessions');
      });

      testWidgets(
        'a user without pos:read is redirected away from '
        '/sales/cash-sessions',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _noAccessUser,
            '/sales/cash-sessions',
          );
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets(
        'the detail route /sales/cash-sessions/:cashSessionId parses its '
        'int param and gates identically to the list route',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _posReaderUser,
            '/sales/cash-sessions/42',
          );
          expect(handle.router.state.uri.path, '/sales/cash-sessions/42');
        },
      );

      testWidgets(
        'a user without pos:read is redirected away from the detail route '
        'too',
        (tester) async {
          final handle = await pumpAt(
            tester,
            _noAccessUser,
            '/sales/cash-sessions/42',
          );
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets(
        'activates shell branch NavBranch.cashSessions (17) — the only '
        'guard against a silent branch-index mismatch (contracts/routes.md '
        '§3)',
        (tester) async {
          await pumpAt(tester, _posReaderUser, '/sales/cash-sessions');
          final shell = tester.widget<AppShell>(find.byType(AppShell));
          expect(shell.navigationShell.currentIndex, NavBranch.cashSessions);
        },
      );
    },
  );

  group(
    '023-pos-ux-improvements — /sales/pos is the sales list (in the shell), '
    'the sale workspace moved to top-level sibling routes (research R1, '
    'contracts/pos-workspace.md §1)',
    () {
      testWidgets('a user with pos:read reaches /sales/pos (the sales list)', (
        tester,
      ) async {
        final handle = await pumpAt(tester, _posReaderUser, '/sales/pos');
        expect(handle.router.state.uri.path, '/sales/pos');
      });

      testWidgets(
        'a user without pos:read is redirected away from /sales/pos',
        (tester) async {
          final handle = await pumpAt(tester, _noAccessUser, '/sales/pos');
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets(
        'activates shell branch NavBranch.pos (18) for /sales/pos — the '
        'branch itself is unchanged; only what it renders moved',
        (tester) async {
          await pumpAt(tester, _posReaderUser, '/sales/pos');
          final shell = tester.widget<AppShell>(find.byType(AppShell));
          expect(shell.navigationShell.currentIndex, NavBranch.pos);
        },
      );

      testWidgets(
        'a user with pos:read reaches /sales/pos/new — the sale workspace, '
        'a top-level route with no shell around it',
        (tester) async {
          final handle = await pumpAt(tester, _posReaderUser, '/sales/pos/new');
          expect(handle.router.state.uri.path, '/sales/pos/new');
          // The initial `/` page's AppShell is still mid-exit-transition
          // right after `pumpAt`'s two bounded `pump()`s (which are enough
          // for `_redirect`'s own synchronous decision, but not for a page
          // transition to finish) — settle before asserting on the tree.
          await tester.pumpAndSettle();
          expect(find.byType(AppShell), findsNothing);
        },
      );

      testWidgets(
        'a user without pos:read is redirected away from /sales/pos/new',
        (tester) async {
          final handle = await pumpAt(tester, _noAccessUser, '/sales/pos/new');
          expect(handle.router.state.uri.path, '/');
        },
      );

      testWidgets(
        'the workspace route /sales/pos/:saleId parses its int param, gates '
        'identically to /new, and also renders with no shell',
        (tester) async {
          final handle = await pumpAt(tester, _posReaderUser, '/sales/pos/42');
          expect(handle.router.state.uri.path, '/sales/pos/42');
          await tester.pumpAndSettle();
          expect(find.byType(AppShell), findsNothing);
        },
      );

      testWidgets(
        'a user without pos:read is redirected away from /sales/pos/:saleId too',
        (tester) async {
          final handle = await pumpAt(tester, _noAccessUser, '/sales/pos/42');
          expect(handle.router.state.uri.path, '/');
        },
      );
    },
  );

  group('018-nested-facility-management — NavBranch renumbering matches the '
      "shell's actual branch order (contracts/routes.md §2)", () {
    // The renumbering invariant (NavBranch.X == that destination's real
    // position among StatefulShellRoute branches) has no compile-time
    // enforcement — nav_destinations.dart and app_router.dart are two
    // hand-maintained lists that must stay in lockstep. Scoped to the
    // three destinations this feature actually renumbered (facilities,
    // paymentMethodOptions, taxpayerIssuers) rather than every
    // destination in kNavigationTree: the unrenumbered branches (pricing,
    // exchangeRates, expenses, vehicles, …) aren't mocked in this file's
    // `pumpAt`, and exhaustive coverage of branches this feature never
    // touched belongs to a broader nav-tree regression test, not here.
    final renumbered = _flattenDestinations(kNavigationTree).where(
      (d) => const {
        'facilities',
        'payment-method-options',
        'taxpayer-issuers',
      }.contains(d.id),
    );

    for (final destination in renumbered) {
      testWidgets('${destination.id} (branchIndex ${destination.branchIndex}) '
          'activates that exact shell branch', (tester) async {
        final handle = await pumpAt(
          tester,
          _renumberedBranchesReaderUser,
          destination.route,
        );
        expect(handle.router.state.uri.path, destination.route);
        final shell = tester.widget<AppShell>(find.byType(AppShell));
        expect(shell.navigationShell.currentIndex, destination.branchIndex);
      });
    }
  });

  group('018-nested-facility-management — removed list routes; surviving '
      'detail routes keep their guards (contracts/routes.md §5)', () {
    // A reader who holds warehouses/cashDrawers/pointsOfSale read but not
    // facilities:read (_childObjectsReaderUser) is the scenario FR-002's
    // "no longer resolves" is really about — but that user is exactly the
    // case the guard clause does NOT block, so GoRouter is left trying to
    // match an authorized location against a route that no longer exists
    // at all, which throws inside GoRouter itself rather than producing
    // an observable redirect. `_noAccessUser` below proves the same
    // FR-002 outcome (nothing resolves at these three bare paths) via the
    // path GoRouter actually handles gracefully: deny-by-default redirect.
    testWidgets('/warehouses no longer resolves to a list screen', (
      tester,
    ) async {
      final handle = await pumpAt(tester, _noAccessUser, '/warehouses');
      expect(handle.router.state.uri.path, '/');
    });

    testWidgets('/cash-drawers no longer resolves to a list screen', (
      tester,
    ) async {
      final handle = await pumpAt(tester, _noAccessUser, '/cash-drawers');
      expect(handle.router.state.uri.path, '/');
    });

    testWidgets('/points-of-sale no longer resolves to a list screen', (
      tester,
    ) async {
      final handle = await pumpAt(tester, _noAccessUser, '/points-of-sale');
      expect(handle.router.state.uri.path, '/');
    });

    // The highest-risk edit in this feature (research §4): the three
    // `_gateFor` clauses matching `startsWith('/warehouses')` etc. gate
    // the record detail routes too, not just the deleted list route. It
    // is the intuitive (and wrong) move to delete them alongside the list
    // screens — doing so would silently strip RBAC from every surviving
    // warehouse/cash-drawer/point-of-sale record screen with no crash and
    // no other failing test. These three assertions are what stand
    // between that mistake and a green suite.
    testWidgets('a user without warehouses:read is redirected away from '
        '/warehouses/5, not just /warehouses', (tester) async {
      final handle = await pumpAt(tester, _noAccessUser, '/warehouses/5');
      expect(handle.router.state.uri.path, '/');
    });

    testWidgets('a user without cashDrawers:read is redirected away from '
        '/cash-drawers/5', (tester) async {
      final handle = await pumpAt(tester, _noAccessUser, '/cash-drawers/5');
      expect(handle.router.state.uri.path, '/');
    });

    testWidgets('a user without pointsOfSale:read is redirected away from '
        '/points-of-sale/5', (tester) async {
      final handle = await pumpAt(tester, _noAccessUser, '/points-of-sale/5');
      expect(handle.router.state.uri.path, '/');
    });
  });
}

/// Flattens [kNavigationTree] to its leaf [NavDestination]s, in the same
/// order the tree lists them — [NavGroup.children] is already a flat
/// `List<NavDestination>` (no nested groups), so this is a single pass.
List<NavDestination> _flattenDestinations(List<NavItem> tree) {
  final result = <NavDestination>[];
  for (final item in tree) {
    switch (item) {
      case NavDestination():
        result.add(item);
      case NavGroup():
        result.addAll(item.children);
    }
  }
  return result;
}

/// Thin wrapper so `pumpAt`'s return type stays self-describing at call
/// sites (`handle.router.state.uri.path`).
class GoRouterTestHandle {
  GoRouterTestHandle(this.router);

  final GoRouter router;
}
