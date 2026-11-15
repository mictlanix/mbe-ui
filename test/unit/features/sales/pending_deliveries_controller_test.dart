import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_controller.dart';

class _MockRepository extends Mock implements DeliveryItineraryRepository {}

PendingDeliveryLine _line(int id) => PendingDeliveryLine(
  deliveryOrderId: 30,
  lineId: id,
  serial: 1500,
  customerId: 7,
  priority: 1,
  productId: 5,
  productCode: 'P',
  productName: 'Producto',
  warehouseId: 3,
  openQuantity: '1',
);

PendingDeliveryBucket _bucket(int total, List<int> ids, {DateTime? date}) =>
    (date: date, total: total, items: [for (final id in ids) _line(id)]);

PendingDeliveriesResult _response({
  PendingDeliveryBucket? today,
  PendingDeliveryBucket? tomorrow,
}) => {
  PendingDeliveryPeriod.earlier: _bucket(4, [91]),
  PendingDeliveryPeriod.yesterday: _bucket(2, [
    92,
  ], date: DateTime(2026, 11, 14)),
  PendingDeliveryPeriod.today:
      today ?? _bucket(12, [1, 2], date: DateTime(2026, 11, 15)),
  PendingDeliveryPeriod.tomorrow:
      tomorrow ?? _bucket(7, [93], date: DateTime(2026, 11, 16)),
  PendingDeliveryPeriod.dayAfter: _bucket(3, [
    94,
  ], date: DateTime(2026, 11, 17)),
  PendingDeliveryPeriod.later: _bucket(9, [95]),
};

/// Spec 063 R4: only the selected period's lines become the page; the other
/// five contribute their date and total. No facility is ever sent.
void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        deliveryItineraryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  void serve(PendingDeliveriesResult result) => when(
    () => repository.pendingDeliveries(
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => result);

  test(
    'the selected period becomes the page, the others only summaries',
    () async {
      serve(_response());

      final view = await container().read(
        pendingDeliveriesControllerProvider(
          PendingDeliveryPeriod.today,
          0,
        ).future,
      );

      verify(() => repository.pendingDeliveries(skip: 0, limit: 20)).called(1);
      expect(view.page.items.map((l) => l.lineId), [1, 2]);
      expect(view.page.total, 12);
      expect(view.page.pageIndex, 0);
      expect(view.periods.map((s) => s.period), PendingDeliveryPeriod.values);
      expect(view.periods.map((s) => s.total), [4, 2, 12, 7, 3, 9]);
      expect(view.periods[1].date, DateTime(2026, 11, 14));
      expect(view.periods[0].date, isNull);
    },
  );

  test('another period shows that period\'s lines', () async {
    serve(_response());

    final view = await container().read(
      pendingDeliveriesControllerProvider(
        PendingDeliveryPeriod.tomorrow,
        0,
      ).future,
    );

    expect(view.page.items.map((l) => l.lineId), [93]);
    expect(view.page.total, 7);
  });

  test('a later page sends its offset', () async {
    serve(_response(today: _bucket(45, [21])));

    final view = await container().read(
      pendingDeliveriesControllerProvider(
        PendingDeliveryPeriod.today,
        1,
      ).future,
    );

    verify(() => repository.pendingDeliveries(skip: 20, limit: 20)).called(1);
    expect(view.page.pageIndex, 1);
  });

  test('a page left empty steps back to the last page with rows, judged on '
      'the selected period alone', () async {
    // Index 2 is past the end of Hoy (40 lines, 2 pages) even though other
    // periods still have lines at that offset.
    when(() => repository.pendingDeliveries(skip: 40, limit: 20)).thenAnswer(
      (_) async =>
          _response(today: _bucket(40, []), tomorrow: _bucket(60, [8])),
    );
    when(
      () => repository.pendingDeliveries(skip: 20, limit: 20),
    ).thenAnswer((_) async => _response(today: _bucket(40, [30])));

    final view = await container().read(
      pendingDeliveriesControllerProvider(
        PendingDeliveryPeriod.today,
        2,
      ).future,
    );

    expect(view.page.pageIndex, 1);
    expect(view.page.items.single.lineId, 30);
  });

  test('an empty first page is empty, not clamped', () async {
    serve(_response(today: _bucket(0, [])));

    final view = await container().read(
      pendingDeliveriesControllerProvider(
        PendingDeliveryPeriod.today,
        0,
      ).future,
    );

    expect(view.page.items, isEmpty);
    verify(() => repository.pendingDeliveries(skip: 0, limit: 20)).called(1);
  });

  test('a successful load writes its summaries for the filter panel, and a '
      'failed one leaves them in place', () async {
    serve(_response());
    final c = container();
    expect(c.read(lastPendingDeliverySummariesProvider), isNull);

    await c.read(
      pendingDeliveriesControllerProvider(
        PendingDeliveryPeriod.today,
        0,
      ).future,
    );
    await Future<void>.delayed(Duration.zero);

    final kept = c.read(lastPendingDeliverySummariesProvider)!;
    expect(kept.map((s) => s.total), [4, 2, 12, 7, 3, 9]);

    when(
      () => repository.pendingDeliveries(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(Exception('down'));
    await expectLater(
      c.read(
        pendingDeliveriesControllerProvider(
          PendingDeliveryPeriod.later,
          0,
        ).future,
      ),
      throwsException,
    );

    expect(c.read(lastPendingDeliverySummariesProvider), same(kept));
  });
}
