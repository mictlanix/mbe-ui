import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/kardex_fixtures.dart';
import '../../../unit/features/inventory/stock_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 071 US3 (T022): the Kardex. The route gate is covered in
/// `app_router_test.dart`.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = InventoryHarness());

  const ready =
      '/inventory/kardex?product=7&warehouse=3&from=2026-10-19&to=2026-11-17';

  Finder inTable(String text) =>
      find.descendant(of: key('kardex_table'), matching: find.text(text));

  Finder inStrip(String strip, String text) =>
      find.descendant(of: key(strip), matching: find.text(text));

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('kardex_filter_button'));
    await tester.pumpAndSettle();
  }

  Future<void> nextPage(WidgetTester tester) async {
    final next = find.descendant(
      of: key('kardex_table'),
      matching: find.byIcon(Icons.chevron_right),
    );
    await tester.tap(next);
    await tester.pumpAndSettle();
  }

  /// [n] movements without a document, each showing "#{i}".
  List<KardexMovement> manyMovements(int n) => [
    for (var i = 1; i <= n; i++)
      aKardexMovement(id: i, sourceType: 10, reference: i, document: null),
  ];

  /// A user with Kardex (32) read plus read on the given document objects.
  User readerOf(List<SystemObject> objects) =>
      InventoryHarness.kardexUser().copyWith(
        privileges: [
          ...InventoryHarness.kardexUser().privileges,
          for (final o in objects) Privilege(systemObject: o, rawValue: 2),
        ],
      );

  String date(DateTime d) =>
      h.container.read(formattersProvider).display.date(d);

  group('selection', () {
    testWidgets('the range defaults to the last 30 days, shown as real '
        'dates', (tester) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(tester);

      final defaults = KardexSelection.initial();
      expect(
        inStrip(
          'kardex_selection',
          l10n.dateRangeFilterRange(date(defaults.from), date(defaults.to)),
        ),
        findsOneWidget,
      );
      expect(
        defaults.to.difference(defaults.from).inDays,
        29,
        reason: '30 days, both ends inclusive',
      );
    });

    testWidgets('incomplete: the prompt, no request, and "Elegir" opens the '
        'sheet', (tester) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(tester, location: '/inventory/kardex?warehouse=3');

      expect(find.text(l10n.inventoryKardexIncompletePrompt), findsOneWidget);
      expect(h.kardexRequests, isEmpty);
      expect(key('kardex_table'), findsNothing);

      await tester.tap(key('list_state_empty_create_button'));
      await tester.pumpAndSettle();

      expect(key('kardex_product_filter'), findsOneWidget);
      expect(key('kardex_warehouse_filter'), findsOneWidget);
      expect(key('date_range_filter_chip'), findsOneWidget);
    });

    testWidgets('a reversed range shows its text and makes no request', (
      tester,
    ) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(
        tester,
        location:
            '/inventory/kardex?product=7&warehouse=3&from=2026-11-17&to=2026-11-01',
      );

      expect(find.text(l10n.inventoryKardexRangeReversed), findsOneWidget);
      expect(h.kardexRequests, isEmpty);
      expect(key('kardex_summary'), findsNothing);
    });

    testWidgets('a range over 366 days shows its text and makes no request', (
      tester,
    ) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(
        tester,
        location:
            '/inventory/kardex?product=7&warehouse=3&from=2025-01-01&to=2026-11-17',
      );

      expect(
        find.text(l10n.inventoryKardexRangeTooLong('366')),
        findsOneWidget,
      );
      expect(h.kardexRequests, isEmpty);
    });

    testWidgets('the selection strip names the product, warehouse and range', (
      tester,
    ) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(tester, location: ready);

      expect(
        inStrip('kardex_selection', 'A-100 Tornillo 1/4 caja'),
        findsOneWidget,
      );
      expect(inStrip('kardex_selection', 'Almacén 3'), findsOneWidget);
      expect(
        inStrip(
          'kardex_selection',
          l10n.dateRangeFilterRange(
            date(DateTime(2026, 10, 19)),
            date(DateTime(2026, 11, 17)),
          ),
        ),
        findsOneWidget,
      );
      expect(h.kardexRequests.single.productId, 7);
      expect(h.kardexRequests.single.warehouseId, 3);
      expect(h.kardexRequests.single.from, DateTime(2026, 10, 19));
      expect(h.kardexRequests.single.to, DateTime(2026, 11, 17));
    });

    testWidgets('the range chip shows real dates, and its clear restores the '
        'last 30 days', (tester) async {
      h.serveKardex(aKardex());
      final router = await h.pumpKardex(
        tester,
        location:
            '/inventory/kardex?product=7&warehouse=3&from=2026-01-01&to=2026-01-31',
      );
      await openFilters(tester);

      final chip = key('date_range_filter_chip');
      expect(
        find.descendant(
          of: chip,
          matching: find.text(
            l10n.dateRangeFilterRange(
              date(DateTime(2026, 1, 1)),
              date(DateTime(2026, 1, 31)),
            ),
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: chip, matching: find.byIcon(Icons.close)),
      );
      await tester.pumpAndSettle();

      final defaults = KardexSelection.initial();
      expect(
        KardexSelection.fromUri(router.state.uri),
        KardexSelection(
          productId: 7,
          warehouseId: 3,
          from: defaults.from,
          to: defaults.to,
        ),
      );
    });

    testWidgets('the Producto facet is absent without Products read', (
      tester,
    ) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(
        tester,
        who: InventoryHarness.kardexUser(productsRead: false),
        location: ready,
      );
      await openFilters(tester);

      expect(key('kardex_product_filter'), findsNothing);
      expect(key('kardex_warehouse_filter'), findsOneWidget);
      // The strip falls back to the id.
      expect(inStrip('kardex_selection', '#7'), findsOneWidget);
    });

    testWidgets('the bar has the filters button only', (tester) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(tester, location: ready);

      final bar = tester.widget<CatalogFilterBar>(
        find.byType(CatalogFilterBar),
      );
      expect(bar.search, isNull);
      expect(bar.actions, isEmpty);
      expect(bar.filters, hasLength(1));
    });
  });

  group('pushed page', () {
    const page =
        '/inventory/kardex/view?product=7&warehouse=3&from=2026-01-01&to=2026-01-31';

    /// The product view, then the Kardex page pushed over it.
    Future<GoRouter> pumpPushed(WidgetTester tester) async {
      h.serveKardex(aKardex());
      final router = await h.pumpProductStock(
        tester,
        aProductStock(),
        who: InventoryHarness.stockUser(kardex: 2),
      );
      router.push(page);
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('has an app bar titled Kardex with back and no actions', (
      tester,
    ) async {
      await pumpPushed(tester);

      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.navInventoryKardex),
        ),
        findsOneWidget,
      );
      expect(find.byType(BackButton), findsOneWidget);
      expect(bar.actions, isNull);
    });

    testWidgets('a range change replaces the page, keeping the product view '
        'under it', (tester) async {
      final router = await pumpPushed(tester);
      await openFilters(tester);

      await tester.tap(
        find.descendant(
          of: key('date_range_filter_chip'),
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pumpAndSettle();

      final defaults = KardexSelection.initial();
      expect(router.state.uri.path, kardexPagePath);
      expect(
        KardexSelection.fromUri(router.state.uri),
        KardexSelection(
          productId: 7,
          warehouseId: 3,
          from: defaults.from,
          to: defaults.to,
        ),
      );

      await tester.tap(find.text(l10n.applyFilters));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/inventory/stock/products/7');
      expect(key('product_stock_kardex_3'), findsOneWidget);
    });

    testWidgets('the tab has no app bar of its own', (tester) async {
      h.serveKardex(aKardex());
      await h.pumpKardex(tester, location: ready);

      expect(find.byType(AppBar), findsNothing);
    });
  });

  group('populated', () {
    testWidgets('the summary strip and the rows in server order, with a '
        'negative balance', (tester) async {
      h.serveKardex(
        aKardex(
          opening: '80',
          totalIn: '60',
          totalOut: '95',
          closing: '-7',
          movements: [
            aKardexMovement(
              id: 3,
              date: DateTime(2026, 11, 5, 8),
              quantityIn: '60',
              balance: '140',
            ),
            aKardexMovement(
              id: 1,
              date: DateTime(2026, 10, 20, 9, 14),
              sourceType: 1,
              reference: 88,
              document: const KardexDocumentRef(type: 1, id: 88, serial: 1023),
              quantityOut: '147',
              balance: '-7',
            ),
          ],
        ),
      );
      await h.pumpKardex(tester, location: ready);

      expect(inStrip('kardex_summary', '80'), findsOneWidget);
      expect(inStrip('kardex_summary', '60'), findsOneWidget);
      expect(inStrip('kardex_summary', '95'), findsOneWidget);
      expect(inStrip('kardex_summary', '-7'), findsOneWidget);
      for (final label in [
        l10n.inventoryKardexSummaryOpening,
        l10n.inventoryKardexSummaryIn,
        l10n.inventoryKardexSummaryOut,
        l10n.inventoryKardexSummaryClosing,
      ]) {
        expect(inStrip('kardex_summary', label), findsOneWidget);
      }

      final fmt = h.container.read(formattersProvider);
      final first = inTable(fmt.display.dateTime(DateTime(2026, 11, 5, 8)));
      final second = inTable(
        fmt.display.dateTime(DateTime(2026, 10, 20, 9, 14)),
      );
      expect(first, findsOneWidget);
      expect(second, findsOneWidget);
      // Server order, not date order.
      expect(
        tester.getTopLeft(first).dy,
        lessThan(tester.getTopLeft(second).dy),
      );
      expect(inTable('147'), findsOneWidget);
      expect(inTable('-7'), findsOneWidget);
      expect(inTable('1023'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Spanish source labels from the type', (tester) async {
      h.serveKardex(
        aKardex(
          movements: [
            aKardexMovement(id: 1, sourceType: 4),
            aKardexMovement(id: 2, sourceType: 12),
            aKardexMovement(id: 3, sourceType: 10, document: null),
            aKardexMovement(id: 4, sourceType: 99, document: null),
          ],
        ),
      );
      await h.pumpKardex(tester, location: ready);

      expect(
        inTable(l10n.inventoryKardexSourceWarehouseReceipt),
        findsOneWidget,
      );
      expect(inTable(l10n.inventoryKardexSourceCount), findsOneWidget);
      expect(
        inTable(l10n.inventoryKardexSourceDeliveryItinerary),
        findsOneWidget,
      );
      expect(inTable(l10n.inventoryKardexSourceFallback), findsOneWidget);
    });

    testWidgets('a row with no document and reference 0 shows "—"', (
      tester,
    ) async {
      h.serveKardex(
        aKardex(
          movements: [
            aKardexMovement(
              id: 1,
              sourceType: 99,
              reference: 0,
              document: null,
            ),
          ],
        ),
      );
      await h.pumpKardex(tester, location: ready);

      expect(inTable('—'), findsOneWidget);
    });

    testWidgets('no movements: the summary strip and the text', (tester) async {
      h.serveKardex(
        aKardex(
          opening: '80',
          totalIn: '0',
          totalOut: '0',
          closing: '80',
          movements: const [],
        ),
      );
      await h.pumpKardex(tester, location: ready);

      expect(key('kardex_summary'), findsOneWidget);
      expect(find.text(l10n.inventoryKardexEmpty), findsOneWidget);
      expect(key('kardex_table'), findsNothing);
    });

    testWidgets('a coded error renders in Spanish, never the server text', (
      tester,
    ) async {
      h.stubKardex(
        (_) async => throw aRefusal(
          api.ErrorCode.kardexPeriodRangeTooLong,
          'kardex.range_too_long',
          {'max_days': 366},
        ),
      );
      await h.pumpKardex(tester, location: ready);

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(
        find.textContaining(l10n.apiErrorKardexRangeTooLong('366')),
        findsOneWidget,
      );
      expect(find.textContaining('SERVER TEXT'), findsNothing);
    });

    testWidgets('a read error offers retry', (tester) async {
      h.stubKardex((_) async => throw const AppError.network());
      await h.pumpKardex(tester, location: ready);

      expect(find.text(l10n.retryButton), findsOneWidget);
    });
  });

  group('document links', () {
    final linked = [
      aKardexMovement(
        id: 1,
        sourceType: 12,
        reference: 41,
        document: const KardexDocumentRef(type: 12, id: 41),
      ),
      aKardexMovement(
        id: 2,
        sourceType: 4,
        reference: 57,
        document: const KardexDocumentRef(type: 4, id: 57, serial: 31),
      ),
      aKardexMovement(
        id: 3,
        sourceType: 1,
        reference: 88,
        document: const KardexDocumentRef(type: 1, id: 88, serial: 1023),
      ),
    ];
    final readsAll = [
      SystemObject.physicalCountAdjustment,
      SystemObject.inventoryReceipts,
      SystemObject.salesOrders,
    ];

    for (final (movementId, label, path) in [
      (1, '#41', '/inventory/counts/41'),
      (2, '31', '/inventory/receipts/57'),
      (3, '1023', '/sales/orders/88'),
    ]) {
      testWidgets('a linked row ($path) reads as a link and pushes its route', (
        tester,
      ) async {
        h.serveKardex(aKardex(movements: linked));
        final router = await h.pumpKardex(
          tester,
          who: readerOf(readsAll),
          location: ready,
        );

        final cell = key('kardex_doc_$movementId');
        expect(cell, findsOneWidget);
        final text = tester.widget<Text>(cell);
        expect(text.data, label);
        expect(text.style?.decoration, TextDecoration.underline);

        await tester.tap(cell);
        await tester.pumpAndSettle();

        expect(router.state.uri.path, path);
      });
    }

    testWidgets('without the read right the row is plain and does nothing', (
      tester,
    ) async {
      h.serveKardex(aKardex(movements: linked));
      final router = await h.pumpKardex(tester, location: ready);

      for (final id in [1, 2, 3]) {
        expect(key('kardex_doc_$id'), findsNothing);
      }
      await tester.tap(inTable('31'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, kardexPath);
    });

    testWidgets('an itinerary and a purchase order show "#{reference}" and do '
        'nothing', (tester) async {
      h.serveKardex(
        aKardex(
          movements: [
            aKardexMovement(
              id: 1,
              sourceType: 10,
              reference: 344,
              document: null,
            ),
            aKardexMovement(
              id: 2,
              sourceType: 6,
              reference: 12,
              document: null,
            ),
          ],
        ),
      );
      final router = await h.pumpKardex(
        tester,
        who: readerOf(readsAll),
        location: ready,
      );

      expect(inTable('#344'), findsOneWidget);
      expect(inTable('#12'), findsOneWidget);
      expect(key('kardex_doc_1'), findsNothing);
      expect(key('kardex_doc_2'), findsNothing);

      await tester.tap(inTable('#344'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, kardexPath);
    });
  });

  group('paging', () {
    testWidgets('250 rows show 100 at a time, the pager moves, and a new '
        'selection returns to page 1', (tester) async {
      h.serveKardex(aKardex(movements: manyMovements(250)));
      final router = await h.pumpKardex(tester, location: ready);

      expect(inTable('#1'), findsOneWidget);
      expect(inTable('#100'), findsOneWidget);
      expect(inTable('#101'), findsNothing);

      await nextPage(tester);
      expect(inTable('#1'), findsNothing);
      expect(inTable('#101'), findsOneWidget);
      expect(inTable('#200'), findsOneWidget);

      await nextPage(tester);
      expect(inTable('#201'), findsOneWidget);
      expect(inTable('#250'), findsOneWidget);

      router.go(
        '/inventory/kardex?product=7&warehouse=4&from=2026-10-19&to=2026-11-17',
      );
      await tester.pumpAndSettle();
      expect(inTable('#1'), findsOneWidget);
      expect(inTable('#201'), findsNothing);
    });

    testWidgets('5,000 rows render the first page and page to the last '
        'without an exception', (tester) async {
      h.serveKardex(aKardex(movements: manyMovements(5000)));
      await h.pumpKardex(tester, location: ready);

      expect(inTable('#1'), findsOneWidget);
      expect(inTable('#101'), findsNothing);
      expect(tester.takeException(), isNull);

      for (var i = 1; i < 50; i++) {
        await nextPage(tester);
      }

      expect(inTable('#4901'), findsOneWidget);
      expect(inTable('#5000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
