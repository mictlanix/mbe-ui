import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'open_sales_selector_controller.g.dart';

/// The open-sales selector's contents (FR-004, FR-058), scoped to the
/// cashier's own register (research.md §5).
///
/// Three statuses are reachable and each means something different:
///
/// - `draft` — captured but not confirmed, resumes on Venta;
/// - `completed` — confirmed and owing money, resumes on Cobro;
/// - `paid` — settled, and only still *open* when it is a delivery sale whose
///   distribution is unfinished (FR-058). A paid counter sale is done and
///   must not clutter the list.
///
/// That last filter is why this is not three plain list calls: `paid` has to
/// be narrowed client-side, and neither `SalesOrderSummary` nor the list
/// endpoint exposes `ship_to` or any distribution figure. Each candidate
/// therefore costs a `getById` plus its delivery orders — issued concurrently,
/// and only for paid sales, which are the smallest of the three sets.
@riverpod
Future<List<OpenSale>> openSalesSelectorController(Ref ref, int pointSale) async {
  final salesOrders = ref.watch(salesOrderRepositoryProvider);

  final pages = await Future.wait([
    salesOrders.listOpen(pointSale: pointSale, status: SaleStatus.draft),
    salesOrders.listOpen(pointSale: pointSale, status: SaleStatus.completed),
    salesOrders.listOpen(pointSale: pointSale, status: SaleStatus.paid),
  ]);

  final resumable = <OpenSale>[
    ...pages[0].items,
    ...pages[1].items,
  ];

  final undistributed = await _paidAndUndistributed(ref, pages[2].items);
  resumable.addAll(undistributed);

  // Newest first (US3 scenario 1, data-model.md §8).
  resumable.sort((a, b) => b.date.compareTo(a.date));
  return resumable;
}

/// Keeps only the paid sales that still owe a distribution.
Future<List<OpenSale>> _paidAndUndistributed(Ref ref, List<OpenSale> paid) async {
  if (paid.isEmpty) return const [];

  final salesOrders = ref.watch(salesOrderRepositoryProvider);
  final deliveries = ref.watch(deliveryOrderRepositoryProvider);

  final checks = paid.map((candidate) async {
    final sale = await salesOrders.getById(saleId: candidate.id);
    // A sale with no lines cannot owe a distribution.
    if (sale.lines.isEmpty) return null;

    final destinations = await deliveries.listForSale(salesOrder: sale.id);
    final distribution = distributionFor(sale: sale, destinations: destinations);
    final complete = distribution.every((line) => line.isFullyDistributed);
    return complete ? null : candidate;
  });

  final results = await Future.wait(checks);
  return results.whereType<OpenSale>().toList();
}
