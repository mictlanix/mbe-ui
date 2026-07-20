import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/expense.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(dioProvider));
});

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(Dio dio) : _api = ExpensesApi(dio, standardSerializers);

  final ExpensesApi _api;

  @override
  Future<ExpenseListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listExpensesApiV1ExpensesGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return ExpenseListResult(
        items: result.items.map(Expense.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Expense> get({required int expenseId}) async {
    try {
      final response = await _api.getExpenseApiV1ExpensesExpenseIdGet(
        expenseId: expenseId,
      );
      final expense = response.data;
      if (expense == null) throw const AppError.server();
      return Expense.fromResponse(expense);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Expense> create({required String name, String? comment}) async {
    try {
      final response = await _api.createExpenseApiV1ExpensesPost(
        expenseCreate: ExpenseCreate((b) {
          b
            ..name = name
            ..comment = comment;
        }),
      );
      final expense = response.data;
      if (expense == null) throw const AppError.server();
      return Expense.fromResponse(expense);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Expense> update({
    required int expenseId,
    String? name,
    String? comment,
  }) async {
    try {
      final response = await _api.updateExpenseApiV1ExpensesExpenseIdPut(
        expenseId: expenseId,
        expenseUpdate: ExpenseUpdate((b) {
          if (name != null) b.name = name;
          if (comment != null) b.comment = comment;
        }),
      );
      final expense = response.data;
      if (expense == null) throw const AppError.server();
      return Expense.fromResponse(expense);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int expenseId}) async {
    try {
      await _api.deleteExpenseApiV1ExpensesExpenseIdDelete(
        expenseId: expenseId,
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
