import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 079 US1 (T018, T019): a request's detail, as a requester sees it;
/// US2 (T024, T025): as an approver sees it; US3 (T027, T028): the approval
/// and purchase-order facts; US4 (T030): a resubmit; US5 (T031, T032): the
/// Comprar mark; US6 (T033, T034): Cancelar.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  final draft = aRequest(
    comment: 'Para el pedido de diciembre',
    lines: [
      aRequestLine(quantity: '5', minOrderQty: 12),
      aRequestLine(
        id: 901,
        productId: 8,
        code: 'B-220',
        quantity: '24',
        warehouseId: 4,
        toPurchase: true,
      ),
    ],
  );

  group('a draft', () {
    testWidgets('shows its title, facts, lines and the minimum band', (
      tester,
    ) async {
      await h.pumpRequest(tester, draft);

      expect(find.text(l10n.purchaseRequestTitleDraft('212')), findsOneWidget);
      expect(find.text(l10n.purchaseRequestStatusDraft), findsOneWidget);
      expect(find.text('Para el pedido de diciembre'), findsOneWidget);
      expect(find.text('Sucursal 2'), findsOneWidget);
      expect(find.text('Empleado 5'), findsOneWidget);
      expect(find.text('A-100'), findsOneWidget);
      expect(find.text('B-220'), findsOneWidget);
      expect(find.text('Almacén 4'), findsOneWidget);
      expect(
        key('purchase_request_line_to_purchase_900_false'),
        findsOneWidget,
      );
      expect(key('purchase_request_line_to_purchase_901_true'), findsOneWidget);
      expect(key('request_minimum_band'), findsOneWidget);
      expect(
        find.text(l10n.purchaseRequestBelowMinimum('A-100', '5', '12')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('offers ✎ 🗑 per line, Agregar producto and Enviar', (
      tester,
    ) async {
      await h.pumpRequest(tester, draft);

      expect(key('purchase_request_line_edit_900'), findsOneWidget);
      expect(key('purchase_request_line_remove_901'), findsOneWidget);
      expect(key('purchase_request_add_product'), findsOneWidget);
      expect(key('purchase_request_submit'), findsOneWidget);
    });

    testWidgets('an empty draft asks for products', (tester) async {
      await h.pumpRequest(tester, aRequest(lines: const []));

      expect(key('purchase_request_lines_empty'), findsOneWidget);
      expect(find.text(l10n.purchaseRequestLinesEmpty), findsOneWidget);
      expect(key('request_minimum_band'), findsNothing);
    });

    testWidgets('without update on 86 nothing is editable', (tester) async {
      await h.pumpRequest(
        tester,
        draft,
        who: PurchasesHarness.user(requestRights: 2),
      );

      expect(key('purchase_request_line_edit_900'), findsNothing);
      expect(key('purchase_request_add_product'), findsNothing);
      expect(key('purchase_request_submit'), findsNothing);
      expect(key('purchase_request_actions'), findsNothing);
    });

    testWidgets("another facility's draft is read-only for a "
        'non-administrator (FR-026)', (tester) async {
      await h.pumpRequest(tester, aRequest(facilityId: 9));

      expect(key('purchase_request_line_edit_900'), findsNothing);
      expect(key('purchase_request_submit'), findsNothing);
    });

    testWidgets('removing a line asks first, naming its code', (tester) async {
      when(
        () => h.requests.removeLine(212, 900),
      ).thenAnswer((_) async => aRequest(lines: const []));
      await h.pumpRequest(tester, draft);

      await tester.tap(key('purchase_request_line_remove_900'));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.purchaseRequestRemoveBody('A-100')),
        findsOneWidget,
      );
      await tester.tap(key('purchase_request_line_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.requests.removeLine(212, 900)).called(1);
      expect(key('purchase_request_lines_empty'), findsOneWidget);
    });
  });

  group('Enviar', () {
    testWidgets('a first submit explains the folio and lists the minimum '
        'warnings', (tester) async {
      await h.pumpRequest(tester, draft);

      await tester.tap(key('purchase_request_submit'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.purchaseRequestSubmitFirstBody), findsOneWidget);
      expect(key('purchase_request_submit_below_minimum'), findsOneWidget);
    });

    testWidgets('a rejected draft says it returns with its folio', (
      tester,
    ) async {
      await h.pumpRequest(tester, aRequest(serial: 569));

      await tester.tap(key('purchase_request_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.purchaseRequestSubmitResubmitBody('569')),
        findsOneWidget,
      );
      expect(key('purchase_request_submit_below_minimum'), findsNothing);
    });

    testWidgets('a refusal shows localized in the dialog, which stays '
        'open', (tester) async {
      when(() => h.requests.submit(212)).thenAnswer(
        (_) async => throw aRefusal(
          api.ErrorCode.purchaseRequestPeriodNoLines,
          'purchase_request.no_lines',
        ),
      );
      await h.pumpRequest(tester, aRequest(lines: const []));

      await tester.tap(key('purchase_request_submit'));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_request_submit_submit'));
      await tester.pumpAndSettle();

      expect(key('purchase_request_submit_dialog'), findsOneWidget);
      expect(key('purchase_request_dialog_refusal'), findsOneWidget);
      expect(
        find.textContaining(l10n.apiErrorPurchaseRequestNoLines),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
    });

    testWidgets('success shows the folio, Enviada and no edit actions', (
      tester,
    ) async {
      when(() => h.requests.submit(212)).thenAnswer(
        (_) async => aRequest(
          serial: 571,
          status: PurchaseRequestStatus.submitted,
          lines: draft.lines,
        ),
      );
      await h.pumpRequest(tester, draft);

      await tester.tap(key('purchase_request_submit'));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_request_submit_submit'));
      await tester.pumpAndSettle();

      expect(key('purchase_request_submit_dialog'), findsNothing);
      expect(find.text(l10n.purchaseRequestTitle('571')), findsOneWidget);
      expect(find.text(l10n.purchaseRequestStatusSubmitted), findsOneWidget);
      expect(key('purchase_request_line_edit_900'), findsNothing);
      expect(key('purchase_request_add_product'), findsNothing);
      expect(key('purchase_request_submit'), findsNothing);
    });
  });

  testWidgets('a submitted request shows no edit actions', (tester) async {
    // Without delete on 86, so Cancelar (US6) is absent too.
    await h.pumpRequest(
      tester,
      aRequest(serial: 571, status: PurchaseRequestStatus.submitted),
      who: PurchasesHarness.user(requestRights: 1 | 2 | 4),
    );

    expect(find.text(l10n.purchaseRequestTitle('571')), findsOneWidget);
    expect(key('purchase_request_line_edit_900'), findsNothing);
    expect(key('purchase_request_actions'), findsNothing);
  });

  group('Aprobar y Rechazar (US2)', () {
    final submitted = aRequest(
      serial: 571,
      status: PurchaseRequestStatus.submitted,
    );
    final approver = PurchasesHarness.user(approvalRights: 6);

    FilledButton primary(WidgetTester tester, String k) =>
        tester.widget<FilledButton>(key(k));

    testWidgets('appear for a submitted request with update on 96', (
      tester,
    ) async {
      await h.pumpRequest(tester, submitted, who: approver);

      expect(key('purchase_request_reject'), findsOneWidget);
      expect(key('purchase_request_approve'), findsOneWidget);
    });

    testWidgets('are absent with read only on 96', (tester) async {
      await h.pumpRequest(
        tester,
        submitted,
        who: PurchasesHarness.user(approvalRights: 2),
      );

      expect(key('purchase_request_reject'), findsNothing);
      expect(key('purchase_request_approve'), findsNothing);
    });

    testWidgets('are absent on a draft, even for an approver', (tester) async {
      await h.pumpRequest(tester, draft, who: approver);

      expect(key('purchase_request_reject'), findsNothing);
      expect(key('purchase_request_approve'), findsNothing);
    });

    testWidgets('Aprobar names the request, approves it and shows the '
        'returned request', (tester) async {
      when(() => h.requests.approve(212)).thenAnswer(
        (_) async =>
            aRequest(serial: 571, status: PurchaseRequestStatus.approved),
      );
      await h.pumpRequest(tester, submitted, who: approver);

      await tester.tap(key('purchase_request_approve'));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.purchaseRequestApproveTitle('571')),
        findsOneWidget,
      );
      expect(
        find.text(
          l10n.purchaseRequestApproveSummary('Sucursal 2', 'Almacén 3', '1'),
        ),
        findsOneWidget,
      );

      await tester.tap(key('purchase_request_approve_submit'));
      await tester.pumpAndSettle();

      expect(key('purchase_request_approve_dialog'), findsNothing);
      expect(find.text(l10n.purchaseRequestStatusApproved), findsOneWidget);
      expect(key('purchase_request_approve'), findsNothing);
    });

    testWidgets('Rechazar stays disabled for an empty or blank reason and '
        'sends it trimmed', (tester) async {
      when(
        () => h.requests.reject(212, reason: any(named: 'reason')),
      ).thenAnswer((_) async => aRequest(serial: 571));
      await h.pumpRequest(tester, submitted, who: approver);

      await tester.tap(key('purchase_request_reject'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.purchaseRequestRejectTitle('571')), findsOneWidget);
      expect(find.text(l10n.purchaseRequestRejectNote), findsOneWidget);
      expect(
        primary(tester, 'purchase_request_reject_submit').onPressed,
        isNull,
      );

      await tester.enterText(key('purchase_request_reject_reason'), '   ');
      await tester.pump();
      expect(
        primary(tester, 'purchase_request_reject_submit').onPressed,
        isNull,
      );

      await tester.enterText(
        key('purchase_request_reject_reason'),
        '  Falta cotizar  ',
      );
      await tester.pump();
      await tester.tap(key('purchase_request_reject_submit'));
      await tester.pumpAndSettle();

      verify(() => h.requests.reject(212, reason: 'Falta cotizar')).called(1);
      expect(key('purchase_request_reject_dialog'), findsNothing);
      expect(find.text(l10n.purchaseRequestStatusDraft), findsOneWidget);
      expect(find.text(l10n.purchaseRequestTitle('571')), findsOneWidget);
    });

    testWidgets('a stale refusal shows in Spanish and leaves only "Cerrar"', (
      tester,
    ) async {
      when(() => h.requests.approve(212)).thenAnswer(
        (_) async => throw aRefusal(
          api.ErrorCode.purchaseRequestPeriodNotSubmitted,
          'purchase_request.not_submitted',
        ),
      );
      await h.pumpRequest(tester, submitted, who: approver);
      // Someone else approved it meanwhile.
      h.stubRequest(
        aRequest(serial: 571, status: PurchaseRequestStatus.approved),
      );

      await tester.tap(key('purchase_request_approve'));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_request_approve_submit'));
      await tester.pumpAndSettle();

      expect(key('purchase_request_dialog_refusal'), findsOneWidget);
      expect(
        find.textContaining(l10n.apiErrorPurchaseRequestNotSubmitted),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
      expect(key('purchase_request_approve_submit'), findsNothing);
      expect(find.text(l10n.purchaseRequestBack), findsNothing);

      await tester.tap(key('purchase_request_dialog_close'));
      await tester.pumpAndSettle();

      expect(key('purchase_request_approve_dialog'), findsNothing);
      expect(find.text(l10n.purchaseRequestStatusApproved), findsOneWidget);
    });
  });

  testWidgets('a missing request shows the not-found state', (tester) async {
    when(() => h.requests.get(99)).thenThrow(const AppError.notFound());
    h.serve(const []);
    await h.pump(tester, location: '/purchases/requests/99');

    expect(key('purchase_request_not_found'), findsOneWidget);
  });

  group('approval and purchase-order facts (US3)', () {
    testWidgets('an approved request shows its approver and time', (
      tester,
    ) async {
      await h.pumpRequest(
        tester,
        aRequest(
          serial: 571,
          status: PurchaseRequestStatus.approved,
          approverId: 8,
          approvalTime: DateTime(2026, 11, 26, 12, 15),
        ),
      );

      expect(key('purchase_request_approver'), findsOneWidget);
      expect(find.text(l10n.purchaseRequestFactApprover), findsOneWidget);
      expect(find.text('Empleado 8'), findsOneWidget);
      expect(find.textContaining('2026-11-26 12:15'), findsOneWidget);
    });

    testWidgets('a request with no approver has no Aprobó fact', (
      tester,
    ) async {
      await h.pumpRequest(tester, draft);

      expect(key('purchase_request_approver'), findsNothing);
      expect(find.text(l10n.purchaseRequestFactApprover), findsNothing);
    });

    testWidgets('a line on a purchase order shows its number and state', (
      tester,
    ) async {
      await h.pumpRequest(
        tester,
        aRequest(
          serial: 571,
          status: PurchaseRequestStatus.approved,
          lines: [
            aRequestLine(
              toPurchase: true,
              purchaseOrderId: 77,
              purchaseOrderStatus: InventoryDocumentStatus.draft,
            ),
            aRequestLine(id: 901, code: 'B-220'),
          ],
        ),
      );

      expect(find.text(l10n.purchaseRequestLineColPurchaseOrder), findsOne);
      final order = key('purchase_request_line_order_900');
      expect(
        find.descendant(of: order, matching: find.text('77')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: order,
          matching: find.text(l10n.inventoryDocumentStatusDraft),
        ),
        findsOneWidget,
      );
      expect(key('purchase_request_line_order_901'), findsNothing);
    });

    testWidgets('the order number links to the order with read on 20, and '
        'is plain text without it (spec 080 FR-030)', (tester) async {
      final request = aRequest(
        serial: 571,
        status: PurchaseRequestStatus.approved,
        lines: [
          aRequestLine(
            toPurchase: true,
            purchaseOrderId: 77,
            purchaseOrderStatus: InventoryDocumentStatus.draft,
          ),
        ],
      );
      h.stubOrder(anOrder(id: 77));
      final router = await h.pumpRequest(
        tester,
        request,
        who: PurchasesHarness.user(orderRights: 2),
      );

      await tester.tap(key('purchase_order_link_77'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/purchases/orders/77');
    });

    testWidgets('without read on 20 the order number is not a link', (
      tester,
    ) async {
      await h.pumpRequest(
        tester,
        aRequest(
          serial: 571,
          status: PurchaseRequestStatus.approved,
          lines: [
            aRequestLine(
              toPurchase: true,
              purchaseOrderId: 77,
              purchaseOrderStatus: InventoryDocumentStatus.draft,
            ),
          ],
        ),
      );

      expect(key('purchase_order_link_77'), findsNothing);
      expect(
        find.descendant(
          of: key('purchase_request_line_order_900'),
          matching: find.text('77'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a request with no line on an order has no Orden de compra '
        'column', (tester) async {
      await h.pumpRequest(
        tester,
        aRequest(serial: 571, status: PurchaseRequestStatus.approved),
      );

      expect(find.text(l10n.purchaseRequestLineColPurchaseOrder), findsNothing);
    });
  });

  testWidgets('a rejected draft keeps its folio through a resubmit (US4)', (
    tester,
  ) async {
    final rejected = aRequest(serial: 569, lines: draft.lines);
    when(() => h.requests.submit(212)).thenAnswer(
      (_) async => aRequest(
        serial: 569,
        status: PurchaseRequestStatus.submitted,
        lines: draft.lines,
      ),
    );
    await h.pumpRequest(tester, rejected);

    expect(find.text(l10n.purchaseRequestTitle('569')), findsOneWidget);
    expect(
      find.descendant(
        of: key('purchase_request_serial'),
        matching: find.text('569'),
      ),
      findsOneWidget,
    );
    await tester.tap(key('purchase_request_submit'));
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.purchaseRequestSubmitResubmitBody('569')),
      findsOneWidget,
    );
    await tester.tap(key('purchase_request_submit_submit'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.purchaseRequestTitle('569')), findsOneWidget);
    expect(find.text(l10n.purchaseRequestStatusSubmitted), findsOneWidget);
  });

  group('Comprar mark (US5)', () {
    final buyer = PurchasesHarness.user(orderRights: 2 | 4);
    final submitted = aRequest(
      serial: 571,
      status: PurchaseRequestStatus.submitted,
    );

    Finder mark(int lineId, bool value) =>
        key('purchase_request_line_to_purchase_${lineId}_$value');

    bool isLive(WidgetTester tester, Finder finder) {
      final widget = tester.widget(finder);
      return widget is Checkbox && widget.onChanged != null;
    }

    testWidgets('is a live checkbox with update on 20 on a submitted or '
        'approved request', (tester) async {
      await h.pumpRequest(tester, submitted, who: buyer);
      expect(isLive(tester, mark(900, false)), isTrue);
    });

    testWidgets('is live on an approved request too', (tester) async {
      await h.pumpRequest(
        tester,
        aRequest(serial: 571, status: PurchaseRequestStatus.approved),
        who: buyer,
      );
      expect(isLive(tester, mark(900, false)), isTrue);
    });

    testWidgets('is read-only without update on 20', (tester) async {
      await h.pumpRequest(
        tester,
        submitted,
        who: PurchasesHarness.user(orderRights: 2),
      );
      expect(tester.widget(mark(900, false)), isA<Icon>());
    });

    testWidgets('is read-only on a draft', (tester) async {
      await h.pumpRequest(tester, aRequest(), who: buyer);
      expect(tester.widget(mark(900, false)), isA<Icon>());
    });

    testWidgets('is read-only on a cancelled request', (tester) async {
      await h.pumpRequest(
        tester,
        aRequest(id: 213, serial: 572, status: PurchaseRequestStatus.cancelled),
        who: buyer,
      );
      expect(tester.widget(mark(900, false)), isA<Icon>());
    });

    testWidgets('a tap sends the flipped mark, disables the box meanwhile '
        'and shows the returned request', (tester) async {
      final reply = Completer<PurchaseRequest>();
      when(
        () => h.requests.markLine(212, 900, toPurchase: true),
      ).thenAnswer((_) => reply.future);
      await h.pumpRequest(tester, submitted, who: buyer);

      await tester.tap(mark(900, false));
      await tester.pump();

      verify(() => h.requests.markLine(212, 900, toPurchase: true)).called(1);
      expect(tester.widget<Checkbox>(mark(900, false)).onChanged, isNull);
      await tester.tap(mark(900, false), warnIfMissed: false);
      await tester.pump();
      verifyNever(() => h.requests.markLine(212, 900, toPurchase: true));

      reply.complete(
        aRequest(
          serial: 571,
          status: PurchaseRequestStatus.submitted,
          lines: [aRequestLine(toPurchase: true)],
        ),
      );
      await tester.pumpAndSettle();

      expect(isLive(tester, mark(900, true)), isTrue);
      expect(tester.widget<Checkbox>(mark(900, true)).value, isTrue);
    });

    testWidgets('a line_on_live_order refusal shows in Spanish with the '
        'order number', (tester) async {
      when(() => h.requests.markLine(212, 900, toPurchase: false)).thenAnswer(
        (_) async => throw aRefusal(
          api.ErrorCode.purchaseRequestPeriodLineOnLiveOrder,
          'purchase_request.line_on_live_order',
          {'line_id': 900},
        ),
      );
      await h.pumpRequest(
        tester,
        aRequest(
          serial: 571,
          status: PurchaseRequestStatus.approved,
          lines: [
            aRequestLine(
              toPurchase: true,
              purchaseOrderId: 77,
              purchaseOrderStatus: InventoryDocumentStatus.draft,
            ),
          ],
        ),
        who: buyer,
      );

      await tester.tap(mark(900, true));
      await tester.pumpAndSettle();

      expect(key('purchase_request_refusal'), findsOneWidget);
      expect(
        find.textContaining(l10n.apiErrorPurchaseRequestLineOnLiveOrder),
        findsOneWidget,
      );
      expect(find.text(l10n.purchaseRequestRefusalOrder('77')), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
      // Unchanged, and the box is usable again.
      expect(isLive(tester, mark(900, true)), isTrue);
    });
  });

  group('Cancelar (US6)', () {
    final submitted = aRequest(
      serial: 571,
      status: PurchaseRequestStatus.submitted,
    );

    testWidgets('appears first in the action area of an own draft', (
      tester,
    ) async {
      await h.pumpRequest(tester, draft);

      final wrap = tester.widget<Wrap>(
        find.descendant(
          of: key('purchase_request_actions'),
          matching: find.byType(Wrap),
        ),
      );
      expect(wrap.children.first.key, const Key('purchase_request_cancel'));
    });

    for (final status in [
      PurchaseRequestStatus.submitted,
      PurchaseRequestStatus.approved,
    ]) {
      testWidgets('appears on an own ${status.name} request', (tester) async {
        await h.pumpRequest(tester, aRequest(serial: 571, status: status));
        expect(key('purchase_request_cancel'), findsOneWidget);
      });
    }

    testWidgets('is absent without delete on 86', (tester) async {
      await h.pumpRequest(
        tester,
        submitted,
        who: PurchasesHarness.user(requestRights: 1 | 2 | 4),
      );
      expect(key('purchase_request_cancel'), findsNothing);
    });

    testWidgets('is absent on a cancelled request', (tester) async {
      await h.pumpRequest(
        tester,
        aRequest(serial: 571, status: PurchaseRequestStatus.cancelled),
      );
      expect(key('purchase_request_cancel'), findsNothing);
    });

    testWidgets("is absent on another facility's request for a "
        'non-administrator', (tester) async {
      await h.pumpRequest(
        tester,
        aRequest(
          serial: 571,
          status: PurchaseRequestStatus.submitted,
          facilityId: 9,
        ),
      );
      expect(key('purchase_request_cancel'), findsNothing);
    });

    testWidgets('a draft is asked about as a draft', (tester) async {
      await h.pumpRequest(tester, draft);

      await tester.tap(key('purchase_request_cancel'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.purchaseRequestCancelDraftBody), findsOneWidget);
      expect(
        find.descendant(
          of: key('purchase_request_cancel_submit'),
          matching: find.text(l10n.purchaseRequestCancelAction),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a numbered request is asked about by its folio', (
      tester,
    ) async {
      await h.pumpRequest(tester, submitted);

      await tester.tap(key('purchase_request_cancel'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.purchaseRequestCancelBody('571')), findsOneWidget);
    });

    testWidgets('success shows Cancelada with no actions', (tester) async {
      when(() => h.requests.cancel(212)).thenAnswer(
        (_) async =>
            aRequest(serial: 571, status: PurchaseRequestStatus.cancelled),
      );
      await h.pumpRequest(tester, submitted);

      await tester.tap(key('purchase_request_cancel'));
      await tester.pumpAndSettle();
      await tester.tap(key('purchase_request_cancel_submit'));
      await tester.pumpAndSettle();

      verify(() => h.requests.cancel(212)).called(1);
      expect(key('purchase_request_cancel_dialog'), findsNothing);
      expect(find.text(l10n.purchaseRequestStatusCancelled), findsOneWidget);
      expect(key('purchase_request_actions'), findsNothing);
    });

    for (final count in [1, 3]) {
      testWidgets('lines_on_live_order ($count) shows its Spanish reason and '
          'leaves the request unchanged', (tester) async {
        when(() => h.requests.cancel(212)).thenAnswer(
          (_) async => throw aRefusal(
            api.ErrorCode.purchaseRequestPeriodLinesOnLiveOrder,
            'purchase_request.lines_on_live_order',
            {'count': count},
          ),
        );
        await h.pumpRequest(tester, submitted);

        await tester.tap(key('purchase_request_cancel'));
        await tester.pumpAndSettle();
        await tester.tap(key('purchase_request_cancel_submit'));
        await tester.pumpAndSettle();

        expect(key('purchase_request_cancel_dialog'), findsOneWidget);
        expect(
          find.textContaining(
            l10n.apiErrorPurchaseRequestLinesOnLiveOrder(count),
          ),
          findsOneWidget,
        );
        expect(find.text('SERVER TEXT'), findsNothing);

        await tester.tap(find.text(l10n.purchaseRequestBack));
        await tester.pumpAndSettle();
        expect(find.text(l10n.purchaseRequestStatusSubmitted), findsOneWidget);
        expect(key('purchase_request_cancel'), findsOneWidget);
      });
    }
  });
}
