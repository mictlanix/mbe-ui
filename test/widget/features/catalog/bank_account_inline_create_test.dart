import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/bank_account_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/bank_account_inline_create.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockBankAccountRepository extends Mock implements BankAccountRepository {}

void main() {
  late MockBankAccountRepository repository;
  late BankAccount? returned;
  late bool closed;

  setUp(() {
    repository = MockBankAccountRepository();
    returned = null;
    closed = false;
  });

  void stubCreate(Future<BankAccount> Function() answer) => when(
    () => repository.create(
      bankName: any(named: 'bankName'),
      accountNumber: any(named: 'accountNumber'),
      reference: any(named: 'reference'),
      routingNumber: any(named: 'routingNumber'),
      comment: any(named: 'comment'),
    ),
  ).thenAnswer((_) => answer());

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          bankAccountRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returned = await showBankAccountInlineCreateDialog(context);
                    closed = true;
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('bank_account_bank_name_field')),
      'BBVA',
    );
    await tester.enterText(
      find.byKey(const Key('bank_account_number_field')),
      '0123456789',
    );
    await tester.tap(find.byKey(const Key('bank_account_save_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('on success the created account is returned and the dialog '
      'closes', (tester) async {
    stubCreate(
      () async => const BankAccount(
        bankAccountId: 5,
        bankName: 'BBVA',
        accountNumber: '0123456789',
      ),
    );
    await openDialog(tester);

    await fillAndSave(tester);

    expect(closed, isTrue);
    expect(returned?.bankAccountId, 5);
    expect(find.byKey(const Key('bank_account_save_button')), findsNothing);
  });

  testWidgets('a failure keeps the dialog open with its input and an '
      'ErrorBanner', (tester) async {
    stubCreate(
      () async => throw const AppError.server(statusCode: 500, message: 'down'),
    );
    await openDialog(tester);

    await fillAndSave(tester);

    expect(closed, isFalse);
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('bank_account_bank_name_field')),
        matching: find.text('BBVA'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('bank_account_number_field')),
        matching: find.text('0123456789'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty required fields show the required message and do not '
      'call the repository', (tester) async {
    await openDialog(tester);

    await tester.tap(find.byKey(const Key('bank_account_save_button')));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.fieldRequired), findsNWidgets(2));
    verifyNever(
      () => repository.create(
        bankName: any(named: 'bankName'),
        accountNumber: any(named: 'accountNumber'),
        reference: any(named: 'reference'),
        routingNumber: any(named: 'routingNumber'),
        comment: any(named: 'comment'),
      ),
    );
  });

  testWidgets('Cancel returns null', (tester) async {
    await openDialog(tester);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(returned, isNull);
  });
}
