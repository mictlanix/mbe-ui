import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';

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

/// FR-011's outstanding balance for the sale's customer. Its own provider
/// rather than a field on [saleCustomerController] because it is a separate
/// call — mbe-api exposes no aggregate on the customer — and a slow or
/// failing balance must not stop the name and price list from rendering.
@riverpod
Future<String> customerOutstandingBalance(Ref ref, int customerId) {
  return ref
      .watch(customerPaymentRepositoryProvider)
      .outstandingBalanceFor(customerId: customerId);
}
