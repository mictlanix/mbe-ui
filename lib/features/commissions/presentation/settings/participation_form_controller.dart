import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';

part 'participation_form_controller.freezed.dart';
part 'participation_form_controller.g.dart';

@freezed
abstract class CommissionParticipationFormState
    with _$CommissionParticipationFormState {
  const factory CommissionParticipationFormState({
    @Default('') String name,
    @Default(false) bool submitting,
    @Default(false) bool nameRequired,

    /// The server's refusal of the last write.
    AppError? error,
  }) = _CommissionParticipationFormState;
}

/// The create/edit form of one participation type (spec 078 FR-013).
/// [participation] is `null` to create.
@riverpod
class CommissionParticipationFormController
    extends _$CommissionParticipationFormController {
  @override
  CommissionParticipationFormState build(
    CommissionParticipation? participation,
  ) => CommissionParticipationFormState(name: participation?.name ?? '');

  bool get isDirty => state.name != (participation?.name ?? '');

  void nameChanged(String v) =>
      state = state.copyWith(name: v, nameRequired: false, error: null);

  /// Creates or updates; `true` when the server accepted it.
  Future<bool> save() async {
    final name = state.name.trim();
    if (name.isEmpty) {
      state = state.copyWith(nameRequired: true, error: null);
      return false;
    }
    final repo = ref.read(commissionRepositoryProvider);
    state = state.copyWith(submitting: true, error: null);
    try {
      final current = participation;
      if (current == null) {
        await repo.createParticipation(name);
      } else {
        await repo.updateParticipation(current.id, name);
      }
      ref.invalidate(commissionParticipationsProvider);
      state = state.copyWith(submitting: false);
      return true;
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }

  /// Deletes the participation; `true` when it went through. One in use is
  /// refused with a coded error, left in the state's `error`.
  Future<bool> delete() async {
    final current = participation;
    if (current == null) return false;
    state = state.copyWith(submitting: true, error: null);
    try {
      await ref
          .read(commissionRepositoryProvider)
          .deleteParticipation(current.id);
      ref.invalidate(commissionParticipationsProvider);
      state = state.copyWith(submitting: false);
      return true;
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }
}
