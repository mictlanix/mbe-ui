import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_count_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_documents_filter.dart';

import 'inventory_count_fixtures.dart';

class MockInventoryCountRepository extends Mock
    implements InventoryCountRepository {}

const _id = 412;

var _listBuilds = 0;

class _CountingList extends InventoryCountsListController {
  @override
  Future<InventoryCountPage> build(InventoryDocumentsFilter filter) async {
    _listBuilds++;
    return const InventoryCountPage(
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

/// Spec 070 contracts/repository.md (T009).
void main() {
  late MockInventoryCountRepository repository;
  late ProviderContainer container;
  final detail = inventoryCountDetailControllerProvider(_id);
  final written = aCount(comment: 'written');
  final batch = [CountLineInput.byCode(code: 'A-100', quantity: Decimal.one)];

  setUp(() async {
    repository = MockInventoryCountRepository();
    _listBuilds = 0;
    when(() => repository.get(_id)).thenAnswer((_) async => aCount());
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryCountRepositoryProvider.overrideWithValue(repository),
        inventoryCountsListControllerProvider(
          const InventoryDocumentsFilter(),
        ).overrideWith(_CountingList.new),
      ],
    );
    addTearDown(container.dispose);
    // The screens keep these alive.
    container.listen(detail, (_, _) {});
    container.listen(
      inventoryCountsListControllerProvider(const InventoryDocumentsFilter()),
      (_, _) {},
    );
    await container.read(detail.future);
    await container.read(
      inventoryCountsListControllerProvider(
        const InventoryDocumentsFilter(),
      ).future,
    );
    clearInteractions(repository);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  InventoryCountActions actions() =>
      container.read(inventoryCountActionsProvider.notifier);

  /// Each action on the count, and how to stub its repository call with an
  /// answer that returns the written count or throws.
  final cases =
      <
        String,
        ({
          Future<AppError?> Function(InventoryCountActions a) act,
          void Function(Future<InventoryCount> Function() answer) stub,
        })
      >{
        'updateHeader': (
          act: (a) => a.updateHeader(_id, comment: 'n'),
          stub: (answer) => when(
            () => repository.updateHeader(_id, comment: 'n'),
          ).thenAnswer((_) => answer()),
        ),
        'setLines': (
          act: (a) => a.setLines(_id, batch),
          stub: (answer) => when(
            () => repository.setLines(_id, batch),
          ).thenAnswer((_) => answer()),
        ),
        'updateLine': (
          act: (a) => a.updateLine(_id, 1200, quantity: Decimal.ten),
          stub: (answer) => when(
            () => repository.updateLine(_id, 1200, quantity: Decimal.ten),
          ).thenAnswer((_) => answer()),
        ),
        'removeLine': (
          act: (a) => a.removeLine(_id, 1200),
          stub: (answer) => when(
            () => repository.removeLine(_id, 1200),
          ).thenAnswer((_) => answer()),
        ),
        'confirm': (
          act: (a) async =>
              (await a.confirm(_id, includeUncounted: false)).error,
          stub: (answer) =>
              when(
                () => repository.confirm(_id, includeUncounted: false),
              ).thenAnswer(
                (_) async => CountConfirmResult(
                  count: await answer(),
                  warnings: const CountWarnings(),
                ),
              ),
        ),
        'cancel': (
          act: (a) => a.cancel(_id),
          stub: (answer) =>
              when(() => repository.cancel(_id)).thenAnswer((_) => answer()),
        ),
      };

  for (final MapEntry(key: name, value: c) in cases.entries) {
    group(name, () {
      test('on success shows the returned count and refreshes the '
          'list', () async {
        c.stub(() async => written);

        expect(await c.act(actions()), isNull);
        await settle();

        expect(container.read(detail).value, written);
        expect(_listBuilds, 2);
        verifyNever(() => repository.get(_id));
      });

      test('passes a refusal through and touches nothing', () async {
        final refusal = _refusal(
          'inventory_count.batch_invalid',
          api.ErrorCode.inventoryCountPeriodBatchInvalid,
        );
        c.stub(() async => throw refusal);

        expect(await c.act(actions()), refusal);
        await settle();

        expect(container.read(detail).value, aCount());
        expect(_listBuilds, 1);
        verifyNever(() => repository.get(_id));
      });

      for (final (codeName, code) in [
        ('document.not_editable', api.ErrorCode.documentPeriodNotEditable),
        (
          'inventory_document.already_cancelled',
          api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
        ),
        (
          'inventory_count.confirmed_cannot_cancel',
          api.ErrorCode.inventoryCountPeriodConfirmedCannotCancel,
        ),
        ('lock.busy', api.ErrorCode.lockPeriodBusy),
      ]) {
        test('re-fetches the count after $codeName', () async {
          c.stub(() async => throw _refusal(codeName, code));
          when(() => repository.get(_id)).thenAnswer(
            (_) async => aCount(status: InventoryDocumentStatus.completed),
          );

          expect(await c.act(actions()), isNotNull);

          verify(() => repository.get(_id)).called(1);
          expect(
            container.read(detail).value?.status,
            InventoryDocumentStatus.completed,
          );
        });
      }
    });
  }

  test('confirm answers the warnings of the response', () async {
    final completed = aCount(
      serial: 57,
      status: InventoryDocumentStatus.completed,
    );
    final warnings = someCountWarnings();
    when(() => repository.confirm(_id, includeUncounted: true)).thenAnswer(
      (_) async => CountConfirmResult(count: completed, warnings: warnings),
    );

    final outcome = await actions().confirm(_id, includeUncounted: true);

    expect(outcome.error, isNull);
    expect(outcome.warnings, warnings);
    expect(container.read(detail).value, completed);
  });

  test('a refused confirm answers empty warnings', () async {
    final refusal = _refusal(
      'inventory_document.no_lines',
      api.ErrorCode.inventoryDocumentPeriodNoLines,
    );
    when(
      () => repository.confirm(_id, includeUncounted: false),
    ).thenAnswer((_) async => throw refusal);

    final outcome = await actions().confirm(_id, includeUncounted: false);

    expect(outcome.error, refusal);
    expect(outcome.warnings.isEmpty, isTrue);
  });

  test('create answers the new id and refreshes the list', () async {
    when(
      () => repository.create(warehouseId: 3, comment: 'n'),
    ).thenAnswer((_) async => aCount(id: 501));

    final result = await actions().create(warehouseId: 3, comment: 'n');
    await settle();

    expect(result.error, isNull);
    expect(result.id, 501);
    expect(_listBuilds, 2);
    expect(
      container.exists(inventoryCountDetailControllerProvider(501)),
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
}
