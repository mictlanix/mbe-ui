import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
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

import '../../../unit/core/documents/document_fakes.dart';

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

  @override
  Future<AppError?> cancel(int id, {required String reason}) =>
      _answer(id, 'cancel $reason');

  @override
  Future<AppError?> requeue(int id) => _answer(id, 'requeue');

  @override
  Future<AppError?> markReady(int id) => _answer(id, 'ready');

  /// Spec 062: approve and reject answer the status the server moved the
  /// order to, and on success run [onSuccess] first, as the writes above do.
  @override
  Future<ApprovalOutcome> approve(int id) async {
    final error = await _answer(id, 'approve');
    return (
      error: error,
      status: error == null ? DeliveryOrderStatus.inPreparation : null,
    );
  }

  @override
  Future<ApprovalOutcome> reject(int id, {required String reason}) async {
    final error = await _answer(id, 'reject $reason');
    return (
      error: error,
      status: error == null ? DeliveryOrderStatus.draft : null,
    );
  }
}

/// A 1×1 PNG, as the proof image endpoint answers.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

Override _access({
  bool update = false,
  bool salesOrdersRead = true,
  bool approvalUpdate = false,
}) => accessControlProvider.overrideWithValue(
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
          if (approvalUpdate)
            const Privilege(
              systemObject: SystemObject.deliveryOrderApproval,
              rawValue: 6,
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
  int? proofId,
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
  proofId: proofId,
  createdAt: DateTime(2026, 11, 14),
  modifiedAt: DateTime(2026, 11, 14),
  lines: lines ?? [_line(1)],
);

/// Spec 061, contracts C4: the delivery order detail screen. US1 (T018) reads
/// it; US2 to US7 (T021, T027, T030, T032, T034, T038) act on it; T039 is the
/// action matrix (data-model §3).
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  DeliveryOrderDetail detailOf(
    DeliveryOrder order, {
    Map<int, int>? sales,
    List<DeliveryOrderSummary> children = const [],
    AsyncValue<List<DeliveryOrderEvent>> events = const AsyncData([]),
    AsyncValue<ProofOfDelivery>? proof,
  }) => DeliveryOrderDetail(
    order: order,
    events: events,
    proof: proof,
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
    Future<Uint8List> Function()? proofImage,
    FakeDocumentSource? documents,
    Locale locale = const Locale('es', 'MX'),
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
        documentSourceProvider.overrideWithValue(
          documents ?? FakeDocumentSource(),
        ),
        documentOutputProvider.overrideWithValue(FakeDocumentOutput()),
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
        employeeDisplayNameProvider.overrideWith(
          (ref, id) async => namesReadable ? 'Empleado $id' : null,
        ),
        deliveryOrderProofImageProvider.overrideWith(
          (ref, id) => (proofImage ?? () async => _png)(),
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
          locale: locale,
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

  AppError refusal(String codeName, api.ErrorCode code) => AppError.server(
    statusCode: 409,
    problem: ApiProblem(codeName: codeName, code: code),
  );

  DeliveryOrderEvent event(
    int id,
    DeliveryOrderStatus? from,
    DeliveryOrderStatus to, {
    int employee = 5,
    int hour = 9,
    String? reason,
  }) => DeliveryOrderEvent(
    id: id,
    from: from,
    to: to,
    employeeId: employee,
    at: DateTime(2026, 11, 14, hour),
    reason: reason,
  );

  group('cancel (US4)', () {
    testWidgets('success shows Cancelada, says so, and the history gains the '
        'cancellation', (tester) async {
      var current = detailOf(
        _order(),
        events: AsyncData([
          event(1, null, DeliveryOrderStatus.draft),
          event(
            2,
            DeliveryOrderStatus.draft,
            DeliveryOrderStatus.inPreparation,
            hour: 10,
          ),
        ]),
      );
      final actions = _FakeActions(
        onSuccess: () => current = detailOf(
          _order(status: DeliveryOrderStatus.cancelled),
          events: AsyncData([
            ...current.events.value!,
            event(
              3,
              DeliveryOrderStatus.inPreparation,
              DeliveryOrderStatus.cancelled,
              hour: 11,
              reason: 'Cliente canceló',
            ),
          ]),
        ),
      );
      await pumpDetail(
        tester,
        answer: () async => current,
        access: _access(update: true),
        actions: actions,
      );
      expect(key('delivery_order_event_3'), findsNothing);

      await tester.tap(key('delivery_order_cancel'));
      await tester.pumpAndSettle();
      await tester.enterText(
        key('delivery_order_cancel_reason'),
        '  Cliente canceló  ',
      );
      await tester.pump();
      await tester.tap(key('delivery_order_cancel_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['cancel Cliente canceló']);
      expect(key('delivery_order_cancel_dialog'), findsNothing);
      expect(key('delivery_order_status_chip_cancelled'), findsOneWidget);
      expect(
        find.text(l10n.deliveryOrderSnackCancelled('1532')),
        findsOneWidget,
      );
      expect(key('delivery_order_event_3'), findsOneWidget);
      expect(key('delivery_order_cancel'), findsNothing);
      // A cancelled order still prints (spec 064 FR-003), so the area stays
      // with only the print action and none of the status actions.
      expect(key('delivery_order_actions'), findsOneWidget);
      expect(key('delivery_order_view_ticket'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('state.transition_invalid closes the dialog, shows the '
        'generic message and reloads', (tester) async {
      var loads = 0;
      var current = detailOf(_order());
      final actions = _FakeActions(
        error: refusal(
          'state.transition_invalid',
          api.ErrorCode.statePeriodTransitionInvalid,
        ),
      );
      await pumpDetail(
        tester,
        answer: () async {
          loads++;
          // The truck left in the meantime.
          if (loads > 1) {
            current = detailOf(_order(status: DeliveryOrderStatus.inTransit));
          }
          return current;
        },
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_cancel'));
      await tester.pumpAndSettle();
      await tester.enterText(key('delivery_order_cancel_reason'), 'Motivo');
      await tester.pump();
      await tester.tap(key('delivery_order_cancel_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_cancel_dialog'), findsNothing);
      expect(key('delivery_order_refusal'), findsOneWidget);
      expect(find.text(l10n.apiErrorStateTransitionInvalid), findsOneWidget);
      expect(loads, 2);
      expect(key('delivery_order_status_chip_inTransit'), findsOneWidget);
      expect(key('delivery_order_cancel'), findsNothing);
    });
  });

  group('history (US5)', () {
    testWidgets('lists events oldest first, a dash for the creation and a '
        'rejection with its reason', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          draft(),
          events: AsyncData([
            event(
              3,
              DeliveryOrderStatus.pendingApproval,
              DeliveryOrderStatus.draft,
              employee: 6,
              hour: 11,
              reason: 'Falta dirección',
            ),
            event(1, null, DeliveryOrderStatus.draft),
            event(
              2,
              DeliveryOrderStatus.draft,
              DeliveryOrderStatus.pendingApproval,
              hour: 10,
            ),
          ]),
        ),
      );

      final first = tester.getTopLeft(key('delivery_order_event_1')).dy;
      final second = tester.getTopLeft(key('delivery_order_event_2')).dy;
      final third = tester.getTopLeft(key('delivery_order_event_3')).dy;
      expect(first < second && second < third, isTrue);

      String transition(int id) =>
          tester.widget<Text>(key('delivery_order_event_transition_$id')).data!;
      expect(
        transition(1),
        '$emptyValuePlaceholder → ${l10n.deliveryOrderStatusDraft}',
      );
      expect(
        transition(3),
        '${l10n.deliveryOrderStatusPendingApproval} → '
        '${l10n.deliveryOrderStatusDraft}',
      );
      expect(
        tester.widget<Text>(key('delivery_order_event_reason_3')).data,
        'Falta dirección',
      );
      expect(
        find.descendant(
          of: key('delivery_order_event_3'),
          matching: find.text('Empleado 6'),
        ),
        findsOneWidget,
      );
      // History follows the lines.
      expect(
        tester.getTopLeft(key('delivery_order_history')).dy,
        greaterThan(tester.getTopLeft(key('delivery_order_lines')).dy),
      );
    });

    testWidgets('employee names fall back to their number', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          _order(),
          events: AsyncData([event(1, null, DeliveryOrderStatus.draft)]),
        ),
        namesReadable: false,
      );

      expect(
        find.descendant(
          of: key('delivery_order_event_1'),
          matching: find.text('#5'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no events shows the empty line', (tester) async {
      await pumpDetail(tester, detail: detailOf(_order()));

      expect(key('delivery_order_events_empty'), findsOneWidget);
    });

    testWidgets('a failed history stays inside its section', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          _order(),
          events: AsyncError(
            const AppError.server(statusCode: 500),
            StackTrace.empty,
          ),
        ),
      );

      expect(
        find.descendant(
          of: key('delivery_order_history'),
          matching: key('delivery_order_events_error'),
        ),
        findsOneWidget,
      );
      expect(key('delivery_order_lines_table'), findsOneWidget);
    });
  });

  group('requeue (US6)', () {
    DeliveryOrder failed() => _order(status: DeliveryOrderStatus.failed);

    testWidgets('success shows En preparación with Devuelta back at 0', (
      tester,
    ) async {
      var current = detailOf(failed());
      final actions = _FakeActions(
        onSuccess: () => current = detailOf(
          _order(
            lines: [_line(1, returned: '0', open: '5')],
          ),
        ),
      );
      await pumpDetail(
        tester,
        answer: () async => current,
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_requeue'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(key('delivery_order_requeue_body')).data,
        l10n.deliveryOrderRequeueBody('Ferretería López'),
      );
      await tester.tap(key('delivery_order_requeue_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['requeue']);
      expect(key('delivery_order_status_chip_inPreparation'), findsOneWidget);
      expect(
        find.text(l10n.deliveryOrderSnackRequeued('1532')),
        findsOneWidget,
      );
      final table = key('delivery_order_lines_table');
      expect(
        find.descendant(of: table, matching: find.text('0')),
        findsOneWidget,
      );
      expect(key('delivery_order_requeue'), findsNothing);
    });

    testWidgets('not_failed shows its message and reloads', (tester) async {
      var loads = 0;
      final actions = _FakeActions(
        error: refusal(
          'delivery_order.not_failed',
          api.ErrorCode.deliveryOrderPeriodNotFailed,
        ),
      );
      await pumpDetail(
        tester,
        answer: () async {
          loads++;
          return detailOf(failed());
        },
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_requeue'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_requeue_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_requeue_dialog'), findsNothing);
      expect(find.text(l10n.apiErrorDeliveryOrderNotFailed), findsOneWidget);
      expect(loads, 2);
    });
  });

  group('pickup (US7)', () {
    DeliveryOrder pickup(DeliveryOrderStatus status, {int? proofId}) => _order(
      status: status,
      type: FulfillmentType.counterPickup,
      proofId: proofId,
    );

    final proof = ProofOfDelivery(
      receiverName: 'Juan Pérez',
      receiverIdShown: 'INE 0123456789',
      capturedAt: DateTime(2026, 11, 14, 16, 22),
      capturedBy: 8,
    );

    testWidgets('marking ready shows Lista para recoger and offers the '
        'handover', (tester) async {
      var current = detailOf(pickup(DeliveryOrderStatus.approved));
      final actions = _FakeActions(
        onSuccess: () =>
            current = detailOf(pickup(DeliveryOrderStatus.readyForPickup)),
      );
      await pumpDetail(
        tester,
        answer: () async => current,
        access: _access(update: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_ready'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(key('delivery_order_ready_body')).data,
        l10n.deliveryOrderReadyBody('Ferretería López'),
      );
      await tester.tap(key('delivery_order_ready_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['ready']);
      expect(key('delivery_order_status_chip_readyForPickup'), findsOneWidget);
      expect(find.text(l10n.deliveryOrderSnackReady('1532')), findsOneWidget);
      expect(key('delivery_order_ready'), findsNothing);
      expect(key('delivery_order_pickup'), findsOneWidget);
    });

    testWidgets('"Entregar al cliente" opens the pickup dialog', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(pickup(DeliveryOrderStatus.readyForPickup)),
        access: _access(update: true),
      );

      await tester.tap(key('delivery_order_pickup'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_pickup_dialog'), findsOneWidget);
    });

    testWidgets('the proof shows between the lines and the history, and the '
        'photo enlarges', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          pickup(DeliveryOrderStatus.pickedUp, proofId: 1),
          proof: AsyncData(proof),
        ),
      );

      final section = key('delivery_order_proof');
      for (final value in ['Juan Pérez', 'INE 0123456789', 'Empleado 8']) {
        expect(
          find.descendant(of: section, matching: find.text(value)),
          findsOneWidget,
          reason: value,
        );
      }
      final y = tester.getTopLeft(section).dy;
      expect(y, greaterThan(tester.getTopLeft(key('delivery_order_lines')).dy));
      expect(y, lessThan(tester.getTopLeft(key('delivery_order_history')).dy));

      await tester.tap(key('delivery_order_proof_photo'));
      await tester.pumpAndSettle();
      expect(key('delivery_order_proof_photo_dialog'), findsOneWidget);
    });

    testWidgets('a failed proof stays inside its section', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          pickup(DeliveryOrderStatus.pickedUp, proofId: 1),
          proof: AsyncError(const AppError.notFound(), StackTrace.empty),
        ),
      );

      expect(
        find.descendant(
          of: key('delivery_order_proof'),
          matching: key('delivery_order_proof_failed'),
        ),
        findsOneWidget,
      );
      expect(key('delivery_order_lines_table'), findsOneWidget);
      expect(key('delivery_order_history'), findsOneWidget);
    });

    testWidgets('a failed photo keeps the details and says so', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          pickup(DeliveryOrderStatus.pickedUp, proofId: 1),
          proof: AsyncData(proof),
        ),
        proofImage: () async => throw const AppError.server(statusCode: 500),
      );

      expect(key('delivery_order_proof_receiver'), findsOneWidget);
      expect(key('delivery_order_proof_photo'), findsNothing);
      expect(find.text(l10n.deliveryOrderProofLoadFailed), findsOneWidget);
    });

    testWidgets('no proof, no section', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(pickup(DeliveryOrderStatus.readyForPickup)),
      );

      expect(key('delivery_order_proof'), findsNothing);
    });
  });

  // T039 (SC-003, data-model §3): the exact action set for every status ×
  // type × rights combination. Drafts carry a line, so Confirmar is enabled
  // and the line icons exist.
  testWidgets('action matrix', (tester) async {
    const confirm = 'delivery_order_confirm';
    const cancel = 'delivery_order_cancel';
    const requeue = 'delivery_order_requeue';
    const ready = 'delivery_order_ready';
    const handover = 'delivery_order_pickup';
    const editHeader = 'delivery_order_edit_header';
    const addLine = 'delivery_order_add_line';
    const lineEdit = 'delivery_order_line_edit_1';
    const lineRemove = 'delivery_order_line_remove_1';
    const all = {
      confirm,
      cancel,
      requeue,
      ready,
      handover,
      editHeader,
      addLine,
      lineEdit,
      lineRemove,
    };

    // What a user with Delivery Orders update and Sales Orders read is
    // offered, transcribed from data-model §3.
    Set<String> offered(DeliveryOrderStatus status, FulfillmentType type) {
      final isPickup = type == FulfillmentType.counterPickup;
      return switch (status) {
        DeliveryOrderStatus.draft => {
          editHeader,
          lineEdit,
          lineRemove,
          addLine,
          confirm,
          cancel,
        },
        DeliveryOrderStatus.pendingApproval => {cancel},
        DeliveryOrderStatus.approved => {if (isPickup) ready, cancel},
        DeliveryOrderStatus.readyForPickup => {if (isPickup) handover, cancel},
        DeliveryOrderStatus.inPreparation => {cancel},
        DeliveryOrderStatus.failed => {requeue, cancel},
        DeliveryOrderStatus.inTransit ||
        DeliveryOrderStatus.pickedUp ||
        DeliveryOrderStatus.delivered ||
        DeliveryOrderStatus.partiallyDelivered ||
        DeliveryOrderStatus.cancelled => {},
      };
    }

    for (final status in DeliveryOrderStatus.values) {
      for (final type in FulfillmentType.values) {
        for (final (update, salesRead) in const [
          (false, true),
          (true, true),
          (true, false),
        ]) {
          await tester.pumpWidget(const SizedBox.shrink());
          await pumpDetail(
            tester,
            detail: detailOf(
              _order(
                serial: status == DeliveryOrderStatus.draft ? null : 1532,
                status: status,
                type: type,
              ),
            ),
            access: _access(update: update, salesOrdersRead: salesRead),
          );

          final expected = !update
              ? <String>{}
              : (offered(status, type)
                  ..removeWhere((k) => k == addLine && !salesRead));
          final present = {
            for (final k in all)
              if (find.byKey(Key(k)).evaluate().isNotEmpty) k,
          };
          final label =
              '${status.name} ${type.name} update=$update '
              'salesRead=$salesRead';
          expect(present, expected, reason: label);
          if (expected.contains(confirm)) {
            expect(
              tester.widget<FilledButton>(key(confirm)).onPressed,
              isNotNull,
              reason: label,
            );
          }
        }
      }
    }
  });

  // Spec 062 T024 (data-model §4, FR-013): Rechazar and Aprobar need Delivery
  // Order Approval update and an order waiting for approval, and nothing
  // else. Cancelar still needs Delivery Orders update (spec 061 FR-018).
  testWidgets('approval action matrix (spec 062)', (tester) async {
    const cancel = 'delivery_order_cancel';
    const reject = 'delivery_order_reject';
    const approve = 'delivery_order_approve';
    const watched = {cancel, reject, approve};
    const cancellable = {
      DeliveryOrderStatus.draft,
      DeliveryOrderStatus.pendingApproval,
      DeliveryOrderStatus.approved,
      DeliveryOrderStatus.readyForPickup,
      DeliveryOrderStatus.inPreparation,
      DeliveryOrderStatus.failed,
    };

    for (final status in DeliveryOrderStatus.values) {
      for (final (orders, approval) in const [
        (false, false),
        (true, false),
        (false, true),
        (true, true),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await pumpDetail(
          tester,
          detail: detailOf(
            _order(
              serial: status == DeliveryOrderStatus.draft ? null : 1532,
              status: status,
            ),
          ),
          access: _access(update: orders, approvalUpdate: approval),
        );

        final expected = {
          if (orders && cancellable.contains(status)) cancel,
          if (approval && status == DeliveryOrderStatus.pendingApproval) ...{
            reject,
            approve,
          },
        };
        final present = {
          for (final k in watched)
            if (find.byKey(Key(k)).evaluate().isNotEmpty) k,
        };
        expect(
          present,
          expected,
          reason: '${status.name} ordersUpdate=$orders approval=$approval',
        );
      }
    }
  });

  group('approval (spec 062)', () {
    final pending = _order(status: DeliveryOrderStatus.pendingApproval);

    testWidgets('an approver with both rights sees Cancelar, Rechazar and '
        'Aprobar in that order, Aprobar filled', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(pending),
        access: _access(update: true, approvalUpdate: true),
      );

      final cancelX = tester.getTopLeft(key('delivery_order_cancel')).dx;
      final rejectX = tester.getTopLeft(key('delivery_order_reject')).dx;
      final approveX = tester.getTopLeft(key('delivery_order_approve')).dx;
      expect(cancelX, lessThan(rejectX));
      expect(rejectX, lessThan(approveX));
      expect(
        tester.widget<FilledButton>(key('delivery_order_approve')).onPressed,
        isNotNull,
      );
      expect(find.byType(OutlinedButton), findsNWidgets(2));
    });

    testWidgets('an approver without Delivery Orders update sees only the two '
        'approval actions', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(pending),
        access: _access(approvalUpdate: true),
      );

      expect(key('delivery_order_approve'), findsOneWidget);
      expect(key('delivery_order_reject'), findsOneWidget);
      expect(key('delivery_order_cancel'), findsNothing);
    });

    testWidgets('approving asks first, writes once, says which status the '
        'order moved to, and the reloaded screen shows it', (tester) async {
      var current = detailOf(pending);
      final actions = _FakeActions(
        onSuccess: () => current = detailOf(
          _order(status: DeliveryOrderStatus.inPreparation),
        ),
      );
      await pumpDetail(
        tester,
        answer: () async => current,
        access: _access(update: true, approvalUpdate: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_approve'));
      await tester.pumpAndSettle();
      expect(key('delivery_order_approve_dialog'), findsOneWidget);
      expect(actions.calls, isEmpty);

      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['approve']);
      expect(
        find.text(l10n.deliveryOrderSnackApproved('1532', 'En preparación')),
        findsOneWidget,
      );
      expect(key('delivery_order_approve'), findsNothing);
      expect(key('delivery_order_reject'), findsNothing);
    });

    testWidgets('rejecting needs a reason, and the reloaded draft shows it in '
        'the rejection banner', (tester) async {
      var current = detailOf(pending);
      final actions = _FakeActions(
        onSuccess: () => current = detailOf(
          // The server keeps the folio a rejected order was confirmed with.
          _order(
            status: DeliveryOrderStatus.draft,
            rejectionReason: 'Dirección equivocada',
          ),
        ),
      );
      await pumpDetail(
        tester,
        answer: () async => current,
        access: _access(update: true, approvalUpdate: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_reject'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(key('delivery_order_reject_submit'))
            .onPressed,
        isNull,
      );

      await tester.enterText(
        key('delivery_order_reject_reason'),
        'Dirección equivocada',
      );
      await tester.pump();
      await tester.tap(key('delivery_order_reject_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['reject Dirección equivocada']);
      expect(
        find.text(l10n.deliveryOrderSnackRejected('1532')),
        findsOneWidget,
      );
      expect(find.textContaining('Dirección equivocada'), findsWidgets);
      expect(key('delivery_order_reject'), findsNothing);
      expect(key('delivery_order_approve'), findsNothing);
    });

    testWidgets('a refusal stays in the dialog and the order is unchanged', (
      tester,
    ) async {
      final actions = _FakeActions(
        error: const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'delivery_order.not_pending_approval',
            code: api.ErrorCode.deliveryOrderPeriodNotPendingApproval,
          ),
        ),
      );
      await pumpDetail(
        tester,
        detail: detailOf(pending),
        access: _access(update: true, approvalUpdate: true),
        actions: actions,
      );

      await tester.tap(key('delivery_order_approve'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_approve_dialog'), findsOneWidget);
      expect(
        find.text(l10n.apiErrorDeliveryOrderNotPendingApproval),
        findsOneWidget,
      );
      await tester.tap(key('delivery_order_approve_close'));
      await tester.pumpAndSettle();
      expect(key('delivery_order_approve_dialog'), findsNothing);
    });
  });

  group('print the ticket (spec 064 US1)', () {
    late AppLocalizations en;

    setUpAll(() async {
      en = await AppLocalizations.delegate.load(const Locale('en'));
    });

    const printable = [
      DeliveryOrderStatus.approved,
      DeliveryOrderStatus.readyForPickup,
      DeliveryOrderStatus.pickedUp,
      DeliveryOrderStatus.inPreparation,
      DeliveryOrderStatus.inTransit,
      DeliveryOrderStatus.delivered,
      DeliveryOrderStatus.partiallyDelivered,
      DeliveryOrderStatus.failed,
      DeliveryOrderStatus.cancelled,
    ];

    // One pump per test: a second pump in one test leaves a provider timer
    // pending.
    for (final status in printable) {
      testWidgets('is offered when the order is ${status.name}', (
        tester,
      ) async {
        await pumpDetail(tester, detail: detailOf(_order(status: status)));
        expect(key('delivery_order_view_ticket'), findsOneWidget);
      });
    }

    testWidgets('is absent for a draft', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(
          _order(status: DeliveryOrderStatus.draft, serial: null),
        ),
      );
      expect(key('delivery_order_view_ticket'), findsNothing);
    });

    testWidgets('is absent for an order awaiting approval', (tester) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order(status: DeliveryOrderStatus.pendingApproval)),
      );
      expect(key('delivery_order_view_ticket'), findsNothing);
    });

    testWidgets('is absent for a user without Delivery Orders read', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order()),
        access: accessControlProvider.overrideWithValue(
          accessFor(noPrivileges),
        ),
      );

      expect(key('delivery_order_view_ticket'), findsNothing);
      expect(key('delivery_order_actions'), findsNothing);
    });

    testWidgets('leads the action area, left of the status actions', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        detail: detailOf(_order(status: DeliveryOrderStatus.failed)),
        access: _access(update: true),
      );

      expect(
        tester.getTopLeft(key('delivery_order_view_ticket')).dx,
        lessThan(tester.getTopLeft(key('delivery_order_requeue')).dx),
      );
      expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isNull);
    });

    testWidgets('opens the ticket of a one-warehouse order in the preview, '
        'unlimited', (tester) async {
      final documents = FakeDocumentSource();
      await pumpDetail(
        tester,
        detail: detailOf(_order(status: DeliveryOrderStatus.approved)),
        documents: documents,
      );

      await tester.tap(key('delivery_order_view_ticket'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(documents.fetched, hasLength(1));
      expect(documents.fetched.single.kind, DocumentKind.deliveryTicket);
      expect(documents.fetched.single.recordId, 9);
      expect(documents.fetched.single.warehouseId, isNull);
      expect(documents.fetched.single.title, 'Ticket de entrega · 1532');
      expect(
        tester.widget<Text>(key('document_preview_title')).data,
        'Ticket de entrega · 1532',
      );
    });

    testWidgets('asks the server for a pickup order\'s ticket the same way', (
      tester,
    ) async {
      final documents = FakeDocumentSource();
      await pumpDetail(
        tester,
        detail: detailOf(
          _order(
            status: DeliveryOrderStatus.approved,
            type: FulfillmentType.counterPickup,
          ),
        ),
        documents: documents,
      );

      await tester.tap(key('delivery_order_view_ticket'));
      await tester.pumpAndSettle();

      // The app never picks the delivery or the pickup ticket (FR-022).
      expect(documents.fetched.single.kind, DocumentKind.deliveryTicket);
      expect(documents.fetched.single.warehouseId, isNull);
    });

    testWidgets('pressing again while the preview loads fetches only once', (
      tester,
    ) async {
      final gate = Completer<RenderedDocument>();
      final documents = FakeDocumentSource(handler: (_) => gate.future);
      await pumpDetail(
        tester,
        detail: detailOf(_order(status: DeliveryOrderStatus.approved)),
        documents: documents,
      );
      final button = tester.widget<OutlinedButton>(
        key('delivery_order_view_ticket'),
      );

      button.onPressed!();
      button.onPressed!();
      await tester.pump();

      expect(documents.fetched, hasLength(1));
      gate.complete(fakeDocument());
      await tester.pumpAndSettle();
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
    });

    testWidgets('closing the preview leaves the screen as it was and reloads '
        'nothing (FR-040, FR-041)', (tester) async {
      var loads = 0;
      final order = detailOf(_order(status: DeliveryOrderStatus.approved));
      await pumpDetail(
        tester,
        answer: () async {
          loads++;
          return order;
        },
        access: _access(update: true),
      );
      expect(loads, 1);

      await tester.tap(key('delivery_order_view_ticket'));
      await tester.pumpAndSettle();
      await tester.tap(key('document_preview_close'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(loads, 1);
      expect(key('delivery_order_view_ticket'), findsOneWidget);
      expect(key('delivery_order_cancel'), findsOneWidget);
    });

    // Refusals reach the preview through its shared error banner, which
    // builds the text from the server's code (constitution §III), so each of
    // the three codes this feature adds reads in the user's language.
    final refusals = <String, (AppError, String Function(AppLocalizations))>{
      'delivery_order.not_approved': (
        AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'delivery_order.not_approved',
            code: api.ErrorCode.deliveryOrderPeriodNotApproved,
            params: const {'status': 'DRAFT'},
          ),
        ),
        (l) => l.apiErrorDeliveryOrderNotApproved,
      ),
      'delivery_order.no_lines_from_warehouse': (
        AppError.validation(
          const [],
          null,
          ApiProblem(
            codeName: 'delivery_order.no_lines_from_warehouse',
            code: api.ErrorCode.deliveryOrderPeriodNoLinesFromWarehouse,
            params: const {'warehouse_id': 2},
          ),
        ),
        (l) => l.apiErrorDeliveryOrderNoLinesFromWarehouse,
      ),
      'delivery_order.unknown_warehouse': (
        AppError.validation(
          const [],
          null,
          ApiProblem(
            codeName: 'delivery_order.unknown_warehouse',
            code: api.ErrorCode.deliveryOrderPeriodUnknownWarehouse,
            params: const {'warehouse_id': 99},
          ),
        ),
        (l) => l.apiErrorDeliveryOrderUnknownWarehouse,
      ),
    };

    for (final entry in refusals.entries) {
      for (final english in [false, true]) {
        testWidgets('${entry.key} reads in ${english ? 'English' : 'Spanish'} '
            'in the preview, with a retry', (tester) async {
          final (error, text) = entry.value;
          final documents = FakeDocumentSource(handler: (_) => throw error);
          await pumpDetail(
            tester,
            detail: detailOf(_order(status: DeliveryOrderStatus.approved)),
            documents: documents,
            locale: english ? const Locale('en') : const Locale('es', 'MX'),
          );

          await tester.tap(key('delivery_order_view_ticket'));
          await tester.pumpAndSettle();

          expect(find.text(text(english ? en : l10n)), findsOneWidget);
          expect(key('document_preview_retry'), findsOneWidget);
        });
      }
    }
  });
}
