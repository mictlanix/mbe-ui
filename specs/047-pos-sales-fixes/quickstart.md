# Quickstart: Validating POS Sales Fixes

**Feature**: 047-pos-sales-fixes

## Prerequisites

- mbe-api running locally, and `.env` filled in. The `MBE_POS_*` account is admin. In live tests, use the product search pattern `clavo`: the pattern `a` finds nothing.
- A cashier account with a cash drawer and point of sale assigned in its user settings.
- For US1: a session left open from a previous day. Either open a session and change its `start` date in the dev DB, or reuse one that is already stale.

## Automated checks

```bash
flutter analyze
flutter test test/unit/features/sales test/unit/core
flutter test test/widget/features/sales
flutter test test/golden --update-goldens   # then review the diffs
```

## Manual scenarios

| # | Story | Steps | Expected |
|---|---|---|---|
| 1 | US1 | With a stale session, open POS → *Nueva venta*. | You land on the session's close screen, with an explanation. No sale is created. |
| 2 | US1 | With a stale session, open an existing unfinished sale → Cobro. | Methods are disabled, and a banner offers *Cerrar sesión*. |
| 3 | US1 | Close the session, return to POS. | The no-session state appears; open a session, then *Nueva venta* works. |
| 4 | US2 | In a sale, open Advanced search, type a term, pick 2 labels, toggle *Inventariable*. | Both labels are still selected, the term is kept, and the results match all filters. |
| 5 | US3 | Add a stock-tracked product, then set qty above what the line's warehouse has available. | The line is marked short, and *Continuar* is disabled with a reason. Lowering the qty or switching warehouse enables it. |
| 6 | US3 | Leave the sale with a short line, then resume it. | The gate still blocks, because stock is loaded on resume. |
| 7 | US4 | Tap a line's warehouse. | A dialog shows full names, stock and the current warehouse checked. Picking one updates the line. At 390 px wide there is no horizontal scroll. |
| 8 | US5 | On Cobro (balance 100), the amount is pre-filled with 100. Change it to 60 and tap *Efectivo*. | 60 is applied at once, and the amount becomes 40. Tapping *Tarjeta* asks for the reference, then applies 40. |
| 9 | US6 | Balance 87.50: enter 100 and tap *Efectivo*. | Paid in full, and the change card shows 12.50 until dismissed. |
| 10 | US6 | Enter more than the balance and tap a non-cash method. | Refused with "Solo el efectivo puede exceder el saldo". |

After scenario 9, check that the session's cash cut shows the cash kept net of change, which is existing backend behavior.
