import 'dart:async';
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
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_cancellation.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';
import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart' show InvoiceHarness;

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
    List<Override> extraOverrides = const [],
    Locale locale = const Locale('es', 'MX'),
    TextScaler? textScaler,
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
        ...extraOverrides,
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
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: textScaler == null
              ? null
              : (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
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

  group('stamping and cancellation pending (spec 072 US1)', () {
    // Every control a draft offers. None may appear on these two states.
    const editControls = [
      'fiscal_document_edit_header',
      'fiscal_document_add_order',
      'fiscal_document_add_product',
      'fiscal_document_add_relation',
      'fiscal_document_confirm',
      'fiscal_document_reopen',
    ];

    FiscalDocument stamping() => aDocument(
      status: FiscalDocumentStatus.stamping,
      serial: 12,
      total: Decimal.parse('232'),
      stampingSince: DateTime(2026, 11, 17, 11, 5),
    );

    FiscalDocument pending() => aDocument(
      status: FiscalDocumentStatus.cancellationPending,
      serial: 12,
      total: Decimal.parse('232'),
      stamp: aStamp(),
      cancellations: [aCancellation(outcome: CancellationOutcome.pending)],
    );

    testWidgets('a stamping document shows its label and banner, offers no '
        'edit action and no files (SC-003)', (tester) async {
      await pumpDetail(tester, document: stamping(), who: access(update: true));

      expect(find.text(l10n.fiscalDocumentStatusStamping), findsWidgets);
      expect(key('fiscal_document_banner_stamping'), findsOneWidget);
      expect(find.textContaining('Timbrando desde'), findsOneWidget);
      expect(find.textContaining('consultarlo ahora'), findsOneWidget);
      for (final k in editControls) {
        expect(key(k), findsNothing, reason: k);
      }
      expect(key('fiscal_document_view_pdf'), findsNothing);
      expect(key('fiscal_document_download_xml'), findsNothing);
    });

    testWidgets('a read-only user is not told they can check it now', (
      tester,
    ) async {
      await pumpDetail(tester, document: stamping());

      expect(key('fiscal_document_banner_stamping'), findsOneWidget);
      expect(find.textContaining('Timbrando desde'), findsOneWidget);
      expect(find.textContaining('consultarlo ahora'), findsNothing);
    });

    testWidgets('a cancellation-pending document shows when it was requested, '
        'offers no edit action and still offers the files', (tester) async {
      await pumpDetail(tester, document: pending(), who: access(update: true));

      expect(
        find.text(l10n.fiscalDocumentStatusCancellationPending),
        findsWidgets,
      );
      expect(
        key('fiscal_document_banner_cancellation_pending'),
        findsOneWidget,
      );
      expect(find.textContaining('Cancelación solicitada el'), findsOneWidget);
      for (final k in editControls) {
        expect(key(k), findsNothing, reason: k);
      }
      expect(key('fiscal_document_view_pdf'), findsOneWidget);
      expect(key('fiscal_document_download_xml'), findsOneWidget);
    });

    testWidgets('a pending cancellation with no open request still says so, '
        'without a date', (tester) async {
      await pumpDetail(
        tester,
        document: pending().copyWith(cancellations: const []),
      );

      expect(
        find.text(l10n.fiscalDocumentBannerCancellationPendingNoDate),
        findsOneWidget,
      );
    });
  });

  group('refresh (spec 072 US4)', () {
    FiscalDocument stamping() => aDocument(
      status: FiscalDocumentStatus.stamping,
      serial: 12,
      total: Decimal.parse('232'),
      stampingSince: DateTime(2026, 11, 17, 11, 5),
    );

    FiscalDocument pending() => aDocument(
      status: FiscalDocumentStatus.cancellationPending,
      serial: 12,
      total: Decimal.parse('232'),
      stamp: aStamp(),
      cancellations: [aCancellation(outcome: CancellationOutcome.pending)],
    );

    FiscalDocument issuedAgain() => aDocument(
      status: FiscalDocumentStatus.issued,
      serial: 12,
      total: Decimal.parse('232'),
      stamp: aStamp(),
      cancellations: [
        aCancellation(
          outcome: CancellationOutcome.rejected,
          pacCode: '2001',
          pacMessage: 'El receptor rechazó la cancelación',
        ),
      ],
    );

    FiscalDocument resolved() => stamping().copyWith(
      summary: stamping().summary.copyWith(status: FiscalDocumentStatus.issued),
      stamp: aStamp(),
      stampingSince: null,
    );

    testWidgets('shows on a stamping and on a cancellation-pending document '
        'with update, and nowhere else', (tester) async {
      await pumpDetail(tester, document: stamping(), who: access(update: true));
      expect(key('fiscal_document_refresh'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentRefreshAction), findsOneWidget);
    });

    testWidgets('shows on a cancellation-pending document, next to its '
        'files', (tester) async {
      await pumpDetail(tester, document: pending(), who: access(update: true));
      expect(key('fiscal_document_refresh'), findsOneWidget);
      expect(key('fiscal_document_view_pdf'), findsOneWidget);
      expect(key('fiscal_document_cancel_cfdi'), findsNothing);
    });

    testWidgets('is absent for a user with read but not update', (
      tester,
    ) async {
      await pumpDetail(tester, document: stamping());
      expect(key('fiscal_document_refresh'), findsNothing);
    });

    for (final status in [
      FiscalDocumentStatus.draft,
      FiscalDocumentStatus.sealed,
      FiscalDocumentStatus.issued,
      FiscalDocumentStatus.cancelled,
    ]) {
      testWidgets('is absent on a ${status.name} document', (tester) async {
        await pumpDetail(
          tester,
          document: aDocument(status: status, serial: 12),
          who: access(update: true),
        );
        expect(key('fiscal_document_refresh'), findsNothing);
      });
    }

    testWidgets('a refresh that leaves the document in process is a note, '
        'not an error, and it can be dismissed', (tester) async {
      when(() => repository.refresh(7)).thenAnswer((_) async => stamping());
      await pumpDetail(tester, document: stamping(), who: access(update: true));

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pumpAndSettle();

      verify(() => repository.refresh(7)).called(1);
      expect(key('fiscal_document_still_in_process'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentStillInProcess), findsOneWidget);
      expect(key('fiscal_document_refusal'), findsNothing);
      expect(key('fiscal_document_banner_stamping'), findsOneWidget);

      await tester.tap(key('fiscal_document_notice_dismiss'));
      await tester.pumpAndSettle();
      expect(key('fiscal_document_still_in_process'), findsNothing);
    });

    // Spec 076: SAT and the receiver can take up to 72 hours, so a pending
    // cancellation does not tell the user to look again in a few minutes.
    testWidgets('a refresh that leaves a cancellation pending says it can take '
        'up to 72 hours, in Spanish and in English', (tester) async {
      when(() => repository.refresh(7)).thenAnswer((_) async => pending());
      await pumpDetail(tester, document: pending(), who: access(update: true));

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pumpAndSettle();

      expect(key('fiscal_document_still_in_process'), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentCancellationStillPending),
        findsOneWidget,
      );
      expect(l10n.fiscalDocumentCancellationStillPending, contains('72 horas'));
      expect(find.text(l10n.fiscalDocumentStillInProcess), findsNothing);
      expect(key('fiscal_document_refusal'), findsNothing);

      await tester.tap(key('fiscal_document_notice_dismiss'));
      await tester.pumpAndSettle();
      expect(key('fiscal_document_still_in_process'), findsNothing);
    });

    testWidgets('the pending-cancellation notice speaks English', (
      tester,
    ) async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      when(() => repository.refresh(7)).thenAnswer((_) async => pending());
      await pumpDetail(
        tester,
        document: pending(),
        who: access(update: true),
        locale: const Locale('en'),
      );

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pumpAndSettle();

      expect(find.text(en.fiscalDocumentCancellationStillPending), findsOne);
      expect(en.fiscalDocumentCancellationStillPending, contains('72 hours'));
      expect(find.text(en.fiscalDocumentStillInProcess), findsNothing);
    });

    for (final surface in const [Size(1400, 1000), Size(400, 900)]) {
      testWidgets('the pending-cancellation notice fits at the largest text '
          'level on ${surface.width.toInt()} px', (tester) async {
        // No lines: at 1.3 the lines table's two-line description cell
        // overflows its 44 px row by 3 px on desktop (specs 066/072, not this
        // notice), and this test is about the notice.
        final noLines = aDocument(
          status: FiscalDocumentStatus.cancellationPending,
          serial: 12,
          total: Decimal.parse('232'),
          stamp: aStamp(),
          cancellations: [aCancellation(outcome: CancellationOutcome.pending)],
          lines: const [],
        );
        when(() => repository.refresh(7)).thenAnswer((_) async => noLines);
        await pumpDetail(
          tester,
          document: noLines,
          who: access(update: true),
          surface: surface,
          textScaler: const TextScaler.linear(1.3),
        );

        await tester.ensureVisible(key('fiscal_document_refresh'));
        await tester.tap(key('fiscal_document_refresh'));
        await tester.pumpAndSettle();

        expect(
          find.text(l10n.fiscalDocumentCancellationStillPending),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a refresh that resolves a stamp says so and shows the stamp, '
        'with Consultar estado gone', (tester) async {
      var refreshed = false;
      when(() => repository.refresh(7)).thenAnswer((_) async {
        refreshed = true;
        return resolved();
      });
      await pumpDetail(tester, document: stamping(), who: access(update: true));
      when(
        () => repository.getById(7),
      ).thenAnswer((_) async => refreshed ? resolved() : stamping());

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.fiscalDocumentRefreshMoved('A12', 'Timbrado')),
        findsOneWidget,
      );
      expect(key('fiscal_document_still_in_process'), findsNothing);
      expect(key('fiscal_document_refresh'), findsNothing);
      expect(key('fiscal_document_banner_stamping'), findsNothing);
      expect(key('fiscal_document_provider_rfc'), findsOneWidget);
    });

    testWidgets('a rejected cancellation takes the document back to Timbrado, '
        'with the rejection in its history and Cancelar offered again', (
      tester,
    ) async {
      var refreshed = false;
      when(() => repository.refresh(7)).thenAnswer((_) async {
        refreshed = true;
        return issuedAgain();
      });
      await pumpDetail(tester, document: pending(), who: access(update: true));
      when(
        () => repository.getById(7),
      ).thenAnswer((_) async => refreshed ? issuedAgain() : pending());

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.fiscalDocumentRefreshMoved('A12', 'Timbrado')),
        findsOneWidget,
      );
      expect(key('fiscal_document_cancel_cfdi'), findsOneWidget);
      expect(key('fiscal_document_refresh'), findsNothing);
    });

    testWidgets('nothing_to_refresh is a refusal, and the screen shows the '
        'document as the server now has it', (tester) async {
      var resolvedMeanwhile = false;
      when(() => repository.refresh(7)).thenAnswer((_) async {
        resolvedMeanwhile = true;
        throw AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'fiscal_document.nothing_to_refresh',
            code: api.ErrorCode.fiscalDocumentPeriodNothingToRefresh,
          ),
        );
      });
      await pumpDetail(tester, document: stamping(), who: access(update: true));
      when(
        () => repository.getById(7),
      ).thenAnswer((_) async => resolvedMeanwhile ? resolved() : stamping());

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.apiErrorFiscalDocumentNothingToRefresh),
        findsOneWidget,
      );
      expect(key('fiscal_document_still_in_process'), findsNothing);
      expect(key('fiscal_document_banner_stamping'), findsNothing);
      expect(key('fiscal_document_refresh'), findsNothing);
    });

    testWidgets('every button waits while it runs, and a second tap refreshes '
        'once', (tester) async {
      final gate = Completer<FiscalDocument>();
      when(() => repository.refresh(7)).thenAnswer((_) => gate.future);
      await pumpDetail(tester, document: pending(), who: access(update: true));

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pump();

      bool enabled(String k) =>
          tester.widget<ButtonStyleButton>(key(k)).onPressed != null;
      expect(enabled('fiscal_document_refresh'), isFalse);
      expect(enabled('fiscal_document_view_pdf'), isFalse);
      expect(enabled('fiscal_document_download_xml'), isFalse);
      expect(
        find.descendant(
          of: key('fiscal_document_refresh'),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      await tester.tap(key('fiscal_document_refresh'), warnIfMissed: false);
      await tester.pump();
      verify(() => repository.refresh(7)).called(1);

      gate.complete(pending());
      await tester.pumpAndSettle();
      expect(enabled('fiscal_document_refresh'), isTrue);
      expect(enabled('fiscal_document_view_pdf'), isTrue);
    });

    testWidgets('pac.unavailable on refresh is a refusal with its own '
        'message', (tester) async {
      when(() => repository.refresh(7)).thenThrow(
        AppError.server(
          statusCode: 503,
          problem: ApiProblem(
            codeName: 'pac.unavailable',
            code: api.ErrorCode.pacPeriodUnavailable,
          ),
        ),
      );
      await pumpDetail(tester, document: stamping(), who: access(update: true));

      await tester.tap(key('fiscal_document_refresh'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.apiErrorPacUnavailable), findsOneWidget);
      expect(key('fiscal_document_still_in_process'), findsNothing);
    });
  });

  group('the cancellation history (spec 072 C19)', () {
    // The server sends newest first.
    List<FiscalCancellation> history() => [
      aCancellation(
        id: 2,
        reason: '01',
        substitution: '9C3D0000-0000-4000-8000-000000007AF0',
        answeredAt: DateTime(2026, 11, 17, 12, 41),
        resolvedAt: DateTime(2026, 11, 17, 12, 42),
      ),
      aCancellation(
        id: 1,
        outcome: CancellationOutcome.rejected,
        pacCode: '2001',
        pacMessage: 'El receptor rechazó la solicitud',
        requestedBy: 6,
        answeredAt: DateTime(2026, 11, 17, 12, 35),
      ),
    ];

    FiscalDocument cancelled({List<FiscalCancellation>? cancellations}) =>
        aDocument(
          status: FiscalDocumentStatus.cancelled,
          serial: 12,
          total: Decimal.parse('232'),
          stamp: aStamp(),
          cancellationSubstitution: '9C3D0000-0000-4000-8000-000000007AF0',
          cancellations: cancellations ?? history(),
        );

    final employees = employeeDisplayNameProvider.overrideWith(
      (ref, id) async => id == 5 ? 'María López' : null,
    );

    testWidgets('lists every request newest first, with reason, outcome, who '
        'and when', (tester) async {
      await pumpDetail(
        tester,
        document: cancelled(),
        extraOverrides: [employees],
      );

      expect(key('fiscal_document_cancellations'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentCancellationsTitle), findsOneWidget);
      expect(
        tester.getTopLeft(key('fiscal_document_cancellation_2')).dy,
        lessThan(tester.getTopLeft(key('fiscal_document_cancellation_1')).dy),
      );
      expect(
        find.text('01 ${l10n.fiscalDocumentCancelReason01}'),
        findsOneWidget,
      );
      expect(
        find.text('02 ${l10n.fiscalDocumentCancelReason02}'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: key('fiscal_document_cancellation_outcome_2'),
          matching: find.text(l10n.fiscalDocumentCancellationOutcomeAccepted),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: key('fiscal_document_cancellation_outcome_1'),
          matching: find.text(l10n.fiscalDocumentCancellationOutcomeRejected),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          l10n.fiscalDocumentCancellationRequestedBy(
            'María López',
            '2026-11-17 12:30',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(l10n.fiscalDocumentCancellationAnswered('2026-11-17 12:41')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.fiscalDocumentCancellationResolved('2026-11-17 12:42')),
        findsOneWidget,
      );
    });

    testWidgets("a requester whose name can't be read shows their id", (
      tester,
    ) async {
      await pumpDetail(
        tester,
        document: cancelled(),
        extraOverrides: [employees],
      );

      expect(
        find.text(
          l10n.fiscalDocumentCancellationRequestedBy('#6', '2026-11-17 12:30'),
        ),
        findsOneWidget,
      );
    });

    testWidgets("shows the PAC's code and message exactly as written", (
      tester,
    ) async {
      await pumpDetail(
        tester,
        document: cancelled(),
        extraOverrides: [employees],
      );

      expect(
        find.text(
          l10n.fiscalDocumentCancellationPac(
            '2001 · «El receptor rechazó la solicitud»',
          ),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_cancellation_pac_2'), findsNothing);
    });

    testWidgets('an open request shows a dash for the answer and the '
        'resolution', (tester) async {
      await pumpDetail(
        tester,
        document: cancelled(
          cancellations: [aCancellation(outcome: CancellationOutcome.pending)],
        ),
        extraOverrides: [employees],
      );

      expect(find.text(l10n.fiscalDocumentCancellationAnswered('—')), findsOne);
      expect(find.text(l10n.fiscalDocumentCancellationResolved('—')), findsOne);
    });

    testWidgets('an outcome this version does not know shows the raw value', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        document: cancelled(
          cancellations: [
            aCancellation(
              outcome: CancellationOutcome.unknown,
            ).copyWith(rawOutcome: 'from_the_future'),
          ],
        ),
        extraOverrides: [employees],
      );

      expect(
        find.text(
          l10n.fiscalDocumentCancellationOutcomeUnknown('from_the_future'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a document with no requests shows no section', (tester) async {
      await pumpDetail(
        tester,
        document: cancelled(cancellations: const []),
        extraOverrides: [employees],
      );

      expect(key('fiscal_document_cancellations'), findsNothing);
    });

    testWidgets('the substitute shows as a fact only when set', (tester) async {
      await pumpDetail(
        tester,
        document: cancelled(),
        extraOverrides: [employees],
      );
      expect(key('fiscal_document_substitution'), findsOneWidget);
      expect(find.text('9C3D0000-0000-4000-8000-000000007AF0'), findsWidgets);
    });

    testWidgets('no substitute fact on a document cancelled with 02', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        document: cancelled().copyWith(cancellationSubstitution: null),
        extraOverrides: [employees],
      );
      expect(key('fiscal_document_substitution'), findsNothing);
    });

    testWidgets('renders at a compact width without overflowing', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        document: cancelled(),
        extraOverrides: [employees],
        surface: const Size(400, 900),
      );

      expect(tester.takeException(), isNull);
      expect(key('fiscal_document_cancellation_2'), findsOneWidget);
      expect(key('fiscal_document_cancellation_1'), findsOneWidget);
    });
  });

  group('the stamp (spec 072 C17)', () {
    testWidgets('an issued document stamped by the simulator shows the UUID, '
        'date, SAT certificate, PAC and the badge', (tester) async {
      await pumpDetail(
        tester,
        document: issued().copyWith(
          stamped: DateTime(2026, 11, 17, 9, 13),
          stamp: aStamp(),
          summary: issued().summary.copyWith(stampUuid: aStamp().uuid),
        ),
      );

      expect(key('fiscal_document_uuid_value'), findsOneWidget);
      expect(find.text(aStamp().uuid), findsOneWidget);
      expect(find.text('2026-11-17 09:13'), findsOneWidget);
      expect(find.text('00001000000509846663'), findsOneWidget);
      expect(find.text('SIM010101SI0'), findsOneWidget);
      expect(key('fiscal_document_simulated_badge'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentSimulatedBadge), findsOneWidget);
    });

    testWidgets('a legacy stamp shows what the server has, with the '
        'placeholder for the rest and no badge', (tester) async {
      await pumpDetail(
        tester,
        document: issued().copyWith(
          stamp: aStamp(
            simulated: false,
            satCertificate: null,
            providerRfc: null,
          ),
        ),
      );

      expect(key('fiscal_document_sat_certificate'), findsOneWidget);
      expect(
        find.descendant(
          of: key('fiscal_document_sat_certificate'),
          matching: find.text('—'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: key('fiscal_document_provider_rfc'),
          matching: find.text('—'),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_simulated_badge'), findsNothing);
    });

    for (final status in [
      FiscalDocumentStatus.cancellationPending,
      FiscalDocumentStatus.cancelled,
    ]) {
      testWidgets(
        'a ${status.name} document keeps showing its stamp (FR-007)',
        (tester) async {
          await pumpDetail(
            tester,
            document: issued(status: status).copyWith(stamp: aStamp()),
          );

          expect(key('fiscal_document_provider_rfc'), findsOneWidget);
          expect(find.text('SIM010101SI0'), findsOneWidget);
          expect(key('fiscal_document_simulated_badge'), findsOneWidget);
        },
      );
    }

    // Spec 076 (FR-012, FR-013): mbe-api spec 040 changed the simulator's
    // provider RFC and migrated the old stamps. The badge follows the flag,
    // never the RFC.
    for (final rfc in ['SIM010101SIM', 'SIM010101SI0']) {
      testWidgets('a simulated stamp from $rfc shows the badge and the RFC', (
        tester,
      ) async {
        await pumpDetail(
          tester,
          document: issued().copyWith(stamp: aStamp(providerRfc: rfc)),
        );

        expect(key('fiscal_document_simulated_badge'), findsOneWidget);
        expect(
          find.descendant(
            of: key('fiscal_document_provider_rfc'),
            matching: find.text(rfc),
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('a real stamp shows its RFC and no simulated badge', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        document: issued().copyWith(
          stamp: aStamp(simulated: false, providerRfc: 'MAS0310229P8'),
        ),
      );

      expect(key('fiscal_document_simulated_badge'), findsNothing);
      expect(find.text('MAS0310229P8'), findsOneWidget);
    });

    // Spec 076 (FR-011): after 72 hours with nothing from SAT, the server
    // closes the request as failed and the document is issued again.
    testWidgets('an issued document whose request failed after 72 hours shows '
        'it in the history and can be cancelled again', (tester) async {
      await pumpDetail(
        tester,
        document: issued().copyWith(
          stamp: aStamp(),
          cancellations: [aCancellation(outcome: CancellationOutcome.failed)],
        ),
        who: access(update: true),
      );

      expect(key('fiscal_document_status_chip_issued'), findsOneWidget);
      expect(key('fiscal_document_cancellations'), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentCancellationOutcomeFailed),
        findsOneWidget,
      );
      expect(key('fiscal_document_cancel_cfdi'), findsOneWidget);
    });

    testWidgets('a document with no stamp shows none of it', (tester) async {
      await pumpDetail(
        tester,
        document: aDocument(
          status: FiscalDocumentStatus.sealed,
          serial: 12,
          total: Decimal.parse('232'),
        ),
      );

      expect(key('fiscal_document_sat_certificate'), findsNothing);
      expect(key('fiscal_document_provider_rfc'), findsNothing);
      expect(key('fiscal_document_simulated_badge'), findsNothing);
    });
  });

  group('the sealed banner (spec 072 C16)', () {
    FiscalDocument sealed({int typeCode = 0}) => aDocument(
      status: FiscalDocumentStatus.sealed,
      typeCode: typeCode,
      serial: 12,
      total: Decimal.parse('232'),
    );

    testWidgets('a user who can update is told to stamp or reopen an '
        'invoice', (tester) async {
      await pumpDetail(tester, document: sealed(), who: access(update: true));

      expect(
        find.text(l10n.fiscalDocumentBannerSealedStampOrReopen),
        findsOneWidget,
      );
      expect(find.textContaining('not available'), findsNothing);
      expect(find.textContaining('no está disponible'), findsNothing);
    });

    testWidgets('a user who can update is told only to stamp a document that '
        'cannot be reopened', (tester) async {
      await pumpDetail(
        tester,
        document: sealed(typeCode: 100),
        who: access(update: true),
      );

      expect(key('fiscal_document_banner_sealed'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentBannerSealedStamp), findsOneWidget);
    });

    testWidgets('a read-only user gets the short text, with no advice', (
      tester,
    ) async {
      await pumpDetail(tester, document: sealed());

      expect(find.text(l10n.fiscalDocumentBannerSealed), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentBannerSealedStampOrReopen),
        findsNothing,
      );
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

  group('Emitir nota de crédito on an invoice (spec 073 C25)', () {
    final h = InvoiceHarness();

    FiscalDocument document({
      int typeCode = 0,
      FiscalDocumentStatus status = FiscalDocumentStatus.issued,
    }) => aDocument(
      status: status,
      typeCode: typeCode,
      serial: 12,
      series: 'GR',
      total: Decimal.parse('232'),
      stamp: aStamp(),
    );

    // FiscalDocuments (23): 1 create, 2 read, 4 update.
    Future<void> shows(
      WidgetTester tester,
      FiscalDocument d, {
      int rights = 7,
    }) async {
      await h.pump(
        tester,
        document: d,
        who: InvoiceHarness.access(fiscalDocuments: rights),
      );
    }

    testWidgets('is the last button of an issued invoice, with create', (
      tester,
    ) async {
      await shows(tester, document());

      expect(key('fiscal_document_issue_credit_note'), findsOneWidget);
      final actions = tester.widget<Wrap>(
        find.descendant(
          of: key('fiscal_document_actions'),
          matching: find.byType(Wrap),
        ),
      );
      expect(
        (actions.children.last as OutlinedButton).key,
        const Key('fiscal_document_issue_credit_note'),
      );
    });

    for (final status in FiscalDocumentStatus.values) {
      if (status == FiscalDocumentStatus.issued) continue;
      testWidgets('is absent on a ${status.name} invoice', (tester) async {
        await shows(tester, document(status: status));
        expect(key('fiscal_document_issue_credit_note'), findsNothing);
      });
    }

    testWidgets('is absent on an issued credit note', (tester) async {
      await shows(
        tester,
        aCreditNote(status: FiscalDocumentStatus.issued, serial: 3),
      );
      expect(key('fiscal_document_issue_credit_note'), findsNothing);
    });

    testWidgets('is absent with update but no create', (tester) async {
      await shows(tester, document(), rights: 6);
      expect(key('fiscal_document_issue_credit_note'), findsNothing);
    });

    testWidgets('is absent for a read-only user', (tester) async {
      await shows(tester, document(), rights: 2);
      expect(key('fiscal_document_issue_credit_note'), findsNothing);
    });
  });

  group('a credit note (spec 073 US3)', () {
    final h = InvoiceHarness();

    FiscalDocument sealedNote({int serial = 5}) =>
        aCreditNote(
          status: FiscalDocumentStatus.sealed,
          serial: serial,
        ).copyWith(
          summary: aCreditNote(serial: serial).summary.copyWith(
            status: FiscalDocumentStatus.sealed,
            total: Decimal.parse('116'),
          ),
        );

    AppError refusal(
      String name,
      api.ErrorCode code, [
      Map<String, Object?> params = const {},
    ]) => AppError.server(
      statusCode: 422,
      problem: ApiProblem(codeName: name, code: code, params: params),
    );

    group('banners', () {
      testWidgets('form 99 shows the form banner, for an editor only', (
        tester,
      ) async {
        await h.pump(tester, document: aCreditNote(paymentForm: 99));
        expect(key('fiscal_document_banner_credit_note_form'), findsOneWidget);
        expect(
          find.text(l10n.fiscalDocumentBannerCreditNoteForm),
          findsOneWidget,
        );
      });

      testWidgets('form 99 shows no banner to a read-only user', (
        tester,
      ) async {
        await h.pump(
          tester,
          document: aCreditNote(paymentForm: 99),
          who: InvoiceHarness.access(fiscalDocuments: 2),
        );
        expect(key('fiscal_document_banner_credit_note_form'), findsNothing);
      });

      testWidgets('a real form shows no banner at all, and never the '
          'read-only one', (tester) async {
        await h.pump(tester, document: aCreditNote(paymentForm: 3));
        expect(key('fiscal_document_banner_credit_note_form'), findsNothing);
        expect(key('fiscal_document_banner_read_only_kind'), findsNothing);
      });

      testWidgets('a sealed credit note says it can be stamped or reopened', (
        tester,
      ) async {
        await h.pump(tester, document: sealedNote());
        expect(key('fiscal_document_banner_sealed'), findsOneWidget);
        expect(
          find.text(l10n.fiscalDocumentBannerSealedStampOrReopen),
          findsOneWidget,
        );
        expect(key('fiscal_document_banner_read_only_kind'), findsNothing);
      });
    });

    testWidgets('a draft offers Confirmar, and never a new credit note', (
      tester,
    ) async {
      await h.pump(tester, document: aCreditNote());
      expect(key('fiscal_document_confirm'), findsOneWidget);
      expect(key('fiscal_document_issue_credit_note'), findsNothing);
    });

    testWidgets('a sealed one offers Reabrir and Timbrar', (tester) async {
      await h.pump(tester, document: sealedNote());
      expect(key('fiscal_document_reopen'), findsOneWidget);
      expect(key('fiscal_document_stamp'), findsOneWidget);
      expect(key('fiscal_document_confirm'), findsNothing);
      expect(key('fiscal_document_issue_credit_note'), findsNothing);
    });

    testWidgets('a read-only user sees no action', (tester) async {
      await h.pump(
        tester,
        document: sealedNote(),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );
      for (final k in [
        'fiscal_document_reopen',
        'fiscal_document_stamp',
        'fiscal_document_confirm',
        'fiscal_document_issue_credit_note',
      ]) {
        expect(key(k), findsNothing, reason: k);
      }
    });

    group('Confirmar refused', () {
      Future<void> confirmRefused(WidgetTester tester, AppError error) async {
        when(() => h.documents.confirm(7)).thenThrow(error);
        await h.pump(tester, document: aCreditNote());
        await tester.tap(key('fiscal_document_confirm'));
        await tester.pumpAndSettle();
        await tester.tap(key('invoice_confirm_submit'));
        await tester.pumpAndSettle();
      }

      testWidgets('over the invoice names the invoice and what is left', (
        tester,
      ) async {
        await confirmRefused(
          tester,
          refusal(
            'fiscal_document.credit_exceeds_invoice',
            api.ErrorCode.fiscalDocumentPeriodCreditExceedsInvoice,
            {'invoice_id': 12, 'remaining': '1500.00'},
          ),
        );

        expect(key('fiscal_document_refusal'), findsOneWidget);
        expect(
          find.text(
            l10n.fiscalDocumentCreditExceedsInvoice('GR12', r'$1,500.00'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('over the invoice, with no related invoice or no amount, '
          'falls back to the localized text', (tester) async {
        await confirmRefused(
          tester,
          refusal(
            'fiscal_document.credit_exceeds_invoice',
            api.ErrorCode.fiscalDocumentPeriodCreditExceedsInvoice,
            {'invoice_id': 12},
          ),
        );
        expect(find.textContaining('factura GR12'), findsNothing);
        expect(key('fiscal_document_refusal'), findsOneWidget);
      });

      for (final (name, code, text)
          in <(String, api.ErrorCode, String Function())>[
            (
              'fiscal_document.payment_form_required',
              api.ErrorCode.fiscalDocumentPeriodPaymentFormRequired,
              () => l10n.apiErrorFiscalDocumentPaymentFormRequired,
            ),
            (
              'fiscal_document.no_lines',
              api.ErrorCode.fiscalDocumentPeriodNoLines,
              () => l10n.apiErrorFiscalDocumentNoLines,
            ),
            (
              'fiscal_document.issue_date_out_of_range',
              api.ErrorCode.fiscalDocumentPeriodIssueDateOutOfRange,
              () => l10n.apiErrorFiscalDocumentIssueDateOutOfRange,
            ),
          ]) {
        testWidgets('$name shows its localized text', (tester) async {
          await confirmRefused(tester, refusal(name, code, {'type': 100}));
          expect(find.text(text()), findsOneWidget);
        });
      }
    });

    testWidgets('Confirmar seals it, and the messages say which document', (
      tester,
    ) async {
      var sealed = false;
      when(() => h.documents.confirm(7)).thenAnswer((_) async {
        sealed = true;
        return sealedNote();
      });
      await h.pump(tester, document: aCreditNote(serial: null));
      when(
        () => h.documents.getById(7),
      ).thenAnswer((_) async => sealed ? sealedNote() : aCreditNote());

      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();
      // Neutral wording: the dialog doesn't call it an invoice.
      expect(find.text(l10n.fiscalDocumentConfirmTitle), findsOneWidget);
      expect(
        find.descendant(
          of: key('invoice_confirm_dialog'),
          matching: find.textContaining('factura'),
        ),
        findsNothing,
      );
      await tester.tap(key('invoice_confirm_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.fiscalDocumentConfirmed(
            l10n.fiscalDocumentKindCreditNote,
            'NC5',
          ),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_banner_sealed'), findsOneWidget);
    });

    testWidgets('Reabrir returns it to a draft that keeps its folio', (
      tester,
    ) async {
      var reopened = false;
      when(() => h.documents.reopen(7)).thenAnswer((_) async {
        reopened = true;
        return aCreditNote(serial: 5);
      });
      await h.pump(tester, document: sealedNote());
      when(() => h.documents.getById(7)).thenAnswer(
        (_) async => reopened ? aCreditNote(serial: 5) : sealedNote(),
      );

      await tester.tap(key('fiscal_document_reopen'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.fiscalDocumentReopenTitle), findsOneWidget);
      expect(
        find.descendant(
          of: key('invoice_reopen_dialog'),
          matching: find.textContaining('factura'),
        ),
        findsNothing,
      );
      await tester.tap(key('invoice_reopen_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.reopen(7)).called(1);
      expect(
        find.text(
          l10n.fiscalDocumentReopened(l10n.fiscalDocumentKindCreditNote, 'NC5'),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_confirm'), findsOneWidget);
    });

    testWidgets('Timbrar issues it, with the simulated badge (spec 072)', (
      tester,
    ) async {
      var stamped = false;
      FiscalDocument issuedNote() => sealedNote().copyWith(
        stamp: aStamp(),
        summary: sealedNote().summary.copyWith(
          status: FiscalDocumentStatus.issued,
          stampUuid: aStamp().uuid,
        ),
      );
      when(() => h.documents.stamp(7)).thenAnswer((_) async {
        stamped = true;
        return issuedNote();
      });
      await h.pump(tester, document: sealedNote());
      when(
        () => h.documents.getById(7),
      ).thenAnswer((_) async => stamped ? issuedNote() : sealedNote());

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.fiscalDocumentStampedSimulated('NC5')),
        findsOneWidget,
      );
      expect(key('fiscal_document_simulated_badge'), findsOneWidget);
      expect(key('fiscal_document_status_chip_issued'), findsOneWidget);
    });

    testWidgets('an empty draft says the document has no lines', (
      tester,
    ) async {
      await h.pump(tester, document: aCreditNote(lines: const []));

      expect(find.text(l10n.fiscalDocumentLinesEmpty), findsOneWidget);
      expect(find.text('El documento no tiene partidas.'), findsOneWidget);
    });
  });

  group('the relation link (spec 073 C28, US4)', () {
    final h = InvoiceHarness();

    testWidgets('a credit note links to its invoice, and Back returns', (
      tester,
    ) async {
      await h.pump(tester, document: aCreditNote());
      when(() => h.documents.getById(12)).thenAnswer(
        (_) async => aDocument(
          id: 12,
          status: FiscalDocumentStatus.issued,
          serial: 12,
          series: 'GR',
          total: Decimal.parse('232'),
          stamp: aStamp(),
        ),
      );

      expect(key('fiscal_document_relation_link_1'), findsOneWidget);
      expect(
        find.descendant(
          of: key('fiscal_document_relation_link_1'),
          matching: find.text('GR12'),
        ),
        findsOneWidget,
      );

      await tester.tap(key('fiscal_document_relation_link_1'));
      await tester.pumpAndSettle();

      // The invoice is open.
      expect(find.text(l10n.fiscalDocumentTitle('GR12')), findsOneWidget);
      expect(key('fiscal_document_issue_credit_note'), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.fiscalDocumentTitleKind(l10n.fiscalDocumentKindCreditNote, '#7'),
        ),
        findsWidgets,
      );
    });

    testWidgets('an invoice links its 04 relation too', (tester) async {
      await h.pump(
        tester,
        document: aDocument(
          relations: [
            aRelation(
              id: 3,
              documentId: 99,
              type: InvoiceRelationType.substitution,
              series: 'A',
              serial: 5,
            ),
          ],
        ),
      );
      when(() => h.documents.getById(99)).thenAnswer(
        (_) async => aDocument(
          id: 99,
          status: FiscalDocumentStatus.issued,
          serial: 5,
          series: 'A',
          total: Decimal.parse('232'),
          stamp: aStamp(),
        ),
      );

      await tester.tap(key('fiscal_document_relation_link_3'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.fiscalDocumentTitle('A5')), findsOneWidget);
    });

    testWidgets('a related document with no folio links by its id', (
      tester,
    ) async {
      await h.pump(
        tester,
        document: aCreditNote().copyWith(
          relations: [aRelation(id: 1, documentId: 12, serial: null)],
        ),
      );

      expect(
        find.descendant(
          of: key('fiscal_document_relation_link_1'),
          matching: find.text('#12'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a legacy credit note with no relation shows no relations '
        'section, and sealed it cannot be reopened', (tester) async {
      await h.pump(
        tester,
        document: aCreditNote(
          withRelation: false,
          status: FiscalDocumentStatus.sealed,
          serial: 5,
        ),
      );

      expect(key('fiscal_document_relations'), findsNothing);
      expect(key('fiscal_document_reopen'), findsNothing);
      expect(key('fiscal_document_edit_header'), findsNothing);
      expect(key('fiscal_document_copy_invoice_lines'), findsNothing);
    });
  });
}
