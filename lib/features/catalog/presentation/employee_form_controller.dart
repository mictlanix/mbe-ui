import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/gender.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/employees_list_controller.dart';

part 'employee_form_controller.freezed.dart';
part 'employee_form_controller.g.dart';

/// Error codes for [EmployeeFormState.error]/`fieldErrors`, localized in the
/// UI layer.
abstract final class EmployeeFormErrorCode {
  static const firstNameRequired = 'firstNameRequired';
  static const lastNameRequired = 'lastNameRequired';
  static const nicknameRequired = 'nicknameRequired';
  static const genderRequired = 'genderRequired';
  static const birthdayRequired = 'birthdayRequired';
  static const startJobDateRequired = 'startJobDateRequired';
  static const enrollNumberInvalid = 'enrollNumberInvalid';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single employee. [employeeId] is `null` in
/// create mode.
@freezed
class EmployeeFormState with _$EmployeeFormState {
  const factory EmployeeFormState({
    int? employeeId,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String nickname,
    Gender? gender,
    DateTime? birthday,
    @Default('') String taxpayerId,
    @Default(false) bool salesPerson,
    @Default(EntityStatus.active) EntityStatus status,
    @Default('') String personalId,
    DateTime? startJobDate,
    @Default('') String enrollNumber,
    @Default('') String comment,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _EmployeeFormState;
}

/// Manages the create/edit employee form (FR-015, FR-016).
@riverpod
class EmployeeFormController extends _$EmployeeFormController {
  @override
  EmployeeFormState build() => const EmployeeFormState();

  void firstNameChanged(String v) => state = state.copyWith(
    firstName: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void lastNameChanged(String v) => state = state.copyWith(
    lastName: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void nicknameChanged(String v) => state = state.copyWith(
    nickname: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void genderChanged(Gender? v) => state = state.copyWith(
    gender: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void birthdayChanged(DateTime v) => state = state.copyWith(
    birthday: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void taxpayerIdChanged(String v) => state = state.copyWith(taxpayerId: v);

  void salesPersonChanged(bool v) => state = state.copyWith(salesPerson: v);

  void statusChanged(EntityStatus v) => state = state.copyWith(status: v);

  void personalIdChanged(String v) => state = state.copyWith(personalId: v);

  void startJobDateChanged(DateTime v) => state = state.copyWith(
    startJobDate: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void enrollNumberChanged(String v) => state = state.copyWith(
    enrollNumber: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void commentChanged(String v) => state = state.copyWith(comment: v);

  /// Loads an existing employee into the form for viewing/editing.
  Future<void> loadForEdit(int employeeId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final employee = await ref
          .read(employeeRepositoryProvider)
          .get(employeeId: employeeId);
      state = EmployeeFormState(
        employeeId: employee.employeeId,
        firstName: employee.firstName,
        lastName: employee.lastName,
        nickname: employee.nickname,
        gender: employee.gender,
        birthday: employee.birthday,
        taxpayerId: employee.taxpayerId ?? '',
        salesPerson: employee.salesPerson,
        status: employee.status,
        personalId: employee.personalId ?? '',
        startJobDate: employee.startJobDate,
        enrollNumber: employee.enrollNumber?.toString() ?? '',
        comment: employee.comment ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: EmployeeFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation (FR-016).
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.firstName)) {
      errors['firstName'] = EmployeeFormErrorCode.firstNameRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.lastName)) {
      errors['lastName'] = EmployeeFormErrorCode.lastNameRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.nickname)) {
      errors['nickname'] = EmployeeFormErrorCode.nicknameRequired;
    }
    if (state.gender == null) {
      errors['gender'] = EmployeeFormErrorCode.genderRequired;
    }
    if (state.birthday == null) {
      errors['birthday'] = EmployeeFormErrorCode.birthdayRequired;
    }
    if (state.startJobDate == null) {
      errors['startJobDate'] = EmployeeFormErrorCode.startJobDateRequired;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeInteger(
      state.enrollNumber,
    )) {
      errors['enrollNumber'] = EmployeeFormErrorCode.enrollNumberInvalid;
    }
    return errors;
  }

  /// Creates the employee (FR-015, FR-016). Re-checks the caller's
  /// `employees` create privilege immediately before submitting.
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
        .can(SystemObject.employees, AccessRight.create)) {
      state = state.copyWith(
        error: EmployeeFormErrorCode.createPermissionDenied,
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
          .read(employeeRepositoryProvider)
          .create(
            firstName: state.firstName,
            lastName: state.lastName,
            nickname: state.nickname,
            gender: state.gender!.value,
            birthday: state.birthday!,
            startJobDate: state.startJobDate!,
            taxpayerId: _orNull(state.taxpayerId),
            salesPerson: state.salesPerson,
            status: state.status,
            personalId: _orNull(state.personalId),
            enrollNumber: _orNullInt(state.enrollNumber),
            comment: _orNull(state.comment),
          );
      ref.invalidate(employeesListControllerProvider);
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
          error: EmployeeFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded employee. No-ops if no employee has been
  /// loaded.
  Future<void> submitUpdate() async {
    final employeeId = state.employeeId;
    if (employeeId == null) return;

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
        .can(SystemObject.employees, AccessRight.update)) {
      state = state.copyWith(
        error: EmployeeFormErrorCode.updatePermissionDenied,
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
          .read(employeeRepositoryProvider)
          .update(
            employeeId: employeeId,
            firstName: state.firstName,
            lastName: state.lastName,
            nickname: state.nickname,
            gender: state.gender?.value,
            birthday: state.birthday,
            startJobDate: state.startJobDate,
            taxpayerId: state.taxpayerId,
            salesPerson: state.salesPerson,
            status: state.status,
            personalId: state.personalId,
            enrollNumber: _orNullInt(state.enrollNumber),
            comment: state.comment,
          );
      ref.invalidate(employeesListControllerProvider);
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
          error: EmployeeFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded employee. No-ops if no employee has been loaded. A
  /// server rejection (e.g. still assigned as a customer's salesperson) is
  /// surfaced via `error`/`errorDetail`, leaving the employee in place.
  Future<void> delete() async {
    final employeeId = state.employeeId;
    if (employeeId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.employees, AccessRight.delete)) {
      state = state.copyWith(
        error: EmployeeFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(employeeRepositoryProvider).delete(employeeId: employeeId);
      ref.invalidate(employeesListControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: EmployeeFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
    }
  }
}

String? _orNull(String value) => value.isEmpty ? null : value;

int? _orNullInt(String value) => value.isEmpty ? null : int.tryParse(value);

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
