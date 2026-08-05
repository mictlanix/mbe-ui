import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';

/// A stored session's own status (data-model.md §3) — distinct from
/// [SessionState], which answers "does the signed-in user have a session
/// right now" and has no `closed` member. `CashSessionStatus` describes *a*
/// session; `SessionState` describes *this user's* situation.
///
/// mbe-api#142 added a **generated** `api.CashSessionStatus` with the
/// identical three members, as a list *filter input* only — never echoed
/// back on any response, so the derivation below is still required for
/// display. [toApi] exists solely to pass this domain value to
/// `CashSessionRepository.list`.
enum CashSessionStatus {
  open,
  stale,
  closed;

  api.CashSessionStatus toApi() => switch (this) {
    CashSessionStatus.open => api.CashSessionStatus.open,
    CashSessionStatus.stale => api.CashSessionStatus.stale,
    CashSessionStatus.closed => api.CashSessionStatus.closed,
  };
}

/// Derives [session]'s status exactly as mbe-api's `session_state` does:
/// `end != null` → closed; open and `start`'s date before [today]'s date →
/// stale; otherwise open. No response ever returns a status field — every
/// list row and detail must replicate this rule themselves.
///
/// [today] is injected rather than read from `DateTime.now()` internally, so
/// the midnight-boundary edge case is deterministic and testable.
CashSessionStatus cashSessionStatusOf(CashSession session, {required DateTime today}) {
  if (session.end != null) return CashSessionStatus.closed;
  final start = session.start;
  final startDate = DateTime(start.year, start.month, start.day);
  final todayDate = DateTime(today.year, today.month, today.day);
  return startDate.isBefore(todayDate) ? CashSessionStatus.stale : CashSessionStatus.open;
}
