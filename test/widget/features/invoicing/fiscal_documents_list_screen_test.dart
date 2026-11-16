import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockRepository extends Mock implements FiscalDocumentRepository {}

typedef _Request = ({
  String? search,
  String? issuer,
  int? type,
  FiscalDocumentStatus? status,
  DateTime? dateFrom,
  DateTime? dateTo,
  int skip,
});

/// Spec 066 US1, contracts C2 and C3: the "Facturas" list. The route gate is
/// covered in `app_router_test.dart`.
void main() {
  late _MockRepository repository;
  late AppLocalizations l10n;
  var requests = <_Request>[];

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    repository = _MockRepository();
    requests = [];
  });

  FiscalDocumentSummary row(
    int id, {
    int? serial,
    String? series = 'GR',
    int type = 0,
    FiscalDocumentStatus status = FiscalDocumentStatus.issued,
    String? total = '232.00',
    DateTime? issued,
  }) => FiscalDocumentSummary(
    id: id,
    typeCode: type,
    version: '4.0',
    series: series,
    serial: serial,
    issuerRfc: 'XAXX010101000',
    issuerName: 'Emisor SA',
    recipientRfc: 'XEXX010101000',
    recipientName: 'Receptor SA',
    issued: issued ?? DateTime(2026, 11, 15, 10, 30),
    status: status,
    total: total == null ? null : Decimal.parse(total),
  );

  void stubList(Future<FiscalDocumentPage> Function(_Request) answer) {
    when(
      () => repository.list(
        search: any(named: 'search'),
        issuer: any(named: 'issuer'),
        type: any(named: 'type'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) {
      final request = (
        search: i.namedArguments[#search] as String?,
        issuer: i.namedArguments[#issuer] as String?,
        type: i.namedArguments[#type] as int?,
        status: i.namedArguments[#status] as FiscalDocumentStatus?,
        dateFrom: i.namedArguments[#dateFrom] as DateTime?,
        dateTo: i.namedArguments[#dateTo] as DateTime?,
        skip: i.namedArguments[#skip] as int,
      );
      requests.add(request);
      return answer(request);
    });
  }

  void serve(List<FiscalDocumentSummary> all) => stubList((_) async {
    return FiscalDocumentPage(items: all, total: all.length);
  });

  Override access({bool taxpayersRead = true}) =>
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
                const Privilege(
                  systemObject: SystemObject.fiscalDocuments,
                  rawValue: 2,
                ),
                if (taxpayersRead)
                  const Privilege(
                    systemObject: SystemObject.taxpayers,
                    rawValue: 2,
                  ),
              ],
            ),
          ),
        ),
      );

  Future<GoRouter> pumpList(
    WidgetTester tester, {
    Override? who,
    String location = '/invoicing/fiscal-documents',
    Size surface = const Size(1400, 1000),
    bool settle = true,
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        who ?? access(),
        fiscalDocumentRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
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
    if (settle) await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(
      of: key('fiscal_documents_filter_button'),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('fiscal_documents_filter_button'));
    await tester.pumpAndSettle();
  }

  group('table', () {
    testWidgets('opens with every type, the badge at 0, and a row per '
        'document: folio, type, issuer, recipient, date, chip, total', (
      tester,
    ) async {
      serve([
        row(2, serial: 4776),
        row(
          1,
          status: FiscalDocumentStatus.draft,
          series: 'A',
          total: null,
          type: 100,
        ),
      ]);
      await pumpList(tester);

      expect(requests.single.type, isNull);
      expect(requests.single.status, isNull);
      expect(badge(tester).isLabelVisible, isFalse);
      for (final header in [
        l10n.fiscalDocumentColFolio,
        l10n.fiscalDocumentColType,
        l10n.fiscalDocumentColIssuer,
        l10n.fiscalDocumentColRecipient,
        l10n.fiscalDocumentColIssued,
        l10n.fiscalDocumentColStatus,
        l10n.fiscalDocumentColTotal,
      ]) {
        expect(find.text(header), findsWidgets, reason: header);
      }
      expect(find.text('GR4776'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentKindInvoice), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentKindCreditNote), findsOneWidget);
      expect(find.text('XAXX010101000'), findsNWidgets(2));
      expect(find.text('Receptor SA'), findsNWidgets(2));
      expect(find.text('2026-11-15'), findsNWidgets(2));
      expect(key('fiscal_document_status_chip_issued'), findsOneWidget);
      expect(find.text(r'$232.00'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a draft reads "Borrador #id" and shows the placeholder '
        'total', (tester) async {
      serve([row(9, status: FiscalDocumentStatus.draft, total: null)]);
      await pumpList(tester);

      expect(find.text(l10n.fiscalDocumentTitleDraft(9)), findsOneWidget);
      expect(key('fiscal_document_status_chip_draft'), findsOneWidget);
      expect(find.text(r'$0.00'), findsNothing);
    });

    testWidgets('a row tap opens the document', (tester) async {
      serve([row(5, serial: 1517)]);
      final router = await pumpList(tester);

      await tester.tap(find.text('GR1517'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/invoicing/fiscal-documents/5');
      expect(find.text('document-5'), findsOneWidget);
    });

    testWidgets('the compact tier stacks the rows: type, issuer and date '
        'columns are dropped', (tester) async {
      serve([row(2, serial: 4776)]);
      await pumpList(tester, surface: const Size(400, 900));

      expect(find.text(l10n.fiscalDocumentColType), findsNothing);
      expect(find.text(l10n.fiscalDocumentColIssuer), findsNothing);
      expect(find.text(l10n.fiscalDocumentColIssued), findsNothing);
      expect(find.text('GR4776'), findsOneWidget);
      expect(find.text('Receptor SA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('search', () {
    testWidgets('submitting sends the text as search and writes the '
        'address', (tester) async {
      serve([row(1, serial: 4776)]);
      final router = await pumpList(tester);

      await tester.enterText(
        find.descendant(
          of: key('fiscal_documents_search'),
          matching: find.byType(TextField),
        ),
        'GR4776',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['search'], 'GR4776');
      expect(requests.last.search, 'GR4776');
    });
  });

  group('facets', () {
    testWidgets('status reaches the controller and resets the page', (
      tester,
    ) async {
      serve([row(1)]);
      final router = await pumpList(
        tester,
        location: '/invoicing/fiscal-documents?page=3',
      );
      await openFilters(tester);

      await tester.tap(key('fiscal_documents_status_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.fiscalDocumentStatusSealed).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'sealed');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(requests.last.status, FiscalDocumentStatus.sealed);
    });

    testWidgets('type reaches the controller', (tester) async {
      serve([row(1)]);
      final router = await pumpList(tester);
      await openFilters(tester);

      await tester.tap(key('fiscal_documents_type_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.fiscalDocumentKindCreditNote).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['type'], '100');
      expect(requests.last.type, 100);
    });

    testWidgets('an unknown type code in the address still applies and '
        'reads "Tipo desconocido"', (tester) async {
      serve([row(1)]);
      await pumpList(tester, location: '/invoicing/fiscal-documents?type=7');
      expect(requests.last.type, 7);

      await openFilters(tester);
      expect(find.text(l10n.fiscalDocumentKindUnknown(7)), findsOneWidget);
    });

    testWidgets('issuer and date range in the address reach the controller '
        'and count on the badge (the range once)', (tester) async {
      serve([row(1)]);
      await pumpList(
        tester,
        location:
            '/invoicing/fiscal-documents?issuer=XAXX010101000'
            '&from=2026-11-01&to=2026-11-30',
      );

      expect(requests.last.issuer, 'XAXX010101000');
      expect(requests.last.dateFrom, DateTime(2026, 11));
      expect(requests.last.dateTo, DateTime(2026, 11, 30));
      expect(badge(tester).isLabelVisible, isTrue);
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsOneWidget,
      );
    });

    testWidgets('the date facet says drafts have no issue date', (
      tester,
    ) async {
      serve([row(1)]);
      await pumpList(tester);
      await openFilters(tester);

      expect(key('fiscal_documents_date_helper'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentDateFacetHelper), findsOneWidget);
    });

    testWidgets('the issuer facet needs Taxpayers read', (tester) async {
      serve([row(1)]);
      await pumpList(tester, who: access(taxpayersRead: false));
      await openFilters(tester);
      expect(key('fiscal_documents_issuer_filter'), findsNothing);
      expect(key('fiscal_documents_status_filter'), findsOneWidget);
    });

    testWidgets('the issuer facet shows with Taxpayers read', (tester) async {
      serve([row(1)]);
      await pumpList(tester);
      await openFilters(tester);
      expect(key('fiscal_documents_issuer_filter'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('loading shows a spinner', (tester) async {
      final pending = Completer<FiscalDocumentPage>();
      stubList((_) => pending.future);
      await pumpList(tester, settle: false);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete(const FiscalDocumentPage(items: [], total: 0));
      await tester.pumpAndSettle();
    });

    testWidgets('an error offers retry', (tester) async {
      var fail = true;
      stubList((_) async {
        if (fail) throw const AppError.network();
        return FiscalDocumentPage(items: [row(1, serial: 7)], total: 1);
      });
      await pumpList(tester);

      expect(find.text(l10n.retryButton), findsOneWidget);
      fail = false;
      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();
      expect(find.text('GR7'), findsOneWidget);
    });

    testWidgets('empty with no filters has no "Quitar filtros"', (
      tester,
    ) async {
      serve(const []);
      await pumpList(tester);

      expect(find.text(l10n.fiscalDocumentsEmpty), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });

    testWidgets('empty when narrowed offers "Quitar filtros"', (tester) async {
      stubList((_) async => const FiscalDocumentPage(items: [], total: 0));
      final router = await pumpList(
        tester,
        location: '/invoicing/fiscal-documents?status=cancelled',
      );

      expect(find.text(l10n.filteredEmptyTitle), findsOneWidget);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
    });
  });
}
