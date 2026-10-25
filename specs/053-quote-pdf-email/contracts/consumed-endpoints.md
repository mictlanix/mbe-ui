# Contract: Consumed mbe-api Endpoints

What mbe-ui relies on from mbe-api spec 024 (PR #254) and the existing customer endpoint.
If any of this changes upstream, regenerate the client and revisit [research.md](../research.md) R1, R4–R6.

## E1 — `GET /api/v1/sales-quotes/{sales_quote_id}/document`

- **Client**: `SalesQuotesApi.printSalesQuoteDocumentApiV1SalesQuotesSalesQuoteIdDocumentGet(salesQuoteId:)`.
  It returns `Response<Uint8List>` and already sets `ResponseType.bytes`.
- **Gate**: `SALES_QUOTES` Read.
- **200**: `application/pdf`, served inline, with `Content-Disposition` filename `cotizacion-{id:08d}.pdf`.
  Any quote state is accepted.
- **Errors**: 401 → session; 403 → `ServerError(403)`; 404 → `NotFoundError`.
  These are handled by `core/documents/` as for the other kinds.
- **mbe-ui guarantees**: the body must start with `%PDF-` or it is treated as a server
  error (spec 044 FR-020). Bytes are never altered or cached.

## E2 — `POST /api/v1/sales-quotes/{sales_quote_id}/email`

- **Client**: `SalesQuotesApi.emailSalesQuoteApiV1SalesQuotesSalesQuoteIdEmailPost(salesQuoteId:, quoteEmailRequest:)`.
- **Gate**: `SALES_QUOTES` Read.
- **Request**: `{"to": ["a@b.mx", ...]}`. mbe-ui sends 1–10 trimmed, client-deduplicated
  addresses that pass `isPlausibleEmail`.
- **200**: `{"recipients": [...], "sent_at": "<Mexico City local>"}`. The server writes one
  `incidence` per send.
- **Errors**:

| Status | Meaning | mbe-ui `AppError` | Dialog cause |
|---|---|---|---|
| 409 | quote is not confirmed (draft or cancelled) | `ServerError(409, detail)` | `notSendable` → refresh on close |
| 422 | 0 or >10 addresses, or a malformed one | `ValidationError(fields, detail)` | `invalidRecipients` |
| 502 | the mail server refused; nothing recorded | `ServerError(502, detail)` | `mailRefused` |
| 503 | mail not configured (`MAIL_*` unset) | `ServerError(503, detail)` | `mailUnavailable` |
| — | no response | `NetworkError` | `other` |

- **Synchronous**: the response arrives only after SMTP answers. mbe-ui sets no extra
  timeout beyond dio's defaults.

## E3 — `GET /api/v1/customers/{customer_id}` *(existing, unchanged)*

- **Client access**: through `saleCustomerControllerProvider(customerId)`.
- **Gate**: any of `CUSTOMERS`, `SALES_ORDERS`, `SALES_QUOTES` or `POS` Read, so a quote
  reader always passes.
- **Used fields**: `contacts[].name`, `contacts[].email` (nullable), `taxpayers[].name`,
  `taxpayers[].email`. The lists are complete; there is no pagination.

## External preconditions *(not mbe-ui work)*

- The deployment used to verify User Story 2 must have `MAIL_FROM` and the SMTP settings
  configured, or every send is a 503.
- No mbe-api issue needs to be filed for this feature.
