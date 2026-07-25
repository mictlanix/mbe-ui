import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';

/// Payment Method Option lookup and full CRUD management (data-model.md §1,
/// contracts/mbe-api-catalogs.md §1, US1). [list]'s `facilityId`/`status`
/// params back the list screen's filter drawer (FR-002). The generated list
/// endpoint exposes no `search` param — [search] is wired to the expected
/// upstream capability regardless (research §15); until it ships, passing a
/// non-null [search] has no server-side effect.
abstract class PaymentMethodOptionRepository {
  Future<PaymentMethodOptionPage> list({
    String? search,
    int? facilityId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  });

  Future<PaymentMethodOption> get({required int paymentMethodOptionId});

  Future<PaymentMethodOption> create({
    required int facilityId,
    int? warehouseId,
    required String name,
    int? numberOfPayments,
    bool? displayOnTicket,
    required int paymentMethod,
    String? commission,
    EntityStatus? status,
  });

  Future<PaymentMethodOption> update({
    required int paymentMethodOptionId,
    int? facilityId,
    int? warehouseId,
    String? name,
    int? numberOfPayments,
    bool? displayOnTicket,
    int? paymentMethod,
    String? commission,
    EntityStatus? status,
  });

  Future<void> delete({required int paymentMethodOptionId});
}

class PaymentMethodOptionPage {
  const PaymentMethodOptionPage({required this.items, required this.total});
  final List<PaymentMethodOption> items;
  final int total;
}
