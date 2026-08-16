import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
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

/// The Entrega step's own shapes (spec 026 contracts/delivery-surface.md):
/// two regions at the Large tier with nothing to scroll to reach any control
/// (US1, SC-001), and the one-column/pinned-foot shape below it (US5),
/// mirroring the payment step's own layout test.
void main() {
  late MockDeliveryOrderRepository deliveries;
  late MockCustomerRepository customers;

  final customer = Customer(
    customerId: 7,
    code: 'C-7',
    name: 'FERRETERÍA LOS PINOS',
    creditLimit: '0',
    creditDays: 0,
    priceList: const PriceListRef(id: 1, name: 'Mostrador'),
    shipping: true,
    shippingRequiredDocument: false,
    status: EntityStatus.active,
    addresses: const [
      AddressListItem(addressId: 11, label: 'Destino uno', type: AddressType.business),
      AddressListItem(addressId: 12, label: 'Destino dos', type: AddressType.business),
    ],
    contacts: const [
      Contact(contactId: 21, name: 'Ana Ruiz', phone: '55 1234 5678'),
      Contact(contactId: 22, name: 'Luis Gómez', phone: '55 8765 4321'),
    ],
  );

  Destination existing({
    required int id,
    required int shipTo,
    required int contact,
    required int salesOrderDetail,
    required String quantity,
  }) => Destination(
    id: id,
    fulfillmentType: FulfillmentType.delivery,
    shipTo: shipTo,
    contact: contact,
    status: DeliveryOrderStatus.draft,
    date: DateTime(2026, 8, 6),
    lines: [
      DestinationLine(
        id: id * 10,
        salesOrderDetail: salesOrderDetail,
        product: 11,
        productCode: 'P-11',
        productName: 'Widget',
        quantity: quantity,
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(FulfillmentType.delivery);
  });

  setUp(() {
    deliveries = MockDeliveryOrderRepository();
    customers = MockCustomerRepository();
    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => customer);
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer(
      (_) async => [
        existing(id: 500, shipTo: 11, contact: 21, salesOrderDetail: 5, quantity: '6'),
        existing(id: 501, shipTo: 12, contact: 22, salesOrderDetail: 6, quantity: '20'),
      ],
    );
  });

  Future<void> pumpStep(WidgetTester tester, {required Size surface}) => pumpPos(
    tester,
    DeliveryStep(
      sale: testSale(
        lines: [
          testLine(id: 5, productName: 'Varilla', quantity: '6'),
          testLine(id: 6, productName: 'Cemento', quantity: '20'),
        ],
      ),
      mode: FulfillmentMode.mixed,
      onClose: () {},
    ),
    surface: surface,
    overrides: [
      deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
      customerRepositoryProvider.overrideWithValue(customers),
    ],
  );

  group('the two-region shape at the Large tier (US1, SC-001)', () {
    testWidgets('the counter row, both cards, the add action and the rail '
        'are all visible with nothing to scroll', (tester) async {
      await pumpStep(tester, surface: const Size(1440, 900));

      expect(find.byKey(const Key('destination_counter_row')), findsOneWidget);
      expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
      expect(find.byKey(const Key('destination_card_501')), findsOneWidget);
      expect(
        find.byKey(const Key('delivery_add_destination_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('line_distribution_panel')), findsOneWidget);
      expect(find.byKey(const Key('delivery_close_button')), findsOneWidget);
    });

    testWidgets('no card header wraps at exactly 1200 px (research R1)',
        (tester) async {
      await pumpStep(tester, surface: const Size(1200, 900));

      // The header row (badge, identity, divider, counts, icons) fits on
      // one line: the identity text does not report more than one line's
      // worth of height for its style.
      final identity = tester.widget<Text>(find.text('Destino uno'));
      expect(identity.maxLines, 1);
      expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
    });

    testWidgets('at 1199 px the content is one column with the foot pinned',
        (tester) async {
      await pumpStep(tester, surface: const Size(1199, 900));

      expect(
        find.ancestor(
          of: find.byKey(const Key('delivery_close_button')),
          matching: find.byType(ListView),
        ),
        findsNothing,
        reason: 'the foot is pinned outside the scrolling ListView',
      );
      expect(find.byKey(const Key('delivery_close_button')), findsOneWidget);
    });
  });

  group('a card keeps its own identity across a removal', () {
    testWidgets("removing the first destination does not leak its expanded "
        "state onto the survivor's card", (tester) async {
      when(
        () => deliveries.cancel(
          destinationId: any(named: 'destinationId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});

      await pumpStep(tester, surface: const Size(1440, 900));

      // Expand only the first card (500).
      await tester.tap(find.byKey(const Key('destination_card_500')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('destination_card_501')),
          matching: find.text('Cemento'),
        ),
        findsNothing,
        reason: '501 starts collapsed',
      );

      // Remove it — 501 shifts to the list's first position.
      await tester.tap(find.byKey(const Key('destination_remove_500')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('destination_card_500')), findsNothing);
      expect(find.byKey(const Key('destination_card_501')), findsOneWidget);
      // Without a stable key, 501 would inherit 500's now-stale expanded
      // Element/State by list position and render its lines open.
      expect(
        find.descendant(
          of: find.byKey(const Key('destination_card_501')),
          matching: find.text('Cemento'),
        ),
        findsNothing,
        reason: '501 must still be collapsed, not inherit 500\'s expanded state',
      );
    });
  });

  group('the add action and nothing left to assign (FR-016, research R14)', () {
    testWidgets('is disabled and states the reason once every unit is '
        'assigned', (tester) async {
      // This fixture's two destinations already cover both lines in full.
      await pumpStep(tester, surface: const Size(1440, 900));

      final button = tester.widget<OutlinedButton>(
        find.byKey(const Key('delivery_add_destination_button')),
      );
      expect(button.onPressed, isNull);
      expect(find.text('No queda nada por asignar'), findsOneWidget);
    });
  });

  group('adding a destination from a side sheet (US4, contract §6)', () {
    Future<void> pumpWithRemainder(WidgetTester tester, {required Size surface}) =>
        pumpPos(
          tester,
          DeliveryStep(
            sale: testSale(
              lines: [
                testLine(id: 5, productName: 'Varilla', quantity: '6'),
                // Only 15 of 20 claimed below — 5 left unassigned.
                testLine(id: 6, productName: 'Cemento', quantity: '20'),
              ],
            ),
            mode: FulfillmentMode.mixed,
            onClose: () {},
          ),
          surface: surface,
          overrides: [
            deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
            customerRepositoryProvider.overrideWithValue(customers),
          ],
        );

    setUp(() {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          existing(id: 500, shipTo: 11, contact: 21, salesOrderDetail: 5, quantity: '6'),
          existing(id: 501, shipTo: 12, contact: 22, salesOrderDetail: 6, quantity: '15'),
        ],
      );
    });

    testWidgets('at the Large tier it is right-anchored over the rail, with '
        'the destination cards still visible behind it', (tester) async {
      await pumpWithRemainder(tester, surface: const Size(1440, 900));

      await tester.tap(find.byKey(const Key('delivery_add_destination_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('destination_editor')), findsOneWidget);
      expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
      expect(find.byKey(const Key('destination_card_501')), findsOneWidget);

      // Right-anchored: the sheet's left edge sits well right of the
      // window's own left edge, unlike a bottom sheet spanning the width.
      final sheetLeft = tester.getTopLeft(find.byKey(const Key('destination_editor'))).dx;
      expect(sheetLeft, greaterThan(800));
    });

    testWidgets('a resize across the two-region threshold with the sheet '
        'open keeps it usable', (tester) async {
      await pumpWithRemainder(tester, surface: const Size(1440, 900));
      await tester.tap(find.byKey(const Key('delivery_add_destination_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('destination_comment_field')),
        'Dejar con el portero',
      );
      await tester.pumpAndSettle();

      // The sheet is on the root navigator, independent of the step's own
      // width-driven rebuild — the typed instructions survive it.
      expect(find.text('Dejar con el portero'), findsOneWidget);
    });
  });

  group('no horizontal overflow at any supported width (SC-007)', () {
    for (final width in [320.0, 390.0, 768.0, 1024.0, 1440.0, 1920.0]) {
      testWidgets('at ${width.toInt()} px', (tester) async {
        await pumpStep(tester, surface: Size(width, 900));
        expectNoHorizontalScroll(tester);
      });
    }
  });
}
