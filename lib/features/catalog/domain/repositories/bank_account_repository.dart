import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';

/// Bank account lookup and creation — deliberately **not** full CRUD, like
/// `AddressRepository`. [list] backs the supplier form's bank-account picker;
/// [create] backs its inline-create dialog. Bank accounts have no screens of
/// their own.
abstract class BankAccountRepository {
  Future<BankAccountListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  Future<BankAccount> create({
    required String bankName,
    required String accountNumber,
    String? reference,
    String? routingNumber,
    String? comment,
  });
}

class BankAccountListResult {
  const BankAccountListResult({required this.items, required this.total});
  final List<BankAccount> items;
  final int total;
}
