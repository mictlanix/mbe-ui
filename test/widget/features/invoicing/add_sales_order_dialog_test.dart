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
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_screen.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';

class _MockDocuments extends Mock implements FiscalDocumentRepository {}

class _MockOrders extends Mock implements SalesOrderRepository {}

/// Spec 066 US3, contract C10: "Agregar pedido", opened from a draft's
/// detail screen.
void main() {
  late _MockDocuments documents;
  late _MockOrders orders;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    documents = _MockDocuments();
    orders = _MockOrders();
  });

  OpenSale order(int id, {int? serial}) => OpenSale(
    id: id,
    serial: serial ?? 8800 + id,
    total: '1160',
    balance: '0',
    status: SaleStatus.completed,
    date: DateTime(2026, 11, 10),
  );

  void serve(List<OpenSale> all, {int? total}) {
    when(
      () => orders.listOrders(
        customer: any(named: 'customer'),
        status: any(named: 'status'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) async {
      final skip = i.namedArguments[#skip] as int;
      final limit = i.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, all.length);
      return OpenSalePage(
        items: skip >= all.length ? const [] : all.sublist(skip, end),
        total: total ?? all.length,
      );
    });
  }

  Override access({bool update = true, bool ordersRead = true}) =>
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
                  rawValue: update ? 6 : 2,
                ),
                if (ordersRead)
                  const Privilege(
                    systemObject: SystemObject.salesOrders,
                    rawValue: 2,
                  ),
              ],
            ),
          ),
        ),
      );

  Future<void> pumpDetail(
    WidgetTester tester, {
    FiscalDocument? document,
    Override? who,
  }) async {
    when(
      () => documents.getById(any()),
    ).thenAnswer((_) async => document ?? aDocument());
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        who ?? access(),
        fiscalDocumentRepositoryProvider.overrideWithValue(documents),
        salesOrderRepositoryProvider.overrideWithValue(orders),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        customerDisplayNameProvider.overrideWith(
          (ref, id) async => 'Cliente $id',
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => 'Sucursal $id',
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/invoicing/fiscal-documents/7',
      routes: [
        GoRoute(
          path: '/invoicing/fiscal-documents/:id',
          builder: (_, s) =>
              const FiscalDocumentDetailScreen(fiscalDocumentId: 7),
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
  }

  Finder key(String k) => find.byKey(Key(k));

  Future<void> open(WidgetTester tester) async {
    await tester.tap(key('fiscal_document_add_order'));
    await tester.pumpAndSettle();
  }

  group('the button', () {
    testWidgets('shows on a draft with update and SalesOrders read', (
      tester,
    ) async {
      await pumpDetail(tester);
      expect(key('fiscal_document_add_order'), findsOneWidget);
    });

    testWidgets('is absent without FiscalDocuments update', (tester) async {
      await pumpDetail(tester, who: access(update: false));
      expect(key('fiscal_document_add_order'), findsNothing);
    });

    testWidgets('is absent without SalesOrders read', (tester) async {
      await pumpDetail(tester, who: access(ordersRead: false));
      expect(key('fiscal_document_add_order'), findsNothing);
    });

    testWidgets('is absent on a draft with no customer', (tester) async {
      await pumpDetail(tester, document: aDocument(customerId: null));
      expect(key('fiscal_document_add_order'), findsNothing);
    });

    testWidgets('is absent on a sealed invoice', (tester) async {
      await pumpDetail(
        tester,
        document: aDocument(status: FiscalDocumentStatus.sealed, serial: 1),
      );
      expect(key('fiscal_document_add_order'), findsNothing);
    });
  });

  group('the dialog', () {
    testWidgets('lists the customer\'s completed orders, asking the server '
        'for them', (tester) async {
      serve([order(1), order(2)]);
      await pumpDetail(tester);
      await open(tester);

      expect(key('add_sales_order_row_1'), findsOneWidget);
      expect(key('add_sales_order_row_2'), findsOneWidget);
      expect(find.text('8801'), findsOneWidget);
      expect(find.text('2026-11-10'), findsNWidgets(2));
      expect(find.text(r'$1,160.00'), findsNWidgets(2));
      verify(
        () => orders.listOrders(
          customer: 4,
          status: SaleStatus.completed,
          search: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('pages with Ver más', (tester) async {
      serve([for (var i = 1; i <= 25; i++) order(i)]);
      await pumpDetail(tester);
      await open(tester);

      expect(key('add_sales_order_row_20'), findsOneWidget);
      expect(key('add_sales_order_row_21'), findsNothing);
      await tester.ensureVisible(key('add_sales_order_load_more'));
      await tester.tap(key('add_sales_order_load_more'));
      await tester.pumpAndSettle();

      expect(key('add_sales_order_row_25'), findsOneWidget);
      expect(key('add_sales_order_load_more'), findsNothing);
    });

    testWidgets('search filters after the typing pause', (tester) async {
      serve([order(1)]);
      await pumpDetail(tester);
      await open(tester);

      await tester.enterText(key('add_sales_order_search'), '8801');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      verify(
        () => orders.listOrders(
          customer: 4,
          status: SaleStatus.completed,
          search: '8801',
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('an empty list says so', (tester) async {
      serve(const []);
      await pumpDetail(tester);
      await open(tester);

      expect(key('add_sales_order_empty'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentAddOrderEmpty), findsOneWidget);
    });

    testWidgets('picking an order adds it, closes, and says so', (
      tester,
    ) async {
      serve([order(1), order(2)]);
      when(
        () => documents.addSalesOrder(7, 2),
      ).thenAnswer((_) async => aDocument());
      await pumpDetail(tester);
      await open(tester);

      await tester.tap(key('add_sales_order_row_2'));
      await tester.pumpAndSettle();

      verify(() => documents.addSalesOrder(7, 2)).called(1);
      expect(key('add_sales_order_dialog'), findsNothing);
      expect(find.text(l10n.fiscalDocumentOrderAdded('8802')), findsOneWidget);
      // The detail reloaded.
      verify(() => documents.getById(7)).called(greaterThan(1));
    });

    for (final (code, enumCode, text) in [
      (
        'fiscal_document.no_invoiceable_lines',
        api.ErrorCode.fiscalDocumentPeriodNoInvoiceableLines,
        () => l10n.apiErrorFiscalDocumentNoInvoiceableLines,
      ),
      (
        'fiscal_document.order_not_invoiceable',
        api.ErrorCode.fiscalDocumentPeriodOrderNotInvoiceable,
        () => l10n.apiErrorFiscalDocumentOrderNotInvoiceable,
      ),
    ]) {
      testWidgets('$code stays inline, and another order can be picked', (
        tester,
      ) async {
        serve([order(1), order(2)]);
        when(() => documents.addSalesOrder(7, 1)).thenThrow(
          AppError.server(
            statusCode: 422,
            problem: ApiProblem(
              codeName: code,
              code: enumCode,
              params: const {'sales_order_id': 1},
            ),
          ),
        );
        when(
          () => documents.addSalesOrder(7, 2),
        ).thenAnswer((_) async => aDocument());
        await pumpDetail(tester);
        await open(tester);

        await tester.tap(key('add_sales_order_row_1'));
        await tester.pumpAndSettle();

        expect(key('add_sales_order_dialog'), findsOneWidget);
        expect(find.text(text()), findsOneWidget);

        await tester.tap(key('add_sales_order_row_2'));
        await tester.pumpAndSettle();
        expect(key('add_sales_order_dialog'), findsNothing);
      });
    }

    testWidgets('Cancelar closes without adding', (tester) async {
      serve([order(1)]);
      await pumpDetail(tester);
      await open(tester);

      await tester.tap(key('add_sales_order_close'));
      await tester.pumpAndSettle();

      expect(key('add_sales_order_dialog'), findsNothing);
      verifyNever(() => documents.addSalesOrder(any(), any()));
    });
  });
}
