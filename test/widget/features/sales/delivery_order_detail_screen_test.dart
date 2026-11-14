import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Answers the detail controller with whatever [answer] gives, so a test sets
/// the sale map and child orders directly. The controller's own loading is
/// covered by its unit test.
class _FakeDetail extends DeliveryOrderDetailController {
  _FakeDetail(this.answer);

  final Future<DeliveryOrderDetail> Function() answer;

  @override
  Future<DeliveryOrderDetail> build(int id) => answer();
}

/// Records each write and answers [error]; on success runs [onSuccess]
/// first (to swap what the detail answers), then invalidates the order as the
/// real actions do.
class _FakeActions extends DeliveryOrderActions {
  _FakeActions({this.error, this.onSuccess});

  AppError? error;
  final void Function()? onSuccess;
  final calls = <String>[];

  Future<AppError?> _answer(int id, String call) async {
    calls.add(call);
    if (error == null) onSuccess?.call();
    ref.invalidate(deliveryOrderDetailControllerProvider(id));
    return error;
  }

  @override
  Future<AppError?> confirm(int id) => _answer(id, 'confirm');

  @override
  Future<AppError?> removeLine(int id, {required int lineId}) =>
      _answer(id, 'remove $lineId');
}

Override _access({bool update = false, bool salesOrdersRead = true}) =>
    accessControlProvider.overrideWithValue(
      AccessControlService(
        AuthState.authenticated(
          token: 't',
          user: User(
            userId: 'd',
            email: 'd@example.com',
            administrator: false,
            status: EntityStatus.active,
            sessionVersion: 1,
            privileges: [
              Privilege(
                systemObject: SystemObject.deliveryOrders,
                rawValue: update ? 6 : 2,
              ),
              if (salesOrdersRead)
                const Privilege(
                  systemObject: SystemObject.salesOrders,
                  rawValue: 2,
                ),
            ],
          ),
        ),
      ),
    );

const _customer = Customer(
  customerId: 7,
  code: 'C-7',
  name: 'Ferretería López',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 11,
      label: 'Av. Juárez 120, Centro',
      type: AddressType.business,
    ),
  ],
  contacts: [Contact(contactId: 12, name: 'Luis López', phone: '81 1234')],
);

DeliveryOrderLine _line(
  int id, {
  int? detail,
  String quantity = '10',
  String committed = '8',
  String delivered = '5',
  String returned = '2',
  String open = '3',
}) => DeliveryOrderLine(
  id: id,
  salesOrderDetailId: detail ?? id + 100,
  productId: id,
  productCode: 'P-$id',
  productName: 'Producto $id',
  warehouseId: 3,
  quantity: Decimal.parse(quantity),
  committed: Decimal.parse(committed),
  delivered: Decimal.parse(delivered),
  returned: Decimal.parse(returned),
  open: Decimal.parse(open),
);

DeliveryOrder _order({
  int id = 9,
  int? serial = 1532,
  DeliveryOrderStatus status = DeliveryOrderStatus.inPreparation,
  FulfillmentType type = FulfillmentType.delivery,
  List<int> sales = const [8841],
  int? parentId,
  String? rejectionReason,
  String? comment = 'Por la mañana',
  List<DeliveryOrderLine>? lines,
}) => DeliveryOrder(
  id: id,
  facilityId: 1,
  serial: serial,
  customerId: 7,
  salesOrderIds: sales,
  shipToId: 11,
  date: DateTime(2026, 11, 15),
  priority: 2,
  status: status,
  type: type,
  parentId: parentId,
  contactId: 12,
  comment: comment,
  rejectionReason: rejectionReason,
  createdAt: DateTime(2026, 11, 14),
  modifiedAt: DateTime(2026, 11, 14),
  lines: lines ?? [_line(1)],
);

/// Spec 061 US1 (T018), contracts C4: the delivery order detail screen,
/// read-only. Later stories add their sections' tests here.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  DeliveryOrderDetail detailOf(
    DeliveryOrder order, {
    Map<int, int>? sales,
    List<DeliveryOrderSummary> children = const [],
  }) => DeliveryOrderDetail(
    order: order,
    events: const AsyncData([]),
    sales:
        sales ??
        {
          for (final line in order.lines)
            if (order.salesOrderIds.length == 1)
              line.salesOrderDetailId!: order.salesOrderIds.single,
        },
    children: children,
  );

  Future<GoRouter> pumpDetail(
    WidgetTester tester, {
    Future<DeliveryOrderDetail> Function()? answer,
    DeliveryOrderDetail? detail,
    Override? access,
    String location = '/sales/delivery-orders/9',
    bool namesReadable = true,
    Size surface = const Size(1400, 1400),
    _FakeActions? actions,
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
        access ?? _access(),
        if (actions != null)
          deliveryOrderActionsProvider.overrideWith(() => actions),
        deliveryOrderDetailControllerProvider(
          9,
        ).overrideWith(() => _FakeDetail(answer ?? () async => detail!)),
        // The parent and child the link tests open.
        for (final other in const [4, 20])
          deliveryOrderDetailControllerProvider(other).overrideWith(
            () => _FakeDetail(
              () async => detailOf(_order(id: other, serial: 1000 + other)),
            ),
          ),
        customerDisplayNameProvider.overrideWith(
          (ref, id) async => namesReadable ? 'Ferretería López' : null,
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => namesReadable ? 'Centro' : null,
        ),
        saleCustomerControllerProvider.overrideWith(
          (ref, id) async => namesReadable
              ? _customer
              : throw const AppError.server(statusCode: 403),
        ),
        facilityWarehousesControllerProvider.overrideWith(
          (ref, facilityId) async => namesReadable
              ? const [
                  Warehouse(
                    warehouseId: 3,
                    facilityId: 1,
                    facilityName: 'Centro',
                    code: 'B1',
                    name: 'Bodega 1',
                    status: EntityStatus.active,
                  ),
                ]
              : throw const AppError.server(statusCode: 403),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/sales/delivery-orders',
          builder: (_, _) => const Scaffold(body: Text('delivery-orders')),
        ),
        GoRoute(
          path: '/sales/delivery-orders/:id',
          builder: (context, state) => DeliveryOrderDetailScreen(
            deliveryOrderId: int.tryParse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/sales/orders/:id',
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
    await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  group('header', () {
    testWidgets('shows the facts, the chip and the title', (tester) async {
      await pumpDetail(tester, detail: detailOf(_order()));

      expect(find.text(l10n.deliveryOrderTitle('1532')), findsOneWidget);
      final facts = key('delivery_order_facts');
      for (final value in [
        '1532',
        l10n.deliveryOrderTypeDelivery,
        'Ferretería López',
        'Centro',
        '2026-11-15',
        '2',
      ]) {
        expect(
          find.descendant(of: facts, matching: find.text(value)),
          findsOneWidget,
          reason: value,
        );
      }
      expect(key('delivery_order_status_chip_inPreparation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a draft is titled and folioed "Borrador"', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          _order(serial: null, status: DeliveryOrderStatus.draft),
        ),
      );

      expect(find.text(l10n.deliveryOrderTitleDraft), findsOneWidget);
      expect(
        tester.widget<Text>(key('delivery_order_serial')).data,
        l10n.deliveryOrderDraftFolio,
      );
    });

    testWidgets('the detail band shows ship-to, contact, sales and comment', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order(sales: const [8790, 8812]), sales: const {}),
      );

      final band = key('delivery_order_detail_band');
      for (final value in [
        'Av. Juárez 120, Centro',
        'Luis López · 81 1234',
        'Por la mañana',
      ]) {
        expect(
          find.descendant(of: band, matching: find.text(value)),
          findsOneWidget,
          reason: value,
        );
      }
      expect(key('delivery_order_sale_link_8790'), findsOneWidget);
      expect(key('delivery_order_sale_link_8812'), findsOneWidget);
    });

    testWidgets('a pickup\'s ship-to is its facility', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order(type: FulfillmentType.counterPickup)),
      );

      expect(
        find.descendant(
          of: key('delivery_order_detail_band'),
          matching: find.text('Centro'),
        ),
        findsOneWidget,
      );
      expect(find.text('Av. Juárez 120, Centro'), findsNothing);
    });

    testWidgets('a sale links to Pedidos with Sales Orders read', (
      tester,
    ) async {
      final router = await pumpDetail(tester, detail: detailOf(_order()));

      await tester.tap(key('delivery_order_sale_link_8841'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/orders/8841');
    });

    testWidgets('without Sales Orders read a sale is plain text', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order()),
        access: _access(salesOrdersRead: false),
      );

      expect(key('delivery_order_sale_link_8841'), findsOneWidget);
      expect(
        find.ancestor(
          of: key('delivery_order_sale_link_8841'),
          matching: find.byType(TextButton),
        ),
        findsNothing,
      );
      expect(tester.widget(key('delivery_order_sale_link_8841')), isA<Text>());
    });
  });

  group('rejection banner', () {
    testWidgets('shows the reason when there is one', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          _order(
            serial: null,
            status: DeliveryOrderStatus.draft,
            rejectionReason: 'Falta dirección',
          ),
        ),
      );

      expect(key('delivery_order_rejection_banner'), findsOneWidget);
      expect(
        find.text(l10n.deliveryOrderRejectionBanner('Falta dirección')),
        findsOneWidget,
      );
    });

    testWidgets('is absent without a reason', (tester) async {
      await pumpDetail(tester, detail: detailOf(_order()));

      expect(key('delivery_order_rejection_banner'), findsNothing);
    });
  });

  group('parent and child orders', () {
    testWidgets('the parent links to its order', (tester) async {
      final router = await pumpDetail(
        tester,
        detail: detailOf(_order(parentId: 4)),
      );

      expect(find.text(l10n.deliveryOrderFactParent), findsOneWidget);
      await tester.tap(key('delivery_order_parent_link'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-orders/4');
    });

    testWidgets('a partial delivery links to its child orders', (tester) async {
      final router = await pumpDetail(
        tester,
        detail: detailOf(
          _order(status: DeliveryOrderStatus.partiallyDelivered),
          children: const [
            DeliveryOrderSummary(
              id: 20,
              facilityId: 1,
              serial: 1600,
              customerId: 7,
              priority: 0,
              status: DeliveryOrderStatus.inPreparation,
              type: FulfillmentType.delivery,
              parentId: 9,
            ),
          ],
        ),
      );

      expect(find.text(l10n.deliveryOrderFactChild), findsOneWidget);
      expect(key('delivery_order_parent_link'), findsNothing);
      await tester.tap(key('delivery_order_child_link_20'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-orders/20');
    });

    testWidgets('no parent or child row when there is none', (tester) async {
      await pumpDetail(tester, detail: detailOf(_order()));

      expect(find.text(l10n.deliveryOrderFactParent), findsNothing);
      expect(find.text(l10n.deliveryOrderFactChild), findsNothing);
    });
  });

  group('lines', () {
    testWidgets('show code, product, warehouse and all five quantities', (
      tester,
    ) async {
      await pumpDetail(tester, detail: detailOf(_order()));

      final table = key('delivery_order_lines_table');
      for (final header in [
        l10n.deliveryOrderLineColumnCode,
        l10n.deliveryOrderLineColumnProduct,
        l10n.deliveryOrderLineColumnWarehouse,
        l10n.deliveryOrderLineColumnSalesOrder,
        l10n.deliveryOrderLineColumnOrdered,
        l10n.deliveryOrderLineColumnCommitted,
        l10n.deliveryOrderLineColumnDelivered,
        l10n.deliveryOrderLineColumnReturned,
        l10n.deliveryOrderLineColumnOpen,
      ]) {
        expect(
          find.descendant(of: table, matching: find.text(header)),
          findsOneWidget,
          reason: header,
        );
      }
      for (final value in [
        'P-1',
        'Producto 1',
        'Bodega 1',
        '10',
        '8',
        '5',
        '2',
        '3',
      ]) {
        expect(
          find.descendant(of: table, matching: find.text(value)),
          findsOneWidget,
          reason: value,
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('a single-sale order shows that sale on every line', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order(lines: [_line(1), _line(2)])),
      );

      expect(
        find.descendant(
          of: key('delivery_order_lines_table'),
          matching: find.text('8841'),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('several sales: each line shows its own, or "—" when it '
        'can\'t tell', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          _order(
            sales: const [8790, 8812],
            lines: [_line(1), _line(2), _line(3)],
          ),
          sales: const {101: 8790, 102: 8812},
        ),
      );

      final table = key('delivery_order_lines_table');
      expect(
        find.descendant(of: table, matching: find.text('8790')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: table, matching: find.text('8812')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: table, matching: find.text(emptyValuePlaceholder)),
        findsOneWidget,
      );
    });

    testWidgets('stack as cards at the compact tier, every quantity kept', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order()),
        surface: const Size(400, 1400),
      );

      expect(key('delivery_order_lines_table'), findsNothing);
      final card = key('delivery_order_line_card_1');
      expect(card, findsOneWidget);
      for (final value in [
        '${l10n.deliveryOrderLineColumnOrdered} 10',
        '${l10n.deliveryOrderLineColumnCommitted} 8',
        '${l10n.deliveryOrderLineColumnDelivered} 5',
        '${l10n.deliveryOrderLineColumnReturned} 2',
        '${l10n.deliveryOrderLineColumnOpen} 3',
      ]) {
        expect(
          find.descendant(of: card, matching: find.text(value)),
          findsOneWidget,
          reason: value,
        );
      }
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('names fall back to their number without the right', (
    tester,
  ) async {
    await pumpDetail(tester, detail: detailOf(_order()), namesReadable: false);

    final facts = key('delivery_order_facts');
    expect(
      find.descendant(of: facts, matching: find.text('#7')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: facts, matching: find.text('#1')),
      findsOneWidget,
    );
    final band = key('delivery_order_detail_band');
    expect(
      find.descendant(of: band, matching: find.text('#11')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: band, matching: find.text('#12')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: key('delivery_order_lines_table'),
        matching: find.text('#3'),
      ),
      findsOneWidget,
    );
  });

  group('load states', () {
    testWidgets('a missing order shows not found and goes back to the list', (
      tester,
    ) async {
      final router = await pumpDetail(
        tester,
        answer: () async => throw const AppError.notFound(),
      );

      expect(key('delivery_order_not_found'), findsOneWidget);
      await tester.tap(find.text(l10n.deliveryOrderBackToList));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-orders');
    });

    testWidgets('a non-numeric id shows not found', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order()),
        location: '/sales/delivery-orders/abc',
      );

      expect(key('delivery_order_not_found'), findsOneWidget);
    });

    testWidgets('a load error offers retry', (tester) async {
      var fail = true;
      await pumpDetail(
        tester,
        answer: () async {
          if (fail) throw const AppError.network();
          return detailOf(_order());
        },
      );

      expect(key('delivery_order_load_failed'), findsOneWidget);
      fail = false;
      await tester.tap(key('delivery_order_retry_button'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_facts'), findsOneWidget);
    });
  });

  DeliveryOrder draft({List<DeliveryOrderLine>? lines}) =>
      _order(serial: null, status: DeliveryOrderStatus.draft, lines: lines);

  group('confirm (US2)', () {
    testWidgets('is offered on a draft with update', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(draft()),
        access: _access(update: true),
      );

      final button = tester.widget<FilledButton>(key('delivery_order_confirm'));
      expect(button.onPressed, isNotNull);
      expect(key('delivery_order_confirm_needs_lines'), findsNothing);
    });

    testWidgets('is absent on a confirmed order, even with update', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order()),
        access: _access(update: true),
      );

      expect(key('delivery_order_confirm'), findsNothing);
      expect(key('delivery_order_actions'), findsNothing);
    });

    testWidgets('is disabled with a hint on a draft with no lines', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(draft(lines: const [])),
        access: _access(update: true),
      );

      final button = tester.widget<FilledButton>(key('delivery_order_confirm'));
      expect(button.onPressed, isNull);
      expect(find.text(l10n.deliveryOrderConfirmNeedsLines), findsOneWidget);
    });

    testWidgets('asks first, naming customer, date and line count', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(draft(lines: [_line(1), _line(2)])),
        access: _access(update: true),
      );

      await tester.tap(key('delivery_order_confirm'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(key('delivery_order_confirm_summary')).data,
        l10n.deliveryOrderConfirmSummary('Ferretería López', '2026-11-15', 2),
      );
      expect(find.text(l10n.deliveryOrderConfirmIrreversible), findsOneWidget);
    });

    testWidgets('success shows the folio and status the server chose', (
      tester,
    ) async {
      var current = detailOf(draft());
      final actions = _FakeActions(
        onSuccess: () => current = detailOf(
          _order(serial: 1600, status: DeliveryOrderStatus.pendingApproval),
        ),
      );
      await pumpDetail(
        tester,
        answer: () async => current,
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_confirm_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['confirm']);
      expect(key('delivery_order_confirm_dialog'), findsNothing);
      expect(
        find.text(l10n.deliveryOrderSnackConfirmed('1600')),
        findsOneWidget,
      );
      expect(find.text(l10n.deliveryOrderTitle('1600')), findsOneWidget);
      expect(key('delivery_order_status_chip_pendingApproval'), findsOneWidget);
      expect(key('delivery_order_confirm'), findsNothing);
    });

    testWidgets('too little notice keeps the dialog open with the earliest '
        'date', (tester) async {
      final actions = _FakeActions(
        error: const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'delivery_order.insufficient_notice',
            code: api.ErrorCode.deliveryOrderPeriodInsufficientNotice,
            params: {'min_hours': 24, 'earliest': '2026-11-16T08:00:00'},
          ),
        ),
      );
      await pumpDetail(
        tester,
        detail: detailOf(draft()),
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_confirm_submit'));
      await tester.pumpAndSettle();

      final dialog = key('delivery_order_confirm_dialog');
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining('2026-11-16'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.textContaining('24')),
        findsOneWidget,
      );
    });

    testWidgets('another refusal closes the dialog, shows why and reloads', (
      tester,
    ) async {
      var loads = 0;
      final actions = _FakeActions(
        error: const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'delivery_order.no_lines',
            code: api.ErrorCode.deliveryOrderPeriodNoLines,
          ),
        ),
      );
      await pumpDetail(
        tester,
        answer: () async {
          loads++;
          return detailOf(draft());
        },
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_confirm_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_confirm_dialog'), findsNothing);
      expect(key('delivery_order_refusal'), findsOneWidget);
      expect(find.text(l10n.apiErrorDeliveryOrderNoLines), findsOneWidget);
      expect(loads, 2);
    });

    testWidgets('a lost connection says the result is unknown', (tester) async {
      final actions = _FakeActions(error: const AppError.network());
      await pumpDetail(
        tester,
        detail: detailOf(draft()),
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_confirm_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_confirm_dialog'), findsNothing);
      expect(find.text(l10n.deliveryOrderActionUnknown), findsOneWidget);
    });
  });

  group('edit controls (US3)', () {
    const editKeys = [
      'delivery_order_edit_header',
      'delivery_order_add_line',
      'delivery_order_line_edit_1',
      'delivery_order_line_remove_1',
    ];

    testWidgets('show on a draft with update', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(draft()),
        access: _access(update: true),
      );

      for (final k in editKeys) {
        expect(key(k), findsOneWidget, reason: k);
      }
    });

    testWidgets('are absent on a confirmed order', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order()),
        access: _access(update: true),
      );

      for (final k in editKeys) {
        expect(key(k), findsNothing, reason: k);
      }
    });

    testWidgets('"Agregar línea" needs Sales Orders read', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(draft()),
        access: _access(update: true, salesOrdersRead: false),
      );

      expect(key('delivery_order_add_line'), findsNothing);
      expect(key('delivery_order_edit_header'), findsOneWidget);
      expect(key('delivery_order_line_edit_1'), findsOneWidget);
      expect(key('delivery_order_line_remove_1'), findsOneWidget);
    });

    testWidgets('the line icons are on the compact cards too', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(draft()),
        access: _access(update: true),
        surface: const Size(400, 1400),
      );

      expect(
        find.descendant(
          of: key('delivery_order_line_card_1'),
          matching: key('delivery_order_line_edit_1'),
        ),
        findsOneWidget,
      );
      expect(key('delivery_order_line_remove_1'), findsOneWidget);
    });

    testWidgets('removing a line asks, then removes it and says so', (
      tester,
    ) async {
      final actions = _FakeActions();
      await pumpDetail(
        tester,
        detail: detailOf(draft()),
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_line_remove_1'));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.deliveryOrderLineRemoveTitle('Producto 1')),
        findsOneWidget,
      );
      await tester.tap(key('delivery_order_line_remove_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['remove 1']);
      expect(
        find.text(
          l10n.deliveryOrderSnackLineRemoved(l10n.deliveryOrderDraftFolio),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('no action or edit control for a user without update', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      detail: detailOf(_order(serial: null, status: DeliveryOrderStatus.draft)),
    );

    for (final k in [
      'delivery_order_edit_header',
      'delivery_order_add_line',
      'delivery_order_line_edit_1',
      'delivery_order_line_remove_1',
      'delivery_order_confirm',
      'delivery_order_cancel',
    ]) {
      expect(key(k), findsNothing, reason: k);
    }
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isNull);
  });
}
