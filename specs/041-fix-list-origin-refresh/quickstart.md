# Quickstart: Validating 041 — List Origin Filtering & Cash Session Refresh

**Feature**: `041-fix-list-origin-refresh` | **Date**: 2026-09-20

How to prove this feature works, from cheapest check to a live round trip. Run
in order; each stage assumes the previous one passed.

---

## Prerequisites

- Flutter stable on `PATH`; dependencies fetched (`flutter pub get`).
- For stages 3–4 only: a running mbe-api dev instance (default
  `http://127.0.0.1:8000`) and a populated `.env` — copy `.env.template` and
  fill in real credentials. The account/privilege contract is
  `test/integration/TEST_ACCOUNTS.md`.
- For stage 4 (manual): the mbe-api dev database must contain **at least one
  order of each origin** plus, ideally, one pre-#209 order with no recorded
  origin. Without a null-origin row present, SC-003 cannot be observed manually —
  only asserted in tests.

---

## Stage 0 — Codegen

The only generation this feature needs is `freezed`, for `OpenSale`'s new field
and the two filter classes.

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Expected**: clean run. If the generator reports a missing part file for
`open_sale.freezed.dart`, the field was added without the `part` directive
already present — it is (`open_sale.dart`), so this should not occur.

**Not expected**: any change under `lib/generated/openapi/`. This feature
re-runs **no** OpenAPI codegen; both `exclude_origin` and `SalesOrderSummary.origin`
already exist there. A diff in that directory means something unrelated ran.

---

## Stage 1 — Static analysis

```bash
flutter analyze
```

**Expected**: no new issues. Watch specifically for unused-import warnings in
the two list controllers if `SaleOrigin` is imported before it is wired through.

---

## Stage 2 — Unit and widget tests

```bash
flutter test test/unit/features/sales/ test/widget/features/sales/
```

**Expected outcomes, mapped to requirements:**

| Check | Proves |
|---|---|
| `PosSalesFilter.fromQuery` decodes `hide-back-office`; absent facet ⇒ `false` | FR-001 default |
| `SalesOrdersFilter.fromQuery` decodes `hide-point-of-sale` | FR-003 default |
| `activeFilterCount` rises by 1 with the facet on | FR-007 (badge) |
| Repository forwards `excludeOrigin: SaleOrigin.backOffice` ⇒ `exclude_origin` present; `null` ⇒ parameter **absent** | FR-002, FR-012 |
| Toggling the drawer chip resets `pageIndex` to 0 | contract §3 invariant |
| `onClearAll` clears the origin facet with the rest | FR-007 |
| Origin column renders a distinct chip for `pointOfSale`, `backOffice` and `null` | FR-006 |
| No overflow at desktop width **and** the largest text-size level | constitution V/VI (research R5) |
| Cash sessions: list re-fetched after open, after close, **not** after cancel | FR-008, FR-009, FR-010 |

The cash-session checks must assert a **re-fetch count**
(`verify(() => cashSessionRepository.list(...)).called(2)`), not rendered rows —
see contracts/list-refresh.md §6 for why row assertions would pass against a
stale fixture.

---

## Stage 3 — Live integration

```bash
flutter test --dart-define-from-file=.env -j 1 test/integration/
```

`-j 1` matters: these suites share server state. Suites with missing credentials
skip rather than fail (each guards on a `_canRun` const).

| Suite | Account | Note |
|---|---|---|
| `pos_sales_list_flow_test.dart` | `MBE_POS_*` | Needs an already-open cash session |
| `sales_orders_flow_test.dart` | `MBE_POS_*` | Explicitly needs **no** open session |
| `cash_session_flow_test.dart` | `MBE_CASH_SESSION_*` | Walks open → refuse second → close; skips if the account already has an open/stale session, and leaves a closed one behind |

**What to assert live** (beyond the existing coverage): a list call with
`excludeOrigin` set returns no row carrying the excluded origin, and — the
guarantee that matters — a null-origin order, if one exists in the fixture data,
is still present in **both** lists' filtered results.

---

## Stage 4 — Manual verification in the running app

Tests cannot confirm the feature reads well; this stage is about judgment.

```bash
flutter run -d chrome --dart-define-from-file=.env
```

> **Amended 2026-09-20**: steps 1–5 originally exercised an origin facet and
> an origin column. Both were removed; each list is now permanently scoped
> with nothing to toggle (spec.md § Amendments). These are the current checks.

1. **POS list** (`/sales/pos-sales`): confirm the columns are exactly as they
   were before this feature — **no Origin column** — and that the filter
   drawer offers **no** origin control.
2. Confirm the rows are register sales only: a back-office order created
   today must **not** appear here. Then widen the date range back past the
   mbe-api#209 migration date and confirm the accepted consequence — sales
   predating it do not appear on this list at all, because it filters
   inclusively.
3. **Pedidos list** (`/sales/orders`): same two checks — no Origin column, no
   origin control — then confirm a register sale created today does **not**
   appear here, while older orders with no recorded origin **do** (this list
   is where that history stays reachable).
4. Confirm each list's other facets still behave as before: date range,
   status, and on Pedidos the admin-only salesperson/facility pickers,
   including their badge counts and clear-all.
5. **Column budget**: with the Origin column gone both tables are back to
   their pre-feature six columns — confirm no horizontal scroll at a
   laptop-width window, at the largest text-size level.
6. **Cash sessions** (`/sales/cash-sessions`): with the history list visible,
   open a session from the shift sheet. The new session must appear in the list
   **without** any further action. Then close it — via the shift card, which
   navigates to the session's detail screen — and confirm the list shows it
   closed on return. Finally, open the sheet and cancel; the list must not
   flicker or reload.

---

## Done when

- Stages 0–3 pass, with the integration suites either passing or explicitly
  skipped for missing credentials.
- Stage 4's six checks hold, in particular 5 (no horizontal scroll at the
  largest text size) and 6 (both open **and** close refresh the list).
- `git diff --stat lib/generated/openapi/` is empty.
