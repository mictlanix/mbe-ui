import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_controller.dart';

import 'inventory_receipt_fixtures.dart';

class MockInventoryReceiptRepository extends Mock
    implements InventoryReceiptRepository {}

const _id = 318;

var _listBuilds = 0;

class _CountingList extends InventoryReceiptsListController {
  @override
  Future<InventoryReceiptPage> build(InventoryReceiptsFilter filter) async {
    _listBuilds++;
    return const InventoryReceiptPage(
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

/// Spec 067 contracts/repository.md "Actions notifier", research R6 and R7
/// (T011).
void main() {
  late MockInventoryReceiptRepository repository;
  late ProviderContainer container;
  final detail = inventoryReceiptDetailControllerProvider(_id);
  final written = aReceipt(comment: 'written');

  setUpAll(() => registerFallbackValue(Decimal.zero));

  setUp(() async {
    repository = MockInventoryReceiptRepository();
    _listBuilds = 0;
    when(() => repository.get(_id)).thenAnswer((_) async => aReceipt());
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryReceiptRepositoryProvider.overrideWithValue(repository),
        inventoryReceiptsListControllerProvider(
          const InventoryReceiptsFilter(),
        ).overrideWith(_CountingList.new),
      ],
    );
    addTearDown(container.dispose);
    // The screens keep these alive.
    container.listen(detail, (_, _) {});
    container.listen(
      inventoryReceiptsListControllerProvider(const InventoryReceiptsFilter()),
      (_, _) {},
    );
    await container.read(detail.future);
    await container.read(
      inventoryReceiptsListControllerProvider(
        const InventoryReceiptsFilter(),
      ).future,
    );
    clearInteractions(repository);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  InventoryReceiptActions actions() =>
      container.read(inventoryReceiptActionsProvider.notifier);

  /// Each action on the receipt, the repository call it makes, and its error.
  final cases =
      <
        String,
        ({
          Future<AppError?> Function(InventoryReceiptActions a) act,
          Future<InventoryReceipt> Function() call,
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
          act: (a) => a.updateLine(_id, 900, quantity: Decimal.ten),
          call: () => repository.updateLine(_id, 900, quantity: Decimal.ten),
        ),
        'removeLine': (
          act: (a) => a.removeLine(_id, 900),
          call: () => repository.removeLine(_id, 900),
        ),
        'confirm': (
          act: (a) async => (await a.confirm(_id)).error,
          call: () => repository.confirm(_id),
        ),
        'cancel': (
          act: (a) async => (await a.cancel(_id)).error,
          call: () => repository.cancel(_id),
        ),
        'complementary': (
          act: (a) async => (await a.complementary(_id)).error,
          call: () => repository.complementary(_id),
        ),
      };

  for (final MapEntry(key: name, value: c) in cases.entries) {
    group(name, () {
      test('on success shows the returned receipt and refreshes the '
          'list', () async {
        when(c.call).thenAnswer((_) async => written);

        expect(await c.act(actions()), isNull);
        await settle();

        expect(container.read(detail).value, written);
        expect(_listBuilds, 2);
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

        expect(container.read(detail).value, aReceipt());
        expect(_listBuilds, 1);
        verifyNever(() => repository.get(_id));
      });

      for (final (codeName, code) in [
        ('document.not_editable', api.ErrorCode.documentPeriodNotEditable),
        (
          'inventory_document.already_cancelled',
          api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
        ),
        ('lock.busy', api.ErrorCode.lockPeriodBusy),
      ]) {
        test('re-fetches the receipt after $codeName', () async {
          when(c.call).thenAnswer((_) async => throw _refusal(codeName, code));
          when(
            () => repository.get(_id),
          ).thenAnswer((_) async => aReceipt(status: ReceiptStatus.completed));

          expect(await c.act(actions()), isNotNull);

          verify(() => repository.get(_id)).called(1);
          expect(container.read(detail).value?.status, ReceiptStatus.completed);
        });
      }
    });
  }

  test('create answers the new id and refreshes the list', () async {
    when(
      () => repository.create(warehouseId: 3, comment: 'n'),
    ).thenAnswer((_) async => aReceipt(id: 401));

    final result = await actions().create(warehouseId: 3, comment: 'n');
    await settle();

    expect(result.error, isNull);
    expect(result.id, 401);
    expect(_listBuilds, 2);
    expect(
      container.exists(inventoryReceiptDetailControllerProvider(401)),
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

  test('complementary answers the id of the receipt it returned', () async {
    when(
      () => repository.complementary(_id),
    ).thenAnswer((_) async => aReceipt(id: 402, purchaseOrderId: 55));

    final result = await actions().complementary(_id);

    expect(result.error, isNull);
    expect(result.id, 402);
    expect(container.read(detail).value, aReceipt());
  });

  group('hasUnmappedWarnings', () {
    // One linked line received beyond its order: one computed over-receipt.
    final overLines = [
      aReceiptLine(purchaseOrderLineId: 1, quantity: '12', ordered: '10'),
    ];

    test('is true when the server sent more warnings than computed', () async {
      when(() => repository.confirm(_id)).thenAnswer(
        (_) async => aReceipt(lines: overLines, serverWarningCount: 2),
      );
      when(
        () => repository.cancel(_id),
      ).thenAnswer((_) async => aReceipt(serverWarningCount: 1));

      expect((await actions().confirm(_id)).hasUnmappedWarnings, isTrue);
      expect((await actions().cancel(_id)).hasUnmappedWarnings, isTrue);
    });

    test('is false when every warning is a computed over-receipt', () async {
      when(() => repository.confirm(_id)).thenAnswer(
        (_) async => aReceipt(lines: overLines, serverWarningCount: 1),
      );
      when(() => repository.cancel(_id)).thenAnswer((_) async => aReceipt());

      expect((await actions().confirm(_id)).hasUnmappedWarnings, isFalse);
      expect((await actions().cancel(_id)).hasUnmappedWarnings, isFalse);
    });

    test('is false on a refusal', () async {
      when(
        () => repository.confirm(_id),
      ).thenAnswer((_) async => throw const AppError.network());

      final result = await actions().confirm(_id);

      expect(result.error, isA<NetworkError>());
      expect(result.hasUnmappedWarnings, isFalse);
    });
  });
}
