# Data Model: Invoice List, View, PDF and Editor (spec 066)

All entities are immutable freezed classes in `lib/features/invoicing/domain/entities/`, mapped from the generated `mbe_api_client` models in `data/` (§III). Amounts and quantities are `Decimal`.

## 1. Enums

| Enum | Values | Wire |
|---|---|---|
| `FiscalDocumentStatus` | `draft`, `sealed`, `issued`, `cancelled` | Summary/Response status enums (`sealed` is `sealed_` in Dart). An unknown value maps to `draft`, and the repository test fixes that behaviour |
| `FiscalDocumentKind` (catalog, **renamed**, research R2) | `invoice(0)`, `feeReceipt(1)`, `rentReceipt(2)`, `debitNote(3)`, `creditNote(100)`, `advancePaymentsApplied(101)`, `paymentReceipt(200)` | `int`; `fromCode` returns null for an unknown code |
| `PaymentTerms` | `pue` (0, IMMEDIATE), `ppd` (1, NET_D) | `int` in responses, generated `PaymentTerms` in `InvoiceUpdate` |
| `InvoiceTaxRate` | `iva16` (0.16), `zero` (0), `exempt` (-1) | Decimal string; any other value maps to null and the line shows the raw rate |
| `InvoiceRelationType` | `substitution` ('04'), `advanceApplication` ('07'), `creditNoteOf` ('01', read only) | '01'/'04'/'07'; null when absent |

## 2. Entities

### FiscalDocumentSummary (list row)

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `fiscal_document_id` | |
| typeCode | int | `type` | `kind` is the getter `FiscalDocumentKind.fromCode(typeCode)` |
| version | String | `version` | "0" on drafts |
| series | String? | `batch` | |
| serial | int? | `serial` | null until the first confirm |
| issuerRfc | String | `issuer` | |
| issuerName | String? | `issuer_name` | |
| recipientRfc | String? | `recipient` | |
| recipientName | String? | `recipient_name` | |
| issued | DateTime? | `issued` | wall-clock Mexico City (spec 043) |
| stampUuid | String? | `stamp_uuid` | |
| status | FiscalDocumentStatus | `status` | |
| total | Decimal? | `total` | null for draft (no XML) |

Getter `folioLabel`: `"{series}{serial}"` when serial is set; otherwise null, and the UI shows "Borrador #{id}".

### FiscalDocument (detail)

All summary fields, plus:

| Field | Type | From |
|---|---|---|
| issuerRegime / issuerRegimeName | String? | `issuer_regime`, `issuer_regime_name` |
| customerId | int? | `customer` |
| facilityId | int? | `facility` |
| issuedLocation | String | `issued_location` (postal code) |
| taxpayerRegime / taxpayerPostalCode | String? | recipient's, copied |
| usage | String? | `usage` (SAT code) |
| paymentTerms | PaymentTerms | `payment_terms` |
| paymentForm | int | `payment_method` (SAT forma de pago; mapped to `PaymentMethod` for display) |
| currencyCode | int | `currency` (display only; MXN) |
| exchangeRate | Decimal | `exchange_rate` |
| reference | String? | `reference` |
| comment | String? | `comment` |
| stamped | DateTime? | `stamped` |
| cancellationDate | DateTime? | `cancellation_date` |
| cancellationReason | String? | `cancellation_reason` |
| lines | List\<InvoiceLine\> | `lines` |
| relations | List\<InvoiceRelation\> | `relations ?? []` |

Getters:
- `isInvoice` is `typeCode == 0`.
- `isEditableDraft` is `isInvoice && status == draft`.
- `canReopen` is `isInvoice && status == sealed`.
- `hasDocuments` is `status == issued` (PDF and XML offered; the server still refuses non-4.0 or unstamped documents).
- `relationType` is the type shared by `relations`, or null.
- `amounts` is `invoiceAmounts(lines)` (§4).

### InvoiceLine

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `fiscal_document_detail_id` | the `line_id` |
| productId | int? | `product` | |
| orderLineId | int? | `order_detail` | non-null means the line came from a sales order |
| productCode | String? | `product_code` | internal code |
| productName | String | `product_name` | |
| satProductKey | String? | `product_service` | |
| unitKey / unitName | String? | `unit_of_measurement[_name]` | |
| quantity | Decimal | `quantity` | |
| price | Decimal | `price` | unit price as entered (tax-included or not) |
| discountRate | Decimal | `discount` | fraction 0–1 |
| taxRate | Decimal | `tax_rate` | 0.16 / 0 / -1 |
| taxIncluded | bool | `tax_included` | |
| comment | String? | `comment` | |

Getter `amounts` is `lineAmounts(this)` (§4).

### InvoiceRelation

| Field | Type | From |
|---|---|---|
| id | int | `fiscal_document_relation_id` (the `relation_id` for DELETE) |
| documentId | int | `relation` |
| type | InvoiceRelationType? | `type` |
| stampUuid | String? | `stamp_uuid` |
| series / serial | String? / int? | `batch`, `serial` |

## 3. Write inputs (domain → wire)

| Domain input | Wire model | Rules enforced client-side (the server re-checks all) |
|---|---|---|
| `NewInvoice(customerId, recipientRfc)` | `InvoiceCreate(customer, recipient)` | The recipient is chosen from the customer's taxpayers |
| `InvoiceHeaderPatch` (each field nullable; only non-null fields sent) | `InvoiceUpdate` | Series not sent once `serial != null`. PPD sends no form (the server forces 99). `issued` is within the last 72 h and not in the future. `reference` ≤ 25, `comment` ≤ 1000. `facility` only with 103 update. Receipt-only fields are never sent |
| `InvoiceLinePatch(quantity?, price?, discountPercent?, taxRate?, productCode?, productName?, comment?)` | `InvoiceLineUpdate` | quantity > 0 (4 dp); price ≥ 0 (7 dp); discount % 0–100 sent as `percent / 100` (fraction, exact Decimal); `productCode` ≤ 35; `productName` ≤ 1000, where blank is sent as `""` so the server resets it |
| `salesOrderId` | `InvoiceSalesOrderAdd(sales_order)` | |
| `productId` | `InvoiceLineAdd(product)` | |
| `(documentId, InvoiceRelationType)` | `InvoiceRelationAdd(relation, type)` | Only `04`/`07`. The type is locked to `relationType` when one exists |

## 4. Amounts (pure functions, research R11)

`lineAmounts(InvoiceLine) → LineAmounts(subtotal, discount, total, taxes)` and `invoiceAmounts(List<InvoiceLine>) → InvoiceAmounts(subtotal, discount, taxes, total)` mirror mbe-api `cfdi_invoice.line_amounts` and the `SubTotal`/`Descuento`/`Total` sums in `build`. Exempt (−1) is treated as t = 0. Rounding is half away from zero to 2 places, applied only when the value has more than 2 places. Line row amount = `subtotal − discount`.

## 5. State transitions

```text
          create (23 C)
               │
               ▼
  ┌────────► draft ──confirm (23 U)──► sealed ──(stamp: roadmap#46)──► issued
  │            ▲                         │                                │
  │            └──────reopen (23 U)──────┘                     (cancel: roadmap#52)
  │                                                                       ▼
  │                                                                   cancelled
  └── edits (23 U; manual line 56 C; facility 103 U) loop on draft only
```

This spec drives only create, edits, confirm and reopen. Issued and cancelled documents come from legacy or from later roadmap items.

## 6. List filter (URL state)

`FiscalDocumentsFilter` (freezed) holds `search: String?`, `status: FiscalDocumentStatus?`, `kind: int?` (type code), `issuerRfc: String?`, `from: DateTime?`, `to: DateTime?` (both or neither), `pageIndex: int`. Its query keys are `q`, `status`, `type`, `issuer`, `from`, `to` and `page`. `activeFilterCount` counts status, type, issuer and the date range as one. `cleared()` keeps the search.
