import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_screen.dart';
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

/// Spec 066 US3, contract C6: "Nueva factura", opened from the list.
void main() {
  late _MockDocuments documents;
  late _MockCustomers customers;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(const NewInvoice(customerId: 1, recipientRfc: 'X'));
  });

  setUp(() {
    documents = _MockDocuments();
    customers = _MockCustomers();
    when(
      () => documents.list(
        search: any(named: 'search'),
        issuer: any(named: 'issuer'),
        type: any(named: 'type'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const FiscalDocumentPage(items: [], total: 0));
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

  Override access({bool create = true}) =>
      accessControlProvider.overrideWithValue(
        AccessControlService(
          AuthState.authenticated(
            token: 't',
            user: User(
              userId: 'd',
              email: 'd@example.com',
              administrator: false,
              status: EntityStatus.active,
              sessionVersion: 1,
              privileges: [
                Privilege(
                  systemObject: SystemObject.fiscalDocuments,
                  rawValue: create ? 3 : 2,
                ),
                const Privilege(
                  systemObject: SystemObject.customers,
                  rawValue: 2,
                ),
              ],
            ),
          ),
        ),
      );

  Future<GoRouter> pumpList(WidgetTester tester, {bool create = true}) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        access(create: create),
        fiscalDocumentRepositoryProvider.overrideWithValue(documents),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/invoicing/fiscal-documents',
      routes: [
        GoRoute(
          path: '/invoicing/fiscal-documents',
          builder: (context, state) => Scaffold(
            body: FiscalDocumentsListScreen(
              query: ListQuery.fromUri(state.uri),
            ),
          ),
        ),
        GoRoute(
          path: '/invoicing/fiscal-documents/:id',
          builder: (_, s) =>
              Scaffold(body: Text('document-${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  Future<void> open(WidgetTester tester) async {
    await tester.tap(key('fiscal_documents_new_button'));
    await tester.pumpAndSettle();
  }

  Future<void> pickCustomer(WidgetTester tester) async {
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
  }

  void customerHas(List<TaxpayerRecipient> t) => when(
    () => customers.get(customerId: 4),
  ).thenAnswer((_) async => _customer(t));

  testWidgets('the Nueva factura button needs FiscalDocuments create', (
    tester,
  ) async {
    await pumpList(tester, create: false);
    expect(key('fiscal_documents_new_button'), findsNothing);
  });

  testWidgets('the button is there with create', (tester) async {
    await pumpList(tester);
    expect(key('fiscal_documents_new_button'), findsOneWidget);
    expect(find.text(l10n.fiscalDocumentNewAction), findsOneWidget);
  });

  testWidgets('Crear stays disabled until a customer and RFC are chosen', (
    tester,
  ) async {
    customerHas([_acme, _acmeNorte]);
    await pumpList(tester);
    await open(tester);

    expect(key('new_invoice_recipient'), findsNothing);
    expect(
      tester.widget<FilledButton>(key('new_invoice_submit')).onPressed,
      isNull,
    );

    await pickCustomer(tester);
    expect(key('new_invoice_recipient'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(key('new_invoice_submit')).onPressed,
      isNull,
    );
  });

  testWidgets('the RFC dropdown fills after a customer is picked; Crear '
      'creates and opens the new document', (tester) async {
    customerHas([_acme, _acmeNorte]);
    when(
      () => documents.create(any()),
    ).thenAnswer((_) async => aDocument(id: 21));
    final router = await pumpList(tester);
    await open(tester);
    await pickCustomer(tester);

    await tester.tap(key('new_invoice_recipient'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('BBB010101BBB').last);
    await tester.pumpAndSettle();
    await tester.tap(key('new_invoice_submit'));
    await tester.pumpAndSettle();

    final sent =
        verify(() => documents.create(captureAny())).captured.single
            as NewInvoice;
    expect(sent.customerId, 4);
    expect(sent.recipientRfc, 'BBB010101BBB');
    expect(router.state.uri.path, '/invoicing/fiscal-documents/21');
    expect(find.text('document-21'), findsOneWidget);
  });

  testWidgets('a customer with one RFC needs no choice', (tester) async {
    customerHas([_acme]);
    when(
      () => documents.create(any()),
    ).thenAnswer((_) async => aDocument(id: 22));
    await pumpList(tester);
    await open(tester);
    await pickCustomer(tester);
    await tester.pumpAndSettle();

    await tester.tap(key('new_invoice_submit'));
    await tester.pumpAndSettle();

    final sent =
        verify(() => documents.create(captureAny())).captured.single
            as NewInvoice;
    expect(sent.recipientRfc, 'AAA010101AAA');
  });

  testWidgets('a customer with no taxpayers shows the message and Crear is '
      'disabled', (tester) async {
    customerHas(const []);
    await pumpList(tester);
    await open(tester);
    await pickCustomer(tester);

    expect(key('new_invoice_no_taxpayers'), findsOneWidget);
    expect(find.text(l10n.fiscalDocumentNewNoTaxpayers), findsOneWidget);
    expect(
      tester.widget<FilledButton>(key('new_invoice_submit')).onPressed,
      isNull,
    );
  });

  for (final (code, enumCode, text) in [
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
  ]) {
    testWidgets('$code stays inline and the dialog stays open', (tester) async {
      customerHas([_acme]);
      when(() => documents.create(any())).thenThrow(
        AppError.server(
          statusCode: 422,
          problem: ApiProblem(
            codeName: code,
            code: enumCode,
            params: const {'type': 0, 'customer_id': 4, 'recipient': 'X'},
          ),
        ),
      );
      await pumpList(tester);
      await open(tester);
      await pickCustomer(tester);
      await tester.pumpAndSettle();

      await tester.tap(key('new_invoice_submit'));
      await tester.pumpAndSettle();

      expect(key('new_invoice_dialog'), findsOneWidget);
      expect(find.text(text()), findsOneWidget);
    });
  }

  testWidgets('user.no_facility stays inline', (tester) async {
    customerHas([_acme]);
    when(() => documents.create(any())).thenThrow(
      const AppError.server(
        statusCode: 422,
        problem: ApiProblem(
          codeName: 'user.no_facility',
          code: api.ErrorCode.userPeriodNoFacility,
        ),
      ),
    );
    await pumpList(tester);
    await open(tester);
    await pickCustomer(tester);
    await tester.pumpAndSettle();

    await tester.tap(key('new_invoice_submit'));
    await tester.pumpAndSettle();

    expect(key('new_invoice_dialog'), findsOneWidget);
    expect(key('fiscal_document_refusal'), findsOneWidget);
  });

  testWidgets('a lost connection says the result is unknown', (tester) async {
    customerHas([_acme]);
    when(() => documents.create(any())).thenThrow(const AppError.network());
    await pumpList(tester);
    await open(tester);
    await pickCustomer(tester);
    await tester.pumpAndSettle();

    await tester.tap(key('new_invoice_submit'));
    await tester.pumpAndSettle();

    expect(key('fiscal_document_action_unknown'), findsOneWidget);
    expect(find.text(l10n.fiscalDocumentUnknownResult), findsOneWidget);
  });

  testWidgets('Cancelar closes without creating', (tester) async {
    await pumpList(tester);
    await open(tester);
    await tester.tap(find.text(l10n.cancelButton));
    await tester.pumpAndSettle();

    expect(key('new_invoice_dialog'), findsNothing);
    verifyNever(() => documents.create(any()));
  });

  group('"Nuevo complemento de pago" on the list (spec 074 C36, FR-002)', () {
    setUpAll(() {
      registerFallbackValue(
        const NewPaymentReceipt(customerId: 1, recipientRfc: 'X'),
      );
    });

    testWidgets('is offered with create, beside Nueva factura', (tester) async {
      await pumpList(tester);

      expect(key('fiscal_documents_new_receipt'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentNewReceiptAction), findsOneWidget);
      expect(key('fiscal_documents_new_button'), findsOneWidget);
    });

    testWidgets('is absent without create, like Nueva factura', (tester) async {
      await pumpList(tester, create: false);

      expect(key('fiscal_documents_new_receipt'), findsNothing);
      expect(key('fiscal_documents_new_button'), findsNothing);
    });

    testWidgets('Nueva factura still creates an invoice', (tester) async {
      customerHas([_acme]);
      when(
        () => documents.create(any()),
      ).thenAnswer((_) async => aDocument(id: 30));
      await pumpList(tester);
      await open(tester);
      await pickCustomer(tester);
      await tester.pumpAndSettle();
      await tester.tap(key('new_invoice_submit'));
      await tester.pumpAndSettle();

      verify(() => documents.create(any())).called(1);
      verifyNever(() => documents.createPaymentReceipt(any()));
    });

    testWidgets('opens the dialog in receipt mode, and a created receipt '
        'opens its screen', (tester) async {
      customerHas([_acme]);
      when(() => documents.createPaymentReceipt(any())).thenAnswer(
        (_) async => aPaymentReceipt(id: 31, customerPaymentId: null),
      );
      final router = await pumpList(tester);

      await tester.tap(key('fiscal_documents_new_receipt'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(key('responsive_dialog_title')).data,
        l10n.fiscalDocumentNewReceiptTitle,
      );
      await pickCustomer(tester);
      await tester.pumpAndSettle();
      await tester.tap(key('new_invoice_submit'));
      await tester.pumpAndSettle();

      final sent =
          verify(
                () => documents.createPaymentReceipt(captureAny()),
              ).captured.single
              as NewPaymentReceipt;
      expect(sent.customerId, 4);
      expect(sent.recipientRfc, 'AAA010101AAA');
      expect(sent.customerPaymentId, isNull);
      verifyNever(() => documents.create(any()));
      expect(router.state.uri.path, '/invoicing/fiscal-documents/31');
    });
  });
}
