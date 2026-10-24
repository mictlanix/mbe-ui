import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';

part 'customer_discounts_controller.g.dart';

/// Loads the open customer's discounts for the Discounts section (spec 052,
/// FR-002) — a family provider keyed by customer id. The server already
/// orders them by product code, so they are kept as received. No
/// search/pagination: a per-customer collection is small and bounded.
/// Refreshed (via `ref.invalidate`) after a discount is added, changed or
/// removed, and after the server refuses one.
@riverpod
class CustomerDiscountsController extends _$CustomerDiscountsController {
  @override
  Future<List<CustomerDiscount>> build(int customerId) => ref
      .read(customerRepositoryProvider)
      .listDiscounts(customerId: customerId);
}
