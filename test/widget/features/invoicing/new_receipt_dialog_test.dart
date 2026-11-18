import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/new_invoice_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';

class _MockDocuments extends Mock implements FiscalDocumentRepository {}

class _MockCustomers extends Mock implements CustomerRepository {}

const _acme = TaxpayerRecipient(
  taxpayerRecipientId: 'AAA010101AAA',
  name: 'Acme SA',
  email: 'a@acme.mx',
);
const _acmeNorte = TaxpayerRecipient(
  taxpayerRecipientId: 'BBB010101BBB',
  name: 'Acme Norte SA',
  email: 'b@acme.mx',
);

Customer _customer(List<TaxpayerRecipient> taxpayers) => Customer(
  customerId: 4,
  code: 'C-4',
  name: 'Cliente 4',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  taxpayers: taxpayers,
);

final _payment = CustomerPayment(
  customerPaymentId: 4127,
  customerId: 4,
  customerName: 'Cliente 4',
  amount: '11600.00',
  currency: Currency.mxn,
  methodCode: 3,
  reference: 'SPEI 99812',
  date: DateTime(2026, 11, 12, 9, 30),
  facilityId: 9,
  type: PaymentType.immediate,
  unapplied: '0.00',
);

AppError _refusal(String name, api.ErrorCode code, [Map<String, Object?>? p]) =>
    AppError.server(
      statusCode: 422,
      problem: ApiProblem(codeName: name, code: code, params: p ?? const {}),
    );

/// Spec 074 C35: the shared create dialog in its two receipt modes.
void main() {
  late _MockDocuments documents;
  late _MockCustomers customers;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(
      const NewPaymentReceipt(customerId: 1, recipientRfc: 'X'),
    );
  });

  setUp(() {
    documents = _MockDocuments();
    customers = _MockCustomers();
    when(
      () => customers.list(
        search: any(named: 'search'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CustomerPage(
        items: [
          CustomerListItem(
            customerId: 4,
            code: 'C-4',
            name: 'Cliente 4',
            creditLimit: '0',
            creditDays: 0,
            priceList: const PriceListRef(id: 1, name: 'Mostrador'),
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
  });

  void customerHas(List<TaxpayerRecipient> t) => when(
    () => customers.get(customerId: 4),
  ).thenAnswer((_) async => _customer(t));

  Finder key(String k) => find.byKey(Key(k));

  /// Opens the dialog from a button and records what it answered.
  Future<List<int?>> open(
    WidgetTester tester,
    NewFiscalDocumentMode mode, {
    Size size = const Size(1200, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        fiscalDocumentRepositoryProvider.overrideWithValue(documents),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
    );
    addTearDown(container.dispose);
    final answers = <int?>[];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                key: const Key('host_open'),
                onPressed: () async => answers.add(
                  await showNewFiscalDocumentDialog(context, mode),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(key('host_open'));
    await tester.pumpAndSettle();
    return answers;
  }

  NewFiscalDocumentMode fromPayment() =>
      NewFiscalDocumentMode.receiptFromPayment(_payment);

  String titleText(WidgetTester tester) =>
      tester.widget<Text>(key('responsive_dialog_title')).data!;

  group('from a customer payment', () {
    testWidgets('shows the payment, fixes the customer and preselects a single '
        'RFC', (tester) async {
      customerHas([_acme]);
      await open(tester, fromPayment());

      expect(titleText(tester), l10n.fiscalDocumentIssueReceiptTitle);
      final summary = tester.widget<Text>(key('new_receipt_payment_summary'));
      expect(summary.data, contains('Pago #4127'));
      expect(summary.data, contains('Cliente 4'));
      expect(summary.data, contains(r'$11,600.00'));
      expect(summary.data, contains('MXN'));
      expect(summary.data, contains('2026-11-12'));
      expect(find.text(l10n.fiscalDocumentIssueReceiptHint), findsOneWidget);
      // No customer to pick.
      expect(key('new_invoice_customer'), findsNothing);
      expect(key('new_invoice_recipient'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(key('new_invoice_submit')).onPressed,
        isNotNull,
      );
    });

    testWidgets('Crear sends the payment and answers the new id', (
      tester,
    ) async {
      customerHas([_acme, _acmeNorte]);
      when(
        () => documents.createPaymentReceipt(any()),
      ).thenAnswer((_) async => aPaymentReceipt(id: 88));
      final answers = await open(tester, fromPayment());

      // Two RFCs: the clerk chooses.
      expect(
        tester.widget<FilledButton>(key('new_invoice_submit')).onPressed,
        isNull,
      );
      await tester.tap(key('new_invoice_recipient'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('BBB010101BBB').last);
      await tester.pumpAndSettle();
      await tester.tap(key('new_invoice_submit'));
      await tester.pumpAndSettle();

      final sent =
          verify(
                () => documents.createPaymentReceipt(captureAny()),
              ).captured.single
              as NewPaymentReceipt;
      expect(sent.customerId, 4);
      expect(sent.recipientRfc, 'BBB010101BBB');
      expect(sent.customerPaymentId, 4127);
      expect(answers, [88]);
      expect(key('new_invoice_dialog'), findsNothing);
    });

    testWidgets('a payment that already has a receipt offers to open it', (
      tester,
    ) async {
      customerHas([_acme]);
      when(() => documents.createPaymentReceipt(any())).thenThrow(
        _refusal(
          'fiscal_document.payment_already_receipted',
          api.ErrorCode.fiscalDocumentPeriodPaymentAlreadyReceipted,
          const {'fiscal_document_id': 77},
        ),
      );
      final answers = await open(tester, fromPayment());

      await tester.tap(key('new_invoice_submit'));
      await tester.pumpAndSettle();

      expect(key('new_invoice_dialog'), findsOneWidget);
      expect(
        find.text(l10n.apiErrorFiscalDocumentPaymentAlreadyReceipted),
        findsOneWidget,
      );
      expect(key('new_receipt_open_existing'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentReceiptOpenExisting), findsOneWidget);

      await tester.tap(key('new_receipt_open_existing'));
      await tester.pumpAndSettle();

      expect(answers, [77]);
      expect(key('new_invoice_dialog'), findsNothing);
    });

    for (final (name, code, text) in [
      (
        'fiscal_document.issuer_has_no_series',
        api.ErrorCode.fiscalDocumentPeriodIssuerHasNoSeries,
        () => l10n.apiErrorFiscalDocumentIssuerHasNoSeries,
      ),
      (
        'fiscal_document.recipient_not_linked',
        api.ErrorCode.fiscalDocumentPeriodRecipientNotLinked,
        () => l10n.apiErrorFiscalDocumentRecipientNotLinked,
      ),
      (
        'fiscal_document.payment_other_customer',
        api.ErrorCode.fiscalDocumentPeriodPaymentOtherCustomer,
        () => l10n.apiErrorFiscalDocumentPaymentOtherCustomer,
      ),
    ]) {
      testWidgets('$name stays inline, without an open-existing button', (
        tester,
      ) async {
        customerHas([_acme]);
        when(
          () => documents.createPaymentReceipt(any()),
        ).thenThrow(_refusal(name, code, const {'type': 200}));
        await open(tester, fromPayment());

        await tester.tap(key('new_invoice_submit'));
        await tester.pumpAndSettle();

        expect(key('new_invoice_dialog'), findsOneWidget);
        expect(find.text(text()), findsOneWidget);
        expect(key('new_receipt_open_existing'), findsNothing);
      });
    }

    testWidgets('a customer with no taxpayers cannot continue', (tester) async {
      customerHas(const []);
      await open(tester, fromPayment());

      expect(key('new_invoice_no_taxpayers'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(key('new_invoice_submit')).onPressed,
        isNull,
      );
    });

    testWidgets('both buttons are disabled while the request runs', (
      tester,
    ) async {
      customerHas([_acme]);
      final pending = Completer<FiscalDocument>();
      when(
        () => documents.createPaymentReceipt(any()),
      ).thenAnswer((_) => pending.future);
      await open(tester, fromPayment());

      await tester.tap(key('new_invoice_submit'));
      await tester.pump();

      expect(
        tester.widget<FilledButton>(key('new_invoice_submit')).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, l10n.cancelButton),
            )
            .onPressed,
        isNull,
      );

      pending.complete(aPaymentReceipt(id: 5));
      await tester.pumpAndSettle();
    });
  });

  group('by hand', () {
    testWidgets('shows the receipt title and hint with the customer picker', (
      tester,
    ) async {
      await open(tester, NewFiscalDocumentMode.receipt);

      expect(titleText(tester), l10n.fiscalDocumentNewReceiptTitle);
      expect(find.text(l10n.fiscalDocumentNewReceiptHint), findsOneWidget);
      expect(key('new_invoice_customer'), findsOneWidget);
      expect(key('new_receipt_payment_summary'), findsNothing);
    });

    testWidgets('creates a receipt with no payment id', (tester) async {
      customerHas([_acme]);
      when(() => documents.createPaymentReceipt(any())).thenAnswer(
        (_) async => aPaymentReceipt(id: 90, customerPaymentId: null),
      );
      final answers = await open(tester, NewFiscalDocumentMode.receipt);

      await tester.enterText(
        find.descendant(
          of: key('new_invoice_customer'),
          matching: find.byType(TextFormField),
        ),
        'cli',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('C-4 — Cliente 4'));
      await tester.pumpAndSettle();
      await tester.tap(key('new_invoice_submit'));
      await tester.pumpAndSettle();

      final sent =
          verify(
                () => documents.createPaymentReceipt(captureAny()),
              ).captured.single
              as NewPaymentReceipt;
      expect(sent.customerPaymentId, isNull);
      expect(answers, [90]);
    });
  });

  testWidgets('the invoice mode is the old "Nueva factura" dialog', (
    tester,
  ) async {
    await open(tester, NewFiscalDocumentMode.invoice);

    expect(titleText(tester), l10n.fiscalDocumentNewTitle);
    expect(key('new_invoice_customer'), findsOneWidget);
    expect(key('new_receipt_payment_summary'), findsNothing);
    expect(find.text(l10n.fiscalDocumentNewReceiptHint), findsNothing);
  });
}
