import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide AddressType;

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/features/catalog/domain/address_formatting.dart';

part 'address_list_item.freezed.dart';

/// A lightweight address projection used by the facility form's address
/// `CatalogEntityPicker` (data-model.md "AddressListItem", FR-031).
@freezed
class AddressListItem with _$AddressListItem {
  const factory AddressListItem({
    required int addressId,
    required String label,
    required AddressType type,
  }) = _AddressListItem;

  factory AddressListItem.fromResponse(AddressResponse r) => AddressListItem(
    addressId: r.addressId,
    label: formatAddress(r),
    type: AddressType.fromApi(r.type),
  );
}

/// The fields the inline address-create dialog collects (FR-031, FR-032),
/// mirroring `AddressCreate`'s required/optional split exactly so the
/// repository can pass it straight through to `AddressesApi.create`.
class AddressCreatePayload {
  const AddressCreatePayload({
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    required this.postalCode,
    required this.neighborhood,
    this.locality,
    required this.borough,
    // Named `addressState`, not `state` — this value object is held inside
    // a Riverpod `Notifier`'s own `state`, and `state.state` would read
    // ambiguously at every call site.
    required this.addressState,
    this.city,
    required this.country,
    this.nickname,
    this.type,
    this.comment,
  });

  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String postalCode;
  final String neighborhood;
  final String? locality;
  final String borough;
  final String addressState;
  final String? city;
  final String country;
  final String? nickname;
  final AddressType? type;
  final String? comment;
}
