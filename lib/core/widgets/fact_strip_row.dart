import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';

/// The one always-visible row of a document header (spec 049 FR-016–FR-019):
/// a strip of read-only [facts] with a [trailing] control — the disclosure
/// toggle, plus whatever sits beside it — on the trailing edge.
///
/// Shared by the quote and order headers, which used to carry two copies of
/// `Row[Expanded(Wrap), Flexible(trailing)]`. `Expanded` and `Flexible` both
/// have `flex: 1`, so that row split the free space 50/50: the facts got half
/// the card and wrapped, and the trailing control started at the midpoint.
///
/// Here [trailing] is a non-flex child, so it is laid out first at its own
/// width and the facts take everything left. It is capped at
/// [_trailingShare] of the row so that, at the compact tier or a large text
/// scale, a longer label ("Menos detalles") wraps inside its slot instead of
/// starving the facts or overflowing.
///
/// A header whose trailing slot carries actions beside the toggle (the
/// quote's "Ver cotización" and "Enviar por correo", spec 053) passes a
/// larger [trailingMaxShare], so they stay on one line and the facts wrap
/// instead — the facts' `Wrap` is built for that, the actions' is not.
class FactStripRow extends StatelessWidget {
  const FactStripRow({
    super.key,
    required this.facts,
    required this.trailing,
    this.trailingMaxShare = 0.4,
  });

  final List<Widget> facts;
  final Widget trailing;

  /// The most of the row [trailing] may take.
  final double trailingMaxShare;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Wrap(
              spacing: spacing.lg,
              runSpacing: spacing.sm,
              children: facts,
            ),
          ),
          SizedBox(width: spacing.md),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * trailingMaxShare,
            ),
            child: trailing,
          ),
        ],
      ),
    );
  }
}
