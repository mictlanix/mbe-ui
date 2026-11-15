import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';

class _MockDeliveryOrderAdminRepository extends Mock
    implements DeliveryOrderAdminRepository {}

typedef _Request = ({
  List<DeliveryOrderStatus>? statuses,
  FulfillmentType? type,
  DateTime? dateFrom,
  DateTime? dateTo,
  int? customer,
  int? salesOrder,
  int? facility,
  String? search,
});

Customer _customer(int id) => Customer(
  customerId: id,
  code: 'C-$id',
  name: 'Cliente $id',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 11,
      label: 'Av. Juárez 120, Centro',
      type: AddressType.business,
    ),
  ],
);

/// Spec 061 US1 (T017), contracts C2 and C3: the "Órdenes de entrega" list.
/// The route gate (no Delivery Orders read is redirected) is covered in
/// `app_router_test.dart`.
void main() {
  late _MockDeliveryOrderAdminRepository repository;
  late AppLocalizations l10n;
  var requests = <_Request>[];

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    repository = _MockDeliveryOrderAdminRepository();
    requests = [];
  });

  DeliveryOrderSummary row(
    int id, {
    int? serial,
    DeliveryOrderStatus status = DeliveryOrderStatus.inPreparation,
    FulfillmentType type = FulfillmentType.delivery,
    int customer = 7,
    List<int> sales = const [8841],
  }) => DeliveryOrderSummary(
    id: id,
    facilityId: 1,
    serial: serial,
    customerId: customer,
    salesOrderIds: sales,
    shipToId: 11,
    date: DateTime(2026, 11, 15),
    priority: 0,
    status: status,
    type: type,
  );

  /// The full order [getById] answers for a list press: one line per
  /// warehouse in [warehouses].
  DeliveryOrder fullOrder(int id, List<int> warehouses, {int? serial}) =>
      DeliveryOrder(
        id: id,
        facilityId: 1,
        serial: serial ?? 1500 + id,
        customerId: 7,
        salesOrderIds: const [8841],
        shipToId: 11,
        date: DateTime(2026, 11, 15),
        priority: 0,
        status: DeliveryOrderStatus.approved,
        type: FulfillmentType.delivery,
        createdAt: DateTime(2026, 11, 14),
        modifiedAt: DateTime(2026, 11, 14),
        lines: [
          for (var i = 0; i < warehouses.length; i++)
            DeliveryOrderLine(
              id: i + 1,
              salesOrderDetailId: i + 101,
              productId: i + 1,
              productCode: 'P-${i + 1}',
              productName: 'Producto ${i + 1}',
              warehouseId: warehouses[i],
              quantity: Decimal.parse('1'),
              committed: Decimal.zero,
              delivered: Decimal.zero,
              returned: Decimal.zero,
              open: Decimal.parse('1'),
            ),
        ],
      );

  void stubList(Future<DeliveryOrderPage> Function(_Request) answer) {
    when(
      () => repository.list(
        statuses: any(named: 'statuses'),
        customer: any(named: 'customer'),
        facility: any(named: 'facility'),
        type: any(named: 'type'),
        salesOrder: any(named: 'salesOrder'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) {
      final request = (
        statuses: i.namedArguments[#statuses] as List<DeliveryOrderStatus>?,
        type: i.namedArguments[#type] as FulfillmentType?,
        dateFrom: i.namedArguments[#dateFrom] as DateTime?,
        dateTo: i.namedArguments[#dateTo] as DateTime?,
        customer: i.namedArguments[#customer] as int?,
        salesOrder: i.namedArguments[#salesOrder] as int?,
        facility: i.namedArguments[#facility] as int?,
        search: i.namedArguments[#search] as String?,
      );
      requests.add(request);
      return answer(request);
    });
  }

  /// A fake server over [all] that honours status, type and folio search.
  void serve(List<DeliveryOrderSummary> all) => stubList((r) async {
    final kept = [
      for (final o in all)
        if ((r.statuses == null || r.statuses!.contains(o.status)) &&
            (r.type == null || o.type == r.type) &&
            (r.search == null || '${o.serial}' == r.search))
          o,
    ];
    return DeliveryOrderPage(items: kept, total: kept.length);
  });

  Override access({bool customersRead = true, bool administrator = false}) =>
      accessControlProvider.overrideWithValue(
        AccessControlService(
          AuthState.authenticated(
            token: 't',
            user: User(
              userId: 'd',
              email: 'd@example.com',
              administrator: administrator,
              status: EntityStatus.active,
              sessionVersion: 1,
              privileges: [
                const Privilege(
                  systemObject: SystemObject.deliveryOrders,
                  rawValue: 2,
                ),
                if (customersRead)
                  const Privilege(
                    systemObject: SystemObject.customers,
                    rawValue: 2,
                  ),
              ],
            ),
          ),
        ),
      );

  Future<GoRouter> pumpList(
    WidgetTester tester, {
    Override? who,
    String location = '/sales/delivery-orders',
    int? facilityId = 1,
    Size surface = const Size(1400, 1000),
    bool settle = true,
    FakeDocumentSource? documents,
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        who ?? access(),
        userFacilityIdProvider.overrideWithValue(facilityId),
        deliveryOrderAdminRepositoryProvider.overrideWithValue(repository),
        documentSourceProvider.overrideWithValue(
          documents ?? FakeDocumentSource(),
        ),
        documentOutputProvider.overrideWithValue(FakeDocumentOutput()),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        customerDisplayNameProvider.overrideWith(
          (ref, id) async => 'Cliente $id',
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => 'Sucursal $id',
        ),
        saleCustomerControllerProvider.overrideWith(
          (ref, id) async => _customer(id),
        ),
        facilityWarehousesControllerProvider.overrideWith(
          (ref, facilityId) async => const [
            Warehouse(
              warehouseId: 2,
              facilityId: 1,
              facilityName: 'Sucursal 1',
              code: 'N1',
              name: 'Bodega norte',
              status: EntityStatus.active,
            ),
            Warehouse(
              warehouseId: 5,
              facilityId: 1,
              facilityName: 'Sucursal 1',
              code: 'P1',
              name: 'Patio',
              status: EntityStatus.active,
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/sales/delivery-orders',
          builder: (context, state) => Scaffold(
            body: DeliveryOrdersListScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
        GoRoute(
          path: '/sales/delivery-orders/:id',
          builder: (_, s) =>
              Scaffold(body: Text('order-${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(
      of: key('delivery_orders_filter_button'),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('delivery_orders_filter_button'));
    await tester.pumpAndSettle();
  }

  Finder searchField() => find.descendant(
    of: key('delivery_orders_search'),
    matching: find.byType(TextField),
  );

  group('opening state and table', () {
    testWidgets('opens on the active statuses at the user\'s facility with the '
        'badge at 0; a draft reads "Borrador"', (tester) async {
      serve([
        row(2, serial: 1532, sales: const [8790, 8812]),
        row(1, status: DeliveryOrderStatus.draft),
      ]);
      await pumpList(tester);

      expect(requests.single.statuses, DeliveryOrderStatus.active);
      expect(requests.single.facility, isNull);
      expect(badge(tester).isLabelVisible, isFalse);
      expect(badge(tester).label, isA<Text>());
      // The draft's folio cell and its status chip.
      expect(find.text(l10n.deliveryOrderDraftFolio), findsNWidgets(2));
      expect(key('delivery_order_status_chip_draft'), findsOneWidget);
      expect(find.text('1532'), findsOneWidget);
    });

    testWidgets('shows the seven columns, names, ship-to and joined sales', (
      tester,
    ) async {
      serve([
        row(2, serial: 1532, sales: const [8790, 8812]),
        row(1, serial: 1529, type: FulfillmentType.counterPickup),
      ]);
      await pumpList(tester);

      for (final header in [
        l10n.deliveryOrderColumnSerial,
        l10n.deliveryOrderColumnCustomer,
        l10n.deliveryOrderColumnType,
        l10n.deliveryOrderColumnScheduled,
        l10n.deliveryOrderColumnDestination,
        l10n.deliveryOrderColumnSalesOrders,
        l10n.deliveryOrderColumnStatus,
      ]) {
        expect(find.text(header), findsWidgets, reason: header);
      }
      expect(find.text('Cliente 7'), findsNWidgets(2));
      expect(find.text('8790, 8812'), findsOneWidget);
      expect(find.text('2026-11-15'), findsNWidgets(2));
      // A delivery's ship-to is the customer's address; a pickup's is the
      // facility.
      expect(find.text('Av. Juárez 120, Centro'), findsOneWidget);
      expect(find.text('Sucursal 1'), findsOneWidget);
      expect(find.text(l10n.deliveryOrderTypeDelivery), findsOneWidget);
      expect(find.text(l10n.deliveryOrderTypePickup), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a row tap opens the order', (tester) async {
      serve([row(5, serial: 1517)]);
      final router = await pumpList(tester);

      await tester.tap(find.text('1517'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-orders/5');
      expect(find.text('order-5'), findsOneWidget);
    });

    testWidgets('the compact tier drops Pedidos', (tester) async {
      serve([
        row(2, serial: 1532, sales: const [8790, 8812]),
      ]);
      await pumpList(tester, surface: const Size(400, 900));

      expect(find.text(l10n.deliveryOrderColumnSalesOrders), findsNothing);
      expect(find.text('8790, 8812'), findsNothing);
      expect(find.text('1532'), findsOneWidget);
      expect(key('delivery_order_status_chip_inPreparation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('search', () {
    testWidgets('a folio finds the order and writes the address', (
      tester,
    ) async {
      serve([row(2, serial: 1532), row(1, serial: 1529)]);
      final router = await pumpList(tester);

      await tester.enterText(searchField(), '1532');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['search'], '1532');
      expect(requests.last.search, '1532');
      expect(find.text('1532'), findsWidgets);
      expect(find.text('1529'), findsNothing);
    });

    testWidgets('letters are not accepted as a search term', (tester) async {
      serve([row(2, serial: 1532)]);
      final router = await pumpList(tester);

      await tester.enterText(searchField(), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(searchField());
      expect(field.controller!.text, isEmpty);
      expect(router.state.uri.queryParameters.containsKey('search'), isFalse);
      expect(requests.every((r) => r.search == null), isTrue);
    });

    testWidgets('a search with letters in the address is ignored', (
      tester,
    ) async {
      serve([row(2, serial: 1532)]);
      await pumpList(tester, location: '/sales/delivery-orders?search=ab1');

      expect(requests.single.search, isNull);
    });
  });

  group('facets', () {
    testWidgets('status reaches the controller and counts on the badge', (
      tester,
    ) async {
      serve([row(1)]);
      final router = await pumpList(tester);
      await openFilters(tester);

      await tester.tap(key('delivery_orders_status_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.deliveryOrderStatusFailed).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], '9');
      expect(requests.last.statuses, [DeliveryOrderStatus.failed]);
    });

    testWidgets('"Todas" asks for every status and puts status=all in the URL '
        '(mbe-api#312)', (tester) async {
      serve([row(1)]);
      final router = await pumpList(tester);
      await openFilters(tester);

      await tester.tap(key('delivery_orders_status_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.deliveryOrderFilterAllStatuses).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'all');
      expect(requests.last.statuses, isNull);
    });

    testWidgets('the drawer offers "Activas", "Todas" and the 11 statuses', (
      tester,
    ) async {
      serve([row(1)]);
      await pumpList(tester);
      await openFilters(tester);

      await tester.tap(key('delivery_orders_status_filter'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.deliveryOrderFilterActiveStatuses), findsWidgets);
      expect(find.text(l10n.deliveryOrderFilterAllStatuses), findsWidgets);
      for (final label in [
        l10n.deliveryOrderStatusPendingApproval,
        l10n.deliveryOrderStatusApproved,
        l10n.deliveryOrderStatusReadyForPickup,
        l10n.deliveryOrderStatusPickedUp,
        l10n.deliveryOrderStatusInTransit,
        l10n.deliveryOrderStatusDelivered,
        l10n.deliveryOrderStatusPartiallyDelivered,
        l10n.deliveryOrderStatusFailed,
        l10n.deliveryOrderStatusCancelled,
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('type reaches the controller', (tester) async {
      serve([row(1)]);
      final router = await pumpList(tester);
      await openFilters(tester);

      await tester.tap(key('delivery_orders_type_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.deliveryOrderTypePickup).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['type'], '0');
      expect(requests.last.type, FulfillmentType.counterPickup);
    });

    testWidgets('the sales-order field reaches the controller', (tester) async {
      serve([row(1)]);
      final router = await pumpList(tester);
      await openFilters(tester);

      await tester.enterText(key('delivery_orders_sales_order_filter'), '8841');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['order'], '8841');
      expect(requests.last.salesOrder, 8841);
    });

    testWidgets('date range and customer in the address reach the controller '
        'and count on the badge', (tester) async {
      serve([row(1)]);
      await pumpList(
        tester,
        location:
            '/sales/delivery-orders?from=2026-11-01&to=2026-11-30&customer=7',
      );

      expect(requests.last.dateFrom, DateTime(2026, 11));
      expect(requests.last.dateTo, DateTime(2026, 11, 30));
      expect(requests.last.customer, 7);
      expect(badge(tester).isLabelVisible, isTrue);
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsOneWidget,
      );
    });

    testWidgets('"Limpiar todo" returns to the opening state', (tester) async {
      serve([row(1, status: DeliveryOrderStatus.failed)]);
      final router = await pumpList(
        tester,
        location:
            '/sales/delivery-orders?status=9&type=1&customer=7&order=8841'
            '&from=2026-11-01&to=2026-11-30',
      );
      await openFilters(tester);

      await tester.tap(find.text(l10n.clearAllFilters));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      final last = requests.last;
      expect(last.statuses, DeliveryOrderStatus.active);
      expect(last.type, isNull);
      expect(last.customer, isNull);
      expect(last.salesOrder, isNull);
      expect(last.dateFrom, isNull);
      expect(last.facility, isNull);
    });

    testWidgets('the customer facet needs Customers read', (tester) async {
      serve([row(1)]);
      await pumpList(tester, who: access(customersRead: false));
      await openFilters(tester);

      expect(key('delivery_orders_customer_filter'), findsNothing);
      expect(key('delivery_orders_sales_order_filter'), findsOneWidget);
    });

    testWidgets('a non-administrator has no facility facet, and a facility in '
        'the address is ignored', (tester) async {
      serve([row(1)]);
      await pumpList(tester, location: '/sales/delivery-orders?facility=5');

      expect(requests.single.facility, isNull);
      expect(badge(tester).isLabelVisible, isFalse);
      await openFilters(tester);
      expect(key('delivery_orders_customer_filter'), findsOneWidget);
      expect(key('delivery_orders_facility_filter'), findsNothing);
    });

    testWidgets('an administrator gets the facility facet, "Mi sucursal" by '
        'default', (tester) async {
      serve([row(1)]);
      await pumpList(tester, who: access(administrator: true));
      await openFilters(tester);

      expect(key('delivery_orders_facility_filter'), findsOneWidget);
      expect(find.text(l10n.deliveryOrderFilterMyFacility), findsOneWidget);
      expect(key('delivery_orders_facility_mine'), findsNothing);
      expect(requests.single.facility, isNull);
    });

    testWidgets('an administrator\'s facility reaches the controller, and '
        '"Mi sucursal" clears it', (tester) async {
      serve([row(1)]);
      final router = await pumpList(
        tester,
        who: access(administrator: true),
        location: '/sales/delivery-orders?facility=5',
      );
      expect(requests.last.facility, 5);

      await openFilters(tester);
      await tester.tap(key('delivery_orders_facility_mine'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters.containsKey('facility'), isFalse);
      expect(requests.last.facility, isNull);
    });
  });

  group('states', () {
    testWidgets('loading shows a spinner', (tester) async {
      final pending = Completer<DeliveryOrderPage>();
      stubList((_) => pending.future);
      await pumpList(tester, settle: false);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete(const DeliveryOrderPage(items: [], total: 0));
      await tester.pumpAndSettle();
    });

    testWidgets('an error offers retry', (tester) async {
      var fail = true;
      stubList((_) async {
        if (fail) throw const AppError.network();
        return DeliveryOrderPage(items: [row(1, serial: 7)], total: 1);
      });
      await pumpList(tester);

      expect(find.text(l10n.retryButton), findsOneWidget);
      fail = false;
      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('empty at the opening state has no "Quitar filtros"', (
      tester,
    ) async {
      serve(const []);
      await pumpList(tester);

      expect(find.text(l10n.deliveryOrdersEmpty), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });

    testWidgets('empty when narrowed offers "Quitar filtros"', (tester) async {
      serve([row(1)]);
      final router = await pumpList(
        tester,
        location: '/sales/delivery-orders?status=10',
      );

      // The shared filtered-empty variant, with its own wording.
      expect(find.text(l10n.filteredEmptyTitle), findsOneWidget);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(requests.last.statuses, DeliveryOrderStatus.active);
    });

    testWidgets('a user with no facility sees the notice and no request is '
        'made, administrators included', (tester) async {
      serve([row(1)]);
      await pumpList(
        tester,
        who: access(administrator: true),
        facilityId: null,
      );

      expect(key('delivery_orders_no_facility'), findsOneWidget);
      expect(find.text(l10n.deliveryOrdersNoFacilityMessage), findsOneWidget);
      expect(key('delivery_orders_table'), findsNothing);
      expect(requests, isEmpty);
    });
  });

  group('print the ticket (spec 064 US2)', () {
    // Every status at once, whatever the server's own filter would keep.
    void serveEvery(List<DeliveryOrderSummary> rows) => stubList(
      (_) async => DeliveryOrderPage(items: rows, total: rows.length),
    );

    Finder ticket(int id) => key('delivery_order_view_ticket_$id');

    testWidgets('the icon is on rows past approval, cancelled included, and '
        'not on a draft or an order awaiting approval', (tester) async {
      serveEvery([
        row(1, status: DeliveryOrderStatus.draft),
        row(2, serial: 902, status: DeliveryOrderStatus.pendingApproval),
        row(3, serial: 903, status: DeliveryOrderStatus.approved),
        row(4, serial: 904, status: DeliveryOrderStatus.inPreparation),
        row(5, serial: 905, status: DeliveryOrderStatus.cancelled),
      ]);
      await pumpList(tester);

      expect(ticket(1), findsNothing);
      expect(ticket(2), findsNothing);
      expect(ticket(3), findsOneWidget);
      expect(ticket(4), findsOneWidget);
      expect(ticket(5), findsOneWidget);
      expect(find.byTooltip(l10n.deliveryOrderViewTicket), findsNWidgets(3));
    });

    testWidgets('no icon without Delivery Orders read', (tester) async {
      serveEvery([row(3, serial: 903, status: DeliveryOrderStatus.approved)]);
      await pumpList(
        tester,
        who: accessControlProvider.overrideWithValue(accessFor(noPrivileges)),
      );

      expect(ticket(3), findsNothing);
    });

    testWidgets('a one-warehouse order is looked up once, then its ticket '
        'opens unlimited in the preview', (tester) async {
      serveEvery([row(3, serial: 903, status: DeliveryOrderStatus.approved)]);
      when(
        () => repository.getById(3),
      ).thenAnswer((_) async => fullOrder(3, [2, 2], serial: 903));
      final documents = FakeDocumentSource();
      await pumpList(tester, documents: documents);

      await tester.tap(ticket(3));
      await tester.pumpAndSettle();

      verify(() => repository.getById(3)).called(1);
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(documents.fetched, hasLength(1));
      expect(documents.fetched.single.kind, DocumentKind.deliveryTicket);
      expect(documents.fetched.single.recordId, 3);
      expect(documents.fetched.single.warehouseId, isNull);
      expect(documents.fetched.single.title, 'Ticket de entrega · 903');
    });

    testWidgets('a failed lookup shows its message and opens nothing', (
      tester,
    ) async {
      serveEvery([row(3, serial: 903, status: DeliveryOrderStatus.approved)]);
      when(() => repository.getById(3)).thenThrow(
        AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'delivery_order.not_approved',
            code: api.ErrorCode.deliveryOrderPeriodNotApproved,
            params: const {'status': 'DRAFT'},
          ),
        ),
      );
      final documents = FakeDocumentSource();
      await pumpList(tester, documents: documents);

      await tester.tap(ticket(3));
      await tester.pumpAndSettle();

      expect(find.text(l10n.apiErrorDeliveryOrderNotApproved), findsOneWidget);
      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(documents.fetched, isEmpty);
    });

    testWidgets('pressing again during the lookup starts nothing new', (
      tester,
    ) async {
      serveEvery([row(3, serial: 903, status: DeliveryOrderStatus.approved)]);
      final gate = Completer<DeliveryOrder>();
      when(() => repository.getById(3)).thenAnswer((_) => gate.future);
      final documents = FakeDocumentSource();
      await pumpList(tester, documents: documents);
      final press = tester.widget<IconButton>(ticket(3)).onPressed!;

      press();
      press();
      await tester.pump();
      gate.complete(fullOrder(3, [2], serial: 903));
      await tester.pumpAndSettle();

      verify(() => repository.getById(3)).called(1);
      expect(documents.fetched, hasLength(1));
    });

    testWidgets('the icon doesn\'t open the order, the row tap still does', (
      tester,
    ) async {
      serveEvery([row(3, serial: 903, status: DeliveryOrderStatus.approved)]);
      when(
        () => repository.getById(3),
      ).thenAnswer((_) async => fullOrder(3, [2], serial: 903));
      final router = await pumpList(tester);

      await tester.tap(ticket(3));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/sales/delivery-orders');

      await tester.tap(key('document_preview_close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('903'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/sales/delivery-orders/3');
    });

    testWidgets('closing the preview leaves the list as it was and reloads '
        'nothing (FR-040, FR-041)', (tester) async {
      serveEvery([row(3, serial: 903, status: DeliveryOrderStatus.approved)]);
      when(
        () => repository.getById(3),
      ).thenAnswer((_) async => fullOrder(3, [2], serial: 903));
      final router = await pumpList(
        tester,
        location: '/sales/delivery-orders?search=903',
      );
      final before = requests.length;
      final uri = router.state.uri.toString();

      await tester.tap(ticket(3));
      await tester.pumpAndSettle();
      await tester.tap(key('document_preview_close'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(requests.length, before);
      expect(router.state.uri.toString(), uri);
      expect(ticket(3), findsOneWidget);
    });
  });

  group('warehouse choice from the list (spec 064 US3)', () {
    Finder ticket(int id) => key('delivery_order_view_ticket_$id');

    void serveOne() => stubList(
      (_) async => DeliveryOrderPage(
        items: [row(3, serial: 903, status: DeliveryOrderStatus.approved)],
        total: 1,
      ),
    );

    testWidgets('an order from two warehouses asks after the lookup, before '
        'any fetch', (tester) async {
      serveOne();
      when(
        () => repository.getById(3),
      ).thenAnswer((_) async => fullOrder(3, [2, 5], serial: 903));
      final documents = FakeDocumentSource();
      await pumpList(tester, documents: documents);

      await tester.tap(ticket(3));
      await tester.pumpAndSettle();

      verify(() => repository.getById(3)).called(1);
      expect(key('delivery_ticket_scope_dialog'), findsOneWidget);
      expect(find.text('Bodega norte'), findsOneWidget);
      expect(find.text('Patio'), findsOneWidget);
      expect(documents.fetched, isEmpty);
    });

    testWidgets('choosing a warehouse fetches only its lines', (tester) async {
      serveOne();
      when(
        () => repository.getById(3),
      ).thenAnswer((_) async => fullOrder(3, [2, 5], serial: 903));
      final documents = FakeDocumentSource();
      await pumpList(tester, documents: documents);

      await tester.tap(ticket(3));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_ticket_scope_5'));
      await tester.pump();
      await tester.tap(key('delivery_ticket_scope_confirm'));
      await tester.pumpAndSettle();

      expect(documents.fetched, hasLength(1));
      expect(documents.fetched.single.warehouseId, 5);
      expect(documents.fetched.single.title, 'Ticket de entrega · 903 · Patio');
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
    });

    testWidgets('dismissing the choice fetches nothing', (tester) async {
      serveOne();
      when(
        () => repository.getById(3),
      ).thenAnswer((_) async => fullOrder(3, [2, 5], serial: 903));
      final documents = FakeDocumentSource();
      await pumpList(tester, documents: documents);

      await tester.tap(ticket(3));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_ticket_scope_cancel'));
      await tester.pumpAndSettle();

      expect(documents.fetched, isEmpty);
      expect(find.byType(DocumentPreviewDialog), findsNothing);
    });
  });
}
