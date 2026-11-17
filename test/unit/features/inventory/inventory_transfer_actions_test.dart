import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/in_transit_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_controller.dart';

import 'inventory_transfer_fixtures.dart';

class MockInventoryTransferRepository extends Mock
    implements InventoryTransferRepository {}

const _id = 412;

var _listBuilds = 0;
var _inTransitBuilds = 0;

class _CountingList extends InventoryTransfersListController {
  @override
  Future<InventoryTransferPage> build(InventoryTransfersFilter filter) async {
    _listBuilds++;
    return const InventoryTransferPage(
      items: [],
      total: 0,
      pageIndex: 0,
      pageSize: 20,
    );
  }
}

class _CountingInTransit extends InTransitController {
  @override
  Future<InTransitView> build(int facilityId) async {
    _inTransitBuilds++;
    return anInTransitView(facilityId: facilityId);
  }
}

AppError _refusal(String codeName, api.ErrorCode code) => AppError.validation(
  [],
  codeName,
  ApiProblem(codeName: codeName, code: code),
);

/// Spec 069 contracts/repository.md "Actions notifier" (T009).
void main() {
  late MockInventoryTransferRepository repository;
  late ProviderContainer container;
  final detail = inventoryTransferDetailControllerProvider(_id);
  const filter = InventoryTransfersFilter();
  final listProvider = inventoryTransfersListControllerProvider(filter);
  final inTransitProvider = inTransitControllerProvider(2);
  final written = aTransfer(comment: 'written');

  setUpAll(() => registerFallbackValue(Decimal.zero));

  setUp(() async {
    repository = MockInventoryTransferRepository();
    _listBuilds = 0;
    _inTransitBuilds = 0;
    when(() => repository.get(_id)).thenAnswer((_) async => aTransfer());
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryTransferRepositoryProvider.overrideWithValue(repository),
        listProvider.overrideWith(_CountingList.new),
        inTransitProvider.overrideWith(_CountingInTransit.new),
      ],
    );
    addTearDown(container.dispose);
    container.listen(detail, (_, _) {});
    container.listen(listProvider, (_, _) {});
    container.listen(inTransitProvider, (_, _) {});
    await container.read(detail.future);
    await container.read(listProvider.future);
    await container.read(inTransitProvider.future);
    clearInteractions(repository);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  InventoryTransferActions actions() =>
      container.read(inventoryTransferActionsProvider.notifier);

  final cases =
      <
        String,
        ({
          Future<AppError?> Function(InventoryTransferActions a) act,
          Future<InventoryTransfer> Function() call,
          bool inTransit,
        })
      >{
        'updateHeader': (
          act: (a) => a.updateHeader(_id, comment: 'n'),
          call: () => repository.updateHeader(_id, comment: 'n'),
          inTransit: false,
        ),
        'addLine': (
          act: (a) => a.addLine(_id, productId: 7, quantity: Decimal.one),
          call: () =>
              repository.addLine(_id, productId: 7, quantity: Decimal.one),
          inTransit: false,
        ),
        'updateLine': (
          act: (a) => a.updateLine(_id, 900, quantity: Decimal.ten),
          call: () => repository.updateLine(_id, 900, quantity: Decimal.ten),
          inTransit: false,
        ),
        'removeLine': (
          act: (a) => a.removeLine(_id, 900),
          call: () => repository.removeLine(_id, 900),
          inTransit: false,
        ),
        'addSalesOrderItems': (
          act: (a) async =>
              (await a.addSalesOrderItems(_id, salesOrderId: 61)).$1,
          call: () => repository.addSalesOrderItems(_id, salesOrderId: 61),
          inTransit: false,
        ),
        'dispatch': (
          act: (a) => a.dispatch(_id),
          call: () => repository.dispatch(_id),
          inTransit: true,
        ),
        'receive (all)': (
          act: (a) => a.receive(_id),
          call: () => repository.receive(_id),
          inTransit: true,
        ),
        'receive (lines)': (
          act: (a) => a.receive(_id, lines: {900: Decimal.one}),
          call: () => repository.receive(_id, lines: {900: Decimal.one}),
          inTransit: true,
        ),
        'close': (
          act: (a) => a.close(_id),
          call: () => repository.close(_id),
          inTransit: true,
        ),
        'cancel': (
          act: (a) => a.cancel(_id),
          call: () => repository.cancel(_id),
          inTransit: true,
        ),
      };

  for (final MapEntry(key: name, value: c) in cases.entries) {
    group(name, () {
      test('on success shows the returned transfer and refreshes the '
          'list${c.inTransit ? ' and the in-transit view' : ''}', () async {
        when(c.call).thenAnswer((_) async => written);

        expect(await c.act(actions()), isNull);
        await settle();

        expect(container.read(detail).value, written);
        expect(_listBuilds, 2);
        expect(_inTransitBuilds, c.inTransit ? 2 : 1);
        verifyNever(() => repository.get(_id));
      });

      test('passes a refusal through and touches nothing', () async {
        final refusal = _refusal(
          'warehouse.in_transit_location',
          api.ErrorCode.warehousePeriodInTransitLocation,
        );
        when(c.call).thenAnswer((_) async => throw refusal);

        expect(await c.act(actions()), refusal);
        await settle();

        expect(container.read(detail).value, aTransfer());
        expect(_listBuilds, 1);
        expect(_inTransitBuilds, 1);
        verifyNever(() => repository.get(_id));
      });

      for (final (codeName, code) in [
        ('document.not_editable', api.ErrorCode.documentPeriodNotEditable),
        (
          'inventory_document.already_cancelled',
          api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
        ),
        ('lock.busy', api.ErrorCode.lockPeriodBusy),
        (
          'inventory_transfer.not_in_transit',
          api.ErrorCode.inventoryTransferPeriodNotInTransit,
        ),
        (
          'inventory_transfer.over_received',
          api.ErrorCode.inventoryTransferPeriodOverReceived,
        ),
      ]) {
        test('re-fetches the transfer after $codeName', () async {
          when(c.call).thenAnswer((_) async => throw _refusal(codeName, code));
          when(() => repository.get(_id)).thenAnswer(
            (_) async => aTransfer(status: InventoryTransferStatus.received),
          );

          expect(await c.act(actions()), isNotNull);

          verify(() => repository.get(_id)).called(1);
          expect(
            container.read(detail).value?.status,
            InventoryTransferStatus.received,
          );
        });
      }
    });
  }

  test('addSalesOrderItems answers the lines added', () async {
    when(() => repository.addSalesOrderItems(_id, salesOrderId: 61)).thenAnswer(
      (_) async => aTransfer(
        lines: [
          aTransferLine(),
          aTransferLine(id: 901),
          aTransferLine(id: 902),
        ],
      ),
    );

    final (error, added) = await actions().addSalesOrderItems(
      _id,
      salesOrderId: 61,
    );

    expect(error, isNull);
    expect(added, 2);
  });

  test('addSalesOrderItems answers zero when everything was there', () async {
    when(
      () => repository.addSalesOrderItems(_id, salesOrderId: 61),
    ).thenAnswer((_) async => aTransfer());

    final (error, added) = await actions().addSalesOrderItems(
      _id,
      salesOrderId: 61,
    );

    expect(error, isNull);
    expect(added, 0);
  });

  test('create answers the new id and refreshes the list only', () async {
    when(
      () => repository.create(warehouseId: 3, warehouseToId: 4, comment: 'n'),
    ).thenAnswer((_) async => aTransfer(id: 501));

    final result = await actions().create(
      warehouseId: 3,
      warehouseToId: 4,
      comment: 'n',
    );
    await settle();

    expect(result.error, isNull);
    expect(result.id, 501);
    expect(_listBuilds, 2);
    expect(_inTransitBuilds, 1);
    expect(
      container.exists(inventoryTransferDetailControllerProvider(501)),
      isFalse,
    );
  });

  test('create passes a refusal through, with no id', () async {
    final refusal = _refusal(
      'inventory_transfer.same_warehouse',
      api.ErrorCode.inventoryTransferPeriodSameWarehouse,
    );
    when(
      () => repository.create(warehouseId: 3, warehouseToId: 3, comment: null),
    ).thenAnswer((_) async => throw refusal);

    final result = await actions().create(warehouseId: 3, warehouseToId: 3);

    expect(result.error, refusal);
    expect(result.id, isNull);
    expect(_listBuilds, 1);
  });
}
