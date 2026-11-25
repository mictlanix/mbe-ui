import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';

part 'agent_form_controller.freezed.dart';
part 'agent_form_controller.g.dart';

@freezed
abstract class CommissionAgentFormState with _$CommissionAgentFormState {
  const factory CommissionAgentFormState({
    /// The chosen employee; fixed when editing.
    int? employeeId,
    @Default(CommissionScheme.fullyPaid) CommissionScheme scheme,
    @Default(false) bool submitting,
    @Default(false) bool employeeRequired,

    /// The server's refusal of the last write.
    AppError? error,
  }) = _CommissionAgentFormState;
}

/// The create/edit form of one commission agent (spec 078 FR-014). [agent] is
/// `null` to create; editing changes only the scheme.
@riverpod
class CommissionAgentFormController extends _$CommissionAgentFormController {
  @override
  CommissionAgentFormState build(CommissionAgent? agent) =>
      CommissionAgentFormState(
        employeeId: agent?.employeeId,
        scheme: agent?.scheme ?? CommissionScheme.fullyPaid,
      );

  bool get isDirty =>
      state.employeeId != agent?.employeeId ||
      state.scheme != (agent?.scheme ?? CommissionScheme.fullyPaid);

  void employeeChosen(int employeeId) => state = state.copyWith(
    employeeId: employeeId,
    employeeRequired: false,
    error: null,
  );

  void schemeChanged(CommissionScheme scheme) =>
      state = state.copyWith(scheme: scheme, error: null);

  /// Creates or updates; `true` when the server accepted it.
  Future<bool> save() async {
    final employeeId = state.employeeId;
    if (employeeId == null) {
      state = state.copyWith(employeeRequired: true, error: null);
      return false;
    }
    final repo = ref.read(commissionRepositoryProvider);
    state = state.copyWith(submitting: true, error: null);
    try {
      if (agent == null) {
        await repo.createAgent(employeeId, state.scheme);
      } else {
        await repo.updateAgent(employeeId, state.scheme);
      }
      ref.invalidate(commissionAgentsProvider);
      state = state.copyWith(submitting: false);
      return true;
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }

  /// Deletes the agent; `true` when it went through. An agent with rates is
  /// refused (`still_referenced`), left in the state's `error`.
  Future<bool> delete() async {
    final current = agent;
    if (current == null) return false;
    state = state.copyWith(submitting: true, error: null);
    try {
      await ref
          .read(commissionRepositoryProvider)
          .deleteAgent(current.employeeId);
      ref.invalidate(commissionAgentsProvider);
      state = state.copyWith(submitting: false);
      return true;
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }
}
