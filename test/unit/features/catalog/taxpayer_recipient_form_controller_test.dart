import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_form_controller.dart';

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 15),
  ],
);

ProviderContainer _containerFor(
  User user,
  TaxpayerRecipientRepository repository,
) {
  return ProviderContainer(
    overrides: [
      taxpayerRecipientRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockTaxpayerRecipientRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockTaxpayerRecipientRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group(
    'TaxpayerRecipientFormController.submitCreate validation (FR-023, FR-024)',
    () {
      test('id/name/email are required before submit (create mode)', () async {
        final notifier = container.read(
          taxpayerRecipientFormControllerProvider.notifier,
        );

        await notifier.submitCreate();

        final state = container.read(taxpayerRecipientFormControllerProvider);
        expect(
          state.fieldErrors['taxpayerRecipientId'],
          TaxpayerRecipientFormErrorCode.idRequired,
        );
        expect(
          state.fieldErrors['name'],
          TaxpayerRecipientFormErrorCode.nameRequired,
        );
        expect(
          state.fieldErrors['email'],
          TaxpayerRecipientFormErrorCode.emailRequired,
        );
        verifyNever(
          () => repository.create(
            taxpayerRecipientId: any(named: 'taxpayerRecipientId'),
            email: any(named: 'email'),
          ),
        );
      });

      test('a valid submission creates the taxpayer recipient', () async {
        when(
          () => repository.create(
            taxpayerRecipientId: 'XAXX010101000',
            email: 'test@example.com',
            name: 'Acme Corp',
            postalCode: '06500',
            regime: '601',
          ),
        ).thenAnswer(
          (_) async => TaxpayerRecipient(
            taxpayerRecipientId: 'XAXX010101000',
            name: 'Acme Corp',
            email: 'test@example.com',
          ),
        );

        final notifier = container.read(
          taxpayerRecipientFormControllerProvider.notifier,
        );
        notifier
          ..taxpayerRecipientIdChanged('XAXX010101000')
          ..nameChanged('Acme Corp')
          ..emailChanged('test@example.com')
          ..postalCodeSelected('06500', 'Ciudad de México')
          ..regimeSelected('601', 'General de Ley');

        await notifier.submitCreate();

        expect(
          container.read(taxpayerRecipientFormControllerProvider).saved,
          isTrue,
        );
      });

      test(
        'a duplicate tax id server rejection surfaces as a field error (FR-027)',
        () async {
          when(
            () => repository.create(
              taxpayerRecipientId: 'XAXX010101000',
              email: any(named: 'email'),
              name: any(named: 'name'),
              postalCode: any(named: 'postalCode'),
              regime: any(named: 'regime'),
            ),
          ).thenThrow(
            const AppError.validation([
              FieldError(
                loc: ['body', 'taxpayer_recipient_id'],
                msg: 'Taxpayer recipient already exists',
                type: 'value_error',
              ),
            ]),
          );

          final notifier = container.read(
            taxpayerRecipientFormControllerProvider.notifier,
          );
          notifier
            ..taxpayerRecipientIdChanged('XAXX010101000')
            ..nameChanged('Acme Corp')
            ..emailChanged('test@example.com');

          await notifier.submitCreate();

          final state = container.read(
            taxpayerRecipientFormControllerProvider,
          );
          expect(
            state.fieldErrors['taxpayer_recipient_id'],
            'Taxpayer recipient already exists',
          );
        },
      );
    },
  );

  group('TaxpayerRecipientFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        taxpayerRecipientFormControllerProvider.notifier,
      );
      notifier
        ..taxpayerRecipientIdChanged('XAXX010101000')
        ..nameChanged('Acme Corp')
        ..emailChanged('test@example.com');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(
        taxpayerRecipientFormControllerProvider,
      );
      expect(state.error, TaxpayerRecipientFormErrorCode.createPermissionDenied);
    });
  });

  group('TaxpayerRecipientFormController.loadForEdit / submitUpdate', () {
    test('the id is not editable and is never sent on update', () async {
      when(
        () => repository.get(taxpayerRecipientId: 'XAXX010101000'),
      ).thenAnswer(
        (_) async => const TaxpayerRecipient(
          taxpayerRecipientId: 'XAXX010101000',
          name: 'Acme Corp',
          email: 'test@example.com',
        ),
      );
      when(
        () => repository.update(
          taxpayerRecipientId: 'XAXX010101000',
          name: 'Acme Corp',
          email: 'updated@example.com',
          postalCode: null,
          regime: null,
        ),
      ).thenAnswer(
        (_) async => const TaxpayerRecipient(
          taxpayerRecipientId: 'XAXX010101000',
          name: 'Acme Corp',
          email: 'updated@example.com',
        ),
      );

      final notifier = container.read(
        taxpayerRecipientFormControllerProvider.notifier,
      );
      await notifier.loadForEdit('XAXX010101000');
      notifier.emailChanged('updated@example.com');

      await notifier.submitUpdate();

      final state = container.read(taxpayerRecipientFormControllerProvider);
      expect(state.saved, isTrue);
      // The id field itself must not have been treated as required/changed —
      // no idRequired field error should ever surface once loaded for edit.
      expect(
        state.fieldErrors.containsKey('taxpayerRecipientId'),
        isFalse,
      );
    });
  });

  group('TaxpayerRecipientFormController.delete', () {
    test('a rejection is surfaced and the record stays loaded', () async {
      when(
        () => repository.get(taxpayerRecipientId: 'XAXX010101000'),
      ).thenAnswer(
        (_) async => const TaxpayerRecipient(
          taxpayerRecipientId: 'XAXX010101000',
          name: 'Acme Corp',
          email: 'test@example.com',
        ),
      );
      when(
        () => repository.delete(taxpayerRecipientId: 'XAXX010101000'),
      ).thenThrow(
        const AppError.server(
          statusCode: 400,
          message: 'Taxpayer recipient is referenced by a fiscal document',
        ),
      );

      final notifier = container.read(
        taxpayerRecipientFormControllerProvider.notifier,
      );
      await notifier.loadForEdit('XAXX010101000');

      await notifier.delete();

      final state = container.read(taxpayerRecipientFormControllerProvider);
      expect(state.deleted, isFalse);
      expect(state.error, TaxpayerRecipientFormErrorCode.deleteFailed);
    });
  });
}
