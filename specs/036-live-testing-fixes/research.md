# Phase 0 Research: Live Testing Session Fixes

**Feature**: 036-live-testing-fixes | **Date**: 2026-09-02

Findings below come from direct code reading (five parallel research passes) plus, for R1 only,
a read-only look at the sibling `mbe-api` checkout's service layer — never edited, per §III.
Two open questions (R3, R13) were put to the requester directly and their answers are recorded
as decisions, not left as open items.

---

## R1 — Why "stay draft until payment" can't be done by loosening `isEditable`

**Findings.** `Sale.isEditable` is `status == draft` (`sale.dart:93`), and reaching the payment
step already flips status to `completed` via a real server call — `PosSaleController.confirm()`
→ `repository.confirm(saleId:)` (`sale_editing.dart:168-173`) → `POST /sales-orders/{id}/confirm`
(`sales_order_repository_impl.dart:188-201`) — invoked *before* any payment, right when advancing
Venta→Cobro (`capture_step.dart:80-92`). Reading mbe-api's own service layer (read-only,
`app/services/documents.py:42-58`, `sales_order_service.py:762,811,837`,
`customer_payment_service.py:31-45`) shows both halves of the current behavior are server-enforced,
not client convention: a `draft` sale's payment endpoint 409s (`assert_order_payable`), and a
`completed` sale's line-mutation endpoints 409 unconditionally (`assert_editable`) — payment
status is irrelevant to that second check.

**Decision.** Move the `confirm()` call itself to just before the first server operation that
genuinely needs `completed` status, instead of calling it on Venta→Cobro:
1. inside `PaymentController.submit`, before `createPayment` (`payment_controller.dart:126-135`);
2. before the first delivery-order `create` in the Entrega step;
3. when leaving Cobro on credit terms (no cash payment ever posted, but the sale still needs to
   become payable/deliverable).

The sale is then genuinely `draft` throughout Cobro/Entrega, `isEditable` and every existing
read-only/line-edit path need **no change**, and FR-005/FR-007/FR-008 all fall out for free.

**Rationale.** It is the only option that satisfies FR-008 (stays `draft` until payment) without
an mbe-api change. Broadening `isEditable` to include `completed && unpaid` was the initial idea
but is not implementable client-side at all — it would just move today's silent failure into a
409 the moment a "still editable" completed sale tried to save a line change, exactly the failure
mode `contracts/pos-screen.md §5` (spec 020) says the read-only rendering exists to prevent.

**Alternatives considered.** Broaden `isEditable`: rejected, see above — requires an mbe-api
change (a reopen/un-confirm endpoint that does not exist) and still leaves stock reservation and
folio assignment out of sync with a document that can be freely re-edited after being "confirmed".
Add a client-only "soft draft" flag ignored by the server: rejected — cosmetic only, the server
still refuses every line edit past confirm, so it would not fix the bug.

**Costs to carry forward (see Risks in plan.md):**
- `confirm()`'s failure modes (empty order, zero-priced line, stock shortfall) now surface at
  payment/delivery time instead of at Venta→Cobro, and must be routed back to Venta using the
  existing `_toConfirmError` rendering (`capture_step.dart`, `sales_order_repository_impl.dart:361-380`),
  not treated as a payment failure.
- Stock is reserved later (at confirm-just-before-payment) than today — two registers can now
  race for the same stock between capture and payment. A behavior change worth flagging to
  operations, not something this feature can mitigate in code.
- `Sale.serial` is assigned later; already tolerated everywhere via `provisionalReference`
  (`sale.dart:87-91`).

---

## R2 — Back-navigation mechanics

**Decision.** Add two guarded methods to `PosStepController` (`pos_step_controller.dart`),
matching its existing guard+transition pairing style (`canConfirm`/`advanceToCobro`,
`canLeavePayment`/`advanceFromCobro`):

```dart
bool canReturnToCapture({required bool isEditable, required bool hasNonCancelledPayments});
void returnToVenta();
```

The guard reads `sale.isEditable` (now reliably true throughout Cobro/Entrega per R1) and
`orderPaymentsControllerProvider(sale.id)` filtered on `!SalePayment.cancelled` — loading/error
states deny the transition, matching the conservative-default convention already used by
`sale_workability.dart`'s empty `resumableIds` fallback. `jumpTo` stays reserved for resume only
(`pos_workspace_screen.dart` `_syncStepTo`'s `_syncedSaleId` latch already ensures a manual
back-jump is not undone by the next rebuild).

**Affordance.** Make the `_StepPill` (`pos_workspace_screen.dart:443-487`) tappable for an earlier
step only when the guard passes, wrapping the existing `Container` in an `InkWell`. The compact
breakpoint renders a text progress indicator instead of pills (`:399-405`), so compact needs a
second affordance — placed in the payment/delivery footer band next to the existing close action.

**Rationale.** Mirrors the existing controller's own idiom exactly (a `can*` guard beside every
transition) rather than inventing a new pattern.

---

## R3 — The "Sin pagar" resume bucket needs relabeling

**Findings.** `open_sales_selector` buckets resumable sales into three sections keyed on status —
Borrador (`draft`), Sin pagar (`completed`), Sin entregar (`paid`) (`open_sales_selector.dart:53-59,198-203`;
`open_sales_selector_controller.dart:41-105`). Under R1, a captured-but-unpaid sale is now `draft`,
not `completed` — the "Sin pagar" bucket's entire premise (a confirmed order waiting on payment)
no longer exists as a distinct status.

**Recommendation (not yet confirmed with the requester — flag before implementing).** Merge
"Borrador" and "Sin pagar" into a single bucket — every sale with at least one line and no
payment recorded is, post-fix, indistinguishable from a draft in progress, and showing them as
one list is the accurate description. "Sin entregar" (`paid`, awaiting delivery) is unaffected by
R1 and keeps its own bucket.

**Rationale.** A resume-list label/grouping change is user-visible, and "Sin pagar" implied
something (a confirmed, locked-in order) that no longer exists post-fix — leaving a bucket whose
predicate can never again be true is worse than merging it, but this is a product call about a
screen cashiers use constantly, not something to decide unilaterally. Carried into plan.md's Risks
table as an open item requiring sign-off before the resume-selector change ships.

**Alternatives considered.** Keep three buckets, redefine "Sin pagar" using `lineCount > 0` as a
proxy for "captured": rejected — every draft has `lineCount > 0` once past Venta, so the two
buckets would show the identical set of sales under two different headings, which is more
confusing than one bucket.

---

## R4 — Stock reservation timing (risk, not a design decision)

Carried forward from R1: reservation now happens at confirm-just-before-payment rather than at
Venta→Cobro, narrowing — but not eliminating — the existing race between two registers selling
the same stock. No code mitigates this; it is recorded in plan.md's Risks table for operational
awareness, matching how spec 020's original design already accepted a similar window.

---

## R5 — Sales Order customer-first flow

**Findings.** An order does not exist server-side until first touched: `SaleEditing.ensureOpen`
(`sale_editing.dart:43-50`) POSTs an **empty** `SalesOrderCreate()`, and mbe-api fills the customer
from its own `default_customer_id`. Three separate call sites can trigger this today — adding a
line (`order_screen.dart:74-95`), the product-lookup pricing call
(`product_lookup_controller.dart:26`), and any header edit — so gating only `_addLine` would still
create a customer-less order from the search field.

**Decision.** Add `bool get _needsCustomer` to `_OrderScreenBodyState`, true when
`sale == null || sale.customer == appSettings.posDefaultCustomerId`. While true, render
`CustomerBar` plus an inline hint and **omit** `ProductSearchField` entirely (this codebase's own
convention for "not applicable yet" — absent, not disabled, matching `showAction: editable` at
`order_screen.dart:289`) — which also removes the `productLookupController` path for free. Fold
`!_needsCustomer` into the existing `onContinue` confirm-gate (`order_screen.dart:293-300`) for
FR-003's "or saving" half.

**Optional refinement, recommended:** extend `SalesOrderRepository.open()` to accept
`{int? customer, int? salesperson}` (`SalesOrderCreate` already carries both fields,
`sales_order_create.dart:35-39`) so the very first customer pick is a single POST instead of
create-then-PATCH. No mbe-api change required either way.

**Rationale.** Matches the existing absent-not-disabled convention, closes all three creation
paths with one predicate, and the optional refinement is a small win with no added risk.

---

## R6 — Excluding "Público en General" (shared mechanism, two call sites)

**Findings.** `posDefaultCustomerId` is a build-time `--dart-define`
(`pos_defaults.dart:30-33`, mirrored onto `AppSettings.posDefaultCustomerId`,
`app_settings.dart:48,78`) — the only discriminator for the generic customer; there is no
server-side "is generic" flag. `CustomerBar` is shared between POS capture
(`capture_step.dart:174,182`) and the order screen (`order_screen.dart:240`), so the exclusion
must be conditional, not baked into the shared widget.

**Decision.** Add `bool excludeGenericCustomer = false` to `CustomerBar`, threaded into its
`optionsBuilder` (`customer_bar.dart:456-461`) as
`result.items.where((c) => !exclude || c.customerId != genericId)`. Pass `true` only from the
order screen; POS keeps the default `false`, leaving its own behavior (and its goldens) untouched.
Add one shared predicate — `AppSettings.isGenericCustomer(int id)` — used by both this filter
(FR-002) and the fulfillment-mode gate (R8/FR-015), so the two call sites can never disagree about
which customer is "the" generic one.

**Rationale.** A shared predicate sourced from the one existing app setting, rather than two
independent id comparisons that could drift, or a new customer-classification field (explicitly
out of scope per spec.md).

---

## R7 — Salesperson autofill wiring

**Findings.** `CustomerListItem.salesperson` (`customer_list_item.dart:23`) is already on the
object the picker's `onSelected` receives (`customer_bar.dart:461`) — no extra fetch needed.
`CustomerBar._updateHeader` → `SaleEditing.updateHeader` (`sale_editing.dart:72-104`) already
accepts a `salesperson` argument, and every named arg there is null-skipping
(`sales_order_repository_impl.dart:76-81`), so one call can carry both fields. `Sale.salesperson`
is non-nullable (`sale.dart:23`, defaults to the creating user) — there is no way to detect "the
user already chose one manually" from the sale itself.

**Decision.** Change the customer picker's `onSelected` to
`(c) => _updateHeader(customer: c.customerId, salesperson: c.salesperson?.id)` — sending the
customer's salesperson only when present, as part of the same write that sets the customer, live
(no local draft state exists to hold a pending value in). `OrderHeaderPanel`'s salesperson field
must also start passing its `initialDisplayText` from the resolved customer's salesperson name
(`order_header_panel.dart:184-186` already watches `saleCustomerControllerProvider`) — today it
renders blank on load regardless of what's stored.

**Rationale.** Reuses fields and call paths that already exist end-to-end; the "server push, not
client draft" choice matches this screen's established live-surface pattern (no Save button).
Changing the customer again re-applies the new customer's salesperson (overwriting a manual pick
made in between) — an explicit, spec'd trade-off (FR-018 keeps the field changeable afterward),
not a silent surprise.

---

## R8 — Fulfillment-mode gating replacement, including the mid-sale switch case

**Findings.** `fulfillment_mode_selector.dart:249` gates delivery/mixed on `!customer.shipping`
today; nothing is disabled in the UI — all three mode segments are always tappable, and a refusal
after the fact renders a message (`:304-312`). Modes are `counterPickup`/`delivery`/`mixed`
(`fulfillment_mode.dart:15-17`). Switching a sale's customer mid-sale is possible via
`CustomerBar._updateHeader` and nothing today re-validates the chosen mode against the new
customer — a gap the original spec didn't cover.

**Decision.**
- Replace the `!customer.shipping` check with a synchronous comparison against
  `AppSettings.isGenericCustomer` (R6) — deletes the async `saleCustomerControllerProvider(...).future`
  round-trip and its failure mode, and the now-unused import.
- Guard against gating the *first* mode choice: fall back to allowing delivery/mixed when
  `widget.sale == null` (no customer attached yet), since the selector already supports choosing
  a mode before a customer is picked (`:193-197,256-262`).
- Per the requester's decision (FR-016): in `CustomerBar._updateHeader`, after a successful
  customer change, if the new customer is generic and the sale's current mode is not
  `counterPickup`, call `setMode(counterPickup)` + `updateHeader(fulfillmentIntent: counterPickup)`
  and surface a one-time notice explaining the reset.

**Rationale.** Keeps the existing "refuse, don't disable" shape spec 023/025 already established;
the mid-sale demotion closes a real gap (an otherwise-reachable delivery/mixed sale attached to a
customer that can't use either) with the smallest change that keeps the sale internally
consistent.

**Risk to record:** `posDefaultCustomerId` is a build-time constant the file itself documents as
drift-prone across deployments (`pos_defaults.dart:1-31`). Today drift only mislabels a UI band;
under FR-015/FR-016 it becomes a functional mis-gate. Not fixed by this feature — flagged as an
existing, now slightly higher-stakes, known issue.

---

## R9 — The pricing-grid lost-edit bug: root cause and fix

**Findings.** Not a race: Flutter deliberately suppresses the notification. Tapping another cell
calls `openCell(keyB)` (`pricing_grid_controller.dart:355-359`), which sets `active = keyB`
**without touching cell A**. On the next build, A's `TextField` unmounts
(`price_cell.dart:206-207`), and Flutter's `FocusManager._markDetached` removes the node from
`_dirtyNodes` before it can notify — so A's `_onFocusChange` (`:152-154`) never runs and the typed
value is dropped. The only thing that ever saves such an edit today is incidental:
`EditableText`'s tap-outside handling unfocuses on pointer-*down* on desktop/web (before the
InkWell's tap-up fires), so it happens to commit there by ordering luck; native mobile touch does
not unfocus on tap-down at all, so the edit is lost outright. `dispose` (`:137-150`) removes the
listener *before* teardown specifically to avoid a dispose-time commit, so an unmount-while-active
cell (page change, filter change, resync) loses its edit the same way. `commitCell` also sets
`active: null` on every path (`pricing_grid_controller.dart:753-789`), which can close a
just-opened cell if a stale commit lands after it.

**Decision.** Lift the in-progress edit into `PricingGridState` as a per-cell draft, rather than
patching the widget's Focus lifecycle. `openCell(next)` first commits the currently-active cell's
draft (if any and if changed) through the same `commitCell` path used by keyboard moves, then sets
`active = next`. This makes "no case exists in which moving to another cell leaves an edit
uncommitted" (FR-009) true by construction — the commit is the controller's own responsibility, not
contingent on which widget lifecycle callback happens to fire for a given input method (mouse,
keyboard, or touch) — and is directly unit-testable in `pricing_grid_controller_test.dart` with no
widget pump required. Guard `commitCell` itself against a duplicate in-flight commit (compare
against the value already in flight, not only `state.rows`, which updates late) so a keyboard move
immediately followed by `openCell`'s own commit cannot double-write.

**Rationale.** The widget-level alternative (commit on `didUpdateWidget`'s active→inactive edge,
plus a dispose-time commit, plus a discard flag for Escape, plus a `_lastCommitted` idempotence
guard per cell) fixes the reported bug but keeps the invariant tied to Focus/lifecycle timing —
fragile to any future new way of leaving a cell, and only testable end-to-end with widget pumps.
Given this is a silent-data-loss bug (the worst class), the larger, controller-owned fix is
justified.

**Alternatives considered.** The widget-level patch above: rejected as primary fix for the
robustness reason just given, though its idempotence-guard idea (compare against the last
committed value) is still needed regardless of where the commit lives.

---

## R10 — Currency decimal-digit gaps in the pricing surface

**Findings.** Reading-mode cells already honor `currencyDecimalDigits`
(`price_cell.dart:232,267`) — the gap is entirely in editing mode. `price_cell.dart:121-123`
seeds the `TextEditingController` from the **raw wire string** (`widget.price?.price`, a
`Numeric(18,4)` value like `20.0000`) instead of `formattersProvider.field.price(...)`, and
`:156-165` commits the raw typed text instead of routing it through `field.parsePrice()`. The
single-product edit dialog (`pricing_screen.dart:154,192`) has the identical raw-seed/raw-commit
pair. `adjust-percent` (`pricing_grid_controller.dart:700-719`) hardcodes `.round(scale: 2)`,
wrong for a non-default digit count.

**Decision.** Route both edit paths (grid cell and single-product dialog) through
`AppFormatters.field.price()`/`parsePrice()` for seed and commit, and parameterize the
adjust-percent rounding on `currencyDecimalDigits` instead of a literal `2`. `field.price()`
already pads trailing zeros to the configured digit count and `parsePrice` round-trips through
`Decimal`, so this is a pure routing fix, not a new formatting mechanism — consistent with the
"one formatting surface" constitution rule (§V) the guard test already partially enforces (the
guard only bans direct `NumberFormat`/`toStringAsFixed`, not a raw-string pass-through, which is
exactly how this gap survived).

**Rationale.** Closes the exact live-testing complaint (a price cell showing `20.0000` instead of
`20.00`) without inventing a second formatting path, and fixes the dialog and the percent-adjust
helper the same way since they share the same bypass pattern.

---

## R11 — Warehouse picker: three-state stock flag

**Findings.** `productStockCacheProvider` (`product_stock_cache.dart:14`) is populated only on
product lookup (`capture_step.dart:55`, `order_screen.dart:75`) from `ProductLookupResult.stock`.
A missing product-key entry means nothing is known for *any* warehouse; a present product-key
with no entry for warehouse *W* means unknown for *W* specifically. `_stockIn()`
(`sale_line_editing.dart:390`) already returns `null` for both cases — "unknown" is already
distinguishable from "zero" with no data-model change.

**Decision.** Compute a three-state flag (enough / short-or-none / unknown) per dropdown item
using the exact comparison `shortfall()` already uses (`sale_line_editing.dart:411-424`:
`available.sign <= 0` ⇒ none, `ordered > available` ⇒ short), so the picker and the existing
line-level warning can never disagree. Render it as icon + short wording (reusing
`Icons.warning_amber`, already used by the shortfall row) rather than a filled `status_chip`
container, which is sized for table cells and too tall for a dropdown item row — color alone is
not used as the only signal, per Material 3 guidance. Keep every `DropdownMenuItem.enabled` at its
default `true` (FR-020/FR-021 — informational, not blocking) and use
`DropdownButtonFormField.selectedItemBuilder` to keep the *closed* display name-only, so the
shared row-height/baseline invariant (`sale_line_layout.dart:71,103`, asserted by
`sale_line_row_test.dart:505,567` and `sale_line_symmetry_test.dart`) is not put at risk by a
badge in the closed state.

**Rationale.** Reuses the shortfall logic and iconography that already exist rather than inventing
a second stock-comparison path, and respects an existing, test-asserted layout invariant instead
of quietly breaking it.

**Confirmed live during implementation (T046 spike):** the product-lookup call's `warehouse:`
parameter **does** filter the returned `stock` list to just that warehouse — requesting
`warehouse=12` on a facility with warehouses `[12, 15, 16]` returned `stock` for warehouse 12
only. Since `capture_step.dart`/`order_screen.dart` only ever look up a product at the register's
single default warehouse, `productStockCacheProvider` never holds more than one warehouse's entry
per product — every warehouse *other than* the one last looked up shows as "unknown" in the
picker, never falsely "in stock" (still FR-020/021/022-compliant), but the flag's practical value
is limited to that one warehouse until a per-warehouse stock fetch is added. That fetch is out of
scope for this feature — recorded here as a known limitation, not fixed.

---

## R12 — Auto-assigning the first delivery destination in one call

**Findings.** `LineDistribution.claimable` (`ordered − distributed`, floored at 0,
`line_distribution.dart`) is already exactly "full remaining quantity" — with no destinations yet,
`claimable == ordered` for every line. `DeliveryOrderRepository.create` already accepts
`List<DestinationLineRequest>? lines`
(`delivery_order_repository.dart:22-30`), and *omitting* `lines` is documented to claim everything
the sale still owes (already relied on by `sweepRemainderToCounter()`,
`delivery_controller.dart:143-149`) — `addDestination` today deliberately passes `lines: const []`
to avoid exactly that.

**Decision.** In `DeliveryController.addDestination`, when the current destination list is empty,
build an explicit line list from `distributionFor(...)`'s `claimable` per line (skipping zero
amounts) and pass it to `create` — one POST, atomic: a refused create leaves nothing behind
(`DestinationEditor._submit` already renders that failure, `destination_editor.dart:151-157`), so
there is no partial-assignment case to handle. Second and later destinations keep passing
`lines: const []` (unchanged, FR-025). Adjustability (FR-024) and quantity release on delete
(FR-025's neighbor, deletion) need no code change — the stepper already re-syncs from
`Destination.lines` on every build (`destination_card.dart:156-172`), and `removeDestination`
already recomputes `perDestination` from the remaining destinations.

**Rationale.** An explicit line list (vs. relying on "omit means everything") keeps the client's
own figure authoritative and avoids ambiguity if a counter-pickup destination already exists
alongside an empty delivery list. One call means no per-line partial-failure handling needs to be
invented.

**Alternative considered.** N separate `assignLine` calls after create: rejected — would require
building new per-line failure handling (today it exists only inside `DestinationCard._commit`,
unreachable from the controller) for no benefit over the single-call route.

---

## R13 — Debounce: two settings, not one

**Findings.** Three independent debounce implementations exist today:
`catalog_entity_picker.dart:101` (300ms, search), `product_search_field.dart:72-73` (300ms,
search), and `quantity_stepper.dart:15` (`kQuantityCommitDebounce`, 400ms, a write-coalescing gate
reused by `destination_card.dart` and `sale_line_editing.dart`). The 400ms figure is not a search
delay — it is the window `PendingWrites` holds open before allowing step advancement
(`critical_action_guard.dart:66-76`), a different mechanic with a different risk profile than
delaying a read.

**Decision (confirmed with the requester).** Two settings, not one:
`AppSettings.inputDebounce` (env `INPUT_DEBOUNCE_MS`, default 300ms) for the two search fields,
and `AppSettings.quantityCommitDebounce` (env `QUANTITY_COMMIT_DEBOUNCE_MS`, default 400ms) for
the quantity-stepper commit window — both parsed with the same fallback-not-crash pattern as
`FormattingSettings._parseDigits` (`formatting_settings.dart:109-113`), documented in
`.env.template`. `catalog_entity_picker.dart` becomes `ConsumerStatefulWidget` to reach
`ref.read(inputDebounceProvider)` (a small derived provider, mirroring `formattersProvider`); the
other two call sites already run inside `ConsumerState` hosts.

**Rationale.** A single knob cannot satisfy FR-030 ("each setting defaults to the value already
in effect today for its category") since the two categories' current defaults differ (300 vs
400ms) and serve different purposes — this was surfaced to and confirmed by the requester (spec.md
FR-028..FR-030, Assumptions) rather than assumed.

---

## R14 — Sequencing the two mbe-api-dependent Customer changes

**Findings.** `CustomerCreate.code` is a non-nullable generated field (`customer_create.dart:35`);
`CustomerUpdate.code` is already nullable (`customer_update.dart:35`). Both `shipping` fields are
already `bool?` on both DTOs, so simply not sending them needs no backend change at all.

**Decision.** Split by what's blocked and what isn't:
- **Doable now, no regeneration needed:** relax the client-side "code required" validation
  (`customer_form_controller.dart:165-167`); change the update path to omit `code` when blank
  instead of sending `""`; remove the two shipping switches from both the main form and the POS
  inline-create mini-form, and stop reading `Customer.shipping`/`shippingRequiredDocument`
  entirely (R8 already replaces their one behavioral consumer).
- **Blocked on mbe-api#198 + regeneration:** actually omitting `code` on **create** (today's
  generated field is non-nullable, so create must still send `code: state.code` — an empty
  string — until regenerated), and confirming whether the response schema keeps `code` as a
  required string or also becomes nullable.
- **Blocked on mbe-api#199 + regeneration:** removing the two fields from the generated DTOs
  themselves (`./tool/generate_api_client.sh`) — not user-visible, purely a codegen cleanup once
  the backend field is gone.

**Rationale.** Maximizes what ships today without waiting on the backend, while keeping the
regeneration-gated slice small and explicit, consistent with §198/#199 landing same-day per the
requester.

---

## Summary: research questions closed

Every `NEEDS CLARIFICATION` the Technical Context in plan.md would otherwise carry is resolved
above: R1 (POS status mechanics), R6/R8 (generic-customer mechanism, both call sites), R9 (root
cause + fix shape for the pricing bug), R11 (stock-cache semantics), R13 (one vs. two debounce
settings), R14 (mbe-api sequencing). No unresolved *technical* unknown remains going into Phase 1.

One open **product** question is carried forward rather than resolved here: R3's recommendation
to merge the "Borrador"/"Sin pagar" resume buckets needs the requester's sign-off before it ships
(see plan.md Risks) — it is a consequence of R1, not a separate ask, but it changes what cashiers
see on a screen they use constantly.
