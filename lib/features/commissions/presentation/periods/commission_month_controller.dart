import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';

part 'commission_month_controller.g.dart';

/// One month as the server reads it (`GET /periods/{y}/{m}`), for all agents
/// or, with [agentId], for one (`?salesperson=`). The totals in the response
/// are filtered the same way, so a screen that needs the month's whole total
/// reads the `null` agent's instance. Commissions (112) read is the right it
/// needs. Actions refresh it by invalidating the family.
@riverpod
class CommissionMonthController extends _$CommissionMonthController {
  @override
  Future<CommissionPeriod> build(CommissionMonth month, int? agentId) => ref
      .watch(commissionRepositoryProvider)
      .getPeriod(month, agentId: agentId);
}

/// Why a month that is open cannot be closed yet (data-model "Action
/// availability"), or [available].
enum CommissionCloseAvailability {
  available,
  blockedNotEnded,
  blockedPrevious,
  blockedLater,
}

bool _isClosedOrPaid(CommissionPeriodSummary period) =>
    period.status != CommissionPeriodStatus.open;

/// Whether [month], an open month, can be closed, from the months the server
/// lists (spec 078 FR-007; guidance only, the server decides, FR-011).
///
/// The month must have ended; a month before it must already be closed when
/// anything is closed at all (the chain, where "closed" includes paid, spec
/// 025 FR-010a); and no later month may be closed. The first close ever has
/// no previous month to wait for.
CommissionCloseAvailability closeAvailability(
  CommissionMonth month,
  List<CommissionPeriodSummary> months,
  DateTime now,
) {
  // The business month is the app's own "now"; there is no separate
  // business clock yet.
  // simplified: device local time, switch to the business time zone's now
  // when the app gets one (a month boundary can differ by hours).
  final current = CommissionMonth(year: now.year, month: now.month);
  if (month.compareTo(current) >= 0) {
    return CommissionCloseAvailability.blockedNotEnded;
  }
  // The server's order (mbe-api commission_service close): compare with the
  // latest closed or paid month. None closed yet: this is the first close.
  final closed = months.where(_isClosedOrPaid).map((p) => p.month).toList();
  if (closed.isEmpty) return CommissionCloseAvailability.available;
  final latest = closed.reduce((a, b) => a > b ? a : b);
  if (latest.compareTo(month.previous) == 0) {
    return CommissionCloseAvailability.available;
  }
  return latest > month
      ? CommissionCloseAvailability.blockedLater
      : CommissionCloseAvailability.blockedPrevious;
}

/// Reabrir: the month is closed and no later month is closed or paid.
bool canReopen(
  CommissionPeriodStatus status,
  CommissionMonth month,
  List<CommissionPeriodSummary> months,
) =>
    status == CommissionPeriodStatus.closed &&
    !months.any((p) => _isClosedOrPaid(p) && p.month > month);

/// Marcar pagado: the month is closed.
bool canPay(CommissionPeriodStatus status) =>
    status == CommissionPeriodStatus.closed;
