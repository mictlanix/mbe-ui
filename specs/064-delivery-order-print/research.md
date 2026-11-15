# Research: Delivery Order Print

Phase 0 for [plan.md](plan.md). Each entry gives the decision, why, and what else was weighed.

## R1. Plug the two documents into the spec 044 module

**Decision.** Add two kinds to `DocumentKind` (`lib/core/documents/domain/document_kind.dart`):

- `deliveryTicket`
- `deliveryOrderDocument`

Both gate on `SystemObject.deliveryOrders` read. Their fallback filenames are `entrega-%08d.pdf` and `orden-entrega-%08d.pdf`, as mbe-api spec 026 FR-011 names them.

`DocumentSourceImpl` builds a `DeliveryOrdersApi` and adds two switch arms:

- `printDeliveryOrderTicketApiV1DeliveryOrdersDeliveryOrderIdTicketGet(deliveryOrderId:, warehouse:)`
- `printDeliveryOrderDocumentApiV1DeliveryOrdersDeliveryOrderIdDocumentGet(deliveryOrderId:)`

The preview, the `%PDF-` check, the Content-Disposition filename, the repeated-press guard and the error banner all come unchanged.

**Why.** Every document in the app goes through this one path (spec 044 FR-010, FR-015, FR-020). A fetch in the delivery-order repository would duplicate the PDF check and the filename parsing.

**Alternatives.**
- A fetch callback on the preview: it would change every existing caller.
- A delivery-order repository method: rejected for the duplication above.

## R2. Carry the warehouse in `DocumentRef`

**Decision.** Add an optional `int? warehouseId` to `DocumentRef` and include it in equality and `hashCode`. Only the `deliveryTicket` arm reads it. An assert keeps it null for every other kind.

**Why.** The preview controller and the repeated-press guard are keyed by `DocumentRef`. Two tickets of one order for two warehouses are different documents, so they must be different keys. The title already differs, but relying on that would be accidental.

**Alternatives.**
- A generic `Map<String, Object> params`: more than one optional int needs.
- A separate kind per warehouse: impossible, since warehouses are data.

## R3. Which orders can print

**Decision.** A shared helper next to the delivery-order widgets:

```text
canPrintDeliveryOrder(access, status) =
    canOpenDocument(access, DocumentKind.deliveryTicket)
    && status not in {draft, pendingApproval}
```

The detail screen, the list row and the letter-format button all call it. It mirrors `canShowPaymentTicket` (`payments/payment_widgets.dart`).

**Why.** mbe-api refuses those two statuses with 409 `delivery_order.not_approved`. Every later status renders, cancelled included (spec FR-003). One helper keeps the row and the detail screen from drifting apart.

**Alternatives.**
- Check only the right and let the server refuse: this would show actions that can't work (spec 061 SC-003 style).

## R4. Find an order's warehouses

**Decision.**
- **Detail screen.** The distinct `warehouseId`s of `order.lines`, in first-appearance order.
- **List row.** The summary has no lines; neither the domain `DeliveryOrderSummary` nor the generated DTO has them. On tap, the flow calls `deliveryOrderAdminRepository.getById(id)` and takes the distinct warehouses from its lines. The lookup is skipped when the detail is already at hand.

**Why.** It's one extra request per list print, only when the user prints. Server ids are compared, never names.

**Alternatives.**
- **Ask mbe-api to add warehouses to the summary.** It would mean an mbe-api issue and waiting for it, for 5% of orders. It can come later without changing the UI.
- **Always ask on the list.** The user would get a pointless dialog for 95% of orders, against spec FR-011.

## R5. Busy state for the list lookup (spec amendment)

**Decision.**
- **Repeated taps.** The flow keeps an in-flight set of order ids, and a tap on an order already in it does nothing.
- **Busy feedback.** There is no visible busy state on the row icon: the shared `CatalogRowAction` has none, and the lookup is a single read of one order. A preview has its own loading state, and it opens as soon as the lookup returns.
- **Lookup failure.** It shows the error's localized message in a SnackBar, and no preview opens.

The spec's edge case "Warehouses can't be determined from the list" is amended to match.

**Why.** Adding a busy variant to the shared row-action component for one sub-second read would touch every list.

**Alternatives.**
- A progress dialog during the lookup: it would flash for almost every print.
- Opening the preview first and asking for the warehouse inside it: that changes the shared preview.

## R6. The warehouse chooser

**Decision.** A new `showDeliveryTicketScopeDialog` in `lib/features/sales/presentation/delivery_orders/`. It is built on `ResponsiveDialog`, so it goes fullscreen on compact screens, like every other delivery-order dialog. Its parts:

- **Options.** A `RadioGroup` with "Todos los almacenes" first and preselected, then one `RadioListTile` per warehouse.
- **Labels.** Each option shows `DeliveryOrderWarehouseName(facilityId:, warehouseId:)`, which falls back to `#id`.
- **Buttons.** Primary "Ver ticket" and secondary "Cancelar".
- **Result.** A `DeliveryTicketScope?`: `null` when dismissed, otherwise either all or one warehouse.

**Why.**
- **Not the capture picker.** `showWarehousePicker` is tied to sale capture (stock flags, quantity, other facilities) and has no "all" option.
- **Precedent.** The radio pattern matches `refund_confirm_dialog.dart`.

**Alternatives.**
- A popup menu on the button: it doesn't work for the list row's icon on touch, and differs between the two entry points.

## R7. Preview titles

**Decision.** Use new ARB keys in the style of the existing `documentSalesOrderTitle` ("Pedido · {reference}"):

| Key | es | en |
|---|---|---|
| `documentDeliveryTicketTitle` | Ticket de entrega · {folio} | Delivery ticket · {folio} |
| `documentDeliveryTicketWarehouseTitle` | Ticket de entrega · {folio} · {warehouse} | Delivery ticket · {folio} · {warehouse} |
| `documentDeliveryOrderLetterTitle` | Orden de entrega · {folio} (carta) | Delivery order · {folio} (letter) |

The folio is the unpadded serial, which the detail screen's `_serialOf` already produces. Printable orders always have one. The warehouse name is read from `facilityWarehousesControllerProvider(facilityId)` when the choice is made, falling back to `#id`.

**Why.** It matches the existing preview titles. Spec FR-021 gives its titles as examples, so this format satisfies it.

## R8. Where the actions sit

**Decision.**
- **Detail screen.** Two buttons lead the existing action `Wrap` in `_actionButtons`:
  - "Ver ticket": `OutlinedButton.icon`, `Icons.receipt_long_outlined`, key `delivery_order_view_ticket`.
  - "Ver formato carta": `TextButton.icon`, `Icons.description_outlined`, key `delivery_order_view_letter`.

  The status actions follow as today, so print sits left and the filled action stays rightmost.
- **List row.** A `rowActionsBuilder` with `buildCatalogRowActions(extraActions: [ticket])` for printable rows. This follows the payments-list precedent of no Edit and one extra icon. The icon is `Icons.receipt_long_outlined`, the key is `delivery_order_view_ticket_<id>`, and the tooltip is "Ver ticket".
- **Doc comments.** The list's class comment and the line-216 comment ("no row icons") are updated.

**Why.**
- **Body actions.** Constitution §VI requires body actions, never app-bar icons, and caps a row at Edit plus one extra.
- **Button weights.** Outlined beside text keeps the letter format secondary (spec FR-001). The same receipt icon is used as for the POS ticket.

**Test impact.** `delivery_order_detail_screen_test.dart` l.1114 expects no action area on a cancelled order. That test changes: a cancelled order now shows only the two print buttons and no status action.

## R9. Error codes (constitution §III, API error text)

**Decision.** The two endpoints can return these codes, from mbe-api's catalog and the spec 026 contract:

| Code | HTTP | Params | Today in the app | Message |
|---|---|---|---|---|
| `delivery_order.not_approved` | 409 | `status` | not localized | es "La orden de entrega aún no está aprobada; no se puede imprimir." / en "The delivery order isn't approved yet, so it can't be printed." |
| `delivery_order.unknown_warehouse` | 422 | `warehouse_id` | not localized | es "El almacén elegido no existe." / en "The chosen warehouse doesn't exist." |
| `delivery_order.no_lines_from_warehouse` | 422 | `warehouse_id` | not localized | es "Ninguna línea de esta orden sale del almacén elegido." / en "No line of this order leaves from the chosen warehouse." |
| `resource.not_found` | 404 | resource | localized (`delivery_order` noun mapped) | as is |
| `auth.forbidden` | 403 | | localized | as is |

All three new messages are fixed text that ignores params. A missing or mistyped param can't hide them, and the "needs params" test doesn't list them.

These codes are added in the places spec 058 requires:
- `localizedErrorCodes`;
- the `localizeProblem` switch;
- both ARB files;
- `problem_fixtures.dart`.

In `specs/058-localized-api-errors/contracts/code-scope.tsv`, rows 50, 51 and 63 flip from `OUT` to `IN`, and `catalog_coverage_test`'s pinned count goes from 110 to 113.

**Why.** The constitution requires these messages for every code an endpoint the app starts calling can return.

## R10. Bytes guard on the generated client

**Decision.** Add both generated method names to `test/unit/core/documents/generated_client_bytes_test.dart`. The generated code already uses `ResponseType.bytes` (l.1585 and the ticket method), so codegen is not re-run.

**Why.** Spec 044's guard catches a future regeneration that loses the bytes response type.

## R11. Tests

**Decision.**

- **Unit tests**
  - `DocumentSourceImpl`: both kinds, with and without a warehouse, plus the filename fallback.
  - `DocumentRef` equality with `warehouseId`.
  - `canPrintDeliveryOrder` across all 11 statuses × right.
  - Distinct warehouses in first-appearance order.
  - The three error codes.
- **Widget tests**
  - Detail screen: the print buttons by status and right; one warehouse opens the preview directly; two warehouses open the chooser; dismissing fetches nothing; the cancelled-order test is updated.
  - List: the row icon only on printable rows; a tap looks the order up and then previews; the lookup failure SnackBar; repeated taps.
  - Chooser dialog: options, default, result.
  - All of these use the spec 044 fakes (`FakeDocumentSource`, `documentContainer`).
- **Live test.** A new read-only `integration_test/delivery_order_print_quickstart_test.dart`. It opens the ticket of an approved-or-later order from the list and from the detail screen, and the letter format. It checks that a draft has no print action, and runs the multi-warehouse path when the tenant has such an order (SKIP otherwise). The pattern is that of `document_printing_quickstart_test.dart`.

## R12. Nothing needed from mbe-api

**Decision.** No mbe-api issue is filed. Both endpoints exist (mbe-api spec 026, roadmap#42 closed) and are in the generated client. Warehouses in the list summary (R4) would be a nice-to-have, not a dependency.
