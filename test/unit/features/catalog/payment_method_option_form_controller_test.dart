import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_option_form_controller.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 15),
  ],
);

ProviderContainer _containerFor(
  User user,
  PaymentMethodOptionRepository repository,
) {
  return ProviderContainer(
    overrides: [
      paymentMethodOptionRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockPaymentMethodOptionRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockPaymentMethodOptionRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('PaymentMethodOptionFormController defaults (FR-005)', () {
    test('numberOfPayments defaults to 1 and displayOnTicket to true', () {
      final state = container.read(paymentMethodOptionFormControllerProvider);
      expect(state.numberOfPayments, 1);
      expect(state.displayOnTicket, isTrue);
    });

    test('creating with numberOfPayments/displayOnTicket untouched persists '
        'the defaults (Acceptance Scenario 4)', () async {
      when(
        () => repository.create(
          facilityId: 9,
          warehouseId: null,
          name: 'Cash',
          numberOfPayments: 1,
          displayOnTicket: true,
          paymentMethod: 1,
          commission: null,
          status: EntityStatus.active,
        ),
      ).thenAnswer(
        (_) async => PaymentMethodOption(
          paymentMethodOptionId: 1,
          facilityId: 9,
          facilityName: 'Main Store',
          name: 'Cash',
          numberOfPayments: 1,
          displayOnTicket: true,
          paymentMethod: 1,
          status: EntityStatus.active,
        ),
      );

      final notifier = container.read(
        paymentMethodOptionFormControllerProvider.notifier,
      );
      notifier
        ..facilitySelected(9, 'Main Store')
        ..nameChanged('Cash')
        ..paymentMethodChanged(1);

      await notifier.submitCreate();

      verify(
        () => repository.create(
          facilityId: 9,
          warehouseId: null,
          name: 'Cash',
          numberOfPayments: 1,
          displayOnTicket: true,
          paymentMethod: 1,
          commission: null,
          status: EntityStatus.active,
        ),
      ).called(1);
      expect(
        container.read(paymentMethodOptionFormControllerProvider).saved,
        isTrue,
      );
    });
  });

  group('PaymentMethodOptionFormController validation (FR-003)', () {
    test('facility/name/paymentMethod are required before submit', () async {
      final notifier = container.read(
        paymentMethodOptionFormControllerProvider.notifier,
      );

      await notifier.submitCreate();

      final state = container.read(paymentMethodOptionFormControllerProvider);
      expect(
        state.fieldErrors['facility'],
        PaymentMethodOptionFormErrorCode.facilityRequired,
      );
      expect(
        state.fieldErrors['name'],
        PaymentMethodOptionFormErrorCode.nameRequired,
      );
      expect(
        state.fieldErrors['paymentMethod'],
        PaymentMethodOptionFormErrorCode.paymentMethodRequired,
      );
      verifyNever(
        () => repository.create(
          facilityId: any(named: 'facilityId'),
          name: any(named: 'name'),
          paymentMethod: any(named: 'paymentMethod'),
        ),
      );
    });

    test('numberOfPayments below 1 is rejected', () async {
      final notifier = container.read(
        paymentMethodOptionFormControllerProvider.notifier,
      );
      notifier
        ..facilitySelected(9, 'Main Store')
        ..nameChanged('Cash')
        ..paymentMethodChanged(1)
        ..numberOfPaymentsChanged(0);

      await notifier.submitCreate();

      final state = container.read(paymentMethodOptionFormControllerProvider);
      expect(
        state.fieldErrors['numberOfPayments'],
        PaymentMethodOptionFormErrorCode.numberOfPaymentsInvalid,
      );
    });

    test('a non-numeric commission is rejected', () async {
      final notifier = container.read(
        paymentMethodOptionFormControllerProvider.notifier,
      );
      notifier
        ..facilitySelected(9, 'Main Store')
        ..nameChanged('Cash')
        ..paymentMethodChanged(1)
        ..commissionChanged('not-a-number');

      await notifier.submitCreate();

      final state = container.read(paymentMethodOptionFormControllerProvider);
      expect(
        state.fieldErrors['commission'],
        PaymentMethodOptionFormErrorCode.commissionInvalid,
      );
    });
  });

  group('PaymentMethodOptionFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        paymentMethodOptionFormControllerProvider.notifier,
      );
      notifier
        ..facilitySelected(9, 'Main Store')
        ..nameChanged('Cash')
        ..paymentMethodChanged(1);

      await notifier.submitCreate();

      final state = readOnlyContainer.read(
        paymentMethodOptionFormControllerProvider,
      );
      expect(
        state.error,
        PaymentMethodOptionFormErrorCode.createPermissionDenied,
      );
    });
  });
}
