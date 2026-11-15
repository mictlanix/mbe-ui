# Quickstart: Delivery Order Approval

**Feature**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md)

This guide proves the feature end to end against the dev tenant.

## Prerequisites

- **Backend.** mbe-api is running with spec 012 US2.
  - The server needs `DELIVERY_ORDER_APPROVAL_REQUIRED=true`. This is the `delivery_order_approval_required` setting in `app/core/config.py`. It is a deployment-wide env var, defaults to `false`, and isn't per tenant.
  - Without it, confirm skips the queue, so steps 3–8 can't be shown and the live write part skips.
  - Check by confirming a draft in Órdenes de entrega: it must land in Pendiente de aprobación.
  - A local mbe-api with the variable set is the simplest route if the shared dev server keeps the default.
- **Accounts.** The admin account from `.env` (`MBE_POS_*`) has every right, including 94 and 71. Rights-matrix checks (step 9) use a role edited in Seguridad, or the widget tests.
- **Data.**
  - The user has a facility assigned.
  - At least two POS-created drafts with lines exist at that facility: one Entrega and one Recoge en tienda. Create them through POS → Entrega if needed.
- **DB tunnel.** The live test needs a stable DB tunnel (spec 061 note).

## Automated

```sh
flutter analyze
flutter test test/unit/features/sales test/widget/features/sales
flutter test test/unit/core   # catalog_coverage_test, problem fixtures

# Live, read-only part (queue loads at the user's facility)
flutter test integration_test/delivery_order_approval_quickstart_test.dart -d macos
# Live, with writes (confirm → approve / reject); skips the write part with a
# message if confirm doesn't land in Pendiente de aprobación
MBE_WRITE=1 flutter test integration_test/delivery_order_approval_quickstart_test.dart -d macos
```

Expected: everything passes. The write run leaves one order in En preparación (or Aprobada, for the pickup) and one draft carrying a rejection reason.

## Manual walkthrough

1. **Nav.** Logística shows "Aprobación de entregas" after "Órdenes de entrega" (C1).
2. **Empty.** With nothing pending, the queue shows the empty text and no button.
3. **Fill.** Confirm the two drafts in Órdenes de entrega. Both land in Pendiente de aprobación. Open the queue, which now lists both with folio, customer, type, date, ship-to, sales orders and priority. The footer reads "1–2 de 2" (FR-002, FR-003).
4. **Review.** Tap the delivery row. The spec 061 detail screen opens, with Cancelar orden, Rechazar and Aprobar bottom-right. Back returns to the queue (C2, C7).
5. **Approve a delivery.** From the queue, tap ✓ on the delivery. The dialog names folio, customer, type and date, and says it will go to En preparación. Confirm. The SnackBar names En preparación, the row is gone, and the footer reads 1 (US1).
6. **Approve a pickup from detail.** Open the pickup and tap Aprobar. The dialog says Aprobada. After confirming, the screen shows (Aprobada) and a new history line. Back in the queue, the pickup is gone.
7. **Reject.** Confirm another draft and open the queue. Tap ✕. With a blank reason the button stays disabled; type 501 characters and the counter stops at 500. Enter a reason and confirm. The row leaves the queue. In Órdenes de entrega the order is Borrador, its detail shows the rejection banner with the reason, and the history reads Pend. aprob. → Borrador with the reason and your name (US2).
8. **Stale action.** Open the queue in two windows. Approve an order in one, then approve the same order in the other. The dialog stays open with "Esta orden ya no está pendiente de aprobación." "Cerrar" closes it, and the row is gone (FR-015).
9. **Rights.** The matrix is covered by widget tests. Spot-check one role:
   - with 94 read only: no ✓/✕ column;
   - with 94 read + update and no 71 read: rows don't open, and ✓/✕ still work.
10. **No facility.** A user without a facility sees the no-facility notice.
11. **Compact and text size.** Narrow the window to phone width. Rows stack with ✓ ✕ on the first line. At the largest text size, nothing is clipped.
