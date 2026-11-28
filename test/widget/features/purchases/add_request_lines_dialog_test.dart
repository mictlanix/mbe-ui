import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';

import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US2 (T020), FR-017, FR-018 and research R9: "Agregar partidas
/// de una solicitud", opened from a draft order's detail.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    h = PurchasesHarness();
    h.serve([
      aRequestSummary(
        id: 212,
        serial: 571,
        status: PurchaseRequestStatus.approved,
      ),
    ]);
  });

  final buyer = PurchasesHarness.user(requestRights: 2, orderRights: 15);

  Future<void> open(WidgetTester tester) async {
    await h.pumpOrder(tester, anOrder(), who: buyer);
    await tester.tap(key('purchase_order_add_request'));
    await tester.pumpAndSettle();
  }

  const option = '571 · Sucursal 2 · Almacén 3';

  Future<void> pick571(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: key('add_request_lines_request'),
        matching: find.byType(TextField),
      ),
      '571',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('add_request_lines_submit'));

  void addAnswers(Future<PurchaseOrder> Function() answer) => when(
    () => h.orders.addRequestLines(310, requestId: 212),
  ).thenAnswer((_) => answer());

  testWidgets("offers everyone's approved requests by folio, naming the "
      'facility and warehouse', (tester) async {
    await open(tester);

    expect(key('add_request_lines_dialog'), findsOneWidget);
    expect(submit(tester).onPressed, isNull);
    await pick571(tester);

    verify(
      () => h.requests.list(
        status: PurchaseRequestStatus.approved,
        all: true,
        serial: 571,
        skip: 0,
        limit: 10,
      ),
    ).called(greaterThan(0));
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: key('add_request_lines_request'),
              matching: find.byType(TextField),
            ),
          )
          .controller!
          .text,
      option,
    );
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('adds the lines and says how many', (tester) async {
    addAnswers(
      () async => anOrder(
        lines: [
          anOrderLine(),
          anOrderLine(id: 901, requestId: 212),
          anOrderLine(id: 902, requestId: 212),
        ],
      ),
    );
    when(
      () => h.requests.get(212),
    ).thenAnswer((_) async => aRequest(serial: 571));
    await open(tester);
    await pick571(tester);

    await tester.tap(key('add_request_lines_submit'));
    await tester.pumpAndSettle();

    expect(key('add_request_lines_dialog'), findsNothing);
    expect(find.text(l10n.purchaseOrderAddRequestSnack(2)), findsOneWidget);
    expect(key('purchase_order_line_request_901'), findsOneWidget);
  });

  testWidgets('says how many lines were left out', (tester) async {
    addAnswers(
      () async => anOrder(
        skippedCount: 2,
        lines: [anOrderLine(), anOrderLine(id: 901, requestId: 212)],
      ),
    );
    when(
      () => h.requests.get(212),
    ).thenAnswer((_) async => aRequest(serial: 571));
    await open(tester);
    await pick571(tester);

    await tester.tap(key('add_request_lines_submit'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '${l10n.purchaseOrderAddRequestSnack(1)}'
        '${l10n.purchaseOrderLeftOutSnack(2)}',
      ),
      findsOneWidget,
    );
  });

  for (final (codeName, code, message) in [
    (
      'purchase_order.nothing_to_add',
      api.ErrorCode.purchaseOrderPeriodNothingToAdd,
      (AppLocalizations l) => l.apiErrorPurchaseOrderNothingToAdd,
    ),
    (
      'purchase_order.request_not_approved',
      api.ErrorCode.purchaseOrderPeriodRequestNotApproved,
      (AppLocalizations l) => l.apiErrorPurchaseOrderRequestNotApproved,
    ),
  ]) {
    testWidgets('$codeName shows in the dialog, localized', (tester) async {
      addAnswers(() async => throw aRefusal(code, codeName));
      await open(tester);
      await pick571(tester);

      await tester.tap(key('add_request_lines_submit'));
      await tester.pumpAndSettle();

      expect(key('add_request_lines_dialog'), findsOneWidget);
      expect(key('add_request_lines_refusal'), findsOneWidget);
      expect(find.text(message(l10n)), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  }

  testWidgets('closing the dialog while the options load is harmless', (
    tester,
  ) async {
    final loading = Completer<PurchaseRequestPage>();
    when(
      () => h.requests.list(
        all: any(named: 'all'),
        status: any(named: 'status'),
        facilityId: any(named: 'facilityId'),
        warehouseId: any(named: 'warehouseId'),
        creatorId: any(named: 'creatorId'),
        serial: any(named: 'serial'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => loading.future);
    await open(tester);

    await tester.enterText(
      find.descendant(
        of: key('add_request_lines_request'),
        matching: find.byType(TextField),
      ),
      '571',
    );
    await tester.pump(const Duration(seconds: 1));
    Navigator.of(tester.element(key('add_request_lines_request'))).pop();
    await tester.pumpAndSettle();
    expect(key('add_request_lines_dialog'), findsNothing);

    loading.complete(
      CatalogPage(
        items: [
          aRequestSummary(
            id: 212,
            serial: 571,
            status: PurchaseRequestStatus.approved,
          ),
        ],
        total: 1,
        pageIndex: 0,
        pageSize: 10,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
