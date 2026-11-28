import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/receipt_cost_warning.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_receipt_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 067 US2 (T020): the receipt detail screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() => h = InventoryHarness());

  final completed = aReceipt(
    serial: 1043,
    status: InventoryDocumentStatus.completed,
  );

  String title(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(of: find.byType(AppBar), matching: find.byType(Text)),
      )
      .data!;

  /// The text the screen shows for [error]: its code, localized.
  String localized(AppError error) =>
      error.localizedMessage(l10n, h.container.read(formattersProvider))!;

  group('a draft', () {
    testWidgets('is titled "Entrada · Borrador #id" and shows its facts, '
        'lines and every action with full rights', (tester) async {
      await h.pumpReceipt(tester, aReceipt(comment: 'Sin factura'));

      expect(title(tester), l10n.inventoryReceiptTitleDraft('318'));
      expect(key('inventory_document_status_chip'), findsOneWidget);
      expect(
        tester.widget<RecordIdText>(key('inventory_receipt_serial')).text,
        '—',
      );
      expect(find.text('Almacén 3'), findsOneWidget);
      expect(find.text('Sucursal 2'), findsOneWidget);
      expect(find.text('Sin factura'), findsOneWidget);
      expect(find.text('Empleado 5'), findsNWidgets(2));
      expect(key('inventory_receipt_purchase_order'), findsNothing);
      expect(find.text('A-100'), findsOneWidget);
      expect(find.text('Tornillo 1/4 caja'), findsOneWidget);
      expect(
        tester.widget<Text>(key('inventory_receipt_line_quantity_900')).data,
        '8',
      );
      expect(key('inventory_receipt_line_edit_900'), findsOneWidget);
      expect(key('inventory_receipt_line_remove_900'), findsOneWidget);
      expect(key('inventory_receipt_add_product'), findsOneWidget);
      expect(key('inventory_receipt_confirm'), findsOneWidget);
      expect(key('inventory_receipt_edit_header'), findsOneWidget);
      expect(key('inventory_receipt_cancel'), findsOneWidget);
      // Not linked to a purchase order (FR-021).
      expect(key('inventory_receipt_complementary'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with no lines says to add the products received', (
      tester,
    ) async {
      await h.pumpReceipt(tester, aReceipt(lines: const []));

      expect(find.text(l10n.inventoryReceiptLinesEmpty), findsOneWidget);
    });

    testWidgets('a linked receipt shows its purchase order, as text without '
        'read on purchase orders', (tester) async {
      await h.pumpReceipt(tester, aReceipt(purchaseOrderId: 5512));

      expect(
        find.descendant(
          of: key('inventory_receipt_purchase_order'),
          matching: find.text('5512'),
        ),
        findsOneWidget,
      );
      expect(key('purchase_order_link_5512'), findsNothing);
    });

    testWidgets('with PurchasesOrders (20) read the purchase order is a link '
        'to it (spec 080 FR-030)', (tester) async {
      final router = await h.pumpReceipt(
        tester,
        aReceipt(purchaseOrderId: 5512),
        who: InventoryHarness.user(purchaseOrders: 2),
      );

      await tester.tap(key('purchase_order_link_5512'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/purchases/orders/5512');
    });

    testWidgets('Agregar producto needs Products read', (tester) async {
      await h.pumpReceipt(
        tester,
        aReceipt(),
        who: InventoryHarness.user(productsRead: false),
      );

      expect(key('inventory_receipt_add_product'), findsNothing);
      expect(key('inventory_receipt_confirm'), findsOneWidget);
    });

    testWidgets('a read-only user sees no actions and no line icons', (
      tester,
    ) async {
      await h.pumpReceipt(
        tester,
        aReceipt(),
        who: InventoryHarness.user(receipts: 2),
      );

      expect(key('inventory_receipt_actions'), findsNothing);
      expect(key('inventory_receipt_line_edit_900'), findsNothing);
      expect(key('inventory_receipt_line_remove_900'), findsNothing);
    });
  });

  testWidgets('a confirmed receipt is titled with its folio and shows no '
      'edit actions or line icons', (tester) async {
    await h.pumpReceipt(tester, completed);

    expect(title(tester), l10n.inventoryReceiptTitle('1043'));
    expect(
      tester.widget<RecordIdText>(key('inventory_receipt_serial')).text,
      '1043',
    );
    expect(key('inventory_receipt_edit_header'), findsNothing);
    expect(key('inventory_receipt_add_product'), findsNothing);
    expect(key('inventory_receipt_confirm'), findsNothing);
    expect(key('inventory_receipt_line_edit_900'), findsNothing);
    // Spec 067 US4: cancelling stays available on a confirmed receipt.
    expect(key('inventory_receipt_cancel'), findsOneWidget);
  });

  testWidgets('adding a product already on the receipt shows the single '
      'merged line the server returns', (tester) async {
    when(
      () => h.products.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const ProductListResult(
        items: [
          ProductListItem(
            productId: 7,
            code: 'A-100',
            name: 'Tornillo 1/4 caja',
            unitOfMeasurementCode: 'H87',
            unitOfMeasurementName: 'Pieza',
            taxRate: '0.16',
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
    when(
      () => h.receipts.addLine(
        318,
        productId: 7,
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async => aReceipt(lines: [aReceiptLine(quantity: '11')]));
    await h.pumpReceipt(tester, aReceipt());

    await tester.tap(key('inventory_receipt_add_product'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: key('add_receipt_line_product'),
        matching: find.byType(TextField),
      ),
      'torn',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tornillo 1/4 caja').last);
    await tester.pumpAndSettle();
    await tester.enterText(key('add_receipt_line_quantity'), '3');
    await tester.pumpAndSettle();
    await tester.tap(key('add_receipt_line_submit'));
    await tester.pumpAndSettle();

    expect(find.text('A-100'), findsOneWidget);
    expect(
      tester.widget<Text>(key('inventory_receipt_line_quantity_900')).data,
      '11',
    );
  });

  group('confirm', () {
    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(key('inventory_receipt_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_receipt_confirm_submit'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the folio and the read-only state', (tester) async {
      when(() => h.receipts.confirm(318)).thenAnswer((_) async => completed);
      await h.pumpReceipt(tester, aReceipt());

      await confirm(tester);

      expect(title(tester), l10n.inventoryReceiptTitle('1043'));
      expect(
        tester.widget<RecordIdText>(key('inventory_receipt_serial')).text,
        '1043',
      );
      expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
      expect(key('inventory_receipt_confirm'), findsNothing);
      expect(key('inventory_receipt_edit_header'), findsNothing);
      expect(key('inventory_receipt_line_edit_900'), findsNothing);
    });

    testWidgets('an empty draft shows the localized no_lines text', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodNoLines,
        'inventory_document.no_lines',
        {'resource': 'inventory_receipt'},
      );
      when(
        () => h.receipts.confirm(318),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpReceipt(tester, aReceipt(lines: const []));

      await confirm(tester);

      expect(key('inventory_receipt_refusal'), findsOneWidget);
      expect(find.text(localized(refusal)), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
      expect(key('inventory_receipt_confirm'), findsOneWidget);
    });

    testWidgets('a facility.other_facility refusal shows its Spanish '
        'message', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.facilityPeriodOtherFacility,
        'facility.other_facility',
        {'resource': 'inventory_receipt'},
      );
      when(
        () => h.receipts.confirm(318),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpReceipt(tester, aReceipt());

      await confirm(tester);

      expect(find.text(localized(refusal)), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  });

  group('load', () {
    testWidgets('a missing receipt shows the not-found view', (tester) async {
      when(
        () => h.receipts.get(9),
      ).thenAnswer((_) async => throw const AppError.notFound());
      h.serve(const []);
      await h.pump(tester, location: '/inventory/receipts/9');

      expect(key('inventory_receipt_not_found'), findsOneWidget);
    });

    testWidgets('a failed load offers retry', (tester) async {
      var fail = true;
      when(() => h.receipts.get(318)).thenAnswer((_) async {
        if (fail) throw const AppError.network();
        return aReceipt();
      });
      h.serve(const []);
      await h.pump(tester, location: '/inventory/receipts/318');

      expect(key('inventory_receipt_load_failed'), findsOneWidget);
      fail = false;
      await tester.tap(key('inventory_receipt_retry_button'));
      await tester.pumpAndSettle();
      expect(key('inventory_receipt_confirm'), findsOneWidget);
    });
  });

  group('Editar encabezado (US3)', () {
    testWidgets('is absent on a confirmed receipt', (tester) async {
      await h.pumpReceipt(tester, completed);
      expect(key('inventory_receipt_edit_header'), findsNothing);
    });

    testWidgets('is absent on a cancelled receipt', (tester) async {
      await h.pumpReceipt(
        tester,
        aReceipt(serial: 1043, status: InventoryDocumentStatus.cancelled),
      );
      expect(key('inventory_receipt_edit_header'), findsNothing);
    });

    testWidgets('is absent without update on 15', (tester) async {
      await h.pumpReceipt(
        tester,
        aReceipt(),
        who: InventoryHarness.user(receipts: 1 | 2 | 8),
      );
      expect(key('inventory_receipt_edit_header'), findsNothing);
    });
  });

  group('cancel (US4)', () {
    Future<void> cancel(WidgetTester tester) async {
      await tester.tap(key('inventory_receipt_cancel'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_receipt_cancel_submit'));
      await tester.pumpAndSettle();
    }

    testWidgets('is first in the action area', (tester) async {
      await h.pumpReceipt(tester, aReceipt(purchaseOrderId: 5512));

      final buttons = tester
          .widget<Wrap>(
            find.descendant(
              of: key('inventory_receipt_actions'),
              matching: find.byType(Wrap),
            ),
          )
          .children;
      expect(buttons.first.key, const Key('inventory_receipt_cancel'));
      expect(buttons[1].key, const Key('inventory_receipt_complementary'));
      expect(buttons[2].key, const Key('inventory_receipt_edit_header'));
    });

    testWidgets('success shows Cancelada', (tester) async {
      when(() => h.receipts.cancel(318)).thenAnswer(
        (_) async =>
            aReceipt(serial: 1043, status: InventoryDocumentStatus.cancelled),
      );
      await h.pumpReceipt(tester, completed);

      await cancel(tester);

      verify(() => h.receipts.cancel(318)).called(1);
      expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
      expect(key('inventory_receipt_cancel'), findsNothing);
    });

    testWidgets('is absent without delete on 15', (tester) async {
      await h.pumpReceipt(
        tester,
        completed,
        who: InventoryHarness.user(receipts: 1 | 2 | 4),
      );
      expect(key('inventory_receipt_cancel'), findsNothing);
    });

    testWidgets('is absent on a cancelled receipt', (tester) async {
      await h.pumpReceipt(
        tester,
        aReceipt(serial: 1043, status: InventoryDocumentStatus.cancelled),
      );
      expect(key('inventory_receipt_actions'), findsNothing);
    });

    testWidgets('insufficient_stock shows the quantities and the product '
        'code, and leaves the receipt confirmed', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock,
        'inventory_document.insufficient_stock',
        {
          'product_id': 7,
          'warehouse_id': 3,
          'requested': '8',
          'available': '2',
        },
      );
      when(() => h.receipts.cancel(318)).thenAnswer((_) async => throw refusal);
      await h.pumpReceipt(tester, completed);

      await cancel(tester);

      final message = localized(refusal);
      expect(message, contains('8'));
      expect(message, contains('2'));
      expect(find.text(message), findsOneWidget);
      expect(
        find.text(l10n.inventoryReceiptRefusalProduct('A-100')),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
      expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
    });

    testWidgets('already_cancelled shows its message and refreshes', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
        'inventory_document.already_cancelled',
        {'resource': 'inventory_receipt'},
      );
      when(() => h.receipts.cancel(318)).thenAnswer((_) async => throw refusal);
      await h.pumpReceipt(tester, completed);
      h.stubReceipt(
        aReceipt(serial: 1043, status: InventoryDocumentStatus.cancelled),
      );

      await cancel(tester);

      expect(find.text(localized(refusal)), findsOneWidget);
      expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
      expect(key('inventory_receipt_cancel'), findsNothing);
    });
  });

  group('purchase order (US5)', () {
    /// A draft linked to order 5512: line 900 on order line 1 (ordered 10,
    /// 5 received elsewhere, 8 here: 3 over) and hand-added line 901.
    InventoryReceipt linked({
      InventoryDocumentStatus status = InventoryDocumentStatus.draft,
      int? serial,
    }) => aReceipt(
      purchaseOrderId: 5512,
      status: status,
      serial: serial,
      lines: [
        aReceiptLine(purchaseOrderLineId: 1, ordered: '10', elsewhere: '5'),
        aReceiptLine(id: 901, productId: 8),
      ],
    );

    testWidgets('linked columns show the order\'s figures, and "—" on a '
        'hand-added line', (tester) async {
      await h.pumpReceipt(tester, linked());

      expect(find.text(l10n.inventoryReceiptLineColOrdered), findsOneWidget);
      expect(find.text(l10n.inventoryReceiptLineColElsewhere), findsOneWidget);
      String cell(String k) => tester.widget<Text>(key(k)).data!;
      expect(cell('inventory_receipt_line_ordered_900'), '10');
      expect(cell('inventory_receipt_line_elsewhere_900'), '5');
      expect(cell('inventory_receipt_line_ordered_901'), '—');
      expect(cell('inventory_receipt_line_elsewhere_901'), '—');
    });

    testWidgets('an unlinked receipt has no linked columns', (tester) async {
      await h.pumpReceipt(tester, aReceipt());

      expect(find.text(l10n.inventoryReceiptLineColOrdered), findsNothing);
      expect(find.text(l10n.inventoryReceiptLineColElsewhere), findsNothing);
    });

    testWidgets('the over-receipt band shows on a draft', (tester) async {
      await h.pumpReceipt(tester, linked());
      expect(key('receipt_over_receipt_band'), findsOneWidget);
      expect(find.text(overReceiptLine(l10n)), findsOneWidget);
    });

    testWidgets('no over-receipt band on a cancelled receipt', (tester) async {
      await h.pumpReceipt(
        tester,
        linked(status: InventoryDocumentStatus.cancelled, serial: 1043),
      );
      expect(key('receipt_over_receipt_band'), findsNothing);
    });

    testWidgets('the confirm prompt lists the over-receipts and confirming '
        'still works', (tester) async {
      when(() => h.receipts.confirm(318)).thenAnswer(
        (_) async =>
            linked(status: InventoryDocumentStatus.completed, serial: 1043),
      );
      await h.pumpReceipt(tester, linked());

      await tester.tap(key('inventory_receipt_confirm'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: key('inventory_receipt_confirm_over_receipts'),
          matching: find.text(overReceiptLine(l10n)),
        ),
        findsOneWidget,
      );
      await tester.tap(key('inventory_receipt_confirm_submit'));
      await tester.pumpAndSettle();

      verify(() => h.receipts.confirm(318)).called(1);
      expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
      // No cost warnings in the response: no notice.
      expect(key('receipt_cost_notice_band'), findsNothing);
    });

    testWidgets('a confirm with cost warnings shows the cost notice until '
        'closed', (tester) async {
      when(() => h.receipts.confirm(318)).thenAnswer(
        (_) async =>
            aReceipt(
              serial: 1043,
              status: InventoryDocumentStatus.completed,
              costWarnings: const [
                (
                  kind: ReceiptCostWarningKind.zeroPrice,
                  productCode: 'A1',
                  receipt: null,
                ),
              ],
            ),
      );
      await h.pumpReceipt(tester, aReceipt());

      await tester.tap(key('inventory_receipt_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_receipt_confirm_submit'));
      await tester.pumpAndSettle();

      expect(key('receipt_cost_notice_band'), findsOneWidget);
      expect(
        find.text(l10n.inventoryReceiptCostZeroPrice('A1')),
        findsOneWidget,
      );
      await tester.tap(key('receipt_cost_notice_close'));
      await tester.pumpAndSettle();
      expect(key('receipt_cost_notice_band'), findsNothing);
    });

    testWidgets('a cancel with cost warnings shows the cost notice', (
      tester,
    ) async {
      when(() => h.receipts.cancel(318)).thenAnswer(
        (_) async => aReceipt(
          serial: 1043,
          status: InventoryDocumentStatus.cancelled,
          costWarnings: const [
            (
              kind: ReceiptCostWarningKind.notRestored,
              productCode: 'B2',
              receipt: '1044',
            ),
          ],
        ),
      );
      await h.pumpReceipt(tester, completed);

      await tester.tap(key('inventory_receipt_cancel'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_receipt_cancel_submit'));
      await tester.pumpAndSettle();

      expect(key('receipt_cost_notice_band'), findsOneWidget);
      expect(
        find.text(l10n.inventoryReceiptCostNotRestored('B2', '1044')),
        findsOneWidget,
      );
    });

    group('Entrada complementaria', () {
      testWidgets('is absent without create on 15', (tester) async {
        await h.pumpReceipt(
          tester,
          linked(),
          who: InventoryHarness.user(receipts: 2 | 4 | 8),
        );
        expect(key('inventory_receipt_complementary'), findsNothing);
      });

      testWidgets('is absent on an unlinked receipt', (tester) async {
        await h.pumpReceipt(tester, completed);
        expect(key('inventory_receipt_complementary'), findsNothing);
      });

      testWidgets('is absent on a cancelled receipt', (tester) async {
        await h.pumpReceipt(
          tester,
          linked(status: InventoryDocumentStatus.cancelled, serial: 1043),
        );
        expect(key('inventory_receipt_complementary'), findsNothing);
      });

      // The repository answers the receipt alike for the existing draft
      // (200) and a new one (201).
      for (final (label, id) in [('200, existing', 330), ('201, new', 331)]) {
        testWidgets('opens the returned draft ($label)', (tester) async {
          final draft = aReceipt(id: id, purchaseOrderId: 5512);
          when(
            () => h.receipts.complementary(318),
          ).thenAnswer((_) async => draft);
          h.stubReceipt(draft);
          await h.pumpReceipt(
            tester,
            linked(status: InventoryDocumentStatus.completed, serial: 1043),
          );

          await tester.tap(key('inventory_receipt_complementary'));
          await tester.pumpAndSettle();

          verify(() => h.receipts.complementary(318)).called(1);
          expect(title(tester), l10n.inventoryReceiptTitleDraft('$id'));
        });
      }

      for (final reason in [
        'no_purchase_order',
        'purchase_order_cancelled',
        'purchase_order_not_completed',
        'purchase_order_fully_received',
      ]) {
        testWidgets('complementary_unavailable ($reason) shows its Spanish '
            'text', (tester) async {
          final refusal = aRefusal(
            api.ErrorCode.inventoryReceiptPeriodComplementaryUnavailable,
            'inventory_receipt.complementary_unavailable',
            {'reason': reason},
          );
          when(
            () => h.receipts.complementary(318),
          ).thenAnswer((_) async => throw refusal);
          await h.pumpReceipt(
            tester,
            linked(status: InventoryDocumentStatus.completed, serial: 1043),
          );

          await tester.tap(key('inventory_receipt_complementary'));
          await tester.pumpAndSettle();

          expect(key('inventory_receipt_refusal'), findsOneWidget);
          expect(find.text(localized(refusal)), findsOneWidget);
          expect(find.text('SERVER TEXT'), findsNothing);
        });
      }
    });
  });
}

/// Line 900's over-receipt, as the band and the prompt word it.
String overReceiptLine(AppLocalizations l10n) =>
    l10n.inventoryReceiptOverReceipt('A-100', '3', '13', '10');
