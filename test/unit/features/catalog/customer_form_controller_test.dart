import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form_controller.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 15)],
);

ProviderContainer _containerFor(User user, CustomerRepository repository) {
  return ProviderContainer(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

Customer _customer({EmployeeRef? salesperson}) => Customer(
  customerId: 1,
  code: 'CUST-001',
  name: 'Acme Corp',
  creditLimit: '1000.50',
  creditDays: 30,
  priceList: const PriceListRef(id: 1, name: 'Retail'),
  shipping: false,
  shippingRequiredDocument: false,
  salesperson: salesperson,
  disabled: false,
);

void main() {
  late MockCustomerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCustomerRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group(
    'CustomerFormController.submitCreate validation (FR-018, FR-019)',
    () {
      test('code/name/priceList are required before submit', () async {
        final notifier = container.read(
          customerFormControllerProvider.notifier,
        );

        await notifier.submitCreate();

        final state = container.read(customerFormControllerProvider);
        expect(state.fieldErrors['code'], CustomerFormErrorCode.codeRequired);
        expect(state.fieldErrors['name'], CustomerFormErrorCode.nameRequired);
        expect(
          state.fieldErrors['priceList'],
          CustomerFormErrorCode.priceListRequired,
        );
        verifyNever(
          () => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            priceList: any(named: 'priceList'),
          ),
        );
      });

      test(
        'a valid submission (with salesperson) creates the customer',
        () async {
          when(
            () => repository.create(
              code: 'CUST-001',
              name: 'Acme Corp',
              priceList: 1,
              zone: null,
              creditLimit: null,
              creditDays: null,
              shipping: false,
              shippingRequiredDocument: false,
              salesperson: 2,
              comment: null,
            ),
          ).thenAnswer(
            (_) async =>
                _customer(salesperson: const EmployeeRef(id: 2, name: 'Jane Doe')),
          );

          final notifier = container.read(
            customerFormControllerProvider.notifier,
          );
          notifier
            ..codeChanged('CUST-001')
            ..nameChanged('Acme Corp')
            ..priceListSelected(1, 'Retail')
            ..salespersonSelected(2, 'Jane Doe');

          await notifier.submitCreate();

          expect(
            container.read(customerFormControllerProvider).saved,
            isTrue,
          );
        },
      );

      test('a negative credit limit is rejected before submit', () async {
        final notifier = container.read(
          customerFormControllerProvider.notifier,
        );
        notifier
          ..codeChanged('CUST-001')
          ..nameChanged('Acme Corp')
          ..priceListSelected(1, 'Retail')
          ..creditLimitChanged('-1');

        await notifier.submitCreate();

        final state = container.read(customerFormControllerProvider);
        expect(
          state.fieldErrors['creditLimit'],
          CustomerFormErrorCode.creditLimitInvalid,
        );
      });
    },
  );

  group('CustomerFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        customerFormControllerProvider.notifier,
      );
      notifier
        ..codeChanged('CUST-001')
        ..nameChanged('Acme Corp')
        ..priceListSelected(1, 'Retail');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(customerFormControllerProvider);
      expect(state.error, CustomerFormErrorCode.createPermissionDenied);
    });
  });

  group('CustomerFormController.loadForEdit', () {
    test('a customer with no salesperson pre-fills an empty display text', () async {
      when(() => repository.get(customerId: 1)).thenAnswer(
        (_) async => _customer(),
      );

      final notifier = container.read(customerFormControllerProvider.notifier);
      await notifier.loadForEdit(1);

      final state = container.read(customerFormControllerProvider);
      expect(state.salespersonId, isNull);
      expect(state.salespersonDisplayText, '');
      expect(state.priceListDisplayText, 'Retail');
    });
  });

  group('CustomerFormController.delete', () {
    test(
      'a still-referenced rejection is surfaced and the customer stays loaded',
      () async {
        when(() => repository.get(customerId: 1)).thenAnswer(
          (_) async => _customer(),
        );
        when(() => repository.delete(customerId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Customer has existing sales orders',
          ),
        );

        final notifier = container.read(
          customerFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(customerFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, CustomerFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Customer has existing sales orders');
      },
    );
  });
}
