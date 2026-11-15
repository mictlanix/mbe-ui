import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_screen.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockRepository extends Mock implements DeliveryOrderAdminRepository {}

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

DeliveryOrderSummary _row(
  int id, {
  required int serial,
  FulfillmentType type = FulfillmentType.delivery,
  List<int> sales = const [8790, 8812],
  int priority = 2,
  int customer = 7,
}) => DeliveryOrderSummary(
  id: id,
  facilityId: 1,
  serial: serial,
  customerId: customer,
  salesOrderIds: sales,
  shipToId: 11,
  date: DateTime(2026, 11, 16),
  priority: priority,
  status: DeliveryOrderStatus.pendingApproval,
  type: type,
);

DeliveryOrder _approved(int id, DeliveryOrderStatus status) => DeliveryOrder(
  id: id,
  facilityId: 1,
  serial: 1500 + id,
  customerId: 7,
  priority: 0,
  status: status,
  type: FulfillmentType.delivery,
  createdAt: DateTime(2026, 11, 1),
  modifiedAt: DateTime(2026, 11, 1),
);

/// Spec 062 US1 (T015), contracts C2: the "Aprobación de entregas" queue.
/// The route gate is covered in `app_router_test.dart`.
void main() {
  late _MockRepository repository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => repository = _MockRepository());

  /// A fake server over [queue]: approving removes the order from it, as the
  /// real one does.
  void serve(List<DeliveryOrderSummary> queue, {int? total}) {
    when(
      () => repository.approvalQueue(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => DeliveryOrderPage(
        items: List.of(queue),
        total: total ?? queue.length,
      ),
    );
  }

  Override access({bool update = true, bool orders = false}) =>
      accessControlProvider.overrideWithValue(
        AccessControlService(
          AuthState.authenticated(
            token: 't',
            user: User(
              userId: 'a',
              email: 'a@example.com',
              administrator: false,
              status: EntityStatus.active,
              sessionVersion: 1,
              privileges: [
                Privilege(
                  systemObject: SystemObject.deliveryOrderApproval,
                  rawValue: update ? 6 : 2,
                ),
                if (orders)
                  const Privilege(
                    systemObject: SystemObject.deliveryOrders,
                    rawValue: 2,
                  ),
              ],
            ),
          ),
        ),
      );

  Future<GoRouter> pump(
    WidgetTester tester, {
    Override? who,
    int? facilityId = 1,
    String location = deliveryOrderApprovalPath,
    Size surface = const Size(1400, 1000),
    Future<String?> Function(int id)? customerName,
    Future<Customer> Function(int id)? customerLookup,
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
        customerDisplayNameProvider.overrideWith(
          (ref, id) => (customerName ?? (i) async => 'Cliente $i')(id),
        ),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => 'Sucursal $id',
        ),
        saleCustomerControllerProvider.overrideWith(
          (ref, id) => (customerLookup ?? (i) async => _customer(i))(id),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: deliveryOrderApprovalPath,
          builder: (context, state) => Scaffold(
            body: DeliveryOrderApprovalScreen(
              query: ListQuery.fromUri(state.uri),
            ),
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
    await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  group('table', () {
    testWidgets('shows folio, customer, type, date, ship-to, sales orders and '
        'priority for each waiting order, with the server total in the '
        'footer', (tester) async {
      serve([
        _row(31, serial: 1541),
        _row(
          32,
          serial: 1536,
          type: FulfillmentType.counterPickup,
          sales: const [8802],
          priority: 0,
        ),
      ]);

      await pump(tester);

      expect(key('delivery_order_approval_table'), findsOneWidget);
      expect(find.text('1541'), findsOneWidget);
      expect(find.text('1536'), findsOneWidget);
      expect(find.text('Cliente 7'), findsNWidgets(2));
      expect(find.text('Entrega'), findsOneWidget);
      expect(find.text('Recoge en tienda'), findsOneWidget);
      expect(find.text('2026-11-16'), findsNWidgets(2));
      // A delivery's destination is the customer's address, a pickup's is the
      // facility (spec 061 name cells).
      expect(find.text('Av. Juárez 120, Centro'), findsOneWidget);
      expect(find.text('Sucursal 1'), findsOneWidget);
      expect(find.text('8790, 8812'), findsOneWidget);
      expect(find.text('8802'), findsOneWidget);
      expect(
        find.text(l10n.deliveryOrderApprovalColumnPriority),
        findsOneWidget,
      );
      expect(find.textContaining('de 2'), findsOneWidget);
      // No filter row at all: nothing here to search or filter (FR-003).
      expect(find.byIcon(Icons.tune), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('asks the server for the first page and nothing else, no '
        'facility included', (tester) async {
      serve([_row(31, serial: 1541)]);

      await pump(tester);

      verify(() => repository.approvalQueue(skip: 0, limit: 20)).called(1);
    });

    testWidgets("a name the user can't read falls back to its number "
        '(spec edge case)', (tester) async {
      serve([_row(31, serial: 1541)]);

      await pump(
        tester,
        customerName: (id) async => null,
        customerLookup: (id) async =>
            throw const AppError.server(statusCode: 403),
      );

      expect(find.text('#7'), findsOneWidget, reason: 'customer');
      expect(find.text('#11'), findsOneWidget, reason: 'ship-to');
    });
  });

  group('rights (FR-005, SC-005)', () {
    testWidgets('a user with update gets an approve icon on every row', (
      tester,
    ) async {
      serve([_row(31, serial: 1541), _row(32, serial: 1536)]);

      await pump(tester);

      expect(key('approve_delivery_order_31'), findsOneWidget);
      expect(key('approve_delivery_order_32'), findsOneWidget);
    });

    testWidgets('a user with read only sees the list but no action column', (
      tester,
    ) async {
      serve([_row(31, serial: 1541)]);

      await pump(tester, who: access(update: false));

      expect(find.text('1541'), findsOneWidget);
      expect(key('approve_delivery_order_31'), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    });
  });

  group('states', () {
    testWidgets('no facility shows the notice and makes no request (FR-004)', (
      tester,
    ) async {
      serve([_row(31, serial: 1541)]);

      await pump(tester, facilityId: null);

      expect(key('delivery_order_approval_no_facility'), findsOneWidget);
      expect(
        find.text(l10n.deliveryOrderApprovalNoFacilityMessage),
        findsOneWidget,
      );
      verifyNever(
        () => repository.approvalQueue(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });

    testWidgets('an empty queue says so and offers no action', (tester) async {
      serve(const []);

      await pump(tester);

      expect(find.text(l10n.deliveryOrderApprovalEmpty), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });

    testWidgets('a 403 shows the not-allowed state with no retry', (
      tester,
    ) async {
      when(
        () => repository.approvalQueue(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const AppError.server(statusCode: 403));

      await pump(tester);

      expect(key('delivery_order_approval_forbidden'), findsOneWidget);
      expect(find.text(l10n.retryButton), findsNothing);
    });

    testWidgets('a load error shows retry, and retrying loads the page', (
      tester,
    ) async {
      var calls = 0;
      when(
        () => repository.approvalQueue(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const AppError.server(statusCode: 500);
        return DeliveryOrderPage(items: [_row(31, serial: 1541)], total: 1);
      });

      await pump(tester);
      expect(find.text(l10n.retryButton), findsOneWidget);

      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(find.text('1541'), findsOneWidget);
    });
  });

  group('approving from a row (US1)', () {
    testWidgets('tapping approve asks first, naming the customer, type and '
        'date and the next status, and writes nothing until confirmed', (
      tester,
    ) async {
      serve([_row(31, serial: 1541)]);
      await pump(tester);

      await tester.tap(key('approve_delivery_order_31'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_approve_dialog'), findsOneWidget);
      expect(find.text(l10n.deliveryOrderApproveTitle('1541')), findsOneWidget);
      expect(find.text(l10n.deliveryOrderApproveNextDelivery), findsOneWidget);
      verifyNever(() => repository.approve(any()));
    });

    testWidgets('confirming approves, says which status the order moved to, '
        'and the row leaves the queue', (tester) async {
      final queue = [_row(31, serial: 1541), _row(32, serial: 1536)];
      serve(queue);
      when(() => repository.approve(31)).thenAnswer((_) async {
        queue.removeWhere((o) => o.id == 31);
        return _approved(31, DeliveryOrderStatus.inPreparation);
      });
      await pump(tester);

      await tester.tap(key('approve_delivery_order_31'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pumpAndSettle();

      verify(() => repository.approve(31)).called(1);
      expect(
        find.text(l10n.deliveryOrderSnackApproved('1541', 'En preparación')),
        findsOneWidget,
      );
      expect(find.text('1541'), findsNothing);
      expect(find.text('1536'), findsOneWidget);
    });

    testWidgets('backing out writes nothing and keeps the row', (tester) async {
      serve([_row(31, serial: 1541)]);
      await pump(tester);

      await tester.tap(key('approve_delivery_order_31'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.deliveryOrderBackButton));
      await tester.pumpAndSettle();

      verifyNever(() => repository.approve(any()));
      expect(find.text('1541'), findsOneWidget);
    });
  });

  group('rejecting from a row (US2)', () {
    testWidgets('a user with update gets approve and reject, and nothing '
        'else, on every row', (tester) async {
      serve([_row(31, serial: 1541)]);

      await pump(tester);

      expect(key('approve_delivery_order_31'), findsOneWidget);
      expect(key('reject_delivery_order_31'), findsOneWidget);
      expect(find.byType(PopupMenuButton<VoidCallback>), findsNothing);
    });

    testWidgets('a user with read only gets neither icon', (tester) async {
      serve([_row(31, serial: 1541)]);

      await pump(tester, who: access(update: false));

      expect(key('approve_delivery_order_31'), findsNothing);
      expect(key('reject_delivery_order_31'), findsNothing);
    });

    testWidgets('rejecting needs a reason, then writes it, says the order '
        'went back to draft, and the row leaves the queue', (tester) async {
      final queue = [_row(31, serial: 1541), _row(32, serial: 1536)];
      serve(queue);
      when(
        () => repository.reject(id: 31, reason: 'Dirección equivocada'),
      ).thenAnswer((_) async {
        queue.removeWhere((o) => o.id == 31);
        return _approved(31, DeliveryOrderStatus.draft);
      });
      await pump(tester);

      await tester.tap(key('reject_delivery_order_31'));
      await tester.pumpAndSettle();
      expect(key('delivery_order_reject_dialog'), findsOneWidget);
      verifyNever(
        () => repository.reject(
          id: any(named: 'id'),
          reason: any(named: 'reason'),
        ),
      );

      await tester.enterText(
        key('delivery_order_reject_reason'),
        'Dirección equivocada',
      );
      await tester.pump();
      await tester.tap(key('delivery_order_reject_submit'));
      await tester.pumpAndSettle();

      verify(
        () => repository.reject(id: 31, reason: 'Dirección equivocada'),
      ).called(1);
      expect(
        find.text(l10n.deliveryOrderSnackRejected('1541')),
        findsOneWidget,
      );
      expect(find.text('1541'), findsNothing);
      expect(find.text('1536'), findsOneWidget);
    });

    testWidgets('a refusal keeps the dialog open and the row in the queue', (
      tester,
    ) async {
      serve([_row(31, serial: 1541)]);
      when(() => repository.reject(id: 31, reason: 'x')).thenThrow(
        const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'delivery_order.not_pending_approval',
            code: api.ErrorCode.deliveryOrderPeriodNotPendingApproval,
          ),
        ),
      );
      await pump(tester);

      await tester.tap(key('reject_delivery_order_31'));
      await tester.pumpAndSettle();
      await tester.enterText(key('delivery_order_reject_reason'), 'x');
      await tester.pump();
      await tester.tap(key('delivery_order_reject_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.apiErrorDeliveryOrderNotPendingApproval),
        findsOneWidget,
      );
      expect(key('delivery_order_reject_dialog'), findsOneWidget);
    });
  });

  group('paging (spec edge case "Last row on a page")', () {
    testWidgets('a page left empty by the last action steps back one page', (
      tester,
    ) async {
      // Page 2 in the URL (index 1) holds one order; approving it leaves 20,
      // all on page 1.
      var approved = false;
      when(
        () => repository.approvalQueue(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((i) async {
        final skip = i.namedArguments[#skip] as int;
        final all = [
          for (var n = 1; n <= 20; n++) _row(n, serial: 1000 + n),
          if (!approved) _row(99, serial: 1999),
        ];
        return DeliveryOrderPage(
          items: all.skip(skip).take(20).toList(),
          total: all.length,
        );
      });
      when(() => repository.approve(99)).thenAnswer((_) async {
        approved = true;
        return _approved(99, DeliveryOrderStatus.inPreparation);
      });

      await pump(tester, location: '$deliveryOrderApprovalPath?page=2');
      expect(find.text('1999'), findsOneWidget);

      await tester.tap(key('approve_delivery_order_99'));
      await tester.pumpAndSettle();
      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pumpAndSettle();

      expect(find.text('1999'), findsNothing);
      expect(find.text('1001'), findsOneWidget, reason: 'back on page 0');
    });
  });

  group('opening the order (US3, FR-006)', () {
    testWidgets('with Delivery Orders read, a row tap pushes the order screen '
        'and back returns to the queue', (tester) async {
      serve([_row(31, serial: 1541), _row(32, serial: 1536)]);
      final router = await pump(tester, who: access(orders: true));

      await tester.tap(find.text('1541'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/delivery-orders/31');
      expect(find.text('order-31'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      expect(router.state.uri.path, deliveryOrderApprovalPath);
      expect(find.text('1541'), findsOneWidget);
      expect(find.text('1536'), findsOneWidget);
    });

    testWidgets('tapping an icon does not also open the order', (tester) async {
      serve([_row(31, serial: 1541)]);
      final router = await pump(tester, who: access(orders: true));

      await tester.tap(key('approve_delivery_order_31'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_approve_dialog'), findsOneWidget);
      expect(router.state.uri.path, deliveryOrderApprovalPath);
    });

    testWidgets('without Delivery Orders read, rows are not tappable, and the '
        'row icons still work', (tester) async {
      serve([_row(31, serial: 1541)]);
      final router = await pump(tester, who: access(orders: false));

      await tester.tap(find.text('1541'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, deliveryOrderApprovalPath);
      expect(find.text('order-31'), findsNothing);

      await tester.tap(key('reject_delivery_order_31'));
      await tester.pumpAndSettle();
      expect(key('delivery_order_reject_dialog'), findsOneWidget);
    });
  });
}
