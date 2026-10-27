import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

const _read = 2;

User _user({required List<Privilege> privileges}) => User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: privileges,
);

final _reader = _user(
  privileges: const [
    Privilege(systemObject: SystemObject.customerPayments, rawValue: _read),
  ],
);

final _editor = _user(
  privileges: const [
    Privilege(systemObject: SystemObject.customerPayments, rawValue: _read),
    Privilege(systemObject: SystemObject.paymentsEditor, rawValue: _read),
  ],
);

CustomerPayment _payment({int id = 18342, int facilityId = 3}) =>
    CustomerPayment(
      customerPaymentId: id,
      customerId: 77,
      amount: '1250.00',
      currency: Currency.mxn,
      methodCode: 3,
      date: DateTime(2026, 10, 27, 10, 14),
      facilityId: facilityId,
      type: PaymentType.immediate,
      unapplied: '0.00',
    );

PaymentApplication _application(String amount, {bool reversed = false}) =>
    PaymentApplication(
      id: 1,
      saleId: 5512,
      amount: amount,
      change: '0.00',
      reversed: reversed,
    );

ProviderContainer _containerFor(
  User user,
  CustomerPaymentRepository repository, {
  int? facility = 3,
}) {
  return ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      customerPaymentRepositoryProvider.overrideWithValue(repository),
      userFacilityIdProvider.overrideWithValue(facility),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockCustomerPaymentRepository repository;

  setUp(() {
    repository = MockCustomerPaymentRepository();
  });

  group('paymentDetailProvider facility guard (FR-013b, R4)', () {
    test('opens a payment from the user\'s own facility', () async {
      when(
        () => repository.get(customerPaymentId: 18342),
      ).thenAnswer((_) async => _payment(facilityId: 3));
      final container = _containerFor(_reader, repository);
      addTearDown(container.dispose);

      final payment = await container.read(paymentDetailProvider(18342).future);

      expect(payment.customerPaymentId, 18342);
    });

    test('refuses another facility\'s payment as not-found', () async {
      when(
        () => repository.get(customerPaymentId: 18342),
      ).thenAnswer((_) async => _payment(facilityId: 51));
      final container = _containerFor(_reader, repository);
      addTearDown(container.dispose);

      await expectLater(
        container.read(paymentDetailProvider(18342).future),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('a Payments Editor may open another facility\'s payment', () async {
      when(
        () => repository.get(customerPaymentId: 18342),
      ).thenAnswer((_) async => _payment(facilityId: 51));
      final container = _containerFor(_editor, repository);
      addTearDown(container.dispose);

      final payment = await container.read(paymentDetailProvider(18342).future);

      expect(payment.facilityId, 51);
    });

    test('a user with no facility matches nothing, unless an editor', () async {
      when(
        () => repository.get(customerPaymentId: 18342),
      ).thenAnswer((_) async => _payment(facilityId: 3));
      final reader = _containerFor(_reader, repository, facility: null);
      addTearDown(reader.dispose);
      final editor = _containerFor(_editor, repository, facility: null);
      addTearDown(editor.dispose);

      await expectLater(
        reader.read(paymentDetailProvider(18342).future),
        throwsA(isA<NotFoundError>()),
      );
      expect(
        (await editor.read(paymentDetailProvider(18342).future)).facilityId,
        3,
      );
    });

    test('a missing payment surfaces the server\'s not-found', () async {
      when(
        () => repository.get(customerPaymentId: 99999),
      ).thenThrow(const AppError.notFound('Payment not found'));
      final container = _containerFor(_reader, repository);
      addTearDown(container.dispose);

      await expectLater(
        container.read(paymentDetailProvider(99999).future),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('paymentApplicationsProvider', () {
    test('never requests the applications of a refused payment', () async {
      when(
        () => repository.get(customerPaymentId: 18342),
      ).thenAnswer((_) async => _payment(facilityId: 51));
      final container = _containerFor(_reader, repository);
      addTearDown(container.dispose);

      await expectLater(
        container.read(paymentApplicationsProvider(18342).future),
        throwsA(isA<NotFoundError>()),
      );

      verifyNever(
        () => repository.listApplications(
          customerPaymentId: any(named: 'customerPaymentId'),
        ),
      );
    });

    test('loads them once the guard passes', () async {
      when(
        () => repository.get(customerPaymentId: 18342),
      ).thenAnswer((_) async => _payment());
      when(
        () => repository.listApplications(customerPaymentId: 18342),
      ).thenAnswer((_) async => [_application('1000.00')]);
      final container = _containerFor(_reader, repository);
      addTearDown(container.dispose);

      final applications = await container.read(
        paymentApplicationsProvider(18342).future,
      );

      expect(applications, hasLength(1));
    });

    test('a failing applications call leaves the payment loaded', () async {
      when(
        () => repository.get(customerPaymentId: 18342),
      ).thenAnswer((_) async => _payment());
      when(
        () => repository.listApplications(customerPaymentId: 18342),
      ).thenThrow(const AppError.server());
      final container = _containerFor(_reader, repository);
      addTearDown(container.dispose);

      await expectLater(
        container.read(paymentApplicationsProvider(18342).future),
        throwsA(isA<ServerError>()),
      );
      expect(
        (await container.read(
          paymentDetailProvider(18342).future,
        )).customerPaymentId,
        18342,
      );
    });
  });

  group('appliedTotal (FR-013a, SC-003)', () {
    test('excludes reversed applications', () {
      expect(
        appliedTotal([
          _application('1000.00'),
          _application('300.00', reversed: true),
          _application('250.00'),
        ]),
        '1250',
      );
    });

    test('sums in decimal, not floating point (0.1 + 0.2 = 0.3)', () {
      expect(appliedTotal([_application('0.1'), _application('0.2')]), '0.3');
    });

    test('is zero with no applications, or only reversed ones', () {
      expect(appliedTotal(const []), '0');
      expect(appliedTotal([_application('300.00', reversed: true)]), '0');
    });
  });
}
