import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';

/// Cash session lifecycle: read the caller's current shift, browse history,
/// open, read one, and close (data-model.md §5, §6, §10;
/// contracts/mbe-api-cash-sessions.md). Five operations, matching the five
/// mbe-api endpoints exactly — no update, no delete.
abstract class CashSessionRepository {
  Future<CurrentSession> getCurrent();

  /// [dateFrom]/[dateTo] are accepted because mbe-api#142 exposes them, but
  /// nothing in this feature's UI wires them — no user story or requirement
  /// asks for a date-range filter (research.md §17).
  Future<CashSessionListResult> list({
    int? cashDrawerId,
    int? cashierId,
    CashSessionStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int skip = 0,
    int limit = 20,
  });

  /// [cashDrawerId] omitted ⇒ the server falls back to the caller's
  /// configured drawer.
  Future<CashSession> open({int? cashDrawerId, required String openingAmount});

  Future<CashSession> get({required int cashSessionId});

  /// Only entries with `quantity > 0` should be present in [counts] — the
  /// client-only "require a deliberate count" rule (FR-020, FR-021) is
  /// enforced by the form controller, not here.
  Future<CashSession> close({
    required int cashSessionId,
    required List<DenominationCount> counts,
  });
}

class CashSessionListResult {
  const CashSessionListResult({required this.items, required this.total});
  final List<CashSession> items;
  final int total;
}
