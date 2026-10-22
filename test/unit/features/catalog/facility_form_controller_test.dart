import 'dart:typed_data';

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
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_form_controller.dart';

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _user = User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.facilities, rawValue: 15)],
);

Facility _facility(int id, {String? logo}) => Facility(
  facilityId: id,
  code: 'FAC',
  name: 'Main',
  type: FacilityType.store,
  locationId: '06600',
  locationLabel: 'Cuauhtémoc',
  addressId: 42,
  addressLabel: 'Reforma 100',
  taxpayerRfc: 'AAA010101AAA',
  logo: logo,
  status: EntityStatus.active,
);

final _png = Uint8List.fromList([1, 2, 3]);

void main() {
  setUpAll(() => registerFallbackValue(Uint8List(0)));

  late MockFacilityRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockFacilityRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        facilityRepositoryProvider.overrideWithValue(repo),
        accessControlProvider.overrideWithValue(
          AccessControlService(
            const AuthState.authenticated(token: 't', user: _user),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  FacilityFormController notifier() =>
      container.read(facilityFormControllerProvider.notifier);
  FacilityFormState state() => container.read(facilityFormControllerProvider);

  void fillValid() {
    notifier()
      ..codeChanged('FAC')
      ..nameChanged('Main')
      ..locationSelected('06600', 'Cuauhtémoc')
      ..addressSelected(42, 'Reforma 100')
      ..taxpayerRfcTyped('AAA010101AAA');
  }

  void stubCreate() => when(
    () => repo.create(
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
  ).thenAnswer((_) async => _facility(7));

  void stubUpdate(int id) => when(
    () => repo.update(
      facilityId: id,
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
  ).thenAnswer((_) async => _facility(id));

  When<Future<Facility>> uploadCall(int id) => when(
    () => repo.uploadLogo(
      facilityId: id,
      bytes: any(named: 'bytes'),
      filename: any(named: 'filename'),
    ),
  );

  group('logoPicked', () {
    test('rejects a non-JPEG/PNG file and leaves staging untouched', () {
      notifier().logoPicked(_png, 'logo.gif');
      expect(
        state().fieldErrors['logo'],
        FacilityFormErrorCode.logoInvalidType,
      );
      expect(state().pendingLogoBytes, isNull);
    });

    test('rejects a file over 2 MB', () {
      notifier().logoPicked(Uint8List(2 * 1024 * 1024 + 1), 'logo.png');
      expect(state().fieldErrors['logo'], FacilityFormErrorCode.logoTooLarge);
      expect(state().pendingLogoBytes, isNull);
    });

    test('stages a valid file and clears a previous logo error', () {
      notifier().logoPicked(_png, 'logo.gif');
      notifier().logoPicked(_png, 'LOGO.PNG');
      expect(state().fieldErrors.containsKey('logo'), isFalse);
      expect(state().pendingLogoBytes, _png);
      expect(state().pendingLogoFilename, 'LOGO.PNG');
    });
  });

  group('submit', () {
    test('create with no staged logo sends no upload and saves', () async {
      stubCreate();
      fillValid();
      await notifier().submitCreate();

      expect(state().saved, isTrue);
      expect(state().error, isNull);
      verifyNever(
        () => repo.uploadLogo(
          facilityId: any(named: 'facilityId'),
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      );
    });

    test('create uploads the staged logo using the new id', () async {
      stubCreate();
      uploadCall(7).thenAnswer((_) async => _facility(7, logo: 'u.png'));
      fillValid();
      notifier().logoPicked(_png, 'logo.png');
      await notifier().submitCreate();

      verify(
        () => repo.uploadLogo(facilityId: 7, bytes: _png, filename: 'logo.png'),
      ).called(1);
      expect(state().saved, isTrue);
      expect(state().error, isNull);
      expect(state().pendingLogoBytes, isNull);
      expect(state().logoUrl, 'u.png');
    });

    test('update uploads the staged logo', () async {
      when(() => repo.get(facilityId: 3)).thenAnswer((_) async => _facility(3));
      stubUpdate(3);
      uploadCall(3).thenAnswer((_) async => _facility(3, logo: 'u.png'));
      await notifier().loadForEdit(3);
      notifier().logoPicked(_png, 'logo.jpg');
      await notifier().submitUpdate();

      verify(
        () => repo.uploadLogo(facilityId: 3, bytes: _png, filename: 'logo.jpg'),
      ).called(1);
      expect(state().saved, isTrue);
      expect(state().error, isNull);
    });

    test('a failed upload keeps saved, the bytes and the created id', () async {
      stubCreate();
      uploadCall(7).thenThrow(const AppError.server());
      fillValid();
      notifier().logoPicked(_png, 'logo.png');
      await notifier().submitCreate();

      expect(state().saved, isTrue);
      expect(state().error, FacilityFormErrorCode.logoUploadFailed);
      expect(state().pendingLogoBytes, _png);
      expect(state().facilityId, 7);
      expect(state().submitting, isFalse);
    });

    test('a retry after a failed create upload updates, not creates', () async {
      stubCreate();
      stubUpdate(7);
      uploadCall(7).thenThrow(const AppError.server());
      fillValid();
      notifier().logoPicked(_png, 'logo.png');
      await notifier().submitCreate();

      uploadCall(7).thenAnswer((_) async => _facility(7, logo: 'u.png'));
      await notifier().submitUpdate();

      verify(
        () => repo.create(
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
      ).called(1);
      verify(
        () => repo.update(
          facilityId: 7,
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
      ).called(1);
      expect(state().error, isNull);
      expect(state().saved, isTrue);
      expect(state().pendingLogoBytes, isNull);
    });

    test('a failed create attempts no upload', () async {
      when(
        () => repo.create(
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
      ).thenThrow(const AppError.server());
      fillValid();
      notifier().logoPicked(_png, 'logo.png');
      await notifier().submitCreate();

      expect(state().saved, isFalse);
      expect(state().error, FacilityFormErrorCode.createFailed);
      expect(state().facilityId, isNull);
      verifyNever(
        () => repo.uploadLogo(
          facilityId: any(named: 'facilityId'),
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      );
    });
  });
}
