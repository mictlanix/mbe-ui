# Consumed Endpoints: Taxpayer Batches

All four endpoints are on the generated `TaxpayerIssuersApi`, called only from `TaxpayerBatchRepositoryImpl`. SystemObject: Taxpayers (24).

| Repository method | Generated method | HTTP | Right | Returns |
|---|---|---|---|---|
| `listForIssuer(rfc)` | `listTaxpayerBatches…` | GET `/api/v1/taxpayer-issuers/{rfc}/batches` | Read | `BuiltList<TaxpayerBatchResponse>` (a bare list, not a `ListResponse`) |
| `create(rfc, draft)` | `createTaxpayerBatch…` | POST `/api/v1/taxpayer-issuers/{rfc}/batches` | Create | `TaxpayerBatchResponse` (201) |
| `update(rfc, id, draft)` | `updateTaxpayerBatch…` | PUT `/api/v1/taxpayer-issuers/{rfc}/batches/{id}` | Update | `TaxpayerBatchResponse` |
| `delete(rfc, id)` | `deleteTaxpayerBatch…` | DELETE `/api/v1/taxpayer-issuers/{rfc}/batches/{id}` | Delete | `void` (204) |

## Request body (create and update)

```json
{
  "batch": "FAC",
  "type": 0,
  "template": {
    "name": "Factura",
    "logo": "logo.png",
    "header_height": 0,
    "footer_height": 15,
    "extra_info": [
      {"bank": "BBVA", "account": "0123456789", "clabe": "012180001234567891", "currency": "MXN"}
    ]
  }
}
```

The repository builds `TaxpayerBatchCreate` / `TaxpayerBatchUpdate` from the domain draft. `type` maps from `FiscalDocumentKind.code` to `FiscalDocumentType` by wire number.

## Refusals and their handling

| Status | Code / type | Params | When | UI handling | es message |
|---|---|---|---|---|---|
| 409 | `resource.already_exists` | `resource: taxpayer_batch`, `field: batch` | Duplicate series for the issuer | Error under the series field (R7) | "Ya existe una serie con ese valor." (generic resource message with the new `taxpayer_batch` noun) |
| 409 | `taxpayer_batch.in_use` | `action: update` | Series or type changed on an in-use series | Banner; lock and reset series/type; invalidate list (R6) | "La serie ya se usa en documentos emitidos; solo puede cambiar su plantilla." |
| 409 | `taxpayer_batch.in_use` | `action: delete` | Delete of an in-use series | Banner; lock; invalidate list (R6) | "La serie ya se usa en documentos emitidos y no se puede eliminar." |
| 404 | `resource.not_found` | `resource: taxpayer_issuer` | Issuer gone (list, create) | Close dialog, go to `/taxpayer-issuers` (R8) | existing |
| 404 | `resource.not_found` | `resource: taxpayer_batch` | Series gone (update, delete) | Banner; invalidate list (R8) | generic message with the new noun |
| 422 | `taxpayer_batch_series_blank` | none | Series blank after trim (the client prevents this) | Field error on series | "La serie no puede quedar en blanco." |
| 422 | generic validation types | | Length or range limits (the client prevents these) | Field errors via the existing generic path | existing |
| 403 | `auth.forbidden` | | Missing right (the UI hides the action) | Banner | existing |

## Coverage bookkeeping

`specs/058-localized-api-errors/contracts/code-scope.tsv`:

- `code taxpayer_batch.in_use`: OUT → IN. Example routes `PUT /taxpayer-issuers/{}/batches/{}; DELETE /taxpayer-issuers/{}/batches/{}`.
- `validation_type taxpayer_batch_series_blank`: OUT → IN.
- New rows `resource taxpayer_batch resource.already_exists IN` and `resource taxpayer_batch resource.not_found IN`.
- `test/unit/core/errors/catalog_coverage_test.dart`: 113 → 114.
