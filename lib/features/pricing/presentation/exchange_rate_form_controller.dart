import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/pricing_validators.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rates_list_controller.dart';

part 'exchange_rate_form_controller.freezed.dart';
part 'exchange_rate_form_controller.g.dart';

/// Error codes for [ExchangeRateFormState.error]/`fieldErrors`.
abstract final class ExchangeRateFormErrorCode {
  static const dateRequired = 'dateRequired';
  static const rateInvalid = 'rateInvalid';
  static const currencyRequired = 'currencyRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single exchange rate. [exchangeRateId] is
/// `null` in create mode.
@freezed
class ExchangeRateFormState with _$ExchangeRateFormState {
  const factory ExchangeRateFormState({
    int? exchangeRateId,
    DateTime? date,
    @Default('') String rate,
    Currency? base,
    Currency? target,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _ExchangeRateFormState;
}

/// Manages the create/edit exchange-rate form (FR-016, FR-017).
@riverpod
class ExchangeRateFormController extends _$ExchangeRateFormController {
  @override
  ExchangeRateFormState build() => const ExchangeRateFormState();

  void dateChanged(DateTime v) => state = state.copyWith(
    date: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void rateChanged(String v) => state = state.copyWith(
    rate: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void baseChanged(Currency v) => state = state.copyWith(
    base: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void targetChanged(Currency v) => state = state.copyWith(
    target: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  Future<void> loadForEdit(int exchangeRateId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final rate = await ref
          .read(exchangeRateRepositoryProvider)
          .get(exchangeRateId: exchangeRateId);
      state = ExchangeRateFormState(
        exchangeRateId: rate.exchangeRateId,
        date: rate.date,
        rate: rate.rate,
        base: rate.base,
        target: rate.target,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: ExchangeRateFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation (FR-016, FR-018). Note the rate must be
  /// **positive** (zero rejected), unlike prices which allow zero.
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.date == null) {
      errors['date'] = ExchangeRateFormErrorCode.dateRequired;
    }
    if (!PricingValidators.isPositiveDecimal(state.rate)) {
      errors['rate'] = ExchangeRateFormErrorCode.rateInvalid;
    }
    if (state.base == null) {
      errors['base'] = ExchangeRateFormErrorCode.currencyRequired;
    }
    if (state.target == null) {
      errors['target'] = ExchangeRateFormErrorCode.currencyRequired;
    }
    return errors;
  }

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
        .can(SystemObject.exchangeRates, AccessRight.create)) {
      state = state.copyWith(
        error: ExchangeRateFormErrorCode.createPermissionDenied,
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
          .read(exchangeRateRepositoryProvider)
          .create(
            date: state.date!,
            rate: state.rate,
            base: state.base!.value,
            target: state.target!.value,
          );
      ref.invalidate(exchangeRatesListControllerProvider);
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
          error: ExchangeRateFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  Future<void> submitUpdate() async {
    final exchangeRateId = state.exchangeRateId;
    if (exchangeRateId == null) return;

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
        .can(SystemObject.exchangeRates, AccessRight.update)) {
      state = state.copyWith(
        error: ExchangeRateFormErrorCode.updatePermissionDenied,
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
          .read(exchangeRateRepositoryProvider)
          .update(
            exchangeRateId: exchangeRateId,
            date: state.date,
            rate: state.rate,
            base: state.base?.value,
            target: state.target?.value,
          );
      ref.invalidate(exchangeRatesListControllerProvider);
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
          error: ExchangeRateFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  Future<void> delete() async {
    final exchangeRateId = state.exchangeRateId;
    if (exchangeRateId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.exchangeRates, AccessRight.delete)) {
      state = state.copyWith(
        error: ExchangeRateFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(exchangeRateRepositoryProvider)
          .delete(exchangeRateId: exchangeRateId);
      ref.invalidate(exchangeRatesListControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: ExchangeRateFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
    }
  }
}

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
