import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';
import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US1 (T013): an order's detail, read-only; US2 (T022): the draft
/// actions and Confirmar; US3 (T024): the confirmed columns; US4 (T029):
/// Imprimir and Enviar por correo; US5 (T033): Editar encabezado, ✎ 🗑 and
/// Cancelar orden.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  final buyer = PurchasesHarness.user(requestRights: 2, orderRights: 15);

  testWidgets('a draft shows its title, facts, totals and lines', (
    tester,
  ) async {
    await h.pumpOrder(
      tester,
      anOrder(
        estimatedReceiptDate: DateTime(2026, 12, 5),
        lines: [
          anOrderLine(),
          anOrderLine(
            id: 901,
            code: 'B-220',
            name: 'Taquete 5/16',
            warehouseId: 4,
          ),
        ],
      ).copyWith(comment: 'Entregar en andén 2'),
      who: buyer,
    );

    expect(find.text(l10n.purchaseOrderTitle('310')), findsOneWidget);
    expect(find.text(l10n.inventoryDocumentStatusDraft), findsOneWidget);
    expect(find.text('Ferretera del Norte'), findsOneWidget);
    expect(find.text('2026-12-05'), findsOneWidget);
    expect(find.text('Entregar en andén 2'), findsOneWidget);
    expect(find.text('Empleado 5'), findsOneWidget);
    expect(find.text('A-100'), findsOneWidget);
    expect(find.text('Taquete 5/16'), findsOneWidget);
    expect(find.text('Almacén 3'), findsOneWidget);
    expect(find.text('Almacén 4'), findsOneWidget);
    for (final header in [
      l10n.purchaseOrderLineColCode,
      l10n.purchaseOrderLineColProduct,
      l10n.purchaseOrderLineColWarehouse,
      l10n.purchaseOrderLineColQuantity,
      l10n.purchaseOrderLineColPrice,
      l10n.purchaseOrderLineColAmount,
    ]) {
      expect(find.text(header), findsWidgets);
    }
    expect(
      tester.widget<Text>(key('purchase_order_line_quantity_900')).data,
      '8',
    );
    expect(
      tester.widget<Text>(key('purchase_order_line_price_900')).data,
      contains('125.00'),
    );
    expect(
      tester.widget<Text>(key('purchase_order_line_amount_900')).data,
      contains('1,000.00'),
    );
    expect(
      tester.widget<Text>(key('purchase_order_line_tax_900')).data,
      contains('16'),
    );
    expect(
      tester.widget<Text>(key('purchase_order_total')).data,
      contains('1,160.00'),
    );
    expect(
      tester.widget<Text>(key('purchase_order_subtotal')).data,
      contains('1,000.00'),
    );
    expect(
      tester.widget<Text>(key('purchase_order_tax')).data,
      contains('160.00'),
    );
    expect(key('order_warnings_band'), findsNothing);
  });

  testWidgets('the AppBar has no actions', (tester) async {
    await h.pumpOrder(tester, anOrder(), who: buyer);

    expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isNull);
  });

  testWidgets('a zero-priced line shows the price-0 band', (tester) async {
    await h.pumpOrder(
      tester,
      anOrder(
        lines: [
          anOrderLine(),
          anOrderLine(id: 901, code: 'C-007', name: 'Rondana', price: '0'),
        ],
      ),
      who: buyer,
    );

    expect(key('order_warnings_band'), findsOneWidget);
    expect(
      find.text(l10n.purchaseOrderZeroPriceWarning('C-007', 'Rondana')),
      findsOneWidget,
    );
  });

  testWidgets('a line from a request shows its folio under the product', (
    tester,
  ) async {
    when(
      () => h.requests.get(212),
    ).thenAnswer((_) async => aRequest(serial: 571));

    await h.pumpOrder(
      tester,
      anOrder(lines: [anOrderLine(requestId: 212)]),
      who: buyer,
    );

    expect(
      tester.widget<Text>(key('purchase_order_line_request_900')).data,
      l10n.purchaseOrderLineRequest('571'),
    );
  });

  testWidgets("a request whose folio can't be read shows its id", (
    tester,
  ) async {
    when(
      () => h.requests.get(212),
    ).thenAnswer((_) async => throw const AppError.auth());

    await h.pumpOrder(
      tester,
      anOrder(lines: [anOrderLine(requestId: 212)]),
      who: buyer,
    );

    expect(
      tester.widget<Text>(key('purchase_order_line_request_900')).data,
      l10n.purchaseOrderLineRequest('#212'),
    );
  });

  testWidgets('a request whose folio failed to load shows its id', (
    tester,
  ) async {
    when(
      () => h.requests.get(212),
    ).thenAnswer((_) async => throw const AppError.network());

    await h.pumpOrder(
      tester,
      anOrder(lines: [anOrderLine(requestId: 212)]),
      who: buyer,
    );

    expect(
      tester.widget<Text>(key('purchase_order_line_request_900')).data,
      l10n.purchaseOrderLineRequest('#212'),
    );
  });

  testWidgets('an empty draft says how to add lines', (tester) async {
    await h.pumpOrder(tester, anOrder(lines: const []), who: buyer);

    expect(key('purchase_order_lines_empty'), findsOneWidget);
    expect(find.text(l10n.purchaseOrderLinesEmpty), findsOneWidget);
    expect(key('purchase_order_lines_table'), findsNothing);
    expect(key('purchase_order_totals'), findsOneWidget);
  });

  testWidgets('shows progress while the order loads', (tester) async {
    final reply = Completer<PurchaseOrder>();
    when(() => h.orders.get(310)).thenAnswer((_) => reply.future);

    await h.pump(
      tester,
      who: buyer,
      location: '/purchases/orders/310',
      settle: false,
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    reply.complete(anOrder());
    await tester.pumpAndSettle();
    expect(find.text(l10n.purchaseOrderTitle('310')), findsOneWidget);
  });

  testWidgets('a failed load shows the error and retries', (tester) async {
    var calls = 0;
    when(() => h.orders.get(310)).thenAnswer((_) async {
      if (calls++ == 0) throw const AppError.network();
      return anOrder();
    });

    await h.pump(tester, who: buyer, location: '/purchases/orders/310');

    expect(key('purchase_order_load_failed'), findsOneWidget);
    await tester.tap(key('purchase_order_retry_button'));
    await tester.pumpAndSettle();
    expect(key('purchase_order_lines_table'), findsOneWidget);
  });

  testWidgets('a missing order shows the not-found state', (tester) async {
    when(() => h.orders.get(99)).thenThrow(const AppError.notFound());

    await h.pump(tester, who: buyer, location: '/purchases/orders/99');

    expect(key('purchase_order_not_found'), findsOneWidget);
  });

  testWidgets('a non-numeric id shows the not-found state', (tester) async {
    await h.pump(tester, who: buyer, location: '/purchases/orders/abc');

    expect(key('purchase_order_not_found'), findsOneWidget);
  });

  group('draft actions (T022)', () {
    const addRequest = 'purchase_order_add_request';
    const addProduct = 'purchase_order_add_product';
    const confirm = 'purchase_order_confirm';

    testWidgets('a draft shows Agregar solicitud, Agregar producto and '
        'Confirmar last', (tester) async {
      await h.pumpOrder(tester, anOrder(), who: buyer);

      expect(key(addRequest), findsOneWidget);
      expect(key(addProduct), findsOneWidget);
      expect(key(confirm), findsOneWidget);
      final buttons = tester
          .widget<Wrap>(
            find.descendant(
              of: key('purchase_order_actions'),
              matching: find.byType(Wrap),
            ),
          )
          .children;
      expect(buttons.last.key, const Key(confirm));
      expect(tester.widget<FilledButton>(key(confirm)).onPressed, isNotNull);
    });

    testWidgets('without update on 20 there are no actions', (tester) async {
      await h.pumpOrder(
        tester,
        anOrder(),
        who: PurchasesHarness.user(requestRights: 2, orderRights: 2),
      );

      expect(key('purchase_order_actions'), findsNothing);
      expect(key(addRequest), findsNothing);
      expect(key(addProduct), findsNothing);
      expect(key(confirm), findsNothing);
    });

    testWidgets('Agregar solicitud needs PurchaseRequest (86) read', (
      tester,
    ) async {
      await h.pumpOrder(
        tester,
        anOrder(),
        who: PurchasesHarness.user(requestRights: 0, orderRights: 15),
      );

      expect(key(addRequest), findsNothing);
      expect(key(addProduct), findsOneWidget);
      expect(key(confirm), findsOneWidget);
    });

    testWidgets('Agregar producto needs Products read', (tester) async {
      await h.pumpOrder(
        tester,
        anOrder(),
        who: PurchasesHarness.user(
          requestRights: 2,
          orderRights: 15,
          productsRead: false,
        ),
      );

      expect(key(addProduct), findsNothing);
      expect(key(addRequest), findsOneWidget);
    });

    for (final status in [
      InventoryDocumentStatus.completed,
      InventoryDocumentStatus.cancelled,
    ]) {
      testWidgets('a ${status.name} order has none of them', (tester) async {
        await h.pumpOrder(tester, anOrder(status: status), who: buyer);

        expect(key(addRequest), findsNothing);
        expect(key(addProduct), findsNothing);
        expect(key(confirm), findsNothing);
      });
    }

    testWidgets('Confirmar is disabled on an empty draft, saying why', (
      tester,
    ) async {
      await h.pumpOrder(tester, anOrder(lines: const []), who: buyer);

      expect(tester.widget<FilledButton>(key(confirm)).onPressed, isNull);
      expect(
        find.ancestor(of: key(confirm), matching: find.byType(Tooltip)),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Tooltip>(
              find.ancestor(of: key(confirm), matching: find.byType(Tooltip)),
            )
            .message,
        l10n.purchaseOrderConfirmNoLinesTooltip,
      );
    });

    testWidgets('confirming shows the order confirmed with its receipts and '
        'says how many were created', (tester) async {
      when(() => h.orders.confirm(310)).thenAnswer(
        (_) async => anOrder(
          status: InventoryDocumentStatus.completed,
          receipts: [aReceipt(id: 8812), aReceipt(id: 8813, warehouseId: 4)],
        ),
      );
      await h.pumpOrder(tester, anOrder(), who: buyer);

      await tester.tap(key(confirm));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_order_confirm_submit'));
      await tester.pumpAndSettle();

      verify(() => h.orders.confirm(310)).called(1);
      expect(find.text(l10n.purchaseOrderConfirmedSnack(2)), findsOneWidget);
      expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
      expect(key('purchase_order_receipts'), findsOneWidget);
      expect(key('purchase_order_receipt_8812'), findsOneWidget);
      expect(key('purchase_order_receipt_8813'), findsOneWidget);
      expect(key(confirm), findsNothing);
    });

    for (final (codeName, code, message) in [
      (
        'purchase_order.no_supplier',
        api.ErrorCode.purchaseOrderPeriodNoSupplier,
        (AppLocalizations l) => l.apiErrorPurchaseOrderNoSupplier,
      ),
      (
        'purchase_order.line_without_quantity',
        api.ErrorCode.purchaseOrderPeriodLineWithoutQuantity,
        (AppLocalizations l) => l.apiErrorPurchaseOrderLineWithoutQuantity,
      ),
    ]) {
      testWidgets('a $codeName refusal shows above the actions, localized', (
        tester,
      ) async {
        when(
          () => h.orders.confirm(310),
        ).thenAnswer((_) async => throw aRefusal(code, codeName));
        await h.pumpOrder(tester, anOrder(), who: buyer);

        await tester.tap(key(confirm));
        await tester.pumpAndSettle();
        await tester.tap(key('purchase_order_confirm_submit'));
        await tester.pumpAndSettle();

        expect(key('purchase_order_refusal'), findsOneWidget);
        expect(
          find.descendant(
            of: key('purchase_order_refusal'),
            matching: find.text(message(l10n)),
          ),
          findsOneWidget,
        );
        expect(find.text('SERVER TEXT'), findsNothing);
        expect(key(confirm), findsOneWidget);
        verify(() => h.orders.get(310)).called(1);
      });
    }

    testWidgets('a stale refusal reloads the order', (tester) async {
      var loads = 0;
      when(() => h.orders.get(310)).thenAnswer(
        (_) async => loads++ == 0
            ? anOrder()
            : anOrder(status: InventoryDocumentStatus.completed),
      );
      when(() => h.orders.confirm(310)).thenAnswer(
        (_) async => throw aRefusal(
          api.ErrorCode.documentPeriodNotEditable,
          'document.not_editable',
        ),
      );
      await h.pump(tester, who: buyer, location: '/purchases/orders/310');

      await tester.tap(key(confirm));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_order_confirm_submit'));
      await tester.pumpAndSettle();

      expect(loads, 2);
      expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
      expect(key(confirm), findsNothing);
      expect(key('purchase_order_refusal'), findsOneWidget);
    });
  });

  group('confirmed columns (T024)', () {
    testWidgets('a confirmed order partly received shows Recibido and '
        'Pendiente in place of Precio and IVA', (tester) async {
      await h.pumpOrder(
        tester,
        anOrder(
          status: InventoryDocumentStatus.completed,
          lines: [
            anOrderLine(quantity: '12', received: '12', pending: '0'),
            anOrderLine(
              id: 901,
              code: 'B-220',
              quantity: '24',
              received: '5',
              pending: '19',
            ),
          ],
        ),
        who: buyer,
      );

      expect(find.text(l10n.purchaseOrderLineColReceived), findsWidgets);
      expect(find.text(l10n.purchaseOrderLineColPending), findsWidgets);
      expect(find.text(l10n.purchaseOrderLineColPrice), findsNothing);
      expect(key('purchase_order_line_price_900'), findsNothing);
      expect(key('purchase_order_line_tax_900'), findsNothing);
      expect(
        tester.widget<Text>(key('purchase_order_line_received_901')).data,
        '5',
      );
      expect(
        tester.widget<Text>(key('purchase_order_line_pending_901')).data,
        '19',
      );
      expect(
        tester.widget<Text>(key('purchase_order_line_pending_900')).data,
        '0',
      );
      expect(key('purchase_order_line_amount_901'), findsOneWidget);
    });

    testWidgets('a non-stockable line shows "—" for received and pending', (
      tester,
    ) async {
      await h.pumpOrder(
        tester,
        anOrder(
          status: InventoryDocumentStatus.completed,
          lines: [anOrderLine(code: 'S-001', name: 'Flete (servicio)')],
        ),
        who: buyer,
      );

      expect(
        tester.widget<Text>(key('purchase_order_line_received_900')).data,
        '—',
      );
      expect(
        tester.widget<Text>(key('purchase_order_line_pending_900')).data,
        '—',
      );
    });

    testWidgets('a cancelled order keeps the draft columns and its lines, '
        'read-only', (tester) async {
      await h.pumpOrder(
        tester,
        anOrder(
          status: InventoryDocumentStatus.cancelled,
          lines: [
            anOrderLine(),
            anOrderLine(id: 901, code: 'B-220'),
          ],
        ),
        who: buyer,
      );

      expect(find.text(l10n.purchaseOrderLineColPrice), findsWidgets);
      expect(key('purchase_order_line_price_900'), findsOneWidget);
      expect(key('purchase_order_line_tax_901'), findsOneWidget);
      expect(find.text(l10n.purchaseOrderLineColReceived), findsNothing);
      expect(key('purchase_order_line_received_900'), findsNothing);
      expect(key('purchase_order_actions'), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });
  });

  group('Imprimir and Enviar por correo (T029)', () {
    late FakeDocumentSource source;

    setUp(() => source = FakeDocumentSource());

    List<Override> documents() => [
      documentSourceProvider.overrideWithValue(source),
      documentOutputProvider.overrideWithValue(FakeDocumentOutput()),
    ];

    final confirmed = anOrder(status: InventoryDocumentStatus.completed);
    const print = 'purchase_order_print';
    const email = 'purchase_order_email';

    testWidgets('a confirmed order offers both with read and update on 20', (
      tester,
    ) async {
      await h.pumpOrder(tester, confirmed, who: buyer);

      expect(key(email), findsOneWidget);
      expect(key(print), findsOneWidget);
    });

    testWidgets('with read only on 20 there is Imprimir, not the email', (
      tester,
    ) async {
      await h.pumpOrder(
        tester,
        confirmed,
        who: PurchasesHarness.user(requestRights: 0, orderRights: 2),
      );

      expect(key(print), findsOneWidget);
      expect(key(email), findsNothing);
    });

    for (final status in [
      InventoryDocumentStatus.draft,
      InventoryDocumentStatus.cancelled,
    ]) {
      testWidgets('a ${status.name} order has neither', (tester) async {
        await h.pumpOrder(tester, anOrder(status: status), who: buyer);

        expect(key(print), findsNothing);
        expect(key(email), findsNothing);
      });
    }

    testWidgets('Imprimir opens the order document in the preview', (
      tester,
    ) async {
      await h.pumpOrder(
        tester,
        confirmed,
        who: buyer,
        extraOverrides: documents(),
      );

      await tester.tap(key(print));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched.single.kind, DocumentKind.purchaseOrder);
      expect(source.fetched.single.recordId, 310);
      expect(source.fetched.single.title, l10n.purchaseOrderTitle('310'));
    });

    testWidgets('Enviar por correo opens the email dialog', (tester) async {
      await h.pumpOrder(tester, confirmed, who: buyer);

      await tester.tap(key(email));
      await tester.pumpAndSettle();

      expect(key('purchase_order_email_dialog'), findsOneWidget);
      expect(find.text(l10n.purchaseOrderEmailTitle('310')), findsOneWidget);
    });
  });

  group('edit and cancel (T033)', () {
    const cancel = 'purchase_order_cancel';
    const editHeader = 'purchase_order_edit_header';
    const editLine = 'purchase_order_line_edit_900';
    const removeLine = 'purchase_order_line_remove_900';

    final editor = PurchasesHarness.user(
      requestRights: 2,
      orderRights: 15,
      suppliersRead: true,
    );

    testWidgets('a draft offers Cancelar orden first, Editar encabezado, '
        'and ✎ 🗑 on each line', (tester) async {
      await h.pumpOrder(tester, anOrder(), who: editor);

      expect(key(editHeader), findsOneWidget);
      expect(key(editLine), findsOneWidget);
      expect(key(removeLine), findsOneWidget);
      final buttons = tester
          .widget<Wrap>(
            find.descendant(
              of: key('purchase_order_actions'),
              matching: find.byType(Wrap),
            ),
          )
          .children;
      expect(buttons.first.key, const Key(cancel));
      expect(buttons[1].key, const Key(editHeader));
    });

    testWidgets('Editar encabezado needs Suppliers read', (tester) async {
      await h.pumpOrder(tester, anOrder(), who: buyer);

      expect(key(editHeader), findsNothing);
      expect(key(cancel), findsOneWidget);
    });

    testWidgets('Cancelar orden needs delete on 20', (tester) async {
      await h.pumpOrder(
        tester,
        anOrder(),
        who: PurchasesHarness.user(
          requestRights: 2,
          orderRights: 7,
          suppliersRead: true,
        ),
      );

      expect(key(cancel), findsNothing);
      expect(key(editHeader), findsOneWidget);
      expect(key(editLine), findsOneWidget);
    });

    testWidgets('✎ needs Warehouses read; 🗑 does not', (tester) async {
      await h.pumpOrder(
        tester,
        anOrder(),
        who: PurchasesHarness.user(
          requestRights: 2,
          orderRights: 15,
          warehousesRead: false,
        ),
      );

      expect(key(editLine), findsNothing);
      expect(key(removeLine), findsOneWidget);
    });

    testWidgets('without update on 20 the lines are read-only', (tester) async {
      await h.pumpOrder(
        tester,
        anOrder(),
        who: PurchasesHarness.user(
          requestRights: 2,
          orderRights: 2,
          suppliersRead: true,
        ),
      );

      expect(key(editHeader), findsNothing);
      expect(key(editLine), findsNothing);
      expect(key(removeLine), findsNothing);
    });

    for (final status in [
      InventoryDocumentStatus.completed,
      InventoryDocumentStatus.cancelled,
    ]) {
      testWidgets('a ${status.name} order offers none of them', (tester) async {
        await h.pumpOrder(tester, anOrder(status: status), who: editor);

        expect(key(cancel), findsNothing);
        expect(key(editHeader), findsNothing);
        expect(key(editLine), findsNothing);
        expect(key(removeLine), findsNothing);
      });
    }

    testWidgets('editing the header shows the new notes', (tester) async {
      when(
        () => h.orders.updateHeader(
          310,
          supplierId: any(named: 'supplierId'),
          estimatedReceiptDate: any(named: 'estimatedReceiptDate'),
          clearDate: any(named: 'clearDate'),
          comment: any(named: 'comment'),
          clearComment: any(named: 'clearComment'),
        ),
      ).thenAnswer((_) async => anOrder().copyWith(comment: 'Por la tarde'));
      await h.pumpOrder(tester, anOrder(), who: editor);

      await tester.tap(key(editHeader));
      await tester.pumpAndSettle();
      await tester.enterText(
        key('purchase_order_header_comment'),
        'Por la tarde',
      );
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_order_header_submit'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(key('purchase_order_comment')).data,
        'Por la tarde',
      );
    });

    testWidgets('editing a line shows the new quantity and totals', (
      tester,
    ) async {
      when(
        () => h.orders.updateLine(
          310,
          900,
          quantity: any(named: 'quantity'),
          warehouseId: any(named: 'warehouseId'),
          price: any(named: 'price'),
          taxRate: any(named: 'taxRate'),
        ),
      ).thenAnswer(
        (_) async => anOrder(lines: [anOrderLine(quantity: '10')]).copyWith(
          subtotal: Decimal.parse('1250.00'),
          tax: Decimal.parse('200.00'),
          total: Decimal.parse('1450.00'),
        ),
      );
      await h.pumpOrder(tester, anOrder(), who: editor);

      await tester.tap(key(editLine));
      await tester.pumpAndSettle();
      await tester.enterText(key('order_line_quantity'), '10');
      await tester.pumpAndSettle();
      await tester.tap(key('order_line_submit'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(key('purchase_order_line_quantity_900')).data,
        '10',
      );
      expect(
        tester.widget<Text>(key('purchase_order_total')).data,
        contains('1,450.00'),
      );
    });

    testWidgets('removing a line drops it and updates the totals', (
      tester,
    ) async {
      when(() => h.orders.removeLine(310, 900)).thenAnswer(
        (_) async => anOrder(lines: [anOrderLine(id: 901)]).copyWith(
          subtotal: Decimal.parse('500.00'),
          tax: Decimal.parse('80.00'),
          total: Decimal.parse('580.00'),
        ),
      );
      await h.pumpOrder(
        tester,
        anOrder(lines: [anOrderLine(), anOrderLine(id: 901)]),
        who: editor,
      );

      await tester.tap(key(removeLine));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_order_line_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.orders.removeLine(310, 900)).called(1);
      expect(key('purchase_order_line_quantity_900'), findsNothing);
      expect(key('purchase_order_line_quantity_901'), findsOneWidget);
      expect(
        tester.widget<Text>(key('purchase_order_total')).data,
        contains('580.00'),
      );
    });

    testWidgets('cancelling leaves the order cancelled and read-only, with '
        'its lines', (tester) async {
      when(() => h.orders.cancel(310)).thenAnswer(
        (_) async => anOrder(status: InventoryDocumentStatus.cancelled),
      );
      await h.pumpOrder(tester, anOrder(), who: editor);

      await tester.tap(key(cancel));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_order_cancel_submit'));
      await tester.pumpAndSettle();

      verify(() => h.orders.cancel(310)).called(1);
      expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
      expect(key('purchase_order_line_quantity_900'), findsOneWidget);
      expect(key('purchase_order_actions'), findsNothing);
      expect(key(editLine), findsNothing);
      expect(key(removeLine), findsNothing);
    });

    testWidgets('a confirmed_cannot_cancel refusal reloads the order', (
      tester,
    ) async {
      var loads = 0;
      when(() => h.orders.get(310)).thenAnswer(
        (_) async => loads++ == 0
            ? anOrder()
            : anOrder(status: InventoryDocumentStatus.completed),
      );
      when(() => h.orders.cancel(310)).thenAnswer(
        (_) async => throw aRefusal(
          api.ErrorCode.purchaseOrderPeriodConfirmedCannotCancel,
          'purchase_order.confirmed_cannot_cancel',
        ),
      );
      await h.pump(tester, who: editor, location: '/purchases/orders/310');

      await tester.tap(key(cancel));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_order_cancel_submit'));
      await tester.pumpAndSettle();

      expect(loads, 2);
      expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
      expect(key(cancel), findsNothing);
      expect(
        find.descendant(
          of: key('purchase_order_refusal'),
          matching: find.text(l10n.apiErrorPurchaseOrderConfirmedCannotCancel),
        ),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  });
}
