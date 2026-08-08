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
  shipping: true,
  shippingRequiredDocument: false,
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

Destination _existing() => Destination(
  id: 500,
  fulfillmentType: FulfillmentType.delivery,
  shipTo: 11,
  addressSummary: 'Av. Paseo de la Reforma 100, Cuauhtémoc, Ciudad de México',
  contactName: 'Ana López',
  contactPhone: '55 1234 5678',
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
            .widget<FilledButton>(find.byKey(const Key('delivery_close_button')))
            .onPressed,
        isNull,
        reason: '6 of 10 units are still unassigned',
      );
      expectNoHorizontalScroll(tester);
    });

    testWidgets('the editor — address picker, contact picker, date and the '
        'per-line quantities — opens and fits', (tester) async {
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
      expect(find.text(l10n.posDestinationQuantitiesTitle), findsWidgets);
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
            .widget<FilledButton>(find.byKey(const Key('delivery_close_button')))
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
