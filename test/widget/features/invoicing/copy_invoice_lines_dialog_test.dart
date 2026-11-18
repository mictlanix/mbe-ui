import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

/// Spec 073 US2, contract C29: "Agregar de la factura".
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.one);
  });

  setUp(() => h = InvoiceHarness());

  /// Invoice 12: a tornillo (10 at 150, no discount) and a cemento (4 at 210
  /// with 5 % off), as in the wireframe.
  FiscalDocument invoice({List<InvoiceLine>? lines}) => aDocument(
    id: 12,
    status: FiscalDocumentStatus.issued,
    serial: 12,
    series: 'GR',
    stamp: aStamp(),
    lines:
        lines ??
        [
          anInvoiceLine(
            id: 31,
            quantity: '10',
            price: '150',
            productCode: 'TOR-12',
            productName: 'Tornillo 1/2 caja',
          ),
          anInvoiceLine(
            id: 32,
            quantity: '4',
            price: '210',
            productCode: 'CEM-50',
            productName: 'Cemento gris',
            discountRate: '5',
          ),
        ],
  );

  void stubCopies() => when(
    () =>
        h.documents.copyInvoiceLine(7, any(), quantity: any(named: 'quantity')),
  ).thenAnswer((_) async => aCreditNote());

  Future<void> open(
    WidgetTester tester, {
    FutureOr<FiscalDocument> Function()? load,
    Size surface = const Size(1400, 1000),
  }) async {
    await h.pump(tester, document: aCreditNote(), surface: surface);
    when(
      () => h.documents.getById(12),
    ).thenAnswer((_) async => load == null ? invoice() : await load());
    await tester.ensureVisible(key('fiscal_document_copy_invoice_lines'));
    await tester.pumpAndSettle();
    await tester.tap(key('fiscal_document_copy_invoice_lines'));
    await tester.pumpAndSettle();
  }

  bool enabled(WidgetTester tester, String k) =>
      tester.widget<ButtonStyleButton>(key(k)).onPressed != null;

  String fieldText(WidgetTester tester, String k) =>
      tester.widget<TextField>(key(k)).controller!.text;

  Future<void> check(WidgetTester tester, int line) async {
    await tester.tap(key('copy_invoice_line_check_$line'));
    await tester.pumpAndSettle();
  }

  group('the rows', () {
    testWidgets('list every line of the credited invoice, unchecked, with '
        'their fields off', (tester) async {
      await open(tester);

      expect(key('copy_invoice_lines_dialog'), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLinesTitle('GR12')),
        findsOneWidget,
      );
      expect(key('copy_invoice_line_31'), findsOneWidget);
      expect(key('copy_invoice_line_32'), findsOneWidget);
      expect(find.text('TOR-12'), findsOneWidget);
      expect(find.text('Cemento gris'), findsOneWidget);
      expect(
        tester.widget<TextField>(key('copy_invoice_line_qty_31')).enabled,
        isFalse,
      );
      expect(enabled(tester, 'copy_invoice_lines_submit'), isFalse);
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLinesSubmit(0)),
        findsOneWidget,
      );
    });

    testWidgets('checking a row enables its field at the invoiced quantity', (
      tester,
    ) async {
      await open(tester);

      await check(tester, 31);

      expect(
        tester.widget<TextField>(key('copy_invoice_line_qty_31')).enabled,
        isTrue,
      );
      expect(fieldText(tester, 'copy_invoice_line_qty_31'), '10');
      expect(
        tester.widget<TextField>(key('copy_invoice_line_qty_32')).enabled,
        isFalse,
      );
      expect(enabled(tester, 'copy_invoice_lines_submit'), isTrue);
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLinesSubmit(1)),
        findsOneWidget,
      );
    });

    testWidgets('a quantity above the invoiced one, or 0 or less, shows its '
        'text and blocks Agregar', (tester) async {
      await open(tester);
      await check(tester, 31);

      await tester.enterText(key('copy_invoice_line_qty_31'), '11');
      await tester.pump();
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLineMax('10')),
        findsOneWidget,
      );
      expect(enabled(tester, 'copy_invoice_lines_submit'), isFalse);

      await tester.enterText(key('copy_invoice_line_qty_31'), '0');
      await tester.pump();
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLineQtyPositive),
        findsOneWidget,
      );
      expect(enabled(tester, 'copy_invoice_lines_submit'), isFalse);

      await tester.enterText(key('copy_invoice_line_qty_31'), '10');
      await tester.pump();
      expect(find.byKey(const Key('copy_invoice_line_error_31')), findsNothing);
      expect(enabled(tester, 'copy_invoice_lines_submit'), isTrue);
    });

    testWidgets('an invalid row that is not checked does not block Agregar', (
      tester,
    ) async {
      await open(tester);
      await check(tester, 31);
      await check(tester, 32);
      await tester.enterText(key('copy_invoice_line_qty_32'), '9');
      await tester.pump();
      expect(enabled(tester, 'copy_invoice_lines_submit'), isFalse);

      await check(tester, 32);

      expect(enabled(tester, 'copy_invoice_lines_submit'), isTrue);
    });
  });

  group('sending', () {
    testWidgets('two checked lines go as two requests, in the invoice order, '
        'and the dialog closes', (tester) async {
      stubCopies();
      await open(tester);
      // Checked in reverse; they still go in the invoice's order.
      await check(tester, 32);
      await check(tester, 31);
      await tester.enterText(key('copy_invoice_line_qty_31'), '2');
      await tester.pump();

      await tester.tap(key('copy_invoice_lines_submit'));
      await tester.pumpAndSettle();

      verifyInOrder([
        () => h.documents.copyInvoiceLine(7, 31, quantity: Decimal.fromInt(2)),
        () => h.documents.copyInvoiceLine(7, 32, quantity: Decimal.fromInt(4)),
      ]);
      verifyNever(
        () => h.documents.copyInvoiceLine(
          7,
          any(that: isNot(anyOf(31, 32))),
          quantity: any(named: 'quantity'),
        ),
      );
      expect(key('copy_invoice_lines_dialog'), findsNothing);
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLinesDone(2)),
        findsOneWidget,
      );
    });

    testWidgets('a refusal on the second line keeps the dialog open, marks '
        'the first added and names the failed line', (tester) async {
      when(
        () => h.documents.copyInvoiceLine(
          7,
          31,
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => aCreditNote());
      when(
        () => h.documents.copyInvoiceLine(
          7,
          32,
          quantity: any(named: 'quantity'),
        ),
      ).thenThrow(
        AppError.server(
          statusCode: 422,
          problem: ApiProblem(
            codeName: 'fiscal_document.invoice_not_creditable',
            code: api.ErrorCode.fiscalDocumentPeriodInvoiceNotCreditable,
            params: const {'invoice_id': 12},
          ),
        ),
      );
      await open(tester);
      await check(tester, 31);
      await check(tester, 32);

      await tester.tap(key('copy_invoice_lines_submit'));
      await tester.pumpAndSettle();

      expect(key('copy_invoice_lines_dialog'), findsOneWidget);
      expect(
        find.text(
          l10n.fiscalDocumentCopyInvoiceLineFailed(
            'CEM-50',
            l10n.apiErrorFiscalDocumentInvoiceNotCreditable,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLineAdded),
        findsOneWidget,
      );
      expect(
        tester.widget<Checkbox>(key('copy_invoice_line_check_31')).value,
        isFalse,
      );
      expect(
        tester.widget<Checkbox>(key('copy_invoice_line_check_31')).onChanged,
        isNull,
      );
      // The failed line stays checked, so it can be fixed and sent again.
      expect(
        tester.widget<Checkbox>(key('copy_invoice_line_check_32')).value,
        isTrue,
      );

      // Closing after a partial run still reports what was added.
      await tester.tap(key('copy_invoice_lines_cancel'));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLinesDone(1)),
        findsOneWidget,
      );
    });

    testWidgets('the buttons are off while it runs', (tester) async {
      final gate = Completer<FiscalDocument>();
      when(
        () => h.documents.copyInvoiceLine(
          7,
          any(),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) => gate.future);
      await open(tester);
      await check(tester, 31);

      await tester.tap(key('copy_invoice_lines_submit'));
      await tester.pump();

      expect(enabled(tester, 'copy_invoice_lines_submit'), isFalse);
      expect(enabled(tester, 'copy_invoice_lines_cancel'), isFalse);

      gate.complete(aCreditNote());
      await tester.pumpAndSettle();
    });
  });

  group('the invoice', () {
    testWidgets('that fails to load offers retry', (tester) async {
      var attempts = 0;
      await open(
        tester,
        load: () {
          attempts++;
          if (attempts == 1) throw const AppError.server();
          return invoice();
        },
      );

      expect(find.text(l10n.retryButton), findsOneWidget);
      expect(key('copy_invoice_line_31'), findsNothing);

      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(key('copy_invoice_line_31'), findsOneWidget);
    });

    testWidgets('with no lines says so', (tester) async {
      await open(tester, load: () => invoice(lines: const []));

      expect(key('copy_invoice_lines_empty'), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentCopyInvoiceLinesEmpty),
        findsOneWidget,
      );
    });
  });

  testWidgets('the compact tier shows each line as a card, and the field only '
      'on a checked one', (tester) async {
    await open(tester, surface: const Size(400, 900));

    expect(find.byType(Card), findsNWidgets(2));
    expect(key('copy_invoice_line_qty_31'), findsNothing);

    await check(tester, 31);

    expect(key('copy_invoice_line_qty_31'), findsOneWidget);
    expect(key('copy_invoice_line_qty_32'), findsNothing);
    expect(fieldText(tester, 'copy_invoice_line_qty_31'), '10');
  });

  group('the control band (constitution §VI)', () {
    double baselineY(WidgetTester tester, Finder finder) {
      final box = tester.renderObject<RenderBox>(finder);
      return box.localToGlobal(Offset.zero).dy +
          box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
    }

    testWidgets('has equal padding above and below its controls, and the text '
        'and the quantity field share a baseline', (tester) async {
      await open(tester);
      await check(tester, 31);

      final band = tester.getRect(key('copy_invoice_line_band_31'));
      final box = tester.getRect(key('copy_invoice_line_check_31'));
      final field = tester.getRect(key('copy_invoice_line_qty_31'));
      final top = [box.top, field.top].reduce((a, b) => a < b ? a : b);
      final bottom = [box.bottom, field.bottom].reduce((a, b) => a > b ? a : b);
      expect(top - band.top, greaterThan(0));
      expect(top - band.top, closeTo(band.bottom - bottom, 0.5));

      final text = find.descendant(
        of: key('copy_invoice_line_31'),
        matching: find.text('Tornillo 1/2 caja'),
      );
      final input = find.descendant(
        of: key('copy_invoice_line_qty_31'),
        matching: find.byType(InputDecorator),
      );
      expect(baselineY(tester, text), closeTo(baselineY(tester, input), 0.5));
      // The checkbox is centred on the band, not on the text.
      expect(box.center.dy, closeTo(band.center.dy, 0.5));
    });
  });
}
