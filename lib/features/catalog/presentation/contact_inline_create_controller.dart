import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';

part 'contact_inline_create_controller.freezed.dart';
part 'contact_inline_create_controller.g.dart';

/// Error codes for [ContactInlineCreateState], localized in the UI layer —
/// same split as `AddressInlineCreateErrorCode`.
abstract final class ContactInlineCreateErrorCode {
  static const nameRequired = 'nameRequired';
  static const contactMethodRequired = 'contactMethodRequired';
  static const createFailed = 'createFailed';
}

/// Form state for the delivery step's inline "new contact" dialog (FR-031).
/// Scoped to one dialog instance — auto-disposed when it closes, so each
/// opening starts blank.
@freezed
class ContactInlineCreateState with _$ContactInlineCreateState {
  const factory ContactInlineCreateState({
    @Default('') String name,
    @Default('') String jobTitle,
    @Default('') String phone,
    @Default('') String mobile,
    @Default('') String email,
    @Default(false) bool submitting,
    Contact? created,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _ContactInlineCreateState;
}

@riverpod
class ContactInlineCreateController extends _$ContactInlineCreateController {
  @override
  ContactInlineCreateState build() => const ContactInlineCreateState();

  void nameChanged(String v) => state = _clearErrors(state.copyWith(name: v));
  void jobTitleChanged(String v) => state = state.copyWith(jobTitle: v);
  void phoneChanged(String v) => state = _clearErrors(state.copyWith(phone: v));
  void mobileChanged(String v) => state = _clearErrors(state.copyWith(mobile: v));
  void emailChanged(String v) => state = state.copyWith(email: v);

  Future<void> submit() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(fieldErrors: fieldErrors, error: null, errorDetail: null);
      return;
    }

    state = _clearErrors(state).copyWith(submitting: true);
    try {
      final created = await ref
          .read(contactRepositoryProvider)
          .create(
            name: state.name.trim(),
            jobTitle: state.jobTitle.isEmpty ? null : state.jobTitle.trim(),
            phone: state.phone.isEmpty ? null : state.phone.trim(),
            mobile: state.mobile.isEmpty ? null : state.mobile.trim(),
            email: state.email.isEmpty ? null : state.email.trim(),
          );
      state = state.copyWith(submitting: false, created: created);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(submitting: false, fieldErrors: _fieldErrorsFromServer(e));
      } else {
        state = state.copyWith(
          submitting: false,
          error: ContactInlineCreateErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// A contact with no number is useless to a driver, so at least one of
  /// phone/mobile is required here even though mbe-api accepts neither.
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.name.trim().isEmpty) {
      errors['name'] = ContactInlineCreateErrorCode.nameRequired;
    }
    if (state.phone.trim().isEmpty && state.mobile.trim().isEmpty) {
      errors['mobile'] = ContactInlineCreateErrorCode.contactMethodRequired;
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

  ContactInlineCreateState _clearErrors(ContactInlineCreateState next) =>
      next.copyWith(error: null, errorDetail: null, fieldErrors: const {});
}
