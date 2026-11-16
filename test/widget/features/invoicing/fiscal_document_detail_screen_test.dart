import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
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
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/files/file_saver.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';
import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';

class _MockRepository extends Mock implements FiscalDocumentRepository {}

class _FakeSaver implements FileSaver {
  final List<({Uint8List bytes, String filename})> calls = [];
  bool result = true;

  @override
  Future<bool> save({
    required Uint8List bytes,
    required String filename,
  }) async {
    calls.add((bytes: bytes, filename: filename));
    return result;
  }
}

/// Spec 066 US2, contracts C5 and C14: the document detail, read-only. The
/// edit controls of US3–US6 are covered by their own tests.
void main() {
  late _MockRepository repository;
  late _FakeSaver saver;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    repository = _MockRepository();
    saver = _FakeSaver();
  });

  FiscalDocument issued({int typeCode = 0, FiscalDocumentStatus? status}) =>
      aDocument(
        status: status ?? FiscalDocumentStatus.issued,
        typeCode: typeCode,
        serial: 4776,
        series: 'GR',
        total: Decimal.parse('999.99'),
      );

  Override access({bool read = true, bool update = false}) =>
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
                if (read)
                  Privilege(
                    systemObject: SystemObject.fiscalDocuments,
                    rawValue: update ? 6 : 2,
                  ),
              ],
            ),
          ),
        ),
      );

  Future<void> pumpDetail(
    WidgetTester tester, {
    FiscalDocument? document,
    Object? loadError,
    String location = '/invoicing/fiscal-documents/7',
    Override? who,
    FakeDocumentSource? documents,
    Size surface = const Size(1400, 1000),
  }) async {
    if (loadError != null) {
      when(() => repository.getById(any())).thenThrow(loadError);
    } else {
      when(() => repository.getById(any())).thenAnswer((_) async => document!);
    }
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
        fileSaverProvider.overrideWithValue(saver),
        documentSourceProvider.overrideWithValue(
          documents ?? FakeDocumentSource(),
        ),
        documentOutputProvider.overrideWithValue(FakeDocumentOutput()),
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
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/invoicing/fiscal-documents',
          builder: (_, _) => const Scaffold(body: Text('list')),
        ),
        GoRoute(
          path: '/invoicing/fiscal-documents/:id',
          builder: (_, s) => FiscalDocumentDetailScreen(
            fiscalDocumentId: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
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

  group('an issued invoice', () {
    testWidgets('shows the header, lines and the server total, with both '
        'document buttons', (tester) async {
      await pumpDetail(tester, document: issued());

      expect(find.text(l10n.fiscalDocumentTitle('GR4776')), findsOneWidget);
      expect(key('fiscal_document_folio'), findsOneWidget);
      expect(find.text('GR4776'), findsWidgets);
      expect(key('fiscal_document_status_chip_issued'), findsOneWidget);
      expect(find.text('XAXX010101000 · Emisor SA'), findsOneWidget);
      expect(find.text('XEXX010101000 · Receptor SA'), findsOneWidget);
      expect(find.text('Cliente 4'), findsOneWidget);
      expect(find.text('Sucursal 2'), findsOneWidget);
      expect(find.text('Tornillo'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentLineFromOrder), findsOneWidget);
      // Total is the server's, not the estimate (2 x 100 + 16 % = 232).
      expect(find.text(l10n.fiscalDocumentTotalTotal), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentTotalEstimated), findsNothing);
      expect(
        find.descendant(
          of: key('invoice_total_total'),
          matching: find.text(r'$999.99'),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_view_pdf'), findsOneWidget);
      expect(key('fiscal_document_download_xml'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Ver PDF previews the document with the right ref', (
      tester,
    ) async {
      final documents = FakeDocumentSource();
      await pumpDetail(tester, document: issued(), documents: documents);

      await tester.tap(key('fiscal_document_view_pdf'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(documents.fetched.single.kind, DocumentKind.fiscalDocument);
      expect(documents.fetched.single.recordId, 7);
      expect(
        tester.widget<Text>(key('document_preview_title')).data,
        'Factura GR4776',
      );
    });

    testWidgets('a PDF refusal (version_not_printable) reads in Spanish in '
        'the preview', (tester) async {
      final documents = FakeDocumentSource(
        handler: (_) async => throw const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'fiscal_document.version_not_printable',
            code: api.ErrorCode.fiscalDocumentPeriodVersionNotPrintable,
            params: {'version': '3.3'},
          ),
        ),
      );
      await pumpDetail(tester, document: issued(), documents: documents);

      await tester.tap(key('fiscal_document_view_pdf'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.apiErrorFiscalDocumentVersionNotPrintable('3.3')),
        findsOneWidget,
      );
    });

    testWidgets('Descargar XML saves the bytes under the server\'s name and '
        'says so', (tester) async {
      when(() => repository.downloadXml(7)).thenAnswer(
        (_) async => XmlDownload(
          bytes: Uint8List.fromList(utf8.encode('<xml/>')),
          filename: 'XAXX010101000-GR004776.xml',
        ),
      );
      await pumpDetail(tester, document: issued());

      await tester.tap(key('fiscal_document_download_xml'));
      await tester.pumpAndSettle();

      expect(saver.calls.single.filename, 'XAXX010101000-GR004776.xml');
      expect(utf8.decode(saver.calls.single.bytes), '<xml/>');
      expect(find.text(l10n.fiscalDocumentXmlSaved), findsOneWidget);
    });

    testWidgets('without a server name the file is named from the issuer, '
        'series and serial', (tester) async {
      when(
        () => repository.downloadXml(7),
      ).thenAnswer((_) async => XmlDownload(bytes: Uint8List.fromList([1])));
      await pumpDetail(tester, document: issued());

      await tester.tap(key('fiscal_document_download_xml'));
      await tester.pumpAndSettle();

      expect(saver.calls.single.filename, 'XAXX010101000-GR004776.xml');
    });

    testWidgets('a cancelled save dialog says nothing', (tester) async {
      saver.result = false;
      when(
        () => repository.downloadXml(7),
      ).thenAnswer((_) async => XmlDownload(bytes: Uint8List.fromList([1])));
      await pumpDetail(tester, document: issued());

      await tester.tap(key('fiscal_document_download_xml'));
      await tester.pumpAndSettle();

      expect(saver.calls, hasLength(1));
      expect(find.text(l10n.fiscalDocumentXmlSaved), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('an XML refusal shows its localized message', (tester) async {
      when(() => repository.downloadXml(7)).thenThrow(
        const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'fiscal_document.xml_unavailable',
            code: api.ErrorCode.fiscalDocumentPeriodXmlUnavailable,
          ),
        ),
      );
      await pumpDetail(tester, document: issued());

      await tester.tap(key('fiscal_document_download_xml'));
      await tester.pumpAndSettle();

      expect(saver.calls, isEmpty);
      expect(
        find.text(l10n.apiErrorFiscalDocumentXmlUnavailable),
        findsOneWidget,
      );
    });
  });

  group('other states', () {
    testWidgets('a draft shows the estimated total, the draft title and no '
        'document buttons', (tester) async {
      await pumpDetail(tester, document: aDocument());

      expect(find.text(l10n.fiscalDocumentTitleDraft(7)), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentTotalEstimated), findsOneWidget);
      expect(
        find.descendant(
          of: key('invoice_total_total'),
          matching: find.text(r'$232.00'),
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.fiscalDocumentFactIssuedOnConfirm), findsOneWidget);
      expect(key('fiscal_document_view_pdf'), findsNothing);
      expect(key('fiscal_document_download_xml'), findsNothing);
    });

    testWidgets('a sealed invoice shows the sealed banner and no document '
        'buttons', (tester) async {
      await pumpDetail(
        tester,
        document: aDocument(
          status: FiscalDocumentStatus.sealed,
          serial: 12,
          total: Decimal.parse('232'),
        ),
      );

      expect(key('fiscal_document_banner_sealed'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentBannerSealed), findsOneWidget);
      expect(key('fiscal_document_view_pdf'), findsNothing);
      expect(key('fiscal_document_download_xml'), findsNothing);
    });

    testWidgets('a credit note shows the read-only banner and no edit '
        'controls', (tester) async {
      await pumpDetail(
        tester,
        document: aDocument(typeCode: 100, status: FiscalDocumentStatus.draft),
        who: access(update: true),
      );

      expect(key('fiscal_document_banner_read_only_kind'), findsOneWidget);
      expect(key('fiscal_document_actions'), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(
        find.text('${l10n.fiscalDocumentKindCreditNote} #7'),
        findsOneWidget,
      );
    });

    testWidgets('a cancelled document shows its date and still offers the '
        'files', (tester) async {
      final base = issued(status: FiscalDocumentStatus.cancelled);
      await pumpDetail(
        tester,
        document: base.copyWith(cancellationDate: DateTime(2026, 11, 14)),
      );

      expect(key('fiscal_document_banner_cancelled'), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentBannerCancelled('2026-11-14')),
        findsOneWidget,
      );
      expect(key('fiscal_document_view_pdf'), findsOneWidget);
      expect(key('fiscal_document_download_xml'), findsOneWidget);
    });

    testWidgets('a legacy draft with no customer says so', (tester) async {
      await pumpDetail(tester, document: aDocument(customerId: null));

      expect(key('fiscal_document_no_customer'), findsOneWidget);
      expect(key('fiscal_document_customer'), findsNothing);
    });

    testWidgets('related documents show with their type and folio', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        document: aDocument(
          relations: const [
            InvoiceRelation(
              id: 3,
              documentId: 99,
              type: InvoiceRelationType.advanceApplication,
              series: 'A',
              serial: 5,
              stampUuid: 'UUID-1',
            ),
          ],
        ),
      );

      expect(key('fiscal_document_relations'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentRelationAdvance), findsOneWidget);
      expect(find.text('A5'), findsOneWidget);
      expect(find.text('UUID-1'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('a missing id shows not found', (tester) async {
      await pumpDetail(
        tester,
        document: aDocument(),
        location: '/invoicing/fiscal-documents/abc',
      );
      expect(key('fiscal_document_not_found'), findsOneWidget);
    });

    testWidgets('a not-found document shows not found and goes back', (
      tester,
    ) async {
      await pumpDetail(tester, loadError: const AppError.notFound());
      expect(key('fiscal_document_not_found'), findsOneWidget);

      await tester.tap(key('fiscal_document_back_to_list'));
      await tester.pumpAndSettle();
      expect(find.text('list'), findsOneWidget);
    });

    testWidgets('a load failure offers retry', (tester) async {
      await pumpDetail(tester, loadError: const AppError.network());
      expect(key('fiscal_document_load_failed'), findsOneWidget);
      expect(key('fiscal_document_retry_button'), findsOneWidget);
    });

    testWidgets('a user without FiscalDocuments read gets no document '
        'buttons', (tester) async {
      await pumpDetail(tester, document: issued(), who: access(read: false));
      expect(key('fiscal_document_view_pdf'), findsNothing);
      expect(key('fiscal_document_download_xml'), findsNothing);
    });

    testWidgets('the compact tier renders lines as cards', (tester) async {
      await pumpDetail(
        tester,
        document: issued(),
        surface: const Size(400, 900),
      );

      expect(key('fiscal_document_line_card_10'), findsOneWidget);
      expect(key('fiscal_document_lines_table'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
