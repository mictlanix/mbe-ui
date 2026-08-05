import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';

part 'current_session_controller.g.dart';

/// The signed-in user's shift situation (FR-001), backing the shift panel.
/// A mutation (open/close) invalidates this provider so the panel refreshes
/// without a manual reload.
@riverpod
class CurrentSessionController extends _$CurrentSessionController {
  @override
  Future<CurrentSession> build() {
    return ref.watch(cashSessionRepositoryProvider).getCurrent();
  }
}

/// FR-004's "does the caller have other open sessions" check — a direct,
/// exact query, not the same-drawer heuristic research.md §16 originally
/// specified before mbe-api#142 shipped a `cashier` filter mid-implementation
/// (research.md §17). A manual `FutureProvider`, matching the
/// `employeeDisplayNameProvider`/`cashDrawerDisplayNameProvider` convention
/// for a small derived async value, rather than distorting [CurrentSession]
/// (the wire-mapped entity) with a synthetic field.
///
/// `false` when the caller has no open/stale session at all — there is no
/// `cashierId` to query with, and nothing to warn about. Otherwise, exhaustive
/// across every drawer: unlike the superseded heuristic, this finds an
/// orphaned session regardless of which drawer it is on.
final hasOtherOpenSessionsProvider = FutureProvider<bool>((ref) async {
  final current = await ref.watch(currentSessionControllerProvider.future);
  final session = current.session;
  if (session == null) return false;

  final result = await ref
      .watch(cashSessionRepositoryProvider)
      .list(cashierId: session.cashierId, status: CashSessionStatus.open, limit: 100);
  return result.total > 1;
});
