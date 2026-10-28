# Research: Customer Refunds

Phase 0 decisions for [spec.md](./spec.md). Server facts come from mbe-api `app/services/customer_refund_service.py` and `app/api/v1/endpoints/customer_refunds.py`, read 2026-10-28.

## R1. Record surface and routes

**Decision**:
- **List:** a new shell branch `/sales/refunds` at index 24, with its nav entry after Notas de crédito.
- **Detail:** a top-level full-screen route `/sales/refunds/:refundId`, like `/sales/payments/:paymentId`.

**Rationale**: a refund has its own child section (lines) and needs a per-record URL, since the credit-notes origin and the order actions link to it. That is constitution §VI's test for a full record surface. Shell branches are positional, so the new one is appended rather than inserted.

**Alternatives considered**: a side sheet over the list was rejected because it has no per-record URL. Embedding the refund in the order workspace was rejected because a refund is its own document with its own folio and lifecycle.

## R2. Open or resume

**Decision**: "Devolver", and "Nueva devolución" with an order number, both run `openOrResume(salesOrderId)`:
1. `GET /customer-refunds?sales_order=<id>&status=draft&limit=1`. If it returns a refund, navigate to it.
2. Otherwise, check the order (R3). If it is refundable, `POST /customer-refunds {sales_order}` and navigate to the new refund.

**Rationale**: `open_refund` on the server does not look for an existing open refund. Without step 1, every tap would leave another draft behind (FR-003, SC-004).

**Known limit**: two clerks tapping at the same moment can still create two drafts. The server would have to enforce this to close the gap. It is rare, and a stray draft can be cancelled. Not filed.

## R3. Distinguishable refusals

**Server refusals**: all of them are 409, except the over-quantity one, which is 422.

| Situation | Server detail |
|---|---|
| Order not completed | "Order is not completed; …" |
| Order not paid | "Order is not paid; … cancelling …" |
| Nothing left to return | "No refundable items remain on this order" |
| Units on a live invoice | "Units of line {code} are on invoice {invoice}; cancel the invoice to refund them" |
| No open cash session | "An open cash session is required to confirm a refund" |
| Confirm with every line at zero | "Refund has no lines with a returnable quantity" |
| Above the refundable quantity | "Return quantity … exceeds the refundable quantity …" |

**Decision**: classify from data the client already holds wherever it can, and match server prose nowhere:
- **Not completed, not paid, not found:** before POSTing, `openOrResume` reads the order through the existing `SalesOrderRepository.getById`. Draft or cancelled gives `RefundRefusal.notCompleted`, completed gives `notPaid`, and a 404 gives `orderNotFound`.
- **A 409 from the POST** after that check means nothing can be returned. It becomes `RefundRefusal.nothingToReturn`, and the screen shows the server's own detail under it. That detail is how the invoice case names its invoice (FR-004, Edge Cases).
- **No session:** pre-checked before confirm (R5).
- **All lines at zero:** prevented by disabling confirm.
- **Above the refundable quantity:** prevented by the stepper's max.

Any 409/422 that still reaches the screen is shown through the shared `ErrorBanner` with its server detail.

**Rationale**: this follows the `CreditNoteRefusal` precedent (spec 056), which is derived on the client and not parsed from prose. It needs no new `AppError` variant.

**Alternatives considered**: matching on the detail strings was rejected as brittle, since the server prose is free to change. Asking mbe-api for error codes is a broader change than this feature needs.

## R4. Editing a line

**Decision**: each line has a `QuantityStepper` with `min: 0` and `max: refundableQuantity`. It uses the shared 400 ms commit debounce. Each commit is `PUT /customer-refunds/{id}/lines/{lineId} {quantity}`.

**Writes:**
- Writes are serialized per refund in a small `RefundEditor` controller, using the `tracked()` / `publish()` pattern of `tracked_editing.dart` with write scope `customer-refund`.
- Every response replaces the whole refund, so totals always come from the server (FR-006).
- A refused write restores the last accepted value and shows the server detail on that line, as `destination_card.dart` does.

**Wire format:** quantities go on the wire through a new `Quantity3` setter in `wire_value_setters.dart`, matching the existing ones.

**Warehouse:** the line's warehouse is a tap-field that opens `showWarehousePicker` with `facilityWarehousesControllerProvider(refund.facility)`. The client has no notion of a sellable warehouse. The server refuses an unsellable choice, and that refusal is shown on the line with the picker re-keyed (the `_rejections` pattern in `sale_line_editing.dart`).

## R5. Confirming

**Decision**: confirm is shown when all of these hold: the user has `can(customerRefundConfirm, update)`, the refund is a draft, and at least one line is above zero (FR-008).

**Before the dialog:**
- Read `ref.refresh(currentSessionControllerProvider.future)`, as `PaymentController._sessionIsValid` does.
- `none`: show "Abre una sesión de caja para confirmar" with a button to `/sales/cash-sessions`.
- `stale`: show the same message with a button to `/sales/cash-sessions/{id}`, matching `PosSessionBlockedBanner` (FR-009).

**The dialog** (`ResponsiveDialog`):
- It shows the total, and two choices with nothing pre-selected (FR-008): "Efectivo de la caja" and "Nota de crédito".
- Its confirm button stays disabled until a choice is made.
- On submit it sends `POST /confirm {payout}`.

**Adjustment notice (FR-011):** after a successful confirm, compare the quantities the clerk entered, captured just before the call, with the response. If any line was lowered or dropped, show an info banner on the confirmed refund.

**Network failure:** after a network error the controller re-reads the refund before re-enabling confirm. If the re-read says completed, it shows the completed refund instead of letting the clerk confirm again (Edge Cases).

## R6. Payout and credit note on a confirmed refund (interim until mbe-api#286)

**Decision**: add `CreditNoteRepository.findByRefund({customerId, refundId, refundDate})`. It pages `GET /credit-notes?customer=<id>` newest first and stops at the first of:
- a note whose `customerRefundId == refundId`, which is a credit-note payout;
- a page whose oldest note is dated before the refund, which is treated as a cash payout;
- the end of the list, which is also treated as cash.

The confirmed refund then shows either "Pagada en efectivo" or "Nota de crédito Nº {customerPaymentId}" with a link to the credit note (FR-015, FR-017).

**Interim marker**: `// simplified: scans the customer's notes; replace with the refund's own payout fields when mbe-api#286 ships`.

**Shortcut:** right after a confirm, the controller already knows the payout it sent. It shows that directly and runs the lookup only to get the note number.

**Cost:** one request in practice for a named customer, since they hold few notes. For the walk-in customer the scan stops at the refund's date, so a recent refund takes one or two pages.

**Walk-in customer:** `CustomerRefundResponse.customer` is nullable. With no customer the lookup can't run, so the detail shows "Forma de pago no disponible" instead of guessing.

## R7. Customer names in the list (interim until mbe-api#284)

**Decision**: reuse `PaymentCustomerName(customerId:, name: null)`, which resolves each customer through `customerDisplayNameProvider`. A null customer shows "—". When #284 ships, map `customerDisplayName` and pass it as `name`, as spec 056 plans to do for #283.

## R8. The list

**Decision**: follow the Notas de crédito list (`credit_notes_*`): a freezed `RefundsFilter{status, customerId, salesOrderId, pageIndex}` read from `ListQuery` facets, a family controller using `fetchClampedPage`, `CatalogFilterBar`, a filter sheet, `CatalogListStateView` and `DataTableView`.

**Facets:**
- Status, as a segmented control: Todas / Abiertas / Confirmadas / Canceladas, mapped to `draft`, `completed`, `cancelled`.
- Customer, through `CatalogEntityPicker<CustomerListItem>`.
- Order number, as a numeric field.

**Header and rows:**
- "Nueva devolución" sits in the header, gated by `can(customerRefunds, create)`. It opens a dialog that asks for the order number and runs `openOrResume`.
- Tapping a row pushes `/sales/refunds/{id}`.
- There is no row Edit icon. A refund opens in its record surface, following the Pagos precedent.

**Order and scope:**
- Rows come in server order, newest id first, until mbe-api#285 (FR-013).
- The server scopes the list to the caller's facility.

## R9. Where "Devolver" goes

**Decision**:
- **Pedidos:** in `OrderHeaderPanel`'s trailing `Wrap`, next to "Ver pedido". It is visible on both workspace steps.
- **POS:** in `PosSaleDetailView._Facts`, next to the ticket button.

Both are shown only when `sale.isPaid && can(customerRefunds, create) && can(customerRefunds, read)`, and hidden otherwise (§IV). Read is needed because `openOrResume` lists first.

## R10. Printing (blocked on mbe-api#287)

**Decision**: nothing is built until the regenerated client has the refund ticket method. After that ships:
- add `DocumentKind.customerRefundReceipt(SystemObject.customerRefunds)` with its `DocumentSourceImpl` switch arm and fallback filename `devolucion-{serial}.pdf`;
- add a print button on a confirmed refund, through `documentActionsProvider`.

"Built but hidden" (Clarifications) is honoured by keeping these as tasks gated on #287. No code is written against an endpoint that doesn't exist yet.

**Alternatives considered**:
- A compile-time flag over a hand-written call was rejected. It would bypass the generated client (§III).
- Printing the credit note's backing-payment ticket was also rejected. `PaymentType.creditNote` has `hasTicket == false`, and the server answers 409.

## R11. Linking the credit-notes origin to its refund

**Decision**: in `_OriginCell` (`credit_notes_list_screen.dart`), split the localized string at both `#{refund}` and `#{order}` and render two `WidgetSpan` links. The refund link uses key `credit_note_refund_link_<id>`, is gated by `can(customerRefunds, read)`, and pushes `/sales/refunds/{id}`. Update the doc comment that says refunds have no screen (FR-016).

## R12. Tests

- **Unit tests:**
  - `RefundRepositoryImpl`: mapping, the list's query parameters, and error mapping.
  - `CustomerRefund` entity.
  - `RefundsFilter` and its round trip through `ListQuery`.
  - The list controller.
  - The `RefundEditor` controller: serialized writes, refusal rollback, the confirm session pre-check, the adjustment notice, and the re-read after a network error.
  - `openOrResume`: resume, each refusal, and open.
  - `findByRefund`: its three stop conditions.
- **Widget tests:**
  - List screen: facets, empty and forbidden states, the new-refund dialog.
  - Detail screen: draft, completed and cancelled, plus a user who can edit but not confirm.
  - Confirm dialog: no default choice.
  - "Devolver" on the order header and the POS detail: shown and hidden.
  - The credit-notes origin's refund link.
- **Router:** an `app_router_test` case for the gate and branch index, and `nav_destinations_test`.
- **Live:** `integration_test/customer_refunds_quickstart_test.dart` discovers a paid order with returnable lines at runtime, opens or resumes a refund for it, edits a line, then **cancels** the refund so the tenant is left as it was. Confirming writes stock and cash, so it is covered by an opt-in step behind `--dart-define=MBE_REFUND_CONFIRM=1`.
