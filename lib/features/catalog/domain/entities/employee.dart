import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/domain/gender.dart';

part 'employee.freezed.dart';

/// A staff member — full detail entity for the Employees catalog
/// (data-model.md §3), mapped from `EmployeeResponse`. `birthday`/
/// `startJobDate` are the generated `Date` (y/m/d) on the wire, represented
/// here as `DateTime` for use with `showDatePicker`/`intl` formatting.
///
/// `EmployeeResponse.disabled` is deliberately NOT mapped (spec 012
/// `/speckit-analyze` finding U1): it duplicates `active` with no documented
/// distinction between the two — see data-model.md §3.
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
    required bool active,
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
      active: response.active,
      personalId: response.personalId,
      startJobDate: response.startJobDate.toDateTime(),
      enrollNumber: response.enrollNumber,
      comment: response.comment,
    );
  }
}
