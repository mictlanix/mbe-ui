import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// What the distribution panel renders for one sale line (FR-033,
/// data-model.md §6): how much was ordered, how much each already-created
/// destination takes, how much the destination currently being edited claims,
/// and how much is therefore left at the counter.
///
/// A plain value type, not persisted and not fetched — [distributionFor]
/// computes it from state the screen already holds. `perDestination` is read
/// directly from each `Destination.lines`, which is exactly what was
/// requested, so nothing is re-derived from delivery progress.
class LineDistribution {
  const LineDistribution({
    required this.saleLineId,
    required this.productName,
    required this.ordered,
    required this.perDestination,
    required this.draftQuantity,
    required this.atCounter,
  });

  final int saleLineId;
  final String productName;

  /// The sale line's own quantity.
  final String ordered;

  /// Destination id → the quantity that destination takes of this line.
  final Map<int, String> perDestination;

  /// What the destination being edited (not yet submitted) claims.
  final String draftQuantity;

  /// `ordered` − Σ`perDestination` − `draftQuantity`. Negative when the draft
  /// over-claims, which [isOverClaimed] reports and the server would refuse
  /// with a 422 anyway.
  final String atCounter;

  /// Σ`perDestination` — everything already committed to a destination.
  String get distributed =>
      perDestination.values.fold('0', (sum, q) => addAmounts(sum, q));

  /// FR-035: in mixed mode the remainder is legitimate; in delivery mode a
  /// non-zero remainder means the line is not fully distributed yet.
  bool get isFullyDistributed => isZeroAmount(atCounter);

  /// The draft claims more than the line still has left. The server refuses
  /// this outright (research §3); the client checks only to avoid a round
  /// trip for a request already known to be invalid.
  bool get isOverClaimed => compareAmounts(atCounter, '0') < 0;

  /// What the draft could still claim without over-claiming.
  String get claimable {
    final remaining = subtractAmounts(ordered, distributed);
    return compareAmounts(remaining, '0') < 0 ? '0' : remaining;
  }
}

/// Computes the distribution for every line of [sale] (data-model.md §6).
///
/// [destinations] are the destinations already created — counter-pickup ones
/// included, since a remainder collected at the counter is just as
/// distributed as one being shipped. [draft] maps a sale line id to what the
/// destination currently being edited claims for it.
///
/// Pure: no server round trip, no ordering requirement, no mutation.
List<LineDistribution> distributionFor({
  required Sale sale,
  required List<Destination> destinations,
  Map<int, String> draft = const {},
}) {
  return [
    for (final line in sale.lines)
      () {
        final perDestination = <int, String>{};
        for (final destination in destinations) {
          for (final destinationLine in destination.lines) {
            if (destinationLine.salesOrderDetail != line.id) continue;
            perDestination[destination.id] = addAmounts(
              perDestination[destination.id] ?? '0',
              destinationLine.quantity,
            );
          }
        }

        final claimed = perDestination.values.fold(
          '0',
          (sum, q) => addAmounts(sum, q),
        );
        final draftQuantity = draft[line.id] ?? '0';

        return LineDistribution(
          saleLineId: line.id,
          productName: line.productName,
          ordered: line.quantity,
          perDestination: perDestination,
          draftQuantity: draftQuantity,
          atCounter: subtractAmounts(
            subtractAmounts(line.quantity, claimed),
            draftQuantity,
          ),
        );
      }(),
  ];
}

/// FR-030's step-level gate: every line accounted for. In mixed mode an
/// undistributed remainder is expected (it goes to the counter, FR-035), so
/// only an over-claim blocks closing.
bool isDistributionComplete(List<LineDistribution> distribution, {required bool isMixed}) {
  if (distribution.any((d) => d.isOverClaimed)) return false;
  if (isMixed) return true;
  return distribution.every((d) => d.isFullyDistributed);
}
