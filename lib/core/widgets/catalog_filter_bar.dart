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
  });

  /// The catalog's search control (typically a [CatalogSearchBar]).
  final Widget search;

  /// Facet filter widgets (e.g. `FilterChip`s), shown after [search].
  final List<Widget> filters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= LayoutBreakpoints.expanded) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: search),
              if (filters.isNotEmpty) const SizedBox(width: 8),
              ...filters.map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: filter,
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            search,
            if (filters.isNotEmpty) const SizedBox(height: 8),
            if (filters.isNotEmpty) Wrap(spacing: 8, children: filters),
          ],
        );
      },
    );
  }
}
