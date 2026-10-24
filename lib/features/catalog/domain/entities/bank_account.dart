import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'bank_account.freezed.dart';

/// A bank account a supplier can be paid into (data-model.md), mapped from
/// `BankAccountResponse`. Audit fields are on the wire but not surfaced.
@freezed
abstract class BankAccount with _$BankAccount {
  const BankAccount._();

  const factory BankAccount({
    required int bankAccountId,
    required String bankName,
    required String accountNumber,
    String? reference,
    String? routingNumber,
    String? comment,
  }) = _BankAccount;

  factory BankAccount.fromResponse(BankAccountResponse r) => BankAccount(
    bankAccountId: r.bankAccountId,
    bankName: r.bankName,
    accountNumber: r.accountNumber,
    reference: r.reference,
    routingNumber: r.routingNumber,
    comment: r.comment,
  );

  /// How an account reads in a picker row or on a chip.
  String get label => '$bankName · $accountNumber';
}
