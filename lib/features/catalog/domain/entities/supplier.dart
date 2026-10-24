import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';

part 'supplier.freezed.dart';

/// A vendor a product can be sourced from — full detail entity for the
/// Suppliers catalog (data-model.md §1), mapped from `SupplierResponse` (list rows) or `SupplierDetailResponse`
/// (get/create/update; its addresses/contacts/bank accounts are mapped,
/// agreements are not — they load through their own endpoint). List rows
/// leave the three collections empty.
/// `creditLimit` is kept as `String` end-to-end (research.md §4) — never
/// parsed to `double`. The lightweight `SupplierListItem` (id/code/name)
/// remains the product form's picker item type, unaffected by this entity.
@freezed
abstract class Supplier with _$Supplier {
  const factory Supplier({
    required int supplierId,
    required String code,
    required String name,
    String? zone,
    required String creditLimit,
    required int creditDays,
    String? comment,
    @Default(<AddressListItem>[]) List<AddressListItem> addresses,
    @Default(<Contact>[]) List<Contact> contacts,
    @Default(<BankAccount>[]) List<BankAccount> bankAccounts,
  }) = _Supplier;

  factory Supplier.fromResponse(SupplierResponse response) {
    return Supplier(
      supplierId: response.supplierId,
      code: response.code,
      name: response.name,
      zone: response.zone,
      creditLimit: response.creditLimit,
      creditDays: response.creditDays,
      comment: response.comment,
    );
  }

  factory Supplier.fromDetailResponse(SupplierDetailResponse response) {
    return Supplier(
      supplierId: response.supplierId,
      code: response.code,
      name: response.name,
      zone: response.zone,
      creditLimit: response.creditLimit,
      creditDays: response.creditDays,
      comment: response.comment,
      addresses: (response.addresses ?? const <AddressResponse>[])
          .map(AddressListItem.fromResponse)
          .toList(),
      contacts: (response.contacts ?? const <ContactResponse>[])
          .map(Contact.fromResponse)
          .toList(),
      bankAccounts: (response.bankAccounts ?? const <BankAccountResponse>[])
          .map(BankAccount.fromResponse)
          .toList(),
    );
  }
}
