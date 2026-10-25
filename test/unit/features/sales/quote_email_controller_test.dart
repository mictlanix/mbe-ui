import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/quote_email.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_quote_repository.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_email_controller.dart';

class MockSalesQuoteRepository extends Mock implements SalesQuoteRepository {}

Contact contact(int id, String name, String? email) =>
    Contact(contactId: id, name: name, email: email);

TaxpayerRecipient taxpayer(String id, String name, String email) =>
    TaxpayerRecipient(taxpayerRecipientId: id, name: name, email: email);

void main() {
  const quoteId = 7;
  late MockSalesQuoteRepository repository;
  late ProviderContainer container;
  late QuoteEmailController notifier;

  final receipt = QuoteEmailReceipt(
    recipients: const ['a@x.com'],
    sentAt: DateTime(2026, 1, 1),
  );

  QuoteEmailState read() =>
      container.read(quoteEmailControllerProvider(quoteId));

  setUp(() {
    repository = MockSalesQuoteRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [salesQuoteRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(quoteEmailControllerProvider(quoteId), (_, _) {});
    notifier = container.read(quoteEmailControllerProvider(quoteId).notifier);
  });

  void stubEmail(Future<QuoteEmailReceipt> Function() answer) {
    when(
      () => repository.email(
        quoteId: any(named: 'quoteId'),
        recipients: any(named: 'recipients'),
      ),
    ).thenAnswer((_) => answer());
  }

  void seedBasic() => notifier.seed(
    contacts: [contact(1, 'Ana', 'ana@x.com')],
    taxpayers: [taxpayer('T1', 'Acme', 'acme@x.com')],
  );

  group('seed', () {
    test('contacts first, then fiscal recipients, each in input order', () {
      notifier.seed(
        contacts: [contact(1, 'C1', 'c1@x.com'), contact(2, 'C2', 'c2@x.com')],
        taxpayers: [
          taxpayer('T1', 'T1', 't1@x.com'),
          taxpayer('T2', 'T2', 't2@x.com'),
        ],
      );
      expect(read().chips.map((c) => c.address), [
        'c1@x.com',
        'c2@x.com',
        't1@x.com',
        't2@x.com',
      ]);
      expect(read().chips.map((c) => c.origin), [
        RecipientOrigin.contact,
        RecipientOrigin.contact,
        RecipientOrigin.fiscalRecipient,
        RecipientOrigin.fiscalRecipient,
      ]);
    });

    test('a shared address shows once under the contact name', () {
      notifier.seed(
        contacts: [contact(1, 'Ana', 'Ana@X.com')],
        taxpayers: [taxpayer('T1', 'Acme', 'ana@x.COM')],
      );
      expect(read().chips, hasLength(1));
      expect(read().chips.single.owner, 'Ana');
      expect(read().chips.single.origin, RecipientOrigin.contact);
    });

    test('null, blank and implausible contact emails are skipped', () {
      notifier.seed(
        contacts: [
          contact(1, 'A', null),
          contact(2, 'B', '   '),
          contact(3, 'C', 'nope'),
          contact(4, 'D', 'd@x'),
          contact(5, 'E', ' e@x.com '),
        ],
        taxpayers: const [],
      );
      expect(read().chips.map((c) => c.address), ['e@x.com']);
    });

    test('no chip is selected initially and canSend is false', () {
      seedBasic();
      expect(read().selected, isEmpty);
      expect(read().canSend, isFalse);
    });

    test('seeding twice is idempotent', () {
      seedBasic();
      final first = read().chips;
      seedBasic();
      expect(read().chips, first);
    });

    test(
      're-seeding keeps selection and typed chips, new ones go before typed',
      () {
        seedBasic();
        notifier.toggle('ana@x.com');
        notifier.addTyped('Typed@x.com');
        notifier.seed(
          contacts: [
            contact(1, 'Ana', 'ana@x.com'),
            contact(2, 'Bo', 'bo@x.com'),
          ],
          taxpayers: [
            taxpayer('T1', 'Acme', 'acme@x.com'),
            taxpayer('T2', 'Zed', 'zed@x.com'),
          ],
        );
        expect(read().chips.map((c) => c.address), [
          'ana@x.com',
          'bo@x.com',
          'acme@x.com',
          'zed@x.com',
          'Typed@x.com',
        ]);
        expect(read().selected, {'ana@x.com', 'typed@x.com'});
      },
    );
  });

  group('toggle', () {
    test('selects and deselects', () {
      seedBasic();
      expect(notifier.toggle('ana@x.com'), RecipientToggleResult.toggled);
      expect(read().selected, {'ana@x.com'});
      expect(read().canSend, isTrue);
      expect(notifier.toggle('ana@x.com'), RecipientToggleResult.toggled);
      expect(read().selected, isEmpty);
    });

    test('unknown key is ignored', () {
      seedBasic();
      expect(notifier.toggle('who@x.com'), RecipientToggleResult.ignored);
      expect(read().selected, isEmpty);
    });

    test('an eleventh selection is refused', () {
      notifier.seed(
        contacts: [for (var i = 0; i < 11; i++) contact(i, 'C$i', 'c$i@x.com')],
        taxpayers: const [],
      );
      for (var i = 0; i < 10; i++) {
        expect(notifier.toggle('c$i@x.com'), RecipientToggleResult.toggled);
      }
      expect(read().atLimit, isTrue);
      expect(notifier.toggle('c10@x.com'), RecipientToggleResult.limitReached);
      expect(read().selected, hasLength(10));
      expect(read().selected, isNot(contains('c10@x.com')));
    });
  });

  group('addTyped', () {
    test('a new address becomes a selected typed chip', () {
      expect(notifier.addTyped('  Pedro@Y.com '), AddTypedResult.added);
      final chip = read().chips.single;
      expect(chip.address, 'Pedro@Y.com');
      expect(chip.owner, isNull);
      expect(chip.origin, RecipientOrigin.typed);
      expect(chip.label, 'Pedro@Y.com');
      expect(read().selected, {'pedro@y.com'});
    });

    test('a case variant of an existing chip selects it', () {
      seedBasic();
      expect(notifier.addTyped('ANA@x.com'), AddTypedResult.selectedExisting);
      expect(read().chips, hasLength(2));
      expect(read().selected, {'ana@x.com'});
    });

    test('an implausible address is invalid', () {
      expect(notifier.addTyped('pedro@'), AddTypedResult.invalid);
      expect(read().chips, isEmpty);
    });

    test('limit applies to new addresses, not an already selected one', () {
      for (var i = 0; i < 10; i++) {
        expect(notifier.addTyped('t$i@x.com'), AddTypedResult.added);
      }
      expect(notifier.addTyped('new@x.com'), AddTypedResult.limitReached);
      expect(read().chips, hasLength(10));
      expect(notifier.addTyped('T3@x.com'), AddTypedResult.selectedExisting);
      expect(read().selected, hasLength(10));
    });

    test('a deselected typed chip stays, unselected', () {
      notifier.addTyped('t@x.com');
      notifier.toggle('t@x.com');
      expect(read().chips.map((c) => c.address), ['t@x.com']);
      expect(read().selected, isEmpty);
    });
  });

  group('send', () {
    test(
      'passes selected addresses in chip order and returns the receipt',
      () async {
        seedBasic();
        notifier.addTyped('Zed@x.com');
        notifier.toggle('acme@x.com');
        stubEmail(() async => receipt);

        final result = await notifier.send();

        expect(result, receipt);
        verify(
          () => repository.email(
            quoteId: quoteId,
            recipients: ['acme@x.com', 'Zed@x.com'],
          ),
        ).called(1);
        expect(read().sending, isFalse);
        expect(read().failure, isNull);
      },
    );

    test(
      'while in flight: second send null, toggle/addTyped ignored',
      () async {
        seedBasic();
        notifier.toggle('ana@x.com');
        final completer = Completer<QuoteEmailReceipt>();
        stubEmail(() => completer.future);

        final first = notifier.send();
        expect(read().sending, isTrue);
        expect(read().canSend, isFalse);
        expect(await notifier.send(), isNull);
        expect(notifier.toggle('acme@x.com'), RecipientToggleResult.ignored);
        expect(notifier.addTyped('q@x.com'), AddTypedResult.ignored);
        verify(
          () => repository.email(
            quoteId: any(named: 'quoteId'),
            recipients: any(named: 'recipients'),
          ),
        ).called(1);

        completer.complete(receipt);
        expect(await first, receipt);
        expect(read().sending, isFalse);
      },
    );

    final cases = <String, (AppError, QuoteEmailFailure)>{
      '409': (
        const AppError.server(statusCode: 409),
        QuoteEmailFailure.notSendable,
      ),
      '502': (
        const AppError.server(statusCode: 502),
        QuoteEmailFailure.mailRefused,
      ),
      '503': (
        const AppError.server(statusCode: 503),
        QuoteEmailFailure.mailUnavailable,
      ),
      '422': (
        const AppError.validation([
          FieldError(loc: ['body'], msg: 'bad', type: 'value_error'),
        ]),
        QuoteEmailFailure.invalidRecipients,
      ),
      'network': (const AppError.network(), QuoteEmailFailure.other),
      '500': (const AppError.server(statusCode: 500), QuoteEmailFailure.other),
    };

    for (final entry in cases.entries) {
      final (error, failure) = entry.value;
      test('${entry.key} maps to $failure, keeping the selection', () async {
        seedBasic();
        notifier.toggle('ana@x.com');
        stubEmail(() async => throw error);

        expect(await notifier.send(), isNull);

        expect(read().failure, failure);
        expect(read().failureError, error);
        expect(read().selected, {'ana@x.com'});
        expect(read().sending, isFalse);
        expect(quoteEmailFailureOf(error), failure);
      });
    }

    test('sawNotSendable latches across later failures', () async {
      seedBasic();
      notifier.toggle('ana@x.com');
      stubEmail(() async => throw const AppError.server(statusCode: 409));
      await notifier.send();
      expect(read().sawNotSendable, isTrue);

      stubEmail(() async => throw const AppError.server(statusCode: 503));
      await notifier.send();
      expect(read().failure, QuoteEmailFailure.mailUnavailable);
      expect(read().sawNotSendable, isTrue);
    });

    test('clearFailure resets failure and failureError', () async {
      seedBasic();
      notifier.toggle('ana@x.com');
      stubEmail(() async => throw const AppError.network());
      await notifier.send();
      expect(read().failure, isNotNull);

      notifier.clearFailure();
      expect(read().failure, isNull);
      expect(read().failureError, isNull);
    });

    test('a new send clears the previous failure', () async {
      seedBasic();
      notifier.toggle('ana@x.com');
      stubEmail(() async => throw const AppError.network());
      await notifier.send();
      expect(read().failure, QuoteEmailFailure.other);

      final completer = Completer<QuoteEmailReceipt>();
      stubEmail(() => completer.future);
      final pending = notifier.send();
      expect(read().failure, isNull);
      expect(read().failureError, isNull);
      completer.complete(receipt);
      await pending;
    });
  });
}
