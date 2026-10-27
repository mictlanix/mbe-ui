# Research: Credit Notes

Each decision below states what was chosen, why, and what was rejected. Line references were checked on 2026-10-27.

## R1. A redemption reuses `applyPayment`; it never creates a payment

**Decision:** Add `PaymentController.tenderCreditNotes(...)` beside `tender`. It calls the existing `CustomerPaymentRepository.applyPayment(customerPaymentId: <backing payment>, salesOrder, amount)` once per note and skips `createPayment`. It reuses the three side effects `tender` already performs:
- the `submitting` double-tap guard
- the `_tracked` pending-writes lock that gates Continuar
- the refresh of `posSaleControllerProvider` and the invalidation of `orderPaymentsControllerProvider(sale.id)`

It also keeps the cash-session check. The server doesn't need a session to apply a payment, but the payment step already refuses to work without one, and a second rule for one tender would be surprising.

**Why:** FR-070a makes redemption an ordinary application, so the endpoint and repository method already exist (`customer_payment_repository.dart:29-34`).

**Rejected:**
- Routing through `tender`. It always creates a payment first.
- A separate controller. It would have to duplicate the lock and refresh wiring that keeps Continuar correct.

Update the repository doc comment that says create and apply are "always called as a pair".

## R2. A named customer's credit comes from `GET /credit-notes?customer=`, with every page read and filtered locally

**Decision:** A new `CreditNoteRepository.listForCustomer(customerId)`:
- pages `GET /credit-notes?customer=<id>&limit=100` until it has `total` rows
- never sends `open_only`
- keeps rows whose server `remaining` is greater than zero, oldest first (`date` ascending, then `credit_note_id`)

The payment step then drops notes whose `customerPayment` already appears among the sale's non-cancelled applications (`SalePayment.customerPayment`), and sums the rest.

**Why:**
- Named customers hold few notes: at most 13 per customer on the dev tenant, so one request in practice.
- Reading every page sidesteps mbe-api#278. With `open_only`, page 1 can come back empty while open notes exist further down.
- The figures stay the server's (FR-015). Only the filtering and sorting are local.

**Rejected:**
- `open_only=true` (#278).
- Using the backing payments' `unapplied` instead of `remaining`. That disagrees with the credit note for cashed-out notes (mbe-api#277 addendum), and FR-015 says to show the server's credit-note figure.

## R3. Spending is sequential, oldest first, and stops at the first failure

**Decision:** First work out the total to spend:
- `target` = the entered amount if there is one, else the sale's balance
- `total` = the smaller of `target`, the sale's balance, and the spendable credit

Then walk the notes oldest first and apply `min(note.remaining, left to spend)` to each. On the first `AppError`:
1. stop and refresh (R1)
2. report the amount already applied, using a new `PaymentIssue`/`TenderResult` pairing (C2)

There is no `amountChange` (FR-003). All arithmetic goes through `money.dart`.

**Why:** Applications are independent server writes with no batch endpoint. Legacy `ApplyCreditNotes` looped the same way. Stopping on the first error keeps the report truthful: "applied X of Y", then a re-read (FR-008).

**Rejected:** Parallel applies. They race on the sale's balance and make a partial failure hard to report.

## R4. Redeeming a walk-in ticket

**Decision:** The ticket number is the backing payment's id (legacy `TicketCreditNote.cshtml`). Lookup has two steps:

1. **`CustomerPaymentRepository.get(customerPaymentId)`** for identity. The outcome decides what comes next:

   | Server answer | What the app does |
   |---|---|
   | 404 (also returned for another facility's payment, mbe-api#273) | "No credit note has that number" |
   | A payment whose type isn't `creditNote` | Same message |
   | A credit note issued to another customer | "This credit note belongs to {name}" (FR-006a), using `customerDisplayName` |
   | Already among the sale's applications | "Already applied to this sale" |

2. **`CreditNoteRepository.findByPayment(customerPaymentId, customerId)`** for the server's `remaining`. It scans `GET /credit-notes?customer=<walk-in>&limit=100`, newest first, and stops at the first match. A match with `remaining` 0 gets "Fully used".

Applying goes through R1 with a single note.

**Why:** No endpoint reaches a credit note from its payment. The walk-in customer holds 512 notes on the dev tenant, about 6 pages at roughly 0.85 s each. A ticket brought back is almost always recent, so the newest-first scan usually stops on page 1. The scan is marked `// simplified: worst case reads every walk-in page; switch to the customer_payment filter when mbe-api ships it`.

**Upstream request: filed as mbe-api#280 (2026-10-27).** The text as filed:

> **GET /credit-notes: filter by backing customer_payment (redeem a ticket by its number)**
>
> Add a `customer_payment` query parameter to `GET /credit-notes`: an equality filter on `credit_note.customer_payment`, shaped like the existing `customer` filter. A credit-note ticket prints the backing payment id under its barcode (legacy `TicketCreditNote.cshtml`). Legacy redeems by that number (`PaymentsController.ApplyCreditNote`). mbe-ui is adding the same flow for walk-in sales (mictlanix/mbe-roadmap#28).
>
> Today there's no way to reach a note from its payment. `GET /credit-notes/{id}` takes the credit-note id, which the ticket doesn't print. `GET /customer-payments/{id}` returns `unapplied`, not the note's `remaining` (they differ per #277). Scanning the walk-in customer's notes means about 6 pages on the dev tenant (512 notes).
>
> Expected: `GET /credit-notes?customer_payment=300743` returns the matching note with `remaining` (`total: 1`), or `total: 0`. Same privilege as the list (`CreditPayments` READ).

**Rejected:**
- Showing `unapplied` as the remaining figure (R2).
- Scanning every customer's notes. The walk-in customer alone is the only one a ticket is redeemed for (FR-005).

**Known limit:** a ticket issued at another facility returns 404 from `GET /customer-payments/{id}` for anyone who isn't a payments editor (mbe-api#273). Legacy had no such limit. This is recorded, not worked around.

## R5. Where the controls go in the payment step

**Decision:**
- **Customer credit (FR-001):** one extra tile in `PaymentMethodGrid`, appended after the method tiles. It is titled "Nota de crédito", with the spendable amount as its second line. `_TileData` gains an optional subtitle override, because the second line is hard-wired to the reference text today (`payment_method_grid.dart:233-237`). It's present only when the customer isn't the walk-in one, the credit is above zero, and the gates in R7 pass.
- **Walk-in ticket (FR-005):** on a walk-in sale, the same tile reads "Canjear nota de crédito". It opens a dialog modelled on `payment_reference_dialog.dart`: an autofocused field that submits on Enter, so a keyboard-wedge scanner works. The dialog shows the note's remaining amount and a confirm button.

**Why:** The grid is where cashiers already choose how a sale is paid. Legacy put both buttons in the same row as the payment methods. Reusing the tile keeps the extra-large-text layout tests meaningful.

**Rejected:**
- A chip among the quick amounts. Those set an amount; they don't pay.
- The summary panel. It only holds figures and the Continuar gate.

## R6. Applied rows say "Nota de crédito"

**Decision:** Add `PaymentType type` to `SalePayment`, mapped with `PaymentType.fromApi(r.paymentType)`. `OrderApplicationResponse.paymentType` already exists (`order_application_response.dart:76`). `AppliedPaymentsPanel` shows `paymentTypeLabel` in place of the method label when the type is `creditNote`, because a note's method is "N/A".

**Why:** FR-009. No codegen is needed. It's a freezed rebuild only.

## R7. Gates

| Control | Shown when |
|---|---|
| Credit tile, ticket redemption | `can(creditPayments, read)` **and** `can(customerPayments, create)` (FR-014), the sale isn't cancelled, and its balance is above zero (FR-007). Ticket redemption also needs `can(customerPayments, read)`, because R4 reads the payment. |
| "Notas de crédito" route and nav | `can(creditPayments, read)` (FR-013) |
| A list row opens the payment | `can(customerPayments, read)`. Without it the row isn't tappable. |

Anything a user can't use is hidden, not disabled (§IV).

## R8. List screen: data and paging

**Decision:**
- **Route:** `/sales/credit-notes`, a new shell branch (`NavBranch.creditNotes = 23`). The nav entry sits after Pagos.
- **Filter row:** no search box, because the endpoint has no free-text search (§VI says omit it). The drawer holds two facets: a customer picker (`CatalogEntityPicker`, as on Pagos) and an "Solo con saldo" switch. It's a plain on/off, because the filter is never "only without balance".
- **Toggle off:** server paging, 20 per page (`fetchClampedPage`), newest first as the server orders them.
- **Toggle on with a customer chosen:** R2's read-everything-then-filter, paged locally.
- **Toggle on without a customer:** every page is read once (984 notes, about 10 requests on the dev tenant) and filtered locally. Marked `// simplified: reads every page while mbe-api#278 is open; pass open_only and page on the server once it ships`.

**Why:** It's the only correct answer while #278 is open (spec edge case). The full read happens only when someone turns the toggle on, and the data set grows slowly.

**Rejected:**
- Sending `open_only`. It gives short or empty pages and a wrong count.
- Hiding the toggle until #278 ships. FR-011 asks for it.

## R9. List rows: names, origin and currency

**Decision:**
- **Customer:** `customerDisplayNameProvider(id)` per row. At most 20 distinct ids per page, deduped by the provider family. The response carries no name.
- **Origin:** shown as "Devolución #{refund} · Pedido #{order}". The order number links through `orderLinkTargetProvider` when the user can read orders. The refund is plain text, because no refund screen exists yet (roadmap#29).
- **Amounts:** issued and remaining go through `fmt.display.currency`. The response has no currency, so they're shown in the deployment's currency. Every note on the dev tenant is MXN.
- **Issued:** shown as the server's `refunded` (FR-015). Until mbe-api#277 ships it reads 0.00 on legacy notes. That's a known, upstream-owned wrong figure, not something to patch on the client.

**Rejected:** A batch name lookup. No customer `ids` filter exists, and 20 lookups per page is the cost Pagos already paid before mbe-api#270.

## R10. Opening a row

**Decision:** `context.push('/sales/payments/<customerPayment>')`. Back then returns to the credit-notes list. A note from another facility shows the detail screen's existing not-found state for non-editors (`payment_detail_controller.dart:33-39`). That's accepted: the server enforces the same rule (mbe-api#273).

**Rejected:** Fetching each row's payment up front to hide foreign rows. That's 20 extra requests per page.

## R11. Tests and fixtures

- **Unit:**
  - `CreditNoteRepositoryImpl`, with the fake HTTP adapter used by `customer_payment_repository_impl_test.dart`
  - `tenderCreditNotes`, extending `payment_controller_test.dart`: cap order, oldest first, partial failure, no change
  - the ticket lookup outcomes
  - the list controller's three paging modes
- **Widget:**
  - the grid tile (shown or hidden by gate, customer and balance)
  - the ticket dialog's messages
  - the applied-row label
  - the list screen: columns, facets, no search box, the row tap gate
  - the router and nav gate, in `app_router_test.dart`
- **Live** (`test/integration/credit_notes_live_test.dart`): list paging against the dev tenant; customer lookup for note 990's customer (10653).
  - Redemption isn't tested live until mbe-api#277 ships. No legacy note reports a spendable balance that is real, and note 158 was cashed out.
  - The test calls `markTestSkipped` when no note with `remaining > 0` exists that isn't cashed out.
