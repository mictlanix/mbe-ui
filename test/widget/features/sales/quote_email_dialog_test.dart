import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/quote_email.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_email_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

const _brand = BrandConfig(displayName: 'Mictlanix Business Essentials');

Customer _customer({
  List<Contact>? contacts,
  List<TaxpayerRecipient>? taxpayers,
}) => Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LA PAZ',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  contacts:
      contacts ??
      const [
        Contact(contactId: 1, name: 'Juan Pérez', email: 'juan@lapaz.mx'),
        Contact(contactId: 2, name: 'Compras', email: 'compras@lapaz.mx'),
      ],
  taxpayers:
      taxpayers ??
      const [
        TaxpayerRecipient(
          taxpayerRecipientId: 'RFC1',
          name: 'FERRETERÍA LA PAZ SA DE CV',
          email: 'fact@lapaz.mx',
        ),
      ],
);

Key _chip(String address) => Key('quote_email_chip_${address.toLowerCase()}');

void main() {
  late MockSalesQuoteRepository quotes;
  late MockCustomerRepository customers;
  late AppLocalizations l10n;
  Future<QuoteEmailOutcome?>? outcome;
  var resolved = false;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    quotes = MockSalesQuoteRepository();
    customers = MockCustomerRepository();
    outcome = null;
    resolved = false;
    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
  });

  Future<void> open(
    WidgetTester tester, {
    Size surface = const Size(1200, 1600),
    Sale? quote,
    bool settle = true,
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          salesQuoteOverride(quotes),
          customerRepositoryProvider.overrideWithValue(customers),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          theme: AppTheme.of(_brand).light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('launcher'),
                  onPressed: () {
                    outcome = showQuoteEmailDialog(
                      context,
                      quote:
                          quote ??
                          testQuote(
                            id: 42,
                            serial: 1001,
                            status: SaleStatus.completed,
                            customer: 7,
                          ),
                    )..then((_) => resolved = true);
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('launcher')));
    // A never-resolving customer keeps a spinner animating forever.
    settle
        ? await tester.pumpAndSettle()
        : await tester.pump(const Duration(milliseconds: 300));
  }

  Finder key(String k) => find.byKey(Key(k));

  bool selected(WidgetTester tester, String address) =>
      tester.widget<FilterChip>(find.byKey(_chip(address))).selected;

  FilledButton sendButton(WidgetTester tester) =>
      tester.widget<FilledButton>(key('quote_email_send_button'));

  Future<void> tapChip(WidgetTester tester, String address) async {
    await tester.tap(find.byKey(_chip(address)));
    await tester.pump();
  }

  Future<void> typeAndAdd(WidgetTester tester, String text) async {
    await tester.enterText(key('quote_email_other_field'), text);
    await tester.tap(key('quote_email_add_button'));
    // Not pumpAndSettle: the loading spinner never settles.
    await tester.pump(const Duration(milliseconds: 300));
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(key('quote_email_other_field')).controller!.text;

  Future<void> send(
    WidgetTester tester, {
    String address = 'juan@lapaz.mx',
  }) async {
    await tapChip(tester, address);
    await tester.tap(key('quote_email_send_button'));
    await tester.pumpAndSettle();
  }

  void stubEmailThrows(AppError error) {
    when(
      () => quotes.email(
        quoteId: any(named: 'quoteId'),
        recipients: any(named: 'recipients'),
      ),
    ).thenAnswer((_) async => throw error);
  }

  group('initial state', () {
    testWidgets('title, chips order and labels, nothing selected', (
      tester,
    ) async {
      await open(tester);

      expect(
        find.text(l10n.salesQuoteEmailDialogTitle('1001')),
        findsOneWidget,
      );
      expect(find.text('Enviar cotización 1001'), findsOneWidget);

      final chipKeys = tester
          .widgetList<FilterChip>(find.byType(FilterChip))
          .map((c) => c.key)
          .toList();
      expect(chipKeys, [
        _chip('juan@lapaz.mx'),
        _chip('compras@lapaz.mx'),
        _chip('fact@lapaz.mx'),
      ]);

      void expectLabel(String address, String owner) {
        expect(
          find.descendant(
            of: find.byKey(_chip(address)),
            matching: find.text(owner),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(_chip(address)),
            matching: find.text(' · $address'),
          ),
          findsOneWidget,
        );
      }

      expectLabel('juan@lapaz.mx', 'Juan Pérez');
      expectLabel('compras@lapaz.mx', 'Compras');
      expectLabel('fact@lapaz.mx', 'FERRETERÍA LA PAZ SA DE CV');

      for (final a in ['juan@lapaz.mx', 'compras@lapaz.mx', 'fact@lapaz.mx']) {
        expect(selected(tester, a), isFalse);
      }
      expect(sendButton(tester).onPressed, isNull);
      expect(
        tester.widget<Text>(key('quote_email_counter')).data,
        l10n.salesQuoteEmailLimitHint,
      );
      expect(find.text('Hasta 10 destinatarios.'), findsOneWidget);
    });

    testWidgets('a draft without serial shows the provisional reference', (
      tester,
    ) async {
      await open(tester, quote: testQuote(id: 42, customer: 7));
      expect(find.text(l10n.salesQuoteEmailDialogTitle('#42')), findsOneWidget);
    });

    testWidgets('chip Wrap uses the theme spacing', (tester) async {
      await open(tester);
      final wrap = tester.widget<Wrap>(
        find
            .ancestor(
              of: find.byKey(_chip('juan@lapaz.mx')),
              matching: find.byType(Wrap),
            )
            .first,
      );
      final spacing = Theme.of(
        tester.element(key('quote_email_dialog')),
      ).spacing;
      expect(wrap.spacing, spacing.xs);
      expect(wrap.runSpacing, spacing.xs);
    });
  });

  group('selection', () {
    testWidgets('toggling a chip enables Send and updates the counter', (
      tester,
    ) async {
      await open(tester);

      await tapChip(tester, 'juan@lapaz.mx');
      expect(selected(tester, 'juan@lapaz.mx'), isTrue);
      expect(sendButton(tester).onPressed, isNotNull);
      expect(
        tester.widget<Text>(key('quote_email_counter')).data,
        l10n.salesQuoteEmailCounter(1),
      );
      expect(find.text('1 de 10 destinatarios.'), findsOneWidget);

      await tapChip(tester, 'juan@lapaz.mx');
      expect(selected(tester, 'juan@lapaz.mx'), isFalse);
      expect(sendButton(tester).onPressed, isNull);
      expect(find.text(l10n.salesQuoteEmailLimitHint), findsOneWidget);
    });
  });

  group('typed addresses', () {
    testWidgets('Add creates a selected chip and clears the field', (
      tester,
    ) async {
      await open(tester);
      await typeAndAdd(tester, 'pedro@gmail.com');

      expect(find.byKey(_chip('pedro@gmail.com')), findsOneWidget);
      expect(selected(tester, 'pedro@gmail.com'), isTrue);
      expect(fieldText(tester), isEmpty);
      expect(sendButton(tester).onPressed, isNotNull);
    });

    testWidgets('Enter on the field adds the address', (tester) async {
      await open(tester);
      await tester.enterText(key('quote_email_other_field'), 'pedro@gmail.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(selected(tester, 'pedro@gmail.com'), isTrue);
      expect(fieldText(tester), isEmpty);
    });

    testWidgets('an invalid address shows the error until edited', (
      tester,
    ) async {
      await open(tester);
      final before = find.byType(FilterChip).evaluate().length;
      await typeAndAdd(tester, 'pedro@');

      expect(find.text(l10n.salesQuoteEmailInvalidAddress), findsOneWidget);
      expect(find.byType(FilterChip).evaluate().length, before);

      await tester.enterText(key('quote_email_other_field'), 'pedro@g');
      await tester.pump();
      expect(find.text(l10n.salesQuoteEmailInvalidAddress), findsNothing);
    });

    testWidgets('a case variant of an existing chip selects that chip', (
      tester,
    ) async {
      await open(tester);
      final before = find.byType(FilterChip).evaluate().length;
      await typeAndAdd(tester, 'JUAN@LaPaz.mx');

      expect(find.byType(FilterChip).evaluate().length, before);
      expect(selected(tester, 'juan@lapaz.mx'), isTrue);
      expect(fieldText(tester), isEmpty);
    });
  });

  group('limit', () {
    testWidgets('ten selected: limit text, Add disabled, 11th chip ignored', (
      tester,
    ) async {
      when(
        () => customers.get(customerId: any(named: 'customerId')),
      ).thenAnswer(
        (_) async => _customer(
          contacts: [
            for (var i = 1; i <= 11; i++)
              Contact(contactId: i, name: 'C$i', email: 'c$i@lapaz.mx'),
          ],
          taxpayers: const [],
        ),
      );
      await open(tester);

      for (var i = 1; i <= 10; i++) {
        await tapChip(tester, 'c$i@lapaz.mx');
      }
      expect(
        tester.widget<Text>(key('quote_email_counter')).data,
        l10n.salesQuoteEmailLimitReached,
      );
      expect(
        tester.widget<OutlinedButton>(key('quote_email_add_button')).onPressed,
        isNull,
      );

      await tapChip(tester, 'c11@lapaz.mx');
      expect(selected(tester, 'c11@lapaz.mx'), isFalse);
      expect(
        tester.widget<Text>(key('quote_email_counter')).data,
        l10n.salesQuoteEmailLimitReached,
      );
    });
  });

  group('suggestions', () {
    testWidgets('no known addresses', (tester) async {
      when(
        () => customers.get(customerId: any(named: 'customerId')),
      ).thenAnswer(
        (_) async => _customer(contacts: const [], taxpayers: const []),
      );
      await open(tester);

      expect(key('quote_email_no_addresses'), findsOneWidget);
      expect(find.text(l10n.salesQuoteEmailNoKnownAddresses), findsOneWidget);
      await typeAndAdd(tester, 'pedro@gmail.com');
      expect(selected(tester, 'pedro@gmail.com'), isTrue);
    });

    testWidgets('loading still lets the user type', (tester) async {
      final never = Completer<Customer>();
      when(
        () => customers.get(customerId: any(named: 'customerId')),
      ).thenAnswer((_) => never.future);
      await open(tester, settle: false);

      expect(key('quote_email_suggestions_loading'), findsOneWidget);
      expect(find.text(l10n.salesQuoteEmailSuggestionsLoading), findsOneWidget);
      await typeAndAdd(tester, 'pedro@gmail.com');
      expect(selected(tester, 'pedro@gmail.com'), isTrue);
    });

    testWidgets('failure shows retry, which loads the chips', (tester) async {
      when(
        () => customers.get(customerId: any(named: 'customerId')),
      ).thenAnswer((_) async => throw const AppError.server());
      await open(tester);

      expect(find.text(l10n.salesQuoteEmailSuggestionsFailed), findsOneWidget);
      expect(key('quote_email_suggestions_retry'), findsOneWidget);

      when(
        () => customers.get(customerId: any(named: 'customerId')),
      ).thenAnswer((_) async => _customer());
      await tester.tap(key('quote_email_suggestions_retry'));
      await tester.pumpAndSettle();

      expect(find.byKey(_chip('juan@lapaz.mx')), findsOneWidget);
      expect(key('quote_email_suggestions_retry'), findsNothing);
    });
  });

  group('sending', () {
    testWidgets('in flight: busy label, disabled controls, not dismissible', (
      tester,
    ) async {
      final pending = Completer<QuoteEmailReceipt>();
      when(
        () => quotes.email(
          quoteId: any(named: 'quoteId'),
          recipients: any(named: 'recipients'),
        ),
      ).thenAnswer((_) => pending.future);
      await open(tester);

      await tapChip(tester, 'juan@lapaz.mx');
      await tester.tap(key('quote_email_send_button'));
      await tester.pump();

      expect(
        find.descendant(
          of: key('quote_email_send_button'),
          matching: find.text(l10n.salesQuoteEmailSendingLabel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: key('quote_email_send_button'),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(sendButton(tester).onPressed, isNull);
      expect(
        tester
            .widget<FilterChip>(find.byKey(_chip('juan@lapaz.mx')))
            .onSelected,
        isNull,
      );
      expect(
        tester.widget<TextField>(key('quote_email_other_field')).enabled,
        isFalse,
      );
      expect(
        tester.widget<OutlinedButton>(key('quote_email_add_button')).onPressed,
        isNull,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 300));
      expect(key('quote_email_dialog'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 300));
      expect(key('quote_email_dialog'), findsOneWidget);
      expect(resolved, isFalse);

      pending.complete(
        QuoteEmailReceipt(
          recipients: const ['juan@lapaz.mx'],
          sentAt: DateTime(2026, 8, 5),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('success resolves to QuoteEmailSent and closes', (
      tester,
    ) async {
      when(
        () => quotes.email(
          quoteId: 42,
          recipients: const ['juan@lapaz.mx', 'fact@lapaz.mx'],
        ),
      ).thenAnswer(
        (_) async => QuoteEmailReceipt(
          recipients: const ['juan@lapaz.mx', 'fact@lapaz.mx'],
          sentAt: DateTime(2026, 8, 5),
        ),
      );
      await open(tester);
      await tapChip(tester, 'fact@lapaz.mx');
      await tapChip(tester, 'juan@lapaz.mx');
      await tester.tap(key('quote_email_send_button'));
      await tester.pumpAndSettle();

      expect(key('quote_email_dialog'), findsNothing);
      final result = await outcome;
      expect(result, isA<QuoteEmailSent>());
      expect((result! as QuoteEmailSent).receipt.recipients, [
        'juan@lapaz.mx',
        'fact@lapaz.mx',
      ]);
    });

    Future<void> expectFailure(
      WidgetTester tester,
      AppError error,
      String text,
    ) async {
      stubEmailThrows(error);
      await open(tester);
      await send(tester);

      expect(key('quote_email_error_banner'), findsOneWidget);
      expect(
        find.descendant(
          of: key('quote_email_error_banner'),
          matching: find.text(text),
        ),
        findsOneWidget,
      );
      expect(selected(tester, 'juan@lapaz.mx'), isTrue);
      expect(sendButton(tester).onPressed, isNotNull);
      expect(key('quote_email_dialog'), findsOneWidget);
    }

    testWidgets('409 -> not sendable', (tester) async {
      await expectFailure(
        tester,
        const AppError.server(statusCode: 409, message: 'raw detail'),
        l10n.salesQuoteEmailNotSendable,
      );
    });

    testWidgets('502 -> mail refused', (tester) async {
      await expectFailure(
        tester,
        const AppError.server(statusCode: 502),
        l10n.salesQuoteEmailMailRefused,
      );
    });

    testWidgets('503 -> mail unavailable', (tester) async {
      await expectFailure(
        tester,
        const AppError.server(statusCode: 503),
        l10n.salesQuoteEmailMailUnavailable,
      );
    });

    testWidgets('422 -> the server field message', (tester) async {
      await expectFailure(
        tester,
        const AppError.validation([
          FieldError(
            loc: ['body', 'recipients', '0'],
            msg: 'Dirección rechazada por el servidor',
            type: 'value_error',
          ),
        ]),
        'Dirección rechazada por el servidor',
      );
    });

    testWidgets('network error -> generic network text', (tester) async {
      await expectFailure(
        tester,
        const AppError.network('DioException boom'),
        l10n.errorNetworkGeneric,
      );
    });

    testWidgets('the banner can be dismissed', (tester) async {
      stubEmailThrows(const AppError.server(statusCode: 502));
      await open(tester);
      await send(tester);
      expect(key('quote_email_error_banner'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: key('quote_email_error_banner'),
          matching: find.byType(IconButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(key('quote_email_error_banner'), findsNothing);
      expect(selected(tester, 'juan@lapaz.mx'), isTrue);
    });
  });

  group('closing', () {
    testWidgets('Cancel without a failure resolves to null', (tester) async {
      await open(tester);
      await tester.tap(key('quote_email_cancel_button'));
      await tester.pumpAndSettle();

      expect(key('quote_email_dialog'), findsNothing);
      expect(await outcome, isNull);
    });

    testWidgets('409 then Cancel resolves to QuoteEmailStaleQuote', (
      tester,
    ) async {
      stubEmailThrows(const AppError.server(statusCode: 409));
      await open(tester);
      await send(tester);
      await tester.tap(key('quote_email_cancel_button'));
      await tester.pumpAndSettle();

      expect(await outcome, isA<QuoteEmailStaleQuote>());
    });

    testWidgets('409 then barrier tap resolves to QuoteEmailStaleQuote', (
      tester,
    ) async {
      stubEmailThrows(const AppError.server(statusCode: 409));
      await open(tester);
      await send(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(key('quote_email_dialog'), findsNothing);
      expect(await outcome, isA<QuoteEmailStaleQuote>());
    });

    testWidgets('a non-409 failure then Cancel still resolves to null', (
      tester,
    ) async {
      stubEmailThrows(const AppError.server(statusCode: 502));
      await open(tester);
      await send(tester);
      await tester.tap(key('quote_email_cancel_button'));
      await tester.pumpAndSettle();

      expect(await outcome, isNull);
    });
  });

  group('compact', () {
    testWidgets('close and Send work from the top bar', (tester) async {
      when(
        () => quotes.email(
          quoteId: any(named: 'quoteId'),
          recipients: any(named: 'recipients'),
        ),
      ).thenAnswer(
        (_) async => QuoteEmailReceipt(
          recipients: const ['juan@lapaz.mx'],
          sentAt: DateTime(2026, 8, 5),
        ),
      );
      await open(tester, surface: const Size(500, 1000));

      expect(key('responsive_dialog_close'), findsOneWidget);
      expect(key('quote_email_cancel_button'), findsNothing);
      expect(sendButton2(tester).onPressed, isNull);

      // Close
      await tester.tap(key('responsive_dialog_close'));
      await tester.pumpAndSettle();
      expect(key('quote_email_dialog'), findsNothing);
      expect(await outcome, isNull);

      // Reopen and send from the top bar.
      await tester.tap(find.byKey(const Key('launcher')));
      await tester.pumpAndSettle();
      await tapChip(tester, 'juan@lapaz.mx');
      expect(sendButton2(tester).onPressed, isNotNull);
      await tester.tap(key('quote_email_send_button'));
      await tester.pumpAndSettle();

      expect(key('quote_email_dialog'), findsNothing);
      expect(await outcome, isA<QuoteEmailSent>());
    });
  });
}

TextButton sendButton2(WidgetTester tester) =>
    tester.widget<TextButton>(find.byKey(const Key('quote_email_send_button')));
