import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/customers_list_controller.dart';

part 'customer_form_controller.freezed.dart';
part 'customer_form_controller.g.dart';

/// SAT's RFC for the general public — the only taxpayer recipient the
/// walk-in customer (`AppSettings.posDefaultCustomerId`) may carry
/// (046-catalog-improvements FR-021).
const genericTaxpayerRfc = 'XAXX010101000';

/// Error codes for [CustomerFormState.error]/`fieldErrors`, localized in the
/// UI layer.
abstract final class CustomerFormErrorCode {
  static const nameRequired = 'nameRequired';
  static const priceListRequired = 'priceListRequired';
  static const creditLimitInvalid = 'creditLimitInvalid';
  static const creditDaysInvalid = 'creditDaysInvalid';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single customer. [customerId] is `null` in
/// create mode. `priceListId`/`salespersonId` are set by the form's
/// `CatalogEntityPicker`s (FR-020); their display-text fields pre-fill the
/// picker when editing an existing customer.
///
/// [addresses], [contacts] and [taxpayers] are the customer's complete link
/// sets (046-catalog-improvements data-model §1). Each save sends all three
/// as replace-all id lists, so a link changes only when the user adds or
/// removes it here — and a customer with several RFCs keeps all of them.
@freezed
abstract class CustomerFormState with _$CustomerFormState {
  const factory CustomerFormState({
    int? customerId,
    @Default('') String code,
    @Default('') String name,
    @Default('') String zone,
    @Default('') String creditLimit,
    @Default('') String creditDays,
    int? priceListId,
    @Default('') String priceListDisplayText,
    int? salespersonId,
    @Default('') String salespersonDisplayText,

    @Default(<AddressListItem>[]) List<AddressListItem> addresses,
    @Default(<Contact>[]) List<Contact> contacts,
    @Default(<TaxpayerRecipientListItem>[])
    List<TaxpayerRecipientListItem> taxpayers,
    @Default(EntityStatus.active) EntityStatus status,
    @Default('') String comment,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _CustomerFormState;
}

/// Manages the create/edit customer form (FR-018, FR-019, FR-020).
///
/// A family keyed by customer id (`null` for a create), so each customer
/// screen — and each create — gets its own state. A closing screen and a new
/// create therefore never share a form (mbe-ui#207, spec 052 R8).
@riverpod
class CustomerFormController extends _$CustomerFormController {
  @override
  CustomerFormState build(int? customerId) => const CustomerFormState();

  void codeChanged(String v) => state = state.copyWith(
    code: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void nameChanged(String v) => state = state.copyWith(
    name: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void zoneChanged(String v) => state = state.copyWith(zone: v);

  void creditLimitChanged(String v) => state = state.copyWith(
    creditLimit: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void creditDaysChanged(String v) => state = state.copyWith(
    creditDays: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void priceListSelected(int id, String displayText) => state = state.copyWith(
    priceListId: id,
    priceListDisplayText: displayText,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void salespersonSelected(int? id, String displayText) => state = state
      .copyWith(salespersonId: id, salespersonDisplayText: displayText);

  /// The POS quick-create's single RFC picker (research R4): replaces the
  /// whole set with exactly [id], or clears it when [id] is `null`.
  void taxpayerSelected(String? id, String displayText) =>
      state = state.copyWith(
        taxpayers: id == null
            ? const []
            : [
                TaxpayerRecipientListItem(
                  taxpayerRecipientId: id,
                  name: displayText,
                  email: '',
                ),
              ],
      );

  /// Whether the loaded customer is the walk-in customer, whose links are
  /// fixed: nothing can be linked to it, and its only RFC is
  /// [genericTaxpayerRfc] (FR-021).
  bool get isGenericCustomer {
    final id = state.customerId;
    return id != null && ref.read(appSettingsProvider).isGenericCustomer(id);
  }

  void addressAdded(AddressListItem address) {
    if (isGenericCustomer) return;
    if (state.addresses.any((a) => a.addressId == address.addressId)) return;
    state = _clear(state.copyWith(addresses: [...state.addresses, address]));
  }

  void addressRemoved(int addressId) => state = _clear(
    state.copyWith(
      addresses: [
        for (final a in state.addresses)
          if (a.addressId != addressId) a,
      ],
    ),
  );

  void contactAdded(Contact contact) {
    if (isGenericCustomer) return;
    if (state.contacts.any((c) => c.contactId == contact.contactId)) return;
    state = _clear(state.copyWith(contacts: [...state.contacts, contact]));
  }

  void contactRemoved(int contactId) => state = _clear(
    state.copyWith(
      contacts: [
        for (final c in state.contacts)
          if (c.contactId != contactId) c,
      ],
    ),
  );

  void taxpayerAdded(TaxpayerRecipientListItem taxpayer) {
    if (isGenericCustomer) return;
    final rfc = taxpayer.taxpayerRecipientId;
    if (state.taxpayers.any((t) => t.taxpayerRecipientId == rfc)) return;
    state = _clear(state.copyWith(taxpayers: [...state.taxpayers, taxpayer]));
  }

  void taxpayerRemoved(String rfc) {
    if (isGenericCustomer) return;
    state = _clear(
      state.copyWith(
        taxpayers: [
          for (final t in state.taxpayers)
            if (t.taxpayerRecipientId != rfc) t,
        ],
      ),
    );
  }

  CustomerFormState _clear(CustomerFormState s) =>
      s.copyWith(error: null, errorDetail: null, fieldErrors: const {});

  void statusChanged(EntityStatus v) => state = state.copyWith(status: v);

  void commentChanged(String v) => state = state.copyWith(comment: v);

  /// Loads an existing customer into the form for viewing/editing.
  Future<void> loadForEdit(int customerId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final customer = await ref
          .read(customerRepositoryProvider)
          .get(customerId: customerId);
      state = CustomerFormState(
        customerId: customer.customerId,
        code: customer.code,
        name: customer.name,
        zone: customer.zone ?? '',
        creditLimit: customer.creditLimit,
        creditDays: customer.creditDays.toString(),
        priceListId: customer.priceList.id,
        priceListDisplayText: customer.priceList.name,
        salespersonId: customer.salesperson?.id,
        salespersonDisplayText: customer.salesperson?.name ?? '',
        addresses: customer.addresses,
        contacts: customer.contacts,
        taxpayers: [
          for (final t in customer.taxpayers)
            TaxpayerRecipientListItem.fromRecipient(t),
        ],
        status: customer.status,
        comment: customer.comment ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: CustomerFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation (FR-019). `code` is intentionally not validated
  /// here — spec 036 FR-011 makes it optional, since the business does not
  /// assign one at intake.
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = CustomerFormErrorCode.nameRequired;
    }
    if (state.priceListId == null) {
      errors['priceList'] = CustomerFormErrorCode.priceListRequired;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeDecimal(
      state.creditLimit,
    )) {
      errors['creditLimit'] = CustomerFormErrorCode.creditLimitInvalid;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeInteger(
      state.creditDays,
    )) {
      errors['creditDays'] = CustomerFormErrorCode.creditDaysInvalid;
    }
    return errors;
  }

  /// Creates the customer (FR-018, FR-019). Re-checks the caller's
  /// `customers` create privilege immediately before submitting.
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
        .can(SystemObject.customers, AccessRight.create)) {
      state = state.copyWith(
        error: CustomerFormErrorCode.createPermissionDenied,
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
      final created = await ref
          .read(customerRepositoryProvider)
          .create(
            // spec 036 FR-011 (mbe-api#198): a blank code omits the field
            // entirely rather than sending `""`.
            code: _orNull(state.code),
            name: state.name,
            priceList: state.priceListId!,
            zone: _orNull(state.zone),
            creditLimit: _orNull(state.creditLimit),
            creditDays: _orNullInt(state.creditDays),
            salesperson: state.salespersonId,
            comment: _orNull(state.comment),
            // A new customer has no links to keep, so an empty set is simply
            // left out rather than sent as `[]`.
            addresses: _orNullList(_addressIdsOf(state)),
            contacts: _orNullList(_contactIdsOf(state)),
            taxpayers: _orNullList(_taxpayerIdsOf(state)),
          );
      ref.invalidate(customersListControllerProvider);
      // Recording the new id lets a caller act on the customer it just
      // created — the POS attaches it to the open sale (020 FR-014).
      state = state.copyWith(
        submitting: false,
        saved: true,
        customerId: created.customerId,
      );
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: CustomerFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded customer. No-ops if no customer has been
  /// loaded.
  Future<void> submitUpdate() async {
    final customerId = state.customerId;
    if (customerId == null) return;

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
        .can(SystemObject.customers, AccessRight.update)) {
      state = state.copyWith(
        error: CustomerFormErrorCode.updatePermissionDenied,
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
          .read(customerRepositoryProvider)
          .update(
            customerId: customerId,
            // A blank `code` omits the field rather than sending `""` — an
            // empty code left in place is preferable to overwriting one that
            // was set some other way (FR-011).
            code: _orNull(state.code),
            name: state.name,
            priceList: state.priceListId,
            zone: state.zone,
            creditLimit: _orNull(state.creditLimit) ?? '',
            creditDays: _orNullInt(state.creditDays),
            salesperson: state.salespersonId,
            status: state.status,
            comment: state.comment,
            addresses: _addressIdsOf(state),
            contacts: _contactIdsOf(state),
            // The walk-in customer's RFC is fixed; saving it also corrects
            // any other RFC it was carrying (FR-021).
            taxpayers: isGenericCustomer
                ? const [genericTaxpayerRfc]
                : _taxpayerIdsOf(state),
          );
      ref.invalidate(customersListControllerProvider);
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
          error: CustomerFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded customer. No-ops if no customer has been loaded. A
  /// server rejection (e.g. existing sales orders) is surfaced via
  /// `error`/`errorDetail`, leaving the customer in place.
  Future<void> delete() async {
    final customerId = state.customerId;
    if (customerId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.customers, AccessRight.delete)) {
      state = state.copyWith(
        error: CustomerFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(customerRepositoryProvider).delete(customerId: customerId);
      ref.invalidate(customersListControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: CustomerFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
    }
  }
}

String? _orNull(String value) => value.isEmpty ? null : value;

// On update the three link lists are always sent complete: mbe-api treats
// each as replace-all, and the form holds the full set (loaded by
// `loadForEdit`), so sending it unchanged leaves the links as they were — and
// sending `[]` is how the last link is removed.
List<int> _addressIdsOf(CustomerFormState state) => [
  for (final a in state.addresses) a.addressId,
];

List<int> _contactIdsOf(CustomerFormState state) => [
  for (final c in state.contacts) c.contactId,
];

List<String> _taxpayerIdsOf(CustomerFormState state) => [
  for (final t in state.taxpayers) t.taxpayerRecipientId,
];

int? _orNullInt(String value) => value.isEmpty ? null : int.tryParse(value);

List<T>? _orNullList<T>(List<T> value) => value.isEmpty ? null : value;

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
