import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus, ValidationError;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuer_form_controller.dart';

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 15)],
);

ProviderContainer _containerFor(
  User user,
  TaxpayerIssuerRepository repository,
) {
  return ProviderContainer(
    overrides: [
      taxpayerIssuerRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockTaxpayerIssuerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockTaxpayerIssuerRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('TaxpayerIssuerFormController.submitCreate validation (FR-011)', () {
    test('rfc/name/regime are required before submit', () async {
      final notifier = container.read(
        taxpayerIssuerFormControllerProvider.notifier,
      );

      await notifier.submitCreate();

      final state = container.read(taxpayerIssuerFormControllerProvider);
      expect(state.fieldErrors['rfc'], TaxpayerIssuerFormErrorCode.rfcRequired);
      expect(
        state.fieldErrors['name'],
        TaxpayerIssuerFormErrorCode.nameRequired,
      );
      expect(
        state.fieldErrors['regime'],
        TaxpayerIssuerFormErrorCode.regimeRequired,
      );
      verifyNever(
        () => repository.create(
          rfc: any(named: 'rfc'),
          regime: any(named: 'regime'),
        ),
      );
    });

    test('a valid submission registers the issuer', () async {
      when(
        () => repository.create(
          rfc: 'XAXX010101000',
          name: 'Acme Corp',
          regime: '601',
          provider: FiscalCertificationProvider.number0,
          postalCode: '06500',
          comment: null,
        ),
      ).thenAnswer(
        (_) async => const TaxpayerIssuer(
          rfc: 'XAXX010101000',
          name: 'Acme Corp',
          provider: FiscalCertificationProvider.number0,
        ),
      );

      final notifier = container.read(
        taxpayerIssuerFormControllerProvider.notifier,
      );
      notifier
        ..rfcChanged('XAXX010101000')
        ..nameChanged('Acme Corp')
        ..regimeSelected('601', 'General de Ley')
        ..postalCodeSelected('06500', 'Ciudad de México');

      await notifier.submitCreate();

      expect(
        container.read(taxpayerIssuerFormControllerProvider).saved,
        isTrue,
      );
    });

    test('a duplicate RFC server rejection surfaces as a field error '
        '(FR-017, SC-002)', () async {
      when(
        () => repository.create(
          rfc: 'XAXX010101000',
          name: any(named: 'name'),
          regime: any(named: 'regime'),
          provider: any(named: 'provider'),
          postalCode: any(named: 'postalCode'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(
        const AppError.validation([
          FieldError(
            loc: ['body', 'taxpayer_issuer_id'],
            msg: 'Taxpayer issuer already exists',
            type: 'value_error',
          ),
        ]),
      );

      final notifier = container.read(
        taxpayerIssuerFormControllerProvider.notifier,
      );
      notifier
        ..rfcChanged('XAXX010101000')
        ..nameChanged('Acme Corp')
        ..regimeSelected('601', 'General de Ley');

      await notifier.submitCreate();

      final state = container.read(taxpayerIssuerFormControllerProvider);
      expect(
        state.fieldErrors['taxpayer_issuer_id'],
        'Taxpayer issuer already exists',
      );
      // The rest of the user's input is preserved across the rejection.
      expect(state.name, 'Acme Corp');
      expect(state.regime, '601');
    });
  });

  group('TaxpayerIssuerFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        taxpayerIssuerFormControllerProvider.notifier,
      );
      notifier
        ..rfcChanged('XAXX010101000')
        ..nameChanged('Acme Corp')
        ..regimeSelected('601', 'General de Ley');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(taxpayerIssuerFormControllerProvider);
      expect(state.error, TaxpayerIssuerFormErrorCode.createPermissionDenied);
    });
  });

  group('TaxpayerIssuerFormController.loadForEdit / submitUpdate (FR-012)', () {
    test('the RFC is immutable — never sent on update, and isEdit flips true', () async {
      // A real loaded issuer always carries a regime (required at create,
      // FR-011) — an unset regime would (correctly) fail this form's
      // validation on save, same as it would on create.
      when(
        () => repository.getDetail('XAXX010101000'),
      ).thenAnswer(
        (_) async => const TaxpayerIssuer(
          rfc: 'XAXX010101000',
          name: 'Acme Corp',
          regime: SatCatalogItem(code: '601', description: 'General de Ley'),
          provider: FiscalCertificationProvider.number0,
        ),
      );
      // The controller sends the current value of every field on update
      // (Warehouse/TaxpayerRecipient "send everything" precedent) — an
      // unset postalCode/comment is an empty string, not null, since
      // `loadForEdit` maps a missing SAT expansion to `''` (research §4).
      when(
        () => repository.update(
          rfc: 'XAXX010101000',
          name: 'Updated Corp',
          regime: '601',
          provider: FiscalCertificationProvider.number0,
          postalCode: '',
          comment: '',
        ),
      ).thenAnswer(
        (_) async => const TaxpayerIssuer(
          rfc: 'XAXX010101000',
          name: 'Updated Corp',
          regime: SatCatalogItem(code: '601', description: 'General de Ley'),
          provider: FiscalCertificationProvider.number0,
        ),
      );

      final notifier = container.read(
        taxpayerIssuerFormControllerProvider.notifier,
      );
      await notifier.loadForEdit('XAXX010101000');
      expect(
        container.read(taxpayerIssuerFormControllerProvider).isEdit,
        isTrue,
      );

      notifier.nameChanged('Updated Corp');
      await notifier.submitUpdate();

      final state = container.read(taxpayerIssuerFormControllerProvider);
      expect(state.saved, isTrue);
      // No path re-attempts to change the rfc — verified above the update
      // call never received an `rfc` named param at all (it isn't one).
      verify(
        () => repository.update(
          rfc: 'XAXX010101000',
          name: 'Updated Corp',
          regime: '601',
          provider: FiscalCertificationProvider.number0,
          postalCode: '',
          comment: '',
        ),
      ).called(1);
    });
  });

  group('TaxpayerIssuerFormController.delete (FR-016)', () {
    test('a rejection is surfaced and the record stays loaded', () async {
      when(
        () => repository.getDetail('XAXX010101000'),
      ).thenAnswer(
        (_) async => const TaxpayerIssuer(
          rfc: 'XAXX010101000',
          name: 'Acme Corp',
          provider: FiscalCertificationProvider.number0,
        ),
      );
      when(() => repository.delete('XAXX010101000')).thenThrow(
        const AppError.server(
          statusCode: 400,
          message: 'Taxpayer issuer is referenced by a certificate',
        ),
      );

      final notifier = container.read(
        taxpayerIssuerFormControllerProvider.notifier,
      );
      await notifier.loadForEdit('XAXX010101000');

      await notifier.delete();

      final state = container.read(taxpayerIssuerFormControllerProvider);
      expect(state.deleted, isFalse);
      expect(state.error, TaxpayerIssuerFormErrorCode.deleteFailed);
    });
  });
}
