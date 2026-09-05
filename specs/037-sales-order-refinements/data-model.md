# Phase 1 Data Model: Sales Order Refinements

**Feature**: 037-sales-order-refinements | **Date**: 2026-09-04

No new entity, no new field, no schema change, no codegen. This feature reads one existing value it
was not reading before, writes one existing field from a new place, and adds one shared widget. What
follows is the complete inventory of state this feature touches.

## 1. Entities — read, unchanged

| Entity | Field | Why it matters here |
|---|---|---|
| `CustomerListItem` (`features/catalog/domain/entities/customer_list_item.dart:22`) | `creditLimit` — non-nullable `String`, `Decimal`-parseable | **Newly read at attach time.** The picker already hands the whole item to `onSelected`; this feature reads its credit limit to derive terms (research R2). No change to the entity. |
| `Sale` (`features/sales/domain/entities/sale.dart`) | `paymentTerms` | Already written today, but only by the terms dropdown. Now also written as a consequence of attaching a customer. No change to the entity. |
| `Sale` | `balance` | Stops being *displayed* by `OrderHeaderPanel` (FR-001). Still carried, still used by the orders list screen. |
| `Customer` | `creditLimit` | Still read by `_TermsFact` for the dropdown's enablement and its supporting text. Unchanged. |

`creditLimit` is non-nullable on both the list item and the full record, and mbe-api defaults it to
`0`, so **"no credit line" means exactly zero** — there is no null case to model (research R2).

## 2. Derived value — new

One derivation is introduced, in the presentation layer:

```
customerHasCredit(CustomerListItem) := !isZeroAmount(item.creditLimit)
```

It reuses `isZeroAmount` (`features/sales/domain/money.dart:110`) — the same predicate `_TermsFact`
already applies to the full `Customer` record — so the dropdown's "is credit selectable" rule and
the write's "should credit be the default" rule cannot drift apart.

This is a pure function of a value already in hand. It is deliberately **not** a provider: it needs
no caching, no async, and no lifecycle.

## 3. State transitions — payment terms

The only behavioural state change in this feature. `T` is the terms the client sends; blank means
the field is absent from the payload.

| Trigger | Sale exists? | Customer's credit limit | Client sends | Resulting terms |
|---|---|---|---|---|
| Attach customer | no | any | *(nothing — existing fast path)* | Server derives: credit if limit > 0 and not walk-in, else immediate |
| Attach/change customer | yes | zero | `T = immediate`, in the attach write | immediate |
| Attach/change customer | yes | > 0 | attach write unchanged, then `T = credit` as a separate write | credit, or immediate if the server refuses |
| User picks terms | yes | any | `T = user's choice` | the user's choice, or the server's refusal |
| Any other header edit | yes | any | *(terms absent)* | unchanged |

Three invariants fall out of that table, and each maps to a requirement:

- **I1 (FR-010)** — terms are only ever written by attaching a customer or by the user's own choice.
  No other edit touches them.
- **I2 (FR-008)** — nothing re-applies the default while the same customer stays attached, because
  the only trigger is an attach.
- **I3 (FR-010a)** — the customer attach can never fail *because of* the terms default. Immediate is
  unconditionally accepted so it is safe to bundle; credit is conditionally accepted so it is never
  bundled with anything whose failure would matter (research R3).

## 4. Widget contract — new shared component

One widget is added to `core/widgets/`, per constitution §VI's rule that form-field wrappers live
there rather than being reimplemented per module (research R6).

**`CompactField`** — a caption above a control, with an optional supporting line beneath.

| Slot | Type | Notes |
|---|---|---|
| `label` | `String` | Rendered through `typeRoles.metricLabel`, not raw `labelSmall` — the existing hand-rolled version bypasses the token system. |
| `child` | `Widget` | The control, or a `Text` for a read-only value. |
| `supportingText` | `String?` | The slot `_TermsFact` uses for the credit-limit figure and its "no credit line" hint. |
| `enabled` | `bool` | Dims the caption to match the disabled-field convention. |

Constraints, all of them consequences of research:

- **No fixed width.** It fills whatever width its parent gives it (research R7). Inside
  `ResponsiveFormGrid` that is the cell; a dropdown child uses `isExpanded: true`.
- **Vertical padding symmetric, from spacing tokens only** — no bare pixel literals (constitution
  §VI, line 436).
- **Height driven by content**, so it grows rather than clips as text scales (research R8).

Adopters: `OrderHeaderPanel` (all fields but the comment) and `CustomerBar._TermsFact`. The three
other hand-rolled label-over-value sites are **not** migrated (research R6).

## 5. Localization

| Key | Before | After |
|---|---|---|
| `salesOrderPaymentTermsLabel` | "Payment terms" / "Forma de pago", used by the header panel's read-only field | **Relocated** — same strings, now the customer bar's terms caption |
| `posCustomerCreditLabel` | "Credit line" / "Crédito", used only by the customer bar | **Retired** — its only use is gone (verified: one call site outside the generated files) |
| `salesOrdersColumnBalance` | "Balance" / "Saldo" | **Kept** — the header's use goes, the orders list column keeps it |
| `posCustomerNoCreditHint` | supporting text under the dropdown | Unchanged |

Net: one key retires, one moves, none is added. Both `.arb` catalogues stay in sync, and the parity
test (`test/unit/core/l10n_parity_test.dart`) enforces it.

## 6. Navigation

`kNavigationTree`'s `sales-orders` entry moves after `pos` within the Sales group
(`core/navigation/nav_destinations.dart`). `NavBranch.salesOrders = 20` and `NavBranch.pos = 18` are
**untouched** — display order comes from tree position, branch indices from router branch order, and
the two are already documented as independent (research R10). No route, gate, or branch index
changes.
