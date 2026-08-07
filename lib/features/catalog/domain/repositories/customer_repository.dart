import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';

/// Customer lookup and full CRUD management (data-model.md §4,
/// contracts/mbe-api-catalogs.md §4).
///
/// [create]/[update]'s `addresses`/`contacts` are **replace-all** link lists
/// (020-point-of-sale contracts/mbe-api-pos.md §4): passing a list replaces
/// that customer's whole set of links, and **omitting it leaves the existing
/// links untouched** — which is why they are nullable rather than defaulting
/// to empty. Passing `[]` deliberately unlinks everything. `priceList`/`salesperson` are
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
    List<int>? addresses,
    List<int>? contacts,
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
    List<int>? addresses,
    List<int>? contacts,
  });

  Future<void> delete({required int customerId});
}

class CustomerPage {
  const CustomerPage({required this.items, required this.total});
  final List<CustomerListItem> items;
  final int total;
}
