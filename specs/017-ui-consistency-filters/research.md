# Phase 0 Research: Cross-Screen UX Consistency & Filtering Backfill

**Feature**: `017-ui-consistency-filters` | **Date**: 2026-07-25 | **Plan**: [plan.md](./plan.md)

Every finding below was verified against the shipped code on `main`
(`44b8e95`). Where a claim could not be settled by reading, it was settled by
running a behavioral probe (§3) — one initial assumption in the spec was wrong
and has been corrected there.

---

## §1 — Current-state audit: the shipped surface

**18 list screens** and **18 record detail screens** across three modules.

| Module | List screens | Detail screens |
|---|---|---|
| `catalog` | cash drawers, customers, employees, expenses, facilities, labels, payment method options, points of sale, products, suppliers, taxpayer issuers, taxpayer recipients, vehicle operators, vehicles, warehouses (15) | same 15 + point of sale detail (15) |
| `pricing` | exchange rates, price lists (2) | exchange rate, price list (2) |
| `auth` | users (1) | user (1) |

Two additional screens are neither catalog lists nor record forms and are treated
separately: `pricing_screen.dart` (a product-scoped price table) and
`merge_products_screen.dart` (a wizard). Both exhibit the §6 state-rendering
problem and are in scope for that only.

**Decision**: Treat "all list screens" and "all record screens" as the closed sets
above. Any screen added between this plan and implementation joins the set.

---

## §2 — Finding: the read-only → edit affordance and the duplicated action set

**Verified**: all 18 detail screens carry an identical block —

```dart
appBar: AppBar(
  title: Text(title),
  actions: [
    if (readOnly && canUpdate && widget.<id> != null)
      IconButton(
        key: const Key('edit_<entity>_button'),
        icon: Icon(CatalogAction.edit.icon),
        tooltip: l10n.editRecordTooltip,
        onPressed: () => context.replace('/<path>/${widget.<id>}'),
      ),
  ],
),
```

and, in the form body, a `FilledButton` Save and an error-colored `FilledButton`
Delete, each wrapped in `FormGridChild(span: FormGridSpan.full, …)` — i.e. both
stretch the full width of the form on a desktop display — plus a hand-copied
`_confirmDelete` `AlertDialog`. `lib/features/catalog/presentation/expense_detail_screen.dart:88`
and `:149-183` are the canonical instance; the other 17 differ only in entity
nouns and l10n keys.

**Decision**: introduce `core/widgets/record_form_actions.dart` exposing a single
`RecordFormActions` widget plus a `confirmRecordDelete` helper, and adopt it on all
18 screens. Contract in [contracts/record-form-actions.md](./contracts/record-form-actions.md).

**Layout decision**: a right-aligned `Wrap` (so it degrades to stacked buttons on
Compact) — **not** a full-width stretch — placed as the last `FormGridChild` with
`FormGridSpan.full`. Fixed left-to-right order: **Delete, then Edit-or-Save**. The
destructive action sits furthest from the primary one, and the primary/confirming
action is rightmost, matching the `AlertDialog` convention the codebase already
uses in `_confirmDelete`.

**Rationale for `OutlinedButton` for Edit**: it is the requested treatment, and it
correctly ranks Edit below Save — Edit is a mode switch, not a commit. Save stays
`FilledButton`; Delete stays error-colored, but becomes an `OutlinedButton` in error
colors rather than a filled error block, so a destructive action is not the loudest
thing on a read-only-looking form. *(This last point is a deliberate change of
appearance beyond a straight move; recorded here so it is a decision, not a drift.)*

**l10n**: `RecordFormActions` takes its labels as parameters
(`editLabel`/`saveLabel`/`deleteLabel`, and the confirm dialog's title/message),
exactly as `buildCatalogRowActions` already takes `editTooltip`. This keeps
`core/widgets/` free of a localization dependency, which is the established
convention in this repo — **except** in `entity_status_controls.dart` and
`error_banner.dart`, which do reach for l10n / hard-code strings respectively (see
§6). Follow the `catalog_action_icons` convention, not those.

**Alternatives considered**:
- *Leave Save/Delete alone; only move Edit.* Rejected: it would put Edit in a
  shared component and leave its two siblings copy-pasted, so the three could drift
  apart again — and it would make the same 18-file edit necessary again next time.
- *A persistent bottom action bar pinned to the viewport.* Rejected: out of
  proportion for forms that already scroll as a unit, and no precedent in the app.

---

## §3 — Finding: list view state, corrected by probe

The spec's first draft asserted that returning from a record resets the list. **A
behavioral probe disproved that**, and the spec was corrected before planning.

**Probe** (throwaway widget test, since deleted): reproduced the real navigation
shape — the warehouses list mounted inside a `StatefulShellRoute.indexedStack`
branch, with the record route as a **top-level sibling**, exactly as
`app_router.dart` registers them — then applied a search term and a status facet,
paged to index 1, pushed the record route, and popped.

| Path | search | status facet | page |
|---|---|---|---|
| after applying filters + paging | `north` | `inactive` | 1 |
| after `push(detail)` → `pop()` | `north` | `inactive` | **1 (preserved)** |
| after `invalidate(listController)` (what a save/delete does) | `north` | `inactive` | **0 (reset)** |

**Why**: `push` leaves the shell page mounted beneath the record page, so the
autoDispose providers backing the list are never disposed. But every form
controller calls `ref.invalidate(<entity>ListControllerProvider)` after a
successful mutation (`expense_form_controller.dart:91`, and 15 more), and every
list controller's `build()` hard-codes the first page:

```dart
Future<CatalogPage<Warehouse>> build() {
  final filter = ref.watch(warehouseFilterControllerProvider);
  return _fetch(filter, pageIndex: 0);   // ← page is not part of the rebuilt state
}
```

So the page silently resets on create/update/delete while the filters stay applied
— the list looks right but shows different records.

**In-repo precedent for the fix**: `UsersController.refresh()`
(`users_controller.dart:133`) already does it correctly —
`goToPage(current?.pageIndex ?? 0)` — re-fetching the current page instead of
invalidating. Users is the one screen without this bug.

**Decision**: this is fixed *for free* by §4 — once the page index is part of the
list controller's family key (read from the URL), `invalidate` re-runs `build` with
the same page. No separate mechanism is needed. FR-024's already-correct
view-then-back path gets a regression test rather than new code.

**Still fully true and unaddressed**: no list view can be shared, bookmarked, or
survive a browser refresh, because no part of the view state reaches the URL. That
is the substance of US3.

---

## §4 — Decision: how list state becomes URL-addressable

**Chosen**: make the **URL the only source of truth** and delete the mutable filter
notifiers, rather than keeping them and two-way-syncing.

Shape:

1. `core/navigation/list_query.dart` — a `ListQuery` value (search, page, and a
   typed facet bag) with `fromUri` / `toUri`. Encoding contract in
   [contracts/list-query.md](./contracts/list-query.md).
2. Each list route's builder decodes `state.uri` and passes the result to the
   screen as a constructor argument, exactly as `forceReadOnly` is passed today
   (`app_router.dart:276`).
3. Each entity's filter becomes a plain immutable value derived from `ListQuery`
   (`XFilter.fromQuery`), including `pageIndex`. The `XFilterController` notifiers
   are **removed**.
4. The list controller becomes a family keyed by that filter:
   `build(XFilter filter)` — so a different URL is a different provider instance,
   and `invalidate` re-fetches the same page.
5. Every filter/search/page interaction calls `context.go(uri)`. Nothing writes
   filter state to a notifier.

**Why one-way**: a two-way sync between a notifier and the URL needs a re-entrancy
guard on every screen and is the classic source of "filter flickers back" bugs. A
single direction (URL → provider → UI, UI → URL) has no such failure mode, and it
satisfies FR-019 literally.

**Why `context.go` and not `replace`**: `go` reports a new route to the platform,
which on web produces a browser history entry — that is what makes FR-022's Back
button work. `replace` would silently overwrite history.

**History-spam check**: the search box already fires on submit
(`CatalogSearchBar.onSubmitted`), not per keystroke, so no debounce is needed and no
history entry is created per character.

**Cold-load display text is the real wrinkle.** Foreign-key facets currently keep a
human-readable label in notifier state alongside the id — `WarehouseFilter`
carries both `facilityId` and `facilityDisplayText`
(`warehouses_list_controller.dart:18-24`). A URL carries only the id, so opening a
shared link leaves the picker showing an id-less blank while the results are
correctly filtered — violating FR-018 ("restored values visible in the filter
controls"). **Decision**: on cold load, resolve id → label through the facet's own
repository `get(id)` (all 14 catalog repositories expose one), rendering a
placeholder until it resolves and falling back to the raw id if it fails. Affected
facets: facility (warehouses, cash drawers, points of sale, payment method
options), warehouse (points of sale), price list + salesperson (customers),
employee (vehicle operators), supplier (products, new in §5), labels (products,
multi), and currency base/target (exchange rates).

**Alternatives considered**:
- *Encode display text in the URL too.* Rejected: ugly, unbounded, and goes stale
  the moment the referenced record is renamed.
- *Keep the notifiers, seed them from the URL on mount, and write back on change.*
  Rejected: needs a guard per screen (18 chances to get it wrong) and leaves two
  sources of truth, so FR-019 could not be stated as an invariant.
- *`shared_preferences`-backed sticky filters.* Rejected outright — constitution
  §VII forbids local persistence of server state, and it would not make a view
  shareable.

**Risk to retire first**: whether `context.go` to the same shell-branch path with
different query parameters preserves the branch rather than rebuilding it. The
probe covered push/pop but not this. **Mitigation**: prove it with a widget test on
one screen (Vehicles) before the pattern is rolled out to the other 17 — this is
the first implementation task and a hard gate.

---

## §5 — Finding: filter facets the API accepts but the UI ignores

Extracted from the generated clients in `lib/generated/openapi/lib/src/api/` and
compared with each `domain/repositories/*.dart` `list()` signature.

| Screen | Client accepts | Repository declares | Gap |
|---|---|---|---|
| Vehicles | `search`, `status` | `search` | **`status`** |
| Vehicle Operators | `search`, `employee`, `status` | `search`, `driverId` | **`status`** |
| Users | `search`, `status` | `search` | **`status`** |
| Products | `search`, `label`, `status`, `stockable`, `salable`, `purchasable`, `supplier` | all but `supplier` | **`supplier`** |
| Customers | `search`, `status`, `priceList`, `salesperson` | all four | — |
| Employees | `search`, `status`, `salesPerson` | all three | — |
| Warehouses / Cash Drawers | `search`, `facility`, `status` | all three | — |
| Points of Sale | `search`, `facility`, `warehouse`, `status` | all four | — |
| Payment Method Options | `facility`, `status` (no `search` upstream) | + `search`, wired pending | tracked upstream, unchanged |
| Exchange Rates | `dateFrom`, `dateTo`, `base_`, `target` | all four | — |
| Labels / Suppliers / Expenses / Price Lists / Taxpayer Recipients / Taxpayer Issuers | `search` only | `search` | — (correctly search-only) |

`vehicles_list_screen.dart:19-22` documents itself as "Search-only (no filter
drawer): the list endpoint exposes no facets beyond `search`" — that was true when
spec 013 shipped and is false now. The comment must be corrected, not just the code.

**Decision**: close the four gaps using the existing shared controls, following the
Warehouses screen verbatim as the template
(`warehouses_list_screen.dart:136-186`): `EntityStatusFilterChips` for the three
status facets, `CatalogEntityPicker` for the supplier facet, both inside
`showCatalogFilterSheet`, with a `CatalogFilterBar` filter button carrying an
active-facet count badge.

Vehicles and Users have **no filter sheet at all** today and gain their first one.
Vehicle Operators and Products already have one and gain a control inside it.

**Decision on FR-015 (the standing audit)**: encode the table above as a
**unit test** that reflects over each repository's declared list parameters and
asserts they match a checked-in expectation, so a future upstream addition fails a
test rather than going unnoticed for two specs. This is what makes FR-015 a
durable requirement rather than a one-off review.

---

## §6 — Finding: list loading / empty / error rendering, and a localization defect

**Verified**: **zero** of the 18 list screens use `ErrorBanner`. All 18 render:

```dart
loading: () => const Center(child: CircularProgressIndicator()),
error: (e, _) => Center(child: Text(l10n.<entity>LoadError(e))),
data: (page) => page.items.isEmpty
    ? Center(child: Text(l10n.no<Entity>Found))
    : DataTableView<…>(…),
```

`l10n.<entity>LoadError(e)` interpolates the raw thrown object into user-facing
text, contradicting constitution §III, which requires errors to be "surfaced via
the shared error-display widget rather than handled ad hoc per screen". The record
screens do this correctly. There is no distinction between an empty catalog and an
over-filtered one, and no recovery affordance in either case.

**Blocking defect discovered while designing the fix**: `ErrorBanner` — the very
widget §III points at — **hard-codes its messages in English**
(`error_banner.dart:60-75`: `'The requested item was not found.'`,
`'Could not reach the server. Check your connection and try again.'`, …). It
accepts a `BuildContext` and never uses it. In an `es-MX`-first product this
violates constitution §V. Pointing 18 more screens at it would multiply an existing
bug across the app.

**Decision**: localize `ErrorBanner` as a prerequisite task of US5 — move those five
message variants into both `.arb` files and read them via
`AppLocalizations.of(context)`. This is in scope: US5 cannot be delivered
compliantly without it. It also fixes the record screens that already use it.

**Decision**: add `core/widgets/list_state_views.dart` with one widget per state —
loading, empty, filtered-empty (with a "clear filters" action), and error (rendering
the mapped `AppError` through `ErrorBanner` plus a retry action). Callers supply
entity-specific strings, per §2's l10n convention. Contract in
[contracts/list-state-views.md](./contracts/list-state-views.md).

**Distinguishing empty from filtered-empty** falls out of §4: the screen already
holds a `ListQuery`, so `query.isEmpty` decides which of the two to render — no new
state is needed.

**Error typing check**: repositories already map `DioException` → `AppError` via
`_toAppError`, so `AsyncValue.error` carries an `AppError` today; the shared error
view can rely on that, with a defensive fallback to `ServerError` for anything else.

---

## §7 — Decision: the constitution amendment (§VI → v1.10.0)

Constitution §VI currently states, in the paragraph added at v1.8.0:

> `AppBar.actions` MUST be reserved for the single read-only-to-edit toggle
> affordance already codified above (and, where applicable, the record's own
> delete action per the detail-screen delete rule above).

US1 reverses this. Per the Governance section, the amendment process is: propose
against DESIGN.md first, then update the constitution with a semver bump.

**Decision**: **MINOR → 1.10.0** — this materially redefines an existing
principle's operative rule but adds no principle and removes none, which is exactly
how the v1.5.0 (row action set redefinition) and v1.8.0 (`AppBar.actions`
restriction) bumps were classified. Precedent is on record in the file's own Sync
Impact Report.

**Decision on ordering**: DESIGN.md §4.2/§4.3 → constitution §VI + Sync Impact
Report → screens. The amendment lands in the same PR as the first converted screen,
never after all 18, so the repository never contains a screen that contradicts the
written rule (FR-005).

**New rule text to land** (drafted here so implementation transcribes rather than
invents): the read-only → edit toggle moves into the record's shared form action
area alongside Save and Delete; `AppBar.actions` on a record screen carries nothing
by default; the previously-allowed app-bar delete exception is retained verbatim so
no shipped screen is retroactively non-compliant.

---

## §8 — Decision: localization strategy and volume

New keys land in both `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` (671 keys
each today, exactly in sync — that parity is itself worth asserting).

Estimated additions:
- 5 — `ErrorBanner` message variants (§6).
- ~6 — shared list-state strings that are genuinely generic (retry, clear filters,
  filtered-empty title, generic load-failure title).
- ~8 — the four backfilled facets: filter-sheet titles/labels for Vehicles and
  Users (which gain their first sheet), plus a supplier facet label.
- 0 — the record action area reuses `saveButton`, `editRecordTooltip` (repurposed
  as a label), and each screen's existing `delete<Entity>Button` /
  `delete<Entity>ConfirmTitle` / `…Message` keys.

**Roughly 19 new keys × 2 locales.** Deliberately low: the shared components take
caller-supplied strings, so per-entity wording keeps using the keys that exist.

---

## §9 — Blast radius and test strategy

**Files touched**: 18 detail screens, 18 list screens, ~18 list controllers, 4
repositories + their impls (`vehicle`, `vehicle_operator`, `user`, `product`),
`app_router.dart` (every list route builder gains query decoding), 2 `.arb` files,
`ErrorBanner`, DESIGN.md, the constitution. Plus 4 new files under `core/`.

**Existing tests that will fail by design**: **22 assertions across 15 widget test
files** reference the app-bar `edit_<entity>_button`
(`test/widget/features/{auth,catalog}/*_detail_screen_test.dart`). They must be
updated in the same commit as the screen they cover, not batch-fixed afterward —
otherwise the suite is red across the whole conversion and stops being a signal.

*Not affected*: `pricing_screen_test.dart:203` asserts on `edit_price_button_1`,
which is a **row action inside the pricing table**, not a detail-screen edit toggle.
A naive `edit_.*_button` grep matches it; it must not be "fixed".

**Test surface is complete**: all 18 detail screens and all 18 list screens already
have widget test files, so every conversion has an existing test to update rather
than one to invent. Three detail-screen tests (point of sale, exchange rate, price
list) exist but do not currently assert on the edit affordance — they gain that
assertion during conversion.

**New tests**:
- Unit: `ListQuery` round-trip (encode → decode → equality), including the edge
  cases in the spec (accented and reserved characters, multi-valued label facet,
  ISO dates, out-of-range page, unknown facet value ignored).
- Unit: the §5 repository-parameter audit test.
- Widget: `RecordFormActions` (each RBAC combination, create/view/edit modes,
  submitting state, confirm-dialog wiring) and the list-state views.
- Widget, per converted screen: filters restore from URL; changing a filter updates
  the URL.
- Regression: the view-then-back path that already works (§3), so §4's refactor
  cannot quietly break it.
- Integration: one end-to-end pass — filter a list, page, open a record, edit,
  save, confirm the same page and filters come back.

---

## §10 — Decision: sequencing

The 18-screen conversions are mechanical but numerous; the shared pieces they
depend on are small but load-bearing. Sequence accordingly:

1. **Shared components first** (`RecordFormActions`, `ListQuery`,
   `list_state_views`, `ErrorBanner` localization) — each with its own tests, none
   wired up yet. Nothing user-visible changes.
2. **Governance** (DESIGN.md + constitution §VI) with the first converted screen.
3. **One vertical slice on one screen** — Vehicles, chosen because it needs all
   four changes at once (new filter sheet, new facet, URL state, state views) and
   is small. This retires §4's open risk before it can cost 18×.
4. **Fan out** the remaining 17, module by module.
5. **The audit test** (§5) last, once every repository is in its final shape.

Steps 1–3 are the risky part; step 4 is repetition. `/speckit-tasks` should reflect
that asymmetry rather than treating all 18 screens as equal-risk work.
