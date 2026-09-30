# Contract: mbe-api endpoints consumed

These are owned by mbe-api (#230, shipped in mbe-api#231). The normative source is mbe-api's `specs/019-document-printing/contracts/print-endpoints.md`. This file records only what mbe-ui relies on. **No mbe-api change is required** (constitution §III).

| Route | Generated method (`93bb31f`) | Gate |
|---|---|---|
| `GET /api/v1/sales-orders/{sales_order_id}/ticket` | `SalesOrdersApi.printSalesOrderTicketApiV1SalesOrdersSalesOrderIdTicketGet` | `SALES_ORDERS` READ |
| `GET /api/v1/sales-orders/{sales_order_id}/document` | `SalesOrdersApi.printSalesOrderDocumentApiV1SalesOrdersSalesOrderIdDocumentGet` | `SALES_ORDERS` READ |
| `GET /api/v1/cash-sessions/{cash_session_id}/ticket` | `CashSessionsApi.printCashSessionCutApiV1CashSessionsCashSessionIdTicketGet` | `POS` READ |

## Relied-on facts

| # | Fact | What breaks if it changes |
|---|---|---|
| E1 | Every 200 response is `application/pdf` with a `string`/`binary` schema, so the generated method is `Future<Response<Uint8List>>` with `ResponseType.bytes`. Both were verified on `93bb31f`. | Corrupt PDFs with no error (research §8.2). Re-verify on every regeneration. |
| E2 | `Content-Disposition: inline; filename="ticket-{id:08d}.pdf"` / `pedido-{id:08d}.pdf` / `corte-{id:06d}.pdf` | Only the file name. There is a fallback (R10). |
| E3 | Error bodies are JSON `{"detail": "…"}`: 404 `Sales order not found` / `Cash session not found`; 403 `Insufficient privileges`; 409 `Cash session is not closed` | The message shown (FR-030). They arrive as bytes; see research R9. |
| E4 | The ticket route returns the pre-payment ticket for a non-completed order and the final receipt for a completed one | Which document the POS completion prints. The order is confirmed before `_finish`. |
| E5 | The ticket and document are available in any order state; the cut is available only for closed sessions | When actions are offered (FR-003/004/006) |
| E6 | Rendering is deterministic, and nothing is stored server-side | The byte-equality check in the integration test (SC-003) |
