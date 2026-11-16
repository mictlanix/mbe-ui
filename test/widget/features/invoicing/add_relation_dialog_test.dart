import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

const _advance = InvoiceRelation(
  id: 3,
  documentId: 98,
  type: InvoiceRelationType.advanceApplication,
  series: 'A',
  serial: 5,
  stampUuid: 'UUID-98',
);

/// Spec 066 US6, contract C12: related documents.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(InvoiceRelationType.substitution);
  });

  setUp(() {
    h = InvoiceHarness();
    when(
      () => h.documents.list(
        search: any(named: 'search'),
        issuer: any(named: 'issuer'),
        type: any(named: 'type'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => FiscalDocumentPage(
        items: [
          FiscalDocumentSummary(
            id: 99,
            typeCode: 0,
            version: '4.0',
            series: 'GR',
            serial: 4776,
            issuerRfc: 'XAXX010101000',
            status: FiscalDocumentStatus.cancelled,
            stampUuid: 'UUID-99',
            issued: DateTime(2026, 11, 1),
            total: Decimal.parse('232'),
          ),
        ],
        total: 1,
      ),
    );
  });

  Future<void> open(WidgetTester tester, {FiscalDocument? document}) async {
    await h.pump(tester, document: document);
    await tester.tap(key('fiscal_document_add_relation'));
    await tester.pumpAndSettle();
  }

  void listed(FiscalDocumentStatus status) => verify(
    () => h.documents.list(
      search: 'XEXX010101000',
      issuer: 'XAXX010101000',
      status: status,
      skip: 0,
      limit: 20,
    ),
  ).called(1);

  group('the dialog', () {
    testWidgets('lists cancelled documents for 04 with the recipient\'s RFC '
        'prefilled', (tester) async {
      await open(tester);

      listed(FiscalDocumentStatus.cancelled);
      expect(
        tester.widget<TextField>(key('add_relation_search')).controller!.text,
        'XEXX010101000',
      );
      expect(key('add_relation_row_99'), findsOneWidget);
      expect(find.text('GR4776'), findsOneWidget);
      expect(find.text('UUID-99'), findsOneWidget);
      expect(find.text('2026-11-01'), findsOneWidget);
    });

    testWidgets('switching to 07 lists issued documents', (tester) async {
      await open(tester);

      await tester.tap(key('add_relation_type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.fiscalDocumentRelationAdvance).last);
      await tester.pumpAndSettle();

      verify(
        () => h.documents.list(
          search: 'XEXX010101000',
          issuer: 'XAXX010101000',
          status: FiscalDocumentStatus.issued,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('the type is locked to the one the invoice already has', (
      tester,
    ) async {
      await open(tester, document: aDocument(relations: const [_advance]));

      final dropdown = tester
          .widget<DropdownButtonFormField<InvoiceRelationType>>(
            key('add_relation_type'),
          );
      expect(dropdown.onChanged, isNull);
      expect(dropdown.initialValue, InvoiceRelationType.advanceApplication);
      // The list asks for what a 07 needs.
      verify(
        () => h.documents.list(
          search: 'XEXX010101000',
          issuer: 'XAXX010101000',
          status: FiscalDocumentStatus.issued,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('picking a document adds it with the chosen type and says '
        'so', (tester) async {
      when(
        () => h.documents.addRelation(7, 99, InvoiceRelationType.substitution),
      ).thenAnswer((_) async => aDocument());
      await open(tester);

      await tester.tap(key('add_relation_row_99'));
      await tester.pumpAndSettle();

      verify(
        () => h.documents.addRelation(7, 99, InvoiceRelationType.substitution),
      ).called(1);
      expect(key('add_relation_dialog'), findsNothing);
      expect(find.text(l10n.fiscalDocumentRelationAdded), findsOneWidget);
    });

    for (final (name, code, text)
        in <(String, api.ErrorCode, String Function())>[
          (
            'relation_not_allowed',
            api.ErrorCode.fiscalDocumentPeriodRelationNotAllowed,
            () => l10n.apiErrorFiscalDocumentRelationNotAllowed,
          ),
          (
            'already_related',
            api.ErrorCode.fiscalDocumentPeriodAlreadyRelated,
            () => l10n.apiErrorFiscalDocumentAlreadyRelated,
          ),
          (
            'relation_types_mixed',
            api.ErrorCode.fiscalDocumentPeriodRelationTypesMixed,
            () => l10n.apiErrorFiscalDocumentRelationTypesMixed,
          ),
        ]) {
      testWidgets('$name stays inline and the dialog stays open', (
        tester,
      ) async {
        when(() => h.documents.addRelation(7, 99, any())).thenThrow(
          AppError.server(
            statusCode: 422,
            problem: ApiProblem(
              codeName: 'fiscal_document.$name',
              code: code,
              params: const {'relation_type': '04', 'relation_id': 3},
            ),
          ),
        );
        await open(tester);

        await tester.tap(key('add_relation_row_99'));
        await tester.pumpAndSettle();

        expect(key('add_relation_dialog'), findsOneWidget);
        expect(find.text(text()), findsOneWidget);
      });
    }

    testWidgets('any other refusal closes the dialog and shows above the '
        'actions', (tester) async {
      when(() => h.documents.addRelation(7, 99, any())).thenThrow(
        const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'fiscal_document.not_draft',
            code: api.ErrorCode.fiscalDocumentPeriodNotDraft,
          ),
        ),
      );
      await open(tester);

      await tester.tap(key('add_relation_row_99'));
      await tester.pumpAndSettle();

      expect(key('add_relation_dialog'), findsNothing);
      expect(find.text(l10n.apiErrorFiscalDocumentNotDraft), findsOneWidget);
    });

    testWidgets('an empty list says so', (tester) async {
      when(
        () => h.documents.list(
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
      await open(tester);

      expect(key('add_relation_empty'), findsOneWidget);
    });
  });

  group('removing a relation', () {
    testWidgets('asks first, then removes it', (tester) async {
      when(
        () => h.documents.removeRelation(7, 3),
      ).thenAnswer((_) async => aDocument());
      await h.pump(tester, document: aDocument(relations: const [_advance]));

      await tester.tap(key('fiscal_document_relation_remove_3'));
      await tester.pumpAndSettle();
      expect(key('invoice_relation_remove_dialog'), findsOneWidget);
      verifyNever(() => h.documents.removeRelation(any(), any()));

      await tester.tap(key('invoice_relation_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.removeRelation(7, 3)).called(1);
      expect(key('invoice_relation_remove_dialog'), findsNothing);
    });

    testWidgets('a refusal stays inline', (tester) async {
      when(() => h.documents.removeRelation(7, 3)).thenThrow(
        const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'fiscal_document.not_draft',
            code: api.ErrorCode.fiscalDocumentPeriodNotDraft,
          ),
        ),
      );
      await h.pump(tester, document: aDocument(relations: const [_advance]));

      await tester.tap(key('fiscal_document_relation_remove_3'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_relation_remove_submit'));
      await tester.pumpAndSettle();

      expect(key('invoice_relation_remove_dialog'), findsOneWidget);
      expect(find.text(l10n.apiErrorFiscalDocumentNotDraft), findsOneWidget);
    });
  });

  group('the section', () {
    testWidgets('shows on an editable draft even with no relations, with '
        'Agregar relación', (tester) async {
      await h.pump(tester);
      expect(key('fiscal_document_relations'), findsOneWidget);
      expect(key('fiscal_document_add_relation'), findsOneWidget);
    });

    testWidgets('is read-only without update: listed, but no add or remove', (
      tester,
    ) async {
      await h.pump(
        tester,
        document: aDocument(relations: const [_advance]),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );
      expect(key('fiscal_document_relation_3'), findsOneWidget);
      expect(key('fiscal_document_add_relation'), findsNothing);
      expect(key('fiscal_document_relation_remove_3'), findsNothing);
    });

    testWidgets('is hidden on a non-draft with no relations', (tester) async {
      await h.pump(
        tester,
        document: aDocument(
          status: FiscalDocumentStatus.issued,
          serial: 1,
          total: Decimal.parse('232'),
        ),
      );
      expect(key('fiscal_document_relations'), findsNothing);
    });

    testWidgets('is read-only on a non-draft with relations', (tester) async {
      await h.pump(
        tester,
        document: aDocument(
          status: FiscalDocumentStatus.issued,
          serial: 1,
          total: Decimal.parse('232'),
          relations: const [_advance],
        ),
      );
      expect(key('fiscal_document_relations'), findsOneWidget);
      expect(key('fiscal_document_add_relation'), findsNothing);
      expect(key('fiscal_document_relation_remove_3'), findsNothing);
    });
  });
}
