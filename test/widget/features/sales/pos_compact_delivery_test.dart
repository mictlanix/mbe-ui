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
import 'package:mbe_ui/features/sales/presentation/delivery/destination_editor.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 11,
      label: 'Av. Paseo de la Reforma 100, Cuauhtémoc, Ciudad de México',
      type: AddressType.business,
    ),
  ],
  contacts: [
    Contact(contactId: 21, name: 'Ana López', phone: '55 1234 5678'),
  ],
);

/// Carries only what mbe-api actually returns — the `ship_to`/`contact`
/// **ids**. The address and contact labels are joined from the customer by
/// `DeliveryController`, so asserting on them proves that join happens.
Destination _existing() => Destination(
  id: 500,
  fulfillmentType: FulfillmentType.delivery,
  shipTo: 11,
  contact: 21,
  status: DeliveryOrderStatus.draft,
  date: DateTime(2026, 8, 12),
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

/// The delivery journey (US2) at 390 px: destination cards, the editor with
/// its address and contact pickers, and the distribution panel are all
/// reachable by scrolling down, and nothing pushes the page sideways
/// (SC-007).
void main() {
  late MockDeliveryOrderRepository deliveries;
  late MockCustomerRepository customers;
  late AppLocalizations l10n;

  setUpAll(() async {
    registerFallbackValue(FulfillmentType.delivery);
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    deliveries = MockDeliveryOrderRepository();
    customers = MockCustomerRepository();
    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => [_existing()]);
  });

  Future<void> pumpStep(
    WidgetTester tester, {
    FulfillmentMode mode = FulfillmentMode.delivery,
  }) async {
    await pumpPos(
      tester,
      DeliveryStep(
        // 10 ordered, 4 already claimed by the existing destination.
        sale: testSale(lines: [testLine(id: 5, quantity: '10')]),
        mode: mode,
        onClose: () {},
      ),
      surface: phoneSurface,
      overrides: [
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
    );
  }

  group('the Entrega step on a phone (SC-007)', () {
    testWidgets('the destinations recorded so far render as stacked cards', (
      tester,
    ) async {
      await pumpStep(tester);

      expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
      // A long address and a contact line on one card at 390 px is exactly
      // where a fixed-width layout would overflow.
      expect(find.textContaining('Ana López'), findsWidgets);
      expectNoHorizontalScroll(tester);
    });

    testWidgets('a destination names where it goes and who receives it, '
        'joined from the customer — mbe-api returns only ids', (tester) async {
      await pumpStep(tester);

      expect(
        find.textContaining('Av. Paseo de la Reforma 100'),
        findsWidgets,
        reason: 'ship_to 11 resolves to the customer\'s own address label',
      );
      expect(
        find.textContaining('55 1234 5678'),
        findsWidgets,
        reason: 'contact 21 resolves to that contact\'s name and phone',
      );
      expect(
        find.text(l10n.posDeliveryAddressPending),
        findsNothing,
        reason: 'the "address pending" fallback is for a destination with no '
            'ship_to at all, not for every destination ever created',
      );
    });

    testWidgets('the distribution panel and the add-destination action are '
        'reached by scrolling down, not sideways', (tester) async {
      await pumpStep(tester);

      await tester.dragUntilVisible(
        find.byKey(const Key('delivery_add_destination_button')),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('delivery_add_destination_button')),
        findsOneWidget,
      );
      expectNoHorizontalScroll(tester);
    });

    testWidgets('an incomplete distribution still names what is unassigned, '
        'and the finish action is reachable (FR-035)', (tester) async {
      await pumpStep(tester);

      await tester.dragUntilVisible(
        find.byKey(const Key('delivery_close_button')),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('delivery_outstanding_notice')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FloatingActionButton>(
              find.byKey(const Key('delivery_close_button')),
            )
            .onPressed,
        isNull,
        reason: '6 of 10 units are still unassigned',
      );
      expectNoHorizontalScroll(tester);
    });

    testWidgets('the add sheet — address picker, contact picker, date and '
        'instructions, no quantity — opens as a full-width bottom sheet and '
        'fits (FR-026, FR-027)', (tester) async {
      await pumpStep(tester);

      await tester.dragUntilVisible(
        find.byKey(const Key('delivery_add_destination_button')),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delivery_add_destination_button')));
      await tester.pumpAndSettle();

      expect(find.byType(DestinationEditor), findsOneWidget);
      expect(find.byKey(const Key('destination_address_button')), findsOneWidget);
      expect(find.byKey(const Key('destination_contact_button')), findsOneWidget);
      expect(find.byKey(const Key('destination_date_button')), findsOneWidget);
      expect(find.byKey(const Key('destination_comment_field')), findsOneWidget);
      // No quantity field at all — FR-027's header-only sheet.
      expect(find.byKey(const Key('destination_quantity_5')), findsNothing);
      expectNoHorizontalScroll(tester);
    });

    testWidgets("a card's stepper is reachable and works at phone width "
        '(US5 independent test)', (tester) async {
      // The existing destination already carries sale line 5 (quantity 4),
      // so raising it dispatches to `updateLine`, not `addLine`.
      when(
        () => deliveries.updateLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => Destination(
          id: 500,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: 11,
          contact: 21,
          status: DeliveryOrderStatus.draft,
          date: DateTime(2026, 8, 12),
          lines: const [
            DestinationLine(
              id: 900,
              salesOrderDetail: 5,
              product: 11,
              productCode: 'P-11',
              productName: 'Widget',
              quantity: '5',
            ),
          ],
        ),
      );

      await pumpStep(tester);
      await tester.tap(find.byKey(const Key('destination_card_500')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      verify(
        () => deliveries.updateLine(destinationId: 500, lineId: 900, quantity: '5'),
      ).called(1);
      expectNoHorizontalScroll(tester);
    });

    testWidgets('a mixed sale can be finished with a remainder left over — '
        'the sweep, not an error (FR-036)', (tester) async {
      await pumpStep(tester, mode: FulfillmentMode.mixed);

      await tester.dragUntilVisible(
        find.byKey(const Key('delivery_close_button')),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FloatingActionButton>(
              find.byKey(const Key('delivery_close_button')),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        find.byKey(const Key('delivery_outstanding_notice')),
        findsNothing,
      );
      expectNoHorizontalScroll(tester);
    });
  });
}
