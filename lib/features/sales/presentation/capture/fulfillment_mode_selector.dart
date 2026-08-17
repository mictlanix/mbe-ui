import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/customer_address_picker.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One segment of [_ModeTrack].
typedef _ModeSegment = ({FulfillmentMode mode, String label, IconData icon});

/// The height every mode segment takes: `FloatingActionButton.extended`'s own
/// M3 height, which is also the mock's (`height:56px; border-radius:28px`).
/// The two controls bracket the capture surface — this one at the top of it,
/// the footer's action at the bottom — so they are the pair most worth
/// agreeing.
const fulfillmentModeSelectorHeight = 56.0;

/// A single-select track that does what `SegmentedButton` does — one choice at
/// a time, the selected segment filled and marked with a check, an outlined
/// stadium around the set — but takes its **height** as a given rather than as
/// something to be inferred.
///
/// `SegmentedButton` cannot: it forwards only `textStyle`, `padding`,
/// `visualDensity` and `tapTargetSize` to its segments, dropping
/// `minimumSize`/`fixedSize` outright, and it paints each segment's fill as a
/// plain rectangle clipped to a border rect derived from `fontSize +
/// padding.vertical`. Height could therefore only be bought with vertical
/// padding, which topped out at 48 px; forcing it from outside with a `SizedBox`
/// left the clip rect at the stock size while the fill filled the stretched box,
/// so the selected segment showed a square-cornered block inside the container's
/// rounded end. Sixty lines of `Row` have none of that problem.
class _ModeTrack extends StatelessWidget {
  const _ModeTrack({
    required this.segments,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    required this.stretch,
  });

  final List<_ModeSegment> segments;
  final FulfillmentMode selected;
  final bool enabled;
  final ValueChanged<FulfillmentMode> onSelected;

  /// Whether the track takes the whole width it is offered, sharing it equally
  /// between the segments, or hugs its content.
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('pos_fulfillment_selector'),
      height: fulfillmentModeSelectorHeight,
      // The children clip to the stadium, which is what lets the first and
      // last segment's fill run into the rounded ends instead of stopping
      // square inside them.
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Row(
        mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, segment) in segments.indexed) ...[
            if (index > 0)
              VerticalDivider(
                width: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: theme.colorScheme.outline,
              ),
            // Never fixed: three segments at their natural width need ~538 px,
            // which a phone does not have — `SegmentedButton` shrank its
            // segments to fit and this has to as well.
            //
            // Loose when hugging, so each takes its natural width where the
            // room is there and its share of what is left where it is not;
            // tight when stretching, so the three divide the offered width
            // evenly however much of it there is.
            Flexible(
              fit: stretch ? FlexFit.tight : FlexFit.loose,
              child: _ModeSegmentButton(
                segment: segment,
                selected: segment.mode == selected,
                enabled: enabled,
                onPressed: () => onSelected(segment.mode),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeSegmentButton extends StatelessWidget {
  const _ModeSegmentButton({
    required this.segment,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final _ModeSegment segment;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = switch ((selected, enabled)) {
      (_, false) => theme.colorScheme.onSurface.withValues(alpha: 0.38),
      (true, _) => theme.colorScheme.onSecondaryContainer,
      (false, _) => theme.colorScheme.onSurfaceVariant,
    };

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: selected ? theme.colorScheme.secondaryContainer : Colors.transparent,
        child: InkWell(
          key: Key('pos_fulfillment_${segment.mode.name}'),
          onTap: enabled ? onPressed : null,
          child: Padding(
            // The mock's own segment inset.
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // Only bites when the track is stretched and the segment is
              // wider than its content; a hugging segment is its content.
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // A check in place of the segment's own icon once chosen —
                // `SegmentedButton`'s `showSelectedIcon` behaviour, and what
                // the mock draws on its selected segment.
                Icon(selected ? Icons.check : segment.icon, size: 20, color: foreground),
                SizedBox(width: theme.spacing.xs),
                // The label is what gives when the track is squeezed — the
                // icon and the insets stay, so the segments keep their rhythm
                // and only the words shorten.
                Flexible(
                  child: Text(
                    segment.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typeRoles.buttonLabel.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The three-chip Tienda/Domicilio/Mixta control (FR-017), always visible,
/// defaulting to counter pickup.
///
/// Choosing Domicilio or Mixta is guarded twice:
///
/// - the customer must be permitted to receive deliveries, else the reason is
///   shown and the mode is not changed (FR-019);
/// - the sale's **main delivery address** must be named before capture
///   continues (FR-056), picked from the customer's own addresses or created
///   inline, then written to `Sale.shipTo`.
///
/// `shipTo` is what makes the mode survive a reload (FR-057, research §4):
/// the screen holds no persisted mode of its own.
class FulfillmentModeSelector extends ConsumerStatefulWidget {
  const FulfillmentModeSelector({
    super.key,
    required this.sale,
    this.enabled = true,
    this.stretch = false,
  });

  /// `null` before the first action has opened a sale — the track renders
  /// either way, beside the customer band, so the capture surface opens with
  /// its whole header rather than growing one once the first scan lands.
  /// Choosing a delivery mode is itself a legitimate first action:
  /// `updateHeader` opens the sale before writing `shipTo`.
  final Sale? sale;
  final bool enabled;

  /// Whether the track fills the width it is given, dividing it evenly between
  /// the three segments, instead of hugging its labels.
  ///
  /// Stacked under the customer band (contracts/capture-surface.md §2), where
  /// every other element of the capture surface — the band, the search field,
  /// the lines, the footer's action — runs margin to margin, a hugging track is
  /// the one thing left floating against the leading edge. Beside the band on a
  /// wide tier it must keep hugging: there it is measured with an unbounded
  /// width, which a filling track has no way to answer.
  final bool stretch;

  @override
  ConsumerState<FulfillmentModeSelector> createState() =>
      _FulfillmentModeSelectorState();
}

class _FulfillmentModeSelectorState extends ConsumerState<FulfillmentModeSelector> {
  /// The sale's customer, or the walk-in default until a sale exists — the
  /// same resolution `CustomerBar` beside this makes, so the shipping check
  /// and the address picker ask about the customer the band is naming.
  int get _customerId =>
      widget.sale?.customer ?? ref.read(appSettingsProvider).posDefaultCustomerId;

  AppError? _error;
  String? _refusal;
  bool _busy = false;

  Future<void> _select(FulfillmentMode mode) async {
    setState(() {
      _error = null;
      _refusal = null;
    });

    if (mode == FulfillmentMode.counterPickup) {
      // No address to name, so no round trip — a `null` `shipTo` already
      // means counter pickup unambiguously (`FulfillmentModeEncoding`), and
      // recording `fulfillmentIntent` here would only add a request with
      // nothing at stake if it fails.
      ref.read(posStepControllerProvider.notifier).setMode(mode);
      return;
    }

    // FR-019 — a customer not permitted deliveries cannot use either
    // delivery mode, and is told why rather than silently refused.
    final customer = await ref.read(
      saleCustomerControllerProvider(_customerId).future,
    );
    if (!mounted) return;
    if (!customer.shipping) {
      setState(() => _refusal = AppLocalizations.of(context)!.posDeliveryNotPermitted);
      return;
    }

    // FR-056 — naming the main delivery address is part of choosing the mode,
    // not a later step.
    final addressId = await showCustomerAddressPicker(
      context,
      customerId: _customerId,
    );
    if (addressId == null || !mounted) return;

    setState(() => _busy = true);
    try {
      // `fulfillmentIntent` rides the same call as `shipTo` — one request,
      // and the mode now survives a resume as itself rather than being
      // reconstructed from the address, which cannot tell `delivery` and
      // `mixed` apart (mbe-api#170/#171).
      await ref
          .read(posSaleControllerProvider.notifier)
          .updateHeader(shipTo: addressId, fulfillmentIntent: mode);
      if (mounted) ref.read(posStepControllerProvider.notifier).setMode(mode);
    } on AppError catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final step = ref.watch(posStepControllerProvider);
    final enabled = widget.enabled && !_busy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModeTrack(
          selected: step.mode,
          enabled: enabled,
          stretch: widget.stretch,
          onSelected: _select,
          segments: [
            (
              mode: FulfillmentMode.counterPickup,
              label: l10n.posFulfillmentCounter,
              icon: Icons.store_outlined,
            ),
            (
              mode: FulfillmentMode.delivery,
              label: l10n.posFulfillmentDelivery,
              icon: Icons.local_shipping_outlined,
            ),
            (
              mode: FulfillmentMode.mixed,
              label: l10n.posFulfillmentMixed,
              icon: Icons.call_split,
            ),
          ],
        ),
        if (_refusal != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _refusal!,
              key: const Key('pos_delivery_refusal'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ErrorBanner(
              error: _error!,
              onDismiss: () => setState(() => _error = null),
            ),
          ),
      ],
    );
  }
}
