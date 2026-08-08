import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';

part 'order_payments_controller.g.dart';

/// The applied-payments panel's data (FR-048), keyed by sale id.
/// `GET /sales-orders/{id}/payments` — **not** session-scoped (research.md
/// §11, resolved): it returns every application against the sale, cancelled
/// ones included, so a resumed sale shows its full payment history with no
/// session-controller fallback. `PaymentController` invalidates this after
/// each application and reversal.
@riverpod
Future<List<SalePayment>> orderPaymentsController(Ref ref, int saleId) {
  return ref.watch(customerPaymentRepositoryProvider).listForOrder(saleId: saleId);
}
