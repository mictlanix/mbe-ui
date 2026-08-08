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

  // The register's *current trading day*. Unbounded, `completed` and `paid`
  // answer with the whole history of the point of sale — measured at 19,277
  // and 19,291 rows against a live backend — and only the first page of each
  // is ever read, so an unfinished sale could sit past the cut-off and never
  // be offered at all. A sale left open across a day boundary is a
  // back-office matter, not something the cashier resumes at the counter.
  final since = _startOfToday();

  final pages = await Future.wait([
    salesOrders.listOpen(
      pointSale: pointSale,
      status: SaleStatus.draft,
      dateFrom: since,
    ),
    salesOrders.listOpen(
      pointSale: pointSale,
      status: SaleStatus.completed,
      dateFrom: since,
    ),
    salesOrders.listOpen(
      pointSale: pointSale,
      status: SaleStatus.paid,
      dateFrom: since,
    ),
  ]);

  // mbe-api's `status` filter is not exclusive: `completed` answers with
  // everything confirmed, paid sales included (verified against a live
  // backend — one page came back 80 `paid` to 20 `completed`). Each branch
  // here therefore keeps only the status it asked for. Without this a paid
  // sale arrives twice, once as "unpaid" and once through the distribution
  // check below, and the two entries collide as duplicate widget keys in the
  // menu — a crash, not a cosmetic slip.
  final resumable = <OpenSale>[
    ...pages[0].items.where((sale) => sale.status == SaleStatus.draft),
    ...pages[1].items.where((sale) => sale.status == SaleStatus.completed),
  ];

  final paid = pages[2].items.where((sale) => sale.status == SaleStatus.paid);
  resumable.addAll(await _paidAndUndistributed(ref, paid.toList()));

  // The three queries are concurrent and independent, so a sale confirmed or
  // paid *between* two of them can legitimately appear in both answers however
  // the server filters. Collapsing by id keeps that race off the screen.
  final byId = <int, OpenSale>{};
  for (final sale in resumable) {
    byId.putIfAbsent(sale.id, () => sale);
  }

  // Newest first (US3 scenario 1, data-model.md §8).
  return byId.values.toList()..sort((a, b) => b.date.compareTo(a.date));
}

/// Midnight local time — the register's trading day, in the cashier's own
/// timezone rather than UTC, so the list turns over when the shop does.
DateTime _startOfToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
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
