# Contract: the quote as a third capture host

**Feature**: `040-sales-quotes` | **Date**: 2026-09-20

What the quote screen provides so that `CaptureStep` serves it, and what `CaptureStep` must
change to be servable. Extends — does not replace —
[`039/contracts/shared-step-seam.md`](../../039-back-office-order-workspace/contracts/shared-step-seam.md).

> ⚠ **That file is stale.** It documents a four-parameter `CaptureStep`. The shipped widget
> takes eight and `continueLabel` is optional. This contract records the shipped signature plus
> this feature's additions. **Build against the code.**

---

## 1. The provider seam

A quote host mounts a nested `ProviderScope` overriding the same four providers the order
workspace overrides together (`order_workspace_screen.dart:53-86`). Overriding a subset
silently couples the hosts.

| Provider | Quote host supplies |
|---|---|
| `saleEditorProvider` | `quoteEditorControllerProvider(quoteId).notifier` |
| `saleWritesScopeProvider` | `salesQuoteWritesScope` — a **new, distinct** constant |
| `saleConfirmErrorProvider` | the quote screen's own banner state |
| `saleConfirmFailureProvider` | the quote screen's own failure callback |

**Load-bearing**: any new provider that reads the seam must carry
`@Riverpod(dependencies: [saleEditor])`. Without it the provider resolves against the root
container and writes to the register's sale. This is how `productLookupController` is declared
and it is not optional.

---

## 2. `CaptureStep` — shipped signature plus this feature's addition

```dart
CaptureStep({
  required Sale? sale,
  required VoidCallback? onContinue,
  String? continueLabel,
  bool showFulfillmentSelector = true,
  bool excludeGenericCustomer = false,
  FulfillmentMode? attachFulfillmentIntent,
  Widget? headerExtra,
  Widget? secondaryAction,
  // added by this feature:
  bool showWarehouse = true,        // false ⇒ no picker, no stock seed, no point-of-sale lookup
  bool showAction = true,           // forwarded to SaleTotalsBar (was not forwarded)
  Key? actionKey,                   // forwarded to SaleTotalsBar (was not forwarded)
  bool showComment = false,         // forwarded to the line row/card (was not forwarded)
})
```

### Host table

| Host | `onContinue` | `continueLabel` | `showFulfillment` | `excludeGeneric` | `showWarehouse` |
|---|---|---|---|---|---|
| Register | advance to Cobro | `null` (keeps "Cobro →") | `true` | `false` | `true` |
| Order workspace | advance to Entrega | "Continuar a entrega" | `false` | `true` | `true` |
| **Quote** | **confirm the quote** | **"Confirmar cotización"** | **`false`** | **`true`** | **`false`** |

The quote is the first host whose forward action *ends* the document rather than advancing to
another step. `onContinue` is already just a callback, so this costs nothing — and it is why
the quote screen needs no step machine and no step enum.

The quote passes `attachFulfillmentIntent: null` (a quote has no fulfilment intent) and
`showAction: false` once the quote is no longer a draft.

### What `showWarehouse: false` must do

All three, together — this is one decision, not three flags:

1. **No warehouse picker** on the line row or card.
2. **No stock-cache seed** in `_addLine`, and `warehouse: null` on the add. The tax-rate seed is
   **kept** — without it a fresh line offers only zero and its own rate.
3. **No point-of-sale resolution**: skip `capture_step.dart:189-192` entirely, so a quote host
   never reads `registerPointSaleProvider` and never fetches a point of sale. `ProductSearchField`
   then receives `warehouse: null`, which the lookup already supports.

### What must not change

- The register's rendering, enabling rule (`enabled && lineCount > 0 && !writesPending`), label
  and mode selector are observably identical (FR-040, SC-007).
- Every existing POS and order-workspace test passes **unmodified**.
- `CaptureStep` gains no knowledge of document type. It is told what to show, never what it is
  showing.

---

## 3. `SaleLineRow` / `SaleLineCard`

```dart
SaleLineRow({ required SaleLine line, required int facilityId,
              bool enabled = true, bool showComment = false,
              bool showWarehouse = true })   // added
```

`facilityId` exists only to drive `facilityWarehousesControllerProvider`. With
`showWarehouse: false` it is unused; it stays required rather than becoming nullable, because
a quote always has a facility and relaxing it would weaken the order path for no gain.

**The column budget must follow.** `saleLineSingleRowMinWidth = 950.0` includes a 168 px
warehouse column, and `SaleLineColumns` carries `warehouse` as a required field. Hiding the
column without adjusting both leaves the single-row threshold ~168 px too conservative, so a
quote row falls back to two rows at widths where one would fit. The contract is: a
warehouse-less row reaches single-row layout at its own, lower threshold.

---

## 4. Invariants a test must hold

Extending the five in `039`'s seam contract:

1. A line edited in the quote host writes **only** the quote.
2. An outstanding write on a quote gates nothing at the register or in the order workspace, and
   vice versa — in **all three** pairings.
3. With all three documents open, `confirm()` resolves to the right one.
4. The register's capture step keeps its label, enabling rule, mode selector **and warehouse
   picker**.
5. The order workspace keeps its warehouse picker.
6. A quote host never issues `updateLine(warehouse:)` and never reads
   `registerPointSaleProvider`.
7. Every existing POS and order-workspace test passes unmodified.

`sale_editor_isolation_test.dart` is hardcoded pairwise and must be generalized to three hosts.
Two assertions the `039` contract already requires but nothing yet covers should be added in the
same pass: `saleConfirmErrorProvider` isolation, and `unconfirmedEditsProvider` scope isolation
(only `pendingWritesProvider` is tested today).
