import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';

part 'pending_deliveries_controller.g.dart';

const _pageSize = 20;

/// One period's date (single-day periods only) and total line count, for the
/// filter panel (spec 063 data-model §3).
class PendingDeliveryPeriodSummary {
  const PendingDeliveryPeriodSummary({
    required this.period,
    required this.date,
    required this.total,
  });

  final PendingDeliveryPeriod period;
  final DateTime? date;
  final int total;
}

/// What a load yields: the six period summaries, and the selected period's
/// page of lines.
class PendingDeliveriesView {
  const PendingDeliveriesView({required this.periods, required this.page});

  final List<PendingDeliveryPeriodSummary> periods;
  final CatalogPage<PendingDeliveryLine> page;
}

/// The six summaries of the last successful load (spec 063 R5).
///
/// The panel applies a period live, and a newly picked period is a new
/// controller key that starts in loading. Reading the counts from that key
/// would blank them until the response lands, so each success writes them
/// here and the panel reads them from here. The six totals don't depend on
/// the selected period, so the last known set is the right one to show.
@Riverpod(keepAlive: true)
class LastPendingDeliverySummaries extends _$LastPendingDeliverySummaries {
  @override
  List<PendingDeliveryPeriodSummary>? build() => null;

  void set(List<PendingDeliveryPeriodSummary> summaries) => state = summaries;
}

/// Fetches and holds a page of the pending-deliveries queue for one period
/// (spec 063 R4).
///
/// **There is no facility guard here, on purpose.** The endpoint lists every
/// active facility's lines, as the legacy screen did, and takes no `facility`
/// parameter, so there is nothing for the client to drop or to forward. Don't
/// copy the guard from the delivery orders list: that endpoint honours a
/// `facility` it is sent, this one can't be asked for another.
///
/// The server pages all six buckets by the same `skip`/`limit` in one
/// response. Only the selected period's lines are kept; the other five
/// contribute their date and total to the summaries. A page left empty by
/// lines leaving the period steps back to the last page that has rows, judged
/// on the selected period alone ([fetchClampedPage]).
@riverpod
class PendingDeliveriesController extends _$PendingDeliveriesController {
  @override
  Future<PendingDeliveriesView> build(
    PendingDeliveryPeriod period,
    int pageIndex,
  ) async {
    List<PendingDeliveryPeriodSummary> summaries = const [];

    final page = await fetchClampedPage<PendingDeliveryLine>(
      pageIndex: pageIndex,
      pageSize: _pageSize,
      fetch: (index) async {
        final result = await ref
            .read(deliveryItineraryRepositoryProvider)
            .pendingDeliveries(skip: index * _pageSize, limit: _pageSize);
        summaries = [
          for (final p in PendingDeliveryPeriod.values)
            PendingDeliveryPeriodSummary(
              period: p,
              date: result[p]?.date,
              total: result[p]?.total ?? 0,
            ),
        ];
        final bucket = result[period];
        return CatalogPage(
          items: bucket?.items ?? const [],
          total: bucket?.total ?? 0,
          pageIndex: index,
          pageSize: _pageSize,
        );
      },
    );

    // Riverpod forbids changing another provider while this one builds, so
    // the write waits a microtask. The notifier is keep-alive, so it can't
    // have been disposed meanwhile.
    final last = ref.read(lastPendingDeliverySummariesProvider.notifier);
    final fresh = summaries;
    Future.microtask(() => last.set(fresh));
    return PendingDeliveriesView(periods: summaries, page: page);
  }
}
