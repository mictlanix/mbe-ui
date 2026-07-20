import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';

/// Customer lookup and full CRUD management (data-model.md §4,
/// contracts/mbe-api-catalogs.md §4). `priceList`/`salesperson` are
/// expanded on read (see `Customer`/`CustomerListItem`) but sent as plain
/// ids on write (research.md §7) — the Customer form's price-list/
/// salesperson `CatalogEntityPicker`s resolve the id to select before
/// calling [create]/[update].
abstract class CustomerRepository {
  Future<CustomerPage> list({
    String? search,
    EntityStatus? status,
    int? priceList,
    int? salesperson,
    int skip = 0,
    int limit = 20,
  });

  Future<Customer> get({required int customerId});

  Future<Customer> create({
    required String code,
    required String name,
    required int priceList,
    String? zone,
    String? creditLimit,
    int? creditDays,
    bool? shipping,
    bool? shippingRequiredDocument,
    int? salesperson,
    String? comment,
  });

  Future<Customer> update({
    required int customerId,
    String? code,
    String? name,
    int? priceList,
    String? zone,
    String? creditLimit,
    int? creditDays,
    bool? shipping,
    bool? shippingRequiredDocument,
    int? salesperson,
    EntityStatus? status,
    String? comment,
  });

  Future<void> delete({required int customerId});
}

class CustomerPage {
  const CustomerPage({required this.items, required this.total});
  final List<CustomerListItem> items;
  final int total;
}
