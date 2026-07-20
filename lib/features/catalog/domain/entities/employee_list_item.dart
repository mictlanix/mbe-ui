import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

part 'employee_list_item.freezed.dart';

/// A lightweight employee projection used by the Employees list and by the
/// Customer form's salesperson `CatalogEntityPicker` (data-model.md §3).
@freezed
class EmployeeListItem with _$EmployeeListItem {
  const factory EmployeeListItem({
    required int employeeId,
    required String fullName,
    required String nickname,
    required EntityStatus status,
    required bool salesPerson,
  }) = _EmployeeListItem;

  factory EmployeeListItem.fromResponse(EmployeeResponse r) => EmployeeListItem(
    employeeId: r.employeeId,
    fullName: '${r.firstName} ${r.lastName}',
    nickname: r.nickname,
    status: EntityStatus.fromApi(r.status),
    salesPerson: r.salesPerson,
  );
}
