import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';

part 'bank_account_inline_create_controller.freezed.dart';
part 'bank_account_inline_create_controller.g.dart';

/// Error codes for [BankAccountInlineCreateState], localized in the UI layer —
/// same split as `ContactInlineCreateErrorCode`.
abstract final class BankAccountInlineCreateErrorCode {
  static const required = 'required';
  static const tooLong = 'tooLong';
  static const createFailed = 'createFailed';
}

/// Maximum lengths per field, keyed by the wire field name (FR-007). Shared
/// with the dialog so its copy names the same limit the controller enforces.
abstract final class BankAccountFieldLimit {
  static const bankName = 250;
  static const accountNumber = 20;
  static const reference = 20;
  static const routingNumber = 18;
  static const comment = 500;

  static const byField = <String, int>{
    'bank_name': bankName,
    'account_number': accountNumber,
    'reference': reference,
    'routing_number': routingNumber,
    'comment': comment,
  };
}

/// Form state for the supplier form's inline "new bank account" dialog
/// (FR-006). Scoped to one dialog instance — auto-disposed when it closes, so
/// each opening starts blank.
@freezed
abstract class BankAccountInlineCreateState
    with _$BankAccountInlineCreateState {
  const factory BankAccountInlineCreateState({
    @Default('') String bankName,
    @Default('') String accountNumber,
    @Default('') String reference,
    @Default('') String routingNumber,
    @Default('') String comment,
    @Default(false) bool submitting,
    BankAccount? created,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _BankAccountInlineCreateState;
}

@riverpod
class BankAccountInlineCreateController
    extends _$BankAccountInlineCreateController {
  @override
  BankAccountInlineCreateState build() => const BankAccountInlineCreateState();

  void bankNameChanged(String v) =>
      state = _clearErrors(state.copyWith(bankName: v));
  void accountNumberChanged(String v) =>
      state = _clearErrors(state.copyWith(accountNumber: v));
  void referenceChanged(String v) =>
      state = _clearErrors(state.copyWith(reference: v));
  void routingNumberChanged(String v) =>
      state = _clearErrors(state.copyWith(routingNumber: v));
  void commentChanged(String v) =>
      state = _clearErrors(state.copyWith(comment: v));

  Future<void> submit() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        error: null,
        errorDetail: null,
      );
      return;
    }

    state = _clearErrors(state).copyWith(submitting: true);
    try {
      final created = await ref
          .read(bankAccountRepositoryProvider)
          .create(
            bankName: state.bankName.trim(),
            accountNumber: state.accountNumber.trim(),
            reference: _orNull(state.reference),
            routingNumber: _orNull(state.routingNumber),
            comment: _orNull(state.comment),
          );
      state = state.copyWith(submitting: false, created: created);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: BankAccountInlineCreateErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  String? _orNull(String v) => v.trim().isEmpty ? null : v.trim();

  Map<String, String> _validate() {
    final errors = <String, String>{};
    final values = {
      'bank_name': state.bankName,
      'account_number': state.accountNumber,
      'reference': state.reference,
      'routing_number': state.routingNumber,
      'comment': state.comment,
    };
    for (final entry in values.entries) {
      final isRequired =
          entry.key == 'bank_name' || entry.key == 'account_number';
      final value = entry.value.trim();
      if (isRequired && value.isEmpty) {
        errors[entry.key] = BankAccountInlineCreateErrorCode.required;
      } else if (value.length > BankAccountFieldLimit.byField[entry.key]!) {
        errors[entry.key] = BankAccountInlineCreateErrorCode.tooLong;
      }
    }
    return errors;
  }

  Map<String, String> _fieldErrorsFromServer(ValidationError error) {
    final errors = <String, String>{};
    for (final fieldError in error.errors) {
      final field = fieldError.loc.isEmpty ? null : fieldError.loc.last;
      if (field != null) errors[field] = fieldError.msg;
    }
    return errors;
  }

  BankAccountInlineCreateState _clearErrors(
    BankAccountInlineCreateState next,
  ) => next.copyWith(error: null, errorDetail: null, fieldErrors: const {});
}
