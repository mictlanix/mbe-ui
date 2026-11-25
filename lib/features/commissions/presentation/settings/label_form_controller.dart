import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/formatting/percent_input.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';

part 'label_form_controller.freezed.dart';
part 'label_form_controller.g.dart';

/// Decimals a label rate may carry, as a percentage (research R12).
const commissionRateMaxDecimals = 4;

@freezed
abstract class CommissionLabelFormState with _$CommissionLabelFormState {
  const factory CommissionLabelFormState({
    @Default('') String name,

    /// The rate as typed, a percentage ("2.5").
    @Default('') String rate,
    @Default('') String comment,
    @Default(false) bool submitting,
    @Default(false) bool nameRequired,
    PercentInputError? rateError,

    /// The server's refusal of the last write.
    AppError? error,
  }) = _CommissionLabelFormState;
}

/// The create/edit form of one commission label (spec 078 FR-012). [label] is
/// `null` to create. The rate is typed as a percentage and sent as a fraction
/// (research R12).
@riverpod
class CommissionLabelFormController extends _$CommissionLabelFormController {
  @override
  CommissionLabelFormState build(CommissionLabel? label) {
    if (label == null) return const CommissionLabelFormState();
    return CommissionLabelFormState(
      name: label.name,
      rate: ref.read(formattersProvider).field.rate(label.rate.toString()),
      comment: label.comment ?? '',
    );
  }

  /// Whether the user changed something worth warning about.
  bool get isDirty {
    final initial = build(label);
    return state.name != initial.name ||
        state.rate != initial.rate ||
        state.comment != initial.comment;
  }

  void nameChanged(String v) =>
      state = state.copyWith(name: v, nameRequired: false, error: null);

  void rateChanged(String v) =>
      state = state.copyWith(rate: v, rateError: null, error: null);

  void commentChanged(String v) => state = state.copyWith(comment: v);

  /// Creates or updates; `true` when the server accepted it. A refusal stays
  /// in [CommissionLabelFormState.error].
  Future<bool> save() async {
    final nameRequired = state.name.trim().isEmpty;
    final rateError = PercentInput.validate(
      state.rate,
      maxDecimals: commissionRateMaxDecimals,
    );
    if (nameRequired || rateError != null) {
      state = state.copyWith(
        nameRequired: nameRequired,
        rateError: rateError,
        error: null,
      );
      return false;
    }
    final rate = PercentInput.parse(
      state.rate,
      maxDecimals: commissionRateMaxDecimals,
    )!;
    final comment = state.comment.trim();
    final repo = ref.read(commissionRepositoryProvider);
    state = state.copyWith(submitting: true, error: null);
    try {
      final current = label;
      if (current == null) {
        await repo.createLabel(
          name: state.name.trim(),
          rate: rate,
          comment: comment.isEmpty ? null : comment,
        );
      } else {
        await repo.updateLabel(
          current.id,
          name: state.name.trim(),
          rate: rate,
          comment: comment,
        );
      }
      ref.invalidate(commissionLabelsProvider);
      state = state.copyWith(submitting: false);
      return true;
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }

  /// Deletes the label; `true` when it went through. A label in use is
  /// refused with a coded error, left in [CommissionLabelFormState.error].
  Future<bool> delete() async {
    final current = label;
    if (current == null) return false;
    state = state.copyWith(submitting: true, error: null);
    try {
      await ref.read(commissionRepositoryProvider).deleteLabel(current.id);
      ref.invalidate(commissionLabelsProvider);
      state = state.copyWith(submitting: false);
      return true;
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }
}
