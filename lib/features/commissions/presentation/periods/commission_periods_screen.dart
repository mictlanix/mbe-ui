import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_month_screen.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_period_status_chip.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_periods_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/open_month_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const commissionsPath = '/commissions';

/// The month route (`/commissions/:year/:month[?agent=ID]`). An invalid year
/// or month (not an int, month outside 1-12, after the current month)
/// redirects to the list. Gated by SystemObject 112
/// (`commissionsBySalesPerson`) read through the router's `/commissions`
/// prefix rule. The settings route must be declared before this one.
GoRoute commissionMonthRoute() => GoRoute(
  path: '$commissionsPath/:year/:month',
  redirect: (context, state) =>
      _monthOf(state) == null ? commissionsPath : null,
  builder: (context, state) => CommissionMonthScreen(
    month: _monthOf(state)!,
    agentId: int.tryParse(state.uri.queryParameters['agent'] ?? ''),
  ),
);

CommissionMonth? _monthOf(GoRouterState state) {
  final year = int.tryParse(state.pathParameters['year'] ?? '');
  final month = int.tryParse(state.pathParameters['month'] ?? '');
  if (year == null || month == null || month < 1 || month > 12) return null;
  final parsed = CommissionMonth(year: year, month: month);
  return parsed.isAfterCurrent(DateTime.now()) ? null : parsed;
}

/// Comisiones: the months the server lists, newest first (spec 078 US3,
/// contracts/ui-contract.md "Months list"). Gated by SystemObject 112
/// (`commissionsBySalesPerson`) read.
///
/// A month is a document, so a row has no icons and its tap opens the month.
/// The Estado facet and the paging are client-side (research R9); there is no
/// search box.
class CommissionPeriodsScreen extends ConsumerWidget {
  const CommissionPeriodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final stateAsync = ref.watch(commissionPeriodsControllerProvider);
    final controller = ref.read(commissionPeriodsControllerProvider.notifier);
    final view = stateAsync.value;
    final status = view?.status;
    final previous = CommissionMonth(
      year: DateTime.now().year,
      month: DateTime.now().month,
    ).previous;
    final settingsLabel = l10n.commissionSettingsAction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          filters: [
            if (view == null || view.all.isNotEmpty)
              Badge.count(
                count: status == null ? 0 : 1,
                isLabelVisible: status != null,
                child: IconButton.outlined(
                  key: const Key('commission_periods_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => controller.setStatus(null),
                    builder: (_) => const _CommissionPeriodsFiltersPanel(),
                  ),
                ),
              ),
          ],
          actions: [
            OutlinedButton(
              key: const Key('commission_periods_open_month_button'),
              onPressed: () async {
                final month = await showOpenMonthDialog(context);
                if (month != null && context.mounted) {
                  context.push(commissionMonthPath(month));
                }
              },
              child: Text(l10n.commissionOpenMonthAction),
            ),
            // Icon only below 600 px.
            if (compact)
              Tooltip(
                message: settingsLabel,
                child: OutlinedButton(
                  key: const Key('commission_periods_settings_button'),
                  onPressed: () => context.push('$commissionsPath/settings'),
                  child: const Icon(Icons.settings_outlined),
                ),
              )
            else
              OutlinedButton.icon(
                key: const Key('commission_periods_settings_button'),
                onPressed: () => context.push('$commissionsPath/settings'),
                icon: const Icon(Icons.settings_outlined),
                label: Text(settingsLabel),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<CommissionPeriodSummary>(
            state: stateAsync.whenData((s) => s.page),
            isFiltered: status != null,
            emptyMessage:
                '${l10n.commissionMonthsEmptyTitle} '
                '${l10n.commissionMonthsEmptyBody}',
            createLabel: l10n.commissionViewMonthAction(
              fmt.display.monthYear(previous.year, previous.month),
            ),
            onCreate: () => context.push(commissionMonthPath(previous)),
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => controller.setStatus(null),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(commissionPeriodsControllerProvider),
            onData: (page) => DataTableView<CommissionPeriodSummary>(
              key: const Key('commission_periods_table'),
              columns: [
                DataTableColumn(
                  label: l10n.commissionColumnMonth,
                  size: ColumnSize.M,
                  cellBuilder: (context, r) => Text(
                    fmt.display.monthYear(
                      r.month.year,
                      r.month.month,
                      capitalize: true,
                    ),
                    key: Key(
                      'commission_period_month_${r.month.year}_'
                      '${r.month.month}',
                    ),
                  ),
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, r) =>
                      CommissionPeriodStatusChip(status: r.status),
                ),
                DataTableColumn.text(
                  label: l10n.commissionColumnTotal,
                  size: ColumnSize.S,
                  numeric: true,
                  text: (r) => fmt.display.currency(r.total.toString()),
                ),
                if (!compact)
                  DataTableColumn.timestamp(
                    label: l10n.commissionColumnClosedAt,
                    size: ColumnSize.S,
                    text: (r) => fmt.display.dateTime(r.closedAt),
                  ),
                if (!compact)
                  DataTableColumn.timestamp(
                    label: l10n.commissionColumnPaidAt,
                    size: ColumnSize.S,
                    text: (r) => fmt.display.dateTime(r.paidAt),
                  ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: controller.setPage,
              onRowTap: (r) => context.push(commissionMonthPath(r.month)),
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's one facet, Estado (client-side). Each change returns to the
/// first page.
class _CommissionPeriodsFiltersPanel extends ConsumerWidget {
  const _CommissionPeriodsFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final status = ref.watch(
      commissionPeriodsControllerProvider.select((s) => s.value?.status),
    );
    final controller = ref.read(commissionPeriodsControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Text(l10n.statusFilterLabel, style: theme.textTheme.titleSmall),
        Wrap(
          key: const Key('commission_periods_status_filter'),
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            ChoiceChip(
              key: const Key('commission_periods_status_all'),
              label: Text(l10n.statusFilterAll),
              selected: status == null,
              onSelected: (_) => controller.setStatus(null),
            ),
            for (final value in CommissionPeriodStatus.values)
              ChoiceChip(
                key: Key('commission_periods_status_${value.name}'),
                label: Text(commissionPeriodStatusLabel(l10n, value)),
                selected: status == value,
                // Tapping the selected chip again clears the facet.
                onSelected: (selected) =>
                    controller.setStatus(selected ? value : null),
              ),
          ],
        ),
      ],
    );
  }
}
