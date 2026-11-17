import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_count_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_controller.dart';

part 'inventory_count_actions.g.dart';

/// What `create` answers: the refusal, or the new count's id to navigate to.
typedef CountOpened = ({AppError? error, int? id});

/// What `confirm` answers: the refusal, or the warnings of the confirm
/// response (empty on a refusal, research R9).
typedef CountConfirmOutcome = ({AppError? error, CountWarnings warnings});

/// The refusals after which the count on screen is stale: someone else
/// changed it meanwhile (spec edge cases: concurrent edits, a stale screen).
const _staleCodes = {
  api.ErrorCode.documentPeriodNotEditable,
  api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
  api.ErrorCode.inventoryCountPeriodConfirmedCannotCancel,
  api.ErrorCode.lockPeriodBusy,
};

/// Every write on a physical count (spec 070 contracts/repository.md).
///
/// Each method answers the [AppError] the server refused with, or `null`
/// when it went through, rather than throwing: the dialog that asked shows
/// the refusal where the user is looking. On success the returned count is
/// put into its detail provider (when one is alive) and the list is
/// invalidated.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class InventoryCountActions extends _$InventoryCountActions {
  @override
  void build() {}

  /// `POST /inventory-counts`: a new draft.
  Future<CountOpened> create({
    required int warehouseId,
    String? comment,
  }) async {
    final (:error, :count) = await _run(
      null,
      (r) => r.create(warehouseId: warehouseId, comment: comment),
    );
    return (error: error, id: count?.id);
  }

  /// `PUT /inventory-counts/{id}`. See
  /// [InventoryCountRepository.updateHeader].
  Future<AppError?> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
  }) async => (await _run(
    id,
    (r) => r.updateHeader(id, warehouseId: warehouseId, comment: comment),
  )).error;

  /// `PUT /inventory-counts/{id}/lines`: one batch, already split by the
  /// caller (the paste sender owns the splitting).
  Future<AppError?> setLines(int id, List<CountLineInput> items) async =>
      (await _run(id, (r) => r.setLines(id, items))).error;

  /// `PUT /inventory-counts/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.updateLine(id, lineId, quantity: quantity),
  )).error;

  /// `DELETE /inventory-counts/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, int lineId) async =>
      (await _run(id, (r) => r.removeLine(id, lineId))).error;

  /// `POST /inventory-counts/{id}/confirm`.
  Future<CountConfirmOutcome> confirm(
    int id, {
    required bool includeUncounted,
  }) async {
    var warnings = const CountWarnings();
    final (:error, count: _) = await _run(id, (r) async {
      final result = await r.confirm(id, includeUncounted: includeUncounted);
      warnings = result.warnings;
      return result.count;
    });
    return (error: error, warnings: warnings);
  }

  /// `POST /inventory-counts/{id}/cancel`. Drafts only.
  Future<AppError?> cancel(int id) async =>
      (await _run(id, (r) => r.cancel(id))).error;

  /// The one write path. [id] is the count written to (`null` for `create`),
  /// refreshed after a stale refusal.
  Future<({AppError? error, InventoryCount? count})> _run(
    int? id,
    Future<InventoryCount> Function(InventoryCountRepository r) write,
  ) async {
    final InventoryCount count;
    try {
      count = await write(ref.read(inventoryCountRepositoryProvider));
    } on AppError catch (error) {
      if (id != null && _staleCodes.contains(error.problem?.code)) {
        final detail = inventoryCountDetailControllerProvider(id);
        if (ref.exists(detail)) await ref.read(detail.notifier).refresh();
      }
      return (error: error, count: null);
    }
    final detail = inventoryCountDetailControllerProvider(count.id);
    if (ref.exists(detail)) ref.read(detail.notifier).put(count);
    ref.invalidate(inventoryCountsListControllerProvider);
    return (error: null, count: count);
  }
}
