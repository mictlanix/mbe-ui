import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 079 US1 (T012, T019): the Solicitudes de compra list's default
/// view; US3 (T026, T028): the folio search and the filter drawer. The route
/// gate is covered in `app_router_test.dart`.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  final rows = [
    aRequestSummary(lineCount: 0),
    aRequestSummary(
      id: 230,
      serial: 571,
      status: PurchaseRequestStatus.submitted,
      lineCount: 7,
    ),
    // A rejected request: a draft that keeps its folio.
    aRequestSummary(id: 228, serial: 569, lineCount: 3),
  ];

  testWidgets('a row per request: a never-submitted draft reads "Borrador '
      '#id", a numbered one its folio, with names, chips and line counts', (
    tester,
  ) async {
    h.serve(rows);
    await h.pump(tester);

    for (final header in [
      l10n.purchaseRequestColFolio,
      l10n.purchaseRequestColFacility,
      l10n.purchaseRequestColWarehouse,
      l10n.purchaseRequestColStatus,
      l10n.purchaseRequestColCreator,
      l10n.purchaseRequestColDate,
      l10n.purchaseRequestColLines,
    ]) {
      expect(find.text(header), findsWidgets, reason: header);
    }
    expect(find.text(l10n.purchaseRequestDraftFolio('212')), findsOneWidget);
    expect(find.text('571'), findsOneWidget);
    expect(find.text('569'), findsOneWidget);
    expect(find.text('Almacén 3'), findsNWidgets(3));
    expect(find.text('Sucursal 2'), findsNWidgets(3));
    expect(find.text('Empleado 5'), findsNWidgets(3));
    expect(find.text(l10n.purchaseRequestStatusDraft), findsNWidgets(2));
    expect(find.text(l10n.purchaseRequestStatusSubmitted), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the default view sends no scope widening (FR-002)', (
    tester,
  ) async {
    h.serve(rows);
    await h.pump(tester);

    expect(h.listCalls.single, (all: false, serial: null, skip: 0, limit: 20));
  });

  testWidgets('rows carry no icons (§VI document reading)', (tester) async {
    h.serve(rows);
    await h.pump(tester);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('a row tap opens the request', (tester) async {
    h.serve(rows);
    h.stubRequest(aRequest(id: 230, serial: 571));
    final router = await h.pump(tester);

    await tester.tap(find.text('571'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/purchases/requests/230');
    expect(find.text(l10n.purchaseRequestTitle('571')), findsOneWidget);
  });

  testWidgets('the empty state says the user has no requests', (tester) async {
    h.serve(const []);
    await h.pump(tester);

    expect(find.text(l10n.purchaseRequestEmptyMine), findsOneWidget);
  });

  group('"Nueva solicitud"', () {
    testWidgets('is present with create on 86 and read on 4', (tester) async {
      h.serve(const []);
      await h.pump(tester);
      expect(key('purchase_requests_new_button'), findsOneWidget);
    });

    testWidgets('is absent without create on 86', (tester) async {
      h.serve(const []);
      await h.pump(tester, who: PurchasesHarness.user(requestRights: 2 | 4));
      expect(key('purchase_requests_new_button'), findsNothing);
    });

    testWidgets('is absent without Warehouses (4) read', (tester) async {
      h.serve(const []);
      await h.pump(tester, who: PurchasesHarness.user(warehousesRead: false));
      expect(key('purchase_requests_new_button'), findsNothing);
    });
  });

  group('filters (US3)', () {
    Finder filterBadge() => find.ancestor(
      of: key('purchase_requests_filter_button'),
      matching: find.byType(Badge),
    );

    Future<void> openDrawer(WidgetTester tester) async {
      await tester.tap(key('purchase_requests_filter_button'));
      await tester.pumpAndSettle();
    }

    testWidgets('the filter row holds only the folio search, the filters '
        'button and "Nueva solicitud" (§VI)', (tester) async {
      h.serve(rows);
      await h.pump(tester);

      expect(key('purchase_requests_search'), findsOneWidget);
      expect(key('purchase_requests_filter_button'), findsOneWidget);
      expect(key('purchase_requests_new_button'), findsOneWidget);
      // The scope is a drawer facet, never inline in the row.
      expect(find.byType(SegmentedButton<bool>), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(key('purchase_requests_scope_filter'), findsNothing);
      expect(tester.widget<Badge>(filterBadge()).isLabelVisible, isFalse);
    });

    testWidgets('Mostrar → Todas in the drawer sends all=true and adds one '
        'to the badge', (tester) async {
      h.serve(rows);
      final router = await h.pump(tester);
      await openDrawer(tester);

      expect(
        tester.widget<ChoiceChip>(key('purchase_requests_scope_mine')).selected,
        isTrue,
      );
      await tester.tap(key('purchase_requests_scope_all'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['all'], 'true');
      expect(h.listCalls.last.all, isTrue);
      expect(
        tester.widget<ChoiceChip>(key('purchase_requests_scope_all')).selected,
        isTrue,
      );

      await tester.tap(key('filter_sheet_apply_button'));
      await tester.pumpAndSettle();
      final badge = tester.widget<Badge>(filterBadge());
      expect(badge.isLabelVisible, isTrue);
      expect(
        find.descendant(of: filterBadge(), matching: find.text('1')),
        findsOneWidget,
      );
    });

    testWidgets('a state chip sends its status', (tester) async {
      h.serve(rows);
      final router = await h.pump(tester);
      await openDrawer(tester);

      await tester.tap(key('purchase_requests_status_cancelled'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'cancelled');
      verify(
        () => h.requests.list(
          all: false,
          status: PurchaseRequestStatus.cancelled,
          facilityId: null,
          warehouseId: null,
          creatorId: null,
          serial: null,
          from: null,
          to: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('every facet in the address reaches the repository', (
      tester,
    ) async {
      h.serve(rows);
      await h.pump(
        tester,
        location:
            '/purchases/requests?all=true&status=approved&facility=2'
            '&warehouse=3&creator=5&from=2026-11-01&to=2026-11-26',
      );

      verify(
        () => h.requests.list(
          all: true,
          status: PurchaseRequestStatus.approved,
          facilityId: 2,
          warehouseId: 3,
          creatorId: 5,
          serial: null,
          from: DateTime(2026, 11, 1),
          to: DateTime(2026, 11, 26),
          skip: 0,
          limit: 20,
        ),
      ).called(1);
      // Mostrar, Estado, Sucursal, Almacén, Solicitó and the date range.
      expect(
        find.descendant(of: filterBadge(), matching: find.text('6')),
        findsOneWidget,
      );
    });

    testWidgets('a folio search sends serial and accepts digits only', (
      tester,
    ) async {
      h.serve(rows);
      final router = await h.pump(tester);
      final field = find.descendant(
        of: key('purchase_requests_search'),
        matching: find.byType(TextField),
      );

      await tester.enterText(field, '5a7x1');
      await tester.pump();
      expect(tester.widget<TextField>(field).controller!.text, '571');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['search'], '571');
      expect(h.listCalls.last, (all: false, serial: 571, skip: 0, limit: 20));
    });

    testWidgets('the pickers appear only with read on their catalogs', (
      tester,
    ) async {
      h.serve(rows);
      await h.pump(
        tester,
        who: PurchasesHarness.user(facilitiesRead: true, employeesRead: true),
      );
      await openDrawer(tester);

      expect(key('purchase_requests_facility_filter'), findsOneWidget);
      expect(key('purchase_requests_warehouse_filter'), findsOneWidget);
      expect(key('purchase_requests_creator_filter'), findsOneWidget);
      expect(key('purchase_requests_date_filter'), findsOneWidget);
    });

    testWidgets('without catalog reads only Mostrar, Estado and Fecha are '
        'offered', (tester) async {
      h.serve(rows);
      await h.pump(tester, who: PurchasesHarness.user(warehousesRead: false));
      await openDrawer(tester);

      expect(key('purchase_requests_scope_filter'), findsOneWidget);
      expect(key('purchase_requests_status_filter'), findsOneWidget);
      expect(key('purchase_requests_date_filter'), findsOneWidget);
      expect(key('purchase_requests_facility_filter'), findsNothing);
      expect(key('purchase_requests_warehouse_filter'), findsNothing);
      expect(key('purchase_requests_creator_filter'), findsNothing);
    });

    testWidgets('the filtered-empty state clears every filter', (tester) async {
      h.serve(const []);
      final router = await h.pump(
        tester,
        location: '/purchases/requests?search=999&status=approved',
      );

      expect(find.text(l10n.purchaseRequestEmptyMine), findsNothing);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(h.listCalls.last, (all: false, serial: null, skip: 0, limit: 20));
      expect(find.text(l10n.purchaseRequestEmptyMine), findsOneWidget);
    });

    testWidgets('the "Todas" empty state says there are none at all', (
      tester,
    ) async {
      h.serve(const []);
      await h.pump(tester, location: '/purchases/requests?all=true');

      expect(find.text(l10n.purchaseRequestEmptyAll), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });
  });
}
