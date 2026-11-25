import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A period status's localized name (spec 078).
String commissionPeriodStatusLabel(
  AppLocalizations l10n,
  CommissionPeriodStatus status,
) => switch (status) {
  CommissionPeriodStatus.open => l10n.commissionStatusOpen,
  CommissionPeriodStatus.closed => l10n.commissionStatusClosed,
  CommissionPeriodStatus.paid => l10n.commissionStatusPaid,
};

/// A status's tone: open neutral (still being calculated), closed info
/// (saved, awaiting payment), paid success.
StatusLook commissionPeriodStatusLook(CommissionPeriodStatus status) =>
    switch (status) {
      CommissionPeriodStatus.open => (StatusTone.neutral, null),
      CommissionPeriodStatus.closed => (StatusTone.info, null),
      CommissionPeriodStatus.paid => (StatusTone.success, null),
    };

/// The period's status chip, shared by the months list and the month screen.
class CommissionPeriodStatusChip extends StatelessWidget {
  const CommissionPeriodStatusChip({super.key, required this.status});

  final CommissionPeriodStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = commissionPeriodStatusLook(status);
    return StatusChip<CommissionPeriodStatus>(
      key: const Key('commission_period_status_chip'),
      value: status,
      label: commissionPeriodStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}
