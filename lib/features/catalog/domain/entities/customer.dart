import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';

part 'customer.freezed.dart';

/// A resolved price-list FK reference, mapped from the expanded
/// `PriceListResponse` embedded in `CustomerResponse`/`CustomerListItem`
/// (data-model.md §4, research.md §7 — response-only expansion; writes send
/// a plain id).
@freezed
class PriceListRef with _$PriceListRef {
  const factory PriceListRef({required int id, required String name}) =
      _PriceListRef;

  factory PriceListRef.fromResponse(PriceListResponse r) =>
      PriceListRef(id: r.priceListId, name: r.name);
}

/// A resolved salesperson (Employee) FK reference, mapped from the expanded
/// `EmployeeResponse` embedded in `CustomerResponse`/`CustomerListItem`.
@freezed
class EmployeeRef with _$EmployeeRef {
  const factory EmployeeRef({required int id, required String name}) =
      _EmployeeRef;

  factory EmployeeRef.fromResponse(EmployeeResponse r) =>
      EmployeeRef(id: r.employeeId, name: '${r.firstName} ${r.lastName}');
}

/// A buyer of goods/services — full detail entity for the Customers catalog
/// (data-model.md §4), mapped from `CustomerResponse`. `creditLimit` is kept
/// as `String` end-to-end (research.md §4). `priceList`/`salesperson` are
/// expanded on read; writes send plain ids (research.md §7).
@freezed
class Customer with _$Customer {
  const factory Customer({
    required int customerId,
    required String code,
    required String name,
    String? zone,
    required String creditLimit,
    required int creditDays,
    required PriceListRef priceList,
    required bool shipping,
    required bool shippingRequiredDocument,
    EmployeeRef? salesperson,
    required EntityStatus status,
    String? comment,
    // Embedded on `GET /customers/{id}` since mbe-api#132/#133 (020-point-of-
    // sale research §9, §10). They back the POS delivery step's address and
    // contact pickers, which is why a plain list of already-expanded records
    // is enough — there is no separate fetch. Empty (not null) when the
    // customer has none, and on list projections, which never include them.
    @Default(<AddressListItem>[]) List<AddressListItem> addresses,
    @Default(<Contact>[]) List<Contact> contacts,
  }) = _Customer;

  factory Customer.fromResponse(CustomerResponse response) {
    return Customer(
      customerId: response.customerId,
      code: response.code,
      name: response.name,
      zone: response.zone,
      creditLimit: response.creditLimit,
      creditDays: response.creditDays,
      priceList: PriceListRef.fromResponse(response.priceList),
      shipping: response.shipping,
      shippingRequiredDocument: response.shippingRequiredDocument,
      salesperson: response.salesperson == null
          ? null
          : EmployeeRef.fromResponse(response.salesperson!),
      status: EntityStatus.fromApi(response.status),
      comment: response.comment,
      addresses: (response.addresses ?? const <AddressResponse>[])
          .map(AddressListItem.fromResponse)
          .toList(),
      contacts: (response.contacts ?? const <ContactResponse>[])
          .map(Contact.fromResponse)
          .toList(),
    );
  }
}
