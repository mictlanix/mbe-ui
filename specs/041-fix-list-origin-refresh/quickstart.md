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

1. **POS list** (`/sales/pos-sales`): confirm the default view is unchanged from
   before the feature — same rows, same columns plus Origin, same counts.
2. Open the filter drawer (`Icons.tune`), turn on "hide back-office orders".
   Confirm: back-office rows vanish, the badge count rises by one, the page
   returns to the first, and any unrecorded-origin rows **remain**.
3. Turn it off; confirm the full list returns. Change the date range with the
   facet on; confirm the origin facet survives (FR-007).
4. **Pedidos list** (`/sales/orders`): repeat 1–3 mirrored, with
   "hide point-of-sale sales".
5. **Column budget**: at the largest text-size level (user settings) and a
   laptop-width window, confirm neither table scrolls horizontally and no cell
   clips. This is the risk R5 flagged — if it fails, switch the chip to
   icon-only per the documented fallback rather than widening the table.
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
