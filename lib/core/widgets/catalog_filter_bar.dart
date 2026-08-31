import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Lays out a catalog's search box and facet filter widgets on a single
/// row at/above [LayoutBreakpoints.expanded] (840px), reflowing into a
/// `Wrap` below that width (constitution §VI; FR-009). Implemented once
/// here so every catalog gets the same single-row-when-possible behavior
/// (research.md §4).
///
/// Applies its own horizontal inset of `spacing.cardPadding` — the same
/// tier-dependent metric `cardTheme.margin` gives the list surface below it
/// — so the row's content edges line up with the table's at every
/// breakpoint by construction rather than by two numbers happening to agree
/// (spec 035 FR-013/FR-015). A caller MUST NOT wrap this in a `Padding` of
/// its own; the 20 screens that used to add `EdgeInsets.all(8)` (which is
/// neither 16 nor 24, hence the visible misalignment) no longer do.
class CatalogFilterBar extends StatelessWidget {
  const CatalogFilterBar({
    super.key,
    this.search,
    this.filters = const [],
    this.actions = const [],
  });

  /// The catalog's search control (typically a [CatalogSearchBar]), or
  /// `null` when the underlying endpoint has no free-text `search` parameter
  /// (spec 027 FR-029) — omitted cleanly rather than a screen passing
  /// `const SizedBox.shrink()` to reserve space for a control that will
  /// never exist.
  final Widget? search;

  /// Facet filter widgets (e.g. `FilterChip`s), shown after [search] and
  /// [actions].
  final List<Widget> filters;

  /// Entity actions (e.g. Add, Merge), shown between [search] and [filters]
  /// instead of in the app bar (spec 010 FR-018/019). The Add action is
  /// passed pre-styled as the primary action by callers.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // Entity actions first, then facet filters — actions sit closer to the
    // search box, filters last, in both the single-row and reflowed layouts.
    final trailing = [...actions, ...filters];
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.cardPadding,
        vertical: spacing.xs,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= LayoutBreakpoints.expanded) {
            // `Row.spacing` puts the gaps *between* children only. The old
            // `Padding(right: 8)` on each trailing widget also padded the
            // last one, so the row stopped 8dp short of its right edge while
            // the search box started flush at 0 — asymmetric before the
            // outer inset was even considered (spec 035 FR-014).
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: spacing.xs,
              children: [
                if (search != null) Expanded(flex: 2, child: search!),
                ...trailing,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?search,
              if (search != null && trailing.isNotEmpty)
                SizedBox(height: spacing.xs),
              if (trailing.isNotEmpty)
                Wrap(
                  spacing: spacing.xs,
                  runSpacing: spacing.xs,
                  children: trailing,
                ),
            ],
          );
        },
      ),
    );
  }
}
