import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

/// spec 036 R1: `addDestination` confirms the sale first when it's still
/// `draft` (`confirmBeforePayableAction`, `pos_confirm.dart`), which reads
/// `posSaleControllerProvider` — this seeds it directly with the same [Sale]
/// these tests already drive `deliveryControllerProvider` with, bypassing
/// `open()`/`load()`.
class _FixedPosSale extends PosSaleController {
  _FixedPosSale(this._sale);
  final Sale _sale;
  @override
  Future<Sale?> build() async => _sale;
}

SaleLine _line({required int id, required String quantity}) => SaleLine(
  id: id,
  product: 11,
  productCode: 'P-$id',
  productName: 'Widget $id',
  quantity: quantity,
  cost: '0',
  price: '50.00',
  discountRate: '0',
  taxRate: '0.16',
  taxIncluded: false,
  warehouse: 3,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
);

Sale _sale({required List<SaleLine> lines}) => Sale(
  id: 42,
  facility: 9,
  pointSale: 3,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 8, 20),
  status: SaleStatus.draft,
  lines: lines,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  balance: '0',
  date: DateTime(2026, 8, 20),
  dueDate: DateTime(2026, 8, 20),
  priority: Priority.normal,
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(addressId: 11, label: 'Destino uno', type: AddressType.business),
  ],
);

Destination _created({required List<DestinationLine> lines}) => Destination(
  id: 500,
  fulfillmentType: FulfillmentType.delivery,
  shipTo: 11,
  status: DeliveryOrderStatus.draft,
  lines: lines,
);

/// T053 (US7, FR-023…FR-025, research R12): `DeliveryController.addDestination`
/// sends every line's full `claimable` quantity explicitly on the very first
/// destination — never relying on mbe-api's "omit `lines`" convention, which
/// would claim everything the sale still owes even for a later destination —
/// and keeps sending an explicit empty list for every destination after that.
void main() {
  late MockDeliveryOrderRepository deliveries;
  late MockCustomerRepository customers;
  late MockSalesOrderRepository salesOrders;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FulfillmentType.delivery);
  });

  setUp(() {
    deliveries = MockDeliveryOrderRepository();
    customers = MockCustomerRepository();
    salesOrders = MockSalesOrderRepository();
    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
  });

  /// Builds the container against [sale] and seeds `posSaleControllerProvider`
  /// with it (`confirmBeforePayableAction` reads that controller, not the
  /// `sale` parameter `deliveryControllerProvider` closes over). Also stubs
  /// `confirm` to a no-op success, since these tests don't assert on its own
  /// effect, and keeps a live listener so the `autoDispose` controller isn't
  /// torn down between this call and the test's later read.
  ProviderContainer containerFor(Sale sale) {
    when(
      () => salesOrders.confirm(saleId: sale.id),
    ).thenAnswer((_) async => sale);
    final c = ProviderContainer(
      overrides: [
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
        customerRepositoryProvider.overrideWithValue(customers),
        salesOrderRepositoryProvider.overrideWithValue(salesOrders),
        posSaleControllerProvider.overrideWith(() => _FixedPosSale(sale)),
      ],
    );
    addTearDown(c.dispose);
    c.listen(posSaleControllerProvider, (_, _) {});
    return c;
  }

  test(
    "the first destination's create carries every line's claimable quantity",
    () async {
      final sale = _sale(
        lines: [_line(id: 5, quantity: '10'), _line(id: 6, quantity: '4')],
      );
      container = containerFor(sale);
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => const []);
      when(
        () => deliveries.create(
          salesOrder: any(named: 'salesOrder'),
          fulfillmentType: any(named: 'fulfillmentType'),
          shipTo: any(named: 'shipTo'),
          contact: any(named: 'contact'),
          date: any(named: 'date'),
          comment: any(named: 'comment'),
          lines: any(named: 'lines'),
        ),
      ).thenAnswer(
        (_) async => _created(
          lines: const [
            DestinationLine(
              id: 900,
              salesOrderDetail: 5,
              product: 11,
              productCode: 'P-5',
              productName: 'Widget 5',
              quantity: '10',
            ),
            DestinationLine(
              id: 901,
              salesOrderDetail: 6,
              product: 11,
              productCode: 'P-6',
              productName: 'Widget 6',
              quantity: '4',
            ),
          ],
        ),
      );

      // Establishes build()'s empty destination list before addDestination
      // reads it.
      await container.read(deliveryControllerProvider(sale).future);
      await container
          .read(deliveryControllerProvider(sale).notifier)
          .addDestination(shipTo: 11);

      // `DestinationLineRequest` has no `==` override, so the sent list is
      // captured and its fields checked directly rather than matched by
      // equality.
      final captured = verify(
        () => deliveries.create(
          salesOrder: 42,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: 11,
          contact: null,
          date: null,
          comment: null,
          lines: captureAny(named: 'lines'),
        ),
      ).captured;
      expect(captured, hasLength(1));
      final lines = captured.single as List<DestinationLineRequest>;
      expect(
        lines.map((l) => (l.salesOrderDetail, l.quantity)),
        [(5, '10'), (6, '4')],
      );
    },
  );

  test(
    'confirm() precedes the first delivery-order create — the sale is still '
    'draft at that point (spec 036 R1)',
    () async {
      final sale = _sale(lines: [_line(id: 5, quantity: '10')]);
      container = containerFor(sale);
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => const []);
      when(
        () => deliveries.create(
          salesOrder: any(named: 'salesOrder'),
          fulfillmentType: any(named: 'fulfillmentType'),
          shipTo: any(named: 'shipTo'),
          contact: any(named: 'contact'),
          date: any(named: 'date'),
          comment: any(named: 'comment'),
          lines: any(named: 'lines'),
        ),
      ).thenAnswer((_) async => _created(lines: const []));

      await container.read(deliveryControllerProvider(sale).future);
      await container
          .read(deliveryControllerProvider(sale).notifier)
          .addDestination(shipTo: 11);

      verifyInOrder([
        () => salesOrders.confirm(saleId: 42),
        () => deliveries.create(
              salesOrder: any(named: 'salesOrder'),
              fulfillmentType: any(named: 'fulfillmentType'),
              shipTo: any(named: 'shipTo'),
              contact: any(named: 'contact'),
              date: any(named: 'date'),
              comment: any(named: 'comment'),
              lines: any(named: 'lines'),
            ),
      ]);
    },
  );

  test(
    'a second destination still sends an explicit empty list, unchanged '
    '(FR-025)',
    () async {
      final sale = _sale(lines: [_line(id: 5, quantity: '10')]);
      container = containerFor(sale);
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => [_created(lines: const [])]);
      when(
        () => deliveries.create(
          salesOrder: any(named: 'salesOrder'),
          fulfillmentType: any(named: 'fulfillmentType'),
          shipTo: any(named: 'shipTo'),
          contact: any(named: 'contact'),
          date: any(named: 'date'),
          comment: any(named: 'comment'),
          lines: any(named: 'lines'),
        ),
      ).thenAnswer(
        (_) async => Destination(
          id: 501,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: 12,
          status: DeliveryOrderStatus.draft,
        ),
      );

      await container.read(deliveryControllerProvider(sale).future);
      await container
          .read(deliveryControllerProvider(sale).notifier)
          .addDestination(shipTo: 12);

      verify(
        () => deliveries.create(
          salesOrder: 42,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: 12,
          contact: null,
          date: null,
          comment: null,
          lines: const [],
        ),
      ).called(1);
    },
  );

  test('a refused create adds nothing to state', () async {
    final sale = _sale(lines: [_line(id: 5, quantity: '10')]);
    container = containerFor(sale);
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => const []);
    when(
      () => deliveries.create(
        salesOrder: any(named: 'salesOrder'),
        fulfillmentType: any(named: 'fulfillmentType'),
        shipTo: any(named: 'shipTo'),
        contact: any(named: 'contact'),
        date: any(named: 'date'),
        comment: any(named: 'comment'),
        lines: any(named: 'lines'),
      ),
    ).thenThrow(const AppError.server(statusCode: 409, message: 'Refused'));

    await container.read(deliveryControllerProvider(sale).future);
    await expectLater(
      () => container
          .read(deliveryControllerProvider(sale).notifier)
          .addDestination(shipTo: 11),
      throwsA(isA<AppError>()),
    );

    expect(
      container.read(deliveryControllerProvider(sale)).valueOrNull,
      isEmpty,
    );
  });
}
