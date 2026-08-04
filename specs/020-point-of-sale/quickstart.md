# Quickstart: validating the Point of Sale

**Feature**: `020-point-of-sale` | **Plan**: [plan.md](./plan.md)

How to run the feature and prove it works. Scenarios map to the spec's user
stories and success criteria; details of the calls behind them are in
[contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md).

---

## Prerequisites

1. **mbe-api running** with a seeded tenant:
   ```bash
   cd ../mbe-api && uv run fastapi dev app/main.py     # http://127.0.0.1:8000
   ```
2. **Codegen parity re-verified** (research §15) — regenerate and confirm the
   client is unchanged before trusting it:
   ```bash
   curl -s http://127.0.0.1:8000/openapi.json -o /tmp/openapi.json
   ./tool/generate_api_client.sh                       # then: git diff --stat lib/generated
   ```
3. **A cashier account** whose settings name a default facility, point of sale
   and warehouse, and which holds `salesOrders` create/update, `customerPayments`
   create and `deliveryOrders` create.
4. **Seeded data**: at least one stockable product with availability in that
   warehouse, one customer with a price list, and one payment method option for
   the facility.

```bash
flutter pub get
flutter run -d chrome --dart-define=BRAND_DISPLAY_NAME=MBE
```

Navigate to **Point of Sale** in the side navigation (or `/sales/pos`).

---

## Scenario 1 — Counter sale, end to end (US1, SC-001)

1. Open the screen. **Expect**: a new sale is already open — a provisional
   reference in the header band, the walk-in customer preselected, Tienda
   selected, an empty line area, step 1 of 2.
2. Scan or type a product code and press Enter. **Expect**: the line appears
   within ~1 s with warehouse, availability, price, discount, tax and total; the
   search field is empty and still focused; the totals bar updates.
3. Change the quantity with the stepper; change the discount on one line.
   **Expect**: each edit is recorded and every total matches what the server
   returns — check against `GET /sales-orders/{id}` in another tab.
4. Press **Continuar al cobro**. **Expect**: the folio replaces the provisional
   reference, the lines become read-only, and the payment step opens with the
   full total outstanding.
5. Enter the outstanding amount, choose Efectivo, press **Agregar pago**.
   **Expect**: the payment is listed, the balance drops to zero, and the confirm
   action unlocks.
6. Confirm. **Expect**: change due is shown, the sale reads as paid, and the
   screen offers a new sale.

**Verify server-side**:
```bash
curl -s localhost:8000/api/v1/sales-orders/<id> -H "Authorization: Bearer $TOKEN" \
  | python3 -m json.tool | grep -E '"status"|"serial"|"balance"|"total"'
# expect: status "paid", a non-null serial, balance "0.00"
```

---

## Scenario 2 — Delivery split across two addresses (US2, SC-005)

1. Start a sale, choose **Domicilio**, and pick the main delivery address.
2. Capture three lines with quantities greater than 1.
3. Pay in full. **Expect**: the delivery step opens (step 3 of 3) with the first
   destination pre-filled from the main address.
4. Set per-line quantities for destination 1, leaving some of each line
   undistributed. **Expect**: the distribution panel shows the remainder per
   line and the running "assigned / total" count.
5. Add a second destination. **Expect**: it claims exactly what destination 1
   left; adjust it to take the rest.
6. Close the sale. **Expect**: it is refused while any unit is unassigned, and
   accepted once none is.

**Verify server-side** — the invariant behind SC-005:
```bash
curl -s "localhost:8000/api/v1/delivery-orders?customer=<customerId>" -H "Authorization: Bearer $TOKEN"
# for each sale line: sum of quantities across delivery orders == ordered quantity
```

---

## Scenario 3 — Mixed fulfilment (US2 scenario 6, FR-036)

Repeat Scenario 2 with **Mixta**, leaving part of one line undistributed.
**Expect**: the remainder is presented as staying at the counter, closing is
allowed, and a delivery order with `fulfillment_type = COUNTER_PICKUP` is
created holding exactly that remainder.

---

## Scenario 4 — Resume an interrupted sale (US3, SC-004)

1. Capture two lines, then reload the browser.
2. Reopen the screen and choose the earlier sale from the selector.
   **Expect**: both lines, the customer and the mode are intact and capture
   continues.
3. Repeat after confirming but before paying. **Expect**: it reopens on the
   payment step, lines read-only.
4. Repeat after paying a delivery sale but before distributing.
   **Expect**: it reopens on the delivery step. (Payments taken in the earlier
   session are not itemised — the balance is authoritative; research §11.)

---

## Scenario 5 — Errors surface where the cashier can act (SC-008)

| Provoke | Expect |
|---|---|
| Add a quantity greater than availability, then confirm | Confirmation refused; the offending lines are marked; the sale stays editable on step 1 |
| Set a line's price to 0, then confirm | Refused, offending lines identified |
| Choose credit terms for a customer with no credit line | Refused with the reason; terms stay immediate |
| Add a card payment with no reference | The add action stays disabled until a reference is entered |
| Stop mbe-api mid-capture and add a line | Error banner, retryable; no phantom line appears |

---

## Scenario 6 — Compact tier (US5, SC-007)

Resize to 390 × 844 (or run in a device frame) and repeat Scenario 1.
**Expect**: single-column lines, "Paso N de M" in place of the full stepper, a
pinned bottom bar, and **no horizontal scrolling anywhere**.

---

## Automated checks

```bash
flutter analyze
flutter test test/unit/features/sales test/widget/features/sales   # fast, no server
flutter test test/integration/pos_counter_sale_flow_test.dart   # needs mbe-api
```

The unit suite is the one to trust for the distribution invariant
(`destination_split_test.dart`) and the money gate (`money_test.dart`); the
integration test proves the call sequence in research §2 against a real server,
discovering its fixtures at runtime rather than hardcoding ids.
