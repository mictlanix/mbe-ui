# Phase 0 Research: Back-Office Order Workspace

**Feature**: `039-back-office-order-workspace` | **Date**: 2026-09-11

Every unknown in the plan's Technical Context is resolved here. Findings were
taken from the current source and from a read of mbe-api's own source, not from
the prior specs' descriptions of either.

---

## R1 — How the two reused steps become host-agnostic

**Decision**: extend the existing seam with **one more provider and two widget
parameters**, then migrate eleven call sites onto it. Do not build a shared
step-machine abstraction.

**The seam as it stands.** `sale_editor.dart` already declares two plain
(non-family) providers, overridden together in a nested `ProviderScope`:

- `saleEditorProvider` → which document is edited (defaults to the register's
  `PosSaleController`);
- `saleWritesScopeProvider` → which pending-write / unconfirmed-edit scope
  applies (defaults to `posWritesScope`).

`customer_bar.dart`, `sale_line_editing.dart`, `product_lookup_controller.dart`
and `order_header_panel.dart` already read them and therefore already work in
both hosts.

**What still bypasses it** — the complete list, verified by grep:

| File | Line(s) | Reaches for | Why it must move |
|---|---|---|---|
| `capture/capture_step.dart` | 96, 116 | `posWritesScope` | A back-office edit would count against the register's gate |
| `capture/capture_step.dart` | 61, 85 | `posStepControllerProvider` | Advancing to "Cobro" is meaningless off-register |
| `capture/capture_step.dart` | 127, 135 | `confirmErrorProvider` | POS-only error channel |
| `capture/fulfillment_mode_selector.dart` | 245, 268, 270, 281 | both POS singletons | Writes the intent to the wrong document |
| `capture/customer_bar.dart` | 127 | `posStepControllerProvider` | Resets the register's mode on a back-office customer change |
| `delivery/delivery_step.dart` | 259 | `posWritesScope` | Close gate reads the wrong scope |
| `delivery/delivery_controller.dart` | 82 | `posWritesScope` | Destination writes tracked on the wrong scope |
| `delivery/delivery_controller.dart` | 105, 172 | `confirmBeforePayableAction` | **Confirms the cashier's sale, not the order** |

The last row is the dangerous one. `pos_confirm.dart:35-42` calls
`posSaleControllerProvider.notifier.confirm()` and, on failure,
`posStepControllerProvider.jumpTo(PosStep.venta)`. Rendering `DeliveryStep` in a
second host without changing it would commit the register's in-progress sale
when a back-office user adds a destination — silent, and invisible at the
register until a cashier finds their sale already confirmed.

**The change**:

1. `confirmBeforePayableAction` takes its editor from `saleEditorProvider` and
   reports failure through a new `saleConfirmFailureProvider` — a host-supplied
   callback (`void Function(AppError)`) that POS wires to its existing
   `confirmErrorProvider` + `jumpTo(venta)` pair, and the workspace wires to its
   own banner + return-to-Venta. `confirmErrorProvider` stays POS-only.
2. `CaptureStep` gains two parameters — `onContinue` (the host's forward action)
   and `continueLabel` — and a `showFulfillmentSelector` flag. It stops reading
   `posStepControllerProvider` entirely. `SaleTotalsBar` already accepts
   `actionLabel` and `secondaryAction`, so nothing new is needed below it.
3. Every remaining `posWritesScope` literal in the two step files becomes
   `ref.watch(saleWritesScopeProvider)`.

**Rationale**: the mechanism already exists, is already documented in three
doc comments, and is already asserted by `sale_editor_isolation_test.dart`.
Adding a third override is a smaller change than any abstraction, and it keeps
"which document" and "which write gate" as the only two questions a shared
widget ever asks about its host.

**Alternatives rejected**:

- *A shared step-machine interface.* The two hosts do not share a step
  vocabulary — POS is Venta/Cobro/Entrega, the workspace is
  Cliente/Venta/Entrega — so any common machine would be a union that neither
  host fully uses. Passing the forward action as a callback (FR-045) leaves the
  shared widget with no step concept at all, which is strictly simpler.
- *Family providers keyed by host.* Would force every leaf widget to thread a
  key it has no other use for, and would not prevent the mistake the nested
  scope prevents structurally.
- *Copying the steps for the back office.* This is what exists today and is the
  problem the feature was raised to fix.

**Known trap to carry into tasks**: `product_lookup_controller.dart` declares
`@Riverpod(dependencies: [saleEditor])`. Without it the provider resolves
against the root container and writes to the register's sale regardless of the
nested scope. Any new provider that reads the seam needs the same annotation,
and the annotation must survive codegen.

---

## R2 — How the workspace reconstructs its step on resume

**Decision**: derive the step from `Sale.status` alone. No extra fetch.

**Rationale**: mbe-api refuses to record a delivery against an order that is not
yet committed — `POST /delivery-orders` answers 409 *"Only a completed,
uncancelled sales order can be delivered"*
(`delivery_order_service.py:233-237`). Combined with the fact that this
workspace never collects payment, the implication is exact:

| `Sale.status` | Means | Resume on |
|---|---|---|
| `draft` | Committed nothing, so has no destinations | **Venta** |
| `completed` | Only the first destination create could have committed it | **Entrega** |
| `paid` | Someone collected elsewhere; still owes its distribution | **Entrega** |
| `cancelled` | — | Read-only, no step |

So "has at least one destination" (FR-040) and "is no longer a draft" are the
same condition for an order this workspace raised, and the step is derivable
from a field the order already carries. `DeliveryStep` fetches the destinations
itself when it renders, so nothing is fetched twice.

FR-038's case — an order this workspace did not raise — is settled before this
table is consulted (see R5), not by it.

**Alternatives rejected**:

- *Reusing `resumeTargetFor`* (`pos_resume_controller.dart:35-68`). It maps
  `paid → entrega` and `completed → cobro`, both of which are payment-shaped
  questions. A back-office order is `completed` and unpaid in its normal
  resting state, so this would land every resumed order on a payment step that
  the workspace does not have.
- *Listing delivery orders to decide.* Correct but wasteful — it buys nothing
  over the status, and it adds a round trip to every open.

---

## R3 — Where the customer step gets its behaviour

**Decision**: compose the existing pieces; write no new search, picker or form.

- Search and selection: `CustomerBar` already hosts a
  `CatalogEntityPicker<CustomerListItem>` and already accepts
  `excludeGenericCustomer`, which `order_screen.dart:238` already sets. The
  Cliente step renders the picker directly in its searching state rather than
  behind the facts/searching toggle a populated order needs.
- Inline creation: `showCustomerInlineCreate(context, ref)`
  (`customer_inline_create.dart:29`) already returns the new customer's id and
  is already dialog-on-wide / full-screen-on-phone. FR-013 is satisfied by
  calling it.
- Attachment: `CustomerBar._attachCustomer` already routes through
  `saleEditorProvider.updateHeader(customer:, paymentTerms:, salesperson:,
  fulfillmentIntent:)`, and `updateHeader`'s first-write fast path already opens
  the order with customer and salesperson in one `POST`. FR-014, FR-015 and
  FR-016 are one call.

**The one gap**: `SalesOrderRepository.open()`
(`sales_order_repository_impl.dart:27-36`) sends only `customer` and
`salesperson`. `SalesOrderCreate` accepts `fulfillment_intent`
(`app/schemas/sales_order.py:95`), so FR-015 needs that one parameter threaded
through `open()`. Two lines, no codegen.

**Why this matters beyond convenience**: mbe-api falls back to
`settings.default_customer_id` when an order is created without a customer
(`sales_order_service.py:474-476`). Opening the order *with* the customer
already chosen is what makes FR-014's guarantee true at the server, not merely
in the UI.

---

## R4 — What happens to the order header panel

**Decision**: keep it, delete two fields, move it into the Venta step.

`order_header_panel.dart` is 565 lines and spec 037 shaped it deliberately
(disclosure order, density, one fact in one place). Nothing about the three-step
flow invalidates that work. FR-050 removes exactly two fields — ship-to and
contact — because destinations now own them per shipment. Everything else
(priority, currency, exchange rate, tax recipient, promise date, salesperson,
comment, read-only due date) is unchanged and is what FR-023 asks for.

**Rationale**: a rewrite here would discard a shipped, reviewed design to
produce the same panel minus two rows. The spec's "from scratch" applies to the
*flow*, not to every file the old flow touched.

---

## R5 — Proceeding while mbe-api#209 is open

**Decision**: build everything else now; make the origin check its own final
slice; ship an explicitly temporary, conservative guard in the meantime.

FR-051 – FR-054 cannot be implemented without the server field — that is the
whole point of #209. Everything else in the spec is independent of it: the three
steps, the seam migration, resume, commitment and read-only all work on orders
this workspace raised in the same session.

The exposure is narrow but real: the "Pedidos" list does not distinguish origin
(spec A1), so a register sale can be opened into the workspace today.

**Interim guard** — decline to edit an order when *any* of these hold:

- its customer is the generic walk-in customer (`AppSettings.isGenericCustomer`);
- its recorded `fulfillmentIntent` is `counterPickup`;
- it has any non-cancelled payment recorded.

This is deliberately one-sided. Each condition is *sufficient* to prove an order
is not a back-office order, and none is necessary, so the guard never wrongly
rejects an order this workspace raised (it raises none of those states) and
catches the large majority of register sales. It is a proxy, which FR-052
explicitly forbids — so it is **not** an implementation of FR-052, it is a
stop-gap, and the task that adopts the real field must delete it.

**Alternatives rejected**:

- *Block the whole feature on #209.* The field is additive and uncontroversial,
  but its backfill policy is an open question on the issue, and the other three
  user stories deliver value without it.
- *Ship with no guard.* The failure mode — a user being asked to change a
  register sale's customer, or a counter sale being pushed toward mandatory
  delivery — is bad enough to be worth ten lines.
- *A dedicated back-office `point_sale` row.* Evaluated and rejected on the
  issue: it works, but it abuses `point_sale` semantics, needs a
  facility→register map in deployment config, and `point_sale` is absent from
  `SalesOrderSummary` so it never reaches a list row.

---

## R6 — Two deployment preconditions that no code change can satisfy

Neither is a build-time blocker; both can make the shipped feature fail in a
live environment, so they are release checks rather than tasks.

- **The expiry sweep** (mbe-api#210). `find_expired`
  (`order_expiry.py:74-99`) cancels orders that are committed, unpaid,
  undelivered and holding stock more than `UNPAID_ORDER_EXPIRY_DAYS` (default
  **2**) after their order date. `sales_order.delivered` is set only when every
  line has actually been delivered (`delivery_order_service.py:972-975`) —
  planning a delivery does not set it. That is the normal resting state of a
  back-office order, so if the sweep is scheduled, orders promised further out
  than two days are cancelled. It is a CLI entry point with no scheduler in the
  mbe-api repo; **confirm it is not scheduled, or that #210 is fixed, before
  release.**
- **The delivery payment gate** (mbe-api#211).
  `delivery_order_requires_paid_or_credit_sales_order` defaults to `false`.
  Enabled, it refuses delivery for any immediate-terms order
  (`delivery_order_service.py:238-244`), which is every back-office order for a
  non-credit customer. **Confirm it is off in the target deployment.**

---

## R7 — Test strategy

**Decision**: preserve behaviour-level coverage by preserving widget keys;
rewrite only what asserts the old single-screen shape.

The existing suite is dense and mostly keyed on widget keys
(`sales_order_confirm_button`, `sales_order_product_search_field`,
`sales_order_choose_customer_hint`, …) rather than on layout, so tests that
assert *what the screen does* can largely be re-pointed at the new host by
keeping those keys. Tests that assert the old *flow shape* — one screen, confirm
from Venta, no steps — are invalidated by design and are rewritten.

Three layers, per the constitution's quality gates:

- **Unit** — step reconstruction from status (R2), and the interim guard (R5).
- **Widget** — each of the three steps; the compact tier (constitution VI); and
  an extension of `sale_editor_isolation_test.dart`, which is today the *only*
  guard on the seam and must grow to cover the delivery surface and the confirm
  helper, since those are where the new coupling risk lives.
- **Integration** — the end-to-end flow of User Story 1, alongside the existing
  POS flows which must pass unchanged (SC-007).

The precise per-file disposition is inventoried in
[contracts/order-workspace.md](./contracts/order-workspace.md) §6.
