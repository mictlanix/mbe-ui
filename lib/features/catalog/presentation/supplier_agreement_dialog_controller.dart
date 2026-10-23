import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreements_controller.dart';

part 'supplier_agreement_dialog_controller.freezed.dart';
part 'supplier_agreement_dialog_controller.g.dart';

/// Error codes for [SupplierAgreementDialogState.error], localized in the UI
/// layer — same split as `BankAccountInlineCreateErrorCode`.
abstract final class SupplierAgreementDialogErrorCode {
  static const saveFailed = 'saveFailed';
  static const deleteFailed = 'deleteFailed';
}

/// Maximum length of an agreement's notes (FR-014).
const supplierAgreementCommentMaxLength = 500;

/// Form state for the agreement dialog (spec 050 FR-013, FR-014). Scoped to
/// one dialog instance — auto-disposed when it closes, so each opening
/// starts from its `existing` agreement, or blank.
@freezed
abstract class SupplierAgreementDialogState
    with _$SupplierAgreementDialogState {
  const SupplierAgreementDialogState._();

  const factory SupplierAgreementDialogState({
    DateTime? start,
    DateTime? end,
    @Default('') String comment,
    @Default(false) bool submitting,
    @Default(false) bool done,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _SupplierAgreementDialogState;

  /// `true` when both dates are set and the range is inverted — the dialog
  /// shows this under the End field.
  bool get endBeforeStart =>
      start != null && end != null && end!.isBefore(start!);

  bool get canSubmit =>
      start != null &&
      end != null &&
      !endBeforeStart &&
      comment.length <= supplierAgreementCommentMaxLength &&
      !submitting;
}

@riverpod
class SupplierAgreementDialogController
    extends _$SupplierAgreementDialogController {
  @override
  SupplierAgreementDialogState build(
    int supplierId,
    SupplierAgreement? existing,
  ) => SupplierAgreementDialogState(
    start: existing?.start,
    end: existing?.end,
    comment: existing?.comment ?? '',
  );

  void startChanged(DateTime v) =>
      state = _clearErrors(state.copyWith(start: v));
  void endChanged(DateTime v) => state = _clearErrors(state.copyWith(end: v));
  void commentChanged(String v) =>
      state = _clearErrors(state.copyWith(comment: v));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    state = _clearErrors(state).copyWith(submitting: true);
    final repository = ref.read(supplierRepositoryProvider);
    final comment = state.comment.trim();
    try {
      final current = existing;
      if (current == null) {
        await repository.createAgreement(
          supplierId: supplierId,
          start: state.start!,
          end: state.end!,
          comment: comment.isEmpty ? null : comment,
        );
      } else {
        // Sent as-is, '' included: the serializer drops a null comment and
        // mbe-api keeps an omitted one, so null could never clear the notes.
        await repository.updateAgreement(
          supplierId: supplierId,
          agreementId: current.supplierAgreementId,
          start: state.start!,
          end: state.end!,
          comment: comment,
        );
      }
      ref.invalidate(supplierAgreementsControllerProvider(supplierId));
      state = state.copyWith(submitting: false, done: true);
    } on AppError catch (e) {
      _fail(e, SupplierAgreementDialogErrorCode.saveFailed);
    }
  }

  Future<void> delete() async {
    final current = existing;
    if (current == null || state.submitting) return;
    state = _clearErrors(state).copyWith(submitting: true);
    try {
      await ref
          .read(supplierRepositoryProvider)
          .deleteAgreement(
            supplierId: supplierId,
            agreementId: current.supplierAgreementId,
          );
      ref.invalidate(supplierAgreementsControllerProvider(supplierId));
      state = state.copyWith(submitting: false, done: true);
    } on AppError catch (e) {
      _fail(e, SupplierAgreementDialogErrorCode.deleteFailed);
    }
  }

  void _fail(AppError e, String code) {
    if (e is ValidationError) {
      final errors = <String, String>{};
      for (final fieldError in e.errors) {
        final field = fieldError.loc.isEmpty ? null : fieldError.loc.last;
        if (field != null) errors[field] = fieldError.msg;
      }
      state = state.copyWith(submitting: false, fieldErrors: errors);
    } else {
      state = state.copyWith(
        submitting: false,
        error: code,
        errorDetail: e.serverMessage,
      );
    }
  }

  SupplierAgreementDialogState _clearErrors(
    SupplierAgreementDialogState next,
  ) => next.copyWith(error: null, errorDetail: null, fieldErrors: const {});
}
