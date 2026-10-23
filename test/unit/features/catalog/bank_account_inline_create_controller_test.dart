import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/bank_account_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/bank_account_inline_create_controller.dart';

class MockBankAccountRepository extends Mock implements BankAccountRepository {}

const _created = BankAccount(
  bankAccountId: 5,
  bankName: 'BBVA',
  accountNumber: '0123456789',
);

void main() {
  late MockBankAccountRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockBankAccountRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [bankAccountRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  BankAccountInlineCreateController notifierOf() =>
      container.read(bankAccountInlineCreateControllerProvider.notifier);
  BankAccountInlineCreateState stateOf() =>
      container.read(bankAccountInlineCreateControllerProvider);

  void stubCreate() => when(
    () => repository.create(
      bankName: any(named: 'bankName'),
      accountNumber: any(named: 'accountNumber'),
      reference: any(named: 'reference'),
      routingNumber: any(named: 'routingNumber'),
      comment: any(named: 'comment'),
    ),
  ).thenAnswer((_) async => _created);

  void verifyNoCreate() => verifyNever(
    () => repository.create(
      bankName: any(named: 'bankName'),
      accountNumber: any(named: 'accountNumber'),
      reference: any(named: 'reference'),
      routingNumber: any(named: 'routingNumber'),
      comment: any(named: 'comment'),
    ),
  );

  test('bank name and account number are required', () async {
    notifierOf().bankNameChanged('  ');

    await notifierOf().submit();

    expect(stateOf().fieldErrors, {
      'bank_name': BankAccountInlineCreateErrorCode.required,
      'account_number': BankAccountInlineCreateErrorCode.required,
    });
    verifyNoCreate();
  });

  for (final entry in {
    'bank_name': 251,
    'account_number': 21,
    'reference': 21,
    'routing_number': 19,
    'comment': 501,
  }.entries) {
    test('${entry.key} longer than its limit is rejected', () async {
      notifierOf()
        ..bankNameChanged('BBVA')
        ..accountNumberChanged('0123456789');
      final tooLong = 'x' * entry.value;
      switch (entry.key) {
        case 'bank_name':
          notifierOf().bankNameChanged(tooLong);
        case 'account_number':
          notifierOf().accountNumberChanged(tooLong);
        case 'reference':
          notifierOf().referenceChanged(tooLong);
        case 'routing_number':
          notifierOf().routingNumberChanged(tooLong);
        case 'comment':
          notifierOf().commentChanged(tooLong);
      }

      await notifierOf().submit();

      expect(stateOf().fieldErrors, {
        entry.key: BankAccountInlineCreateErrorCode.tooLong,
      });
      verifyNoCreate();
    });
  }

  test('a valid form creates the account, sending blanks as null', () async {
    stubCreate();
    notifierOf()
      ..bankNameChanged(' BBVA ')
      ..accountNumberChanged('0123456789')
      ..referenceChanged('  ');

    await notifierOf().submit();

    expect(stateOf().created, _created);
    expect(stateOf().submitting, isFalse);
    verify(
      () => repository.create(
        bankName: 'BBVA',
        accountNumber: '0123456789',
        reference: null,
        routingNumber: null,
        comment: null,
      ),
    ).called(1);
  });

  test('a server ValidationError maps to fieldErrors by loc.last', () async {
    when(
      () => repository.create(
        bankName: any(named: 'bankName'),
        accountNumber: any(named: 'accountNumber'),
        reference: any(named: 'reference'),
        routingNumber: any(named: 'routingNumber'),
        comment: any(named: 'comment'),
      ),
    ).thenThrow(
      const AppError.validation([
        FieldError(
          loc: ['body', 'account_number'],
          msg: 'Already in use',
          type: 'value_error',
        ),
      ]),
    );
    notifierOf()
      ..bankNameChanged('BBVA')
      ..accountNumberChanged('0123456789');

    await notifierOf().submit();

    expect(stateOf().fieldErrors['account_number'], 'Already in use');
    expect(stateOf().created, isNull);
    expect(stateOf().submitting, isFalse);
  });

  test('any other AppError sets createFailed and the server detail', () async {
    when(
      () => repository.create(
        bankName: any(named: 'bankName'),
        accountNumber: any(named: 'accountNumber'),
        reference: any(named: 'reference'),
        routingNumber: any(named: 'routingNumber'),
        comment: any(named: 'comment'),
      ),
    ).thenThrow(const AppError.server(statusCode: 500, message: 'down'));
    notifierOf()
      ..bankNameChanged('BBVA')
      ..accountNumberChanged('0123456789');

    await notifierOf().submit();

    expect(stateOf().error, BankAccountInlineCreateErrorCode.createFailed);
    expect(stateOf().errorDetail, 'down');
    expect(stateOf().created, isNull);
  });
}
