# Contract: The order workspace

**Feature**: `039-back-office-order-workspace` | **Date**: 2026-09-11

The screen itself: its routes, its three steps, what gates each transition, and
what happens to the code and tests it replaces.

---

## 1. Routes

Unchanged paths, unchanged placement — only the screen behind them changes.

| Path | Placement | Renders |
|---|---|---|
| `/sales/orders` | Inside the app shell, branch index 20 | `SalesOrdersListScreen` — **untouched** (spec A1, OS-2) |
| `/sales/orders/new` | Top-level sibling, no shell | `OrderWorkspaceScreen()` |
| `/sales/orders/:orderId` | Top-level sibling, no shell | `OrderWorkspaceScreen(orderId:)` |

Gate stays `PrivilegeGate(SystemObject.salesOrders, AccessRight.read)` —
deliberately not `pos` (FR-047).

`/sales/orders/new` writes nothing on open (FR-005). The first customer
selection opens the order and rewrites the URL to its id, mirroring
`pos_workspace_screen.dart`'s existing `_maybeRewriteUrl`.

---

## 2. Step host

```
┌─ step indicator: Cliente · Venta · Entrega ─────────────┐
│                                                         │
│   cliente  →  CustomerStep       (new, this feature)    │
│   venta    →  CaptureStep        (shared, POS's own)    │
│   entrega  →  DeliveryStep       (shared, POS's own)    │
└─────────────────────────────────────────────────────────┘
```

Always three steps — unlike POS, whose count varies with fulfilment mode,
because this workspace has no mode to vary (FR-021).

The host installs the nested `ProviderScope` described in
[shared-step-seam.md](./shared-step-seam.md) §5 **above** the step widgets, so
every leaf resolves to the order rather than to the register.

---

## 3. Steps and their gates

### Cliente

| | |
|---|---|
| Renders | Customer search (`CatalogEntityPicker`), inline-create action |
| Excludes | The generic walk-in customer, from results and by refusal (FR-011, FR-012) |
| On select | `updateHeader(customer:, salesperson:, paymentTerms:, fulfillmentIntent: delivery)` — opens the order in one `POST` (FR-014, FR-015, FR-016) |
| Advances | To Venta, automatically, once a customer is attached |
| Skipped | When a reopened order already has a real customer (§5) |

### Venta

| | |
|---|---|
| Renders | `CaptureStep` + `OrderHeaderPanel` (below the customer bar, per spec 037) |
| Forward action | "Continuar a entrega" |
| Enabled when | `isEditable && lineCount > 0 && !writesPending` |
| Before advancing | `resolveUnconfirmedEdits(context, ref, salesOrderWritesScope)` (FR-008) |
| Not rendered | `FulfillmentModeSelector` (FR-021) |
| Header omits | Ship-to and contact — destinations own them now (FR-050) |

### Entrega

| | |
|---|---|
| Renders | `DeliveryStep(sale:, mode: FulfillmentMode.delivery, onClose:)` |
| Commits the order | On the **first destination create** — the server permits no other ordering (spec A2, research R2) |
| Close requires | Every unit assigned; `isMixed: false` (FR-030) |
| Not offered | Counter-pickup destination, remainder sweep (FR-031) |
| Back to Venta | Only while `status == draft`, i.e. before the first destination (FR-006) |

---

## 4. Commitment and read-only

Commitment is **not** a step transition and has no button. The first
`POST /delivery-orders` triggers `confirmBeforePayableAction`, which confirms
the order because the server refuses to deliver an uncommitted one.

On refusal (zero-priced line, insufficient stock), the failure arrives through
`saleConfirmFailureProvider`: the workspace shows the server's message — which
names the offending products — and returns to Venta (FR-033).

Once `status != draft`: read-only in place, actions **withdrawn rather than
disabled** (FR-034), priority still editable (FR-035).

---

## 5. Opening an existing order

```
1. Is it this workspace's order?          ── no ──▶ decline, explain (FR-053)
        │ yes                                       [#209; interim guard R5]
        ▼
2. status == cancelled?                   ── yes ─▶ read-only, no step
        │ no
        ▼
3. status == draft   ──▶ Venta            (or Cliente, if no real customer)
   status == completed | paid ──▶ Entrega
```

Step 3 needs no extra fetch: for an order this workspace raised, "is no longer
a draft" and "has at least one destination" are the same condition (research R2).

---

## 6. Disposition of existing code and tests

### Source

| File | Disposition |
|---|---|
| `orders/order_screen.dart` | **Deleted** — replaced by `order_workspace_screen.dart` (FR-048) |
| `orders/order_editor_controller.dart` | Kept; `open()` gains `fulfillmentIntent`, and later `origin` |
| `orders/order_header_panel.dart` | Kept; ship-to and contact removed (FR-050). Spec 037's design is not revisited (research R4) |
| `orders/order_no_register_notice.dart` | Kept, unchanged — it is the list's blocked state |
| `sales_orders_list_screen.dart`, `sales_orders_list_controller.dart` | **Untouched** |
| `capture_step.dart`, `fulfillment_mode_selector.dart`, `customer_bar.dart`, `delivery_step.dart`, `delivery_controller.dart`, `pos_confirm.dart`, `sale_editor.dart`, `pos_workspace_screen.dart` | Migrated onto the seam (seam contract §1–§4) |

### Tests

Keys are preserved wherever the behaviour survives, so a test can be re-pointed
at the new host rather than rewritten (research R7).

**A distinction that matters for SC-007.** The four point-of-sale *integration*
tests are repository-level — no widgets, no controllers — so they are genuinely
unaffected and must pass **byte-identical**. Three point-of-sale *widget* tests
construct `CaptureStep` / `DeliveryStep` directly and will need a
signature-only edit when those widgets gain their host parameters. That is a
mechanical compile fix, not a behaviour change, and SC-007 must be read that
way: *no POS test's assertions change*.

| Test | Disposition | Why |
|---|---|---|
| `order_screen_test.dart` | **Re-home** | Asserts lazy-open, the generic-customer gate and confirm enablement — all of which move to the Cliente and Venta steps |
| `order_screen_readonly_test.dart` | **Re-home** (1 test survives) | Read-only gating moves hosts; its final list-side test is untouched |
| `order_cancel_test.dart` | **Re-home** | Cancel behaviour is unchanged; ports cheaply once the new host places the same keys |
| `order_resume_test.dart` | **Re-home** | Same behaviours, new host, plus step-aware resume |
| `order_write_gating_test.dart` | **Re-home — highest value of the four** | Guards the write-scope isolation the seam exists for; the gate moves into `CaptureStep` |
| `order_header_disclosure_test.dart` | Modify | Drops the ship-to and contact assertions (FR-050); re-points the pump host |
| `order_header_density_test.dart` | Modify | Measurement survives; the collapsed/expanded `CompactField` counts drop by 2 |
| `order_no_register_test.dart` | Modify | Test 1 (list-side) survives verbatim; test 2 re-points to the workspace |
| `sales_orders_compact_test.dart` | **Modify — despite its name** | Only its first test is list-side; the rest pump the order editor at 390 px. Not covered by "the list is untouched" |
| `sale_editor_isolation_test.dart` | **Extend — highest value overall** | Provider-level, so it survives as-is; must grow to cover the delivery surface and the confirm helper, where the new coupling risk lives (seam §6 invariant 3) |
| `order_editor_controller_test.dart` | Survives | The controller is kept; add cases when origin and intent land |
| `delivery_controller_test.dart` | Modify (small) | It seeds `posSaleControllerProvider` precisely because `addDestination` confirms through it — that seeding is exactly what the seam changes |
| `pos_write_gating_test.dart`, `pos_compact_delivery_test.dart`, `delivery_step_layout_test.dart` | Signature-only edit | Construct the shared steps directly; assertions unchanged |
| `pos_workspace_route_test.dart`, `pos_step_controller_test.dart`, `pos_sale_workability_test.dart` | Unchanged | POS vocabulary and routes are untouched |
| `sales_orders_{list_screen,filters,admin_facets,filter,scoping}_test.dart` | Unchanged | List-side, out of scope |
| All 4 integration flows | **Byte-identical** | Repository-level; this is SC-007's operational proof |

**Trap**: `sales_orders_list_screen_test.dart` *exports* `stubListOrders`, which
`order_screen_readonly_test.dart` and `order_no_register_test.dart` import.
Re-homing those two must not break the export.

### New tests

| Test | Covers |
|---|---|
| `order_step_controller_test.dart` (unit) | Step reconstruction from status (data-model §4); transition guards. Model on `pos_step_controller_test.dart` |
| `order_workspace_test.dart` (widget) | The three steps, their gates, read-only after commitment |
| `order_workspace_route_test.dart` (widget) | Routes and the `/new` → `/:orderId` rewrite. Model on `pos_workspace_route_test.dart` |
| `order_workspace_compact_test.dart` (widget) | Compact tier — constitution VI |
| `order_customer_step_test.dart` (widget) | Generic-customer exclusion and refusal; inline create |
| `order_workspace_flow_test.dart` (integration) | User Story 1 end to end |

### Harness

`test/widget/features/sales/pos_test_harness.dart` is already imported by every
order-editor test, so adoption is proven. It needs four additions, three of
which retire existing duplication:

| Addition | Why |
|---|---|
| `pumpOrdersRouted` | `pumpPosRouted` wires POS routes only. `sales_orders_filters_test.dart` already keeps a private copy for the orders routes — the natural place to consolidate |
| `fixedOrderSale` | Twin of `fixedPosSale`, needed wherever the confirm helper can fire |
| An auth/privilege helper | `_FixedAuthNotifier` plus a privileged `User` is re-declared in **7** order tests |
| `MockCustomerRepository` | Duplicated across **6** files |

## 7. Localization

Verified against `lib/l10n/app_en.arb` and `app_es.arb` (35 `salesOrder*` keys,
in parity).

**Move, do not delete (8).** These belong to `order_screen.dart` and die with
it, but the workspace still needs every one:
`salesOrderConfirmAction`, `salesOrderNoLinesYet`, `salesOrderChooseCustomerFirst`
(a natural fit for the Cliente step), `salesOrderCancelAction`,
`salesOrderCancelDialogTitle`, `salesOrderCancelDialogMessage`,
`salesOrderCancelDialogKeepEditing`, `salesOrderCancelDialogConfirm`.

**Retire (2).** `salesOrderContactLabel` and `salesOrderShipToLabel` — FR-050
moves both to destinations, and the delivery surface already has its own
(`posDeliveryContactTitle`, `posAddDestinationSheetTitle`, whose Spanish string
is already "Datos de entrega").

**Add.** There is **no** existing key for a *Cliente* step — the nearest strings
are field, column and menu labels. New `salesOrderStep*` keys are needed for the
three step names and the progress announcement. New rather than reusing
`posStepVenta` / `posStepEntrega`: this plan keeps POS vocabulary in POS
(research R1), and the same argument applies to its strings. The forward-action
label is likewise a new key, carried through `SaleTotalsBar.actionLabel`, which
already exists for exactly this.

The Entrega step's close button is labelled `posFinishSale` ("Finalizar venta")
and is owned by `line_distribution_panel.dart`, not `delivery_step.dart`. An
order-flavoured label therefore needs a parameter on that panel — a label
parameter only, not another seam provider.

**Do not touch (2).** Both are shared and have exactly one use each:
`salesOrdersMenuTitle` (`core/navigation/nav_destinations.dart:315`) and
`salesOrderPaymentTermsLabel` (`capture/customer_bar.dart:509`, so it renders at
the register too).

**Unchanged (16 + 6).** The keys that follow `order_header_panel.dart`, which is
kept, and the six owned by the untouched list screen.

Every add and every retirement lands in `app_en.arb` and `app_es.arb` together.

---

## 8. Widget keys to preserve

Twelve string keys on the replaced files are test-load-bearing and need a
deliberate home in the new workspace:

`sales_order_confirm_button` (passed as `SaleTotalsBar.actionKey` — preserve
that override point), `sales_order_cancel_button`,
`sales_order_cancel_confirm_button`, `sales_order_choose_customer_hint`,
`sales_order_product_search_field`, `sales_order_no_register_notice`,
`sales_order_{priority,currency,recipient,comment,salesperson}_field`,
`sales_order_more_details_toggle`.

The keys the tests lean on hardest live in the *children* the workspace
inherits unchanged — `pos_customer_picker`, `sale_line_discount_{id}`,
`delivery_close_button`, `pos_totals_footer` — so those need no action beyond
not being disturbed.
