# UI Contracts: Payments Follow-ups

These contracts extend spec 054's ([../../054-payments-list-search/contracts/ui-contracts.md](../../054-payments-list-search/contracts/ui-contracts.md)). Keys are the test seams.

## C1. Payments list: search box

| Scope | Search box | Hint (es) | Sends |
|---|---|---|---|
| This facility | `payments_search_field` | "Buscar por cliente" (`paymentsSearchCustomerHint`) | `search=<text>` on `GET /customer-payments` |
| All facilities | `payments_search_field` | "Buscar por referencia" (existing `paymentsSearchReferenceHint`) | `reference=<text>` on `/customer-payments/search` (unchanged) |

- The search text is stored in the URL as `?search=`.
- Switching scope drops it.
- With search text and no results, the list shows the filtered-empty view, with "Limpiar filtros" going back to the scope's cleared path.

## C2. Payments list: refused

| State | Widget | Key | Retry |
|---|---|---|---|
| `ServerError(statusCode: 403)` | `_ListForbidden`: `ErrorBanner` with `paymentsListForbidden` | `payments_list_forbidden` | none |
| any other error | `ListFailedView` (unchanged) | `list_state_failed` | yes |

## C3. "Ver ticket"

Shown only when `payment.type.hasTicket && canOpenDocument(access, DocumentKind.customerPaymentTicket)`. Otherwise it is absent, never disabled.

| Surface | Control | Key | Label / tooltip (es) |
|---|---|---|---|
| List row (both scopes) | `buildCatalogRowActions(onEdit: null, extraActions: [CatalogRowAction(...)])`, icon `Icons.receipt_long_outlined` | `payment_view_ticket_<id>` | tooltip "Ver ticket" (`paymentViewTicketTooltip`) |
| Payment view | `OutlinedButton.icon` in the body's action area, aligned to the end | `payment_view_ticket_button` | "Ver ticket" (`paymentViewTicketAction`) |

- Both call `ref.read(documentActionsProvider).preview(context, paymentTicketRef(l10n, payment))`.
- The preview title is `documentPaymentTicketTitle(id)`: "Ticket de pago {id}".
- The row tap still opens the payment view. Tapping the icon must not also trigger the row tap.

## C4. Customer cell

`PaymentCustomerName({required int customerId, String? name})`:

| `name` | Shows | Requests |
|---|---|---|
| non-null | `name` | none |
| `null` | `customerDisplayNameProvider(customerId)`: "…" while loading, then the name, or `#id` if the lookup fails | one per distinct id (spec 054 behavior) |

Used in the list's customer column and in the payment view.

## C5. Strings (es / en)

| Key | es | en |
|---|---|---|
| `paymentsSearchCustomerHint` | Buscar por cliente | Search by customer |
| `paymentsListForbidden` | No tienes permiso para ver estos pagos. | You aren't allowed to see these payments. |
| `paymentViewTicketTooltip` | Ver ticket | View ticket |
| `paymentViewTicketAction` | Ver ticket | View ticket |
| `documentPaymentTicketTitle` | Ticket de pago {id} | Payment ticket {id} |

## C6. Server contract relied on

| Call | Who | Expected |
|---|---|---|
| `GET /customer-payments/{id}` | non-editor, another facility | 404 |
| `GET /customer-payments/{id}/applications` | non-editor, another facility | 404 |
| `GET /customer-payments/{id}/ticket` | non-editor, another facility | 404 |
| `GET /customer-payments/{id}/ticket` | an eligible type | 200 `application/pdf` (72 mm) |
| `GET /customer-payments/{id}/ticket` | any other type | 409, with the type named in `detail` |
| `GET /customer-payments?facility=<other>` | non-editor | 403 |
| `GET /customer-payments?search=<text>` | anyone with read | rows whose customer name contains the text, ignoring case |
