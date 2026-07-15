import 'package:flutter/material.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Lays out a catalog's search box and facet filter widgets on a single
/// row at/above [LayoutBreakpoints.expanded] (840px), reflowing into a
/// `Wrap` below that width (constitution §VI; FR-009). Implemented once
/// here so every catalog gets the same single-row-when-possible behavior
/// (research.md §4).
class CatalogFilterBar extends StatelessWidget {
  const CatalogFilterBar({
    super.key,
    required this.search,
    this.filters = const [],
    this.actions = const [],
  });

  /// The catalog's search control (typically a [CatalogSearchBar]).
  final Widget search;

  /// Facet filter widgets (e.g. `FilterChip`s), shown after [search].
  final List<Widget> filters;

  /// Entity actions (e.g. Add, Merge), shown to the right of [filters]
  /// instead of in the app bar (spec 010 FR-018/019). The Add action is
  /// passed pre-styled as the primary action by callers.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // Filters first, then entity actions — actions always sit to the right of
    // the facet controls, in both the single-row and reflowed layouts.
    final trailing = [...filters, ...actions];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= LayoutBreakpoints.expanded) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: search),
              if (trailing.isNotEmpty) const SizedBox(width: 8),
              ...trailing.map(
                (widget) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget,
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            search,
            if (trailing.isNotEmpty) const SizedBox(height: 8),
            if (trailing.isNotEmpty)
              Wrap(spacing: 8, runSpacing: 8, children: trailing),
          ],
        );
      },
    );
  }
}
