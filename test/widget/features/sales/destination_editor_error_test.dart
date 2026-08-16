import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_step.dart';

import 'pos_test_harness.dart';

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'Acme',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  shipping: true,
  shippingRequiredDocument: false,
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 11,
      label: 'Av. Reforma 100',
      type: AddressType.business,
    ),
  ],
);

Destination _existing() => Destination(
  id: 500,
  fulfillmentType: FulfillmentType.delivery,
  shipTo: 11,
  addressSummary: 'Av. Reforma 100',
  status: DeliveryOrderStatus.draft,
  lines: const [
    DestinationLine(
      id: 900,
      salesOrderDetail: 5,
      product: 11,
      productCode: 'P-11',
      productName: 'Widget',
      quantity: '4',
    ),
  ],
);

void main() {
  late MockDeliveryOrderRepository deliveryRepository;
  late MockCustomerRepository customerRepository;

  setUpAll(() {
    registerFallbackValue(FulfillmentType.delivery);
  });

  setUp(() {
    deliveryRepository = MockDeliveryOrderRepository();
    customerRepository = MockCustomerRepository();
    when(
      () => customerRepository.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => deliveryRepository.listForSale(
        salesOrder: any(named: 'salesOrder'),
      ),
    ).thenAnswer((_) async => [_existing()]);
  });

  Future<void> pumpStep(WidgetTester tester) async {
    await pumpPos(
      tester,
      DeliveryStep(
        // 10 ordered, 4 already claimed by the existing destination.
        sale: testSale(lines: [testLine(id: 5, quantity: '10')]),
        mode: FulfillmentMode.delivery,
        onClose: () {},
      ),
      overrides: [
        deliveryOrderRepositoryProvider.overrideWithValue(deliveryRepository),
        customerRepositoryProvider.overrideWithValue(customerRepository),
      ],
    );
  }

  group('a destination the server refuses (FR-037)', () {
    testWidgets('shows the server\'s own message inline, inside the sheet, '
        'and leaves every already-created destination untouched',
        (tester) async {
      when(
        () => deliveryRepository.create(
          salesOrder: any(named: 'salesOrder'),
          fulfillmentType: any(named: 'fulfillmentType'),
          shipTo: any(named: 'shipTo'),
          contact: any(named: 'contact'),
          date: any(named: 'date'),
          comment: any(named: 'comment'),
          lines: any(named: 'lines'),
        ),
      ).thenThrow(
        const AppError.server(
          statusCode: 409,
          message: 'La dirección no pertenece al cliente',
        ),
      );

      await pumpStep(tester);

      // The already-created destination is on screen before we try.
      expect(find.byKey(const Key('destination_card_500')), findsOneWidget);

      // Opens as a sheet (contract §6) rather than replacing the list.
      await tester.tap(find.byKey(const Key('delivery_add_destination_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('destination_editor')), findsOneWidget);
      // The already-recorded destination stays reachable behind the sheet.
      expect(find.byKey(const Key('destination_card_500')), findsOneWidget);

      await tester.tap(find.byKey(const Key('destination_address_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address_option_11')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('destination_save_button')));
      await tester.pumpAndSettle();

      // The server's own wording, in place, on the still-open sheet — no
      // quantity to send, so the create carries an explicit empty `lines`
      // (research R14).
      expect(find.byKey(const Key('destination_editor')), findsOneWidget);
      expect(find.byKey(const Key('destination_editor_error')), findsOneWidget);
      expect(find.textContaining('La dirección no pertenece'), findsOneWidget);
      verify(
        () => deliveryRepository.create(
          salesOrder: any(named: 'salesOrder'),
          fulfillmentType: any(named: 'fulfillmentType'),
          shipTo: 11,
          contact: any(named: 'contact'),
          date: any(named: 'date'),
          comment: any(named: 'comment'),
          lines: const [],
        ),
      ).called(1);

      // And nothing already recorded was disturbed.
      expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
    });
  });

  group("a remainder meant for the counter is never a dead end", () {
    testWidgets('a sale whose mode came back as plain delivery can still '
        'sweep the rest to the counter and finish', (tester) async {
      when(
        () => deliveryRepository.create(
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
          id: 600,
          fulfillmentType: FulfillmentType.counterPickup,
          status: DeliveryOrderStatus.draft,
        ),
      );
      var closed = false;

      // `FulfillmentMode.delivery` is what `resumeTargetFor` reconstructs
      // for *any* addressed sale — a genuinely mixed one included, since
      // `mixed` is UI-only state it cannot recover.
      await pumpPos(
        tester,
        DeliveryStep(
          sale: testSale(lines: [testLine(id: 5, quantity: '10')]),
          mode: FulfillmentMode.delivery,
          onClose: () => closed = true,
        ),
        overrides: [
          deliveryOrderRepositoryProvider.overrideWithValue(deliveryRepository),
          customerRepositoryProvider.overrideWithValue(customerRepository),
        ],
      );

      // 6 of 10 unassigned: the close is blocked and says so.
      expect(find.byKey(const Key('delivery_outstanding_notice')), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('delivery_close_button')))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const Key('delivery_sweep_to_counter_button')));
      await tester.pumpAndSettle();

      verify(
        () => deliveryRepository.create(
          salesOrder: any(named: 'salesOrder'),
          fulfillmentType: FulfillmentType.counterPickup,
          shipTo: any(named: 'shipTo'),
          contact: any(named: 'contact'),
          date: any(named: 'date'),
          comment: any(named: 'comment'),
          lines: null,
        ),
      ).called(1);
      expect(closed, isTrue);
    });

    testWidgets('the sweep action is absent once nothing is outstanding',
        (tester) async {
      when(
        () => deliveryRepository.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          Destination(
            id: 500,
            fulfillmentType: FulfillmentType.delivery,
            shipTo: 11,
            addressSummary: 'Av. Reforma 100',
            status: DeliveryOrderStatus.draft,
            lines: const [
              DestinationLine(
                id: 900,
                salesOrderDetail: 5,
                product: 11,
                productCode: 'P-11',
                productName: 'Widget',
                quantity: '10',
              ),
            ],
          ),
        ],
      );

      await pumpStep(tester);

      expect(find.byKey(const Key('delivery_outstanding_notice')), findsNothing);
      expect(find.byKey(const Key('delivery_sweep_to_counter_button')), findsNothing);
    });
  });

  group('a recorded counter-pickup destination stays visible', () {
    testWidgets('a resumed sale shows its counter row even though the mode '
        'came back as delivery — and offers no way to remove it',
        (tester) async {
      when(
        () => deliveryRepository.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          _existing(),
          Destination(
            id: 600,
            fulfillmentType: FulfillmentType.counterPickup,
            status: DeliveryOrderStatus.draft,
            lines: const [
              DestinationLine(
                id: 901,
                salesOrderDetail: 5,
                product: 11,
                productCode: 'P-11',
                productName: 'Widget',
                quantity: '6',
              ),
            ],
          ),
        ],
      );

      await pumpStep(tester);

      expect(find.byKey(const Key('destination_counter_row')), findsOneWidget);
      // The addressed destination keeps its delete; the counter never has one.
      expect(find.byKey(const Key('destination_remove_500')), findsOneWidget);
      expect(find.byKey(const Key('destination_remove_600')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('destination_counter_row')),
          matching: find.byIcon(Icons.delete_outline),
        ),
        findsNothing,
      );
    });
  });

  group('the close gate', () {
    testWidgets('a pure-delivery sale names what is still unassigned '
        '(FR-035)', (tester) async {
      await pumpStep(tester);

      expect(
        find.byKey(const Key('delivery_outstanding_notice')),
        findsOneWidget,
      );
      expect(find.textContaining('Widget'), findsWidgets);

      final close = tester.widget<FilledButton>(
        find.byKey(const Key('delivery_close_button')),
      );
      expect(close.onPressed, isNull);
    });
  });
}
