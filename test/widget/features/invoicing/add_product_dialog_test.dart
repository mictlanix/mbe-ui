import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

const _clavo = ProductListItem(
  productId: 77,
  code: 'CLV-1',
  name: 'Clavo de acero',
  unitOfMeasurementCode: 'H87',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  status: EntityStatus.active,
);

/// Spec 066 US4, contract C11: "Agregar producto".
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    h = InvoiceHarness();
    when(
      () => h.products.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const ProductListResult(items: [_clavo], total: 1),
    );
  });

  Future<void> open(WidgetTester tester) async {
    await h.pump(tester);
    await tester.tap(key('fiscal_document_add_product'));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: key('add_invoice_product_field'),
        matching: find.byType(TextFormField),
      ),
      'cla',
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clavo de acero'));
    await tester.pumpAndSettle();
  }

  testWidgets('picking a product adds it, closes and says so', (tester) async {
    when(
      () => h.documents.addProduct(7, 77),
    ).thenAnswer((_) async => aDocument());
    await open(tester);

    await pick(tester);

    verify(() => h.documents.addProduct(7, 77)).called(1);
    expect(key('add_invoice_product_dialog'), findsNothing);
    expect(find.text(l10n.fiscalDocumentProductAdded), findsOneWidget);
  });

  testWidgets('product_unpriced stays inline and another product can be '
      'picked', (tester) async {
    when(() => h.documents.addProduct(7, 77)).thenThrow(
      const AppError.server(
        statusCode: 422,
        problem: ApiProblem(
          codeName: 'fiscal_document.product_unpriced',
          code: api.ErrorCode.fiscalDocumentPeriodProductUnpriced,
          params: {'product_id': 77},
        ),
      ),
    );
    await open(tester);

    await pick(tester);

    expect(key('add_invoice_product_dialog'), findsOneWidget);
    expect(
      find.text(l10n.apiErrorFiscalDocumentProductUnpriced),
      findsOneWidget,
    );
  });

  testWidgets('any other refusal closes the dialog and shows above the '
      'action area', (tester) async {
    when(() => h.documents.addProduct(7, 77)).thenThrow(
      const AppError.server(
        statusCode: 409,
        problem: ApiProblem(
          codeName: 'fiscal_document.not_draft',
          code: api.ErrorCode.fiscalDocumentPeriodNotDraft,
        ),
      ),
    );
    await open(tester);

    await pick(tester);

    expect(key('add_invoice_product_dialog'), findsNothing);
    expect(find.text(l10n.apiErrorFiscalDocumentNotDraft), findsOneWidget);
  });

  testWidgets('searches active products by the typed text', (tester) async {
    when(
      () => h.documents.addProduct(any(), any()),
    ).thenAnswer((_) async => aDocument());
    await open(tester);

    await pick(tester);

    verify(
      () => h.products.list(
        search: 'cla',
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('Cancelar closes without adding', (tester) async {
    await open(tester);

    await tester.tap(key('add_invoice_product_close'));
    await tester.pumpAndSettle();

    expect(key('add_invoice_product_dialog'), findsNothing);
    verifyNever(() => h.documents.addProduct(any(), any()));
  });
}
