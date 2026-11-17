import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 070 US1 (T013): the Conteos físicos list. The route gate is covered
/// in `app_router_test.dart`.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = InventoryHarness());

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(
      of: key('inventory_counts_filter_button'),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('inventory_counts_filter_button'));
    await tester.pumpAndSettle();
  }

  final rows = [
    aCountSummary(),
    aCountSummary(
      id: 413,
      serial: 77,
      status: InventoryDocumentStatus.completed,
    ),
    aCountSummary(id: 414, status: InventoryDocumentStatus.cancelled),
  ];

  testWidgets('a row per count: a draft and a cancelled count read '
      '"Borrador #id", a confirmed one its folio, with names and a chip', (
    tester,
  ) async {
    h.serveCounts(rows);
    await h.pumpCounts(tester);

    for (final header in [
      l10n.inventoryCountColFolio,
      l10n.inventoryCountColWarehouse,
      l10n.inventoryCountColFacility,
      l10n.inventoryCountColStatus,
      l10n.inventoryCountColCreatedBy,
      l10n.inventoryCountColDate,
    ]) {
      expect(find.text(header), findsWidgets, reason: header);
    }
    expect(find.text(l10n.inventoryCountDraftFolio('412')), findsOneWidget);
    expect(find.text(l10n.inventoryCountDraftFolio('414')), findsOneWidget);
    expect(find.text('77'), findsOneWidget);
    // Summaries carry ids only: the names come from the id lookup.
    expect(find.text('Almacén 3'), findsNWidgets(3));
    expect(find.text('Sucursal 2'), findsNWidgets(3));
    expect(find.text('Empleado 5'), findsNWidgets(3));
    // Masculine labels (research R2).
    expect(find.text(l10n.inventoryCountStatusDraft), findsOneWidget);
    expect(find.text('Confirmado'), findsOneWidget);
    expect(find.text('Cancelado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rows carry no icons (§VI document reading)', (tester) async {
    h.serveCounts(rows);
    await h.pumpCounts(tester);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });

  testWidgets('a row tap opens the count', (tester) async {
    h.serveCounts(rows);
    final router = await h.pumpCounts(tester);

    await tester.tap(find.text('77'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/counts/413');
  });

  testWidgets('there is no search control', (tester) async {
    h.serveCounts(rows);
    await h.pumpCounts(tester);

    expect(find.byType(CatalogSearchBar), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('Nuevo conteo comes first in the bar, the filters button '
      'last', (tester) async {
    h.serveCounts(rows);
    await h.pumpCounts(tester);

    final bar = tester.widget<CatalogFilterBar>(find.byType(CatalogFilterBar));
    // The bar lays out `actions` first and `filters` last.
    expect(bar.actions, hasLength(1));
    expect(
      (bar.actions.single as FilledButton).key,
      const Key('inventory_counts_new_button'),
    );
    expect(bar.filters, hasLength(1));
    expect(
      find.descendant(
        of: find.byWidget(bar.filters.single),
        matching: key('inventory_counts_filter_button'),
      ),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(key('inventory_counts_new_button')).dx,
      lessThan(tester.getTopLeft(key('inventory_counts_filter_button')).dx),
    );
  });

  testWidgets('a failed name lookup shows "#id"', (tester) async {
    h.serveCounts(rows);
    await h.pumpCounts(tester, namesFail: true);

    expect(find.text('#3'), findsNWidgets(3));
    expect(find.text('#2'), findsNWidgets(3));
    expect(find.text('#5'), findsNWidgets(3));
  });

  group('facets', () {
    testWidgets('opens unfiltered, with the badge hidden', (tester) async {
      h.serveCounts(rows);
      await h.pumpCounts(tester);

      expect(h.countRequests.single.status, isNull);
      expect(h.countRequests.single.warehouseId, isNull);
      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('status and warehouse in the address reach the repository '
        'and count on the badge', (tester) async {
      h.serveCounts(rows);
      await h.pumpCounts(
        tester,
        location: '/inventory/counts?status=draft&warehouse=3',
      );

      expect(h.countRequests.last.status, InventoryDocumentStatus.draft);
      expect(h.countRequests.last.warehouseId, 3);
      expect(badge(tester).isLabelVisible, isTrue);
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsOneWidget,
      );
    });

    testWidgets('the state chips use the masculine labels', (tester) async {
      h.serveCounts(rows);
      await h.pumpCounts(tester);
      await openFilters(tester);

      for (final (status, label) in [
        (InventoryDocumentStatus.draft, 'Borrador'),
        (InventoryDocumentStatus.completed, 'Confirmado'),
        (InventoryDocumentStatus.cancelled, 'Cancelado'),
      ]) {
        expect(
          find.descendant(
            of: key('inventory_counts_status_${status.name}'),
            matching: find.text(label),
          ),
          findsOneWidget,
          reason: status.name,
        );
      }
    });

    testWidgets('a status chip writes the address, resets the page and '
        'reaches the repository', (tester) async {
      h.serveCounts(rows);
      final router = await h.pumpCounts(
        tester,
        location: '/inventory/counts?page=3',
      );
      await openFilters(tester);

      await tester.tap(key('inventory_counts_status_completed'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'completed');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(h.countRequests.last.status, InventoryDocumentStatus.completed);
    });

    testWidgets('a picked warehouse reaches the repository', (tester) async {
      h.serveCounts(rows);
      h.serveWarehouses([aWarehouse(4, facilityId: 9)]);
      final router = await h.pumpCounts(tester);
      await openFilters(tester);

      await tester.enterText(
        find.descendant(
          of: key('inventory_counts_warehouse_filter'),
          matching: find.byType(TextField),
        ),
        'Alm',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Almacén 4').last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['warehouse'], '4');
      expect(h.countRequests.last.warehouseId, 4);
      verify(
        () => h.warehouses.list(
          search: 'Alm',
          facilityId: null,
          status: any(named: 'status'),
          limit: 10,
        ),
      ).called(greaterThan(0));
    });

    testWidgets('the warehouse facet needs Warehouses (4) read', (
      tester,
    ) async {
      h.serveCounts(rows);
      await h.pumpCounts(
        tester,
        who: InventoryHarness.countUser(warehousesRead: false),
      );
      await openFilters(tester);

      expect(key('inventory_counts_warehouse_filter'), findsNothing);
      expect(key('inventory_counts_status_filter'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('empty', (tester) async {
      h.serveCounts(const []);
      await h.pumpCounts(tester);

      expect(find.text(l10n.inventoryCountListEmpty), findsOneWidget);
    });

    testWidgets('filtered-empty offers "Limpiar filtros"', (tester) async {
      h.serveCounts(const []);
      final router = await h.pumpCounts(
        tester,
        location: '/inventory/counts?status=cancelled',
      );

      expect(find.text(l10n.inventoryCountListEmpty), findsNothing);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(h.countRequests.last.status, isNull);
    });

    testWidgets('a read error shows the banner', (tester) async {
      h.stubCountList((_) async => throw const AppError.network());
      await h.pumpCounts(tester);

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(l10n.retryButton), findsOneWidget);
    });
  });
}
