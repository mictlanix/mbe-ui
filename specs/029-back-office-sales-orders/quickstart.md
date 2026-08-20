# Quickstart: validating Back-Office Sales Orders

**Feature**: `029-back-office-sales-orders` | **Date**: 2026-08-19

How to prove the feature works. *What* to build is in [plan.md](./plan.md),
[research.md](./research.md), [data-model.md](./data-model.md) and
[contracts/](./contracts/); this file is the run and validation guide.

---

## Prerequisites

- Flutter stable, Dart 3.10.3+
- mbe-api reachable — default `http://127.0.0.1:8000`, override with
  `--dart-define=API_BASE_URL=https://...`
- **Four accounts**, because the scoping rules are the feature:
  1. an ordinary user with `SALES_ORDERS` READ+CREATE+UPDATE and a
     `point_sale` in their settings — the main path;
  2. the same, but with **no** `point_sale` — proves FR-014 (list works, creation
     is blocked and explained);
  3. a read-only user (`SALES_ORDERS` READ alone) — proves every mutating
     affordance is *absent*, not disabled;
  4. an **administrator** — proves the salesperson and facility facets and the
     everyone's-orders default.
- Data: in one facility, at least one draft order, one confirmed order, one paid
  order and one cancelled order; **and at least one order belonging to a different
  employee**, which is the only way to see FR-006 actually working.

## Build and check

Codegen is not optional — the filter, both controllers, the `SaleEditor`
provider and the localizations are all generated.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

`flutter analyze` must be clean and `flutter test` green. Run from the repo root:
the l10n parity test reads relative paths and fails spuriously elsewhere.

## The regression gate — run this first

```bash
flutter test test/widget/features/sales/ test/unit/features/sales/
```

**Every pre-existing POS test must pass with no edit to its assertions** (SC-007).
That is the whole safety net for the `saleEditorProvider` refactor. If a POS test
needs changing to go green, the refactor went further than R1 intended — stop and
re-read the default-provider decision rather than editing the test.

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
| `sale_editor_isolation_test.dart` | An order open on `/sales/orders/:id` and a sale in progress at the register are **two different `Sale`s** — mutating one leaves the other untouched. The direct expression of FR-030, and the only test that would catch the refactor's worst failure mode. |
| `sales_orders_scoping_test.dart` | `mine` is `true` for an ordinary user and `false` for an administrator; a `salesperson`/`facility` facet **in the URL** is dropped for a non-administrator before the request is built (SC-009, the hand-edited-address edge case). |
| `sales_orders_filter_test.dart` | Month default, `yyyy-MM-dd` round-trip, unparseable values degrading to defaults, `activeFilterCount`, and — critically — that the "today" anchor is date-truncated. An untruncated anchor makes the list spin forever, confirmed in spec 023. |
| `sales_orders_list_screen_test.dart` | Columns, row action visible only on drafts, the four list states, and the admin-vs-ordinary drawer contents. |
| `order_screen_test.dart` | Nothing is written on mount (SC-005); the first line creates the draft; a refused confirm names every offending line and stays a draft. |
| `order_screen_readonly_test.dart` | A confirmed order renders read-only **except priority**; a cancelled one offers nothing; the no-register notice replaces the create action without blocking the list. |
| `sale_mapping_test.dart` (extended) | The seven new header fields map, and `Priority` decodes all four members with a safe fallback. |
| `app_router_test.dart` | The `/sales/orders` guard is `salesOrders`, not `pos`; `NavBranch.salesOrders` still resolves to the right branch index — the assertion standing between a renumbering slip and a silently wrong screen. |

## Live backend

```bash
flutter test test/integration/sales_orders_flow_test.dart
```

Skips cleanly without credentials in `.env`, like its siblings. It discovers its
fixtures at runtime — never hard-coded ids. Two things it settles rather than
assumes:

- whether `date_to` includes its own day (the month-range upper bound depends on
  it);
- that `mine=true` really does match creator **and** updater **and** salesperson,
  not just one of them.

Record both as findings in the test's own comments when it runs, the way spec 020
and 023 did.

## Manual validation, by story

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### US1 — capture and confirm (P1)

1. Sign in as account 1. Open **Pedidos** from the rail.
2. Click **New order**. The screen opens with the walk-in customer, the default
   currency and the implied terms. **Check the network tab: no `POST` yet.**
3. Search a product and add it. *Now* the `POST` fires, followed by the line.
   Price is display-only; quantity, discount, tax, warehouse and comment are not.
4. Change the customer to one with a price list. Every line reprices; totals
   follow the server.
5. Set promise date, priority, salesperson and a comment. Each is one request.
6. Confirm. A folio appears, the status chip flips to Completed, the screen goes
   read-only — priority still changes.
7. Add a zero-priced line to a fresh order and confirm: refused, every offender
   named, still a draft.

### US2 — resume and cancel (P2)

Reload the order's URL — same order, not a second one. Edit a line, navigate away,
come back: the change stuck. Cancel a draft: confirmation dialog, then Cancelled
and read-only. Cancel an order with a payment against it: refused, message shown.

### US3 — find (P2)

Default view is the current month, newest first. Type a folio → that order. Type a
customer name → their orders. Set a date range and a status in the drawer → the
badge counts two. Copy the URL, open it in a new tab → same view. Page forward and
back → counts stay consistent.

### US4 — read a finished order (P3)

Open a paid order: everything read-only, balance and paid state visible. Sign in
as account 3 (read-only): no New order, no Edit icon, no confirm, no cancel —
absent, not greyed.

### US5 — supervise (P3)

Sign in as account 4 (administrator): the list shows **other people's** orders.
The drawer now has salesperson and facility. Pick a salesperson → only theirs, and
the facet is in the URL with a *name* in the picker, not a bare id. Switch
facility → that facility's orders; start a new order → it is created in **your
own** facility, and the screen said so first.

Then sign back in as account 1 and paste the administrator's filtered URL: the
facets are ignored and only your own orders come back (SC-009).

### FR-014 — no register

Sign in as account 2. The list loads normally. **New order** is replaced by a
notice naming the missing setting. Nothing 422s.

## Definition of done

- `flutter analyze` clean, `flutter test` green, the POS suite unmodified.
- Every acceptance scenario in [spec.md](./spec.md) walked manually at both the
  expanded and compact width tiers.
- No `DateFormat`, `toStringAsFixed` or hand-built percentage string anywhere in
  the new code — everything through `formattersProvider` (spec 028).
- Both `.arb` files in parity; `es-MX` authored first.
