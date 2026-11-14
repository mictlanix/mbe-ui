# Back-office delivery orders ("Órdenes de entrega")

## Summary

The POS "Entrega" step creates delivery orders but never confirms them. Until now, every order made in the new app stayed a draft with no folio and never reached the warehouse. This PR adds the back-office screen where those drafts are confirmed, plus the rest of the delivery-order lifecycle the server already supports.

- **List** under Ventas, right after Pedidos. It shows the facility's delivery orders newest first, with folio search and filters for status, type, scheduled date, customer, sales order and facility.
- **Detail screen** with header facts, links to the sales orders and to the parent and child orders, all five line quantities (ordered, committed, delivered, returned, open), status history and proof of delivery.
- **Draft editing:** header (date, priority, ship-to, contact, comment), line quantity, line removal, and "Agregar línea" from another completed sale of the same customer.
- **Status actions:** confirm, cancel (with a reason), requeue a failed delivery, mark a pickup order ready, and hand it over with the receiver's name, the identification they showed and a photo.

Spec: `specs/061-delivery-orders/` (spec, plan, research R1–R12, contracts C1–C12, tasks).

## Roadmap

Closes mictlanix/mbe-roadmap#38

## Upstream dependencies

None of these blocks the feature. Each one leaves something temporarily different here:

| Issue | Until it ships |
|---|---|
| mictlanix/mbe-api#311 | Cancel is offered in En preparación even when the order is already on an open itinerary. Today that blocks the trip's departure. The risk was accepted at specify time. |
| mictlanix/mbe-api#312 | The list opens on every status, not on "Activas". The server takes only one status per request. |
| mictlanix/mbe-api#313 | "Agregar línea" computes what's left on each sale line on the client, one sale at a time. This mirrors `_covered_quantities`, and the server still refuses any over-claim. |
| mictlanix/mbe-api#314 | Delivery-order reads aren't facility-checked. The list therefore decodes the facility filter only for administrators, in both the URL filter and the fetch, as Pedidos does (spec 029), with a scoping test. A hand-typed detail URL for another facility's order can't be blocked client-side. |

## Also in this PR

- **POS fix (research R9).** `listForSale` no longer counts cancelled destinations as claiming a sale's lines. Without it, a cancel from the new screen would leave the sale looking already distributed when the POS resumed it.
- **`SalesOrderRepository.listOrders`** gains an optional `customer` parameter, used by "Agregar línea". Existing callers are unchanged.
- **Four error codes localized**, with a `_dateTime` placeholder helper: `delivery_order.insufficient_notice`, `.no_lines`, `.not_failed` and `.proof_incomplete`. `code-scope.tsv` is updated.

## Constitution notes

- **§VI:** delivery orders are documents with a status lifecycle, editable only in draft. Like Reembolsos, rows have no Edit icon and there is no View toggle; a draft is edited in place. The plan records a follow-up: amend §VI to state that criterion instead of repeating the reading spec by spec.
- **§III:** research R10 lists every error code each new endpoint can return.

## Tests

- `flutter analyze`: no issues.
- `flutter test test/unit test/widget`: 4,497 passed, 0 failed.
- The new unit and widget tests include:
  - a facility-scoping test;
  - a table-driven action matrix over all 11 statuses × both types × with and without edit rights (SC-003).
- Live (`integration_test/delivery_orders_quickstart_test.dart`, macOS, against a local mbe-api):
  - read-only: 3 of 3 passed;
  - with `MBE_WRITE=true`: 9 of 9 passed, covering create a draft, edit the header, confirm, cancel, then a pickup taken through ready and handover with proof.

  The write run left cancelled order 30238, picked-up order 30239 and two 1-unit sales on the dev tenant.

## Manual checks (quickstart.md)

**Not run yet.** These still need someone at the app:

- Step 1: `qanoaccess` sees no entry and the URL is refused. The router tests cover the gate.
- Step 6: too little notice. The local tenant has no minimum set.
- Step 9: requeue. It needs a FAILED order, which only an itinerary produces.
- Step 10: a user with read but not update rights on Delivery Orders. No seeded account has that combination.
- Step 11: the compact tier.
- Step 12: the largest text size.

## Known gaps

- **Search box filtering:** the box accepts letters while typing; non-digits are stripped when the search is submitted. Rejecting them as they're typed needs an optional `inputFormatters` parameter on the shared `CatalogSearchBar`, which was left out of this PR pending approval.
- **Live test file picker:** the live test replaces the native file picker with a fake, because the macOS open panel can't be driven. The dialog, the upload and the proof display are all exercised.
- **Fixed sizes:** the proof thumbnail (120) and the enlarged-photo dialog width (960) are fixed sizes, not spacing tokens.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
