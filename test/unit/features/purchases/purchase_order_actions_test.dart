import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_list_controller.dart';

import 'purchase_order_fixtures.dart';

class MockPurchaseOrderRepository extends Mock
    implements PurchaseOrderRepository {}

const _id = 310;

AppError _refusal(String codeName, api.ErrorCode code) => AppError.validation(
  [],
  codeName,
  ApiProblem(codeName: codeName, code: code),
);

/// Spec 080 contracts/repository.md, research R11 and R17 (T008).
void main() {
  late MockPurchaseOrderRepository repository;
  late ProviderContainer container;
  final detail = purchaseOrderDetailControllerProvider(_id);
  final written = anOrder(supplierName: 'written');

  setUpAll(() => registerFallbackValue(Decimal.zero));

  setUp(() async {
    repository = MockPurchaseOrderRepository();
    when(() => repository.get(_id)).thenAnswer((_) async => anOrder());
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseOrderRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    // The detail screen keeps it alive.
    container.listen(detail, (_, _) {});
    await container.read(detail.future);
    clearInteractions(repository);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  PurchaseOrderActions actions() =>
      container.read(purchaseOrderActionsProvider.notifier);

  /// Each action on the order, the repository call it makes.
  final cases =
      <
        String,
        ({
          Future<AppError?> Function(PurchaseOrderActions a) act,
          Future<PurchaseOrder> Function() call,
        })
      >{
        'updateHeader': (
          act: (a) => a.updateHeader(_id, comment: 'n'),
          call: () => repository.updateHeader(_id, comment: 'n'),
        ),
        'addLine': (
          act: (a) => a.addLine(_id, productId: 7, quantity: Decimal.one),
          call: () =>
              repository.addLine(_id, productId: 7, quantity: Decimal.one),
        ),
        'updateLine': (
          act: (a) => a.updateLine(_id, 900, price: Decimal.ten),
          call: () => repository.updateLine(_id, 900, price: Decimal.ten),
        ),
        'removeLine': (
          act: (a) => a.removeLine(_id, 900),
          call: () => repository.removeLine(_id, 900),
        ),
        'addRequestLines': (
          act: (a) async =>
              (await a.addRequestLines(_id, requestId: 212)).error,
          call: () => repository.addRequestLines(_id, requestId: 212),
        ),
        'confirm': (
          act: (a) => a.confirm(_id),
          call: () => repository.confirm(_id),
        ),
        'cancel': (
          act: (a) => a.cancel(_id),
          call: () => repository.cancel(_id),
        ),
      };

  /// Keeps the orders list alive, as its screen does, and answers how many
  /// times it has fetched since.
  Future<int Function()> watchList() async {
    var fetches = 0;
    when(
      () => repository.list(
        all: any(named: 'all'),
        status: any(named: 'status'),
        supplierId: any(named: 'supplierId'),
        creatorId: any(named: 'creatorId'),
        orderId: any(named: 'orderId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      fetches++;
      return const CatalogPage<PurchaseOrderSummary>(
        items: [],
        total: 0,
        pageIndex: 0,
        pageSize: 20,
      );
    });
    final list = purchaseOrdersListControllerProvider(
      const PurchaseOrdersFilter(),
    );
    container.listen(list, (_, _) {});
    await container.read(list.future);
    fetches = 0;
    return () => fetches;
  }

  for (final MapEntry(key: name, value: c) in cases.entries) {
    group(name, () {
      test('on success reloads the orders list', () async {
        final fetches = await watchList();
        when(c.call).thenAnswer((_) async => written);

        expect(await c.act(actions()), isNull);
        await container.read(
          purchaseOrdersListControllerProvider(
            const PurchaseOrdersFilter(),
          ).future,
        );

        expect(fetches(), 1);
      });

      test('a refusal leaves the orders list alone', () async {
        final fetches = await watchList();
        when(c.call).thenAnswer(
          (_) async => throw _refusal(
            'purchase_order.no_supplier',
            api.ErrorCode.purchaseOrderPeriodNoSupplier,
          ),
        );

        expect(await c.act(actions()), isNotNull);
        await settle();

        expect(fetches(), 0);
      });

      test('on success shows the returned order', () async {
        when(c.call).thenAnswer((_) async => written);

        expect(await c.act(actions()), isNull);
        await settle();

        expect(container.read(detail).value, written);
        verifyNever(() => repository.get(_id));
      });

      test('passes a refusal through and touches nothing', () async {
        final refusal = _refusal(
          'purchase_order.no_supplier',
          api.ErrorCode.purchaseOrderPeriodNoSupplier,
        );
        when(c.call).thenAnswer((_) async => throw refusal);

        expect(await c.act(actions()), refusal);
        await settle();

        expect(container.read(detail).value, anOrder());
        verifyNever(() => repository.get(_id));
      });

      for (final (codeName, code) in [
        (
          'purchase_order.already_cancelled',
          api.ErrorCode.purchaseOrderPeriodAlreadyCancelled,
        ),
        (
          'purchase_order.confirmed_cannot_cancel',
          api.ErrorCode.purchaseOrderPeriodConfirmedCannotCancel,
        ),
        (
          'purchase_order.not_confirmed',
          api.ErrorCode.purchaseOrderPeriodNotConfirmed,
        ),
        ('document.not_editable', api.ErrorCode.documentPeriodNotEditable),
        ('lock.busy', api.ErrorCode.lockPeriodBusy),
      ]) {
        test('re-fetches the order after $codeName', () async {
          when(c.call).thenAnswer((_) async => throw _refusal(codeName, code));
          when(() => repository.get(_id)).thenAnswer(
            (_) async => anOrder(status: InventoryDocumentStatus.completed),
          );

          expect(await c.act(actions()), isNotNull);
          await settle();

          verify(() => repository.get(_id)).called(1);
          expect(
            container.read(detail).value?.status,
            InventoryDocumentStatus.completed,
          );
        });
      }
    });
  }

  test('a stale refusal on an order not on screen fetches nothing', () async {
    when(() => repository.cancel(999)).thenAnswer(
      (_) async => throw _refusal('lock.busy', api.ErrorCode.lockPeriodBusy),
    );

    expect(await actions().cancel(999), isNotNull);

    verifyNever(() => repository.get(any()));
    expect(
      container.exists(purchaseOrderDetailControllerProvider(999)),
      isFalse,
    );
  });

  test('confirm keeps the response receipts on the detail', () async {
    when(() => repository.confirm(_id)).thenAnswer(
      (_) async => anOrder(
        status: InventoryDocumentStatus.completed,
        receipts: [aReceipt(id: 71), aReceipt(id: 72)],
      ),
    );

    expect(await actions().confirm(_id), isNull);

    expect(container.read(detail).value?.receipts.map((r) => r.id), [71, 72]);
  });

  test('create and createFromGroup reload the orders list', () async {
    final fetches = await watchList();
    when(
      () => repository.create(supplierId: 12),
    ).thenAnswer((_) async => anOrder(id: 401));
    when(
      () => repository.createFromGroup(supplierId: 12, facilityId: 2),
    ).thenAnswer((_) async => anOrder(id: 402));
    final list = purchaseOrdersListControllerProvider(
      const PurchaseOrdersFilter(),
    );

    await actions().create(supplierId: 12);
    await container.read(list.future);
    expect(fetches(), 1);

    await actions().createFromGroup(supplierId: 12, facilityId: 2);
    await container.read(list.future);
    expect(fetches(), 2);
  });

  test('create answers the new id, no skipped lines', () async {
    when(
      () => repository.create(supplierId: 12, comment: 'n'),
    ).thenAnswer((_) async => anOrder(id: 401));

    final result = await actions().create(supplierId: 12, comment: 'n');

    expect(result.error, isNull);
    expect(result.id, 401);
    expect(result.lines, 1);
    expect(result.skipped, 0);
    expect(
      container.exists(purchaseOrderDetailControllerProvider(401)),
      isFalse,
    );
  });

  test('create passes a refusal through, with no id', () async {
    final refusal = _refusal(
      'purchase_order.no_supplier',
      api.ErrorCode.purchaseOrderPeriodNoSupplier,
    );
    when(
      () => repository.create(supplierId: 12),
    ).thenAnswer((_) async => throw refusal);

    final result = await actions().create(supplierId: 12);

    expect(result.error, refusal);
    expect(result.id, isNull);
  });

  test('createFromGroup answers the new id and the skipped count', () async {
    when(
      () => repository.createFromGroup(supplierId: 12, facilityId: 2),
    ).thenAnswer(
      (_) async => anOrder(
        id: 402,
        skippedCount: 2,
        lines: [anOrderLine(), anOrderLine(id: 901), anOrderLine(id: 902)],
      ),
    );

    final result = await actions().createFromGroup(
      supplierId: 12,
      facilityId: 2,
    );

    expect(result.error, isNull);
    expect(result.id, 402);
    // Counted on the server's answer, not on the group shown.
    expect(result.lines, 3);
    expect(result.skipped, 2);
  });

  test('createFromGroup passes a refusal through', () async {
    final refusal = _refusal(
      'purchase_order.nothing_pending',
      api.ErrorCode.purchaseOrderPeriodNothingPending,
    );
    when(
      () => repository.createFromGroup(supplierId: 12, facilityId: 2),
    ).thenAnswer((_) async => throw refusal);

    final result = await actions().createFromGroup(
      supplierId: 12,
      facilityId: 2,
    );

    expect(result.error, refusal);
    expect(result.id, isNull);
    expect(result.lines, 0);
    expect(result.skipped, 0);
  });

  test('addRequestLines answers the lines added and skipped', () async {
    when(() => repository.addRequestLines(_id, requestId: 212)).thenAnswer(
      (_) async => anOrder(
        skippedCount: 1,
        lines: [
          anOrderLine(),
          anOrderLine(id: 901, requestId: 212),
          anOrderLine(id: 902, requestId: 212),
        ],
      ),
    );

    final result = await actions().addRequestLines(_id, requestId: 212);

    expect(result.error, isNull);
    expect(result.added, 2);
    expect(result.skipped, 1);
  });
}
