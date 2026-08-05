import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';

part 'current_session.freezed.dart';

/// The signed-in user's shift situation (data-model.md §4), mapped from
/// `GET /cash-sessions/current`. `state == none` iff [session] is `null`.
///
/// `GET /current` returns only the caller's **most recent** open session when
/// several exist — legacy data has cashiers with three and four. This is not
/// a complete picture of the user's open sessions; the history list (FR-034)
/// is the only way to reach the rest.
@freezed
class CurrentSession with _$CurrentSession {
  const factory CurrentSession({required SessionState state, CashSession? session}) =
      _CurrentSession;

  factory CurrentSession.fromResponse(api.CurrentSessionResponse r) => CurrentSession(
    state: SessionState.fromApi(r.state),
    session: r.session == null ? null : CashSession.fromResponse(r.session!),
  );
}

/// Mirrors the generated `api.SessionState` enum class (`none`/`open`/`stale`)
/// as a plain Dart enum, matching the domain-enum-over-generated-enum
/// convention used elsewhere (e.g. [EntityStatus]). Note there is no `closed`
/// member — a closed session is simply not the caller's current one.
enum SessionState {
  none,
  open,
  stale;

  static SessionState fromApi(api.SessionState value) => switch (value) {
    api.SessionState.none => SessionState.none,
    api.SessionState.open => SessionState.open,
    api.SessionState.stale => SessionState.stale,
    _ => SessionState.none,
  };
}
