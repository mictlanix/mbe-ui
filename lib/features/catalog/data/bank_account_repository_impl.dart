import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/bank_account_repository.dart';

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  return BankAccountRepositoryImpl(ref.watch(dioProvider));
});

class BankAccountRepositoryImpl implements BankAccountRepository {
  BankAccountRepositoryImpl(Dio dio)
    : _api = BankAccountsApi(dio, appSerializers);

  final BankAccountsApi _api;

  @override
  Future<BankAccountListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listBankAccountsApiV1BankAccountsGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return BankAccountListResult(
        items: result.items.map(BankAccount.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<BankAccount> create({
    required String bankName,
    required String accountNumber,
    String? reference,
    String? routingNumber,
    String? comment,
  }) async {
    try {
      final response = await _api.createBankAccountApiV1BankAccountsPost(
        bankAccountCreate: BankAccountCreate((b) {
          b
            ..bankName = bankName
            ..accountNumber = accountNumber
            ..reference = reference
            ..routingNumber = routingNumber
            ..comment = comment;
        }),
      );
      final account = response.data;
      if (account == null) throw const AppError.server();
      return BankAccount.fromResponse(account);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
