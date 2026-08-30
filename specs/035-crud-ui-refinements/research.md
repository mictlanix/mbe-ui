# Phase 0 Research: CRUD UI Refinements

**Feature**: 035-crud-ui-refinements | **Date**: 2026-08-30

Every finding below was verified against the working tree at `81305a4`, not inferred.
Line references are to that state.

---

## R1 — Why the filter bar hangs outside the table, and where the padding belongs

**Findings.** `CatalogFilterBar` (`lib/core/widgets/catalog_filter_bar.dart`) applies **no
horizontal padding of its own**. Each of the 20 consuming screens wraps it in an ad-hoc
`Padding(padding: const EdgeInsets.all(8))` — e.g. `labels_list_screen.dart:45`. The table
below it is a `Card`, whose margin comes from `cardTheme.margin: EdgeInsets.all(spacing.cardPadding)`
(`component_themes.dart:45`), and `cardPadding` is **16** on compact/medium and **24** on
expanded/large (`spacing.dart:75-102`). So the filter row is inset 8 while the table is inset
16 or 24 — an 8 or 16dp mismatch that grows on wide screens, which is exactly what the
screenshot shows.

A second, independent defect: in the `>= expanded` branch the bar renders each trailing widget
inside `Padding(padding: EdgeInsets.only(right: 8))`, so the *last* control stops 8dp short of
the right edge while the search box starts flush at 0. The row is asymmetric even before the
outer padding is considered.

**Decision.** Move the horizontal inset **into** `CatalogFilterBar`, sourced from
`spacing.cardPadding` so it tracks the table's margin across tiers by construction, and delete
the per-screen `EdgeInsets.all(8)` wrapper from all 20 screens. Replace the trailing-padding
hack with `Row`'s own `spacing:` argument (available in Flutter 3.44), so gaps sit *between*
children and no child carries a trailing inset.

**Rationale.** Alignment then holds by construction rather than by two numbers agreeing. It also
retires 20 literal `EdgeInsets.all(8)` values, which §VI forbids ("padding and margin values MUST
come from the shared design tokens, never ad-hoc literals") — the current code is already in
violation there.

**Alternatives considered.** Setting the per-screen padding to `cardPadding` in each of the 20
screens: rejected — leaves 20 places to drift and keeps the token lookup duplicated. Removing the
`Card` margin and padding the page instead: rejected — a far wider blast radius, and the card
margin is load-bearing for every other Card.

---

## R2 — Why the top corners are square, and the cheapest correct fix

**Findings.** Both branches of `DataTableView` render inside a `Card`: `PaginatedDataTable2`
does it internally (`wrapInCard = true` → `Card(semanticContainer: false, child: t)`,
`paginated_data_table_2.dart:992`), and the unpaginated branch does it explicitly
(`data_table_view.dart:~250`). `cardTheme.shape` already rounds all four corners at
`shapes.lgRadius`. **The radius is not missing.** What is missing is clipping: the card's default
`clipBehavior` is `Clip.none`, and `dataTableTheme.headingRowColor: scheme.surfaceContainer`
(`component_themes.dart:89`) paints a square-cornered fill across the heading row, over the
card's rounded top corners. The bottom corners survive only because the footer paints nothing
there.

`CardThemeData.clipBehavior` exists in Flutter 3.44.2 (`card_theme.dart:247`) and `Card` reads it.

**Decision.** Set **`clipBehavior: Clip.antiAlias`** on `cardTheme` in `component_themes.dart`.
One line, in the design system, fixes every table in both branches and every other Card at once.

**Rationale.** Satisfies FR-017, FR-018, FR-020 and FR-021 together, with no per-screen code and
no change to `DataTableView` at all. It is also simply correct: an unclipped rounded card whose
child paints to its edges is a latent bug wherever it occurs, not only in tables.

**Alternatives considered.** `wrapInCard: false` plus a hand-rolled `Card` inside `DataTableView`:
rejected — `paginated_data_table_2.dart:958` subtracts `8 * (wrapInCard ? 1 : 0)` from an internal
height computation, so flipping the flag silently changes row-area height, and it duplicates the
card between the two branches. Overriding `headingRowDecoration` with a top-rounded decoration:
rejected — it fixes the header specifically while leaving the general unclipped-card bug in place,
and it would have to be repeated for any future child that paints to the card's edge.

---

## R3 — Where the hairline outline is defined

**Findings.** No table or card in the app carries a border today. `DataTableThemeData.decoration`
is unset. `FacilityCard` uses a plain `Card` (`facility_card.dart:71`), so it inherits `cardTheme`.
The three child rows are **not** cards — they are `Container`s with fill-only `BoxDecoration`s and
hard-coded radii: `BorderRadius.circular(6)` at `facility_child_row.dart:29` and `:161`, and
`BorderRadius.circular(12)` at `:249`; `facility_card.dart` hard-codes `circular(12)` at `:200`,
`:248` and `:525`. The `shapes` token scale (`shapes.dart:47-52`) already exposes
`xs/sm/md/lg/xl` radii that nothing in these two files consumes.

**Decision.** Add the outline to `cardTheme.shape` as
`RoundedRectangleBorder(borderRadius: shapes.lgRadius, side: BorderSide(color: scheme.outlineVariant))`
— the same `shape` field already being set, now carrying a side. This covers the table surface
(FR-019) and `FacilityCard` (FR-023) in one edit. For the three `Container`-based child rows,
which cannot inherit a card theme, expose the side once as a design-system helper and have those
`BoxDecoration`s consume it plus a `shapes` radius, replacing their literals (FR-024).

**Rationale.** M3 recognises outlined cards as a first-class card variant, so an outline on
`cardTheme` is idiomatic rather than a hack. One colour and one thickness, defined once, is what
FR-021 asks for, and it keeps the card and the non-card rows visually identical without copying a
`BorderSide` into two files.

**Alternatives considered.** `DataTableThemeData.decoration`: rejected — it decorates the table
only, leaving facility cards to define an outline separately, which is the drift this feature
exists to remove. A bespoke `OutlinedSurface` wrapper widget: rejected as an abstraction for
something the theme already models.

**Risk to verify during implementation.** Outlining `cardTheme` touches **every** `Card` in the
app, not just these. That is the intended reading of FR-021/FR-023, but each remaining Card
surface (POS, dashboard, merge review) must be eyeballed once before this is called done.

---

## R4 — Making the search control always refetch

**Findings.** The list screens are URL-driven: `onSubmitted` builds a new `ListQuery` and calls
`context.go(...)` (`labels_list_screen.dart:52-58`). The data lives in a `@riverpod` family
controller keyed by a **freezed filter value** (`labels_list_controller.dart:36-44`). Submitting an
unchanged term produces an identical URI → an identical filter value → the same provider instance,
already resolved. Nothing re-fetches. This is by design, not an oversight.

The refetch primitive already exists and is already used on these very screens:
`onRetry: () => ref.invalidate(labelsListControllerProvider(filter))` (`labels_list_screen.dart:80`),
and the same call is the documented post-mutation path.

**Decision.** On submit, branch: if the submitted term differs from the current filter's term,
`context.go` as today (one fetch, FR-009); if it is identical, call `ref.invalidate` on the current
provider instance (one fetch, page and facets untouched, FR-011). Express the branch once as a
shared helper in `core/navigation/`, taking the refresh as a callback, so all 20 screens submit
identically rather than each re-deriving the rule.

**Rationale.** Uses the mechanism the codebase already trusts for "re-fetch this exact page",
adds no new state, and cannot double-fetch because the two paths are mutually exclusive.
`CatalogSearchBar` is untouched, so its deliberate absence of an `onChanged` hook (FR-010) is
preserved by construction.

**Alternatives considered.** A nonce/refresh counter in `ListQuery`: rejected — it would appear in
the URL, making every shared link carry meaningless state and breaking `toUri`'s canonical-ordering
contract. Watching a separate "refresh signal" provider: rejected — more moving parts than an
`invalidate` the screens already call. Filtering `ListQuery` equality to ignore the term: rejected
as incoherent.

**Note for FR-012.** `ref.invalidate` puts the provider back into `AsyncLoading`. Whether
`CatalogListStateView` blanks the table on that transition must be checked; if it does, the fix is
to render the previous data while loading (`AsyncValue.isRefreshing`), not to skip the invalidate.

---

## R5 — Expressing "Active by default" without breaking "All"

**Findings.** Catalog status facets are shared: `EntityStatusFilterChips`
(`entity_status_controls.dart:55-93`) renders an "All" chip plus one per `EntityStatus`, where
**`null` means All and omits `?status=` entirely** — the widget's own doc-comment states this
matches mbe-api's "omit the parameter to get every state" contract. Screens decode with
`EntityStatus.values.byNameOrNull(query.facet('status'))` (`customers_list_controller.dart:40-46`).

Ten list screens use it: users, user profiles, employees, facilities, customers, vehicles,
vehicle operators, products, payment method options, and the pricing grid.

The collision: today *absent* means All. If absent starts meaning Active, the user has no way to
express All, and FR-004's "that choice persists across paging, sorting and reload" fails.

**Decision.** Introduce an explicit `all` sentinel in the URL. Decoding becomes: absent → Active
(the default, FR-002); `status=all` → no status filter; any other value → that state. The "All"
chip writes `status=all` instead of clearing the facet. Both halves live in the shared widget and
a shared decode helper, so the ten screens inherit it.

**Rationale.** Keeps the filter UI literally truthful about what the table shows (FR-003) and makes
the default a real, visible, clearable filter rather than a hidden bias. `ListQuery.isFiltered`
then reports true for a default-filtered list with no extra work, which is what FR-006 needs for
the filters badge.

**Alternatives considered.** Defaulting inside each controller's `fromQuery` and leaving `null` as
All: rejected — indistinguishable from "user explicitly chose All", so the default could not be
cleared. A separate `?default=off` parameter: rejected as a second mechanism for one idea.

**Precedent.** The POS sales list already applies and badges a default date range
(`pos_sales_list_screen.dart:162`), so a visible, pre-applied default is an established pattern
here rather than a new concept.

---

## R6 — How wide a record panel must be

**Findings.** `showAppSideSheet` renders a **fixed `SizedBox(width: 360)`**
(`app_side_sheet.dart:145`) with 16dp horizontal body padding, giving 328dp of content.
`ResponsiveFormGrid.columnsForWidth` reads the **inner** constraint, not the screen
(`responsive_form_grid.dart:47-53`), and maps compact (<600) → 1 column, medium/expanded → 2,
large (≥1200) → 3. At 328dp every converted form collapses to a single column, which §VI's
multi-column form rule exists to prevent.

**Decision.** Give `showAppSideSheet` a width argument. Filter sheets keep 360. Record sheets get
**640**, clamped to the available width less the card padding. 640 − 32 = 608 inner, which clears
the 600 medium threshold and yields 2 columns on every non-compact tier.

**Rationale.** 640 is the smallest width that produces a two-column form, so it is the least
change that satisfies FR-033. M3 permits side sheets up to half the viewport, which 640 respects
from 1280 up; below that the clamp keeps it on screen. Compact widths keep the existing bottom-sheet
presentation, where one column is correct anyway.

**Alternatives considered.** Keeping 360 and amending §VI to say the form-grid rule is satisfied by
a narrow container: defensible — `ResponsiveFormGrid` already measures the container, so a
one-column form in a 360 panel arguably honours the rule's intent (fields do not stretch across a
wide display). Rejected because the larger forms in scope — employees (397 lines), customers (378) —
would become long scrolls in a narrow panel, trading the navigation cost this feature removes for a
scrolling cost. Recorded here because it remains the cheaper fallback if 640 proves too wide in use.
A width that tracks the screen tier (480 medium / 640 large): rejected as complexity without a
demonstrated need.

---

## R7 — Removing the record routes

**Findings.** All 14 entities follow one route shape, declared **outside** the shell branches
(`app_router.dart:333-535`), which is why opening a record replaces the whole screen:

```
GoRoute(path: '/labels/new',       builder: … LabelDetailScreen())
GoRoute(path: '/labels/:labelId',  builder: … LabelDetailScreen(labelId: …,
                                     forceReadOnly: state.uri.queryParameters['view'] == 'true'))
```

Screens navigate with `context.push('/labels/new')`, `context.push('/labels/$id')` (edit) and
`context.push('/labels/$id?view=true')` (row click) — `labels_list_screen.dart:66,101,105`.
The read-only/editable distinction is already a `?view=true` query parameter plus a
`forceReadOnly` flag, not two different screens.

The detail screens are uniform in shape: `Scaffold(appBar: AppBar(title), body:
SingleChildScrollView(ResponsiveFormGrid(...) + RecordFormActions(...)))`. Everything below the
`Scaffold` is already surface-agnostic. `RecordFormActions` (`record_form_actions.dart:100-102`)
already renders **Delete in edit mode and the view→edit toggle in view mode inside the form body**,
so neither has to be rebuilt for the panel and neither currently lives in `AppBar.actions`.
`formState.saved || formState.deleted` triggers `context.pop()`, which works identically from a
sheet since sheets are pushed on the root navigator.

**Decision.** Extract each detail screen's `Scaffold` body into a form widget, host that widget in
the panel, and delete the `Scaffold`/`AppBar` and the two `GoRoute`s per entity (28 routes). Add a
redirect from the removed paths to the entity's list (FR-030).

**Rationale.** The conversion is mostly deletion: the parts that make a record editable are already
factored out of the route. The `?view=true` flag becomes a constructor argument to the panel's
content, so read-only-vs-edit semantics carry over unchanged.

**Watch item.** The form controllers are **global singletons**, not families
(`labelFormControllerProvider`, not `…Provider(id)`). They are `@riverpod`, hence auto-disposing, so
closing the panel should drop the last listener and reset the state for the next open — but this is
the single most likely source of a "previous record's values appear briefly" bug and must be
asserted with a test, not assumed.

---

## R8 — Warning before discarding edits

**Findings.** Form states carry `loading / submitting / saved / deleted / error / fieldErrors`
(`label_form_controller.dart:32-42`) — **no dirty flag anywhere**. The panel is dismissible three
ways: `barrierDismissible: true`, the Escape key, and the close button
(`app_side_sheet.dart:63,119`).

**Decision.** Snapshot the freezed form state when the panel finishes loading and compare it to the
current state on dismissal; unequal means dirty. Route all three dismissal paths through one guard.

**Rationale.** Every form state is a freezed class with generated value equality, so a snapshot
comparison is exact and costs one field. The alternative — adding a `dirty` flag to 14 controllers
and setting it in every `…Changed` method — touches 14 files to record something the existing
equality already tells us, and would be silently wrong wherever a setter is missed.

**Alternatives considered.** `PopScope` alone: insufficient — it does not intercept a barrier tap on
`showGeneralDialog`, so barrier dismissal would bypass the guard.

---

## R9 — Constitution amendment

**Findings.** §VI conflicts with this feature far less than the spec assumed. It **already**
permits a sheet-hosted form: *"A form MUST NOT be embedded above the list on a list route: it
belongs on its own route, **or in a dialog/sheet launched from a toolbar action in the filter
row**."* Three clauses genuinely bind, all of which say *screen* where they mean *the record's own
surface*:

1. *"Clicking anywhere on a row … MUST open that record's detail **screen** in read-only mode."*
2. *"The read-only detail **screen** MUST label itself as a 'View' screen … MUST offer an explicit
   control to switch to the editable form."*
3. *"Delete/soft-delete MUST be surfaced on the record's own detail **screen** … MUST NOT place it
   back on the list row."*

**Decision.** Amend §VI to re-express all three in terms of the record's own **surface** — a full
screen or the shared panel — and add a sentence naming which entities use which: a panel for simple
records, a full screen for records owning nested collections (products, facilities, taxpayer
issuers). Constitution is at **1.12.0**; this is a material expansion of an existing principle, so
**1.13.0**.

**Rationale.** The three rules' intent — a stray click is safe, view and edit are one form, delete
is never a row action — is fully preserved by the panel. Only the noun changes. Amending is
therefore the honest move; claiming compliance without it would leave the text contradicting the code.

**Sequencing.** This project's stated practice is to land a rule with the code that satisfies it, so
the amendment ships in the same change as the first converted entity, not ahead of it.
