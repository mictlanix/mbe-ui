import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/expense_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/expenses_list_controller.dart';

part 'expense_form_controller.freezed.dart';
part 'expense_form_controller.g.dart';

/// Error codes for [ExpenseFormState.error]/`fieldErrors`, localized in the
/// UI layer (mirrors `LabelFormErrorCode`).
abstract final class ExpenseFormErrorCode {
  static const nameRequired = 'nameRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single expense. [expenseId] is `null` in
/// create mode.
@freezed
class ExpenseFormState with _$ExpenseFormState {
  const factory ExpenseFormState({
    int? expenseId,
    @Default('') String name,
    @Default('') String comment,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _ExpenseFormState;
}

/// Manages the create/edit expense form (FR-010, FR-011).
@riverpod
class ExpenseFormController extends _$ExpenseFormController {
  @override
  ExpenseFormState build() => const ExpenseFormState();

  void nameChanged(String v) => state = state.copyWith(
    name: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void commentChanged(String v) => state = state.copyWith(comment: v);

  /// Loads an existing expense into the form for viewing/editing.
  Future<void> loadForEdit(int expenseId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final expense = await ref
          .read(expenseRepositoryProvider)
          .get(expenseId: expenseId);
      state = ExpenseFormState(
        expenseId: expense.expenseId,
        name: expense.name,
        comment: expense.comment ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: ExpenseFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = ExpenseFormErrorCode.nameRequired;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(expensesListControllerProvider);
  }

  /// Creates the expense (FR-010). Re-checks the caller's `expenses` create
  /// privilege immediately before submitting, since it may have been revoked
  /// since the form was opened.
  Future<void> submitCreate() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        error: null,
        errorDetail: null,
      );
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.expenses, AccessRight.create)) {
      state = state.copyWith(
        error: ExpenseFormErrorCode.createPermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
    try {
      await ref
          .read(expenseRepositoryProvider)
          .create(name: state.name, comment: _orNull(state.comment));
      _invalidateCaches();
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: ExpenseFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded expense (FR-010). No-ops if no expense has
  /// been loaded.
  Future<void> submitUpdate() async {
    final expenseId = state.expenseId;
    if (expenseId == null) return;

    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        error: null,
        errorDetail: null,
      );
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.expenses, AccessRight.update)) {
      state = state.copyWith(
        error: ExpenseFormErrorCode.updatePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
    try {
      await ref
          .read(expenseRepositoryProvider)
          .update(
            expenseId: expenseId,
            name: state.name,
            comment: state.comment,
          );
      _invalidateCaches();
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: ExpenseFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded expense (FR-006). No-ops if no expense has been
  /// loaded. A server rejection is surfaced via `error`/`errorDetail`,
  /// leaving the expense in place.
  Future<void> delete() async {
    final expenseId = state.expenseId;
    if (expenseId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.expenses, AccessRight.delete)) {
      state = state.copyWith(
        error: ExpenseFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(expenseRepositoryProvider).delete(expenseId: expenseId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: ExpenseFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
    }
  }
}

String? _orNull(String value) => value.isEmpty ? null : value;

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
