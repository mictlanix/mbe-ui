import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/sales/delivery_itinerary_fixtures.dart';
import 'delivery_itinerary_harness.dart';

typedef _Request = ({
  ItineraryStatus? status,
  DateTime? dateFrom,
  DateTime? dateTo,
  int? vehicleId,
  int? operatorId,
  int? warehouseId,
  int skip,
  int limit,
});

/// Spec 075 FR-002 to FR-005 (US4): the "Itinerarios" list.
void main() {
  late AppLocalizations l10n;
  late MockDeliveryItineraryRepository repository;
  late List<_Request> requests;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(ItineraryStatus.open);
  });

  setUp(() {
    repository = MockDeliveryItineraryRepository();
    requests = [];
  });

  void serve(List<ItinerarySummary> items, {int? total}) =>
      when(
        () => repository.list(
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          vehicleId: any(named: 'vehicleId'),
          operatorId: any(named: 'operatorId'),
          warehouseId: any(named: 'warehouseId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((i) async {
        requests.add((
          status: i.namedArguments[#status] as ItineraryStatus?,
          dateFrom: i.namedArguments[#dateFrom] as DateTime?,
          dateTo: i.namedArguments[#dateTo] as DateTime?,
          vehicleId: i.namedArguments[#vehicleId] as int?,
          operatorId: i.namedArguments[#operatorId] as int?,
          warehouseId: i.namedArguments[#warehouseId] as int?,
          skip: i.namedArguments[#skip] as int,
          limit: i.namedArguments[#limit] as int,
        ));
        return ItineraryPage(items: items, total: total ?? items.length);
      });

  Future<GoRouter> pumpList(
    WidgetTester tester, {
    String location = '/sales/delivery-itineraries',
    Set<AccessRight> rights = const {AccessRight.read},
    bool vehiclesRead = true,
    bool operatorsRead = true,
    bool warehousesRead = true,
    Size surface = const Size(1400, 900),
  }) => pumpItineraryApp(
    tester,
    location: location,
    routes: [
      GoRoute(
        path: '/sales/delivery-itineraries',
        builder: (_, state) => Scaffold(
          body: DeliveryItinerariesListScreen(
            query: ListQuery.fromUri(state.uri),
          ),
        ),
      ),
      GoRoute(
        path: '/sales/delivery-itineraries/:id',
        builder: (_, s) =>
            Scaffold(body: Text('trip-${s.pathParameters['id']}')),
      ),
    ],
    repository: repository,
    access: itineraryAccess(
      rights: rights,
      vehiclesRead: vehiclesRead,
      operatorsRead: operatorsRead,
      warehousesRead: warehousesRead,
    ),
    surface: surface,
  );

  Finder key(String k) => find.byKey(Key(k));

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(
      of: key('delivery_itineraries_filter_button'),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('delivery_itineraries_filter_button'));
    await tester.pumpAndSettle();
  }

  group('the table', () {
    testWidgets('lists the trips with the names the server sent', (
      tester,
    ) async {
      serve([
        fakeItinerarySummary(id: 58),
        fakeItinerarySummary(id: 57, status: ItineraryStatus.departed),
      ]);
      await pumpList(tester);

      expect(requests.single.skip, 0);
      expect(requests.single.limit, 20);
      expect(requests.single.status, isNull);
      expect(find.text('58'), findsOneWidget);
      expect(find.text('57'), findsOneWidget);
      expect(find.text('Torton · MBE-114'), findsNWidgets(2));
      expect(find.text('Juan Rivas'), findsNWidgets(2));
      expect(find.text('Bodega Norte'), findsNWidgets(2));
      expect(key('itinerary_status_chip_open'), findsOneWidget);
      expect(key('itinerary_status_chip_departed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unnamed id shows its number and no id shows a dash', (
      tester,
    ) async {
      serve([
        ItinerarySummary(
          id: 60,
          date: DateTime(2026, 11, 18),
          vehicleId: 4,
          warehouseId: null,
          status: ItineraryStatus.open,
        ),
      ]);
      await pumpList(tester);

      expect(find.text('#4'), findsOneWidget);
      // Operator, warehouse, departure and return are all unset.
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('a row has no icons, and tapping it opens the trip', (
      tester,
    ) async {
      serve([fakeItinerarySummary(id: 58)]);
      final router = await pumpList(tester, rights: itineraryWriter);

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      await tester.tap(find.text('58'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-itineraries/58');
    });

    testWidgets('page 2 asks for skip 20', (tester) async {
      // A full page, as the server sends one.
      serve([
        for (var i = 0; i < 20; i++) fakeItinerarySummary(id: 100 + i),
      ], total: 58);
      await pumpList(tester, location: '/sales/delivery-itineraries?page=2');

      expect(requests.last.skip, 20);
    });

    testWidgets('the AppBar of the page is not used: no search control', (
      tester,
    ) async {
      serve([fakeItinerarySummary()]);
      await pumpList(tester);

      // The filter bar has the drawer button and no search box (the endpoint
      // has none).
      expect(key('delivery_itineraries_filter_button'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('a compact screen shows two-line rows without the warehouse', (
      tester,
    ) async {
      serve([fakeItinerarySummary(id: 58)]);
      await pumpList(tester, surface: const Size(420, 900));

      expect(find.text(l10n.itineraryColumnWarehouse), findsNothing);
      expect(find.text(l10n.itineraryColumnReturn), findsNothing);
      expect(
        find.textContaining('Torton · MBE-114 · Juan Rivas'),
        findsOneWidget,
      );
      expect(find.text(l10n.itineraryStatusOpen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('"Nuevo itinerario"', () {
    testWidgets('is offered with create on Delivery Itineraries', (
      tester,
    ) async {
      serve(const []);
      await pumpList(tester, rights: itineraryWriter);

      expect(key('delivery_itineraries_new'), findsOneWidget);
    });

    testWidgets('is absent with read alone', (tester) async {
      serve(const []);
      await pumpList(tester);

      expect(key('delivery_itineraries_new'), findsNothing);
    });

    testWidgets('opens the dialog, and the created trip opens', (tester) async {
      serve(const []);
      final actions = FakeItineraryActions(newId: 59);
      final router = await pumpItineraryApp(
        tester,
        location: '/sales/delivery-itineraries',
        routes: [
          GoRoute(
            path: '/sales/delivery-itineraries',
            builder: (_, state) => Scaffold(
              body: DeliveryItinerariesListScreen(
                query: ListQuery.fromUri(state.uri),
              ),
            ),
          ),
          GoRoute(
            path: '/sales/delivery-itineraries/:id',
            builder: (_, s) =>
                Scaffold(body: Text('trip-${s.pathParameters['id']}')),
          ),
        ],
        repository: repository,
        actions: actions,
        access: itineraryAccess(rights: itineraryWriter),
      );

      await tester.tap(key('delivery_itineraries_new'));
      await tester.pumpAndSettle();
      expect(key('new_itinerary_dialog'), findsOneWidget);
      await tester.tap(key('new_itinerary_submit'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-itineraries/59');
    });
  });

  group('the filter drawer', () {
    testWidgets('the badge counts the facets in use, a date range as one', (
      tester,
    ) async {
      serve([fakeItinerarySummary()]);
      await pumpList(
        tester,
        location:
            '/sales/delivery-itineraries?status=1&from=2026-11-01&to=2026-11-18&vehicle=4',
      );

      expect((badge(tester).label! as Text).data, '3');
      expect(badge(tester).isLabelVisible, isTrue);
    });

    testWidgets('each facet reaches the repository', (tester) async {
      serve([fakeItinerarySummary()]);
      await pumpList(
        tester,
        location:
            '/sales/delivery-itineraries?status=1&from=2026-11-01&to=2026-11-18&vehicle=4&operator=9&warehouse=3',
      );

      final r = requests.last;
      expect(r.status, ItineraryStatus.departed);
      expect(r.dateFrom, DateTime(2026, 11, 1));
      expect(r.dateTo, DateTime(2026, 11, 18));
      expect(r.vehicleId, 4);
      expect(r.operatorId, 9);
      expect(r.warehouseId, 3);
    });

    testWidgets('a status chip writes the URL and asks the server', (
      tester,
    ) async {
      serve([fakeItinerarySummary()]);
      final router = await pumpList(tester);
      await openFilters(tester);

      await tester.tap(key('delivery_itineraries_status_closed'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], '2');
      expect(requests.last.status, ItineraryStatus.closed);
    });

    testWidgets('"Todos" clears the status facet', (tester) async {
      serve([fakeItinerarySummary()]);
      final router = await pumpList(
        tester,
        location: '/sales/delivery-itineraries?status=1',
      );
      await openFilters(tester);

      await tester.tap(key('delivery_itineraries_status_all'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters.containsKey('status'), isFalse);
      expect(requests.last.status, isNull);
    });

    testWidgets('a picker the user can not read is left out', (tester) async {
      serve([fakeItinerarySummary()]);
      await pumpList(
        tester,
        vehiclesRead: false,
        operatorsRead: false,
        warehousesRead: false,
      );
      await openFilters(tester);

      expect(key('delivery_itineraries_vehicle_filter'), findsNothing);
      expect(key('delivery_itineraries_operator_filter'), findsNothing);
      expect(key('delivery_itineraries_warehouse_filter'), findsNothing);
      // The status and date facets need no catalog.
      expect(key('delivery_itineraries_status_open'), findsOneWidget);
      expect(key('delivery_itineraries_date_filter'), findsOneWidget);
    });

    testWidgets('with every catalog readable the three pickers show', (
      tester,
    ) async {
      serve([fakeItinerarySummary()]);
      await pumpList(tester);
      await openFilters(tester);

      expect(key('delivery_itineraries_vehicle_filter'), findsOneWidget);
      expect(key('delivery_itineraries_operator_filter'), findsOneWidget);
      expect(key('delivery_itineraries_warehouse_filter'), findsOneWidget);
    });

    testWidgets('clearing one facet drops it and the badge', (tester) async {
      serve([fakeItinerarySummary()]);
      final router = await pumpList(
        tester,
        location: '/sales/delivery-itineraries?vehicle=4',
      );
      expect((badge(tester).label! as Text).data, '1');
      await openFilters(tester);

      await tester.tap(key('delivery_itineraries_vehicle_clear'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters.containsKey('vehicle'), isFalse);
      expect(requests.last.vehicleId, isNull);
      expect(badge(tester).isLabelVisible, isFalse);
    });
  });

  group('states', () {
    testWidgets('empty says there are no itineraries yet', (tester) async {
      serve(const []);
      await pumpList(tester, rights: itineraryWriter);

      expect(find.text(l10n.itinerariesEmpty), findsOneWidget);
      // "Nuevo itinerario" is still there on an empty list.
      expect(key('delivery_itineraries_new'), findsOneWidget);
    });

    testWidgets('filtered-empty offers "Limpiar filtros", which clears them', (
      tester,
    ) async {
      serve(const []);
      final router = await pumpList(
        tester,
        location: '/sales/delivery-itineraries?status=3',
      );

      expect(find.text(l10n.clearFiltersButton), findsWidgets);
      await tester.tap(find.text(l10n.clearFiltersButton).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters.containsKey('status'), isFalse);
    });

    testWidgets('a read error shows the banner and retries', (tester) async {
      var fail = true;
      when(
        () => repository.list(
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          vehicleId: any(named: 'vehicleId'),
          operatorId: any(named: 'operatorId'),
          warehouseId: any(named: 'warehouseId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        if (fail) throw const AppError.network();
        return ItineraryPage(items: [fakeItinerarySummary()], total: 1);
      });
      await pumpList(tester);

      expect(find.text(l10n.retryButton), findsOneWidget);
      fail = false;
      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(find.text('58'), findsOneWidget);
    });
  });
}
