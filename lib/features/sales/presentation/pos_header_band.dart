import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector.dart';
import 'package:mbe_ui/features/sales/presentation/pos_gate_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The band directly beneath the app bar (research.md §13, FR-004): the
/// open-sales selector on the left, the step indicator on the right, and the
/// stale-session banner under both when the session needs attention.
///
/// The banner comes from [PosGateScreen], which owns every rendering decision
/// that follows from `CurrentSession` alone — it draws nothing at all when
/// the session is healthy.
class PosHeaderBand extends ConsumerWidget {
  const PosHeaderBand({
    super.key,
    required this.sale,
    required this.onSaleSelected,
    required this.onStartNew,
  });

  /// `null` while the first sale is still opening — the band renders its
  /// shape immediately so the screen does not jump once it arrives.
  final Sale? sale;

  final ValueChanged<OpenSale> onSaleSelected;
  final VoidCallback onStartNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(posStepControllerProvider);
    final current = sale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              if (current != null)
                OpenSalesSelector(
                  pointSale: current.pointSale,
                  // FR-040: the id always, the folio once assigned.
                  currentId: current.provisionalReference,
                  currentSerial: current.serial,
                  onSelected: onSaleSelected,
                  onStartNew: onStartNew,
                ),
              const Spacer(),
              _StepIndicator(step: step),
            ],
          ),
        ),
        const PosGateScreen(),
      ],
    );
  }
}

/// Two steps or three, driven by the fulfilment mode (FR-005) — the current
/// one emphasised rather than the others hidden, so the cashier can see
/// what is still ahead.
///
/// On a phone there is no room for that: three labels and two chevrons would
/// push the selector off the band, so it collapses to "Paso N de M" (US5,
/// SC-007). The position is what matters; the names are on the step itself.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final PosStepState step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (LayoutBreakpoints.isCompact(context)) {
      return Text(
        key: const Key('pos_step_progress'),
        l10n.posStepProgress(step.current.index + 1, step.stepCount),
        style: theme.textTheme.titleSmall,
      );
    }

    final labels = [
      l10n.posStepVenta,
      l10n.posStepCobro,
      l10n.posStepEntrega,
    ].take(step.stepCount).toList();

    return Row(
      key: const Key('pos_step_indicator'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Text(
            '${i + 1}·${labels[i]}',
            style: i == step.current.index
                ? theme.textTheme.titleSmall
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
          ),
          if (i < labels.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.chevron_right, size: 16),
            ),
        ],
      ],
    );
  }
}
