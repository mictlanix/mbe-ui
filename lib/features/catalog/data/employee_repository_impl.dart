import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(ref.watch(dioProvider));
});

class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl(Dio dio)
    : _api = EmployeesApi(dio, standardSerializers);

  final EmployeesApi _api;

  @override
  Future<EmployeeListResult> list({
    String? search,
    bool? active,
    bool? salesPerson,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listEmployeesApiV1EmployeesGet(
        search: search,
        active: active,
        salesPerson: salesPerson,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return EmployeeListResult(
        items: result.items.map(EmployeeListItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Employee> get({required int employeeId}) async {
    try {
      final response = await _api.getEmployeeApiV1EmployeesEmployeeIdGet(
        employeeId: employeeId,
      );
      final employee = response.data;
      if (employee == null) throw const AppError.server();
      return Employee.fromResponse(employee);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Employee> create({
    required String firstName,
    required String lastName,
    required String nickname,
    required int gender,
    required DateTime birthday,
    required DateTime startJobDate,
    String? taxpayerId,
    bool? salesPerson,
    bool? active,
    String? personalId,
    int? enrollNumber,
    String? comment,
  }) async {
    try {
      final response = await _api.createEmployeeApiV1EmployeesPost(
        employeeCreate: EmployeeCreate((b) {
          b
            ..firstName = firstName
            ..lastName = lastName
            ..nickname = nickname
            ..gender = gender
            ..birthday = birthday.toDate()
            ..startJobDate = startJobDate.toDate()
            ..taxpayerId = taxpayerId
            ..salesPerson = salesPerson
            ..active = active
            ..personalId = personalId
            ..enrollNumber = enrollNumber
            ..comment = comment;
        }),
      );
      final employee = response.data;
      if (employee == null) throw const AppError.server();
      return Employee.fromResponse(employee);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Employee> update({
    required int employeeId,
    String? firstName,
    String? lastName,
    String? nickname,
    int? gender,
    DateTime? birthday,
    DateTime? startJobDate,
    String? taxpayerId,
    bool? salesPerson,
    bool? active,
    String? personalId,
    int? enrollNumber,
    String? comment,
  }) async {
    try {
      final response = await _api.updateEmployeeApiV1EmployeesEmployeeIdPut(
        employeeId: employeeId,
        employeeUpdate: EmployeeUpdate((b) {
          if (firstName != null) b.firstName = firstName;
          if (lastName != null) b.lastName = lastName;
          if (nickname != null) b.nickname = nickname;
          if (gender != null) b.gender = gender;
          if (birthday != null) b.birthday = birthday.toDate();
          if (startJobDate != null) b.startJobDate = startJobDate.toDate();
          if (taxpayerId != null) b.taxpayerId = taxpayerId;
          if (salesPerson != null) b.salesPerson = salesPerson;
          if (active != null) b.active = active;
          if (personalId != null) b.personalId = personalId;
          if (enrollNumber != null) b.enrollNumber = enrollNumber;
          if (comment != null) b.comment = comment;
        }),
      );
      final employee = response.data;
      if (employee == null) throw const AppError.server();
      return Employee.fromResponse(employee);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int employeeId}) async {
    try {
      await _api.deleteEmployeeApiV1EmployeesEmployeeIdDelete(
        employeeId: employeeId,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
