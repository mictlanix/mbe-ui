# Data Model: POS Sales Fixes

**Feature**: 047-pos-sales-fixes | **Date**: 2026-10-17

No server entities change and no codegen is needed. Every change below is to client-side state or entities.

## CurrentSession (unchanged; semantics clarified)

| Field | Type | Notes |
|---|---|---|
| `state` | `SessionState` (`none` \| `open` \| `stale`) | **Valid ⇔ `open`** (R1). `stale` = expired. |
| `session` | `CashSession?` | Non-null for `open` and `stale`. Its `cashSessionId` is the redirect target (R2). |

A new derived getter, `bool get isValid => state == SessionState.open`, gives one name to the rule so screens don't each compare against the enum.

## ProductStock (new; replaces the cache value)

Lives in `lib/features/sales/presentation/capture/product_stock_cache.dart`.

| Field | Type | Source |
|---|---|---|
| `stockable` | `bool` | `ProductLookupResult.stockable` |
| `stockRequired` | `bool` | `ProductLookupResult.stockRequired` (API `stock_verification`) |
| `warehouses` | `List<WarehouseStock>` | `ProductLookupResult.stock` |

- **Derived**: `bool get checked => stockable && stockRequired` (R5).
- **Cache**: `productStockCacheProvider` holds `Map<int productId, ProductStock>`.
  - A missing key means **unknown**.
  - A present key with `checked == false` means **not tracked**, and is never short.
- **Filled by**:
  - `_addLine`, from the lookup result (as today);
  - a new `ensureStockFor(sale)` that loads the products not yet cached when the capture step opens (R4).

## WarehouseStock (unchanged)

`warehouse`, `warehouseName?` (the server always sends null; the name comes from the point of sale's warehouse list), `onHand`, `available` (= on hand − reserved).

## Stock gate (new, pure function)

`StockGate evaluateStock(Sale sale, Map<int, ProductStock> cache)`

| Output | Type | Meaning |
|---|---|---|
| `shortLineIds` | `Set<int>` | Lines in a (product, warehouse) pair whose summed quantity > `available`. |
| `unknownLineIds` | `Set<int>` | Lines of products with no cache entry, or no row for their warehouse. They are shown as a warning only. |
| `blocks` | `bool` | `sale.status == draft && shortLineIds.isNotEmpty`. |

Rules:
- Only lines whose product is `checked` are evaluated.
- Quantities are aggregated per (product, warehouse) across all lines.
- A sale that is not a draft always gives `blocks == false` (R5).
- There is no override input (Q2).

## PaymentDraft (changed)

| Field | Change |
|---|---|
| `amount` | Pre-filled with the remaining balance when the step opens and after each successful payment (was reset to `''`). |
| `methodCode`, `paymentCharge`, `requiresReference` | No longer persistent "selected" state. They are set for the length of one `tender` call. |
| `reference` | Supplied by the reference dialog for methods that need one. |
| `submitting` | Unchanged; it now also guards repeated taps (FR-017). |
| `error` | Also carries the new local validation errors: `amountRequired`, `overpayNonCash`, `sessionInvalid`. |
| `lastChange` | **New**, `Decimal?`. Set after a cash payment with change > 0. Cleared by dismissing it, by the next `tender`, or by leaving the step (R8). |

Transitions of `tender(sale, option)`:

```text
idle ──tap──▶ [submitting? → ignore]
          ├─ amount ≤ 0             → error(amountRequired)
          ├─ amount > balance ∧ ¬cash → error(overpayNonCash)
          ├─ session ≠ open (fresh) → error(sessionInvalid)  (banner + action, R2)
          ├─ requiresReference      → UI asks for reference ─cancel→ idle
          │                                                └confirm┐
          └──────────────────────────────────────────────────────▶ submitting
submitting ──ok──▶ idle(amount = new balance, lastChange = change>0 ? change : null)
           └err──▶ idle(error = e)
```

## Validation rules (traceability)

| Rule | Spec |
|---|---|
| Starting a sale needs `isValid`; `stale` → redirect to the close screen | FR-001–003 |
| Each payment re-reads the session; it must be `open` | FR-004, FR-005 |
| Short (product, warehouse) blocks Continue on a draft sale | FR-008–011a |
| Only cash may exceed the balance | FR-018, FR-019 |
| `lastChange` shown until dismissed, the next tender, or leaving the step | FR-020 |
