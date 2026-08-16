# Contract: List-Screen Structure, Sheets & Alignment

**Feature**: 027-app-user-settings

The structural rules every screen inherits, and the two screens this feature
brings into compliance. Codified in constitution §VI v1.11.0.

---

## 1. A list screen is three things

A filter row, a list, and pagination. Nothing else.

```
┌──────────────────────────────────────────────┐
│ [search…]      [primary action]        [⚙ 2] │  ← CatalogFilterBar
├──────────────────────────────────────────────┤
│ table / list                                 │
│                                              │
├──────────────────────────────────────────────┤
│ pagination                                   │
└──────────────────────────────────────────────┘
```

### 1.1 Facet filters live behind the drawer

```dart
filters: [
  Badge.count(
    count: filter.activeFilterCount,
    isLabelVisible: filter.hasActiveFilters,
    child: IconButton.outlined(
      icon: const Icon(Icons.tune),
      tooltip: l10n.filtersTooltip,
      onPressed: () => showCatalogFilterSheet(context, ...),
    ),
  ),
],
```

**Banned in the `filters:` slot**: `FilterChip`, `ChoiceChip`,
`PopupMenuButton`, `DateRangeFilterChip`, an `OutlinedButton` opening
`showDateRangePicker` — any facet control. Those belong *inside* the drawer's
panel, which is where 10 of the 17 list screens already put them.

The `filters:` slot holds the badged drawer button, and nothing else.

### 1.2 A search-less screen omits the search control

`CatalogFilterBar.search` becomes optional. A screen whose endpoint has no
`search` parameter passes nothing, instead of `const SizedBox.shrink()`
reserving space for a control that will never exist — which is what
`cash_sessions_screen.dart` does today.

### 1.3 No form stacked above a list

A form on a list route belongs on its own route, or in a sheet launched from a
toolbar action in the filter row. When it moves into a sheet, **the toolbar
action must carry the state the inline form used to show** — otherwise
relocating it hides state the user relied on seeing at a glance.

---

## 2. Compliance inventory

Scanned all 17 screens using `CatalogFilterBar`.

| Screen | Status |
|---|---|
| `sales/…/pos_sales_list_screen.dart` | ❌ inline `DateRangeFilterChip` + status `PopupMenuButton`, no drawer, no badge — **fixed by this feature (US4)** |
| `sales/…/cash_sessions_screen.dart` | ❌ form above the list; empty `search:` placeholder — **fixed by this feature (US5)** |
| `pricing/…/exchange_rates_list_screen.dart` | ❌ inline `OutlinedButton.icon` → `showDateRangePicker`, no drawer, no badge; also calls `MoneyFormatters.date` locale-less — **out of scope; correct when next touched** |
| 10 catalog/admin list screens | ✅ badged button + `showCatalogFilterSheet` |
| labels, expenses, price_lists, suppliers, taxpayer_recipients, taxpayer_issuers | ✅ no facets at all — compliant by construction |

---

## 3. The shared sheet shell

`showCatalogFilterSheet`'s presentation mechanics are extracted into
`showAppSideSheet(...)`; the filter sheet delegates to it, and the shift sheet
is built on it.

**What the shell owns** (and why it is not re-solved per sheet):

- Modal bottom sheet below `LayoutBreakpoints.expanded`; right-anchored 360 px
  side sheet above it, with the slide transition.
- **`useRootNavigator: true`** — each list lives in its own
  `StatefulShellBranch` with a nested Navigator, and a sheet attached to that
  nested Navigator is torn down by `context.go`'s declarative page-stack
  rebuild. The shift sheet needs this for the same reason the filter sheet
  does: its blocked-by-another-session error calls `context.push` to that
  session's detail screen from inside the sheet.
- Header with title and close button; scrollable body; footer slot.

**What each sheet owns**: its footer. The filter sheet's is Clear all / Apply;
the shift sheet's is the open or close action.

---

## 4. The two screens

### 4.1 `pos_sales_list_screen.dart` (US4)

Date-range and status facets move from the `filters:` slot into a filter panel
opened by the badged drawer button. Preserved unchanged: both facets'
behaviour, URL-driven state, the default of today's range, and clear-all
returning to that default rather than to an unbounded range.

### 4.2 `cash_sessions_screen.dart` (US5)

The route becomes a standard list screen. The shift panel moves into a sheet
launched from a toolbar action in the filter row.

**The toolbar action reflects shift state** — no shift / open / stale — since
that state is no longer visible inline. It is absent, not disabled, for a user
without the privilege to open a shift.

**The sheet preserves everything the inline panel has**: drawer picker (or the
assigned-drawer static label when the user cannot browse drawers), opening
amount, validation and blocking-session errors, and for an open or stale
shift: drawer name, start time, opening amount, payments by method, the stale
warning, the other-open-sessions note, and the close action.

**On success**: the sheet dismisses, the history list refreshes without a
manual reload, and the toolbar action updates to the new state.

The empty `search:` placeholder goes away via §1.2.

---

## 5. Alignment and symmetry

Within a row or card:

- **Vertical padding is symmetric** — the space above the content equals the
  space below it.
- **Controls and text sharing a horizontal band share a text baseline.**
- **Values come from the design tokens** (`theme.spacing.*`), never ad-hoc
  literals.

### 5.1 The POS sale line (US6)

The reported defect: the line reads bottom-heavy because the control band sits
off the line total's baseline.

`sale_line_layout.dart` already encodes the right idea — text fields and
dropdowns pay their inner-height difference **in padding**, so both boxes come
out the same height *and* both centre their text on the same baseline as the
line total. The fix completes that alignment and makes the row's own insets
symmetric, in all three layouts (single-row, two-row, card), without
regressing either existing guarantee: a fixed line height independent of
product-name wrapping, and no overflow at the tablet width the tests pin.

### 5.2 Text scale (FR-024)

The same file's vertical constants are derived from a 14 px body role at 1.43
line height. They become functions of the effective text scaler, as does
`saleLineSingleRowMinWidth` — so at large scales the **existing, designed**
fallback engages (single row → two-row → card) instead of the row overflowing.
Column widths stay fixed; their secondary text ellipsizes, which constitution
§VI already permits. Money, totals and status are never truncated.

### 5.3 Verification

Asserted by tests that **measure**, never by inspection:

- insets: top inset equals bottom inset
- baselines: the control band's text baseline equals the line total's
- `sale_line_row_test.dart` pumped at all four text-size levels

That test is what kept the original column budget honest — it caught the
quantity column's first, too-tight 104 px. It is the right instrument for an
alignment that took many iterations to land the first time.
