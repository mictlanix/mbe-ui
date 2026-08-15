import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/presentation/payment/facility_payment_options_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Method selection, built from the facility's own configured
/// `PaymentMethodOption`s — each tile reads `requiresReference` directly off
/// the option, since mbe-api computes it from the SAT code (research.md §6,
/// resolved). There is no client-side reference table.
///
/// A facility with no options configured falls back to the shared
/// [PaymentMethod] enum's common tenders, so a cashier is never stuck unable
/// to take money because a catalog is empty; those fall-back tiles carry no
/// `paymentCharge` and never require a reference, which is the safe default
/// (`PaymentMethodOption.requiresReference`'s own documented posture).
///
/// Rendered as tiles, not `ChoiceChip`s (contracts/payment-surface.md §4): a
/// `LayoutBuilder` + `Wrap` sizes two fixed-width columns when the available
/// width admits two tiles of at least [_minTileWidth] each, one column
/// otherwise. Tile height follows its own content — never a `GridView`'s
/// aspect ratio, which is the exact trap `NumberPad` was fixed to avoid
/// (research.md §6): a wide pane would stretch the tiles vertically instead
/// of just adding a column.
class PaymentMethodGrid extends ConsumerWidget {
  const PaymentMethodGrid({
    super.key,
    required this.facilityId,
    this.enabled = true,
  });

  final int facilityId;
  final bool enabled;

  static const _fallbackMethods = [
    PaymentMethod.cash,
    PaymentMethod.creditCard,
    PaymentMethod.debitCard,
    PaymentMethod.eft,
  ];

  /// A tile's minimum width for the two-column layout (contracts/
  /// payment-surface.md §4).
  static const _minTileWidth = 260.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final options = ref.watch(facilityPaymentOptionsControllerProvider(facilityId));
    final draft = ref.watch(paymentControllerProvider);
    final notifier = ref.read(paymentControllerProvider.notifier);

    return options.when(
      data: (list) {
        final tiles = list.isEmpty
            ? [
                for (final method in _fallbackMethods)
                  _TileData(
                    key: Key('payment_method_${method.code}'),
                    icon: paymentMethodIcon(method.code),
                    name: paymentMethodLabel(l10n, method.code),
                    requiresReference: false,
                    selected: draft.methodCode == method.code &&
                        draft.paymentCharge == null,
                    onTap: enabled
                        ? () => notifier.selectMethod(methodCode: method.code)
                        : null,
                  ),
              ]
            : [
                for (final option in list)
                  _TileData(
                    key: Key('payment_option_${option.paymentMethodOptionId}'),
                    icon: paymentMethodIcon(option.paymentMethod),
                    name: option.name,
                    requiresReference: option.requiresReference,
                    selected: draft.paymentCharge == option.paymentMethodOptionId,
                    onTap: enabled
                        ? () => notifier.selectMethod(
                            methodCode: option.paymentMethod,
                            paymentCharge: option.paymentMethodOptionId,
                            requiresReference: option.requiresReference,
                          )
                        : null,
                  ),
              ];

        final gutter = Theme.of(context).spacing.xs;
        return LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= _minTileWidth * 2 + gutter ? 2 : 1;
            final width = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - gutter) / 2;
            return Wrap(
              spacing: gutter,
              runSpacing: gutter,
              children: [
                for (final tile in tiles)
                  _MethodTile(data: tile, width: width, l10n: l10n),
              ],
            );
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

/// What one tile needs, independent of whether it came from a configured
/// [PaymentMethodOption] or the fallback [PaymentMethod] set — the two
/// branches above converge here so the tile itself is built once.
class _TileData {
  const _TileData({
    required this.key,
    required this.icon,
    required this.name,
    required this.requiresReference,
    required this.selected,
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final String name;
  final bool requiresReference;
  final bool selected;
  final VoidCallback? onTap;
}

/// One tile: icon, name, a secondary line stating whether it requires a
/// reference, and a trailing check when selected. Selection is carried by
/// both the border and the icon, never fill alone (FR-014).
class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.data, required this.width, required this.l10n});

  final _TileData data;
  final double width;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final selected = data.selected;

    return SizedBox(
      key: data.key,
      width: width,
      child: Semantics(
        button: true,
        selected: selected,
        label: data.name,
        child: Material(
          color: selected
              ? theme.elevations.engaged.surfaceColor
              : Colors.transparent,
          borderRadius: theme.shapes.mdRadius,
          child: InkWell(
            onTap: data.onTap,
            borderRadius: theme.shapes.mdRadius,
            child: Container(
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                borderRadius: theme.shapes.mdRadius,
                border: Border.all(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(data.icon, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: theme.typeRoles.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          data.requiresReference
                              ? l10n.posPaymentMethodRequiresReference
                              : l10n.posPaymentMethodNoReference,
                          style: theme.typeRoles.metricLabel,
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
