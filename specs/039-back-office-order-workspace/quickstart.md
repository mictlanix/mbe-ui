# Quickstart: Validating the Back-Office Order Workspace

**Feature**: `039-back-office-order-workspace` | **Date**: 2026-09-11

How to prove the feature works end to end, and — just as importantly — how to
prove the register still does.

---

## Prerequisites

- A running mbe-api with a reachable dev database.
- A signed-in user with `salesOrders` read + create + update, and **a point of
  sale configured in their user settings**. Without one, `POST /sales-orders`
  answers 422 and only the blocked state is testable (spec A5).
- At least one customer that is **not** the deployment's generic walk-in
  customer, with a price list and at least one address on file.
- At least one stocked product with available stock in the user's warehouse.
- `POS_DEFAULT_CUSTOMER_ID` in the build matching mbe-api's
  `default_customer_id`, or the generic-customer exclusion is checked against
  the wrong id.

### Two deployment checks that gate this feature (research R6)

Do these before trusting any manual result:

```bash
# In the mbe-api environment — both must be true for the feature to work.
# 1. The expiry sweep must not be scheduled (or mbe-api#210 must be fixed).
crontab -l | grep -i expire_orders        # expect: no match
# 2. The delivery payment gate must be off.
grep -i DELIVERY_ORDER_REQUIRES_PAID .env # expect: unset or false
```

If the sweep runs, a back-office order promised more than
`UNPAID_ORDER_EXPIRY_DAYS` (default 2) out is cancelled before it ships, and no
amount of client testing will reveal it inside one session.

---

## Automated validation

```bash
# Everything this feature touches, plus the regression surface it must not break.
flutter test test/unit/features/sales test/widget/features/sales

# The seam guard specifically — invariant 3 is the new one (contracts §6).
flutter test test/widget/features/sales/sale_editor_isolation_test.dart

# SC-007: the register, unchanged.
flutter test test/integration/pos_counter_sale_flow_test.dart \
             test/integration/pos_delivery_split_flow_test.dart \
             test/integration/pos_resume_flow_test.dart

# The new end-to-end flow (User Story 1).
flutter test test/integration/order_workspace_flow_test.dart

flutter analyze
```

**The four POS integration tests passing byte-identical is the single most
important signal in this list.** They are repository-level — no widgets, no
controllers — so the seam migration cannot legitimately require touching them.
If they needed editing, register behaviour changed and something is wrong.

Three POS *widget* tests (`pos_write_gating_test.dart`,
`pos_compact_delivery_test.dart`, `delivery_step_layout_test.dart`) construct
the shared steps directly and will need a constructor-signature edit when those
widgets gain their host parameters. That is expected and is not an SC-007
failure — but **no assertion in them may change**. If one does, the migration
altered behaviour rather than plumbing.

---

## Manual validation

### Scenario 1 — Take and schedule an order (User Story 1, SC-001)

1. Open **Pedidos** → **New order**. → Workspace opens on **Cliente**. Nothing
   has been written: confirm with `GET /sales-orders` that no new draft exists.
2. Search customers. → The generic walk-in customer never appears, whatever you
   type (FR-011, SC-004).
3. Pick a customer. → The draft is created *now*, carrying that customer and
   `fulfillment_intent = delivery`; the URL rewrites to the order's id; the step
   advances to **Venta**.
   - Verify at the server: `GET /sales-orders/{id}` shows the chosen customer,
     **not** `default_customer_id` (FR-014), and `fulfillment_intent: 1`
     (FR-015).
4. Add two products. → Lines appear priced from the customer's price list.
5. Choose **Continuar a entrega**. → Advances to **Entrega**. The button reads
   for delivery, never for payment (SC-009).
6. Add a destination with an address and a delivery date. → The first
   destination pre-fills every line's full quantity (FR-029), **and the order is
   now committed** — it has a folio and has left draft (spec A2).
7. Try to go back to **Venta**. → Not offered; the order is no longer a draft
   (FR-006). This is the consequence the server forces, not a bug.
8. Close the delivery step. → Read-only in place. Priority is still editable
   (FR-035); nothing else is.

### Scenario 2 — A customer that does not exist (User Story 2, SC-002)

From **Cliente**, create a customer inline. It is attached and the step advances
without leaving the workspace. Cancelling the form creates neither a customer nor
an order.

### Scenario 3 — Resume (User Story 3, SC-008)

Leave an order at **Venta** (draft, lines, no destinations) and reopen it from
the list → resumes on **Venta**. Leave one with a destination and reopen →
resumes on **Entrega**. Neither should land on a payment step, because there
isn't one.

### Scenario 4 — The register is unaffected (User Story 4, SC-007)

**Run this with both screens open at once — it is the whole point.**

1. Open the register in one tab, mid-sale, with a line being edited.
2. Open a back-office order in another and edit one of *its* lines.
3. → Neither screen's forward action is gated by the other's outstanding write
   (FR-043), and each edit lands on its own document (FR-042).
4. Add a destination to the back-office order. → The **order** is committed. The
   register's sale is still a draft (FR-044). Verify both at the server.
5. At the register, walk a counter-pickup sale through capture → payment. → Two
   steps, not three; the fulfilment-mode selector is present; the label still
   reads for payment (FR-046).

### Scenario 5 — Declining a foreign order (User Story 5)

**Blocked on [mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209).**
Until the origin field ships, the interim guard (research R5) is what is
testable: open a register sale from the Pedidos list — one on the walk-in
customer, or counter-pickup, or with a payment — and confirm the workspace
declines to edit it rather than demanding a different customer.

An order the guard cannot recognise (a register sale to a named customer, marked
for delivery, unpaid) **will** still open. That is the known gap the issue
closes, and it is why the guard is documented as a stop-gap rather than as an
implementation of FR-052.

---

## What "done" looks like

| Criterion | How it is shown |
|---|---|
| SC-001, SC-002 | Scenarios 1 and 2 complete within 3 minutes, no navigation away |
| SC-003, SC-005 | Every committed order has a real customer and a full distribution |
| SC-004 | Scenario 1 step 2 |
| SC-006 | One `CaptureStep` and one `DeliveryStep` definition; both hosts render them; grep finds no second copy |
| SC-007 | The four POS integration tests pass **byte-identical**; no POS widget test's assertions change |
| SC-008 | Scenario 3 |
| SC-009 | No payment affordance anywhere in the workspace |
| SC-010 – SC-012 | Deferred with User Story 5 until #209 |
