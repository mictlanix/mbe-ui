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
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';

class MockDeliveryOrderAdminRepository extends Mock
    implements DeliveryOrderAdminRepository {}

const _id = 900;

var _detailBuilds = 0;
var _listBuilds = 0;
var _queueBuilds = 0;

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

class _CountingQueue extends DeliveryOrderApprovalQueueController {
  @override
  Future<CatalogPage<DeliveryOrderSummary>> build(int pageIndex) async {
    _queueBuilds++;
    return const CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20);
  }
}

/// Spec 061 research R6 (T011), and spec 062 R6: every write also refreshes
/// the approval queue, and approve and reject answer the new status.
void main() {
  late MockDeliveryOrderAdminRepository repository;
  late ProviderContainer container;
  final bytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repository = MockDeliveryOrderAdminRepository();
    _detailBuilds = 0;
    _listBuilds = 0;
    _queueBuilds = 0;
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
        deliveryOrderApprovalQueueControllerProvider(
          0,
        ).overrideWith(_CountingQueue.new),
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
    container.listen(
      deliveryOrderApprovalQueueControllerProvider(0),
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
        expect(_queueBuilds, 2, reason: 'approval queue (spec 062 R6)');
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
          expect(_queueBuilds, 1, reason: 'a refusal changed nothing');
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
        expect(_queueBuilds, 2);
      });
    });
  }

  group('approve and reject (spec 062 C5)', () {
    DeliveryOrder inStatus(DeliveryOrderStatus status) =>
        _order().copyWith(status: status);

    test('approve answers the status the server moved the order to, with no '
        'error, and refreshes the order, list and queue', () async {
      when(
        () => repository.approve(_id),
      ).thenAnswer((_) async => inStatus(DeliveryOrderStatus.inPreparation));
      await settle();

      final outcome = await actions().approve(_id);
      await settle();

      expect(outcome.error, isNull);
      expect(outcome.status, DeliveryOrderStatus.inPreparation);
      verify(() => repository.approve(_id)).called(1);
      expect(_detailBuilds, 2);
      expect(_listBuilds, 2);
      expect(_queueBuilds, 2);
    });

    test(
      'reject sends the reason as given and answers the draft status',
      () async {
        when(
          () => repository.reject(id: _id, reason: 'Dirección equivocada'),
        ).thenAnswer((_) async => inStatus(DeliveryOrderStatus.draft));
        await settle();

        final outcome = await actions().reject(
          _id,
          reason: 'Dirección equivocada',
        );
        await settle();

        expect(outcome.error, isNull);
        expect(outcome.status, DeliveryOrderStatus.draft);
        verify(
          () => repository.reject(id: _id, reason: 'Dirección equivocada'),
        ).called(1);
        expect(_queueBuilds, 2);
      },
    );

    test('a refusal answers the error and no status, and leaves the list and '
        'queue alone', () async {
      const refusal = AppError.validation(
        [],
        'not pending',
        ApiProblem(
          codeName: 'delivery_order.not_pending_approval',
          code: api.ErrorCode.deliveryOrderPeriodNotPendingApproval,
        ),
      );
      when(
        () => repository.approve(_id),
      ).thenAnswer((_) async => throw refusal);
      await settle();

      final outcome = await actions().approve(_id);
      await settle();

      expect(outcome.error, refusal);
      expect(outcome.status, isNull);
      expect(_detailBuilds, 2, reason: 'order reloaded (FR-015)');
      expect(_listBuilds, 1);
      expect(_queueBuilds, 1);
    });

    test('a lost connection answers NetworkError and still refreshes the '
        'queue, since the write may have landed', () async {
      when(
        () => repository.reject(id: _id, reason: 'x'),
      ).thenAnswer((_) async => throw const AppError.network());
      await settle();

      final outcome = await actions().reject(_id, reason: 'x');
      await settle();

      expect(outcome.error, isA<NetworkError>());
      expect(outcome.status, isNull);
      expect(_queueBuilds, 2);
    });
  });
}
