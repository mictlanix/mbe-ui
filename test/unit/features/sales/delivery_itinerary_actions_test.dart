import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_controller.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';

import 'delivery_itinerary_fixtures.dart';

class _MockRepository extends Mock implements DeliveryItineraryRepository {}

var _detailBuilds = 0;
var _listBuilds = 0;
var _orderListBuilds = 0;
var _pendingBuilds = 0;

class _CountingDetail extends DeliveryItineraryDetailController {
  @override
  Future<Itinerary> build(int id) async {
    _detailBuilds++;
    return fakeItinerary(id: id);
  }
}

class _CountingList extends DeliveryItinerariesListController {
  @override
  Future<CatalogPage<ItinerarySummary>> build(
    DeliveryItinerariesFilter filter,
  ) async {
    _listBuilds++;
    return const CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20);
  }
}

class _CountingOrderList extends DeliveryOrdersListController {
  @override
  Future<CatalogPage<DeliveryOrderSummary>> build(
    DeliveryOrdersFilter filter,
  ) async {
    _orderListBuilds++;
    return const CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20);
  }
}

class _CountingPending extends PendingDeliveriesController {
  @override
  Future<PendingDeliveriesView> build(
    PendingDeliveryPeriod period,
    int pageIndex,
  ) async {
    _pendingBuilds++;
    return const PendingDeliveriesView(
      periods: [],
      page: CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20),
    );
  }
}

/// Spec 075 T010, research R10: a write puts the trip it returned on the
/// screen with no extra GET; a refusal reloads; orders-moving writes refresh
/// the 061 and 063 screens.
void main() {
  late _MockRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(
      StopClosure(
        receiverName: '',
        receiverIdShown: '',
        lines: const [],
        proof: ProofImage(bytes: Uint8List(0), filename: 'x.png'),
      ),
    );
  });

  setUp(() {
    repository = _MockRepository();
    _detailBuilds = _listBuilds = 0;
    _orderListBuilds = _pendingBuilds = 0;
    container = ProviderContainer(
      overrides: [
        deliveryItineraryRepositoryProvider.overrideWithValue(repository),
        deliveryItineraryDetailControllerProvider(
          58,
        ).overrideWith(_CountingDetail.new),
        deliveryItinerariesListControllerProvider(
          const DeliveryItinerariesFilter(),
        ).overrideWith(_CountingList.new),
        deliveryOrdersListControllerProvider(
          const DeliveryOrdersFilter(),
        ).overrideWith(_CountingOrderList.new),
        pendingDeliveriesControllerProvider(
          PendingDeliveryPeriod.today,
          0,
        ).overrideWith(_CountingPending.new),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the screens' providers, as the app would have them listening.
  Future<void> mount() async {
    container.listen(deliveryItineraryDetailControllerProvider(58), (_, _) {});
    container.listen(
      deliveryItinerariesListControllerProvider(
        const DeliveryItinerariesFilter(),
      ),
      (_, _) {},
    );
    container.listen(
      deliveryOrdersListControllerProvider(const DeliveryOrdersFilter()),
      (_, _) {},
    );
    container.listen(
      pendingDeliveriesControllerProvider(PendingDeliveryPeriod.today, 0),
      (_, _) {},
    );
    await container.read(deliveryItineraryDetailControllerProvider(58).future);
    await container.read(
      deliveryItinerariesListControllerProvider(
        const DeliveryItinerariesFilter(),
      ).future,
    );
    await container.read(
      deliveryOrdersListControllerProvider(const DeliveryOrdersFilter()).future,
    );
    await container.read(
      pendingDeliveriesControllerProvider(
        PendingDeliveryPeriod.today,
        0,
      ).future,
    );
  }

  Itinerary departed() => fakeItinerary(
    status: ItineraryStatus.departed,
    departedAt: DateTime(2026, 11, 18, 7, 4),
  );

  test('a write puts the returned trip on the screen with no extra GET and '
      'refreshes the list', () async {
    await mount();
    final returned = fakeItinerary(
      stops: [fakeItineraryStop(), fakeItineraryStop(id: 502, sequence: 2)],
    );
    when(
      () => repository.addStop(58, deliveryOrderId: 1540),
    ).thenAnswer((_) async => returned);

    final error = await container
        .read(deliveryItineraryActionsProvider.notifier)
        .addStop(58, deliveryOrderId: 1540);

    expect(error, isNull);
    await container.pump();
    final shown = container
        .read(deliveryItineraryDetailControllerProvider(58))
        .value;
    expect(shown, returned);
    expect(_detailBuilds, 1, reason: 'the trip was not fetched again');
    expect(_listBuilds, 2, reason: 'the list is refreshed');
    expect(_orderListBuilds, 1, reason: 'adding a stop moves no order');
    verifyNever(() => repository.getById(any()));
  });

  test(
    'depart, cancel and closeStop also refresh the 061 and 063 screens',
    () async {
      await mount();
      when(() => repository.depart(58)).thenAnswer((_) async => departed());
      when(() => repository.cancel(58)).thenAnswer((_) async => departed());
      when(
        () => repository.closeStop(58, 501, any()),
      ).thenAnswer((_) async => departed());
      final actions = container.read(deliveryItineraryActionsProvider.notifier);
      final closure = StopClosure(
        receiverName: 'Ana',
        receiverIdShown: 'INE',
        lines: const [],
        proof: ProofImage(bytes: Uint8List(1), filename: 'a.png'),
      );

      await actions.depart(58);

      await container.pump();
      expect(_orderListBuilds, 2);
      expect(_pendingBuilds, 2);

      await actions.cancel(58);

      await container.pump();
      expect(_orderListBuilds, 3);
      expect(_pendingBuilds, 3);

      await actions.closeStop(58, 501, closure);

      await container.pump();
      expect(_orderListBuilds, 4);
      expect(_pendingBuilds, 4);
    },
  );

  test('loads, adjusts and releases refresh the order lookups but not the '
      '061 screens', () async {
    await mount();
    when(
      () => repository.commitLine(
        58,
        501,
        deliveryOrderLineId: 900,
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async => fakeItinerary());
    when(
      () => repository.releaseCommitment(58, 501, 7001),
    ).thenAnswer((_) async => fakeItinerary());
    final actions = container.read(deliveryItineraryActionsProvider.notifier);

    expect(
      await actions.commitLine(
        58,
        501,
        deliveryOrderLineId: 900,
        quantity: Decimal.parse('3'),
      ),
      isNull,
    );
    expect(await actions.release(58, 501, 7001), isNull);

    expect(_orderListBuilds, 1);
    expect(_pendingBuilds, 1);
  });

  test('a refusal answers the error and reloads the trip', () async {
    await mount();
    const refusal = AppError.server(statusCode: 409);
    when(() => repository.depart(58)).thenThrow(refusal);

    final error = await container
        .read(deliveryItineraryActionsProvider.notifier)
        .depart(58);

    expect(error, refusal);
    await container.read(deliveryItineraryDetailControllerProvider(58).future);
    expect(_detailBuilds, 2, reason: 'reloaded');
    expect(_orderListBuilds, 1, reason: 'nothing moved');
  });

  test('an unknown result is a NetworkError, and everything reloads', () async {
    await mount();
    when(() => repository.cancel(58)).thenThrow(const AppError.network());

    final error = await container
        .read(deliveryItineraryActionsProvider.notifier)
        .cancel(58);

    expect(error, isA<NetworkError>());
    await container.pump();
    await container.read(deliveryItineraryDetailControllerProvider(58).future);
    expect(_detailBuilds, 2);
    expect(_listBuilds, 2);
  });

  test('create answers the new trip id and refreshes the list', () async {
    await mount();
    when(
      () => repository.create(
        date: any(named: 'date'),
        vehicleId: 4,
        operatorId: any(named: 'operatorId'),
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => fakeItinerary(id: 59));

    final result = await container
        .read(deliveryItineraryActionsProvider.notifier)
        .create(vehicleId: 4);

    expect(result.id, 59);
    expect(result.error, isNull);
    await container.pump();
    expect(_listBuilds, 2);
  });

  test('create answers the refusal and no id', () async {
    const refusal = AppError.server(statusCode: 409);
    when(
      () => repository.create(
        date: any(named: 'date'),
        vehicleId: any(named: 'vehicleId'),
        operatorId: any(named: 'operatorId'),
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
      ),
    ).thenThrow(refusal);

    final result = await container
        .read(deliveryItineraryActionsProvider.notifier)
        .create(vehicleId: 4);

    expect(result.id, isNull);
    expect(result.error, refusal);
  });

  test('a write on a trip no screen is showing does not fetch it', () async {
    when(() => repository.depart(77)).thenAnswer((_) async => departed());

    final error = await container
        .read(deliveryItineraryActionsProvider.notifier)
        .depart(77);

    expect(error, isNull);
    expect(_detailBuilds, 0);
  });
}
