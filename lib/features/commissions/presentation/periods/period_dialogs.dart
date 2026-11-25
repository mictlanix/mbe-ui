import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_period_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the month screen opens for close, reopen and pay (spec 078
// ui-contract "Dialogs"). Each runs its own write through
// `CommissionPeriodActions` and closes on any outcome; the screen shows the
// refusal in its banner (research R6). None is destructive-styled: a month
// is not deleted. Updating SystemObject 112 (`commissionsBySalesPerson`) is
// the right the server checks.

/// What a prompt answers once the user confirmed: the refusal, or `null` when
/// the server accepted. A prompt the user backed out of answers `null`
/// instead of this record.
typedef CommissionActionResult = ({AppError? error});

/// "Cerrar {month}", with the month's line count and total, all agents.
Future<CommissionActionResult?> showCloseCommissionPeriodDialog(
  BuildContext context, {
  required CommissionMonth month,
  required int lineCount,
  required Decimal total,
}) => showResponsiveDialog<CommissionActionResult>(
  context,
  builder: (_) => _PeriodActionDialog(
    keyPrefix: 'commission_close',
    title: (l10n, fmt) => l10n.commissionCloseTitle(_monthName(fmt, month)),
    body: (l10n, fmt) => l10n.commissionCloseBody(
      lineCount,
      fmt.display.count(lineCount),
      fmt.display.currency(total.toString()),
    ),
    actionLabel: (l10n) => l10n.commissionActionClose,
    run: (actions) => actions.close(month),
  ),
);

/// "Reabrir {month}": the stored lines are discarded and recalculated.
Future<CommissionActionResult?> showReopenCommissionPeriodDialog(
  BuildContext context, {
  required CommissionMonth month,
}) => showResponsiveDialog<CommissionActionResult>(
  context,
  builder: (_) => _PeriodActionDialog(
    keyPrefix: 'commission_reopen',
    title: (l10n, fmt) => l10n.commissionReopenTitle(_monthName(fmt, month)),
    body: (l10n, fmt) => l10n.commissionReopenBody,
    actionLabel: (l10n) => l10n.commissionActionReopen,
    run: (actions) => actions.reopen(month),
  ),
);

/// "Marcar {month} como pagado": warns that a paid month is final, with the
/// total.
Future<CommissionActionResult?> showPayCommissionPeriodDialog(
  BuildContext context, {
  required CommissionMonth month,
  required Decimal total,
}) => showResponsiveDialog<CommissionActionResult>(
  context,
  builder: (_) => _PeriodActionDialog(
    keyPrefix: 'commission_pay',
    title: (l10n, fmt) => l10n.commissionPayTitle(_monthName(fmt, month)),
    body: (l10n, fmt) =>
        l10n.commissionPayBody(fmt.display.currency(total.toString())),
    actionLabel: (l10n) => l10n.commissionActionPay,
    run: (actions) => actions.pay(month),
  ),
);

String _monthName(AppFormatters fmt, CommissionMonth month) =>
    fmt.display.monthYear(month.year, month.month);

class _PeriodActionDialog extends ConsumerStatefulWidget {
  const _PeriodActionDialog({
    required this.keyPrefix,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.run,
  });

  /// `<prefix>_dialog`, `<prefix>_body` and `<prefix>_submit`.
  final String keyPrefix;
  final String Function(AppLocalizations l10n, AppFormatters fmt) title;
  final String Function(AppLocalizations l10n, AppFormatters fmt) body;
  final String Function(AppLocalizations l10n) actionLabel;
  final Future<AppError?> Function(CommissionPeriodActions actions) run;

  @override
  ConsumerState<_PeriodActionDialog> createState() =>
      _PeriodActionDialogState();
}

class _PeriodActionDialogState extends ConsumerState<_PeriodActionDialog> {
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await widget.run(
      ref.read(commissionPeriodActionsProvider.notifier),
    );
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final prefix = widget.keyPrefix;
    return ResponsiveDialog(
      key: Key('${prefix}_dialog'),
      title: widget.title(l10n, fmt),
      dismissible: !_busy,
      body: Text(widget.body(l10n, fmt), key: Key('${prefix}_body')),
      secondaryAction: ResponsiveDialogAction(
        key: Key('${prefix}_cancel'),
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: Key('${prefix}_submit'),
        label: widget.actionLabel(l10n),
        busy: _busy,
        onPressed: _submit,
      ),
    );
  }
}
