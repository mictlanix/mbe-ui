import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/count_paste.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_count_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_paste_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';

import 'inventory_count_fixtures.dart';

const _id = 412;

/// A count repository that applies each `setLines` batch to an in-memory
/// draft, or refuses the batch [refuseBatch] (1-based) with [refusal].
class _FakeRepository implements InventoryCountRepository {
  final batches = <List<CountLineInput>>[];
  final applied = <String, Decimal>{};
  int gets = 0;
  int? refuseBatch;
  AppError? refusal;

  /// When set, every `setLines` waits for it.
  Completer<void>? gate;

  @override
  Future<InventoryCount> get(int id) async {
    gets++;
    return aCount(lines: const []);
  }

  @override
  Future<InventoryCountLinesChange> setLines(
    int id,
    List<CountLineInput> items,
  ) async {
    batches.add(items);
    await gate?.future;
    if (batches.length == refuseBatch) throw refusal!;
    for (final item in items) {
      final line = item as CountLineByCode;
      applied[line.code] = line.quantity;
    }
    // Lines are left out: the sender only reads the answer's refusal.
    return aLinesChange(lineCount: 0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// [n] clean rows coded P1…Pn. Row numbers skip every other line (blank
/// rows count), so a row number is never the same as an index.
List<CountPasteRow> _rows(int n) => [
  for (var i = 1; i <= n; i++)
    CountPasteRow(row: i * 2, code: 'P$i', quantity: '$i.5'),
];

AppError _batchInvalid(List<int> indexes) => AppError.validation(
  const [],
  'batch',
  ApiProblem(
    codeName: 'inventory_count.batch_invalid',
    code: api.ErrorCode.inventoryCountPeriodBatchInvalid,
    parts: [
      for (final index in indexes)
        ApiProblemPart(
          codeName: 'inventory_count_line.product_unknown',
          code: api.ErrorCode.inventoryCountLinePeriodProductUnknown,
          extra: {'index': index, 'product_code': 'x', 'reason': 'x'},
        ),
    ],
  ),
);

/// Spec 070 research R8 (T021, T024).
void main() {
  late _FakeRepository repository;
  late ProviderContainer container;
  final sender = countPasteSenderProvider(_id);
  final detail = inventoryCountDetailControllerProvider(_id);

  setUp(() async {
    repository = _FakeRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryCountRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    // The detail screen keeps the count alive under the dialog.
    container.listen(detail, (_, _) {});
    await container.read(detail.future);
    repository.gets = 0;
  });

  /// Keeps the sender alive, as the open dialog does, and records each
  /// state it publishes.
  List<CountPasteSendState> listen() {
    final states = <CountPasteSendState>[];
    container.listen(sender, (_, next) => states.add(next));
    return states;
  }

  test(
    'chunks at exactly 2,000: 2,000 rows go as one batch, 2,001 as two',
    () async {
      listen();
      await container.read(sender.notifier).send(_rows(2000));
      expect(repository.batches.map((b) => b.length), [2000]);
      expect(container.read(sender).phase, CountPastePhase.done);

      repository.batches.clear();
      await container.read(sender.notifier).send(_rows(2001));
      expect(repository.batches.map((b) => b.length), [2000, 1]);
    },
  );

  test('sends each row by code with its quantity as a Decimal', () async {
    listen();
    await container.read(sender.notifier).send(_rows(2));
    expect(repository.batches.single, [
      CountLineInput.byCode(code: 'P1', quantity: Decimal.parse('1.5')),
      CountLineInput.byCode(code: 'P2', quantity: Decimal.parse('2.5')),
    ]);
  });

  test('publishes the batch number and rows applied while sending', () async {
    final states = listen();
    await container.read(sender.notifier).send(_rows(2500));
    final sending = states.where((s) => s.phase == CountPastePhase.sending);
    expect(sending.map((s) => (s.batch, s.applied, s.batches, s.total)), [
      (1, 0, 2, 2500),
      (2, 2000, 2, 2500),
    ]);
    expect(states.last.phase, CountPastePhase.done);
    expect(states.last.applied, 2500);
  });

  test('a 15,000-row paste goes as 8 batches (7 × 2,000 + 1,000) and every '
      'row is applied (SC-007)', () async {
    listen();
    await container.read(sender.notifier).send(_rows(15000));
    expect(repository.batches.map((b) => b.length), [
      ...List.filled(7, 2000),
      1000,
    ]);
    expect(repository.applied, hasLength(15000));
    expect(repository.applied['P15000'], Decimal.parse('15000.5'));
    final state = container.read(sender);
    expect(state.phase, CountPastePhase.done);
    expect(state.applied, 15000);
    expect(state.batches, 8);
  });

  test('a refused batch maps each part back to its pasted row through '
      "extra['index'] plus the batch offset, and stops", () async {
    listen();
    repository
      ..refuseBatch = 2
      ..refusal = _batchInvalid([5, 0]);
    await container.read(sender.notifier).send(_rows(4500));

    // Batch 3 was never sent.
    expect(repository.batches.map((b) => b.length), [2000, 2000]);
    final state = container.read(sender);
    expect(state.phase, CountPastePhase.stopped);
    expect(state.batch, 2);
    expect(state.applied, 2000);
    expect(state.total, 4500);
    expect(state.error, isNull);
    // Index 5 of batch 2 is the 2,006th row: code P2006, pasted on row 4012.
    expect(state.rejected.map((r) => (r.row, r.code)), [
      (4012, 'P2006'),
      (4002, 'P2001'),
    ]);
    expect(
      state.rejected.first.part.code,
      api.ErrorCode.inventoryCountLinePeriodProductUnknown,
    );
  });

  test('a refused first batch applies nothing', () async {
    listen();
    repository
      ..refuseBatch = 1
      ..refusal = _batchInvalid([0]);
    await container.read(sender.notifier).send(_rows(2500));
    expect(repository.batches, hasLength(1));
    expect(container.read(sender).applied, 0);
    expect(container.read(sender).rejected.single.row, 2);
  });

  test(
    'any other refusal stops with that error and the rows applied',
    () async {
      listen();
      final busy = AppError.validation(
        const [],
        'busy',
        const ApiProblem(
          codeName: 'lock.busy',
          code: api.ErrorCode.lockPeriodBusy,
        ),
      );
      repository
        ..refuseBatch = 2
        ..refusal = busy;
      await container.read(sender.notifier).send(_rows(4500));
      expect(repository.batches, hasLength(2));
      final state = container.read(sender);
      expect(state.phase, CountPastePhase.stopped);
      expect(state.error, busy);
      expect(state.rejected, isEmpty);
      expect(state.applied, 2000);
    },
  );

  test('a batch refusal whose index is out of the batch falls back to the '
      'error', () async {
    listen();
    repository
      ..refuseBatch = 1
      ..refusal = _batchInvalid([2]);
    await container.read(sender.notifier).send(_rows(2));
    final state = container.read(sender);
    expect(state.rejected, isEmpty);
    expect(state.error, repository.refusal);
  });

  test(
    'torn down while a batch is in flight, it re-fetches the count so the '
    'batches already applied show (spec edge case "Paste interrupted")',
    () async {
      final subscription = container.listen(sender, (_, _) {});
      repository.gate = Completer<void>();
      final sending = container.read(sender.notifier).send(_rows(4500));
      await Future<void>.delayed(Duration.zero);
      expect(repository.batches, hasLength(1));

      subscription.close();
      await container.pump();
      expect(container.exists(sender), isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(repository.gets, 1);
      expect(container.read(detail).hasError, isFalse);

      // The in-flight batch lands, and nothing more is sent.
      repository.gate!.complete();
      await sending;
      expect(repository.batches, hasLength(1));
    },
  );

  test('torn down after a finished send, it does not re-fetch', () async {
    final subscription = container.listen(sender, (_, _) {});
    await container.read(sender.notifier).send(_rows(3));
    subscription.close();
    await container.pump();
    expect(container.exists(sender), isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(repository.gets, 0);
  });
}
