import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';

class MockDeliveryOrderAdminRepository extends Mock
    implements DeliveryOrderAdminRepository {}

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

const _id = 900;

DeliveryOrderLine _line(int id, int salesOrderDetail) => DeliveryOrderLine(
  id: id,
  salesOrderDetailId: salesOrderDetail,
  productId: 11,
  productCode: 'P-$id',
  productName: 'Widget $id',
  warehouseId: 3,
  quantity: Decimal.one,
  committed: Decimal.one,
  delivered: Decimal.zero,
  returned: Decimal.zero,
  open: Decimal.one,
);

DeliveryOrder _order({
  List<int> sales = const [501],
  List<DeliveryOrderLine>? lines,
  DeliveryOrderStatus status = DeliveryOrderStatus.draft,
}) => DeliveryOrder(
  id: _id,
  facilityId: 4,
  customerId: 77,
  salesOrderIds: sales,
  priority: 0,
  status: status,
  type: FulfillmentType.delivery,
  createdAt: DateTime(2026, 11, 1),
  modifiedAt: DateTime(2026, 11, 1),
  lines: lines ?? [_line(1, 7001), _line(2, 7002)],
);

DeliveryOrderSummary _summary(int id, {int? parent}) => DeliveryOrderSummary(
  id: id,
  facilityId: 4,
  customerId: 77,
  priority: 0,
  status: DeliveryOrderStatus.inPreparation,
  type: FulfillmentType.delivery,
  parentId: parent,
);

SaleLine _saleLine(int id) => SaleLine(
  id: id,
  product: 11,
  productCode: 'P-$id',
  productName: 'Widget $id',
  quantity: '1',
  price: '50.00',
  discountRate: '0',
  taxRate: '0.16',
  taxIncluded: false,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
);

Sale _sale(int id, List<int> lineIds) => Sale(
  id: id,
  facility: 4,
  salesperson: 100,
  customer: 77,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  status: SaleStatus.completed,
  lines: [for (final l in lineIds) _saleLine(l)],
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  balance: '0',
  date: DateTime(2026, 11, 1),
  dueDate: DateTime(2026, 11, 1),
  priority: Priority.normal,
);

final _event = DeliveryOrderEvent(
  id: 1,
  to: DeliveryOrderStatus.draft,
  employeeId: 5,
  at: DateTime(2026, 11, 1),
);

/// [salesRead]: whether the user holds Sales Orders read (an administrator
/// does; a user with no privileges doesn't).
AccessControlService _access({required bool salesRead}) => AccessControlService(
  AuthState.authenticated(
    token: 't',
    user: User(
      userId: 'u',
      email: 'u@example.com',
      administrator: salesRead,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: const [],
    ),
  ),
);

/// Spec 061 research R5 (T010).
void main() {
  late MockDeliveryOrderAdminRepository repository;
  late MockSalesOrderRepository sales;

  setUp(() {
    repository = MockDeliveryOrderAdminRepository();
    sales = MockSalesOrderRepository();
  });

  ProviderContainer container({bool salesRead = true}) {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        deliveryOrderAdminRepositoryProvider.overrideWithValue(repository),
        salesOrderRepositoryProvider.overrideWithValue(sales),
        accessControlProvider.overrideWithValue(_access(salesRead: salesRead)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<DeliveryOrderDetail> load(ProviderContainer c) =>
      c.read(deliveryOrderDetailControllerProvider(_id).future);

  When<Future<DeliveryOrderPage>> whenList() => when(
    () => repository.list(
      status: any(named: 'status'),
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
  );

  test('the order and its events are requested together', () async {
    final order = Completer<DeliveryOrder>();
    when(() => repository.getById(_id)).thenAnswer((_) => order.future);
    when(() => repository.events(_id)).thenAnswer((_) async => [_event]);

    final c = container();
    final detail = load(c);
    await Future<void>.delayed(Duration.zero);
    // Events asked for before the order has answered.
    verify(() => repository.events(_id)).called(1);

    order.complete(_order());
    final result = await detail;
    expect(result.order.id, _id);
    expect(result.events.value, [_event]);
  });

  test("an events failure doesn't hide the order", () async {
    when(() => repository.getById(_id)).thenAnswer((_) async => _order());
    when(
      () => repository.events(_id),
    ).thenThrow(const AppError.server(statusCode: 500));

    final result = await load(container());

    expect(result.order.id, _id);
    expect(result.events.hasError, isTrue);
    expect(result.events.error, isA<ServerError>());
  });

  test('an order failure is the provider error', () async {
    when(
      () => repository.getById(_id),
    ).thenAnswer((_) async => throw const AppError.notFound());
    when(() => repository.events(_id)).thenAnswer((_) async => [_event]);

    await expectLater(load(container()), throwsA(isA<NotFoundError>()));
  });

  group('sale map', () {
    setUp(() => when(() => repository.events(_id)).thenAnswer((_) async => []));

    test('one sale: every line maps to it, with no request', () async {
      when(() => repository.getById(_id)).thenAnswer((_) async => _order());

      final result = await load(container(salesRead: false));

      expect(result.sales, {7001: 501, 7002: 501});
      verifyNever(() => sales.getById(saleId: any(named: 'saleId')));
    });

    test('several sales: each is read and its lines mapped', () async {
      when(
        () => repository.getById(_id),
      ).thenAnswer((_) async => _order(sales: [501, 502]));
      when(
        () => sales.getById(saleId: 501),
      ).thenAnswer((_) async => _sale(501, [7001]));
      when(
        () => sales.getById(saleId: 502),
      ).thenAnswer((_) async => _sale(502, [7002, 7003]));

      final result = await load(container());

      expect(result.sales, {7001: 501, 7002: 502, 7003: 502});
    });

    test('several sales, one failing: the map is empty', () async {
      when(
        () => repository.getById(_id),
      ).thenAnswer((_) async => _order(sales: [501, 502]));
      when(
        () => sales.getById(saleId: 501),
      ).thenAnswer((_) async => _sale(501, [7001]));
      when(
        () => sales.getById(saleId: 502),
      ).thenThrow(const AppError.notFound());

      final result = await load(container());

      expect(result.order.id, _id);
      expect(result.sales, isEmpty);
    });

    test(
      'several sales without Sales Orders read: empty, no request',
      () async {
        when(
          () => repository.getById(_id),
        ).thenAnswer((_) async => _order(sales: [501, 502]));

        final result = await load(container(salesRead: false));

        expect(result.sales, isEmpty);
        verifyNever(() => sales.getById(saleId: any(named: 'saleId')));
      },
    );
  });

  group('children', () {
    setUp(() => when(() => repository.events(_id)).thenAnswer((_) async => []));

    test('a partial delivery looks them up at its own facility and keeps '
        'only those whose parent is this order', () async {
      when(() => repository.getById(_id)).thenAnswer(
        (_) async => _order(status: DeliveryOrderStatus.partiallyDelivered),
      );
      whenList().thenAnswer(
        (_) async => DeliveryOrderPage(
          items: [
            _summary(_id),
            _summary(950, parent: _id),
            _summary(960),
          ],
          total: 3,
        ),
      );

      final result = await load(container());

      expect(result.children.map((o) => o.id), [950]);
      verify(
        () => repository.list(
          salesOrder: 501,
          facility: 4,
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });

    test('any other status makes no lookup', () async {
      when(
        () => repository.getById(_id),
      ).thenAnswer((_) async => _order(status: DeliveryOrderStatus.delivered));

      final result = await load(container());

      expect(result.children, isEmpty);
      verifyNever(
        () => repository.list(
          status: any(named: 'status'),
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
      );
    });

    test('a failed lookup leaves the children empty', () async {
      when(() => repository.getById(_id)).thenAnswer(
        (_) async => _order(status: DeliveryOrderStatus.partiallyDelivered),
      );
      whenList().thenThrow(const AppError.server(statusCode: 500));

      final result = await load(container());

      expect(result.order.id, _id);
      expect(result.children, isEmpty);
    });
  });
}
