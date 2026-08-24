import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_controller.dart';

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

User _user({required bool administrator, int? facilityId}) => User(
  userId: administrator ? 'admin-1' : 'user-1',
  email: 'user@example.com',
  administrator: administrator,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: facilityId == null ? null : UserSettings(facilityId: facilityId),
  privileges: const [],
);

SalesOrdersFilter _filter({
  int? salesperson,
  int? facility,
}) => SalesOrdersFilter(
  from: DateTime(2026, 8, 1),
  to: DateTime(2026, 8, 31),
  salesperson: salesperson,
  facility: facility,
);

/// FR-006, FR-011, SC-009 (spec 029): `mine` follows the caller's own role,
/// never the URL; `salesperson`/`facility` reach the request only for an
/// administrator — dropped here independently of `SalesOrdersFilter.
/// fromQuery`'s own decode rule (`sales_orders_filter_test.dart` already
/// covers that layer), so a filter object built any other way still can't
/// leak another user's or facility's orders to an ordinary caller.
void main() {
  late MockSalesOrderRepository repository;

  setUp(() {
    repository = MockSalesOrderRepository();
    when(
      () => repository.listOrders(
        mine: any(named: 'mine'),
        facility: any(named: 'facility'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));
  });

  ProviderContainer container({required User user}) {
    final c = ProviderContainer(
      overrides: [
        salesOrderRepositoryProvider.overrideWithValue(repository),
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: user)),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('mine is true and salesperson/facility are dropped for an ordinary '
      'user, even when the filter itself carries them (the hand-edited-'
      'address edge case, SC-009)', () async {
    final c = container(user: _user(administrator: false, facilityId: 9));

    await c.read(
      salesOrdersListControllerProvider(
        _filter(salesperson: 100, facility: 5),
        false,
      ).future,
    );

    verify(
      () => repository.listOrders(
        mine: true,
        facility: null,
        salesperson: null,
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });

  test('mine is false for an administrator, and an explicit salesperson/'
      'facility facet reaches the request', () async {
    final c = container(user: _user(administrator: true, facilityId: 9));

    await c.read(
      salesOrdersListControllerProvider(
        _filter(salesperson: 100, facility: 5),
        true,
      ).future,
    );

    verify(
      () => repository.listOrders(
        mine: false,
        facility: 5,
        salesperson: 100,
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });

  test('an administrator with no facility facet set still scopes to their '
      'own facility — never every facility unscoped (US5 scenario 1)', () async {
    final c = container(user: _user(administrator: true, facilityId: 9));
    // `userFacilityIdProvider` reads through the async `authNotifierProvider`
    // — settle it first, or `_fetch` reads it mid-`loading` and treats the
    // caller as having no facility at all.
    await c.read(authNotifierProvider.future);

    await c.read(
      salesOrdersListControllerProvider(_filter(), true).future,
    );

    verify(
      () => repository.listOrders(
        mine: false,
        facility: 9,
        salesperson: null,
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });
}
