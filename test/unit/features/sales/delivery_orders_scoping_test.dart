import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';

class MockDeliveryOrderAdminRepository extends Mock
    implements DeliveryOrderAdminRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

User _user({
  required bool administrator,
  int? facilityId,
  SystemObject? readOn,
}) => User(
  userId: administrator ? 'admin-1' : 'user-1',
  email: 'user@example.com',
  administrator: administrator,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: facilityId == null ? null : UserSettings(facilityId: facilityId),
  privileges: [
    if (readOn != null) Privilege(systemObject: readOn, rawValue: 2),
  ],
);

/// Spec 061 research R3: the `facility` of a user who sees only their own
/// facility is dropped twice —
/// when the URL is decoded and again when the request is built. The server
/// checks it too since mbe-api#314; these stay as defence in depth. Each site
/// is pinned on its own here, so removing either one fails a test.
void main() {
  late MockDeliveryOrderAdminRepository repository;

  setUp(() {
    repository = MockDeliveryOrderAdminRepository();
    when(
      () => repository.list(
        statuses: any(named: 'statuses'),
        customer: any(named: 'customer'),
        facility: any(named: 'facility'),
        type: any(named: 'type'),
        salesOrder: any(named: 'salesOrder'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const DeliveryOrderPage(items: [], total: 0));
  });

  Future<ProviderContainer> container({required User user}) async {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        deliveryOrderAdminRepositoryProvider.overrideWithValue(repository),
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    // `userFacilityIdProvider` and `accessControlProvider` read through the
    // async `authProvider`: settle it first.
    await c.read(authProvider.future);
    return c;
  }

  Future<void> load(ProviderContainer c, DeliveryOrdersFilter filter) =>
      c.read(deliveryOrdersListControllerProvider(filter).future);

  void verifyFacility(int? facility) => verify(
    () => repository.list(
      statuses: any(named: 'statuses'),
      customer: any(named: 'customer'),
      facility: facility,
      type: any(named: 'type'),
      salesOrder: any(named: 'salesOrder'),
      dateFrom: any(named: 'dateFrom'),
      dateTo: any(named: 'dateTo'),
      search: any(named: 'search'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).called(1);

  final urlWithFacility = const ListQuery().withFacet('facility', '5');

  group('a non-administrator', () {
    test('a facility in the URL reaches neither the filter nor the '
        'request', () async {
      final c = await container(
        user: _user(administrator: false, facilityId: 9),
      );
      final filter = DeliveryOrdersFilter.fromQuery(
        urlWithFacility,
        seesEveryFacility: seesEveryFacilitysDeliveryOrders(
          c.read(accessControlProvider),
        ),
      );

      expect(filter.facilityId, isNull);
      await load(c, filter);
      verifyFacility(null);
    });

    test('a filter built directly with a facility still sends none (the '
        'second drop)', () async {
      final c = await container(
        user: _user(administrator: false, facilityId: 9),
      );

      await load(c, const DeliveryOrdersFilter(facilityId: 5));

      verifyFacility(null);
    });
  });

  // mbe-api#314: administrators, and read on SearchCreditsFromAllStores (101)
  // or DeliveryItineraries (87).
  for (final (label, user) in [
    ('an administrator', _user(administrator: true, facilityId: 9)),
    (
      'read on SearchCreditsFromAllStores (101)',
      _user(
        administrator: false,
        facilityId: 9,
        readOn: SystemObject.searchCreditsFromAllStores,
      ),
    ),
    (
      'read on DeliveryItineraries (87)',
      _user(
        administrator: false,
        facilityId: 9,
        readOn: SystemObject.deliveryItineraries,
      ),
    ),
  ]) {
    test('for $label a facility in the URL reaches the filter and the '
        'request', () async {
      final c = await container(user: user);
      final filter = DeliveryOrdersFilter.fromQuery(
        urlWithFacility,
        seesEveryFacility: seesEveryFacilitysDeliveryOrders(
          c.read(accessControlProvider),
        ),
      );

      expect(filter.facilityId, 5);
      await load(c, filter);
      verifyFacility(5);
    });
  }

  test('with no facility on the account, no request is sent, administrators '
      'included', () async {
    for (final administrator in [false, true]) {
      final c = await container(user: _user(administrator: administrator));

      final page = await c.read(
        deliveryOrdersListControllerProvider(
          const DeliveryOrdersFilter(),
        ).future,
      );

      expect(page.items, isEmpty);
      expect(page.total, 0);
    }
    verifyNever(
      () => repository.list(
        statuses: any(named: 'statuses'),
        customer: any(named: 'customer'),
        facility: any(named: 'facility'),
        type: any(named: 'type'),
        salesOrder: any(named: 'salesOrder'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    );
  });
}
