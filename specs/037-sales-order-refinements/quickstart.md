# Quickstart: Validating Sales Order Refinements

**Feature**: 037-sales-order-refinements | **Date**: 2026-09-04

How to prove this feature works. Details of *what* should happen live in
[contracts/](./contracts/); this is the run guide.

## Prerequisites

- Flutter 3.44.2 stable, dependencies fetched (`flutter pub get`).
- For the live checks: a reachable mbe-api and `.env` credentials, launched with
  `--dart-define-from-file=.env` (VS Code's `.env.settings` launch config already does this).
- Two customers on the dev tenant: **one with a credit limit above zero**, one with zero. The credit
  customer must have **no overdue orders**, or the server will refuse credit terms and you will be
  validating the refusal path instead of the happy path (see contracts/payment-terms-default.md C3).

## Automated checks

```bash
flutter analyze
flutter test                         # full suite
flutter test test/widget/features/sales/   # the feature's own surface
```

Targeted, while iterating:

```bash
flutter test test/widget/features/sales/order_header_disclosure_test.dart
flutter test test/widget/features/sales/customer_bar_test.dart
flutter test test/widget/features/sales/sales_orders_compact_test.dart
flutter test test/unit/core/l10n_parity_test.dart
```

Goldens re-baseline on the label rename — expected, not breakage (research R9):

```bash
flutter test test/golden/ --update-goldens      # review every changed PNG before committing
flutter test test/screenshots/ --update-goldens
```

Only `pos_customer_bar_*` (4 files) and capture-surface screenshots `02`–`07` should change. **If a
golden outside that set moves, stop and find out why** — nothing else in this feature is supposed to
be visible to them.

## Manual validation

### 1. One balance, one terms control (US1)

Open an existing order for a customer with an outstanding balance.

- Exactly one balance on screen, in the customer bar. Expand and collapse "More details" — still
  exactly one.
- Exactly one payment-terms control, in the customer bar, captioned **"Forma de pago"**.
- The credit-limit figure (or "no credit line" hint) still sits beneath it.
- Open the register and confirm its customer bar carries the same caption.

### 2. Order and placement (US3)

Same screen.

- The customer bar sits **above** the header panel.
- Expand the disclosure: Priority, Currency, Exchange rate, Tax ID, Delivery details, Contact,
  Comment — in that order, comment last and full width.
- Every field still edits, and each edit still saves without a Save button.

### 3. Credit terms default (US2) — four cases, and they are not interchangeable

This is where the research matters. Watch the network calls, not just the UI.

| Case | Steps | Expect |
|---|---|---|
| New back-office order, credit customer | New order → pick the credit customer | Terms show **Crédito**. **One** request (the create). This path already worked; you are guarding a regression. |
| New back-office order, cash customer | New order → pick the zero-limit customer | Terms show **Contado**, one request. |
| Register, credit customer | Open the register → scan a product → attach the credit customer | Terms flip to **Crédito**. This is the reported bug, fixed. |
| Switch a credit order to a cash customer | On an order showing Crédito, change to the zero-limit customer | Terms fall back to **Contado** — not left on credit. |

Then confirm the default does not fight the user:

- Set terms to Contado on a credit customer's order, then edit the comment, the currency and the
  priority. Terms stay Contado.
- Re-attach the same customer. Only *that* re-applies the default.

If you have a credit customer **with** overdue orders, attach them: the customer must attach
normally, terms stay Contado, and **no error banner appears** (FR-010a).

### 4. Density (US4) — only after the mock is approved

- Compare the expanded panel against `main` at the same window width and text size. It should be
  visibly shorter; SC-004 asks for at least 20%.
- Cycle all four text-size levels in user settings at both a wide window and ~390 px. No clipping, no
  overflow, no ellipsized captions.
- Every dropdown still opens and writes; every picker still launches; read-only values are still
  readable and still clearly not editable.

### 5. Navigation (US5)

- In the Sales group: Point of Sale, then Sales Orders.
- Sign in as a user with sales-order access but no register privilege — Sales Orders is still there.

## What "done" looks like

- `flutter analyze` clean, full suite green.
- Only the expected goldens re-baselined.
- All four rows of §3 pass, **including** the one-request assertion on the first — a passing UI with
  two requests means the fast path was broken.
- The panel is measurably shorter, at every text-size level, with no overflow.
