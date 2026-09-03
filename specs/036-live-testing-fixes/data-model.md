# Phase 1 Data Model: Live Testing Session Fixes

**Feature**: 036-live-testing-fixes

No new persisted server entities. Two `Customer` fields are removed and one becomes optional
(pending mbe-api#198/#199 for the wire contract itself), and one client-side value object
(`PosStep` transitions) gains a new state. Everything else below is view-state or configuration
shape — what the tasks will actually touch.

---

## 1. `Sale.status` timing (behavior change, no schema change)

The `SaleStatus` enum itself (`draft`/`completed`/`paid`/`cancelled`) is unchanged. What changes
is *when* the client asks the server to move a sale from `draft` to `completed`.

| Trigger | Today | After (R1) |
|---|---|---|
| Advancing Venta → Cobro | `confirm()` called; status → `completed` | **no server call**; status stays `draft` |
| Submitting the first payment | requires `completed` (already true) | `confirm()` called first, then `createPayment` |
| Leaving Cobro on credit terms | requires `completed` (already true) | `confirm()` called first |
| First delivery-order `create` (delivery/mixed) | requires `completed` (already true) | `confirm()` called first |

**Rules**

- `confirm()` MUST run exactly once per sale, immediately before the first of the three
  operations above that actually needs `completed` status (FR-008).
- A `confirm()` failure (empty order, zero-priced line, stock shortfall) MUST be routed back to
  the Venta step's existing error rendering, not surfaced as a payment or delivery failure.
- `Sale.isEditable` (`status == draft`) and every reader of it are **unchanged** — R1's whole
  point is that this predicate stays correct without modification.

**Owners**: `PaymentController.submit`, the Entrega step's first delivery-order create call, and
the credit-terms leave-Cobro path — all three gain a `confirm()` call they don't make today.

---

## 2. `PosStep` transitions (new backward transition)

| Method | Direction | Guard |
|---|---|---|
| `advanceToCobro()` | Venta → Cobro | `canConfirm` (≥1 line) — unchanged |
| `advanceFromCobro()` | Cobro → Entrega | `canLeavePayment` — unchanged |
| `jumpTo(step)` | any → any | resume-only, unchanged |
| **`returnToVenta()`** *(new)* | Cobro/Entrega → Venta | **`canReturnToCapture`** *(new)*: `sale.isEditable && !hasNonCancelledPayments` |

**Rules**

- `hasNonCancelledPayments` is derived from `orderPaymentsControllerProvider(sale.id)`, filtered
  on `!SalePayment.cancelled`; a loading/error state denies the transition (conservative default,
  matching `sale_workability.dart`).
- `returnToVenta()` does not touch the server — the sale is already `draft` (per §1), so nothing
  needs to be told to revert.

---

## 3. `PricingGridState` active-cell draft (new field)

| Field | Type | Source | Lifecycle |
|---|---|---|---|
| `activeDraft` | `String?` | the typed text of the currently-active cell | set on every keystroke in the active cell; cleared when that cell is committed or discarded |

**Rules**

- `openCell(next)` MUST commit `activeDraft` for the current `active` cell (via the existing
  `commitCell` path) **before** reassigning `active`, whenever `activeDraft` differs from the
  cell's last-known committed value (FR-009).
- Escape MUST discard `activeDraft` without committing, then call `openCell(null)`.
- `commitCell` MUST treat an in-flight commit for the same cell as authoritative over `state.rows`
  (which only updates once the server responds), so a keyboard-triggered commit immediately
  followed by an `openCell`-triggered commit cannot write twice (FR-009's "no case" guarantee).

**Owners**: `PricingGridController` (currently `pricing_grid_controller.dart`) gains `activeDraft`
and the commit-before-switch call; `PriceCell` no longer needs its own focus-loss commit path
once the controller owns this.

---

## 4. `Customer` entity (fields removed / relaxed)

| Field | Today | After |
|---|---|---|
| `code` | `required String` | `String?` — optional, client-relaxed now; wire-level omission on create is gated on mbe-api#198 |
| `shipping` | `required bool` | **removed** |
| `shippingRequiredDocument` | `required bool` | **removed** |

**Rules**

- The Customer form MUST accept an empty `code` and MUST NOT render either removed field
  (FR-011..FR-014).
- Until mbe-api#198 ships and the client is regenerated, `code` is still sent as `""` on create
  (the generated `CustomerCreate.code` is non-nullable); the update path already supports omitting
  it (`CustomerUpdate.code` is nullable today).
- Nothing MUST read `Customer.shipping`/`shippingRequiredDocument` after this feature — their one
  consumer (fulfillment-mode gating, see §5) is re-derived from the customer's identity instead.

**Owners**: `Customer`/`CustomerListItem` entities, `CustomerFormController`, `CustomerRepository`
and its impl, plus the POS inline-create mini-form — all listed concretely in research.md R14.

---

## 5. Generic-customer predicate (new, shared)

A single function, not a new entity, but load-bearing across two features:

```
isGenericCustomer(int customerId) -> bool   // customerId == AppSettings.posDefaultCustomerId
```

**Consumers**

- Sales Order customer picker (`CustomerBar.excludeGenericCustomer`) — filters this id out of
  search results (FR-002).
- POS fulfillment-mode selector — refuses delivery/mixed when the sale's customer satisfies this
  predicate (FR-015), and triggers the auto-demote-to-pickup path when a customer change makes it
  newly true (FR-016).

**Rule**: both consumers MUST call the same function — no independent id comparison — so they can
never disagree about which customer is "the" generic one.

---

## 6. Warehouse stock flag (new, derived, not persisted)

| Value | Condition | Rendered as |
|---|---|---|
| `enough` | cached `available` exists and `available >= ordered` | no flag |
| `short` | cached `available` exists, `0 < available < ordered` | warning icon + `{available}` wording |
| `none` | cached `available` exists and `available <= 0` | warning icon + "no stock" wording |
| `unknown` | no cached entry for this product+warehouse this session | neutral wording, no warning styling |

**Rules**

- Computed from the same comparison `shortfall()` already uses — the picker flag and the
  line-level warning MUST never disagree (FR-020).
- `DropdownMenuItem.enabled` stays `true` in every state — informational only (FR-022).
- The dropdown's *closed* display MUST remain name-only (via `selectedItemBuilder`) so the shared
  row-height/baseline invariant is unaffected.

**Owners**: `_availabilityIn`/`_stockIn` in `sale_line_editing.dart`, extended into this
four-value flag; consumed by the warehouse `DropdownMenuItem` builder.

---

## 7. Delivery destination line-quantity default (behavior change, no schema change)

| Destination | `lines` sent to `create` |
|---|---|
| First (list was empty) | every sale line's current `claimable` quantity, explicitly listed (skipping zero) |
| Second or later | `[]` (unchanged) |

**Rule**: this MUST be a single `create` call carrying the full explicit line list — not `N`
separate `assignLine` calls — so a refused create leaves nothing partially assigned (FR-023).

---

## 8. `AppSettings` (extended)

| Field | Env var | Default | Used by |
|---|---|---|---|
| `currencyDecimalDigits` *(existing)* | `CURRENCY_DECIMAL_DIGITS` | 2 | every currency field via `formattersProvider` — this feature closes remaining bypasses (§ research R10), adds none |
| `inputDebounce` *(new)* | `INPUT_DEBOUNCE_MS` | 300ms | `catalog_entity_picker.dart`, `product_search_field.dart` |
| `quantityCommitDebounce` *(new)* | `QUANTITY_COMMIT_DEBOUNCE_MS` | 400ms | `quantity_stepper.dart` (and its two reusers) |

**Rules**

- Both new fields MUST parse with the same fallback-not-crash pattern as
  `FormattingSettings._parseDigits` — a malformed or absent value falls back to the documented
  default, never a startup failure (constitution §V).
- Both MUST be listed in `.env.template` with their defaults (constitution §V).
- Neither is a per-user preference — both resolve once at startup, like every other app setting.
