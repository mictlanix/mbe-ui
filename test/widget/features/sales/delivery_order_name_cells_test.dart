import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';

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

/// Spec 063 R7, C8: the ship-to address and the warehouse-by-id cells, for
/// rows that carry no facility.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget cell,
    List<Override> overrides,
  ) => tester.pumpWidget(
    ProviderScope(
      overrides: [
        saleCustomerControllerProvider.overrideWith(
          (ref, id) async => _customer(id),
        ),
        ...overrides,
      ],
      child: MaterialApp(home: Scaffold(body: cell)),
    ),
  );

  group('DeliveryOrderCustomerAddress', () {
    testWidgets("shows the customer's address label", (tester) async {
      await pump(
        tester,
        const DeliveryOrderCustomerAddress(customerId: 7, shipToId: 11),
        const [],
      );
      await tester.pumpAndSettle();

      expect(find.text('Av. Juárez 120, Centro'), findsOneWidget);
    });

    testWidgets('an address the customer does not hold falls back to #id', (
      tester,
    ) async {
      await pump(
        tester,
        const DeliveryOrderCustomerAddress(customerId: 7, shipToId: 99),
        const [],
      );
      await tester.pumpAndSettle();

      expect(find.text('#99'), findsOneWidget);
    });

    testWidgets('no ship-to shows the placeholder', (tester) async {
      await pump(
        tester,
        const DeliveryOrderCustomerAddress(customerId: 7, shipToId: null),
        const [],
      );
      await tester.pumpAndSettle();

      expect(find.text('—'), findsOneWidget);
    });
  });

  group('WarehouseNameById', () {
    testWidgets('shows the warehouse name', (tester) async {
      await pump(tester, const WarehouseNameById(warehouseId: 3), [
        warehouseDisplayNameProvider.overrideWith((ref, id) async => 'Centro'),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Centro'), findsOneWidget);
    });

    testWidgets('falls back to #id when the name cannot be read', (
      tester,
    ) async {
      await pump(tester, const WarehouseNameById(warehouseId: 3), [
        warehouseDisplayNameProvider.overrideWith((ref, id) async => null),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('#3'), findsOneWidget);
    });
  });

  group('server names (mbe-api#324–#326)', () {
    // Every name lookup fails the test: a server name must not trigger one.
    // The customer itself stays served by `pump`; its address differs from
    // the label given below, so the label on screen came from the row.
    final noLookups = [
      customerDisplayNameProvider.overrideWith(
        (ref, id) async => fail('customer name $id looked up'),
      ),
      facilityDisplayNameProvider.overrideWith(
        (ref, id) async => fail('facility $id looked up'),
      ),
      warehouseDisplayNameProvider.overrideWith(
        (ref, id) async => fail('warehouse $id looked up'),
      ),
    ];

    testWidgets('each cell shows the name it is given, with no lookup', (
      tester,
    ) async {
      await pump(
        tester,
        const Column(
          children: [
            DeliveryOrderCustomerName(customerId: 7, name: 'Ferretería Acme'),
            DeliveryOrderShipTo(
              type: FulfillmentType.delivery,
              customerId: 7,
              facilityId: 9,
              shipToId: 11,
              shipToLabel: 'Av. Reforma 5, Centro',
            ),
            DeliveryOrderShipTo(
              type: FulfillmentType.counterPickup,
              customerId: 7,
              facilityId: 9,
              shipToId: null,
              facilityName: 'Matriz',
            ),
            WarehouseNameById(warehouseId: 3, name: 'Bodega Norte'),
          ],
        ),
        noLookups,
      );
      await tester.pumpAndSettle();

      expect(find.text('Ferretería Acme'), findsOneWidget);
      expect(find.text('Av. Reforma 5, Centro'), findsOneWidget);
      expect(find.text('Matriz'), findsOneWidget);
      expect(find.text('Bodega Norte'), findsOneWidget);
    });

    testWidgets('a null name falls back to the lookup', (tester) async {
      await pump(
        tester,
        const DeliveryOrderCustomerAddress(
          customerId: 7,
          shipToId: 11,
          label: null,
        ),
        const [],
      );
      await tester.pumpAndSettle();

      expect(find.text('Av. Juárez 120, Centro'), findsOneWidget);
    });
  });
}
