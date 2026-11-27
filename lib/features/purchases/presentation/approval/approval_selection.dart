import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/purchases/presentation/approval/approval_queue_controller.dart';

part 'approval_selection.g.dart';

/// The queue rows picked for "Aprobar seleccionadas" (spec 079 FR-023,
/// research R10): request ids, **within one page**.
///
/// Keyed by the queue's filter, so a page or filter change starts from an
/// empty selection. It also empties whenever that page reloads, which every
/// approval and rejection causes (the actions invalidate the queue), wherever
/// it was made: a selected id never outlives the row it was picked on.
@riverpod
class ApprovalSelection extends _$ApprovalSelection {
  @override
  Set<int> build(ApprovalQueueFilter filter) {
    ref.listen(approvalQueueControllerProvider(filter), (_, _) {
      if (state.isNotEmpty) state = const {};
    });
    return const {};
  }

  /// Adds [id], or removes it when already picked.
  void toggle(int id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};

  /// Picks every id in [ids] (the page's rows).
  void selectAll(Iterable<int> ids) => state = {...ids};

  void clear() => state = const {};

  int get count => state.length;
}
