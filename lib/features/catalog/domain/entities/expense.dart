import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'expense.freezed.dart';

/// A named expense concept used to classify outgoing costs — full detail
/// entity for the Expenses catalog (data-model.md §1), mapped from
/// `ExpenseResponse`. The response's display field is named `expense`; it is
/// normalized to `name` here for consistency with create/update and every
/// other catalog entity (research.md §3).
@freezed
class Expense with _$Expense {
  const factory Expense({
    required int expenseId,
    required String name,
    String? comment,
  }) = _Expense;

  factory Expense.fromResponse(ExpenseResponse response) {
    return Expense(
      expenseId: response.expenseId,
      name: response.expense,
      comment: response.comment,
    );
  }
}
