import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/formatting/percent_input.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/core/widgets/inline_error_text.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/agent_rates_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/label_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Width of one participation column at the default text size (a field, its
/// `%` and a message under it fit). Fixed, so the columns line up row to row;
/// [_scaled] grows it with the text so a larger text level never wraps a rate.
const _cellWidth = 136.0;

/// Width of the label's own rate column, at the default text size.
const _rateWidth = 96.0;

/// The narrowest the label name gets before the grid scrolls sideways.
const _nameMinWidth = 160.0;

double _scaled(BuildContext context, double width) =>
    MediaQuery.textScalerOf(context).scale(width);

/// One agent's rates: a row per label (name and its own rate), a column per
/// participation type, a share in each cell (spec 078 FR-015, research R11).
///
/// A hand-built table in a `Card`, not `DataTableView`: its rows are a fixed
/// height, and a cell's refusal and "Guardado" line sit under the field, so a
/// row must grow with them. The look (card, 1 px dividers, header role) is the
/// shared table's. A cell is a field only where the user may write it (the
/// controller says so); every other cell is text. Narrower than its columns
/// it scrolls sideways within the card.
class AgentRatesGrid extends ConsumerWidget {
  const AgentRatesGrid({super.key, required this.agentId});

  final int agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final provider = agentRatesControllerProvider(agentId);
    return ref
        .watch(provider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListFailedView(
            error: toAppError(error),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(provider),
          ),
          data: (grid) => grid.labels.isEmpty || grid.participations.isEmpty
              ? ListEmptyView(message: l10n.commissionRatesNoLabels)
              : _Table(agentId: agentId, grid: grid),
        );
  }
}

class _Table extends ConsumerWidget {
  const _Table({required this.agentId, required this.grid});

  final int agentId;
  final AgentRateGrid grid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final columns = grid.participations.length;
    final cellWidth = _scaled(context, _cellWidth);
    final rateWidth = _scaled(context, _rateWidth);
    final natural =
        2 * spacing.cardPadding +
        _nameMinWidth +
        spacing.md +
        rateWidth +
        columns * (spacing.md + cellWidth);
    final divider = Divider(height: 1, thickness: 1, color: theme.dividerColor);

    return Card(
      key: const Key('commission_rates_grid'),
      semanticContainer: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(constraints.maxWidth, natural),
            height: constraints.maxHeight,
            child: Column(
              children: [
                _Band(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.commissionProductLabelLabel,
                          style: theme.typeRoles.tableHeader,
                        ),
                      ),
                      SizedBox(
                        width: rateWidth,
                        child: Text(
                          l10n.commissionColumnRateLabel,
                          textAlign: TextAlign.end,
                          style: theme.typeRoles.tableHeader,
                        ),
                      ),
                      for (final p in grid.participations)
                        Padding(
                          padding: EdgeInsets.only(left: spacing.md),
                          child: SizedBox(
                            width: cellWidth,
                            child: Text(
                              p.name,
                              textAlign: TextAlign.end,
                              style: theme.typeRoles.tableHeader,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                divider,
                Expanded(
                  child: ListView.separated(
                    itemCount: grid.labels.length,
                    separatorBuilder: (_, _) => divider,
                    itemBuilder: (context, i) =>
                        _LabelRow(agentId: agentId, grid: grid, index: i),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A grid row's frame: the same inset above and below, whatever the content.
class _Band extends StatelessWidget {
  const _Band({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.cardPadding,
        vertical: spacing.sm,
      ),
      child: child,
    );
  }
}

class _LabelRow extends ConsumerWidget {
  const _LabelRow({
    required this.agentId,
    required this.grid,
    required this.index,
  });

  final int agentId;
  final AgentRateGrid grid;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final label = grid.labels[index];
    final cellWidth = _scaled(context, _cellWidth);
    final rateWidth = _scaled(context, _rateWidth);
    final name = Text(label.name, overflow: TextOverflow.ellipsis, maxLines: 1);
    return _Band(
      key: Key('commission_rate_row_${label.id}'),
      child: Row(
        // One text baseline across the name, the rate and every cell's text.
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Tooltip(message: label.name, child: name),
          ),
          SizedBox(
            width: rateWidth,
            child: Text(
              fmt.display.percent(label.rate.toString()),
              textAlign: TextAlign.end,
            ),
          ),
          for (final p in grid.participations)
            Padding(
              padding: EdgeInsets.only(left: spacing.md),
              child: SizedBox(
                width: cellWidth,
                child: _RateCell(
                  agentId: agentId,
                  grid: grid,
                  cell: grid.cell(label.id, p.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One cell: a `ConfirmableTextField` where the user may write it, text
/// otherwise, and under it the last refusal or the "Guardado" line.
class _RateCell extends ConsumerStatefulWidget {
  const _RateCell({
    required this.agentId,
    required this.grid,
    required this.cell,
  });

  final int agentId;
  final AgentRateGrid grid;
  final AgentRateCell cell;

  @override
  ConsumerState<_RateCell> createState() => _RateCellState();
}

class _RateCellState extends ConsumerState<_RateCell> {
  late final ConfirmableFieldController _field;

  AgentRatesController get _notifier =>
      ref.read(agentRatesControllerProvider(widget.agentId).notifier);

  @override
  void initState() {
    super.initState();
    _field = ConfirmableFieldController(
      value: widget.cell.wire,
      parse: _parse,
      commit: _commit,
    );
  }

  @override
  void didUpdateWidget(covariant _RateCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _field.sync(value: widget.cell.wire);
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// The typed percentage as the fraction the field keeps ("2.5" ->
  /// "0.025"); empty stays empty (a clear). `null` for text the rules
  /// refuse, which is never sent: the reason is kept for the cell.
  String? _parse(String text) {
    final typed = text.trim();
    if (typed.isEmpty) return '';
    final problem = PercentInput.validate(
      typed,
      maxDecimals: commissionRateMaxDecimals,
    );
    if (problem != null) {
      _notifier.recordInputRefusal(
        widget.cell.labelId,
        widget.cell.participationId,
        problem,
      );
      return null;
    }
    return PercentInput.parse(
      typed,
      maxDecimals: commissionRateMaxDecimals,
    )!.toString();
  }

  Future<bool> _commit(String wire) {
    final fmt = ref.read(formattersProvider);
    return _notifier.writeCell(
      widget.cell.labelId,
      widget.cell.participationId,
      wire.isEmpty ? '' : fmt.field.rate(wire),
    );
  }

  String? _message(
    AppLocalizations l10n,
    AppFormatters fmt,
    AgentRateRefusal refusal,
  ) {
    if (refusal.clearNotAllowed ?? false) {
      return l10n.commissionRateClearNotAllowed;
    }
    final input = refusal.input;
    if (input != null) {
      return switch (input) {
        PercentInputError.invalid => l10n.commissionPercentInvalid,
        PercentInputError.outOfRange => l10n.commissionPercentOutOfRange,
        PercentInputError.tooPrecise => l10n.commissionPercentTooPrecise,
      };
    }
    final error = refusal.error!;
    return error.localizedMessage(l10n, fmt) ??
        error.userMessage(l10n, fmt) ??
        l10n.errorServerGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = ref.watch(formattersProvider);
    // Rebuild when the rights change.
    ref.watch(accessControlProvider);
    final cell = widget.cell;
    final key = (cell.labelId, cell.participationId);
    final refusal = widget.grid.refusals[key];
    final saved = widget.grid.saved;
    final writable = _notifier.isWritable(cell);

    final Widget content;
    if (writable) {
      content = ConfirmableTextField(
        key: Key('commission_rate_${cell.labelId}_${cell.participationId}'),
        fieldKey: Key(
          'commission_rate_field_${cell.labelId}_${cell.participationId}',
        ),
        controller: _field,
        textAlign: TextAlign.end,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(isDense: true, suffixText: '%'),
        format: (wire) => wire.isEmpty ? '' : fmt.field.rate(wire),
      );
    } else {
      content = Text(
        cell.share == null
            ? emptyValuePlaceholder
            : fmt.display.percent(cell.share.toString()),
        key: Key(
          'commission_rate_text_${cell.labelId}_${cell.participationId}',
        ),
        textAlign: TextAlign.end,
      );
    }

    final String? note;
    if (refusal == null && saved.containsKey(key)) {
      final before = saved[key];
      note = before == null
          ? l10n.commissionRateSaved
          : l10n.commissionRateSavedBefore(fmt.display.percent('$before'));
    } else {
      note = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        content,
        if (refusal != null)
          Padding(
            padding: EdgeInsets.only(top: theme.spacing.xxs),
            child: InlineErrorText(
              _message(l10n, fmt, refusal) ?? '',
              key: Key(
                'commission_rate_error_${cell.labelId}_${cell.participationId}',
              ),
            ),
          )
        else if (note != null)
          Padding(
            padding: EdgeInsets.only(top: theme.spacing.xxs),
            child: Text(
              note,
              textAlign: TextAlign.end,
              style: theme.typeRoles.fieldLabel,
            ),
          ),
      ],
    );
  }
}
