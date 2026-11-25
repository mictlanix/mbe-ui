import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart'
    show emptyValuePlaceholder;
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/info_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/assign_label_dialog.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_line_panel.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_month_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_period_status_chip.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_periods_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/period_dialogs.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// `/commissions/:year/:month[?agent=ID]`: one month's path, with the chosen
/// agent when there is one. Gated by SystemObject 112
/// (`commissionsBySalesPerson`) read.
String commissionMonthPath(CommissionMonth month, {int? agentId}) {
  final path = '/commissions/${month.year}/${month.month}';
  return agentId == null ? path : '$path?agent=$agentId';
}

/// Lines per in-memory page (research R8).
const commissionLinesPageSize = 50;

/// One month's commissions (spec 078 US1 and US2, contracts/ui-contract.md
/// "Month"). Gated by SystemObject 112 (`commissionsBySalesPerson`) read; the
/// close, reopen and pay buttons need Update.
///
/// With no agent chosen it shows the month's total and one row per agent; a
/// row tap, or the filter drawer, chooses an agent and the screen shows that
/// agent's total, their totals by label and their lines (research R7, the
/// choice lives in the URL). Totals come from the server's response, never
/// from the visible page of lines (R8).
class CommissionMonthScreen extends ConsumerStatefulWidget {
  const CommissionMonthScreen({super.key, required this.month, this.agentId});

  final CommissionMonth month;
  final int? agentId;

  @override
  ConsumerState<CommissionMonthScreen> createState() =>
      _CommissionMonthScreenState();
}

class _CommissionMonthScreenState extends ConsumerState<CommissionMonthScreen> {
  int _pageIndex = 0;

  /// The last action's refusal, shown above the action row.
  AppError? _actionError;

  @override
  void didUpdateWidget(CommissionMonthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.agentId != widget.agentId) {
      _pageIndex = 0;
      _actionError = null;
    }
  }

  CommissionMonth get _month => widget.month;

  void _go(CommissionMonth month, int? agentId) =>
      context.replace(commissionMonthPath(month, agentId: agentId));

  void _openFilters() {
    final l10n = AppLocalizations.of(context)!;
    showCatalogFilterSheet(
      context,
      title: l10n.filtersButton,
      clearAllLabel: l10n.clearAllFilters,
      applyLabel: l10n.applyFilters,
      onClearAll: () => _go(_month, null),
      builder: (_) => _AgentFilterPanel(month: _month),
    );
  }

  /// The whole month's period: the totals of a read filtered to one agent
  /// cover only that agent, and the prompts show the month's.
  Future<CommissionPeriod?> _wholeMonth() async {
    try {
      return await ref.read(
        commissionMonthControllerProvider(_month, null).future,
      );
    } on AppError catch (error) {
      if (mounted) setState(() => _actionError = error);
      return null;
    }
  }

  Future<void> _close() async {
    setState(() => _actionError = null);
    final whole = await _wholeMonth();
    if (whole == null || !mounted) return;
    final result = await showCloseCommissionPeriodDialog(
      context,
      month: _month,
      lineCount: whole.lineCount,
      total: whole.grandTotal,
    );
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  Future<void> _reopen() async {
    setState(() => _actionError = null);
    final result = await showReopenCommissionPeriodDialog(
      context,
      month: _month,
    );
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  /// "Asignar…" on an unlabelled line: the refusal, if any, lands in the
  /// banner like the other actions'.
  Future<void> _assignLabel(CommissionLine line) async {
    setState(() => _actionError = null);
    final result = await showAssignLabelDialog(context, line: line);
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  Future<void> _pay() async {
    setState(() => _actionError = null);
    final whole = await _wholeMonth();
    if (whole == null || !mounted) return;
    final result = await showPayCommissionPeriodDialog(
      context,
      month: _month,
      total: whole.grandTotal,
    );
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final agentId = widget.agentId;
    final periodAsync = ref.watch(
      commissionMonthControllerProvider(_month, agentId),
    );
    // While a refresh is in flight the previous data stays on screen.
    final period = periodAsync.value;

    final Widget body;
    if (period != null) {
      body = _body(period);
    } else if (periodAsync.hasError) {
      body = ListFailedView(
        error: toAppError(periodAsync.error),
        retryLabel: l10n.retryButton,
        onRetry: () =>
            ref.invalidate(commissionMonthControllerProvider(_month, agentId)),
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // No app bar actions (constitution §VI).
      appBar: AppBar(
        title: Text(
          l10n.commissionMonthTitle(
            fmt.display.monthYear(_month.year, _month.month, capitalize: true),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: spacing.cardPadding,
              right: spacing.cardPadding,
              top: spacing.sm,
            ),
            child: _strip(period),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  /// ‹ month › · status · chosen agent, with the filters button at the end.
  Widget _strip(CommissionPeriod? period) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = ref.watch(formattersProvider);
    final agentId = widget.agentId;
    // simplified: device local time, switch to the business time zone's now
    // when the app gets one.
    final showNext = !_month.next.isAfterCurrent(DateTime.now());
    return FactStripRow(
      key: const Key('commission_month_strip'),
      facts: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('commission_previous_month'),
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.commissionPreviousMonthTooltip,
              onPressed: () => _go(_month.previous, agentId),
            ),
            Flexible(
              child: Text(
                fmt.display.monthYear(
                  _month.year,
                  _month.month,
                  capitalize: true,
                ),
                key: const Key('commission_month_name'),
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (showNext)
              IconButton(
                key: const Key('commission_next_month'),
                icon: const Icon(Icons.chevron_right),
                tooltip: l10n.commissionNextMonthTooltip,
                onPressed: () => _go(_month.next, agentId),
              ),
          ],
        ),
        if (period != null) CommissionPeriodStatusChip(status: period.status),
        if (agentId != null)
          InputChip(
            key: const Key('commission_agent_chip'),
            label: CommissionAgentName(agentId: agentId),
            deleteButtonTooltipMessage: l10n.commissionClearAgentTooltip,
            onDeleted: () => _go(_month, null),
          ),
      ],
      trailing: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Badge.count(
          count: agentId == null ? 0 : 1,
          isLabelVisible: agentId != null,
          child: IconButton.outlined(
            key: const Key('commission_month_filter_button'),
            icon: const Icon(Icons.tune),
            tooltip: l10n.filtersTooltip,
            onPressed: _openFilters,
          ),
        ),
      ),
    );
  }

  String _employee(int? id) {
    if (id == null) return emptyValuePlaceholder;
    return ref
        .watch(employeeDisplayNameProvider(id))
        .when(
          data: (name) => name ?? '#$id',
          loading: () => '…',
          error: (_, _) => '#$id',
        );
  }

  /// "Cerrado el … por …", "· Pagado el … por …"; a reopened open month
  /// shows "Reabierto el … por …" instead. Names come from the employee
  /// lookup (research R2).
  Widget? _auditLine(CommissionPeriod period) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final parts = <String>[];
    if (period.status == CommissionPeriodStatus.open) {
      final at = period.reopenedAt;
      if (at != null) {
        parts.add(
          l10n.commissionReopenedOn(
            fmt.display.dateTime(at),
            _employee(period.reopenedBy),
          ),
        );
      }
    } else {
      final closedAt = period.closedAt;
      if (closedAt != null) {
        parts.add(
          l10n.commissionClosedOn(
            fmt.display.dateTime(closedAt),
            _employee(period.closedBy),
          ),
        );
      }
      final paidAt = period.paidAt;
      if (paidAt != null) {
        parts.add(
          l10n.commissionPaidOn(
            fmt.display.dateTime(paidAt),
            _employee(period.paidBy),
          ),
        );
      }
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' · '), key: const Key('commission_audit_line'));
  }

  Widget _body(CommissionPeriod period) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final audit = _auditLine(period);
    final agentId = widget.agentId;
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.sectionGap,
        children: [
          ?audit,
          if (period.status == CommissionPeriodStatus.open)
            InfoBanner(
              key: const Key('commission_live_notice'),
              message: l10n.commissionLiveNotice,
            ),
          if (agentId == null)
            ..._allAgents(period)
          else
            ..._oneAgent(period, agentId),
          ..._actions(period),
        ],
      ),
    );
  }

  Widget _totalRow(Key key, String label, String amount) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: theme.spacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        Text(
          amount,
          key: key,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _schemeOf(int agentId) {
    final l10n = AppLocalizations.of(context)!;
    final agents = ref.watch(commissionAgentsProvider).value ?? const [];
    for (final agent in agents) {
      if (agent.employeeId == agentId) {
        return commissionSchemeLabel(l10n, agent.scheme);
      }
    }
    return emptyValuePlaceholder;
  }

  List<Widget> _allAgents(CommissionPeriod period) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final rows = period.totalsByAgent;
    return [
      _totalRow(
        const Key('commission_month_total'),
        l10n.commissionMonthTotal,
        fmt.display.currency(period.grandTotal.toString()),
      ),
      if (rows.isEmpty)
        Text(
          l10n.commissionMonthEmpty,
          key: const Key('commission_month_empty'),
        )
      else if (compact)
        // Agents become name + total rows.
        Card(
          key: const Key('commission_agents_table'),
          child: Column(
            children: [
              for (final r in rows)
                ListTile(
                  key: Key('commission_agent_row_${r.agentId}'),
                  title: CommissionAgentName(agentId: r.agentId),
                  trailing: Text(fmt.display.currency(r.commission.toString())),
                  onTap: () => _go(_month, r.agentId),
                ),
            ],
          ),
        )
      else
        DataTableView<CommissionAgentTotal>(
          key: const Key('commission_agents_table'),
          shrinkWrap: true,
          rows: rows,
          onRowTap: (r) => _go(_month, r.agentId),
          columns: [
            DataTableColumn(
              label: l10n.commissionColumnAgent,
              size: ColumnSize.L,
              cellBuilder: (context, r) =>
                  CommissionAgentName(agentId: r.agentId),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnScheme,
              size: ColumnSize.M,
              text: (r) => _schemeOf(r.agentId),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnLines,
              size: ColumnSize.S,
              numeric: true,
              text: (r) => fmt.display.count(r.lines),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnCommission,
              size: ColumnSize.M,
              numeric: true,
              text: (r) => fmt.display.currency(r.commission.toString()),
            ),
          ],
        ),
    ];
  }

  List<Widget> _oneAgent(CommissionPeriod period, int agentId) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final spacing = Theme.of(context).spacing;
    final compact = LayoutBreakpoints.isCompact(context);
    final name =
        ref.watch(commissionAgentNameProvider(agentId)).value ??
        l10n.commissionAgentFallback('$agentId');
    final byLabel = period.totalsByLabel(agentId);
    final lines = period.lines;
    final assignable = _canAssignLabel(period);
    final lastPage = lines.isEmpty
        ? 0
        : (lines.length - 1) ~/ commissionLinesPageSize;
    final pageIndex = _pageIndex > lastPage ? lastPage : _pageIndex;
    final start = pageIndex * commissionLinesPageSize;
    final page = CatalogPage<CommissionLine>(
      items: lines.skip(start).take(commissionLinesPageSize).toList(),
      total: lines.length,
      pageIndex: pageIndex,
      pageSize: commissionLinesPageSize,
    );
    return [
      Wrap(
        spacing: spacing.lg,
        runSpacing: spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _totalRow(
            const Key('commission_agent_total'),
            l10n.commissionAgentTotal(name),
            fmt.display.currency(period.grandTotal.toString()),
          ),
          CompactField(
            label: l10n.commissionColumnScheme,
            child: Text(_schemeOf(agentId)),
          ),
        ],
      ),
      if (byLabel.isNotEmpty)
        DataTableView<CommissionTotal>(
          key: const Key('commission_labels_table'),
          shrinkWrap: true,
          rows: byLabel,
          columns: [
            DataTableColumn.text(
              label: l10n.commissionColumnLabel,
              size: ColumnSize.L,
              text: (r) => r.labelName ?? l10n.commissionNoLabel,
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnLines,
              size: ColumnSize.S,
              numeric: true,
              text: (r) => fmt.display.count(r.lines),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnCommission,
              size: ColumnSize.M,
              numeric: true,
              text: (r) => fmt.display.currency(r.commission.toString()),
            ),
          ],
        ),
      if (lines.isEmpty)
        Text(
          l10n.commissionLinesEmpty,
          key: const Key('commission_lines_empty'),
        )
      else if (compact)
        _lineCards(page, assignable: assignable)
      else
        DataTableView<CommissionLine>(
          key: const Key('commission_lines_table'),
          shrinkWrap: true,
          rows: page.items,
          pagination: page,
          onPageChanged: (index) => setState(() => _pageIndex = index),
          onRowTap: (line) => showCommissionLinePanel(context, line),
          columns: [
            DataTableColumn(
              label: l10n.commissionColumnOrder,
              size: ColumnSize.S,
              cellBuilder: (context, line) => _orderCell(line),
            ),
            DataTableColumn.timestamp(
              label: l10n.commissionColumnPaid,
              size: ColumnSize.S,
              text: (line) => fmt.display.date(line.paidDate),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnCustomer,
              size: ColumnSize.M,
              text: (line) => line.customerName,
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnProduct,
              size: ColumnSize.M,
              text: (line) => line.productName,
            ),
            DataTableColumn(
              label: l10n.commissionColumnLabel,
              size: ColumnSize.S,
              cellBuilder: (context, line) =>
                  _labelCell(line, assignable: assignable),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnParticipation,
              size: ColumnSize.M,
              text: (line) => line.participationName,
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnRate,
              size: ColumnSize.S,
              numeric: true,
              text: (line) => fmt.display.percent(line.rate.toString()),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnAmount,
              size: ColumnSize.S,
              numeric: true,
              text: (line) => fmt.display.currency(line.total.toString()),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnCommission,
              size: ColumnSize.S,
              numeric: true,
              text: (line) => fmt.display.currency(line.commission.toString()),
            ),
          ],
        ),
    ];
  }

  /// Whether an unlabelled line offers "Asignar…": the month is open and the
  /// user has Update (the PUT of the product's label).
  bool _canAssignLabel(CommissionPeriod period) =>
      period.status == CommissionPeriodStatus.open &&
      // Commissions (112) update: assigning a label is a PUT.
      ref
          .watch(accessControlProvider)
          .can(SystemObject.commissionsBySalesPerson, AccessRight.update);

  /// The line's label; an unlabelled line offers "Asignar…" as the row's one
  /// action when [assignable], else "Sin etiqueta".
  Widget _labelCell(CommissionLine line, {required bool assignable}) {
    final l10n = AppLocalizations.of(context)!;
    final name = line.labelName;
    if (name != null) {
      return Tooltip(
        message: name,
        child: Text(name, overflow: TextOverflow.ellipsis, maxLines: 1),
      );
    }
    if (!assignable) return Text(l10n.commissionNoLabel);
    return TextButton(
      key: Key('commission_assign_${line.salesOrderDetailId}'),
      onPressed: () => _assignLabel(line),
      child: Text(l10n.commissionAssignAction),
    );
  }

  /// The order number; a refund adds a leading ↩ whose tooltip (and so its
  /// accessible label) says "Devolución". In the table it stays on one line:
  /// a stacked label does not fit the fixed row height at the largest text
  /// size (T036). A compact card has room, so it spells the word out
  /// ([spelled]). Negative amounts and the line panel's movement also mark a
  /// refund.
  Widget _orderCell(CommissionLine line, {bool spelled = false}) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final order = Text('${line.salesOrderId}');
    if (line.movement != CommissionMovement.refund) return order;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: l10n.commissionRefund,
          child: const Icon(
            Icons.undo,
            size: 16,
            key: Key('commission_refund_icon'),
          ),
        ),
        SizedBox(width: theme.spacing.xs),
        Flexible(
          child: spelled
              ? Text('${line.salesOrderId} · ${l10n.commissionRefund}')
              : order,
        ),
      ],
    );
  }

  /// Compact tier: each line a stacked card, with a plain pager.
  Widget _lineCards(
    CatalogPage<CommissionLine> page, {
    required bool assignable,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = ref.watch(formattersProvider);
    final pages = (page.total - 1) ~/ page.pageSize + 1;
    return Column(
      key: const Key('commission_lines_cards'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing.sm,
      children: [
        for (final line in page.items)
          Card(
            child: InkWell(
              onTap: () => showCommissionLinePanel(context, line),
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: _orderCell(line, spelled: true)),
                        Text(fmt.display.date(line.paidDate)),
                      ],
                    ),
                    if (line.labelName == null && assignable)
                      Row(
                        children: [
                          Flexible(child: Text('${line.productName} · ')),
                          TextButton(
                            key: Key(
                              'commission_assign_${line.salesOrderDetailId}',
                            ),
                            onPressed: () => _assignLabel(line),
                            child: Text(l10n.commissionAssignAction),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${line.productName} · '
                        '${line.labelName ?? l10n.commissionNoLabel}',
                      ),
                    Text('${line.customerName} · ${line.participationName}'),
                    Text(
                      '${fmt.display.currency(line.total.toString())} × '
                      '${fmt.display.percent(line.rate.toString())} = '
                      '${fmt.display.currency(line.commission.toString())}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (pages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page.pageIndex == 0
                    ? null
                    : () => setState(() => _pageIndex = page.pageIndex - 1),
              ),
              Text('${page.pageIndex + 1} / $pages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: page.pageIndex + 1 >= pages
                    ? null
                    : () => setState(() => _pageIndex = page.pageIndex + 1),
              ),
            ],
          ),
      ],
    );
  }

  /// The refusal banner and the action row (research R6): Reabrir, then Marcar
  /// pagado or Cerrar mes, each only when offered and with Update. A blocked
  /// open month shows the reason instead of Cerrar mes.
  List<Widget> _actions(CommissionPeriod period) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    // Commissions (112) update: close, reopen and pay.
    final canUpdate = ref
        .watch(accessControlProvider)
        .can(SystemObject.commissionsBySalesPerson, AccessRight.update);
    final monthsAsync = ref.watch(commissionPeriodsControllerProvider);
    // Wait for the months the rules read; a failed read leaves the guidance
    // empty and the server decides (FR-011).
    final months = monthsAsync.value?.all ?? (monthsAsync.hasError ? [] : null);
    final error = _actionError;

    Widget? primary;
    Widget? reopen;
    Widget? blocked;
    if (canUpdate && months != null) {
      if (period.status == CommissionPeriodStatus.open) {
        final availability = closeAvailability(
          _month,
          months,
          // simplified: device local time, as in the strip.
          DateTime.now(),
        );
        if (availability == CommissionCloseAvailability.available) {
          primary = FilledButton(
            key: const Key('commission_close_button'),
            onPressed: _close,
            child: Text(l10n.commissionActionClose),
          );
        } else {
          blocked = Text(switch (availability) {
            CommissionCloseAvailability.blockedNotEnded =>
              l10n.commissionCloseBlockedNotEnded,
            CommissionCloseAvailability.blockedPrevious =>
              l10n.commissionCloseBlockedPrevious(
                fmt.display.monthYear(
                  _month.previous.year,
                  _month.previous.month,
                ),
              ),
            _ => l10n.commissionCloseBlockedLater,
          }, key: const Key('commission_close_blocked'));
        }
      }
      if (canReopen(period.status, _month, months)) {
        reopen = OutlinedButton(
          key: const Key('commission_reopen_button'),
          onPressed: _reopen,
          child: Text(l10n.commissionActionReopen),
        );
      }
      if (canPay(period.status)) {
        primary = FilledButton(
          key: const Key('commission_pay_button'),
          onPressed: _pay,
          child: Text(l10n.commissionActionPay),
        );
      }
    }

    final buttons = [?reopen, ?primary];
    return [
      if (error != null)
        ErrorBanner(key: const Key('commission_action_refusal'), error: error),
      ?blocked,
      if (buttons.isNotEmpty)
        Align(
          key: const Key('commission_actions'),
          alignment: AlignmentDirectional.centerEnd,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: buttons,
          ),
        ),
    ];
  }
}

/// The drawer's one facet, Agente (research R7). A pick writes the URL.
class _AgentFilterPanel extends ConsumerWidget {
  const _AgentFilterPanel({required this.month});

  final CommissionMonth month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final agentId = int.tryParse(
          currentRouteUri(router).queryParameters['agent'] ?? '',
        );
        final current = agentId == null
            ? null
            : ref.watch(commissionAgentNameProvider(agentId)).value ??
                  l10n.commissionAgentFallback('$agentId');
        return CatalogEntityPicker<CommissionAgent>(
          key: const Key('commission_agent_filter'),
          label: l10n.commissionAgentFilterLabel,
          displayStringForOption: (a) => a.name,
          optionsBuilder: (search) async {
            final agents = await ref.read(commissionAgentsProvider.future);
            final needle = search.trim().toLowerCase();
            return agents.where(
              (a) => needle.isEmpty || a.name.toLowerCase().contains(needle),
            );
          },
          onSelected: (a) => context.replace(
            commissionMonthPath(month, agentId: a.employeeId),
          ),
          initialDisplayText: current,
        );
      },
    );
  }
}
