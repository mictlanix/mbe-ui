import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/inventory/domain/count_paste.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

part 'count_paste_dialog.g.dart';

/// The most rows `PUT /inventory-counts/{id}/lines` takes at once.
const countPasteBatchSize = 2000;

enum CountPastePhase { idle, sending, done, stopped }

/// One entry of a refused batch, mapped back to the pasted row it came from.
class CountPasteRejection {
  const CountPasteRejection({
    required this.row,
    required this.code,
    required this.part,
  });

  /// 1-based row number in the pasted text.
  final int row;
  final String code;

  /// The server's part; its code is the reason.
  final ApiProblemPart part;
}

/// Where a send stands (research R8).
class CountPasteSendState {
  const CountPasteSendState({
    this.phase = CountPastePhase.idle,
    this.batch = 0,
    this.batches = 0,
    this.applied = 0,
    this.total = 0,
    this.rejected = const [],
    this.error,
  });

  final CountPastePhase phase;

  /// The 1-based batch in flight, or the one refused.
  final int batch;
  final int batches;

  /// Rows of the whole batches applied so far.
  final int applied;
  final int total;

  /// A refused batch's bad entries (`inventory_count.batch_invalid`).
  final List<CountPasteRejection> rejected;

  /// Any other refusal, or a batch refusal whose entries can't be mapped.
  final AppError? error;

  CountPasteSendState _copy({
    CountPastePhase? phase,
    int? applied,
    List<CountPasteRejection>? rejected,
    AppError? error,
  }) => CountPasteSendState(
    phase: phase ?? this.phase,
    batch: batch,
    batches: batches,
    applied: applied ?? this.applied,
    total: total,
    rejected: rejected ?? this.rejected,
    error: error ?? this.error,
  );
}

/// Sends a parsed paste to draft [countId] in batches of
/// [countPasteBatchSize], one at a time (FR-011d, research R8).
///
/// Auto-dispose and scoped to the paste dialog. Each batch goes through
/// `InventoryCountActions.setLines`, which puts the returned count on
/// screen. The first refusal stops the send. If the dialog is torn down
/// while a batch is in flight, the count is re-fetched so it shows the
/// batches already applied (spec edge case "Paste interrupted").
@riverpod
class CountPasteSender extends _$CountPasteSender {
  bool _sending = false;

  @override
  CountPasteSendState build(int countId) {
    final container = ref.container;
    ref.onDispose(() {
      if (!_sending) return;
      // A provider can't read another while it is being disposed, so the
      // re-fetch runs right after.
      scheduleMicrotask(() {
        final detail = inventoryCountDetailControllerProvider(countId);
        if (!container.exists(detail)) return;
        container.read(detail.notifier).refresh();
      });
    });
    return const CountPasteSendState();
  }

  Future<void> send(List<CountPasteRow> rows) async {
    if (_sending || rows.isEmpty) return;
    final actions = ref.read(inventoryCountActionsProvider.notifier);
    final batches =
        (rows.length + countPasteBatchSize - 1) ~/ countPasteBatchSize;
    _sending = true;
    for (var k = 0; k < batches; k++) {
      final offset = k * countPasteBatchSize;
      final chunk = rows.skip(offset).take(countPasteBatchSize).toList();
      state = CountPasteSendState(
        phase: CountPastePhase.sending,
        batch: k + 1,
        batches: batches,
        applied: offset,
        total: rows.length,
      );
      final error = await actions.setLines(countId, [
        for (final row in chunk)
          CountLineInput.byCode(
            code: row.code,
            quantity: Decimal.parse(row.quantity),
          ),
      ]);
      if (!ref.mounted) return;
      if (error != null) {
        _sending = false;
        final rejected = _rejections(error, chunk);
        state = state._copy(
          phase: CountPastePhase.stopped,
          rejected: rejected,
          error: rejected.isEmpty ? error : null,
        );
        return;
      }
    }
    _sending = false;
    state = state._copy(phase: CountPastePhase.done, applied: rows.length);
  }

  /// A `batch_invalid` refusal's parts, each mapped back to its row through
  /// `extra['index']` (its position in [chunk]). Empty for any other
  /// refusal, or when an index doesn't point into the batch.
  static List<CountPasteRejection> _rejections(
    AppError error,
    List<CountPasteRow> chunk,
  ) {
    final problem = error.problem;
    if (problem?.code != api.ErrorCode.inventoryCountPeriodBatchInvalid) {
      return const [];
    }
    final rejected = <CountPasteRejection>[];
    for (final part in problem!.parts) {
      final raw = part.extra['index'];
      final index = raw is int ? raw : int.tryParse('$raw');
      if (index == null || index < 0 || index >= chunk.length) return const [];
      final row = chunk[index];
      rejected.add(
        CountPasteRejection(row: row.row, code: row.code, part: part),
      );
    }
    return rejected;
  }
}

/// Opens Pegar lista for draft [countId]. When anything was sent, the count
/// is re-fetched on close (ui-contract "Dialogs").
Future<void> showCountPasteDialog(
  BuildContext context, {
  required int countId,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final sent = await showResponsiveDialog<bool>(
    context,
    builder: (context) => _CountPasteDialog(countId: countId),
  );
  if (sent != true) return;
  final detail = inventoryCountDetailControllerProvider(countId);
  if (container.exists(detail)) await container.read(detail.notifier).refresh();
}

class _CountPasteDialog extends ConsumerStatefulWidget {
  const _CountPasteDialog({required this.countId});

  final int countId;

  @override
  ConsumerState<_CountPasteDialog> createState() => _CountPasteDialogState();
}

class _CountPasteDialogState extends ConsumerState<_CountPasteDialog> {
  // simplified: at most 100 problem rows are listed, the summary still counts
  // them all; add paging if clerks need to see more at once.
  static const _maxProblemsShown = 100;

  final _text = TextEditingController();
  CountPaste _paste = parseCountPaste('');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  CountPasteSenderProvider get _sender =>
      countPasteSenderProvider(widget.countId);

  void _send() {
    if (!_paste.canSend) return;
    ref.read(_sender.notifier).send(_paste.rows);
  }

  String _problemReason(AppLocalizations l10n, CountPasteProblemKind kind) =>
      switch (kind) {
        CountPasteProblemKind.fieldCount =>
          l10n.inventoryCountPasteProblemFieldCount,
        CountPasteProblemKind.missingCode =>
          l10n.inventoryCountPasteProblemMissingCode,
        CountPasteProblemKind.notANumber =>
          l10n.inventoryCountPasteProblemNotANumber,
        CountPasteProblemKind.negative =>
          l10n.inventoryCountPasteProblemNegative,
        CountPasteProblemKind.tooManyDecimals =>
          l10n.inventoryCountPasteProblemTooManyDecimals,
        CountPasteProblemKind.repeatedCode =>
          l10n.inventoryCountPasteProblemRepeatedCode,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final send = ref.watch(_sender);
    // A clean send closes the dialog; the caller re-fetches the count.
    ref.listen(_sender, (_, next) {
      if (next.phase == CountPastePhase.done) Navigator.of(context).pop(true);
    });

    return switch (send.phase) {
      CountPastePhase.idle => _editing(context, l10n),
      CountPastePhase.sending ||
      CountPastePhase.done => _sending(context, l10n, send),
      CountPastePhase.stopped => _stopped(context, l10n, send),
    };
  }

  Widget _editing(BuildContext context, AppLocalizations l10n) {
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final paste = _paste;
    final problems = paste.problems.take(_maxProblemsShown);

    return ResponsiveDialog(
      key: const Key('count_paste_dialog'),
      title: l10n.inventoryCountDialogPasteTitle,
      hasUnsavedChanges: () => _text.text.trim().isNotEmpty,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.inventoryCountPasteInstructions),
          TextField(
            key: const Key('count_paste_text'),
            controller: _text,
            autofocus: true,
            minLines: 8,
            maxLines: 12,
            keyboardType: TextInputType.multiline,
            onChanged: (text) => setState(() => _paste = parseCountPaste(text)),
          ),
          Text(
            l10n.inventoryCountPasteSummary(
              fmt.display.count(paste.readCount),
              fmt.display.count(paste.problems.length),
            ),
            key: const Key('count_paste_summary'),
          ),
          if (paste.problems.isNotEmpty)
            Column(
              key: const Key('count_paste_problems'),
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xs,
              children: [
                for (final problem in problems)
                  Text(
                    l10n.inventoryCountPasteProblemRow(
                      problem.row,
                      _problemReason(l10n, problem.kind),
                    ),
                    key: Key('count_paste_problem_${problem.row}'),
                  ),
              ],
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      // A validity gate, not a right: Enviar waits for a clean list.
      primaryAction: ResponsiveDialogAction(
        key: const Key('count_paste_send'),
        label: l10n.inventoryCountPasteSend,
        onPressed: paste.canSend ? _send : null,
      ),
    );
  }

  Widget _sending(
    BuildContext context,
    AppLocalizations l10n,
    CountPasteSendState send,
  ) {
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);

    return ResponsiveDialog(
      key: const Key('count_paste_dialog'),
      title: l10n.inventoryCountDialogPasteTitle,
      dismissible: false,
      body: Column(
        key: const Key('count_paste_progress'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.inventoryCountPasteSending),
          LinearProgressIndicator(
            value: send.total == 0 ? null : send.applied / send.total,
          ),
          Text(
            l10n.inventoryCountPasteProgress(
              fmt.display.count(send.applied),
              fmt.display.count(send.total),
            ),
            key: const Key('count_paste_progress_rows'),
          ),
          Text(
            l10n.inventoryCountPasteBatch(send.batch, send.batches),
            key: const Key('count_paste_progress_batch'),
          ),
        ],
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('count_paste_send'),
        label: l10n.inventoryCountPasteSend,
        busy: true,
        onPressed: null,
      ),
    );
  }

  Widget _stopped(
    BuildContext context,
    AppLocalizations l10n,
    CountPasteSendState send,
  ) {
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final error = send.error;

    String reason(ApiProblemPart part) =>
        localizeProblem(
          ApiProblem(
            codeName: part.codeName,
            code: part.code,
            params: part.params,
          ),
          l10n,
          fmt,
        ) ??
        l10n.errorValidationGeneric;

    return ResponsiveDialog(
      key: const Key('count_paste_dialog'),
      title: l10n.inventoryCountDialogPasteTitle,
      body: Column(
        key: const Key('count_paste_stopped'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.inventoryCountPasteStopped(
              fmt.display.count(send.applied),
              fmt.display.count(send.total),
            ),
            key: const Key('count_paste_stopped_text'),
          ),
          if (error != null)
            ErrorBanner(key: const Key('count_paste_refusal'), error: error),
          if (send.rejected.isNotEmpty)
            Column(
              key: const Key('count_paste_rejected'),
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xs,
              children: [
                Text(l10n.inventoryCountPasteRejectedHeading(send.batch)),
                for (final rejection in send.rejected)
                  Text(
                    l10n.inventoryCountPasteRejectedLine(
                      rejection.code,
                      reason(rejection.part),
                      rejection.row,
                    ),
                    key: Key('count_paste_rejected_${rejection.row}'),
                  ),
              ],
            ),
          Text(l10n.inventoryCountPasteSafeNote),
        ],
      ),
      // Something may have been applied, so closing re-fetches the count.
      primaryAction: ResponsiveDialogAction(
        key: const Key('count_paste_close'),
        label: MaterialLocalizations.of(context).closeButtonLabel,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
