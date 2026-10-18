import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';

class _FixedSession extends CurrentSessionController {
  _FixedSession(this._current);

  final CurrentSession _current;

  @override
  Future<CurrentSession> build() async => _current;
}

/// Pins the cash session for widget tests that render payment surfaces
/// (spec 047): payments need an `open` session, so a test that pumps the
/// payment step without a session repository gets a disabled grid. Tests that
/// need the session to *change* mock `CashSessionRepository` instead.
Override sessionOverride(CurrentSession current) =>
    currentSessionControllerProvider.overrideWith(() => _FixedSession(current));

Override openSessionOverride() =>
    sessionOverride(const CurrentSession(state: SessionState.open));
