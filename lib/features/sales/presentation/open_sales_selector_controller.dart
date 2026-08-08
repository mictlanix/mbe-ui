import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/pos_resume_controller.dart';

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

/// Midnight of the register's trading day, as the wire wants it.
///
/// Flagged UTC while carrying the **local** wall-clock date, deliberately —
/// two constraints meet here and only this satisfies both:
///
/// - built_value's `Iso8601DateTimeSerializer` throws `ArgumentError` on a
///   local `DateTime`. A plain `DateTime(y, m, d)` therefore never reaches the
///   network at all: the throw happens while the query string is being built,
///   so the request is abandoned before dio sends it.
/// - mbe-api ignores the offset and reads `date_from` as local wall-clock time
///   (verified against a live backend: `…T18:00:00Z` and `…T18:00:00` select
///   the same rows, where `…T12:00:00` selects more). `.toUtc()` would
///   therefore shift the window forward by the UTC offset and silently drop
///   every sale between midnight and, at UTC-6, six in the morning.
///
/// `DateTime.utc` of today's local date serializes cleanly *and* puts the
/// intended wall-clock value on the wire.
DateTime _startOfToday() {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month, now.day);
}

/// Keeps only the paid **delivery** sales that still owe a distribution.
///
/// The delivery test comes first and matters as much as the distribution one:
/// a counter sale has nothing to distribute, so asking only "is everything
/// distributed?" answers "no" for every paid counter sale ever rung at the
/// register — they would fill the selector permanently (FR-058: a paid
/// counter sale is finished). It is also the cheap test, so it runs before
/// any delivery-order round trip.
Future<List<OpenSale>> _paidAndUndistributed(Ref ref, List<OpenSale> paid) async {
  if (paid.isEmpty) return const [];

  final salesOrders = ref.watch(salesOrderRepositoryProvider);
  final deliveries = ref.watch(deliveryOrderRepositoryProvider);

  final checks = paid.map((candidate) async {
    final sale = await salesOrders.getById(saleId: candidate.id);
    // A sale with no lines cannot owe a distribution.
    if (sale.lines.isEmpty) return null;
    // No destination was ever named, so it was collected here — and this
    // costs nothing, which is why it is asked before the facility lookup.
    if (sale.shipTo == null) return null;

    // Counter pickup can also be recorded explicitly, as the facility's own
    // address. Distinguishing that from a real delivery needs the facility,
    // read through the same helper the resume step uses so the selector and
    // the step it reopens on cannot disagree about what a delivery sale is.
    final facilityAddressId = await ref.read(
      facilityAddressControllerProvider(sale.facility).future,
    );
    final isDelivery = FulfillmentModeEncoding.impliesDelivery(
      shipTo: sale.shipTo,
      facilityAddressId: facilityAddressId,
    );
    if (!isDelivery) return null;

    final destinations = await deliveries.listForSale(salesOrder: sale.id);
    final distribution = distributionFor(sale: sale, destinations: destinations);
    final complete = distribution.every((line) => line.isFullyDistributed);
    return complete ? null : candidate;
  });

  final results = await Future.wait(checks);
  return results.whereType<OpenSale>().toList();
}
