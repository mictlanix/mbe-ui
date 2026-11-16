import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

/// Spec 066 US4, contract C9: which edit controls the detail screen shows.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = InvoiceHarness());

  const controls = [
    'fiscal_document_edit_header',
    'fiscal_document_add_order',
    'fiscal_document_add_product',
    'fiscal_document_line_edit_10',
    'fiscal_document_line_remove_10',
  ];

  void expectControls(Set<String> shown) {
    for (final k in controls) {
      expect(
        key(k),
        shown.contains(k) ? findsOneWidget : findsNothing,
        reason: k,
      );
    }
  }

  testWidgets('an editable draft with update shows every control', (
    tester,
  ) async {
    await h.pump(tester);
    expectControls(controls.toSet());
  });

  testWidgets('without FiscalDocuments update none shows', (tester) async {
    await h.pump(tester, who: InvoiceHarness.access(fiscalDocuments: 2));
    expectControls({});
  });

  testWidgets('Agregar producto needs StandaloneFiscalDocuments create', (
    tester,
  ) async {
    await h.pump(tester, who: InvoiceHarness.access(standalone: false));
    expectControls(controls.toSet()..remove('fiscal_document_add_product'));
  });

  testWidgets('Agregar pedido needs SalesOrders read', (tester) async {
    await h.pump(tester, who: InvoiceHarness.access(ordersRead: false));
    expectControls(controls.toSet()..remove('fiscal_document_add_order'));
  });

  for (final (name, doc) in [
    (
      'an issued invoice',
      aDocument(
        status: FiscalDocumentStatus.issued,
        serial: 1,
        total: Decimal.parse('232'),
      ),
    ),
    (
      'a sealed invoice',
      aDocument(
        status: FiscalDocumentStatus.sealed,
        serial: 1,
        total: Decimal.parse('232'),
      ),
    ),
    ('a draft credit note', aDocument(typeCode: 100)),
  ]) {
    testWidgets('$name has no edit controls', (tester) async {
      await h.pump(tester, document: doc);
      expectControls({});
    });
  }

  group('removing a line', () {
    testWidgets('asks first, then removes it', (tester) async {
      when(
        () => h.documents.removeLine(7, 10),
      ).thenAnswer((_) async => aDocument());
      await h.pump(tester);

      await tester.tap(key('fiscal_document_line_remove_10'));
      await tester.pumpAndSettle();

      expect(key('invoice_line_remove_dialog'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentRemoveLineBody), findsOneWidget);
      verifyNever(() => h.documents.removeLine(any(), any()));

      await tester.tap(key('invoice_line_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.removeLine(7, 10)).called(1);
      expect(key('invoice_line_remove_dialog'), findsNothing);
    });

    testWidgets('Cancelar removes nothing', (tester) async {
      await h.pump(tester);

      await tester.tap(key('fiscal_document_line_remove_10'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(key('invoice_line_remove_dialog'), findsNothing);
      verifyNever(() => h.documents.removeLine(any(), any()));
    });
  });

  testWidgets('the compact tier shows the row actions on the cards', (
    tester,
  ) async {
    await h.pump(tester, surface: const Size(400, 900));

    expect(key('fiscal_document_line_edit_10'), findsOneWidget);
    expect(key('fiscal_document_line_remove_10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
