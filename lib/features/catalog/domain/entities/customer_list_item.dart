import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as mbe_api;

import 'package:mbe_ui/core/domain/entity_status.dart';

import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';

part 'customer_list_item.freezed.dart';

/// A customer search-result row for the Customers catalog list
/// (data-model.md §4), mapped from `CustomerListItem` (the generated DTO of
/// the same name — this is the domain-layer projection).
@freezed
class CustomerListItem with _$CustomerListItem {
  const factory CustomerListItem({
    required int customerId,
    required String code,
    required String name,
    String? zone,
    required String creditLimit,
    required int creditDays,
    required PriceListRef priceList,
    EmployeeRef? salesperson,
    required EntityStatus status,
  }) = _CustomerListItem;

  factory CustomerListItem.fromResponse(mbe_api.CustomerListItem r) {
    return CustomerListItem(
      customerId: r.customerId,
      code: r.code,
      name: r.name,
      zone: r.zone,
      creditLimit: r.creditLimit,
      creditDays: r.creditDays,
      priceList: PriceListRef.fromResponse(r.priceList),
      salesperson: r.salesperson == null
          ? null
          : EmployeeRef.fromResponse(r.salesperson!),
      status: EntityStatus.fromApi(r.status),
    );
  }
}
