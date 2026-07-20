import 'package:mbe_ui/features/catalog/domain/entities/expense.dart';

/// Expense lookup and full CRUD management (data-model.md §1,
/// contracts/mbe-api-catalogs.md §1). Unlike Labels, Expenses has no external
/// picker/filter consumer, so a single `list` projection covers both the
/// catalog's own list screen and any future need (research.md §3).
abstract class ExpenseRepository {
  Future<ExpenseListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  Future<Expense> get({required int expenseId});

  Future<Expense> create({required String name, String? comment});

  Future<Expense> update({
    required int expenseId,
    String? name,
    String? comment,
  });

  Future<void> delete({required int expenseId});
}

class ExpenseListResult {
  const ExpenseListResult({required this.items, required this.total});
  final List<Expense> items;
  final int total;
}
