import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';

/// Employee lookup and full CRUD management (data-model.md §3,
/// contracts/mbe-api-catalogs.md §3). `list` serves both the Employees
/// catalog's own list screen (US3, whose columns are exactly name/active/
/// salesPerson) and the Customer form's salesperson `CatalogEntityPicker`
/// (US4) — one projection covers both, unlike Suppliers/Labels which needed
/// a richer catalog-only projection.
abstract class EmployeeRepository {
  Future<EmployeeListResult> list({
    String? search,
    bool? active,
    bool? salesPerson,
    int skip = 0,
    int limit = 20,
  });

  Future<Employee> get({required int employeeId});

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
  });

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
  });

  Future<void> delete({required int employeeId});
}

class EmployeeListResult {
  const EmployeeListResult({required this.items, required this.total});
  final List<EmployeeListItem> items;
  final int total;
}
