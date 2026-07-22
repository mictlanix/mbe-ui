import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';

part 'address_inline_create_controller.freezed.dart';
part 'address_inline_create_controller.g.dart';

/// Error codes for [AddressInlineCreateState.error]/`fieldErrors`, localized
/// in the UI layer.
abstract final class AddressInlineCreateErrorCode {
  static const streetRequired = 'streetRequired';
  static const exteriorNumberRequired = 'exteriorNumberRequired';
  static const postalCodeRequired = 'postalCodeRequired';
  static const neighborhoodRequired = 'neighborhoodRequired';
  static const boroughRequired = 'boroughRequired';
  static const stateRequired = 'stateRequired';
  static const countryRequired = 'countryRequired';
  static const createFailed = 'createFailed';
}

/// Form state for the facility form's inline "new address" dialog
/// (FR-031, FR-032). Scoped to one dialog instance — auto-disposed when the
/// dialog closes, so each opening starts from a blank form.
@freezed
class AddressInlineCreateState with _$AddressInlineCreateState {
  const factory AddressInlineCreateState({
    @Default('') String street,
    @Default('') String exteriorNumber,
    @Default('') String interiorNumber,
    @Default('') String postalCode,
    @Default('') String neighborhood,
    @Default('') String locality,
    @Default('') String borough,
    @Default('') String addressState,
    @Default('') String city,
    @Default('') String country,
    @Default('') String nickname,
    AddressType? type,
    @Default('') String comment,
    @Default(false) bool submitting,
    AddressListItem? created,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _AddressInlineCreateState;
}

/// Manages the inline address-create dialog's form (FR-031, FR-032).
@riverpod
class AddressInlineCreateController extends _$AddressInlineCreateController {
  @override
  AddressInlineCreateState build() => const AddressInlineCreateState();

  void streetChanged(String v) => state = _clearErrors(state.copyWith(street: v));
  void exteriorNumberChanged(String v) =>
      state = _clearErrors(state.copyWith(exteriorNumber: v));
  void interiorNumberChanged(String v) =>
      state = state.copyWith(interiorNumber: v);
  void postalCodeChanged(String v) =>
      state = _clearErrors(state.copyWith(postalCode: v));
  void neighborhoodChanged(String v) =>
      state = _clearErrors(state.copyWith(neighborhood: v));
  void localityChanged(String v) => state = state.copyWith(locality: v);
  void boroughChanged(String v) =>
      state = _clearErrors(state.copyWith(borough: v));
  void addressStateChanged(String v) =>
      state = _clearErrors(state.copyWith(addressState: v));
  void cityChanged(String v) => state = state.copyWith(city: v);
  void countryChanged(String v) =>
      state = _clearErrors(state.copyWith(country: v));
  void nicknameChanged(String v) => state = state.copyWith(nickname: v);
  void typeChanged(AddressType? v) => state = state.copyWith(type: v);
  void commentChanged(String v) => state = state.copyWith(comment: v);

  AddressInlineCreateState _clearErrors(AddressInlineCreateState s) =>
      s.copyWith(error: null, errorDetail: null, fieldErrors: const {});

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.street)) {
      errors['street'] = AddressInlineCreateErrorCode.streetRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.exteriorNumber)) {
      errors['exteriorNumber'] =
          AddressInlineCreateErrorCode.exteriorNumberRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.postalCode)) {
      errors['postalCode'] = AddressInlineCreateErrorCode.postalCodeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.neighborhood)) {
      errors['neighborhood'] =
          AddressInlineCreateErrorCode.neighborhoodRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.borough)) {
      errors['borough'] = AddressInlineCreateErrorCode.boroughRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.addressState)) {
      errors['state'] = AddressInlineCreateErrorCode.stateRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.country)) {
      errors['country'] = AddressInlineCreateErrorCode.countryRequired;
    }
    return errors;
  }

  /// Creates the address (FR-031, FR-032). On success, [AddressInlineCreateState.created]
  /// carries the new [AddressListItem] for the caller (the facility form) to
  /// select. The dialog is responsible for popping itself with that value —
  /// this controller only ever talks to the repository, never `Navigator`.
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
          .read(addressRepositoryProvider)
          .create(
            AddressCreatePayload(
              street: state.street,
              exteriorNumber: state.exteriorNumber,
              interiorNumber: state.interiorNumber.isEmpty
                  ? null
                  : state.interiorNumber,
              postalCode: state.postalCode,
              neighborhood: state.neighborhood,
              locality: state.locality.isEmpty ? null : state.locality,
              borough: state.borough,
              addressState: state.addressState,
              city: state.city.isEmpty ? null : state.city,
              country: state.country,
              nickname: state.nickname.isEmpty ? null : state.nickname,
              type: state.type,
              comment: state.comment.isEmpty ? null : state.comment,
            ),
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
          error: AddressInlineCreateErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
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
