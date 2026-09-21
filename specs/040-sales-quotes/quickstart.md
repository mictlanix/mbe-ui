# Quickstart: Validating Sales Quotes

**Feature**: `040-sales-quotes` | **Date**: 2026-09-20

How to prove the feature works end to end — and, just as importantly, how to prove the register
and the back-office order workspace still do. This feature edits files both of them render.

---

## Prerequisites

- A running mbe-api with a reachable dev database.
- A signed-in user with `salesQuotes` read + create + update. For the conversion story they also
  need `salesOrders` **create**, and **a point of sale configured** — without one, convert
  answers 422 and only the refusal path is testable (FR-030).
- At least one customer that is **not** the deployment's generic walk-in customer, with a price
  list on file.
- At least one product with a price on that customer's price list.
- `POS_DEFAULT_CUSTOMER_ID` in the build matching mbe-api's `default_customer_id`, or the
  generic-customer exclusion is checked against the wrong id.

### Two live checks this feature's design rests on

Neither can be asserted from the client. Do them before trusting any manual result.

```bash
# 1. The quote list is facility-scoped server-side (research R5).
#    Sign in as users in two different facilities and compare. Each must see only its own.
#    The endpoint has no `facility` parameter, so this is the server's own scoping or nothing.
curl -s -H "Authorization: Bearer $TOKEN_FACILITY_A" "$API/api/v1/sales-quotes?limit=100" | jq '.items | length'
curl -s -H "Authorization: Bearer $TOKEN_FACILITY_B" "$API/api/v1/sales-quotes?limit=100" | jq '.items | length'

# 2. The live shape of convert's refusal bodies (research R4, contracts §2).
#    `detail` must be a string, or a map carrying `message`. Anything else and the banner
#    shows only a generic headline.
curl -s -X POST -H "Authorization: Bearer $TOKEN" "$API/api/v1/sales-quotes/<draft id>/convert" | jq .
curl -s -X POST -H "Authorization: Bearer $TOKEN" "$API/api/v1/sales-quotes/<expired id>/convert" | jq .
```

---

## Automated checks

```bash
# Everything, as CI runs it.
flutter analyze
dart run build_runner build --delete-conflicting-outputs   # freezed + riverpod for the new files
flutter test

# The regression that matters most: the two existing hosts, untouched.
flutter test test/widget/features/sales/
flutter test test/unit/app/router/app_router_test.dart

# Host isolation across all three hosts (contracts §4).
flutter test test/widget/features/sales/sale_editor_isolation_test.dart
```

`flutter test test/widget/features/sales/` must pass **with no test file edited except**
`sale_editor_isolation_test.dart` (generalized to three hosts) and `pos_test_harness.dart`
(gaining `testQuote()` / `testQuoteLine()`). Any other POS or order test needing a change is a
signal that FR-040 has been broken — investigate rather than update the expectation.

### Live-backend flow

```bash
flutter test test/integration/sales_quotes_flow_test.dart \
  --dart-define=MBE_POS_USERNAME=... --dart-define=MBE_POS_PASSWORD=...
```

Discovers its fixtures at runtime like the existing flows, so a reseed does not break it.

---

## Manual validation

### US1 — Write and confirm a quote (P1)

1. Sign in; confirm **Cotizaciones** appears in the sales group of the nav.
2. Open it, choose **Nueva cotización**.
   - ✅ The customer band opens **already searching**.
   - ✅ No product search is offered yet.
   - ✅ **Nothing has been written**: no new quote appears in the list in another tab.
3. Type any part of the generic walk-in customer's name.
   - ✅ It never appears in the results, whatever you type.
4. Pick a real customer.
   - ✅ A draft quote is created *now*, carrying that customer and its payment terms.
   - ✅ Product capture becomes available **on the same screen** — no step change.
5. Add a product.
   - ✅ Priced from the customer's price list; quantity defaults to the product's minimum (or 1).
   - ✅ **No warehouse column.** No stock badge, no shortfall warning.
   - ✅ No fulfilment-mode selector anywhere.
6. Check the reference shown for the draft.
   - ✅ A provisional reference, not a folio.
7. Remove every line.
   - ✅ The confirm action is unavailable.
8. Add a line back and confirm.
   - ✅ A folio is assigned; the quote becomes read-only; **the primary action is gone, not
     greyed out**.

### US2 — Convert an accepted quote (P1)

9. On the confirmed quote, choose convert.
   - ✅ An order is created with the same customer, terms and lines.
   - ✅ You land in the **order workspace on the Venta step**.
   - ✅ Each line still needs a warehouse; delivery can then be planned normally.
10. Re-open the quote and convert **again**.
    - ✅ A second, independent order is created. Conversion is not presented as one-time.
11. Try to convert a **draft** quote, then a **cancelled** one.
    - ✅ Each is refused with the server's own reason, and the quote is unchanged.
12. Try to convert an **expired** quote (one whose due date has passed).
    - ✅ Refused, the reason names expiry, and **Duplicate is offered right there**.
13. Sign in as a user with quote rights but **no** `salesOrders` create.
    - ✅ The convert action is not offered at all.
14. Sign in as a user with **no point of sale configured** and convert.
    - ✅ The refusal explains the missing point of sale in words — **not** a bare
      "validation failed". *(This is the error-mapping trap in contracts §2. If you see a
      generic message here, `_toQuoteError` is missing or not applied to `convert`.)*

### US3 — Find, reopen, amend, cancel (P2)

15. Open the quotes list.
    - ✅ It shows the **facility's** quotes, not only your own.
    - ✅ Rows show customer **names**, not ids, with no visible per-row loading.
16. Filter by status; filter by customer.
17. Search a customer's name.
    - ✅ The list **narrows**. *(Before mbe-api#213 this silently returned everything — if the
      row count does not drop, the server is older than the fix.)*
18. Find a quote past its due date.
    - ✅ Marked expired **as a separate marker**, distinct from its status chip.
19. Reopen a draft: ✅ customer and lines intact and editable.
20. Reopen a confirmed quote: ✅ read-only, offering only what is still available.
21. Cancel a quote: ✅ becomes cancelled, no longer editable or convertible; ✅ the list reflects
    it **without a manual reload**.
22. Page past page 1, then edit a quote and come back.
    - ✅ You return to **the same page**, not page 1.

### US4 — Quote an unregistered customer (P2)

23. From a new quote's customer band, create a customer inline.
    - ✅ Created, attached, capture available — without leaving the screen.
24. Cancel the inline form: ✅ no customer and no quote created.

### US5 — Duplicate (P3)

25. Duplicate any quote.
    - ✅ A new **draft** with the same products, priced at **today's** prices, no folio.
    - ✅ The original is untouched.

---

## Regression: the two existing hosts

Do these last, and do not skip them — this feature edits `capture_step.dart`,
`sale_line_row.dart`, `sale_line_card.dart`, `sale_line_layout.dart` and `sale.dart`, all of
which the register renders.

26. **Register**: open a POS sale, add a line.
    - ✅ The warehouse picker is present and defaults to the register's warehouse.
    - ✅ Stock badges and shortfall warnings behave exactly as before.
    - ✅ The primary action still reads "Cobro →" **with its arrow**.
27. **Order workspace**: open a back-office order, add a line.
    - ✅ Warehouse picker present; "Continuar a entrega" with no arrow; delivery step reachable.
28. **Both at once** — the isolation case. In one tab start a register sale; in another, a
    quote. Add lines to each.
    - ✅ Neither document acquires the other's lines.
    - ✅ A pending write on one never disables the other's action.
    - ✅ Confirming the quote does **not** confirm the register's sale.
29. **Row layout**: at ~1000 px width, compare an order line row with a quote line row.
    - ✅ Both render as a single row. *(If the quote row drops to two rows here, the column
      budget in `sale_line_layout.dart` was not adjusted — research R1.)*
30. **Payment surface**: take a register sale through to payment.
    - ✅ The "Restante" chip, quick-amount buttons and change calculation are unchanged.
      *(This is what the `balanceOrZero` getter protects — data-model §1.)*
