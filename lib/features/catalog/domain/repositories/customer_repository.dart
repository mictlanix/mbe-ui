import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
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
    // spec 036 FR-011: optional since mbe-api#198 landed — `null` omits the
    // field entirely rather than sending an empty string.
    String? code,
    required String name,
    required int priceList,
    String? zone,
    String? creditLimit,
    int? creditDays,
    int? salesperson,
    String? comment,
    List<int>? addresses,
    List<int>? contacts,

    /// RFC keys this customer may invoice under (mbe-api#150) — replace-all,
    /// exactly like [addresses] and [contacts].
    List<String>? taxpayers,
  });

  Future<Customer> update({
    required int customerId,
    String? code,
    String? name,
    int? priceList,
    String? zone,
    String? creditLimit,
    int? creditDays,
    int? salesperson,
    EntityStatus? status,
    String? comment,
    List<int>? addresses,
    List<int>? contacts,

    /// RFC keys this customer may invoice under (mbe-api#150) — replace-all,
    /// exactly like [addresses] and [contacts].
    List<String>? taxpayers,
  });

  Future<void> delete({required int customerId});

  /// The customer's product discounts, in the server's order (by product
  /// code). Throws `NotFoundError` when the customer no longer exists.
  Future<List<CustomerDiscount>> listDiscounts({required int customerId});

  /// Adds a discount on [productId]. [discount] is a **fraction** string
  /// (`"0.1"` is 10 %), never a percentage. Throws `ServerError` with status
  /// 409 when the customer already has one for that product, and
  /// `ValidationError` on 422 (unknown product, or field errors).
  Future<CustomerDiscount> createDiscount({
    required int customerId,
    required int productId,
    required String discount,
  });

  /// Changes only the rate: the product is fixed once the discount exists.
  /// Throws `NotFoundError` when the discount is gone.
  Future<CustomerDiscount> updateDiscount({
    required int customerId,
    required int customerDiscountId,
    required String discount,
  });

  /// Throws `NotFoundError` when the discount is already gone.
  Future<void> deleteDiscount({
    required int customerId,
    required int customerDiscountId,
  });
}

class CustomerPage {
  const CustomerPage({required this.items, required this.total});
  final List<CustomerListItem> items;
  final int total;
}
