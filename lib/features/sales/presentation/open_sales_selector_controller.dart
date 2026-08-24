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

  // Grouped by what the cashier can do about the sale — still capturing, then
  // owed money, then owed a delivery — and newest first within each group.
  //
  // This supersedes data-model.md §8's flat "newest first": with three
  // statuses interleaved, the register's own drafts were scattered among
  // sales that need a different action entirely. The section order matches
  // the order a sale moves through, so the top of the list is always the work
  // nearest to hand.
  return byId.values.toList()
    ..sort((a, b) {
      final byStatus = _statusRank(a.status).compareTo(_statusRank(b.status));
      return byStatus != 0 ? byStatus : b.id.compareTo(a.id);
    });
}

/// Sale ids are sequential, so descending id is newest-first *within* a group
/// — data-model.md §8's intent, kept inside each section.
int _statusRank(SaleStatus status) => switch (status) {
  SaleStatus.draft => 0,
  SaleStatus.completed => 1,
  SaleStatus.paid => 2,
  // Never listed; ranked last rather than left to chance.
  SaleStatus.cancelled => 3,
};

/// Midnight of the register's trading day, as the wire wants it — a thin
/// wrapper over the shared [wireDate] (extracted to
/// `sales_order_repository_impl.dart` in spec 023, since `PosSalesListController`
/// needs the same encoding for a cashier-chosen date, not only "today").
DateTime _startOfToday() => wireDate(DateTime.now());

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

    // `fulfillmentIntent` (mbe-api#171) records the mode directly and is
    // checked first, exactly as `resumeTargetFor` does — the two must never
    // disagree about what a delivery sale is. `shipTo` is only the pre-#171
    // fallback, for a sale old enough to predate the field: a `null` `shipTo`
    // is no longer proof of "collected here" now that Venta stopped asking
    // for an address at all (spec 020 FR-056, amended 2026-08-23).
    final bool isDelivery;
    final recorded = sale.fulfillmentIntent;
    if (recorded != null) {
      isDelivery = recorded != FulfillmentMode.counterPickup;
    } else if (sale.shipTo == null) {
      // Cheap, and asked before the facility lookup below for the same
      // reason it always was: nothing was ever named, so it was collected
      // here.
      isDelivery = false;
    } else {
      // Counter pickup can also be recorded explicitly, as the facility's own
      // address. Distinguishing that from a real delivery needs the
      // facility, read through the same helper the resume step uses so the
      // selector and the step it reopens on cannot disagree.
      final facilityAddressId = await ref.read(
        facilityAddressControllerProvider(sale.facility).future,
      );
      isDelivery = FulfillmentModeEncoding.impliesDelivery(
        shipTo: sale.shipTo,
        facilityAddressId: facilityAddressId,
      );
    }
    if (!isDelivery) return null;

    final destinations = await deliveries.listForSale(salesOrder: sale.id);
    final distribution = distributionFor(sale: sale, destinations: destinations);
    final complete = distribution.every((line) => line.isFullyDistributed);
    return complete ? null : candidate;
  });

  final results = await Future.wait(checks);
  return results.whereType<OpenSale>().toList();
}
