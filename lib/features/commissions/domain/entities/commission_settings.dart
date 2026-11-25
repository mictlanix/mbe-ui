import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'commission_settings.freezed.dart';

/// How an agent earns on a sale (spec 078 data-model). The wire value is the
/// integer in [wire].
enum CommissionScheme {
  /// Commission once the order is fully paid.
  fullyPaid(1),

  /// Commission in proportion to each payment.
  partialPayments(2);

  const CommissionScheme(this.wire);

  final int wire;

  /// An unknown wire value maps to [fullyPaid], the server's default.
  static CommissionScheme fromWire(int value) =>
      value == 2 ? partialPayments : fullyPaid;
}

/// A commission label: a name and a rate (a fraction, 0 to 1).
@freezed
abstract class CommissionLabel with _$CommissionLabel {
  const factory CommissionLabel({
    required int id,
    required String name,
    required Decimal rate,
    String? comment,
  }) = _CommissionLabel;
}

/// A participation type (client for life, channeling, field service...).
@freezed
abstract class CommissionParticipation with _$CommissionParticipation {
  const factory CommissionParticipation({
    required int id,
    required String name,
  }) = _CommissionParticipation;
}

/// An employee who earns commissions.
@freezed
abstract class CommissionAgent with _$CommissionAgent {
  const factory CommissionAgent({
    required int employeeId,
    required String name,
    required CommissionScheme scheme,
  }) = _CommissionAgent;
}

/// An agent's share (a fraction, 0 to 1) for a label and participation type.
@freezed
abstract class CommissionAgentRate with _$CommissionAgentRate {
  const factory CommissionAgentRate({
    required int id,
    required int agentId,
    required int labelId,
    required int participationId,
    required Decimal share,
  }) = _CommissionAgentRate;
}

/// A product's commission label.
@freezed
abstract class CommissionProductLabel with _$CommissionProductLabel {
  const factory CommissionProductLabel({
    required int productId,
    required String productCode,
    required String productName,
    required int labelId,
  }) = _CommissionProductLabel;
}

/// One page of product labels; [total] counts every match.
@freezed
abstract class CommissionProductLabelPage with _$CommissionProductLabelPage {
  const factory CommissionProductLabelPage({
    required List<CommissionProductLabel> items,
    required int total,
  }) = _CommissionProductLabelPage;
}
