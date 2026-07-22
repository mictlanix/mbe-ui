import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_controller.dart';

part 'facility_form_controller.freezed.dart';
part 'facility_form_controller.g.dart';

/// Error codes for [FacilityFormState.error]/`fieldErrors`, localized in the
/// UI layer.
abstract final class FacilityFormErrorCode {
  static const codeRequired = 'codeRequired';
  static const nameRequired = 'nameRequired';
  static const locationRequired = 'locationRequired';
  static const addressRequired = 'addressRequired';
  static const taxpayerRequired = 'taxpayerRequired';
  static const taxpayerInvalid = 'taxpayerInvalid';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single facility. [facilityId] is `null` in
/// create mode. FK fields are held as `id?` + `displayText` pairs.
@freezed
class FacilityFormState with _$FacilityFormState {
  const factory FacilityFormState({
    int? facilityId,
    @Default('') String code,
    @Default('') String name,
    @Default(FacilityType.store) FacilityType type,
    String? locationId,
    @Default('') String locationDisplayText,
    int? addressId,
    @Default('') String addressDisplayText,

    /// The stored issuer RFC (FR-034). Empty until a taxpayer is picked (or
    /// typed, in the read-denied fallback).
    @Default('') String taxpayerRfc,

    /// The issuer display name resolved on load (FR-034b); the taxpayer field
    /// shows `taxpayerDisplayText`, which the detail screen prefers over the
    /// bare [taxpayerRfc].
    @Default('') String taxpayerDisplayText,
    @Default('') String logo,
    @Default('') String receiptMessage,
    @Default('') String defaultBatch,
    @Default(EntityStatus.active) EntityStatus status,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _FacilityFormState;
}

/// Manages the create/edit facility form (FR-028 – FR-035).
@riverpod
class FacilityFormController extends _$FacilityFormController {
  @override
  FacilityFormState build() => const FacilityFormState();

  void codeChanged(String v) => state = _clear(state.copyWith(code: v));
  void nameChanged(String v) => state = _clear(state.copyWith(name: v));
  void typeChanged(FacilityType v) => state = state.copyWith(type: v);

  void locationSelected(String locationId, String label) => state = _clear(
    state.copyWith(locationId: locationId, locationDisplayText: label),
  );

  void addressSelected(int addressId, String label) => state = _clear(
    state.copyWith(addressId: addressId, addressDisplayText: label),
  );

  /// FR-034: a taxpayer picked from the autocomplete. Stores the issuer RFC
  /// and the display name shown in the field.
  void taxpayerSelected(String rfc, String displayText) => state = _clear(
    state.copyWith(taxpayerRfc: rfc, taxpayerDisplayText: displayText),
  );

  /// FR-034 read-denied fallback: the field degrades to a typed RFC entry.
  /// The typed value is both the stored RFC and its own display text.
  void taxpayerRfcTyped(String rfc) =>
      state = _clear(state.copyWith(taxpayerRfc: rfc, taxpayerDisplayText: rfc));

  void logoChanged(String v) => state = state.copyWith(logo: v);
  void receiptMessageChanged(String v) =>
      state = state.copyWith(receiptMessage: v);
  void defaultBatchChanged(String v) =>
      state = state.copyWith(defaultBatch: v);
  void statusChanged(EntityStatus v) => state = state.copyWith(status: v);

  FacilityFormState _clear(FacilityFormState s) =>
      s.copyWith(error: null, errorDetail: null, fieldErrors: const {});

  /// Loads an existing facility for viewing/editing. Resolves the stored
  /// taxpayer RFC to a display name via `TaxpayerIssuersApi.get` (FR-034b)
  /// when the user can read taxpayers — a single request, never per row.
  /// Falls back to the bare RFC when the read is denied or the issuer is
  /// unresolvable, so the field is never blank.
  Future<void> loadForEdit(int facilityId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final facility = await ref
          .read(facilityRepositoryProvider)
          .get(facilityId: facilityId);

      var taxpayerDisplay = facility.taxpayerRfc;
      if (ref
          .read(accessControlProvider)
          .can(SystemObject.taxpayers, AccessRight.read)) {
        try {
          final issuer = await ref
              .read(taxpayerIssuerRepositoryProvider)
              .get(facility.taxpayerRfc);
          if (issuer != null &&
              issuer.name != null &&
              issuer.name!.isNotEmpty) {
            taxpayerDisplay = issuer.name!;
          }
        } on AppError {
          // Resolution is best-effort; a failure leaves the RFC as the
          // display text (FR-034b) rather than failing the whole load.
        }
      }

      state = FacilityFormState(
        facilityId: facility.facilityId,
        code: facility.code,
        name: facility.name,
        type: facility.type,
        locationId: facility.locationId,
        locationDisplayText: facility.locationLabel,
        addressId: facility.addressId,
        addressDisplayText: facility.addressLabel,
        taxpayerRfc: facility.taxpayerRfc,
        taxpayerDisplayText: taxpayerDisplay,
        logo: facility.logo ?? '',
        receiptMessage: facility.receiptMessage ?? '',
        defaultBatch: facility.defaultBatch ?? '',
        status: facility.status,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: FacilityFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.code)) {
      errors['code'] = FacilityFormErrorCode.codeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = FacilityFormErrorCode.nameRequired;
    }
    if (state.locationId == null) {
      errors['location'] = FacilityFormErrorCode.locationRequired;
    }
    if (state.addressId == null) {
      errors['address'] = FacilityFormErrorCode.addressRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.taxpayerRfc)) {
      errors['taxpayer'] = FacilityFormErrorCode.taxpayerRequired;
    } else if (!CatalogFieldValidators.isValidRfcShape(state.taxpayerRfc)) {
      errors['taxpayer'] = FacilityFormErrorCode.taxpayerInvalid;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(facilitiesListControllerProvider);
  }

  /// Creates the facility (FR-028, FR-029). Re-checks create privilege
  /// immediately before submitting.
  Future<void> submitCreate() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(fieldErrors: fieldErrors, error: null);
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.facilities, AccessRight.create)) {
      state = state.copyWith(
        error: FacilityFormErrorCode.createPermissionDenied,
      );
      return;
    }

    state = _clear(state).copyWith(submitting: true);
    try {
      await ref
          .read(facilityRepositoryProvider)
          .create(
            code: state.code,
            name: state.name,
            type: state.type,
            location: state.locationId!,
            address: state.addressId!,
            taxpayer: state.taxpayerRfc,
            logo: state.logo.isEmpty ? null : state.logo,
            receiptMessage: state.receiptMessage.isEmpty
                ? null
                : state.receiptMessage,
            defaultBatch: state.defaultBatch.isEmpty
                ? null
                : state.defaultBatch,
            status: state.status,
          );
      _invalidateCaches();
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      _handleSaveError(e, FacilityFormErrorCode.createFailed);
    }
  }

  /// Saves edits to the loaded facility. No-ops if none has been loaded.
  Future<void> submitUpdate() async {
    final facilityId = state.facilityId;
    if (facilityId == null) return;

    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(fieldErrors: fieldErrors, error: null);
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.facilities, AccessRight.update)) {
      state = state.copyWith(
        error: FacilityFormErrorCode.updatePermissionDenied,
      );
      return;
    }

    state = _clear(state).copyWith(submitting: true);
    try {
      await ref
          .read(facilityRepositoryProvider)
          .update(
            facilityId: facilityId,
            code: state.code,
            name: state.name,
            type: state.type,
            location: state.locationId,
            address: state.addressId,
            taxpayer: state.taxpayerRfc,
            logo: state.logo,
            receiptMessage: state.receiptMessage,
            defaultBatch: state.defaultBatch,
            status: state.status,
          );
      _invalidateCaches();
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      _handleSaveError(e, FacilityFormErrorCode.updateFailed);
    }
  }

  void _handleSaveError(AppError e, String failCode) {
    if (e is ValidationError) {
      state = state.copyWith(
        submitting: false,
        fieldErrors: _fieldErrorsFromServer(e),
      );
    } else {
      state = state.copyWith(
        submitting: false,
        error: failCode,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Deletes the loaded facility (FR-007). A server rejection (e.g. a
  /// facility still referenced by a warehouse) is surfaced, leaving the
  /// record in place.
  Future<void> delete() async {
    final facilityId = state.facilityId;
    if (facilityId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.facilities, AccessRight.delete)) {
      state = state.copyWith(
        error: FacilityFormErrorCode.deletePermissionDenied,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(facilityRepositoryProvider)
          .delete(facilityId: facilityId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: FacilityFormErrorCode.deleteFailed,
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
