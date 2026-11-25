import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

part 'commission_period.freezed.dart';

/// A period's state (spec 078 data-model). An unknown wire value maps to
/// [open]: a period the app does not know about is not final.
enum CommissionPeriodStatus { open, closed, paid }

/// A calendar month, comparable chronologically.
@freezed
abstract class CommissionMonth
    with _$CommissionMonth
    implements Comparable<CommissionMonth> {
  const CommissionMonth._();

  /// [month] is 1 to 12.
  const factory CommissionMonth({required int year, required int month}) =
      _CommissionMonth;

  CommissionMonth get previous => month == 1
      ? CommissionMonth(year: year - 1, month: 12)
      : CommissionMonth(year: year, month: month - 1);

  CommissionMonth get next => month == 12
      ? CommissionMonth(year: year + 1, month: 1)
      : CommissionMonth(year: year, month: month + 1);

  @override
  int compareTo(CommissionMonth other) => year != other.year
      ? year.compareTo(other.year)
      : month.compareTo(other.month);

  bool operator <(CommissionMonth other) => compareTo(other) < 0;

  bool operator >(CommissionMonth other) => compareTo(other) > 0;

  /// Whether this month lies after the month of [now]. The caller passes the
  /// business-time-zone "now", not device UTC.
  bool isAfterCurrent(DateTime now) =>
      compareTo(CommissionMonth(year: now.year, month: now.month)) > 0;
}

/// One row of the months list.
@freezed
abstract class CommissionPeriodSummary with _$CommissionPeriodSummary {
  const factory CommissionPeriodSummary({
    required CommissionMonth month,
    required CommissionPeriodStatus status,

    /// Zero for a reopened month.
    required Decimal total,
    DateTime? closedAt,
    DateTime? paidAt,
    DateTime? reopenedAt,

    /// Employee ids.
    int? closedBy,
    int? paidBy,
    int? reopenedBy,
  }) = _CommissionPeriodSummary;
}

/// What a sale line is.
enum CommissionMovement { sale, refund }

/// Commission earned by one agent for one label in a period.
@freezed
abstract class CommissionTotal with _$CommissionTotal {
  const factory CommissionTotal({
    required int agentId,

    /// Null means "no label".
    int? labelId,
    String? labelName,
    required int lines,
    required Decimal commission,
  }) = _CommissionTotal;
}

/// One commission line of a period.
@freezed
abstract class CommissionLine with _$CommissionLine {
  const factory CommissionLine({
    required CommissionMovement movement,
    required CommissionScheme scheme,
    required int salesOrderId,
    required int salesOrderDetailId,
    int? customerRefundDetailId,
    required DateTime orderDate,
    required DateTime paidDate,
    required int customerId,
    required String customerName,
    required int productId,
    required String productName,
    int? labelId,
    String? labelName,
    required Decimal labelRate,
    required int agentId,
    required int orderSalespersonId,
    required int customerSalespersonId,
    required int participationId,
    required String participationName,
    required Decimal participationRate,
    required Decimal rate,
    required Decimal price,
    required Decimal quantity,
    required Decimal total,
    required Decimal fullCommission,

    /// Only for scheme-2 sales.
    Decimal? share,
    required Decimal commission,
  }) = _CommissionLine;
}

/// An agent's lines and commission in a period.
typedef CommissionAgentTotal = ({int agentId, int lines, Decimal commission});

/// A period read with its totals and lines.
@freezed
abstract class CommissionPeriod with _$CommissionPeriod {
  const CommissionPeriod._();

  const factory CommissionPeriod({
    required CommissionMonth month,
    required CommissionPeriodStatus status,
    DateTime? closedAt,
    DateTime? paidAt,
    DateTime? reopenedAt,
    int? closedBy,
    int? paidBy,
    int? reopenedBy,

    /// The server's `final`: the figures are stored, not live.
    required bool isFinal,
    required List<CommissionTotal> totals,
    required List<CommissionLine> lines,

    /// The filter the period was read with.
    int? agentId,
  }) = _CommissionPeriod;

  /// The sum of the server's rounded totals.
  Decimal get grandTotal =>
      totals.fold(Decimal.zero, (sum, t) => sum + t.commission);

  int get lineCount => totals.fold(0, (sum, t) => sum + t.lines);

  /// One entry per agent, in first-seen order.
  List<CommissionAgentTotal> get totalsByAgent {
    final byAgent = <int, CommissionAgentTotal>{};
    for (final t in totals) {
      final current = byAgent[t.agentId];
      byAgent[t.agentId] = (
        agentId: t.agentId,
        lines: (current?.lines ?? 0) + t.lines,
        commission: (current?.commission ?? Decimal.zero) + t.commission,
      );
    }
    return byAgent.values.toList();
  }

  /// One agent's rows, per label.
  List<CommissionTotal> totalsByLabel(int agentId) =>
      totals.where((t) => t.agentId == agentId).toList();
}
