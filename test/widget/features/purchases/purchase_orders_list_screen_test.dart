import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US2 (T017): the Órdenes de compra list's default view. The
/// route gate is covered in `app_router_test.dart`.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  final reader = PurchasesHarness.user(requestRights: 0, orderRights: 2);
  final creator = PurchasesHarness.user(
    requestRights: 0,
    orderRights: 2 | 1,
    suppliersRead: true,
  );

  final rows = [
    anOrderSummary(
      id: 5534,
      supplierName: 'Tornillería del Centro y Asociados de Monterrey',
      estimatedReceiptDate: DateTime(2026, 12, 5),
      lineCount: 3,
      total: '1240.00',
    ),
    anOrderSummary(
      id: 5531,
      status: InventoryDocumentStatus.completed,
      lineCount: 12,
      total: '18903.50',
    ),
    anOrderSummary(
      id: 5520,
      status: InventoryDocumentStatus.cancelled,
      supplierId: null,
      supplierName: null,
      lineCount: 0,
      total: '0',
    ),
  ];

  Future<void> pumpList(WidgetTester tester, {required User who}) =>
      h.pump(tester, who: who, location: purchaseOrdersPath);

  testWidgets('a row per order with its columns, names and chips', (
    tester,
  ) async {
    h.serveOrders(rows);
    await pumpList(tester, who: reader);

    for (final header in [
      l10n.purchaseOrderColNumber,
      l10n.purchaseOrderColSupplier,
      l10n.purchaseOrderColStatus,
      l10n.purchaseOrderColDelivery,
      l10n.purchaseOrderColCreator,
      l10n.purchaseOrderColDate,
      l10n.purchaseOrderColLines,
      l10n.purchaseOrderColTotal,
    ]) {
      expect(find.text(header), findsWidgets, reason: header);
    }
    expect(find.text('5534'), findsOneWidget);
    expect(find.text('5531'), findsOneWidget);
    expect(find.text('Ferretera del Norte'), findsOneWidget);
    expect(find.text(l10n.inventoryDocumentStatusDraft), findsOneWidget);
    expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
    expect(find.text(l10n.inventoryDocumentStatusCancelled), findsOneWidget);
    expect(find.text('2026-12-05'), findsOneWidget);
    expect(find.text('Empleado 5'), findsNWidgets(3));
    expect(tester.widget<Text>(key('purchase_order_lines_5531')).data, '12');
    expect(
      tester.widget<Text>(key('purchase_order_total_5531')).data,
      contains('18,903.50'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long supplier name is truncated with the full name in a '
      'tooltip; the total never is', (tester) async {
    h.serveOrders(rows);
    await pumpList(tester, who: reader);

    const long = 'Tornillería del Centro y Asociados de Monterrey';
    final text = tester.widget<Text>(find.text(long));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(
      find.byWidgetPredicate((w) => w is Tooltip && w.message == long),
      findsOneWidget,
    );
    final total = tester.widget<Text>(key('purchase_order_total_5534'));
    expect(total.overflow, isNull);
    expect(total.softWrap, isFalse);
  });

  testWidgets('the default view sends no scope widening, 20 per page', (
    tester,
  ) async {
    h.serveOrders(rows);
    await pumpList(tester, who: reader);

    expect(h.orderListCalls.single, (
      all: false,
      orderId: null,
      skip: 0,
      limit: 20,
    ));
  });

  testWidgets('rows carry no icons (§VI document reading)', (tester) async {
    h.serveOrders(rows);
    await pumpList(tester, who: reader);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('a row tap opens the order', (tester) async {
    h.serveOrders(rows);
    h.stubOrder(anOrder(id: 5531, status: InventoryDocumentStatus.completed));
    final router = await h.pump(
      tester,
      who: reader,
      location: purchaseOrdersPath,
    );

    await tester.tap(find.text('5531'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/purchases/orders/5531');
    expect(find.text(l10n.purchaseOrderTitle('5531')), findsOneWidget);
  });

  testWidgets('the number search sends the order id', (tester) async {
    h.serveOrders(rows);
    final router = await h.pump(
      tester,
      who: reader,
      location: purchaseOrdersPath,
    );

    await tester.enterText(
      find.descendant(
        of: key('purchase_orders_search'),
        matching: find.byType(TextField),
      ),
      '5531',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(router.state.uri.queryParameters['search'], '5531');
    expect(h.orderListCalls.last.orderId, 5531);
  });

  group('"Nueva orden"', () {
    testWidgets('is present with create on 20 and read on suppliers', (
      tester,
    ) async {
      h.serveOrders(const []);
      await pumpList(tester, who: creator);
      expect(key('purchase_orders_new_button'), findsOneWidget);
    });

    testWidgets('is absent without create on 20', (tester) async {
      h.serveOrders(const []);
      await pumpList(
        tester,
        who: PurchasesHarness.user(
          requestRights: 0,
          orderRights: 2,
          suppliersRead: true,
        ),
      );
      expect(key('purchase_orders_new_button'), findsNothing);
    });

    testWidgets('is absent without Suppliers read', (tester) async {
      h.serveOrders(const []);
      await pumpList(
        tester,
        who: PurchasesHarness.user(requestRights: 0, orderRights: 2 | 1),
      );
      expect(key('purchase_orders_new_button'), findsNothing);
    });
  });

  testWidgets('the empty state says the user has no orders', (tester) async {
    h.serveOrders(const []);
    await pumpList(tester, who: reader);

    expect(find.text(l10n.purchaseOrderEmptyMine), findsOneWidget);
  });

  testWidgets('"Todas" with nothing found has its own empty text', (
    tester,
  ) async {
    h.serveOrders(const []);
    await h.pump(tester, who: reader, location: '$purchaseOrdersPath?all=true');

    expect(find.text(l10n.purchaseOrderEmptyAll), findsOneWidget);
  });

  testWidgets('a search with nothing found offers "Limpiar filtros"', (
    tester,
  ) async {
    h.serveOrders(const []);
    final router = await h.pump(
      tester,
      who: reader,
      location: '$purchaseOrdersPath?search=99',
    );

    await tester.tap(find.text(l10n.clearFiltersButton));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), purchaseOrdersPath);
  });

  testWidgets('a failure offers a retry', (tester) async {
    var calls = 0;
    when(
      () => h.orders.list(
        all: any(named: 'all'),
        status: any(named: 'status'),
        supplierId: any(named: 'supplierId'),
        creatorId: any(named: 'creatorId'),
        orderId: any(named: 'orderId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      if (calls++ == 0) throw const AppError.network();
      return PurchaseOrderPage(
        items: rows,
        total: rows.length,
        pageIndex: 0,
        pageSize: 20,
      );
    });
    await pumpList(tester, who: reader);

    await tester.tap(find.text(l10n.retryButton));
    await tester.pumpAndSettle();

    expect(find.text('5534'), findsOneWidget);
  });

  group('filters (US3, T023)', () {
    Finder filterBadge() => find.ancestor(
      of: key('purchase_orders_filter_button'),
      matching: find.byType(Badge),
    );

    Future<void> openDrawer(WidgetTester tester) async {
      await tester.tap(key('purchase_orders_filter_button'));
      await tester.pumpAndSettle();
    }

    final allReads = PurchasesHarness.user(
      requestRights: 0,
      orderRights: 2,
      suppliersRead: true,
      employeesRead: true,
    );

    testWidgets('the filter row holds only the number search, the filters '
        'button and "Nueva orden" (§VI)', (tester) async {
      h.serveOrders(rows);
      await pumpList(tester, who: creator);

      expect(key('purchase_orders_search'), findsOneWidget);
      expect(key('purchase_orders_filter_button'), findsOneWidget);
      expect(key('purchase_orders_new_button'), findsOneWidget);
      // The scope is a drawer facet, never inline in the row.
      expect(find.byType(ChoiceChip), findsNothing);
      expect(key('purchase_orders_scope_filter'), findsNothing);
      expect(tester.widget<Badge>(filterBadge()).isLabelVisible, isFalse);
    });

    testWidgets('Mostrar → Todas sends all=true and adds one to the badge', (
      tester,
    ) async {
      h.serveOrders(rows);
      final router = await h.pump(
        tester,
        who: reader,
        location: purchaseOrdersPath,
      );
      await openDrawer(tester);

      expect(
        tester.widget<ChoiceChip>(key('purchase_orders_scope_mine')).selected,
        isTrue,
      );
      await tester.tap(key('purchase_orders_scope_all'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['all'], 'true');
      expect(h.orderListCalls.last.all, isTrue);

      await tester.tap(key('filter_sheet_apply_button'));
      await tester.pumpAndSettle();
      expect(tester.widget<Badge>(filterBadge()).isLabelVisible, isTrue);
      expect(
        find.descendant(of: filterBadge(), matching: find.text('1')),
        findsOneWidget,
      );
    });

    testWidgets('a state chip sends its status', (tester) async {
      h.serveOrders(rows);
      final router = await h.pump(
        tester,
        who: reader,
        location: purchaseOrdersPath,
      );
      await openDrawer(tester);

      // Borrador, Confirmada, Cancelada.
      expect(key('purchase_orders_status_draft'), findsOneWidget);
      expect(key('purchase_orders_status_completed'), findsOneWidget);
      await tester.tap(key('purchase_orders_status_cancelled'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'cancelled');
      verify(
        () => h.orders.list(
          all: false,
          status: InventoryDocumentStatus.cancelled,
          supplierId: null,
          creatorId: null,
          orderId: null,
          from: null,
          to: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('every facet in the address reaches the repository and the '
        'badge counts each, the range as one', (tester) async {
      h.serveOrders(rows);
      await h.pump(
        tester,
        who: reader,
        location:
            '$purchaseOrdersPath?all=true&status=completed&supplier=4'
            '&creator=5&from=2026-11-01&to=2026-11-26&search=55',
      );

      verify(
        () => h.orders.list(
          all: true,
          status: InventoryDocumentStatus.completed,
          supplierId: 4,
          creatorId: 5,
          orderId: 55,
          from: DateTime(2026, 11, 1),
          to: DateTime(2026, 11, 26),
          skip: 0,
          limit: 20,
        ),
      ).called(1);
      // Mostrar, Estado, Proveedor, Creó and the date range; not the search.
      expect(
        find.descendant(of: filterBadge(), matching: find.text('5')),
        findsOneWidget,
      );
    });

    testWidgets('the pickers appear only with read on their catalogs', (
      tester,
    ) async {
      h.serveOrders(rows);
      await pumpList(tester, who: allReads);
      await openDrawer(tester);

      expect(key('purchase_orders_scope_filter'), findsOneWidget);
      expect(key('purchase_orders_status_filter'), findsOneWidget);
      expect(key('purchase_orders_supplier_filter'), findsOneWidget);
      expect(key('purchase_orders_creator_filter'), findsOneWidget);
      expect(key('purchase_orders_date_filter'), findsOneWidget);
    });

    testWidgets('without catalog reads only Mostrar, Estado and Fecha are '
        'offered', (tester) async {
      h.serveOrders(rows);
      await pumpList(tester, who: reader);
      await openDrawer(tester);

      expect(key('purchase_orders_scope_filter'), findsOneWidget);
      expect(key('purchase_orders_status_filter'), findsOneWidget);
      expect(key('purchase_orders_date_filter'), findsOneWidget);
      expect(key('purchase_orders_supplier_filter'), findsNothing);
      expect(key('purchase_orders_creator_filter'), findsNothing);
    });

    testWidgets('"Limpiar todo" in the drawer empties the facets and keeps the '
        'number', (tester) async {
      h.serveOrders(rows);
      final router = await h.pump(
        tester,
        who: reader,
        location: '$purchaseOrdersPath?search=55&all=true&status=draft',
      );
      await openDrawer(tester);

      await tester.tap(find.text(l10n.clearAllFilters));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {'search': '55'});
    });

    testWidgets('the filtered-empty state clears every filter', (tester) async {
      h.serveOrders(const []);
      final router = await h.pump(
        tester,
        who: reader,
        location: '$purchaseOrdersPath?search=999&status=completed',
      );

      expect(find.text(l10n.purchaseOrderEmptyMine), findsNothing);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(h.orderListCalls.last, (
        all: false,
        orderId: null,
        skip: 0,
        limit: 20,
      ));
      expect(find.text(l10n.purchaseOrderEmptyMine), findsOneWidget);
    });
  });
}
