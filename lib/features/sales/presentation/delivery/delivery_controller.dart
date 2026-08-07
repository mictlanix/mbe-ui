import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';

part 'delivery_controller.g.dart';

/// The destinations recorded against the sale being delivered (FR-030).
///
/// `build()` loads what already exists, which is what makes resuming a
/// part-distributed sale work (contracts/pos-screen.md §5). Each
/// [addDestination] is one repository call carrying that destination's whole
/// line distribution — no trim step, and no ordering requirement between
/// destinations (research §3, mbe-api#138).
///
/// A refused create leaves this list exactly as it was: the failure is thrown
/// for the editor to render, and every already-created destination is
/// untouched (FR-037).
@riverpod
class DeliveryController extends _$DeliveryController {
  @override
  Future<List<Destination>> build(Sale sale) {
    return ref
        .watch(deliveryOrderRepositoryProvider)
        .listForSale(
          salesOrder: sale.id,
          customer: sale.customer,
          saleLineIds: sale.lines.map((line) => line.id).toSet(),
        );
  }

  /// Records one addressed destination and its share of each line.
  Future<Destination> addDestination({
    required int shipTo,
    int? contact,
    DateTime? date,
    String? comment,
    required Map<int, String> quantities,
  }) async {
    final lines = [
      for (final entry in quantities.entries)
        if (!_isZero(entry.value))
          DestinationLineRequest(salesOrderDetail: entry.key, quantity: entry.value),
    ];

    final created = await ref
        .read(deliveryOrderRepositoryProvider)
        .create(
          salesOrder: sale.id,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: shipTo,
          contact: contact,
          date: date,
          comment: comment,
          lines: lines,
        );

    state = AsyncData([...?state.valueOrNull, created]);
    return created;
  }

  /// FR-036 — sweeps whatever is left into a counter-pickup destination.
  /// `lines` is deliberately omitted: that claims everything the sale still
  /// owes, which is exactly the remainder, computed server-side against the
  /// same figure it validates every other destination against.
  Future<Destination> sweepRemainderToCounter() async {
    final created = await ref
        .read(deliveryOrderRepositoryProvider)
        .create(
          salesOrder: sale.id,
          fulfillmentType: FulfillmentType.counterPickup,
        );

    state = AsyncData([...?state.valueOrNull, created]);
    return created;
  }

  /// Undoes a destination the cashier changed their mind about, releasing the
  /// quantities it held back to the pool.
  Future<void> removeDestination(int destinationId, {required String reason}) async {
    await ref
        .read(deliveryOrderRepositoryProvider)
        .cancel(destinationId: destinationId, reason: reason);

    state = AsyncData([
      for (final destination in state.valueOrNull ?? const <Destination>[])
        if (destination.id != destinationId) destination,
    ]);
  }

  /// The distribution as it stands, optionally including the destination
  /// being edited but not yet submitted (FR-033).
  List<LineDistribution> distribution({Map<int, String> draft = const {}}) {
    return distributionFor(
      sale: sale,
      destinations: state.valueOrNull ?? const [],
      draft: draft,
    );
  }

  static bool _isZero(String value) => double.tryParse(value) == 0;
}
