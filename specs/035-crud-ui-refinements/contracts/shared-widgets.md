# Contract: shared UI surfaces

**Feature**: 035-crud-ui-refinements

The interfaces this feature exposes are Flutter widget/function signatures in `lib/core/`, which
every feature module consumes. They are the app's internal UI contract; changing one changes every
screen. Each section states the signature, what callers may rely on, and what they are forbidden
from doing.

---

## C1 — `CatalogFilterBar`

```dart
const CatalogFilterBar({
  Widget? search,
  List<Widget> filters = const [],
  List<Widget> actions = const [],
})
```

**Signature is unchanged.** Behaviour changes:

- The bar now applies its own horizontal inset of `spacing.cardPadding`, matching the table card's
  margin at every tier.
- Gaps sit between children only; no child carries a trailing inset, so the row is symmetric.

**Callers MUST NOT** wrap the bar in a `Padding` of their own. The 20 existing
`Padding(padding: EdgeInsets.all(8))` wrappers are removed by this feature and must not come back —
re-adding one reintroduces the misalignment.

---

## C2 — `DataTableView`

```dart
DataTableView<T>({ required List<DataTableColumn<T>> columns, required List<T> rows, … })
```

**Signature and call sites are unchanged.** The rounded corners and hairline outline arrive from
`cardTheme`, not from this widget.

**Callers MUST NOT** pass their own card, border, radius or clip around a table. A screen that
needs a table takes this widget as-is.

---

## C3 — `EntityStatusFilterChips`

```dart
const EntityStatusFilterChips({
  required String filterKey,
  required EntityStatus? value,
  required ValueChanged<EntityStatus?> onChanged,
})
```

**Signature is unchanged; the meaning of the URL is not.**

- Selecting "All" now writes `status=all` rather than clearing the parameter.
- `value == null` still renders "All" as selected — the widget's own contract is untouched.

**Callers MUST** decode the facet through the shared helper rather than calling
`EntityStatus.values.byNameOrNull(query.facet('status'))` directly, or the default will not apply.

---

## C4 — search submission helper (new)

```dart
void submitCatalogSearch({
  required BuildContext context,
  required ListQuery query,
  required String path,
  required String submitted,
  required String current,
  required VoidCallback refresh,
})
```

**Guarantees**

- `submitted != current` → navigates with the new term, page reset to 0. **One** fetch.
- `submitted == current` → calls `refresh()`, preserving page, sort and every facet. **One** fetch.
- Never both.

**Callers MUST** pass the same `ref.invalidate(...)` closure they already pass to
`CatalogListStateView.onRetry`, so refresh and retry cannot diverge.

**`CatalogSearchBar` is not modified.** It still exposes no `onChanged`, so per-keystroke fetching
remains impossible to wire by mistake.

---

## C5 — `showAppSideSheet`

```dart
Future<void> showAppSideSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  WidgetBuilder? footerBuilder,
  double width = 360,          // new
  bool confirmDismiss = false, // new
})
```

**Guarantees**

- `width` applies to the side-sheet presentation only; compact widths keep the bottom sheet.
- `width` is clamped to the available width so the panel is never wider than the viewport.
- With `confirmDismiss: true`, barrier tap, Escape and the close button all route through the
  caller's dirty check before the panel closes.

**Existing callers** (the filter sheet, the shift sheet) pass neither new argument and are
unaffected.

---

## C6 — record panel host (new)

```dart
Future<void> showRecordSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder form,
  required bool Function() isDirty,
})
```

Wraps C5 at the record width with dismissal confirmation. Every one of the 14 converted entities
goes through this one function, so no module invents its own record panel.

**Guarantees**

- Opens at the record width, so a form of sufficient size renders in two columns.
- Closes on save and on delete without a dirty prompt.
- Prompts on any other dismissal while `isDirty()` is true.

---

## C7 — routes (removed)

For each of the 14 entities, these two routes are **deleted**:

```
/{entity}/new
/{entity}/:{id}          (including the ?view=true variant)
```

Replaced by a redirect to `/{entity}`.

**Callers MUST NOT** `context.push` a record path. Row taps, Edit icons and New actions all call
C6 instead.

**Out of scope — these routes remain**: `/products/*`, `/facilities/*`, `/taxpayer-issuers/*`,
`/users/*`, `/user-profiles/*` (FR-036).
