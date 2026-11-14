import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';

part 'delivery_order_detail_controller.g.dart';

/// Everything the detail screen reads about one delivery order (spec 061
/// research R5).
class DeliveryOrderDetail {
  const DeliveryOrderDetail({
    required this.order,
    required this.events,
    this.sales = const {},
    this.children = const [],
    this.proof,
  });

  final DeliveryOrder order;

  /// The status history. Its own [AsyncValue], so a failed history leaves the
  /// order on screen with only the history section in its error state.
  final AsyncValue<List<DeliveryOrderEvent>> events;

  /// Sales-order detail id → sale id, for linking each line to its sale.
  /// Empty when the sales couldn't be read (no Sales Orders read, or a
  /// request failed): the screen then shows no per-line sale.
  final Map<int, int> sales;

  /// The orders split off this one by a partial delivery. Only looked up for
  /// a partially delivered order; empty otherwise or when the lookup failed.
  final List<DeliveryOrderSummary> children;

  /// The proof of delivery's details, `null` when the order has none. Its own
  /// [AsyncValue], so a failed proof shows inside the proof section only
  /// (FR-010). The photo is read separately, through
  /// [deliveryOrderProofImageProvider], once these details are in.
  final AsyncValue<ProofOfDelivery>? proof;
}

/// One delivery order for its detail screen, keyed by id (spec 061 R5).
///
/// The order and its events load in parallel. Once the order is in, the sale
/// map and (for a partial delivery) the child orders load, in parallel too.
/// Neither of those can fail the screen: a failure leaves it empty.
///
/// Writes go through `DeliveryOrderActions`, which invalidates this provider
/// so the screen refetches what the server now holds.
@riverpod
class DeliveryOrderDetailController extends _$DeliveryOrderDetailController {
  @override
  Future<DeliveryOrderDetail> build(int id) async {
    final repository = ref.watch(deliveryOrderAdminRepositoryProvider);
    // Started before the order is awaited, and settled into an AsyncValue at
    // once, so its failure is never left unhandled while the order loads.
    final eventsFuture = _events(repository, id);
    final order = await repository.getById(id);

    final (events, sales, children, proof) = await (
      eventsFuture,
      _sales(order),
      _children(order),
      _proof(repository, order),
    ).wait;
    return DeliveryOrderDetail(
      order: order,
      events: events,
      sales: sales,
      children: children,
      proof: proof,
    );
  }

  /// The proof's details, only when the order has one (research R5).
  Future<AsyncValue<ProofOfDelivery>?> _proof(
    DeliveryOrderAdminRepository repository,
    DeliveryOrder order,
  ) async {
    if (!order.hasProof) return null;
    try {
      return AsyncData(await repository.proof(order.id));
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }

  Future<AsyncValue<List<DeliveryOrderEvent>>> _events(
    DeliveryOrderAdminRepository repository,
    int id,
  ) async {
    try {
      return AsyncData(await repository.events(id));
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }

  /// A single-sale order maps every line to that sale with no request. With
  /// several sales, each is read (needs Sales Orders read) and its line ids
  /// mapped; any failure leaves the map empty.
  Future<Map<int, int>> _sales(DeliveryOrder order) async {
    final saleIds = order.salesOrderIds;
    if (saleIds.length == 1) {
      return {
        for (final line in order.lines)
          if (line.salesOrderDetailId != null)
            line.salesOrderDetailId!: saleIds.single,
      };
    }
    final canRead = ref
        .read(accessControlProvider)
        .can(SystemObject.salesOrders, AccessRight.read);
    if (saleIds.isEmpty || !canRead) return const {};
    try {
      final repository = ref.read(salesOrderRepositoryProvider);
      final sales = await Future.wait([
        for (final saleId in saleIds) repository.getById(saleId: saleId),
      ]);
      return {
        for (final sale in sales)
          for (final line in sale.lines) line.id: sale.id,
      };
    } on AppError {
      return const {};
    }
  }

  /// One list call by a sale of the order, at the order's own facility (the
  /// server otherwise filters on the caller's, research R5), keeping the
  /// orders whose parent is this one.
  Future<List<DeliveryOrderSummary>> _children(DeliveryOrder order) async {
    if (order.status != DeliveryOrderStatus.partiallyDelivered ||
        order.salesOrderIds.isEmpty) {
      return const [];
    }
    try {
      // simplified: one page of 100 orders for the sale, a child past it is
      // not linked; page through `total` if a sale ever carries more.
      final page = await ref
          .read(deliveryOrderAdminRepositoryProvider)
          .list(
            salesOrder: order.salesOrderIds.first,
            facility: order.facilityId,
            limit: 100,
          );
      return [
        for (final summary in page.items)
          if (summary.parentId == order.id) summary,
      ];
    } on AppError {
      return const [];
    }
  }
}

/// A delivery order's proof photo, as PNG bytes (research R5).
///
/// Shaped like `licensePhotoProvider`: an autodispose family keyed by order
/// id, not kept alive, since the photo is personal data. A provider of its
/// own, read by the proof section only after the proof's details loaded, so a
/// slow or failed photo never holds up or breaks the rest of the screen.
@riverpod
Future<Uint8List> deliveryOrderProofImage(Ref ref, int deliveryOrderId) =>
    ref.watch(deliveryOrderAdminRepositoryProvider).proofImage(deliveryOrderId);
