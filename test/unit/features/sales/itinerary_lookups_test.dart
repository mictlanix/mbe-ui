import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_operator_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart';

class _MockOrders extends Mock implements DeliveryOrderAdminRepository {}

class _MockOperators extends Mock implements VehicleOperatorRepository {}

DeliveryOrder _order(int id) => DeliveryOrder(
  id: id,
  facilityId: 4,
  customerId: 7,
  priority: 0,
  status: DeliveryOrderStatus.inPreparation,
  type: FulfillmentType.delivery,
  createdAt: DateTime(2026, 11, 1),
  modifiedAt: DateTime(2026, 11, 1),
  lines: [
    DeliveryOrderLine(
      id: 900,
      productId: 5,
      productCode: 'CLA-25',
      productName: 'Clavo',
      warehouseId: 3,
      quantity: Decimal.parse('25'),
      committed: Decimal.zero,
      delivered: Decimal.zero,
      returned: Decimal.zero,
      open: Decimal.parse('25'),
    ),
  ],
);

VehicleOperator _operator(DateTime expires) => VehicleOperator(
  vehicleOperatorId: 9,
  driverId: 2,
  driverName: 'Juan Rivas',
  licenseType: 'E',
  driverLicenseNumber: 'X1',
  issueDate: DateTime(2020, 1, 1),
  expirationDate: expires,
  issuingLocation: 'Puebla',
  status: EntityStatus.active,
  hasLicensePhoto: false,
);

/// Spec 075 T008: the two reads the itinerary screens still make.
void main() {
  late _MockOrders orders;
  late _MockOperators operators;
  late ProviderContainer container;

  setUp(() {
    orders = _MockOrders();
    operators = _MockOperators();
    container = ProviderContainer(
      overrides: [
        deliveryOrderAdminRepositoryProvider.overrideWithValue(orders),
        vehicleOperatorRepositoryProvider.overrideWithValue(operators),
      ],
    );
    addTearDown(container.dispose);
  });

  test('the order is read once per id, however many stops ask', () async {
    when(() => orders.getById(1532)).thenAnswer((_) async => _order(1532));
    when(() => orders.getById(1540)).thenAnswer((_) async => _order(1540));

    final a = await container.read(itineraryOrderProvider(1532).future);
    final b = await container.read(itineraryOrderProvider(1532).future);
    final c = await container.read(itineraryOrderProvider(1540).future);

    expect(a?.id, 1532);
    expect(identical(a, b), isTrue);
    expect(c?.id, 1540);
    verify(() => orders.getById(1532)).called(1);
    verify(() => orders.getById(1540)).called(1);
  });

  test('invalidating an order reads it again', () async {
    when(() => orders.getById(1532)).thenAnswer((_) async => _order(1532));

    await container.read(itineraryOrderProvider(1532).future);
    container.invalidate(itineraryOrderProvider(1532));
    await container.read(itineraryOrderProvider(1532).future);

    verify(() => orders.getById(1532)).called(2);
  });

  test('a failed or forbidden order read is null, not an error', () async {
    when(() => orders.getById(any())).thenThrow(const AppError.auth());

    expect(await container.read(itineraryOrderProvider(1).future), isNull);
  });

  test('the operator is read for the licence expiry', () async {
    when(
      () => operators.get(vehicleOperatorId: 9),
    ).thenAnswer((_) async => _operator(DateTime(2026, 11, 2)));

    final operator = await container.read(vehicleOperatorProvider(9).future);

    expect(operator?.expirationDate, DateTime(2026, 11, 2));
    expect(operator?.driverName, 'Juan Rivas');
  });

  test('a failed operator read is null: no licence warning', () async {
    when(
      () => operators.get(vehicleOperatorId: any(named: 'vehicleOperatorId')),
    ).thenThrow(const AppError.server());

    expect(await container.read(vehicleOperatorProvider(9).future), isNull);
  });
}
