# Phase 0 Research: Catalog UI/Layout Improvements

All decisions below resolve the "how" for a presentation-only change. No API, data,
or dependency questions exist, so this is a UI-pattern research pass.

## §1. Filter panel presentation — bottom sheet vs side sheet

**Decision**: A single shared launcher `showCatalogFilterSheet(context, ...)` that branches
on the centralized breakpoint:

- **Compact (`< LayoutBreakpoints.expanded`, 840px)** → `showModalBottomSheet` with
  `isScrollControlled: true` and `showDragHandle: true`. Standard M3 modal bottom sheet.
- **Expanded (`>= 840px`)** → a **right-anchored modal side sheet** rendered via
  `showGeneralDialog` with an `Align(alignment: Alignment.centerRight)` +
  `SizedBox(width: ~360)` + `SlideTransition` (offset from the right) and a scrim barrier.

**Rationale**: Material 3 specifies bottom sheets for compact and side sheets for
expanded/large windows. Flutter's framework ships `showModalBottomSheet` but has **no
built-in modal side sheet** widget, so the right sheet is composed from `showGeneralDialog`
(gives us the scrim, barrier-dismiss, `Escape`-to-close, and a slide transition for free).
Both branches return via `Navigator.pop`, and because filtering is live (see §2) the sheet
carries no result payload — closing simply reveals the already-filtered list.

**Alternatives considered**:
- `Scaffold.endDrawer` + `openEndDrawer()` for the side sheet — rejected: couples the sheet
  to the `Scaffold` (must be declared on the screen, harder to make a self-contained
  reusable launcher), and its width/animation are less controllable than a `showGeneralDialog`
  overlay.
- `showModalBottomSheet` at all widths — rejected: on a wide desktop monitor a bottom sheet
  is awkward and ignores M3's side-sheet guidance; the whole point is better wide-screen UX.
- A third-party side-sheet package — rejected: unnecessary dependency (constitution favors
  built-ins; cf. 005 using built-in `Autocomplete`).

## §2. Filtering interaction model — live vs staged/apply

**Decision**: **Live filtering** — facet controls inside the sheet call the existing
`ProductFilterController` mutators directly, so the list re-fetches immediately (unchanged
reactive behavior). The sheet footer has **Clear all** (resets every facet) and a primary
**Apply / Done** button whose only job is to close the sheet.

**Rationale**: The existing `ProductsListController` already watches `ProductFilter` and
re-fetches on any change; live filtering keeps that intact and satisfies FR-014 ("no
controller logic changes beyond layout"). On the expanded side sheet the list is visible
alongside the sheet, so users see results update instantly. On the compact bottom sheet the
list is hidden behind the sheet, so the **Apply/Done** button gives the expected "reveal my
results" affordance even though filtering already applied. This avoids introducing a
"draft filter" copy and an apply-commit step, which would be new controller state.

**Alternatives considered**: Staged filters (edit a draft, commit on Apply) — rejected: adds
duplicate draft state and a commit path to the controller, violating the minimal-change
constraint, for marginal benefit given live re-fetch is cheap and already the norm.

## §3. Active-filter count badge

**Decision**: Add a pure derived getter `int get activeFilterCount` (and a convenience
`bool get hasActiveFilters`) to the existing `ProductFilter` freezed class, counting each
facet that differs from its default: `deactivated != null` (i.e. "show inactive" on),
`stockable != null`, `salable != null`, `purchasable != null`, `label != null`. **Search
text is excluded** (it has its own always-visible box). Render it with M3 `Badge` wrapping
the Filters `IconButton`; show the badge only when `count > 0`.

**Rationale**: The count is a projection of existing state, not new state — cheapest possible
addition, fully testable, and keeps the badge and any future consumers consistent. Default
`ProductFilter()` yields `deactivated == null`; per the current screen, `deactivated == null`
means "show inactive included". So the badge counts "show inactive" as active when the user
has turned inactive results on — consistent with the assumptions in spec.md.

**Note on "show inactive" default**: current default `ProductFilter()` has `deactivated ==
null` and the inline chip treats *selected = null*. We keep the existing default and semantics
untouched; only the control's location moves into the sheet. `activeFilterCount` treats
`deactivated != null` (i.e. user narrowed to active-only) OR the current behavior as the
"non-default" signal — see data-model.md for the exact definition to avoid a badge that is
"always on" at defaults.

## §4. Responsive multi-column form grid

**Decision**: New shared widget `ResponsiveFormGrid` in `core/widgets/` that takes a list of
children and lays them out with a `LayoutBuilder` + `Wrap`, computing per-cell width as
`(availableWidth - totalSpacing) / columns` where `columns` = `1 | 2 | 3` from
`LayoutBreakpoints.tierOf(width)` (compact→1, medium/expanded→2, large→3). Children that must
span the full row (multiline comment field, section headers, the switches/prices/labels
blocks, the save button) opt in via a `FormGridSpan.full` marker so they aren't squeezed into
a narrow cell. The whole form is wrapped in a `Center` + `ConstrainedBox(maxWidth: ~1200)` so
fields never stretch edge-to-edge on 4K.

**Rationale**: `Wrap` handles odd field counts by left-aligning the trailing row with empty
trailing space (matches edge case in spec), reflows automatically, and needs no manual row
chunking. Driving `columns` from the centralized `LayoutBreakpoints` keeps FR-015 satisfied.
A max-width container is the standard M3 remedy for over-wide forms.

**Alternatives considered**:
- `GridView`/`SliverGrid` — rejected: fixed-extent grids fight variable-height fields
  (a field with an error text is taller) and complicate full-width spans.
- Manual `Row`/`Column` chunking per breakpoint — rejected: verbose, error-prone, and not
  reusable; the `Wrap`-based widget is a clean shared primitive.

## §5. Breakpoint extension for the `large` tier

**Decision**: Extend `core/layout/breakpoints.dart` additively:
- add `static const double large = 1200;`
- add `LayoutTier.large` to the enum (after `expanded`)
- update `tierOf` to return `LayoutTier.large` when `width >= large`
- keep `isExpanded`/`isCompact` semantics; optionally add `isLarge(context)`.

**Rationale**: Matches M3 window size classes (compact <600, medium 600–840, expanded
840–1200, large ≥1200). Additive change; existing callers that switch on `expanded` continue
to work (large is a superset of "at least expanded" for their purposes — verify each
`tierOf`/`isExpanded` call site treats `large` correctly). The `CatalogFilterBar`'s
`>= expanded` single-row check still holds for large.

**Risk/mitigation**: Any existing `switch` on `LayoutTier` that is non-exhaustive will now
need a `large` case. Audit call sites of `tierOf`/`LayoutTier` during implementation (grep
shows current usage is limited to `catalog_filter_bar.dart` and the breakpoints file itself).

## §6. Photo thumbnail + inline actions row

**Decision**: Replace the centered `Column` (thumbnail above a row/column of buttons) with a
`Row` (thumbnail + a `Column` of Change/Remove or a single Upload button beside it), wrapped
so that on **compact** width it falls back to the current stacked layout to avoid horizontal
overflow. Photo validation error text stays directly beneath the photo area. All existing
keys (`upload_photo_button`, `replace_photo_button`, `remove_photo_button`) and the
`canEditPhoto`/`hasPhoto` gating are preserved.

**Rationale**: Reclaims the near-empty row (the user's specific complaint) while honoring
read-only mode (no actions) and compact safety. Small, self-contained change.

## §7. Test impact

**Decision**: Update the two widget tests:
- `products_list_screen_test.dart`: facet chips (`products_filter_stockable`, etc.) are no
  longer in the initial tree — tests must first tap the Filters button (`products_filter_button`)
  to open the sheet, then assert/interact with the chips. Add a test for the badge count and
  Clear all. Keys on the chips themselves are unchanged.
- `product_detail_screen_test.dart`: assert the responsive layout renders (fields present,
  keys unchanged) and that photo action buttons still respond; add a wide-viewport pump to
  sanity-check multi-column rendering (via `tester.view.physicalSize`). No key changes.

**Rationale**: The DOM location of facet controls changes even though behavior/keys don't;
tests that assumed inline presence must open the sheet first. This is expected and called out
so the tasks phase budgets for it.

## Summary of decisions

| # | Topic | Decision |
|---|---|---|
| 1 | Filter panel | Bottom sheet (compact) / right side sheet via `showGeneralDialog` (expanded), one shared launcher |
| 2 | Interaction | Live filtering; footer = Clear all + Apply/Done (Done just closes) |
| 3 | Badge | Derived `ProductFilter.activeFilterCount`; M3 `Badge`, hidden at 0 |
| 4 | Form grid | Shared `ResponsiveFormGrid` (LayoutBuilder + Wrap), 1/2/3 cols, full-span opt-in, max-width container |
| 5 | Breakpoints | Add `large` (1200) tier + `LayoutTier.large`, additive |
| 6 | Photo row | Actions beside thumbnail; stack on compact; keys/gating preserved |
| 7 | Tests | Update 2 widget tests (open sheet first; wide-viewport form check) |
