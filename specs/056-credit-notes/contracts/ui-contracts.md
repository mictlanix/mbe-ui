# UI Contracts: Credit Notes

## C1. Routes and navigation

| Route | Screen | Gate | SystemObject |
|---|---|---|---|
| `/sales/credit-notes` | `CreditNotesListScreen(query: ListQuery.fromUri(state.uri))` | `PrivilegeGate(SystemObject.creditPayments, AccessRight.read)` | CreditPayments (83) |

- The shell branch is appended last, at index 23. Add `NavBranch.creditNotes = 23` to `core/navigation/nav_destinations.dart`.
- The nav entry sits in the `sales` group right after Pagos: `id: 'credit-notes'`, the label `creditNotesMenuTitle`, and the icon `Icons.receipt_long_outlined`.
- Add a `_routeGate` clause for the `/sales/credit-notes` prefix next to `/sales/payments` in `app_router.dart`.

## C2. Payment step: customer credit tile (FR-001, FR-002)

- **Key:** `payment_credit_note_tile`.
- **Shown when** all of these hold:
  - the user passes `can(creditPayments, read)` and `can(customerPayments, create)`
  - the customer isn't the walk-in one
  - the sale isn't cancelled
  - `balanceOrZero > 0`
  - `customerCreditProvider(sale.id).total > 0`
- **Label:** "Nota de crédito". **Second line:** "Saldo {amount}".
- **Tap:** `tenderCreditNotes(sale, notes, enteredAmount)`, where `enteredAmount` is the draft's amount or null.

| Outcome | What the step shows |
|---|---|
| Applied | The balance and the applied rows refresh. A new row reads "Nota de crédito · {amount}" (C4). The draft is pre-filled with the remaining balance. |
| `creditPartlyApplied` | The issue message "Se aplicaron {applied} de crédito; el resto no se pudo aplicar." and an `ErrorBanner` with the server's error. Everything re-reads. |

## C3. Payment step: walk-in ticket (FR-005, FR-006, FR-006a)

- **Tile:** key `payment_credit_note_redeem_tile`, labelled "Canjear nota de crédito". It replaces C2's tile on a walk-in sale. **Gate:** C2's gates, plus `can(customerPayments, read)`, with no credit-total condition.
- **Dialog:** `showCreditNoteTicketDialog`.
  - An autofocused number field, key `credit_note_ticket_input`. Enter submits it.
  - Once a valid note is found, the dialog shows "Saldo disponible {remaining}" and enables confirm (key `credit_note_ticket_confirm`). Confirm applies `min(remaining, balance)`, or the entered amount when it is smaller.

| Refusal | Message (es) |
|---|---|
| `noteNotFound` | "No hay una nota de crédito con ese número." |
| `noteUsedUp` | "Esta nota de crédito ya se usó por completo." |
| `noteAlreadyOnSale` | "Esta nota de crédito ya está aplicada a esta venta." |
| `noteOtherCustomer` | "Esta nota de crédito es de {name}. Haz la venta a su nombre para usarla." |

Refusals show inside the dialog and apply nothing.

## C4. Applied payments panel (FR-009)

A row whose `SalePayment.type == PaymentType.creditNote` leads with `paymentTypeLabel` ("Nota de crédito") where the method label would be. Its icon is `Icons.receipt_long_outlined`. Everything else (amount, undo, cancelled styling) is unchanged.

## C5. "Notas de crédito" list (FR-010 to FR-013)

**Filter row:** a `CatalogFilterBar` with no `search`, no `actions`, and `filters` holding the badged tune button. Its drawer holds:
- a customer `CatalogEntityPicker` (key `credit_notes_customer_filter`)
- a "Solo con saldo" `SwitchListTile` (key `credit_notes_open_only_filter`)

**List:** `CatalogListStateView` + `DataTableView`, 20 per page, page in the URL. Columns:

| Column | Content | Alignment | May be truncated |
|---|---|---|---|
| Fecha | `fmt.display.dateTime` | left | no |
| Cliente | display name | left | yes, with a tooltip |
| Origen | "Devolución #{refund} · Pedido #{order}"; the order number links when readable | left | no |
| Emitido | `fmt.display.currency(issued)` | right | no |
| Saldo | `fmt.display.currency(remaining)` | right | no |

**Rows:** no row icons. A credit note is never edited; this follows the cash-sessions list and Pagos precedent. When the user can read customer payments, the row tap pushes `/sales/payments/{customerPaymentId}`; otherwise the row isn't tappable.

**States:** a 403 shows the same forbidden view as Pagos. The empty and filtered-empty states come from `CatalogListStateView`.

## C6. l10n keys (en template + es)

**Nav and list:**
- `creditNotesMenuTitle`
- `creditNotesColumnDate`, `creditNotesColumnCustomer`, `creditNotesColumnOrigin`, `creditNotesColumnIssued`, `creditNotesColumnRemaining`
- `creditNotesOrigin` (`{refund}`, `{order}`)
- `creditNotesOpenOnlyFilter`, `creditNotesCustomerFilter`
- `creditNotesEmpty`

**Payment step:**
- `paymentCreditNoteTile`, `paymentCreditNoteBalance` (`{amount}`), `paymentCreditNoteRedeemTile`, `paymentCreditPartlyApplied` (`{amount}`)

**Ticket dialog:**
- `creditNoteTicketTitle`, `creditNoteTicketInput`, `creditNoteTicketAvailable` (`{amount}`), `creditNoteTicketConfirm`
- `creditNoteNotFound`, `creditNoteUsedUp`, `creditNoteAlreadyOnSale`, `creditNoteOtherCustomer` (`{name}`)
