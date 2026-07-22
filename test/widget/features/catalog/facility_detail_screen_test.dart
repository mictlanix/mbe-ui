import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/address_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

class MockSatCatalogRepository extends Mock implements SatCatalogRepository {}

/// facilities + addresses + taxpayers all fully granted.
Privilege _priv(SystemObject o) => Privilege(systemObject: o, rawValue: 15);

User _user({
  bool facilities = true,
  bool addresses = true,
  bool taxpayers = true,
}) => User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    if (facilities) _priv(SystemObject.facilities),
    if (addresses) _priv(SystemObject.addresses),
    if (taxpayers) _priv(SystemObject.taxpayers),
  ],
);

final _facility = Facility(
  facilityId: 1,
  code: 'FAC-1',
  name: 'Main Store',
  type: FacilityType.store,
  locationId: '06600',
  locationLabel: 'Cuauhtémoc',
  addressId: 42,
  addressLabel: 'Reforma 100, Juárez, CDMX',
  taxpayerRfc: 'AAA010101AAA',
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockFacilityRepository facilityRepo;
  late MockAddressRepository addressRepo;
  late MockTaxpayerIssuerRepository taxpayerRepo;
  late MockSatCatalogRepository satRepo;
  ProviderContainer? container;

  setUp(() {
    facilityRepo = MockFacilityRepository();
    addressRepo = MockAddressRepository();
    taxpayerRepo = MockTaxpayerIssuerRepository();
    satRepo = MockSatCatalogRepository();
    container = null;
  });

  tearDown(() => container?.dispose());

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? facilityId,
  }) async {
    if (facilityId != null) {
      when(
        () => facilityRepo.get(facilityId: facilityId),
      ).thenAnswer((_) async => _facility);
    }
    container = ProviderContainer(
      overrides: [
        facilityRepositoryProvider.overrideWithValue(facilityRepo),
        addressRepositoryProvider.overrideWithValue(addressRepo),
        taxpayerIssuerRepositoryProvider.overrideWithValue(taxpayerRepo),
        satCatalogRepositoryProvider.overrideWithValue(satRepo),
        accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: FacilityDetailScreen(facilityId: facilityId)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the create form shows location, address, and taxpayer fields', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _user());

    expect(find.byKey(const Key('location_field')), findsOneWidget);
    expect(find.byKey(const Key('address_field')), findsOneWidget);
    expect(find.byKey(const Key('taxpayer_field')), findsOneWidget);
  });

  testWidgets(
    'the inline "new address" action is shown with addresses(11) create '
    'privilege (FR-032)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _user());
      expect(find.byKey(const Key('new_address_button')), findsOneWidget);
    },
  );

  testWidgets(
    'without addresses(11) create, the address picker stays but the inline '
    'create path is hidden (FR-032)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _user(addresses: false));
      expect(find.byKey(const Key('new_address_button')), findsNothing);
      expect(find.byKey(const Key('address_field')), findsOneWidget);
    },
  );

  testWidgets(
    'the taxpayer field degrades to a typed RFC entry without taxpayers(24) '
    'read (FR-034)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _user(taxpayers: false));

      expect(find.byKey(const Key('taxpayer_field')), findsNothing);
      expect(find.byKey(const Key('taxpayer_rfc_field')), findsOneWidget);
    },
  );

  testWidgets(
    'the taxpayer field never offers an inline create-issuer path (FR-034a)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _user());
      // There is deliberately no create-issuer affordance in the widget tree
      // at all — issuers are picked, never created from the facility form.
      expect(find.byKey(const Key('new_taxpayer_issuer_button')), findsNothing);
    },
  );

  testWidgets(
    'a loaded facility resolves its taxpayer to the issuer name, never blank '
    '(FR-034b)',
    (tester) async {
      when(() => taxpayerRepo.get('AAA010101AAA')).thenAnswer(
        (_) async => const TaxpayerIssuerListItem(
          rfc: 'AAA010101AAA',
          name: 'ACME Corp',
        ),
      );

      await pumpScreen(tester, signedInAs: _user(), facilityId: 1);

      // The resolution (T095/G2) is what FR-034b requires; assert on the
      // loaded controller state rather than the Autocomplete's rendered text
      // (which only seeds its field once and is brittle to load timing).
      final state = container!.read(facilityFormControllerProvider);
      expect(state.taxpayerRfc, 'AAA010101AAA');
      expect(state.taxpayerDisplayText, 'ACME Corp');
      verify(() => taxpayerRepo.get('AAA010101AAA')).called(1);
    },
  );

  testWidgets(
    'a loaded facility falls back to the RFC when the issuer has no name '
    '(FR-034b)',
    (tester) async {
      when(() => taxpayerRepo.get('AAA010101AAA')).thenAnswer(
        (_) async => const TaxpayerIssuerListItem(rfc: 'AAA010101AAA'),
      );

      await pumpScreen(tester, signedInAs: _user(), facilityId: 1);

      // No usable name → display falls back to the bare RFC (never blank).
      final state = container!.read(facilityFormControllerProvider);
      expect(state.taxpayerDisplayText, 'AAA010101AAA');
    },
  );

  testWidgets('a user without update privilege gets no edit toggle or delete', (
    tester,
  ) async {
    when(() => taxpayerRepo.get(any())).thenAnswer(
      (_) async => const TaxpayerIssuerListItem(rfc: 'AAA010101AAA'),
    );

    await pumpScreen(
      tester,
      // read-only on facilities: view but not edit/delete.
      signedInAs: User(
        userId: 'r',
        email: 'r@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: const [
          Privilege(systemObject: SystemObject.facilities, rawValue: 2),
          Privilege(systemObject: SystemObject.taxpayers, rawValue: 2),
        ],
      ),
      facilityId: 1,
    );

    expect(find.byKey(const Key('edit_facility_button')), findsNothing);
    expect(find.byKey(const Key('delete_facility_button')), findsNothing);
  });
}
