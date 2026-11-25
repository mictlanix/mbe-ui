import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// How many years back the Año dropdown reaches.
// simplified: ten years, widen the range if a company reviews older months.
const _yearsOffered = 10;

/// "Abrir mes" (spec 078 ui-contract): pick a month and a year, defaulting
/// to the previous month, and answer it for the caller to open, or `null`
/// when the user backed out. A month after the current one is not offered,
/// so there is nothing to refuse. Reachable with SystemObject 112
/// (`commissionsBySalesPerson`) read.
Future<CommissionMonth?> showOpenMonthDialog(BuildContext context) =>
    showResponsiveDialog<CommissionMonth>(
      context,
      builder: (_) => const _OpenMonthDialog(),
    );

class _OpenMonthDialog extends ConsumerStatefulWidget {
  const _OpenMonthDialog();

  @override
  ConsumerState<_OpenMonthDialog> createState() => _OpenMonthDialogState();
}

class _OpenMonthDialogState extends ConsumerState<_OpenMonthDialog> {
  late final DateTime _now = DateTime.now();
  late CommissionMonth _picked = CommissionMonth(
    year: _now.year,
    month: _now.month,
  ).previous;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final lastMonth = _picked.year == _now.year ? _now.month : 12;

    return ResponsiveDialog(
      key: const Key('commission_open_month_dialog'),
      title: l10n.commissionOpenMonthTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          // Rebuilt when the year changes, so a clamped month shows.
          KeyedSubtree(
            key: ValueKey(_picked.year),
            child: DropdownButtonFormField<int>(
              key: const Key('commission_open_month_month'),
              initialValue: _picked.month,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.commissionOpenMonthMonthLabel,
              ),
              items: [
                for (var m = 1; m <= lastMonth; m++)
                  DropdownMenuItem(
                    value: m,
                    child: Text(fmt.display.monthName(m, capitalize: true)),
                  ),
              ],
              onChanged: (m) => setState(
                () => _picked = CommissionMonth(
                  year: _picked.year,
                  month: m ?? _picked.month,
                ),
              ),
            ),
          ),
          DropdownButtonFormField<int>(
            key: const Key('commission_open_month_year'),
            initialValue: _picked.year,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.commissionOpenMonthYearLabel,
            ),
            items: [
              for (var y = _now.year; y > _now.year - _yearsOffered; y--)
                DropdownMenuItem(value: y, child: Text('$y')),
            ],
            onChanged: (y) => setState(() {
              final year = y ?? _picked.year;
              final last = year == _now.year ? _now.month : 12;
              _picked = CommissionMonth(
                year: year,
                month: _picked.month > last ? last : _picked.month,
              );
            }),
          ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('commission_open_month_cancel'),
        label: l10n.cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('commission_open_month_confirm'),
        label: l10n.commissionOpenMonthConfirm,
        onPressed: () => Navigator.of(context).pop(_picked),
      ),
    );
  }
}
