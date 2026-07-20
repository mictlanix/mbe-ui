import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

import 'package:mbe_ui/core/domain/gender.dart';

part 'employee.freezed.dart';

/// A staff member — full detail entity for the Employees catalog
/// (data-model.md §3), mapped from `EmployeeResponse`. `birthday`/
/// `startJobDate` are the generated `Date` (y/m/d) on the wire, represented
/// here as `DateTime` for use with `showDatePicker`/`intl` formatting.
///
/// The old `active`/`disabled` duplication (spec 012 `/speckit-analyze`
/// finding U1) is gone: mbe-api#80 collapsed both into the single [status]
/// field shared by every catalog entity.
@freezed
class Employee with _$Employee {
  const factory Employee({
    required int employeeId,
    required String firstName,
    required String lastName,
    required String nickname,
    required Gender? gender,
    required DateTime birthday,
    String? taxpayerId,
    required bool salesPerson,
    required EntityStatus status,
    String? personalId,
    required DateTime startJobDate,
    int? enrollNumber,
    String? comment,
  }) = _Employee;

  factory Employee.fromResponse(EmployeeResponse response) {
    return Employee(
      employeeId: response.employeeId,
      firstName: response.firstName,
      lastName: response.lastName,
      nickname: response.nickname,
      gender: Gender.fromValue(response.gender),
      birthday: response.birthday.toDateTime(),
      taxpayerId: response.taxpayerId,
      salesPerson: response.salesPerson,
      status: EntityStatus.fromApi(response.status),
      personalId: response.personalId,
      startJobDate: response.startJobDate.toDateTime(),
      enrollNumber: response.enrollNumber,
      comment: response.comment,
    );
  }
}
