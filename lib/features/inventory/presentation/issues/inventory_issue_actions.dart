import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_issue_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issues_list_controller.dart';

part 'inventory_issue_actions.g.dart';

/// What `create` answers: the refusal, or the new issue's id to navigate to.
typedef IssueOpened = ({AppError? error, int? id});

/// The refusals after which the issue on screen is stale: someone else
/// changed it meanwhile (spec edge case: concurrent edits).
const _staleCodes = {
  api.ErrorCode.documentPeriodNotEditable,
  api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
  api.ErrorCode.lockPeriodBusy,
};

/// Every write on a warehouse issue (spec 068 contracts/repository.md
/// "Actions notifier").
///
/// Each method answers the [AppError] the server refused with, or `null`
/// when it went through, rather than throwing: the dialog that asked shows
/// the refusal where the user is looking. On success the returned issue is
/// put into its detail provider (when one is alive) and the list is
/// invalidated.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class InventoryIssueActions extends _$InventoryIssueActions {
  @override
  void build() {}

  /// `POST /inventory-issues`: a new draft.
  Future<IssueOpened> create({
    required int warehouseId,
    String? comment,
  }) async {
    final (:error, :issue) = await _run(
      null,
      (r) => r.create(warehouseId: warehouseId, comment: comment),
    );
    return (error: error, id: issue?.id);
  }

  /// `PUT /inventory-issues/{id}`. See
  /// [InventoryIssueRepository.updateHeader].
  Future<AppError?> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  }) async => (await _run(
    id,
    (r) => r.updateHeader(
      id,
      warehouseId: warehouseId,
      comment: comment,
      clearComment: clearComment,
    ),
  )).error;

  /// `POST /inventory-issues/{id}/lines`. The server merges a product
  /// already on the issue into its line.
  Future<AppError?> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.addLine(id, productId: productId, quantity: quantity),
  )).error;

  /// `PUT /inventory-issues/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.updateLine(id, lineId, quantity: quantity),
  )).error;

  /// `DELETE /inventory-issues/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, int lineId) async =>
      (await _run(id, (r) => r.removeLine(id, lineId))).error;

  /// `POST /inventory-issues/{id}/confirm`.
  Future<AppError?> confirm(int id) async =>
      (await _run(id, (r) => r.confirm(id))).error;

  /// `POST /inventory-issues/{id}/cancel`.
  Future<AppError?> cancel(int id) async =>
      (await _run(id, (r) => r.cancel(id))).error;

  /// The one write path. [id] is the issue written to (`null` for `create`),
  /// refreshed after a stale refusal.
  Future<({AppError? error, InventoryIssue? issue})> _run(
    int? id,
    Future<InventoryIssue> Function(InventoryIssueRepository r) write,
  ) async {
    final InventoryIssue issue;
    try {
      issue = await write(ref.read(inventoryIssueRepositoryProvider));
    } on AppError catch (error) {
      if (id != null && _staleCodes.contains(error.problem?.code)) {
        final detail = inventoryIssueDetailControllerProvider(id);
        if (ref.exists(detail)) await ref.read(detail.notifier).refresh();
      }
      return (error: error, issue: null);
    }
    final detail = inventoryIssueDetailControllerProvider(issue.id);
    if (ref.exists(detail)) ref.read(detail.notifier).put(issue);
    ref.invalidate(inventoryIssuesListControllerProvider);
    return (error: null, issue: issue);
  }
}
