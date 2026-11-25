import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/repositories/commission_repository.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_month_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_periods_controller.dart';

part 'commission_period_actions.g.dart';

/// The writes on a month: close, reopen and pay (spec 078 FR-006 to FR-010),
/// and labelling a line's product (FR-016a).
///
/// Each method answers the [AppError] the server refused with, or `null` when
/// it went through, so the dialog that asked can hand the refusal to the
/// screen's banner. The action's answer carries no total, so the month and the
/// months list are re-read after every action, success or refusal (FR-010): a
/// refusal usually means someone else changed the month meanwhile.
///
/// Keep-alive because a write outlives the dialog that started it. Updating
/// SystemObject 112 (`commissionsBySalesPerson`) is the right the server
/// checks.
@Riverpod(keepAlive: true)
class CommissionPeriodActions extends _$CommissionPeriodActions {
  @override
  void build() {}

  /// `POST /periods/{y}/{m}/close`.
  Future<AppError?> close(CommissionMonth month) =>
      _run((r) => r.closePeriod(month));

  /// `POST /periods/{y}/{m}/reopen`.
  Future<AppError?> reopen(CommissionMonth month) =>
      _run((r) => r.reopenPeriod(month));

  /// `POST /periods/{y}/{m}/pay`.
  Future<AppError?> pay(CommissionMonth month) =>
      _run((r) => r.payPeriod(month));

  /// `PUT /product-labels/{product}`: gives the product the label, then the
  /// open month is recomputed with it (FR-016a).
  Future<AppError?> assignLabel(int productId, int labelId) =>
      _run((r) => r.setProductLabel(productId, labelId));

  Future<AppError?> _run(
    Future<Object?> Function(CommissionRepository r) write,
  ) async {
    AppError? refusal;
    try {
      await write(ref.read(commissionRepositoryProvider));
    } on AppError catch (error) {
      refusal = error;
    }
    ref.invalidate(commissionMonthControllerProvider);
    ref.invalidate(commissionPeriodsControllerProvider);
    return refusal;
  }
}
