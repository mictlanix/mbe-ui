import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

/// Commission periods and settings (spec 078 contracts/repository.md). Every
/// method throws `AppError`. Rates and shares are `Decimal` fractions (0 to 1).
abstract class CommissionRepository {
  /// Months with a period, newest first.
  Future<List<CommissionPeriodSummary>> listPeriods();

  /// The period's totals and lines. [agentId] limits the lines to one agent
  /// and is sent only when set.
  Future<CommissionPeriod> getPeriod(CommissionMonth month, {int? agentId});

  Future<CommissionPeriodSummary> closePeriod(CommissionMonth month);

  Future<CommissionPeriodSummary> reopenPeriod(CommissionMonth month);

  Future<CommissionPeriodSummary> payPeriod(CommissionMonth month);

  Future<List<CommissionLabel>> listLabels();

  Future<CommissionLabel> createLabel({
    required String name,
    required Decimal rate,
    String? comment,
  });

  /// Only the fields given are sent.
  Future<CommissionLabel> updateLabel(
    int id, {
    String? name,
    Decimal? rate,
    String? comment,
  });

  Future<void> deleteLabel(int id);

  Future<List<CommissionParticipation>> listParticipations();

  Future<CommissionParticipation> createParticipation(String name);

  Future<CommissionParticipation> updateParticipation(int id, String name);

  Future<void> deleteParticipation(int id);

  Future<List<CommissionAgent>> listAgents();

  Future<CommissionAgent> createAgent(int employeeId, CommissionScheme scheme);

  Future<CommissionAgent> updateAgent(int employeeId, CommissionScheme scheme);

  Future<void> deleteAgent(int employeeId);

  Future<List<CommissionAgentRate>> listAgentRates({
    int? agentId,
    int? labelId,
  });

  Future<CommissionAgentRate> createAgentRate({
    required int agentId,
    required int labelId,
    required int participationId,
    required Decimal share,
  });

  Future<CommissionAgentRate> updateAgentRate(int id, Decimal share);

  Future<void> deleteAgentRate(int id);

  Future<CommissionProductLabelPage> listProductLabels({
    int? labelId,
    int? productId,
    required int skip,
    required int limit,
  });

  Future<CommissionProductLabel> setProductLabel(int productId, int labelId);

  Future<void> removeProductLabel(int productId);
}
