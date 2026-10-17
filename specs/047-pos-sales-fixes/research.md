# Research: POS Sales Fixes

**Feature**: 047-pos-sales-fixes | **Date**: 2026-10-17

All paths are relative to the repository root. The audit for this research was done on 2026-10-17, against `main` at `9956174`.

## R1 — What "valid cash session" means, and where to check it

**Decision**:
- Valid means `CurrentSession.state == SessionState.open`. Both `none` and `stale` are invalid.
- The state is re-read, never trusted from cache, at two points:
  - when a new sale starts;
  - before each payment is applied.
- The re-read is `await ref.refresh(currentSessionControllerProvider.future)`.

**Rationale**:
- `SessionState.stale` already exists. It mirrors mbe-api's `session_state`: a session opened before today and never closed. No new expiry rule is needed (see the spec's Assumptions).
- `currentSessionControllerProvider` is auto-dispose and has no refresh method. The existing callers invalidate it (`open_session_form_controller.dart:139`, `close_session_form_controller.dart:142`). Refreshing its `future` gives one network read and fresh state for everyone listening.
- These two points are where money or a new order is created, so they are where FR-005 matters. The capture step does not need a re-check: lines on a draft sale are not booked to a session.

**Alternatives considered**:
- *Periodic polling, or a timer at midnight*: rejected. It adds a timer for no benefit, because the check at the moment of the action already covers sessions that expire while the POS is open.
- *A backend rule*: out of scope (spec Assumptions). It is noted as a possible mbe-api follow-up and is not filed by this feature, because the UI gate meets the spec.

## R2 — Redirecting an expired session to its close screen

**Decision**:
- **Sales list.** *New sale* is enabled only when the state is `open`.
  - When the state is `stale`, *New sale* stays visible and enabled. Tapping it re-reads the session (R1). If the session is still stale, the app navigates to `/sales/cash-sessions/<id>` and shows a snackbar saying why.
  - When the state is `none`, the button is disabled, as it is today.
- **`/sales/pos/new` opened directly.** The workspace sees `stale` and replaces the route with the close screen, with the same explanation. No sale is created: sales open lazily (`SaleEditing.ensureOpen`), so nothing has been written yet.
- **Existing sale (`/sales/pos/:id`) under a stale session.** The sale can be viewed and edited as today. On the payment step, the method grid is disabled and a blocking banner takes the place of the stale warning: "La sesión de caja está vencida; ciérrala para cobrar". The banner has a *Cerrar sesión* action that goes to the close screen.
- **`none` on an existing sale.** The same banner appears, with *Ir a sesiones de caja* instead.

**Rationale**:
- The close screen already exists. It opens with the close form visible inline (`cash_session_detail_screen.dart:141-148`) and refreshes `currentSessionControllerProvider` after closing, so the POS sees `none` when the cashier comes back. That is spec scenario 6.
- Navigation uses `context.go`/`replace`, not `push`. That way Back does not return to a POS screen that cannot be used.

**Known limitation (documented, not solved)**:
- A cashier without the `cashSessionClose` update privilege lands on the close screen and sees "a supervisor must close this session" (`cash_session_supervisor_required_message`). This is correct per §IV. The redirect still gets them to the right place and tells them what is needed.

**Alternatives considered**:
- *Disabling New sale for `stale` too*: rejected. The spec asks for a redirect, not a dead button.
- *Closing the session from inside the POS*: rejected. It would duplicate the close form, which includes a denomination count.

## R3 — The Advanced search filter panel shows an empty selection

**Decision**:
- Fix `CurrentListQueryBuilder` (`lib/core/navigation/list_query.dart:150-165`). It should read the URI of the **top-most** route match, so a route that was pushed is included, instead of `routerDelegate.currentConfiguration.uri`.
- The fix is resolved in one helper in `list_query.dart`:
  - If `currentConfiguration.last` is an `ImperativeRouteMatch`, use its `matches.uri`.
  - Otherwise, use `currentConfiguration.uri`.
- A regression test opens the screen through `router.push` from a host route. It selects two labels, then toggles *stockable*, and checks that both labels and the search term survive.

**Rationale**:
- In go_router 17, `push` and `replace` add an `ImperativeRouteMatch` and leave `currentConfiguration.uri` pointing at the base route. The panel therefore parses an empty query. `onChanged` then rebuilds from that empty query, so the previous selections and the term are lost. This one cause explains every symptom in the spec (US2), including the *stockable*, *purchasable* and *supplier* filters.
- The advanced search is the only one of the 15 users of this builder that is reached by `push`. Fixing the shared builder still protects any future screen that is pushed, and costs nothing for the other 14, which see the same URI as before.
- The existing test (`advanced_search_screen_test.dart:135`) starts at the search path, where the two URIs are the same. That is why the bug was not caught.

**Alternatives considered**:
- *Passing `widget.query` into the panel*: this works for one screen only. The sheet is built once, while each `replace` produces a new `widget.query`, so the sheet would also need its own listener. It is kept as the fallback if the `ImperativeRouteMatch` lookup proves fragile across go_router versions.
- *`GoRouterState.of(context)`*: the sheet's context belongs to the modal route, not to the search route, so it resolves the wrong state.

## R4 — Stock for every line, including resumed sales

**Decision**:
- `productStockCacheProvider` changes from `Map<productId, List<WarehouseStock>>` to `Map<productId, ProductStock>`. `ProductStock` holds `stockable`, `stockRequired` and `warehouses`; see the data model.
- When the capture step opens for a sale, every product on it that is not already cached is loaded with one `productLookup(pattern: product.code, customer: sale.customer)` call per distinct product. The calls run concurrently. The row whose `product` id matches is kept.
- A product whose lookup fails, or whose row is not among the results, is left uncached. It counts as **unknown** (clarification Q1: warns, does not block).

**Rationale**:
- mbe-api has no stock endpoint and no batch lookup. `product-lookup` is the only source of per-warehouse stock (`sales_orders.py:82-93`).
- That endpoint returns `stockable` and `stockRequired` alongside `stock`, which separates a product that is not tracked (`stock: []`) from one that is unknown. Today's cache cannot tell these apart.
- Matching on `code`: the endpoint searches `ilike %pattern%` across code, name and similar fields with `limit 20`. In theory a product could be pushed out of the results by 20 others whose fields contain its code. That case degrades to "unknown", which is safe under Q1.
- A 13-digit `code` with no matching barcode used to return nothing (mbe-api#208). That was fixed upstream on 2026-09-12 (mbe-api#214): a search that finds no barcode now falls back to the normal search. Looking up by code therefore resolves those products too.
- POS sales have few distinct products, so N concurrent calls are acceptable.

**Follow-up (not a dependency)**:
- Propose an mbe-api issue for a batched `products=[ids]` parameter on `product-lookup`. The service already computes stock for a set of products at `sales_order_service.py:1365`.
- Optionally, also propose adding `stockable` and `stock_verification` to `SalesOrderLineResponse`.
- **Filed 2026-10-17 as mbe-api#237**: a batch `products=[ids]` parameter on `product-lookup`, plus filling the always-null `warehouse_name`. Until it ships, this feature uses the per-code lookup above. Once it ships, regenerate the client and replace the per-code calls with one batch call. That also removes the limit-20 risk described above.

**Alternatives considered**:
- *`GET /products/{id}`*: rejected. It needs the PRODUCTS read privilege, which the lookup was designed to avoid (#157), and it carries no stock.
- *Blocking until the backend change ships*: rejected, because it is not needed.

## R5 — The short-line rule (the Continue gate)

**Decision**:
- A product is *checked* only when `stockable && stockRequired`. This mirrors the backend's confirm check (`_stocked_products`, `sales_order_service.py:1261-1278`).
- For each (product, warehouse) pair among checked products, the quantities on the sale's lines are summed. If the sum is greater than that warehouse's `available`, every line in the pair is short.
- `available` is on hand minus reserved, the same value confirmation enforces.
- *Continue* is disabled while any line is short. A message beside it names how many lines are short, and each short line keeps its existing per-line warning.
- The check runs only while the sale is a **draft**. A confirmed sale already passed the server's check, and its own reservation is inside `reserved`, so re-checking it would produce false shortfalls.
- Unknown stock (R4) never blocks (Q1). There is no override for any role or sale type (Q2).

**Rationale**:
- The backend already rejects confirmation for stock-tracked shortfalls, at the first payment. Applying the same rule at capture turns a late, confusing error into an early, explained one, without inventing a different rule.

**Alternatives considered**:
- *Capping the quantity field at what is available*: rejected. The comment at `sale_line_editing.dart:52-56` explains why quantities stay uncapped: a cap fights the cashier while they type. The gate blocks only the step change.

## R6 — Warehouse pop-up

**Decision**:
- `warehousePicker()` stops being a `DropdownButtonFormField`. It becomes a read-only field that looks like the other line controls: an `InputDecorator` showing the warehouse name, the stock indicator and a trailing arrow icon. Tapping it opens `showWarehousePicker(context, ...)`, which returns `Future<int?>`.
- The dialog is an `AlertDialog`, built the same way as `showCustomerAddressPicker`:
  - width capped at 480, list height at 320;
  - each row is a `ListTile` with the full name, the available quantity (or "unknown") and the short/no-stock indicator for the line's quantity;
  - the current warehouse is marked with a check;
  - Cancel closes it with no change.
- On compact screens, the dialog keeps a 16 px inset, so it fits a 390 px phone without horizontal scrolling.
- When the line is not editable, the field shows the name but has no tap handler.

**Rationale**:
- The dropdown menu is only as wide as its 168-240 px column. A dialog is not limited by the column, so names never need to be cut.
- Keeping the field inside the existing band preserves the measured row height and baseline (§VI, `sale_line_layout.dart`).
- A plain `AlertDialog` with `ListTile`s is the feature's existing picker idiom. A new shared core dialog is not justified for a single consumer.

## R7 — Applying a payment when a method is tapped

**Decision**:
- A new `PaymentController.tender(sale, option)` replaces `selectMethod` followed by `submit`. It does the following:
  - ignores the tap if `submitting` is set;
  - validates the amount;
  - applies the cash/non-cash overpayment rule (R8);
  - if `requiresReference`, returns a request for the UI to collect the reference. A small dialog with one field and confirm/cancel buttons opens, and the payment is applied on confirm.
- After that, it runs the existing submit pipeline: confirm the draft, create, apply, then refresh.
- The amount is pre-filled with the remaining balance when the step opens, and again after every successful payment. The existing reset clears the amount; it now sets it to the new balance instead. The quick chips are unchanged.
- The `payment_submit_button` and the inline reference field are removed. Method tiles stop showing a "selected" state, because they are now actions.

**Rationale**:
- One tap per payment (SC-005).
- Using a dialog for the reference keeps "one tap, one payment" for the common methods. Methods that need a reference still get an explicit confirmation, so nothing is applied without it.
- The re-entry guard on `submitting` (FR-017) already exists in the draft.
- Mistakes are corrected through the existing reversal in `applied_payments_panel.dart`, as before.

**Alternatives considered**:
- *Selecting the method, then typing the reference inline and pressing Enter*: rejected. It brings back the two-step flow for those methods and adds a hidden keyboard action.

## R8 — Cash overpayment and change

**Decision**:
- Overpayment is allowed only when the method code is `PaymentMethod.cash`. For any other method with amount > balance, `tender` sets a validation error ("Solo el efectivo puede exceder el saldo") and applies nothing.
- The existing `changeFor`, create/apply split and `amountChange` stay as they are. They are correct for cash.
- **Change notice.** After a successful cash payment with change > 0, the controller sets `lastChange`. The payment step shows a prominent change card above the summary, in a large amount style, with a dismiss button.
  - The card is cleared by dismissing it, by the next tender, or by leaving the step.
  - The existing live "Cambio" row in the summary stays as the preview while an amount above the balance is entered.

**Rationale**:
- The backend already records change (`ApplicationCreate.amount_change`) and subtracts it in the cash cut (`cash_session_service.py:176-219`). No backend change is needed.
- Once applying a payment clears the amount, the old preview row disappears at the moment change is due. That is exactly the "easy to miss" problem, so the card must outlive the draft.

**Alternatives considered**:
- *A modal "give change" dialog*: rejected. It blocks the next split payment, and a dismissible card is still prominent.
- *Showing change in the completed-sale dialog*: rejected. That dialog appears only when the cashier taps Close, which may be several actions later.

## R9 — Tests touched

- **Unit**
  - `payment_controller_test`: tender, the guard, the non-cash cap, `lastChange`, reference flow, amount pre-fill.
  - New stock-gate test for the short-line rule.
  - `list_query` URI resolution.
- **Widget**
  - `pos_sales_list_screen_test`: the stale-session redirect.
  - `pos_workspace_route_test`: `/new` under stale.
  - `payment_step_gate_test`, `payment_step_layout_test`, `pos_compact_layout_test`: the Apply button is gone and tiles apply payments.
  - `advanced_search_screen_test`: the pushed variant with two labels.
  - `sale_line_row_test`: the warehouse field opens the dialog.
  - New `warehouse_picker_dialog_test`.
  - `capture_step` gate.
- **Harness**: `pos_test_harness.dart` gains a `/sales/cash-sessions/:cashSessionId` stub route, so the redirect can be asserted (research item F).
- **Golden/screenshot**: the POS capture and payment goldens are regenerated, because the warehouse field and the payment pane change visibly.
