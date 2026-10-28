import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/credit_note_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment/customer_credit_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

class MockCreditNoteRepository extends Mock implements CreditNoteRepository {}

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

class _FixedPosSale extends PosSaleController {
  _FixedPosSale(this._sale);
  final Sale _sale;
  @override
  Future<Sale?> build() async => _sale;
}

const _named = 7;

Sale _sale({
  int customer = _named,
  SaleStatus status = SaleStatus.completed,
  String balance = '1000.00',
}) => Sale(
  id: 42,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: customer,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 8, 20),
  status: status,
  lines: const [],
  subtotal: '100.00',
  taxTotal: '16.00',
  total: '1000.00',
  balance: balance,
  date: DateTime(2026, 8, 20),
  dueDate: DateTime(2026, 8, 20),
  priority: Priority.normal,
);

CreditNote _note(int id, String remaining, {int customer = _named}) =>
    CreditNote(
      id: id,
      customerId: customer,
      salesOrderId: 300 + id,
      customerRefundId: 400 + id,
      customerPaymentId: 500 + id,
      issued: remaining,
      remaining: remaining,
      date: DateTime(2026, 9, id),
    );

SalePayment _applied(int customerPayment, {bool cancelled = false}) =>
    SalePayment(
      id: customerPayment,
      customerPayment: customerPayment,
      amount: '10.00',
      methodCode: 0,
      currency: Currency.mxn,
      changeAmount: '0',
      cancelled: cancelled,
      type: PaymentType.creditNote,
      paymentDate: DateTime(2026, 9, 1),
    );

AccessControlService _access({
  bool creditRead = true,
  bool paymentsCreate = true,
}) => AccessControlService(
  AuthState.authenticated(
    token: 't',
    user: User(
      userId: 'c',
      email: 'c@example.com',
      administrator: false,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: [
        if (creditRead)
          const Privilege(
            systemObject: SystemObject.creditPayments,
            rawValue: 2,
          ),
        if (paymentsCreate)
          const Privilege(
            systemObject: SystemObject.customerPayments,
            rawValue: 1,
          ),
      ],
    ),
  ),
);

void main() {
  late MockCreditNoteRepository notes;
  late MockCustomerPaymentRepository payments;

  setUp(() {
    notes = MockCreditNoteRepository();
    payments = MockCustomerPaymentRepository();
    when(
      () => payments.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => const []);
  });

  Future<CustomerCredit> creditFor(
    Sale sale, {
    AccessControlService? access,
  }) async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        creditNoteRepositoryProvider.overrideWithValue(notes),
        customerPaymentRepositoryProvider.overrideWithValue(payments),
        accessControlProvider.overrideWithValue(access ?? _access()),
        posSaleControllerProvider.overrideWith(() => _FixedPosSale(sale)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(posSaleControllerProvider, (_, _) {});
    await container.read(posSaleControllerProvider.future);
    return container.read(customerCreditProvider(sale.id).future);
  }

  void stubNotes(List<CreditNote> list) =>
      when(() => notes.listSpendable(any())).thenAnswer((_) async => list);

  void expectNoRequest() => verifyNever(() => notes.listSpendable(any()));

  test('keeps the repository\'s oldest-first order and totals the server '
      'remaining (FR-001, FR-015)', () async {
    stubNotes([_note(1, '300.00'), _note(2, '700.00')]);

    final credit = await creditFor(_sale());

    expect(credit.notes.map((n) => n.id), [1, 2]);
    expect(compareAmounts(credit.total, '1000.00'), 0);
  });

  test('leaves out notes with nothing remaining', () async {
    stubNotes([_note(1, '0'), _note(2, '0.000000'), _note(3, '40.00')]);

    final credit = await creditFor(_sale());

    expect(credit.notes.map((n) => n.id), [3]);
    expect(compareAmounts(credit.total, '40.00'), 0);
  });

  test('leaves out a note already applied to this sale', () async {
    stubNotes([_note(1, '300.00'), _note(2, '700.00')]);
    when(
      () => payments.listForOrder(saleId: 42),
    ).thenAnswer((_) async => [_applied(501)]);

    final credit = await creditFor(_sale());

    expect(credit.notes.map((n) => n.id), [2]);
    expect(compareAmounts(credit.total, '700.00'), 0);
  });

  test('a cancelled application does not hide its note', () async {
    stubNotes([_note(1, '300.00')]);
    when(
      () => payments.listForOrder(saleId: 42),
    ).thenAnswer((_) async => [_applied(501, cancelled: true)]);

    final credit = await creditFor(_sale());

    expect(credit.notes.map((n) => n.id), [1]);
  });

  test(
    'is empty, with no request, for the walk-in customer (FR-004)',
    () async {
      stubNotes([_note(1, '300.00')]);
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          creditNoteRepositoryProvider.overrideWithValue(notes),
          customerPaymentRepositoryProvider.overrideWithValue(payments),
          accessControlProvider.overrideWithValue(_access()),
        ],
      );
      addTearDown(container.dispose);
      final walkIn = container.read(appSettingsProvider).posDefaultCustomerId;

      final credit = await creditFor(_sale(customer: walkIn));

      expect(credit.notes, isEmpty);
      expect(compareAmounts(credit.total, '0'), 0);
      expectNoRequest();
    },
  );

  test('is empty, with no request, on a cancelled sale (FR-007)', () async {
    stubNotes([_note(1, '300.00')]);

    final credit = await creditFor(_sale(status: SaleStatus.cancelled));

    expect(credit.notes, isEmpty);
    expectNoRequest();
  });

  test('is empty, with no request, when nothing is owed (FR-007)', () async {
    stubNotes([_note(1, '300.00')]);

    final credit = await creditFor(
      _sale(status: SaleStatus.paid, balance: '0.00'),
    );

    expect(credit.notes, isEmpty);
    expectNoRequest();
  });

  test(
    'is empty, with no request, without credit-payments read (FR-014)',
    () async {
      stubNotes([_note(1, '300.00')]);

      final credit = await creditFor(
        _sale(),
        access: _access(creditRead: false),
      );

      expect(credit.notes, isEmpty);
      expectNoRequest();
    },
  );

  test(
    'is empty, with no request, without customer-payments create (FR-014)',
    () async {
      stubNotes([_note(1, '300.00')]);

      final credit = await creditFor(
        _sale(),
        access: _access(paymentsCreate: false),
      );

      expect(credit.notes, isEmpty);
      expectNoRequest();
    },
  );

  group('creditTenderAllowed', () {
    test('needs an open sale, a balance and both privileges', () {
      expect(creditTenderAllowed(_sale(), _access()), isTrue);
      expect(
        creditTenderAllowed(_sale(status: SaleStatus.cancelled), _access()),
        isFalse,
      );
      expect(creditTenderAllowed(_sale(balance: '0'), _access()), isFalse);
      expect(creditTenderAllowed(_sale(), _access(creditRead: false)), isFalse);
      expect(
        creditTenderAllowed(_sale(), _access(paymentsCreate: false)),
        isFalse,
      );
    });
  });
}
