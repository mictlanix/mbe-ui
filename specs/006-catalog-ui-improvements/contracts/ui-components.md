# Phase 1 UI Component Contracts

This feature exposes no network/API contracts. Its "contracts" are the public widget APIs of
the two new shared `core/widgets/` components (constitution §VI mandates shared, reusable
implementations). These are the interfaces other catalog/form screens will consume later, so
they are specified here.

## 1. `showCatalogFilterSheet` — filter panel launcher

**File**: `lib/core/widgets/catalog_filter_sheet.dart`

**Contract**:

```dart
/// Opens the catalog filter panel: a modal bottom sheet on compact widths
/// (< LayoutBreakpoints.expanded) and a right-anchored modal side sheet on
/// expanded+ widths. Returns when the user dismisses it. Filtering is applied
/// live by [builder]'s controls, so no value is returned.
Future<void> showCatalogFilterSheet(
  BuildContext context, {
  required String title,          // localized panel title, e.g. "Filters"
  required WidgetBuilder builder, // builds the facet controls (chips, dropdown)
  VoidCallback? onClearAll,       // wired to the "Clear all" footer action
});
```

**Behavioral requirements**:

- Chooses presentation by `LayoutBreakpoints.tierOf(MediaQuery.sizeOf(context).width)`:
  bottom sheet (`compact`/below expanded) vs right side sheet (`expanded`/`large`).
- Renders a header with `title` and a close affordance; a scrollable body from `builder`;
  and a footer with **Clear all** (calls `onClearAll`, disabled/hidden when null) and a
  primary **Apply / Done** button that pops the sheet.
- Barrier-dismissible; `Escape` closes on desktop; drag handle on the bottom-sheet variant.
- Side-sheet variant width ≈ 360dp, full height, slides in from the right with a scrim.
- Adds no Riverpod state; the builder's controls mutate the caller's existing controller.

**Consumers**: `products_list_screen.dart` (this feature); available to future catalogs.

## 2. `ResponsiveFormGrid` — responsive multi-column form layout

**File**: `lib/core/widgets/responsive_form_grid.dart`

**Contract**:

```dart
/// Lays out form children in 1/2/3 columns based on the centralized
/// LayoutBreakpoints tier (compact→1, medium/expanded→2, large→3), inside a
/// max-width container. Children may request a full-row span.
class ResponsiveFormGrid extends StatelessWidget {
  const ResponsiveFormGrid({
    super.key,
    required this.children,      // list of FormGridChild
    this.maxContentWidth = 1200, // caps overall width; centered
    this.spacing = 16,           // horizontal + vertical gap between cells
    this.maxColumns = 3,         // upper bound on columns regardless of width
  });

  final List<FormGridChild> children;
  final double maxContentWidth;
  final double spacing;
  final int maxColumns;
}

/// Wraps a field/section with its column span.
class FormGridChild {
  const FormGridChild(this.child, {this.span = FormGridSpan.single});
  final Widget child;
  final FormGridSpan span;
}

enum FormGridSpan { single, full } // single = one column; full = whole row
```

**Behavioral requirements**:

- Column count derived once per layout via `LayoutBuilder` +
  `LayoutBreakpoints.tierOf(constraints.maxWidth)`, then capped at `maxColumns` (the
  product form passes `maxColumns: 2`).
- `single` children occupy one column of width `(inner - spacing*(cols-1))/cols`; `full`
  children occupy the entire row regardless of column count.
- Odd trailing cells are left-aligned (no stretching to fill) — `Wrap`-based.
- Wrapped in `Center` + `ConstrainedBox(maxWidth: maxContentWidth)`.
- No horizontal scrolling at any width; cell content wraps/truncates per constitution §VI.
- Layout-only: imposes no styling on children beyond sizing; preserves each child's own
  keys, decoration, enabled state, and error display.

**Consumers**: `product_detail_screen.dart` (this feature); available to future form screens.

## 3. `LayoutBreakpoints` extension (existing file, additive)

**File**: `lib/core/layout/breakpoints.dart`

```dart
static const double large = 1200;          // NEW
enum LayoutTier { compact, medium, expanded, large } // + large
// tierOf(width): width >= large ? LayoutTier.large : ...existing...
```

**Compatibility requirement**: All existing `tierOf`/`isExpanded` call sites must continue to
behave correctly with the new `large` value (audit non-exhaustive `switch`es).

## 4. `ProductFilter` derived getters (existing file, additive)

**File**: `lib/features/catalog/presentation/products_list_controller.dart`

```dart
extension ProductFilterBadge on ProductFilter {
  int get activeFilterCount; // see data-model.md definition
  bool get hasActiveFilters => activeFilterCount > 0;
}
// + ProductFilterController.reset() preserving `search`
```

Pure projection + a `copyWith`-composed reset; introduces no new stored state.
