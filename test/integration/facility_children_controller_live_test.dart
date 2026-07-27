import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_children.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_children_controller.dart';

/// One-off live-backend smoke check for `FacilityChildrenController`
/// (018-nested-facility-management quickstart.md Gate 1) — this controller
/// is new code that had never touched a real mbe-api response shape before
/// this run; every prior test used mocked repositories. Fetches the real
/// first page of facilities and runs the actual fetch-by-type logic
/// (research §2) against each one, confirming the wire format matches the
/// domain-entity mapping with no surprises.
///
/// Skipped entirely when credentials aren't provided — read-only, but still
/// requires a real environment.
const _username = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');
const _canRun = _username != '' && _password != '';

void main() {
  test('FacilityChildrenController resolves real facilities correctly', () async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';

    final facilityRepository = FacilityRepositoryImpl(dio);
    final facilities = await facilityRepository.list(limit: 20);
    expect(facilities.items, isNotEmpty);

    // FacilityChildrenController also reads accessControlProvider — a bare
    // container defaults to unauthenticated (every `can()` false), which
    // would silently skip every fetch. administrator: true short-circuits
    // AccessControlService.can() regardless of the specific User fields, so
    // this doesn't need to mirror the real account's actual privilege rows.
    const adminUser = User(
      userId: 'live-check',
      email: 'live-check@example.com',
      administrator: true,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: [],
    );
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(token: token, user: adminUser),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Concurrent, not sequential — this is what the real app does: every
    // FacilityCard watches its own provider independently, all in the same
    // frame (research §1's non-lazy card list), so all facilities' children
    // requests fire together rather than waiting on each other in turn.
    final allChildren = await Future.wait([
      for (final facility in facilities.items)
        container.read(
          facilityChildrenControllerProvider(
            facility.facilityId,
            facility.type,
          ).future,
        ),
    ]);

    for (var i = 0; i < facilities.items.length; i++) {
      final facility = facilities.items[i];
      final children = allChildren[i];

      expect(children.facilityId, facility.facilityId);
      // Fetch-by-type (research §2): a production site never has points of
      // sale or cash drawers, by the domain invariant this feature codifies.
      if (facility.type == FacilityType.productionSite) {
        expect(children.pointsOfSale, isEmpty);
        expect(children.cashDrawers, isEmpty);
      }
      // Every point of sale nests under the facility named by its OWN
      // facilityId — the isCrossFacility check must not throw even when a
      // legacy record's warehouse belongs elsewhere (research §3).
      for (final pointSale in children.pointsOfSale) {
        expect(() => children.isCrossFacility(pointSale), returnsNormally);
      }
    }
  }, skip: !_canRun, timeout: const Timeout(Duration(seconds: 60)));
}
