import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/purchase_request_approval_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 079 US2 (T021, T023, T025): Aprobación de solicitudes.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  PurchaseRequestSummary row(int id, int serial, {int facilityId = 2}) =>
      aRequestSummary(
        id: id,
        serial: serial,
        status: PurchaseRequestStatus.submitted,
        facilityId: facilityId,
        comment: id == 1 ? 'Urgente para el fin de semana' : null,
      );

  final rows = [row(3, 318, facilityId: 5), row(1, 571), row(2, 92)];

  /// 96 read + update and 86 read, unless told otherwise.
  Future<GoRouter> pumpQueue(
    WidgetTester tester, {
    int approvalRights = 6,
    int requestRights = 2,
    bool facilitiesRead = true,
    String location = purchaseRequestApprovalPath,
  }) => h.pump(
    tester,
    who: PurchasesHarness.user(
      approvalRights: approvalRights,
      requestRights: requestRights,
      facilitiesRead: facilitiesRead,
    ),
    location: location,
  );

  group('the table', () {
    testWidgets("rows come in the server's order, with no Estado column", (
      tester,
    ) async {
      h.serveQueue(rows);
      await pumpQueue(tester);

      final ys = [
        for (final id in [3, 1, 2])
          tester.getTopLeft(key('purchase_request_folio_$id')).dy,
      ];
      expect(ys, [...ys]..sort());
      expect(find.text(l10n.purchaseRequestColStatus), findsNothing);
      expect(find.text('Urgente para el fin de semana'), findsOneWidget);
      expect(h.queueCalls.single, (facilityId: null, skip: 0, limit: 20));
      expect(tester.takeException(), isNull);
    });

    testWidgets('96 update and 86 read: checkboxes, ✓ and rows that open the '
        'detail', (tester) async {
      h.serveQueue(rows);
      h.stubRequest(
        aRequest(id: 1, serial: 571, status: PurchaseRequestStatus.submitted),
      );
      final router = await pumpQueue(tester);

      expect(key('purchase_request_select_all'), findsOneWidget);
      expect(key('purchase_request_select_1'), findsOneWidget);
      expect(key('purchase_request_approve_1'), findsOneWidget);
      expect(key('purchase_request_approve_selected'), findsOneWidget);

      await tester.tap(key('purchase_request_folio_1'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/purchases/requests/1');
    });

    testWidgets('96 update without 86 read: checkboxes and ✓, but rows '
        "don't respond", (tester) async {
      h.serveQueue(rows);
      final router = await pumpQueue(tester, requestRights: 0);

      expect(key('purchase_request_select_1'), findsOneWidget);
      expect(key('purchase_request_approve_1'), findsOneWidget);

      await tester.tap(key('purchase_request_folio_1'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, purchaseRequestApprovalPath);
    });

    testWidgets('96 read only: no checkboxes, no ✓, no bulk button', (
      tester,
    ) async {
      h.serveQueue(rows);
      await pumpQueue(tester, approvalRights: 2);

      expect(key('purchase_request_folio_1'), findsOneWidget);
      expect(key('purchase_request_select_all'), findsNothing);
      expect(key('purchase_request_select_1'), findsNothing);
      expect(key('purchase_request_approve_1'), findsNothing);
      expect(key('purchase_request_approve_selected'), findsNothing);
    });

    testWidgets('the empty queue says so', (tester) async {
      h.serveQueue(const []);
      await pumpQueue(tester);

      expect(find.text(l10n.purchaseRequestQueueEmpty), findsOneWidget);
    });
  });

  group('selection', () {
    FilledButton bulk(WidgetTester tester) =>
        tester.widget<FilledButton>(key('purchase_request_approve_selected'));

    testWidgets('the bulk button is disabled until rows are picked, then '
        'counts them', (tester) async {
      h.serveQueue(rows);
      await pumpQueue(tester);

      expect(bulk(tester).onPressed, isNull);
      expect(find.text(l10n.purchaseRequestApproveSelected('0')), findsOne);

      await tester.tap(key('purchase_request_select_1'));
      await tester.tap(key('purchase_request_select_2'));
      await tester.pumpAndSettle();

      expect(bulk(tester).onPressed, isNotNull);
      expect(find.text(l10n.purchaseRequestApproveSelected('2')), findsOne);
    });

    testWidgets('tapping a checkbox does not open the detail', (tester) async {
      h.serveQueue(rows);
      final router = await pumpQueue(tester);

      await tester.tap(key('purchase_request_select_1'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, purchaseRequestApprovalPath);
      expect(
        tester.widget<Checkbox>(key('purchase_request_select_1')).value,
        isTrue,
      );
    });

    testWidgets('select-all picks the page, and again clears it', (
      tester,
    ) async {
      h.serveQueue(rows);
      await pumpQueue(tester);

      await tester.tap(key('purchase_request_select_all'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.purchaseRequestApproveSelected('3')), findsOne);
      expect(
        tester.widget<Checkbox>(key('purchase_request_select_all')).value,
        isTrue,
      );

      await tester.tap(key('purchase_request_select_all'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.purchaseRequestApproveSelected('0')), findsOne);
    });

    testWidgets('changing page clears the selection', (tester) async {
      h.serveQueue([...rows, for (var id = 10; id < 32; id++) row(id, id)]);
      final router = await pumpQueue(tester);

      await tester.tap(key('purchase_request_select_1'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.purchaseRequestApproveSelected('1')), findsOne);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['page'], isNotNull);
      expect(h.queueCalls.last.skip, 20);
      expect(find.text(l10n.purchaseRequestApproveSelected('0')), findsOne);
    });
  });

  group('the facility facet', () {
    testWidgets('lives in the filter sheet, not in the row', (tester) async {
      h.serveQueue(rows);
      await pumpQueue(tester);

      expect(key('purchase_request_approval_filter_facility'), findsNothing);

      await tester.tap(key('purchase_request_approval_filter_button'));
      await tester.pumpAndSettle();

      expect(key('purchase_request_approval_filter_facility'), findsOneWidget);
    });

    testWidgets('a chosen facility reaches the server and counts in the '
        'badge', (tester) async {
      h.serveQueue(rows);
      await pumpQueue(
        tester,
        location: '$purchaseRequestApprovalPath?facility=4',
      );

      expect(h.queueCalls.single.facilityId, 4);
      final badge = tester.widget<Badge>(
        find.ancestor(
          of: key('purchase_request_approval_filter_button'),
          matching: find.byType(Badge),
        ),
      );
      expect(badge.isLabelVisible, isTrue);
      expect(
        find.descendant(of: find.byWidget(badge), matching: find.text('1')),
        findsOneWidget,
      );
    });

    testWidgets('without Facilities read there is no filters button', (
      tester,
    ) async {
      h.serveQueue(rows);
      await pumpQueue(tester, facilitiesRead: false);

      expect(key('purchase_request_approval_filter_button'), findsNothing);
      expect(key('purchase_request_folio_1'), findsOneWidget);
    });

    testWidgets('an empty filtered queue offers "Limpiar filtros"', (
      tester,
    ) async {
      h.serveQueue(const []);
      final router = await pumpQueue(
        tester,
        location: '$purchaseRequestApprovalPath?facility=4',
      );

      await tester.tap(key('list_state_clear_filters_button'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(h.queueCalls.last.facilityId, isNull);
    });
  });

  group('approving', () {
    testWidgets('the row ✓ asks, approves, says so and reloads the queue', (
      tester,
    ) async {
      h.serveQueue(rows);
      when(() => h.requests.approve(1)).thenAnswer(
        (_) async => aRequest(
          id: 1,
          serial: 571,
          status: PurchaseRequestStatus.approved,
        ),
      );
      await pumpQueue(tester);

      await tester.tap(key('purchase_request_approve_1'));
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

      h.serveQueue([rows[0], rows[2]]);
      await tester.tap(key('purchase_request_approve_submit'));
      await tester.pumpAndSettle();

      verify(() => h.requests.approve(1)).called(1);
      expect(find.text(l10n.purchaseRequestApprovedSnack('571')), findsOne);
      expect(h.queueCalls, hasLength(2));
      expect(key('purchase_request_folio_1'), findsNothing);
    });

    testWidgets('bulk: all approved gives the SnackBar, and the queue reloads '
        'with nothing selected', (tester) async {
      h.serveQueue(rows);
      when(() => h.requests.approveMany(any())).thenAnswer(
        (_) async => const [
          BulkApproveOutcome(requestId: 1, approved: true),
          BulkApproveOutcome(requestId: 2, approved: true),
        ],
      );
      await pumpQueue(tester);

      await tester.tap(key('purchase_request_select_1'));
      await tester.tap(key('purchase_request_select_2'));
      await tester.pumpAndSettle();
      h.serveQueue([rows[0]]);
      await tester.tap(key('purchase_request_approve_selected'));
      await tester.pumpAndSettle();

      final ids =
          verify(() => h.requests.approveMany(captureAny())).captured.single
              as List<int>;
      expect(ids.toSet(), {1, 2});
      expect(find.text(l10n.purchaseRequestBulkApprovedSnack('2')), findsOne);
      expect(key('purchase_request_bulk_result_dialog'), findsNothing);
      expect(h.queueCalls, hasLength(2));
      expect(find.text(l10n.purchaseRequestApproveSelected('0')), findsOne);
    });

    testWidgets('bulk: a refused one gives the result dialog naming its '
        'folio, facility and Spanish reason', (tester) async {
      h.serveQueue(rows);
      when(() => h.requests.approveMany(any())).thenAnswer(
        (_) async => [
          const BulkApproveOutcome(requestId: 1, approved: true),
          const BulkApproveOutcome(requestId: 2, approved: true),
          BulkApproveOutcome(
            requestId: 3,
            approved: false,
            problem: ApiProblem(
              codeName: 'purchase_request.not_submitted',
              code: api.ErrorCode.purchaseRequestPeriodNotSubmitted,
              detail: 'SERVER TEXT',
            ),
          ),
        ],
      );
      await pumpQueue(tester);

      await tester.tap(key('purchase_request_select_all'));
      await tester.pumpAndSettle();
      h.serveQueue(const []);
      await tester.tap(key('purchase_request_approve_selected'));
      await tester.pumpAndSettle();

      expect(key('purchase_request_bulk_result_dialog'), findsOneWidget);
      expect(
        find.text(l10n.purchaseRequestBulkResultSummary('2', '3')),
        findsOneWidget,
      );
      expect(
        find.text(
          l10n.purchaseRequestBulkResultRefusedItem(
            '318',
            'Sucursal 5',
            l10n.apiErrorPurchaseRequestNotSubmitted,
          ),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('SERVER TEXT'), findsNothing);
      expect(h.queueCalls, hasLength(2));

      await tester.tap(key('purchase_request_bulk_result_close'));
      await tester.pumpAndSettle();
      expect(key('purchase_request_bulk_result_dialog'), findsNothing);
    });
  });
}
