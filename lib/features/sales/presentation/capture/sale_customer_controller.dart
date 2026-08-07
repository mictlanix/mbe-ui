import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';

part 'sale_customer_controller.g.dart';

/// The full [Customer] behind `Sale.customer`, for the credit line and price
/// list the customer area must show (FR-011). The sale itself carries only
/// the id and a display name, so this resolves the rest — an autodispose
/// family keyed by customer id, refetched when the cashier switches customer
/// because the key changes, not because anything invalidates it.
@riverpod
Future<Customer> saleCustomerController(Ref ref, int customerId) {
  return ref.watch(customerRepositoryProvider).get(customerId: customerId);
}
