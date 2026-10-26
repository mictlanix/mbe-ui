import 'dart:convert';
import 'dart:typed_data';

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
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
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

/// A valid 1x1 PNG, so `Image.memory` can decode the staged preview.
final _tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

final _facilityWithLogo = _facility.copyWith(logo: 'http://localhost:1/x.png');

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
    Locale? locale,
    Facility? facility,
    bool forceReadOnly = false,
  }) async {
    if (facilityId != null) {
      when(
        () => facilityRepo.get(facilityId: facilityId),
      ).thenAnswer((_) async => facility ?? _facility);
    }
    container = ProviderContainer(
      retry: (_, _) => null,
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
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FacilityDetailScreen(
              facilityId: facilityId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'in Spanish the type dropdown offers "Planta" for a production site '
    '(046-catalog-improvements FR-012)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _user(), locale: const Locale('es'));

      await tester.tap(find.byKey(const Key('facility_type_field')));
      await tester.pumpAndSettle();

      expect(find.text('Planta'), findsWidgets);
      expect(find.textContaining('Sitio de producción'), findsNothing);
    },
  );

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

    // 017-ui-consistency-filters / constitution v1.10.0: the edit toggle
    // lives in the record action area now, not the AppBar.
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.actions, anyOf(isNull, isEmpty));
  });

  group('logo section (049 US2)', () {
    setUp(() {
      when(() => taxpayerRepo.get(any())).thenAnswer(
        (_) async => const TaxpayerIssuerListItem(rfc: 'AAA010101AAA'),
      );
    });

    testWidgets('shows the placeholder and the upload button with no logo', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _user(), locale: const Locale('es'));

      expect(find.byKey(const Key('facility_logo_section')), findsOneWidget);
      expect(find.byType(ProductPhoto), findsOneWidget);
      expect(find.text('Subir logotipo'), findsOneWidget);
      expect(
        find.byKey(const Key('facility_logo_replace_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('facility_logo_remove_button')),
        findsNothing,
      );
      expect(find.byKey(const Key('logo_field')), findsNothing);
    });

    testWidgets('shows the replace button when the facility has a logo', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _user(),
        facilityId: 1,
        facility: _facilityWithLogo,
      );

      expect(
        find.byKey(const Key('facility_logo_replace_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('facility_logo_upload_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('facility_logo_remove_button')),
        findsOneWidget,
      );
    });

    testWidgets('Remove logo stages the removal until Save', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _user(),
        facilityId: 1,
        facility: _facilityWithLogo,
      );

      await tester.tap(find.byKey(const Key('facility_logo_remove_button')));
      await tester.pump();

      expect(
        find.byKey(const Key('facility_logo_remove_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('facility_logo_upload_button')),
        findsOneWidget,
      );
      verifyNever(() => facilityRepo.removeLogo(facilityId: 1));
    });

    testWidgets('an unreachable logo URL renders the placeholder', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _user(),
        facilityId: 1,
        facility: _facilityWithLogo,
      );
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('offers no upload action in view mode', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _user(),
        facilityId: 1,
        forceReadOnly: true,
      );

      expect(find.byKey(const Key('facility_logo_section')), findsOneWidget);
      expect(
        find.byKey(const Key('facility_logo_upload_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('facility_logo_replace_button')),
        findsNothing,
      );
    });

    testWidgets(
      'a save whose logo upload fails keeps the form open with the error',
      (tester) async {
        when(
          () => facilityRepo.update(
            facilityId: 1,
            code: any(named: 'code'),
            name: any(named: 'name'),
            type: any(named: 'type'),
            location: any(named: 'location'),
            address: any(named: 'address'),
            taxpayer: any(named: 'taxpayer'),
            receiptMessage: any(named: 'receiptMessage'),
            defaultBatch: any(named: 'defaultBatch'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => _facility);
        registerFallbackValue(Uint8List(0));
        when(
          () => facilityRepo.uploadLogo(
            facilityId: 1,
            bytes: any(named: 'bytes'),
            filename: any(named: 'filename'),
          ),
        ).thenThrow(const AppError.server());

        await pumpScreen(
          tester,
          signedInAs: _user(),
          facilityId: 1,
          locale: const Locale('es'),
        );
        container!
            .read(facilityFormControllerProvider.notifier)
            .logoPicked(_tinyPng, 'logo.png');
        await tester.pumpAndSettle();

        final save = find.byKey(const Key('save_button'));
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pump();
        await tester.pump();
        await tester.pump();

        // Popping with no router would have thrown; the banner persists.
        expect(tester.takeException(), isNull);
        expect(find.byType(FacilityDetailScreen), findsOneWidget);
        expect(
          find.textContaining('el logotipo no se pudo subir'),
          findsOneWidget,
        );
      },
    );
  });
}
