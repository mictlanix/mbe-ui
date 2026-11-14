import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';

class MockDeliveryOrderAdminRepository extends Mock
    implements DeliveryOrderAdminRepository {}

const _id = 900;

var _detailBuilds = 0;
var _listBuilds = 0;

DeliveryOrder _order() => DeliveryOrder(
  id: _id,
  facilityId: 4,
  customerId: 77,
  priority: 0,
  status: DeliveryOrderStatus.draft,
  type: FulfillmentType.delivery,
  createdAt: DateTime(2026, 11, 1),
  modifiedAt: DateTime(2026, 11, 1),
);

class _CountingDetail extends DeliveryOrderDetailController {
  @override
  Future<DeliveryOrderDetail> build(int id) async {
    _detailBuilds++;
    return DeliveryOrderDetail(order: _order(), events: const AsyncData([]));
  }
}

class _CountingList extends DeliveryOrdersListController {
  @override
  Future<CatalogPage<DeliveryOrderSummary>> build(
    DeliveryOrdersFilter filter,
  ) async {
    _listBuilds++;
    return const CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20);
  }
}

/// Spec 061 research R6 (T011).
void main() {
  late MockDeliveryOrderAdminRepository repository;
  late ProviderContainer container;
  final bytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repository = MockDeliveryOrderAdminRepository();
    _detailBuilds = 0;
    _listBuilds = 0;
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        deliveryOrderAdminRepositoryProvider.overrideWithValue(repository),
        deliveryOrderDetailControllerProvider(
          _id,
        ).overrideWith(_CountingDetail.new),
        deliveryOrdersListControllerProvider(
          const DeliveryOrdersFilter(),
        ).overrideWith(_CountingList.new),
      ],
    );
    addTearDown(container.dispose);
    // The screens keep these alive; listening here is what makes an
    // invalidation visible as a rebuild.
    container.listen(deliveryOrderDetailControllerProvider(_id), (_, _) {});
    container.listen(
      deliveryOrdersListControllerProvider(const DeliveryOrdersFilter()),
      (_, _) {},
    );
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  DeliveryOrderActions actions() =>
      container.read(deliveryOrderActionsProvider.notifier);

  /// Each action, the repository call it must make, and how to stub that
  /// call with [answer].
  final cases =
      <
        String,
        ({
          Future<AppError?> Function(DeliveryOrderActions a) act,
          Future<DeliveryOrder> Function() call,
        })
      >{
        'confirm': (
          act: (a) => a.confirm(_id),
          call: () => repository.confirm(_id),
        ),
        'cancel': (
          act: (a) => a.cancel(_id, reason: 'no stock'),
          call: () => repository.cancel(id: _id, reason: 'no stock'),
        ),
        'requeue': (
          act: (a) => a.requeue(_id),
          call: () => repository.requeue(_id),
        ),
        'markReady': (
          act: (a) => a.markReady(_id),
          call: () => repository.markReadyForPickup(_id),
        ),
        'confirmPickup': (
          act: (a) => a.confirmPickup(
            _id,
            receiverName: 'Ana',
            receiverIdShown: 'INE',
            bytes: bytes,
            filename: 'proof.png',
          ),
          call: () => repository.confirmPickup(
            id: _id,
            receiverName: 'Ana',
            receiverIdShown: 'INE',
            bytes: bytes,
            filename: 'proof.png',
          ),
        ),
        'updateHeader': (
          act: (a) => a.updateHeader(
            _id,
            priority: 2,
            shipTo: 31,
            contact: 41,
            date: DateTime(2026, 11, 20),
            comment: 'gate B',
          ),
          call: () => repository.updateHeader(
            id: _id,
            priority: 2,
            shipTo: 31,
            contact: 41,
            date: DateTime(2026, 11, 20),
            comment: 'gate B',
          ),
        ),
        'addLine': (
          act: (a) => a.addLine(
            _id,
            salesOrderDetail: 7001,
            quantity: Decimal.parse('2.5'),
          ),
          call: () => repository.addLine(
            id: _id,
            salesOrderDetail: 7001,
            quantity: '2.5',
          ),
        ),
        'updateLine': (
          act: (a) =>
              a.updateLine(_id, lineId: 1, quantity: Decimal.parse('3')),
          call: () => repository.updateLine(id: _id, lineId: 1, quantity: '3'),
        ),
        'removeLine': (
          act: (a) => a.removeLine(_id, lineId: 1),
          call: () => repository.removeLine(id: _id, lineId: 1),
        ),
      };

  for (final MapEntry(key: name, value: c) in cases.entries) {
    group(name, () {
      test('calls the repository, answers null and reloads the order and the '
          'list', () async {
        when(c.call).thenAnswer((_) async => _order());
        await settle();

        final result = await c.act(actions());
        await settle();

        expect(result, isNull);
        verify(c.call).called(1);
        expect(_detailBuilds, 2, reason: 'order and events');
        expect(_listBuilds, 2, reason: 'list');
      });

      test(
        "passes the server's error through and reloads the order only",
        () async {
          const refusal = AppError.validation(
            [],
            'not editable',
            ApiProblem(
              codeName: 'delivery_order.not_editable',
              code: api.ErrorCode.deliveryOrderPeriodNotEditable,
            ),
          );
          when(c.call).thenAnswer((_) async => throw refusal);
          await settle();

          final result = await c.act(actions());
          await settle();

          expect(result, refusal);
          expect(
            result?.problem?.code,
            api.ErrorCode.deliveryOrderPeriodNotEditable,
          );
          expect(_detailBuilds, 2, reason: 'order reloaded (FR-023)');
          expect(_listBuilds, 1, reason: 'a refusal changed nothing');
        },
      );

      test('a lost connection answers NetworkError (unknown result) and '
          'reloads the order and the list', () async {
        when(c.call).thenAnswer((_) async => throw const AppError.network());
        await settle();

        final result = await c.act(actions());
        await settle();

        expect(result, isA<NetworkError>());
        expect(_detailBuilds, 2);
        expect(_listBuilds, 2);
      });
    });
  }
}
