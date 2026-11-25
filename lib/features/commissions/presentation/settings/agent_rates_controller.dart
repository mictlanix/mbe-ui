import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/percent_input.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/label_form_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';

part 'agent_rates_controller.g.dart';

/// One cell of the grid: an agent's share for a label and participation type.
/// An empty cell has no [rateId] and no [share] (data-model `AgentRateGrid`).
class AgentRateCell {
  const AgentRateCell({
    required this.labelId,
    required this.participationId,
    this.rateId,
    this.share,
  });

  final int labelId;
  final int participationId;
  final int? rateId;

  /// A fraction, 0 to 1.
  final Decimal? share;

  bool get isEmpty => rateId == null;

  /// The share as the wire carries it, canonical (`0.025`, never `0.025000`),
  /// or `''` for an empty cell; what a cell's field holds as its value.
  String get wire => share?.toString() ?? '';
}

/// Why a cell's last write did not go through.
class AgentRateRefusal {
  const AgentRateRefusal._({this.error, this.input, this.clearNotAllowed});

  /// The server refused it.
  const AgentRateRefusal.server(AppError error) : this._(error: error);

  /// The typed text broke a [PercentInput] rule; nothing was sent.
  const AgentRateRefusal.invalidInput(PercentInputError input)
    : this._(input: input);

  /// The user may update the cell but not delete it; nothing was sent.
  const AgentRateRefusal.clearNotAllowed() : this._(clearNotAllowed: true);

  final AppError? error;
  final PercentInputError? input;
  final bool? clearNotAllowed;
}

/// `(labelId, participationId)`.
typedef AgentRateKey = (int, int);

/// An agent's rates as a grid: a row per label (by name), a column per
/// participation type (by id), every cell present.
class AgentRateGrid {
  const AgentRateGrid({
    required this.labels,
    required this.participations,
    required this.cells,
    this.refusals = const {},
    this.saved = const {},
  });

  final List<CommissionLabel> labels;
  final List<CommissionParticipation> participations;
  final Map<AgentRateKey, AgentRateCell> cells;

  /// The last refusal per cell; cleared by the cell's next write.
  final Map<AgentRateKey, AgentRateRefusal> refusals;

  /// Cells written since the grid was read, with the share they held before
  /// (`null` when they were empty).
  final Map<AgentRateKey, Decimal?> saved;

  AgentRateCell cell(int labelId, int participationId) =>
      cells[(labelId, participationId)]!;

  AgentRateGrid _with(
    AgentRateKey key, {
    AgentRateCell? cell,
    AgentRateRefusal? refusal,
    bool hasSaved = false,
    Decimal? previous,
  }) => AgentRateGrid(
    labels: labels,
    participations: participations,
    cells: cell == null ? cells : {...cells, key: cell},
    refusals: {
      for (final e in refusals.entries)
        if (e.key != key) e.key: e.value,
      key: ?refusal,
    },
    saved: {
      for (final e in saved.entries)
        if (e.key != key) e.key: e.value,
      if (hasSaved) key: previous,
    },
  );
}

/// One agent's rate grid (spec 078 FR-015, research R11), keyed by the
/// agent's employee id. [writeCell] picks create, update or delete from the
/// cell's state and patches the grid in place with no refetch.
///
/// The rights are those of the call each write makes: empty to a value is a
/// POST (Create), a change a PUT (Update), clearing a DELETE (Delete).
@riverpod
class AgentRatesController extends _$AgentRatesController {
  static const _object = SystemObject.commissionsBySalesPerson;

  @override
  Future<AgentRateGrid> build(int agentId) async {
    final repo = ref.watch(commissionRepositoryProvider);
    final labels = [...await ref.watch(commissionLabelsProvider.future)]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final participations = [
      ...await ref.watch(commissionParticipationsProvider.future),
    ]..sort((a, b) => a.id.compareTo(b.id));
    final rates = await repo.listAgentRates(agentId: agentId);
    final byKey = <AgentRateKey, CommissionAgentRate>{};
    for (final r in rates) {
      byKey.putIfAbsent((r.labelId, r.participationId), () => r);
    }
    return AgentRateGrid(
      labels: labels,
      participations: participations,
      cells: {
        for (final l in labels)
          for (final p in participations)
            (l.id, p.id): AgentRateCell(
              labelId: l.id,
              participationId: p.id,
              rateId: byKey[(l.id, p.id)]?.id,
              share: byKey[(l.id, p.id)]?.share,
            ),
      },
    );
  }

  /// Whether [cell] is a field for the current rights: an empty cell needs
  /// Create, a filled one Update. Otherwise it renders as text.
  bool isWritable(AgentRateCell cell) => ref
      .read(accessControlProvider)
      .can(_object, cell.isEmpty ? AccessRight.create : AccessRight.update);

  /// Whether a filled cell may be cleared (a DELETE needs Delete).
  bool get canClear =>
      ref.read(accessControlProvider).can(_object, AccessRight.delete);

  /// Keeps the typed text a field refused before it was ever submitted (the
  /// field discards it), so the reason shows under the cell.
  void recordInputRefusal(
    int labelId,
    int participationId,
    PercentInputError problem,
  ) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current._with((
        labelId,
        participationId,
      ), refusal: AgentRateRefusal.invalidInput(problem)),
    );
  }

  /// Writes [text], a percentage as typed ("2.5"; empty clears), to the cell.
  /// `true` when it stuck. A refusal stays in [AgentRateGrid.refusals] and the
  /// cell keeps its value.
  Future<bool> writeCell(int labelId, int participationId, String text) async {
    final grid = state.requireValue;
    final key = (labelId, participationId);
    final cell = grid.cell(labelId, participationId);
    final typed = text.trim();
    final repo = ref.read(commissionRepositoryProvider);

    void refuse(AgentRateRefusal refusal) =>
        state = AsyncData((state.value ?? grid)._with(key, refusal: refusal));

    if (typed.isEmpty) {
      final id = cell.rateId;
      if (id == null) return true; // Empty stays empty: nothing to send.
      if (!canClear) {
        refuse(const AgentRateRefusal.clearNotAllowed());
        return false;
      }
      try {
        await repo.deleteAgentRate(id);
      } on AppError catch (e) {
        refuse(AgentRateRefusal.server(e));
        return false;
      }
      _patch(
        key,
        AgentRateCell(labelId: labelId, participationId: participationId),
        previous: cell.share,
      );
      return true;
    }

    final problem = PercentInput.validate(
      typed,
      maxDecimals: commissionRateMaxDecimals,
    );
    if (problem != null) {
      refuse(AgentRateRefusal.invalidInput(problem));
      return false;
    }
    final share = PercentInput.parse(
      typed,
      maxDecimals: commissionRateMaxDecimals,
    )!;
    try {
      final rate = cell.rateId == null
          ? await repo.createAgentRate(
              agentId: agentId,
              labelId: labelId,
              participationId: participationId,
              share: share,
            )
          : await repo.updateAgentRate(cell.rateId!, share);
      _patch(
        key,
        AgentRateCell(
          labelId: labelId,
          participationId: participationId,
          rateId: rate.id,
          share: rate.share,
        ),
        previous: cell.share,
      );
      return true;
    } on AppError catch (e) {
      refuse(AgentRateRefusal.server(e));
      return false;
    }
  }

  /// Applies a write that went through to the grid as it is now, which may
  /// have changed while the request was out.
  void _patch(AgentRateKey key, AgentRateCell cell, {Decimal? previous}) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current._with(key, cell: cell, hasSaved: true, previous: previous),
    );
  }
}
