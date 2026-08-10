# Quickstart: validating the POS sales list, workspace and capture polish

**Feature**: `023-pos-ux-improvements` | **Date**: 2026-08-10

How to prove the feature works. *What* to build is in [plan.md](./plan.md),
[research.md](./research.md), [data-model.md](./data-model.md) and
[contracts/](./contracts/); this file is the run and validation guide.

---

## Prerequisites

- Flutter stable, Dart 3.10.3+
- mbe-api reachable — default `http://127.0.0.1:8000`, override with
  `--dart-define=API_BASE_URL=https://...`
- A user with `POS (44)` READ and a `point_sale` assigned in their settings —
  without the register assignment the list renders its "no register" state, which
  is a valid scenario but not the one most checks need
- A user with `SALES_ORDERS` UPDATE, for the Edit affordance; and one **without**
  it, to confirm the icon is absent rather than disabled
- An **open cash session** for the register (spec 021), for anything that opens a
  sale; and a moment with **no** open session, to check the blocked "Nueva venta"
- On the register: at least one draft sale, one confirmed sale with a balance, and
  one finished (paid, counter) sale — the three row states that differ

## Build and check

Run in this order — codegen is not optional; the filter, the list controller and
the localizations are all generated.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

`flutter analyze` must be clean and `flutter test` green. Run from the repo root:
the l10n parity test (`test/unit/core/l10n_parity_test.dart`) reads relative
paths and fails spuriously elsewhere.

## Unit and widget tests

```bash
flutter test test/unit/features/sales/
flutter test test/widget/features/sales/
flutter test test/unit/app/router/app_router_test.dart
flutter test test/unit/core/l10n_parity_test.dart
```

The checks carrying the most risk:

| Test | Proves |
|---|---|
| `pos_sale_workability_test.dart` | The six status/balance combinations from data-model §3, including that a zero-balance paid sale outside the resumable set is **not** workable and that an unresolved set makes rows provisionally non-workable rather than offering a doomed Edit |
| `pos_workspace_route_test.dart` | `/sales/pos/new` writes nothing on mount; the URL rewrites to the real id once a sale exists; a reload of that URL resumes the same sale rather than opening a second; a cancelled sale renders `pos_sale_unreachable` and opens no replacement |
| `pos_sales_list_screen_test.dart` | Row states → affordances (§3 of the list contract), the client-side status narrowing, and that returning from the workspace re-reads **both** providers — the selector set as well as the page |
| `product_search_field_test.dart` | Typing offers candidates without Enter **and never adds a line**; Enter with one match still adds directly; a slow lookup for a shorter prefix cannot overwrite a later one |
| `sale_line_row_test.dart` | Single row at a 1024-px surface with no overflow (FR-037a), two rows below 950, card at 390 |
| `customer_bar_test.dart` | The resolved name is visible in all three states; the terms dropdown mirrors the sale and issues **zero** writes when a credit customer is attached |
| `app_router_test.dart` | The `pos` gate still covers all three paths, and `AppShell.navigationShell.currentIndex` still resolves to the POS branch for `/sales/pos` — the branch-index assertion is what stands between a renumbering slip and a silently wrong screen |

**If unrelated tests fail at teardown** after the router change, suspect a missing
repository override in `app_router_test.dart`'s pump helper: the list screen now
fetches on mount, so its repository must be overridden wherever the router is
pumped at `/sales/pos`.

## Golden images

```bash
flutter test test/golden/                                  # verify
flutter test test/golden/ --update-goldens                 # accept changes
```

Two things must both hold:

1. `core_widgets_golden_test.dart` passes, **including its directory-scan test** —
   adding `lib/core/widgets/date_range_filter_chip.dart` without a golden
   scenario (or a justification entry) fails that scan by design (spec 022
   FR-023).
2. `pos_capture_golden_test.dart` (new) captures the restyled customer band, line
   row and totals footer at both widths and both themes. Its wide width is
   1024 px, which is also the tablet-landscape case FR-037a is about — so a
   regression in the single-row layout shows up as a golden diff, not just a
   failed assertion.

Review every diff before accepting it: refreshing these images is the point of
FR-051, and `--update-goldens` without looking defeats it.

## Live backend

```bash
flutter test test/integration/pos_sales_list_flow_test.dart
```

Needs `MBE_POS_*` credentials in `.env`; the test skips cleanly when they are
absent, like its siblings. It is the only place two endpoint behaviours get
settled rather than assumed (research U1, U2):

- what `search` on `GET /sales-orders` actually matches (folio? customer? both?)
- whether `date_to` includes its own day

Both are recorded as findings in the test's own comments when it runs, the way
spec 020's live findings were. It discovers its fixtures at runtime — never
hard-coded ids.

## Manual validation, by story

Run the app and sign in as the register user:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### US1 — the list

1. Open **Punto de Venta** from the rail. Expect the register's sales for today,
   newest first, with folio/date/customer/status/total/balance.
2. The draft sale and the unpaid sale show an Edit icon; the finished one shows it
   disabled with a tooltip; a cancelled one likewise.
3. Click the **finished** sale's row (not the icon). It must open read-only, with
   the read-only banner and every control inert — this is FR-006a, the check most
   likely to be missed.
4. Widen the date range to yesterday: earlier sales appear, paged. Clear the
   chip: it returns to **today**, not to everything.
5. Set the status facet to `paid`: no `completed` rows leak in (the client-side
   narrowing).
6. Press **Nueva venta** with no open shift: disabled, reason stated, link to the
   shift screen. Open a shift; it enables.

### US2 — the workspace

7. Open a sale. Expect: no rail, no drawer, a Back arrow, and the reference,
   selector and step indicator in the app bar — no separate band beneath it.
8. At 1440×900 with one line, look at the gap above the footer: there must be
   none. Add lines until they scroll; header, search and footer stay put.
9. Reload the browser on `/sales/pos/new` before adding anything: exactly one
   sale, not two. Check the register's list afterwards for stray empty drafts.
10. Press Back from a sale with no lines, then check the list: the empty draft is
    gone.
11. Hand-type `/sales/pos/999999`: the unreachable panel with a way back, and no
    new sale.

### US3 — the customer band

12. Confirm the customer's name is visible **in the band itself**, not only in the
    facts row — the blank-field bug.
13. Press **Buscar**: the facts animate out and the picker takes focus. Type: a
    spinner while candidates load. Pick a customer: a spinner while the sale
    updates, then the band returns to facts with the new customer and re-priced
    lines.
14. Press Buscar and dismiss with Escape: the previous customer is intact and
    nothing was written.
15. With a customer that has no credit line, open the terms dropdown: `Crédito` is
    not selectable and the reason is stated. Attach a customer that *has* a credit
    line: the terms shown are whatever the sale reports, and nothing changed them
    on the screen's initiative.
16. Check the fulfilment mode control sits to the right of the band at desktop
    width and below it at ~800 px.

### US4 — the product field

17. Type three characters and wait: candidates appear with no Enter, and **no line
    is added**.
18. Type a full product code and press Enter (what a scanner does): the line is
    added immediately, the field clears and keeps focus.
19. Type a short prefix, then keep typing quickly: the list that lands matches
    what is currently typed.

### US5/US6 — line and footer

20. At 1440 px each line is one row with a thumbnail placeholder, the name
    prominent and the code beneath. Narrow to ~800 px: two rows, nothing clipped.
    Narrow to a phone: the stacked card.
21. **On a tablet in landscape (or a 1024-px window)**: still one row. This is the
    explicit requirement, and the width where the budget is tightest.
22. The footer shows labelled Artículos/Subtotal/Descuentos/IVA groups with the
    total dominant and right-aligned, and **Continuar al cobro on the same band**.
    With no lines it is present and disabled.

## What "done" looks like

- `flutter analyze` clean, `flutter test` green, goldens reviewed and accepted.
- The 22 manual checks above pass at 1440 px, ~1024 px, ~800 px and 390 px.
- No literal colour, spacing or font-size value introduced in any touched widget
  (grep the diff for `fontSize:`, `Color(0x`, and bare `EdgeInsets.all(1` before
  calling it finished).
- Both `.arb` files carry every new key; the parity test proves it.
