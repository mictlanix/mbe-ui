import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_step.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

/// The stepper's own contract (spec 026 contracts/delivery-surface.md
/// §4.3–§4.4): dispatch to `addLine` the first time a line is raised above
/// zero, `updateLine` after, `removeLine` at zero — never a second
/// `addLine`, and never a request the client's own ceiling would refuse
/// first (research R7, R13; FR-021, FR-022, SC-006).
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
    status: EntityStatus.active,
    addresses: const [
      AddressListItem(addressId: 11, label: 'Destino uno', type: AddressType.business),
    ],
  );

  Destination existingDestination({List<DestinationLine> lines = const []}) => Destination(
    id: 500,
    fulfillmentType: FulfillmentType.delivery,
    shipTo: 11,
    status: DeliveryOrderStatus.draft,
    lines: lines,
  );

  Destination updatedWith(List<DestinationLine> lines) => Destination(
    id: 500,
    fulfillmentType: FulfillmentType.delivery,
    shipTo: 11,
    status: DeliveryOrderStatus.draft,
    lines: lines,
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
  });

  Future<void> pumpStep(WidgetTester tester) async {
    final sale = testSale(lines: [testLine(id: 5, quantity: '10')]);
    final salesOrders = MockSalesOrderRepository();
    // spec 036 R1: `addDestination`/`sweepRemainderToCounter` confirm the
    // sale first when it's still `draft` — a no-op answer is enough since
    // these tests don't assert on confirm's own effect.
    when(() => salesOrders.confirm(saleId: sale.id)).thenAnswer((_) async => sale);
    final container = await pumpPos(
      tester,
      DeliveryStep(sale: sale, mode: FulfillmentMode.delivery, onClose: () {}),
      overrides: [
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
        customerRepositoryProvider.overrideWithValue(customers),
        salesOrderOverride(salesOrders),
        fixedPosSale(sale),
      ],
    );
    // `posSaleControllerProvider` is `autoDispose`, and nothing in
    // `DeliveryStep`'s own tree watches it — without a live subscription it
    // would be torn down right after the read below, so the *next* read
    // (from a later button tap) would rebuild it from scratch and find
    // `AsyncLoading` again. This keeps `fixedPosSale`'s seeded instance alive
    // for the rest of the test.
    container.listen(posSaleControllerProvider, (_, _) {});
    await container.read(posSaleControllerProvider.future);
  }

  Future<void> expand(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('destination_card_500')));
    await tester.pumpAndSettle();
  }

  group('dispatch (research R13)', () {
    testWidgets('raising a line this destination does not carry yet calls '
        'addLine, not updateLine', (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => [existingDestination()]);
      when(
        () => deliveries.addLine(
          destinationId: any(named: 'destinationId'),
          salesOrderDetail: any(named: 'salesOrderDetail'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => updatedWith([
          const DestinationLine(
            id: 900,
            salesOrderDetail: 5,
            product: 11,
            productCode: 'P-11',
            productName: 'Widget',
            quantity: '1',
          ),
        ]),
      );

      await pumpStep(tester);
      await expand(tester);
      await tester.tap(find.byKey(const Key('destination_claim_all_5')).hitTestable().first);
      await tester.pumpAndSettle();

      verify(
        () => deliveries.addLine(
          destinationId: 500,
          salesOrderDetail: 5,
          quantity: '10',
        ),
      ).called(1);
      verifyNever(
        () => deliveries.updateLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
        ),
      );
    });

    testWidgets('raising a line this destination already carries calls '
        'updateLine, not a second addLine', (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          existingDestination(
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
          ),
        ],
      );
      when(
        () => deliveries.updateLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => updatedWith([
          const DestinationLine(
            id: 900,
            salesOrderDetail: 5,
            product: 11,
            productCode: 'P-11',
            productName: 'Widget',
            quantity: '5',
          ),
        ]),
      );

      await pumpStep(tester);
      await expand(tester);
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      verify(
        () => deliveries.updateLine(destinationId: 500, lineId: 900, quantity: '5'),
      ).called(1);
      verifyNever(
        () => deliveries.addLine(
          destinationId: any(named: 'destinationId'),
          salesOrderDetail: any(named: 'salesOrderDetail'),
          quantity: any(named: 'quantity'),
        ),
      );
    });

    testWidgets('taking a line to zero calls removeLine, not updateLine '
        "with '0'", (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          existingDestination(
            lines: const [
              DestinationLine(
                id: 900,
                salesOrderDetail: 5,
                product: 11,
                productCode: 'P-11',
                productName: 'Widget',
                quantity: '1',
              ),
            ],
          ),
        ],
      );
      when(
        () => deliveries.removeLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
        ),
      ).thenAnswer((_) async => updatedWith(const []));

      await pumpStep(tester);
      await expand(tester);
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();

      verify(() => deliveries.removeLine(destinationId: 500, lineId: 900)).called(1);
      verifyNever(
        () => deliveries.updateLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
        ),
      );
    });
  });

  group("the stepper's own figure follows the value it just sent", () {
    testWidgets('tapping + updates the field, not only the header and the '
        'rail', (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          existingDestination(
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
          ),
        ],
      );
      when(
        () => deliveries.updateLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => updatedWith([
          const DestinationLine(
            id: 900,
            salesOrderDetail: 5,
            product: 11,
            productCode: 'P-11',
            productName: 'Widget',
            quantity: '5',
          ),
        ]),
      );

      await pumpStep(tester);
      await expand(tester);

      expect(
        tester.widget<TextField>(find.byKey(const Key('destination_quantity_5'))).controller!.text,
        '4',
      );

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      // The controller is seeded once and never re-read on rebuild, so
      // without an explicit write it would still show the pre-tap value
      // while the header and the rail moved to 5.
      expect(
        tester.widget<TextField>(find.byKey(const Key('destination_quantity_5'))).controller!.text,
        '5',
        reason: "the stepper's figure must follow the value it just sent",
      );
    });
  });

  group('a burst of taps is coalesced into one write', () {
    testWidgets('three rapid + taps send a single request for the final '
        'value, and the field tracks every tap', (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          existingDestination(
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
          ),
        ],
      );
      when(
        () => deliveries.updateLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => updatedWith([
          const DestinationLine(
            id: 900,
            salesOrderDetail: 5,
            product: 11,
            productCode: 'P-11',
            productName: 'Widget',
            quantity: '7',
          ),
        ]),
      );

      await pumpStep(tester);
      await expand(tester);

      final plus = find.byIcon(Icons.add).first;
      await tester.tap(plus);
      await tester.pump();
      await tester.tap(plus);
      await tester.pump();
      await tester.tap(plus);
      await tester.pump();

      // Every tap is already on screen, before any request goes out.
      expect(
        tester.widget<TextField>(find.byKey(const Key('destination_quantity_5'))).controller!.text,
        '7',
        reason: 'the field must not wait for the network',
      );
      verifyNever(
        () => deliveries.updateLine(
          destinationId: any(named: 'destinationId'),
          lineId: any(named: 'lineId'),
          quantity: any(named: 'quantity'),
        ),
      );

      // Let the debounce window elapse.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      verify(
        () => deliveries.updateLine(destinationId: 500, lineId: 900, quantity: '7'),
      ).called(1);
    });
  });

  group('the shared quantity stepper (spec 030)', () {
    testWidgets('destination_quantity_<id> still resolves to a real TextField '
        'backed by a TextEditingController after the swap onto the widget '
        'shared with the capture surface', (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => [existingDestination()]);

      await pumpStep(tester);
      await expand(tester);

      final field = tester.widget<TextField>(
        find.byKey(const Key('destination_quantity_5')),
      );
      expect(field.controller, isA<TextEditingController>());
      expect(field.controller!.text, '0');
    });
  });

  group('the client-side clamp sends nothing out of range (FR-021, SC-006)', () {
    testWidgets('typing more than the sale still owes sends no request',
        (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => [existingDestination()]);

      await pumpStep(tester);
      await expand(tester);
      await tester.enterText(find.byKey(const Key('destination_quantity_5')), '20');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Spec 030 FR-013: the discard now animates rather than snapping back
      // silently — still showing the typed value right after Enter, before
      // the fade has covered it.
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('destination_quantity_5')))
            .controller!
            .text,
        '20',
      );

      await tester.pumpAndSettle();

      verifyNever(
        () => deliveries.addLine(
          destinationId: any(named: 'destinationId'),
          salesOrderDetail: any(named: 'salesOrderDetail'),
          quantity: any(named: 'quantity'),
        ),
      );
      // Reverted to the last confirmed value.
      expect(find.text('0'), findsWidgets);
    });

    testWidgets("the '+' stepper is disabled once the ceiling is reached",
        (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer(
        (_) async => [
          existingDestination(
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
      await expand(tester);

      final addButton = tester.widget<IconButton>(
        find
            .ancestor(of: find.byIcon(Icons.add).first, matching: find.byType(IconButton))
            .first,
      );
      expect(addButton.onPressed, isNull);
    });
  });

  group('a refused assignment (FR-024)', () {
    testWidgets('reverts the displayed quantity and reports the message on '
        'that line', (tester) async {
      when(
        () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
      ).thenAnswer((_) async => [existingDestination()]);
      when(
        () => deliveries.addLine(
          destinationId: any(named: 'destinationId'),
          salesOrderDetail: any(named: 'salesOrderDetail'),
          quantity: any(named: 'quantity'),
        ),
      ).thenThrow(const AppError.server(statusCode: 409, message: 'Ya existe'));

      await pumpStep(tester);
      await expand(tester);
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Ya existe'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });
  });

  group('the first destination absorbs the full order automatically (US7, '
      'FR-023…FR-025)', () {
    Future<void> pumpEmptyStep(WidgetTester tester) async {
      final sale = testSale(
        lines: [
          testLine(id: 5, quantity: '10', productName: 'Tuerca'),
          testLine(id: 6, quantity: '4', productName: 'Tornillo'),
        ],
      );
      final salesOrders = MockSalesOrderRepository();
      when(() => salesOrders.confirm(saleId: sale.id)).thenAnswer((_) async => sale);
      final container = await pumpPos(
        tester,
        DeliveryStep(sale: sale, mode: FulfillmentMode.delivery, onClose: () {}),
        overrides: [
          deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
          customerRepositoryProvider.overrideWithValue(customers),
          salesOrderOverride(salesOrders),
          fixedPosSale(sale),
        ],
      );
      // `posSaleControllerProvider` is `autoDispose` and nothing in
      // `DeliveryStep`'s own tree watches it — a live subscription keeps
      // `fixedPosSale`'s seeded instance alive for the rest of the test.
      container.listen(posSaleControllerProvider, (_, _) {});
      await container.read(posSaleControllerProvider.future);
    }

    Destination created({required List<DestinationLine> lines}) => Destination(
      id: 500,
      fulfillmentType: FulfillmentType.delivery,
      shipTo: 11,
      status: DeliveryOrderStatus.draft,
      lines: lines,
    );

    Future<void> addFirstDestination(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('delivery_add_destination_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('destination_address_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address_option_11')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('destination_save_button')));
      await tester.pumpAndSettle();
    }

    setUp(() {
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
        (_) async => created(
          lines: const [
            DestinationLine(
              id: 900,
              salesOrderDetail: 5,
              product: 11,
              productCode: 'P-11',
              productName: 'Tuerca',
              quantity: '10',
            ),
            DestinationLine(
              id: 901,
              salesOrderDetail: 6,
              product: 11,
              productCode: 'P-11',
              productName: 'Tornillo',
              quantity: '4',
            ),
          ],
        ),
      );
    });

    testWidgets(
      'every line lands on its full ordered quantity with zero manual '
      'entry, and each stepper is still adjustable',
      (tester) async {
        when(
          () => deliveries.updateLine(
            destinationId: any(named: 'destinationId'),
            lineId: any(named: 'lineId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer(
          (_) async => created(
            lines: const [
              DestinationLine(
                id: 900,
                salesOrderDetail: 5,
                product: 11,
                productCode: 'P-11',
                productName: 'Tuerca',
                quantity: '9',
              ),
              DestinationLine(
                id: 901,
                salesOrderDetail: 6,
                product: 11,
                productCode: 'P-11',
                productName: 'Tornillo',
                quantity: '4',
              ),
            ],
          ),
        );

        await pumpEmptyStep(tester);
        await addFirstDestination(tester);

        // Auto-expanded (it was just created) — no manual entry needed to
        // see every line already at its full ordered quantity.
        expect(find.byKey(const Key('destination_card_500')), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byKey(const Key('destination_quantity_5'))).controller!.text,
          '10',
        );
        expect(
          tester.widget<TextField>(find.byKey(const Key('destination_quantity_6'))).controller!.text,
          '4',
        );
        final l10n = await AppLocalizations.delegate.load(const Locale('es'));
        expect(find.text(l10n.posDeliveryAssignedUnits('14', '14')), findsOneWidget);

        // Still adjustable exactly like a manually-entered quantity (FR-024):
        // stepping line 5 down one unit goes through the same adjustLine
        // dispatch a manually-assigned line uses.
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('destination_line_500_5')),
            matching: find.byIcon(Icons.remove),
          ),
        );
        await tester.pumpAndSettle();

        verify(
          () => deliveries.updateLine(destinationId: 500, lineId: 900, quantity: '9'),
        ).called(1);
        expect(
          tester.widget<TextField>(find.byKey(const Key('destination_quantity_5'))).controller!.text,
          '9',
        );
      },
    );

    testWidgets(
      'deleting the auto-assigned destination returns every line to '
      'unassigned',
      (tester) async {
        when(
          () => deliveries.cancel(
            destinationId: any(named: 'destinationId'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async {});

        await pumpEmptyStep(tester);
        await addFirstDestination(tester);
        expect(find.byKey(const Key('destination_card_500')), findsOneWidget);

        await tester.tap(find.byKey(const Key('destination_remove_500')));
        await tester.pumpAndSettle();

        verify(
          () => deliveries.cancel(destinationId: 500, reason: any(named: 'reason')),
        ).called(1);
        expect(find.byKey(const Key('destination_card_500')), findsNothing);

        final l10n = await AppLocalizations.delegate.load(const Locale('es'));
        expect(find.text(l10n.posDeliveryAssignedUnits('0', '14')), findsOneWidget);
        expect(find.byKey(const Key('delivery_outstanding_notice')), findsOneWidget);
      },
    );
  });
}
