import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/approval_queue_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_controller.dart';

import 'purchase_request_fixtures.dart';

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

const _id = 212;

var _listBuilds = 0;
var _queueBuilds = 0;
var _toPurchaseBuilds = 0;

/// The writes that change which lines are pending, so Por comprar reloads.
const _changesPending = {'cancel', 'markLine', 'approve', 'reject'};

class _CountingToPurchase extends ToPurchaseController {
  @override
  Future<List<ToPurchaseGroup>> build(int? facilityId) async {
    _toPurchaseBuilds++;
    return const [];
  }
}

class _CountingList extends PurchaseRequestsListController {
  @override
  Future<PurchaseRequestPage> build(PurchaseRequestsFilter filter) async {
    _listBuilds++;
    return const PurchaseRequestPage(
      items: [],
      total: 0,
      pageIndex: 0,
      pageSize: 20,
    );
  }
}

class _CountingQueue extends ApprovalQueueController {
  @override
  Future<PurchaseRequestPage> build(ApprovalQueueFilter filter) async {
    _queueBuilds++;
    return const PurchaseRequestPage(
      items: [],
      total: 0,
      pageIndex: 0,
      pageSize: 20,
    );
  }
}

AppError _refusal(String codeName, api.ErrorCode code) => AppError.validation(
  [],
  codeName,
  ApiProblem(codeName: codeName, code: code),
);

/// Spec 079 contracts/repository.md, research R11 and R13 (T010).
void main() {
  late MockPurchaseRequestRepository repository;
  late ProviderContainer container;
  final detail = purchaseRequestDetailControllerProvider(_id);
  const listFilter = PurchaseRequestsFilter();
  const queueFilter = ApprovalQueueFilter();
  final written = aRequest(comment: 'written');

  setUpAll(() => registerFallbackValue(Decimal.zero));

  setUp(() async {
    repository = MockPurchaseRequestRepository();
    _listBuilds = 0;
    _queueBuilds = 0;
    _toPurchaseBuilds = 0;
    when(() => repository.get(_id)).thenAnswer((_) async => aRequest());
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseRequestRepositoryProvider.overrideWithValue(repository),
        purchaseRequestsListControllerProvider(
          listFilter,
        ).overrideWith(_CountingList.new),
        approvalQueueControllerProvider(
          queueFilter,
        ).overrideWith(_CountingQueue.new),
        toPurchaseControllerProvider(
          null,
        ).overrideWith(_CountingToPurchase.new),
      ],
    );
    addTearDown(container.dispose);
    // The screens keep these alive.
    container.listen(detail, (_, _) {});
    container.listen(
      purchaseRequestsListControllerProvider(listFilter),
      (_, _) {},
    );
    container.listen(approvalQueueControllerProvider(queueFilter), (_, _) {});
    container.listen(toPurchaseControllerProvider(null), (_, _) {});
    await container.read(toPurchaseControllerProvider(null).future);
    await container.read(detail.future);
    await container.read(approvalQueueControllerProvider(queueFilter).future);
    await container.read(
      purchaseRequestsListControllerProvider(listFilter).future,
    );
    clearInteractions(repository);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  PurchaseRequestActions actions() =>
      container.read(purchaseRequestActionsProvider.notifier);

  /// Each action on the request, the repository call it makes, and its error.
  final cases =
      <
        String,
        ({
          Future<AppError?> Function(PurchaseRequestActions a) act,
          Future<PurchaseRequest> Function() call,
        })
      >{
        'updateHeader': (
          act: (a) => a.updateHeader(_id, comment: 'n'),
          call: () => repository.updateHeader(_id, comment: 'n'),
        ),
        'addLine': (
          act: (a) => a.addLine(_id, productId: 7),
          call: () => repository.addLine(_id, productId: 7),
        ),
        'updateLine': (
          act: (a) => a.updateLine(_id, 900, quantity: Decimal.ten),
          call: () => repository.updateLine(_id, 900, quantity: Decimal.ten),
        ),
        'removeLine': (
          act: (a) => a.removeLine(_id, 900),
          call: () => repository.removeLine(_id, 900),
        ),
        'submit': (
          act: (a) => a.submit(_id),
          call: () => repository.submit(_id),
        ),
        'cancel': (
          act: (a) => a.cancel(_id),
          call: () => repository.cancel(_id),
        ),
        'markLine': (
          act: (a) => a.markLine(_id, 900, toPurchase: true),
          call: () => repository.markLine(_id, 900, toPurchase: true),
        ),
        'approve': (
          act: (a) => a.approve(_id),
          call: () => repository.approve(_id),
        ),
        'reject': (
          act: (a) => a.reject(_id, reason: 'No'),
          call: () => repository.reject(_id, reason: 'No'),
        ),
      };

  for (final MapEntry(key: name, value: c) in cases.entries) {
    group(name, () {
      test('on success shows the returned request and refreshes the '
          'list and the approval queue', () async {
        when(c.call).thenAnswer((_) async => written);

        expect(await c.act(actions()), isNull);
        await settle();

        expect(container.read(detail).value, written);
        expect(_listBuilds, 2);
        expect(_queueBuilds, 2);
        expect(_toPurchaseBuilds, _changesPending.contains(name) ? 2 : 1);
        verifyNever(() => repository.get(_id));
      });

      test('passes a refusal through and touches nothing', () async {
        final refusal = _refusal(
          'purchase_request.no_lines',
          api.ErrorCode.purchaseRequestPeriodNoLines,
        );
        when(c.call).thenAnswer((_) async => throw refusal);

        expect(await c.act(actions()), refusal);
        await settle();

        expect(container.read(detail).value, aRequest());
        expect(_listBuilds, 1);
        expect(_queueBuilds, 1);
        expect(_toPurchaseBuilds, 1);
        verifyNever(() => repository.get(_id));
      });

      for (final (codeName, code) in [
        (
          'purchase_request.not_draft',
          api.ErrorCode.purchaseRequestPeriodNotDraft,
        ),
        (
          'purchase_request.not_submitted',
          api.ErrorCode.purchaseRequestPeriodNotSubmitted,
        ),
        (
          'purchase_request.already_cancelled',
          api.ErrorCode.purchaseRequestPeriodAlreadyCancelled,
        ),
        (
          'purchase_request.lines_not_markable',
          api.ErrorCode.purchaseRequestPeriodLinesNotMarkable,
        ),
        (
          'purchase_request.warehouse_facility_changed',
          api.ErrorCode.purchaseRequestPeriodWarehouseFacilityChanged,
        ),
        ('lock.busy', api.ErrorCode.lockPeriodBusy),
      ]) {
        test('re-fetches the request and reloads the approval queue after '
            '$codeName', () async {
          when(c.call).thenAnswer((_) async => throw _refusal(codeName, code));
          when(() => repository.get(_id)).thenAnswer(
            (_) async => aRequest(status: PurchaseRequestStatus.cancelled),
          );

          expect(await c.act(actions()), isNotNull);
          await settle();

          verify(() => repository.get(_id)).called(1);
          expect(_queueBuilds, 2);
          expect(
            container.read(detail).value?.status,
            PurchaseRequestStatus.cancelled,
          );
        });
      }
    });
  }

  test('create answers the new id and refreshes the list', () async {
    when(
      () => repository.create(warehouseId: 3, comment: 'n'),
    ).thenAnswer((_) async => aRequest(id: 401));

    final result = await actions().create(warehouseId: 3, comment: 'n');
    await settle();

    expect(result.error, isNull);
    expect(result.id, 401);
    expect(_listBuilds, 2);
    expect(
      container.exists(purchaseRequestDetailControllerProvider(401)),
      isFalse,
    );
  });

  test('create passes a refusal through, with no id', () async {
    final refusal = _refusal(
      'warehouse.in_transit_location',
      api.ErrorCode.warehousePeriodInTransitLocation,
    );
    when(
      () => repository.create(warehouseId: 3, comment: null),
    ).thenAnswer((_) async => throw refusal);

    final result = await actions().create(warehouseId: 3);

    expect(result.error, refusal);
    expect(result.id, isNull);
    expect(_listBuilds, 1);
  });

  group('approveMany', () {
    test('answers mixed outcomes, refreshes the list and the approval queue '
        'and writes no detail', () async {
      final outcomes = [
        const BulkApproveOutcome(requestId: _id, approved: true),
        BulkApproveOutcome(
          requestId: 213,
          approved: false,
          problem: ApiProblem(
            codeName: 'purchase_request.not_submitted',
            code: api.ErrorCode.purchaseRequestPeriodNotSubmitted,
          ),
        ),
      ];
      when(
        () => repository.approveMany([_id, 213]),
      ).thenAnswer((_) async => outcomes);

      final result = await actions().approveMany([_id, 213]);
      await settle();

      expect(result.error, isNull);
      expect(result.outcomes, outcomes);
      expect(_listBuilds, 2);
      expect(_queueBuilds, 2);
      expect(_toPurchaseBuilds, 2);
      expect(container.read(detail).value, aRequest());
      verifyNever(() => repository.get(_id));
    });

    test('a whole-call failure answers the error and refreshes '
        'nothing', () async {
      when(
        () => repository.approveMany([_id]),
      ).thenAnswer((_) async => throw const AppError.network());

      final result = await actions().approveMany([_id]);
      await settle();

      expect(result.error, isA<NetworkError>());
      expect(result.outcomes, isNull);
      expect(_listBuilds, 1);
      expect(_queueBuilds, 1);
      expect(_toPurchaseBuilds, 1);
    });
  });
}
