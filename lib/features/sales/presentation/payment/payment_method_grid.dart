import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/payment/facility_payment_options_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_reference_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Method tiles, built from the facility's own configured
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
/// Tapping a tile *applies the payment* for the draft amount (spec 047 US5):
/// the tiles are actions, not a selection, so none is ever shown as selected.
/// A method that requires a reference asks for it in a small dialog first.
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
    required this.sale,
    required this.facilityId,
    this.enabled = true,
  });

  /// The sale a tapped tile pays.
  final Sale sale;
  final int facilityId;

  /// Whether the tiles can be tapped — off while a tender is in flight or the
  /// cash session is not valid.
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

  /// One tap, one payment: the method is applied now, and when it needs a
  /// reference the cashier is asked for it before anything is recorded.
  Future<void> _tender(
    BuildContext context,
    WidgetRef ref, {
    required int methodCode,
    int? paymentCharge,
    bool requiresReference = false,
  }) async {
    final notifier = ref.read(paymentControllerProvider.notifier);
    final result = await notifier.tender(
      sale,
      methodCode: methodCode,
      paymentCharge: paymentCharge,
      requiresReference: requiresReference,
    );
    if (result != TenderResult.needsReference || !context.mounted) return;
    final reference = await showPaymentReferenceDialog(context);
    if (reference == null) return;
    await notifier.tender(
      sale,
      methodCode: methodCode,
      paymentCharge: paymentCharge,
      requiresReference: requiresReference,
      reference: reference,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final options = ref.watch(
      facilityPaymentOptionsControllerProvider(facilityId),
    );
    final submitting = ref.watch(
      paymentControllerProvider.select((d) => d.submitting),
    );
    final active = enabled && !submitting;

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
                    onTap: active
                        ? () => _tender(context, ref, methodCode: method.code)
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
                    onTap: active
                        ? () => _tender(
                            context,
                            ref,
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
            final columns = constraints.maxWidth >= _minTileWidth * 2 + gutter
                ? 2
                : 1;
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
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final String name;
  final bool requiresReference;
  final VoidCallback? onTap;
}

/// One tile: icon, name, and a secondary line stating whether it requires a
/// reference. Dimmed and inert while [_TileData.onTap] is null.
class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.data,
    required this.width,
    required this.l10n,
  });

  final _TileData data;
  final double width;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    return SizedBox(
      key: data.key,
      width: width,
      child: Semantics(
        button: true,
        enabled: data.onTap != null,
        label: data.name,
        child: Opacity(
          opacity: data.onTap == null ? 0.5 : 1,
          child: Material(
            color: Colors.transparent,
            borderRadius: theme.shapes.mdRadius,
            child: InkWell(
              onTap: data.onTap,
              borderRadius: theme.shapes.mdRadius,
              child: Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  borderRadius: theme.shapes.mdRadius,
                  border: Border.all(color: colorScheme.outlineVariant),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
