import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_completed_dialog.dart';

import '../../../unit/core/documents/document_fakes.dart';
import 'pos_test_harness.dart';

/// Spec 044 US1: the "Venta completada" dialog prints the ticket in one press.
void main() {
  late FakeDocumentSource source;
  late FakeDocumentOutput output;
  late int newSaleCalls;

  setUp(() {
    source = FakeDocumentSource();
    output = FakeDocumentOutput();
    newSaleCalls = 0;
  });

  List<Override> overridesFor(user) => [
    accessControlProvider.overrideWithValue(accessFor(user)),
    documentSourceProvider.overrideWithValue(source),
    documentOutputProvider.overrideWithValue(output),
  ];

  /// Opens the dialog the way `_finish` does, over a launcher button.
  Future<void> openDialog(
    WidgetTester tester, {
    required user,
    int? saleId = 42,
  }) async {
    await pumpPos(
      tester,
      Builder(
        builder: (context) => Center(
          child: TextButton(
            key: const Key('open_dialog'),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => PosSaleCompletedDialog(
                saleId: saleId,
                reference: '1234',
                onNewSale: () {
                  Navigator.of(dialogContext).pop();
                  newSaleCalls++;
                },
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
      overrides: overridesFor(user),
    );
    await tester.tap(find.byKey(const Key('open_dialog')));
    await tester.pumpAndSettle();
  }

  final printButton = find.byKey(const Key('print_ticket_button'));
  final newSaleButton = find.byKey(const Key('start_new_sale_button'));

  testWidgets('offers "Imprimir ticket" as a secondary action before '
      '"Nueva venta", which stays the primary one (FR-002)', (tester) async {
    await openDialog(tester, user: salesOrdersReader);

    expect(find.text('Venta completada'), findsOneWidget);
    expect(find.text('Imprimir ticket'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is OutlinedButton && w.key == const Key('print_ticket_button'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is FilledButton && w.key == const Key('start_new_sale_button'),
      ),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(printButton).dx,
      lessThan(tester.getTopLeft(newSaleButton).dx),
    );
  });

  testWidgets('is absent for a user without sales-orders read (FR-040)', (
    tester,
  ) async {
    await openDialog(tester, user: posReader);

    expect(printButton, findsNothing);
    expect(newSaleButton, findsOneWidget);
  });

  testWidgets('is absent when the sale has no id yet', (tester) async {
    await openDialog(tester, user: salesOrdersReader, saleId: null);

    expect(printButton, findsNothing);
  });

  testWidgets('one press fetches that sale\'s ticket and prints it, with no '
      'preview, leaving the dialog open (US1-1, US1-2)', (tester) async {
    await openDialog(tester, user: salesOrdersReader);

    await tester.tap(printButton);
    await tester.pumpAndSettle();

    expect(source.fetched, hasLength(1));
    expect(source.fetched.single.kind, DocumentKind.saleTicket);
    expect(source.fetched.single.recordId, 42);
    expect(source.fetched.single.title, 'Ticket · Folio #1234');
    expect(output.printed, hasLength(1));
    expect(output.rastered, isEmpty, reason: 'no preview on this path');
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(newSaleCalls, 0);
  });

  testWidgets('shows progress and ignores a second press while fetching '
      '(US1-3, FR-032)', (tester) async {
    final gate = Completer<void>();
    source.handler = (ref) async {
      await gate.future;
      return fakeDocument();
    };
    await openDialog(tester, user: salesOrdersReader);

    await tester.tap(printButton);
    await tester.pump();

    expect(
      find.descendant(
        of: printButton,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(tester.widget<OutlinedButton>(printButton).onPressed, isNull);
    await tester.tap(printButton, warnIfMissed: false);
    await tester.pump();
    expect(source.fetched, hasLength(1));
    // "Nueva venta" is not held up by it.
    expect(tester.widget<FilledButton>(newSaleButton).onPressed, isNotNull);

    gate.complete();
    await tester.pumpAndSettle();

    expect(output.printed, hasLength(1));
    expect(tester.widget<OutlinedButton>(printButton).onPressed, isNotNull);
  });

  testWidgets('a failure shows the server\'s reason, offers retry, and still '
      'lets the cashier start a new sale (US1-4)', (tester) async {
    var attempts = 0;
    source.handler = (ref) async {
      attempts++;
      if (attempts == 1) {
        throw const AppError.notFound('Sales order not found');
      }
      return fakeDocument();
    };
    await openDialog(tester, user: salesOrdersReader);

    await tester.tap(printButton);
    await tester.pumpAndSettle();

    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.text('Sales order not found'), findsOneWidget);
    expect(find.text('No se pudo imprimir el ticket.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Imprimir ticket'), findsNothing);
    expect(output.printed, isEmpty);

    // Retry succeeds, and the error clears.
    await tester.tap(printButton);
    await tester.pumpAndSettle();

    expect(output.printed, hasLength(1));
    expect(find.byType(ErrorBanner), findsNothing);
    expect(find.text('Imprimir ticket'), findsOneWidget);
  });

  testWidgets('"Nueva venta" starts the next sale and closes the dialog', (
    tester,
  ) async {
    await openDialog(tester, user: salesOrdersReader);

    await tester.tap(newSaleButton);
    await tester.pumpAndSettle();

    expect(newSaleCalls, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('a platform failure while printing is shown as a generic '
      'error, not thrown', (tester) async {
    output.printHandler = (document) async => throw StateError('no printer');
    await openDialog(tester, user: salesOrdersReader);

    await tester.tap(printButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorBanner), findsOneWidget);
  });
}
