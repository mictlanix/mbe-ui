# Contract: mbe-api Fiscal Catalog Endpoints & DTOs

**Feature**: `015-fiscal-catalogs` | **Date**: 2026-07-21

All endpoints below are already present in the generated client
(`lib/generated/openapi/lib/src/api/`). The app consumes them through
hand-written repositories that map `*Response` DTOs to feature-layer `freezed`
entities (constitution §III); generated types never reach the presentation
layer. Method names are the generated Dart method names, abbreviated.

---

## 1. Payment Method Options — `PaymentMethodOptionsApi` — RBAC `paymentMethodOptions(84)`

| Op | Method | Verb / Path | Returns |
|---|---|---|---|
| List | `listPaymentMethodOptions…Get(facility?, status?, skip?, limit?)` | GET `/api/v1/payment-method-options` | `ListResponsePaymentMethodOptionResponse` |
| Get | `getPaymentMethodOption…Get(paymentMethodOptionId)` | GET `/…/{id}` | `PaymentMethodOptionResponse` |
| Create | `createPaymentMethodOption…Post(PaymentMethodOptionCreate)` | POST `/…` | `PaymentMethodOptionResponse` |
| Update | `updatePaymentMethodOption…Put(id, PaymentMethodOptionUpdate)` | PUT `/…/{id}` | `PaymentMethodOptionResponse` |
| Delete | `deletePaymentMethodOption…Delete(id)` | DELETE `/…/{id}` | void |

**List filters**: `facility (int?)`, `status (EntityStatus?)`. ⚠️ **No `search`** —
tracked upstream dependency (research §15); search box wired to the expected capability.

**`PaymentMethodOptionResponse`**: `paymentMethodOptionId:int`, `facility:FacilitySummary`,
`warehouse:WarehouseSummary`, `name:String`, `numberOfPayments:int`,
`displayOnTicket:bool`, `paymentMethod:int`, `commission:String`, `status:EntityStatus`.
`facility`/`warehouse` are **pre-expanded** → no N+1.

**`PaymentMethodOptionCreate`**: `facility:int`(req), `warehouse:int?`, `name:String`(req),
`numberOfPayments:int=1`, `displayOnTicket:bool=true`, `paymentMethod:int`(req),
`commission:Commission?`(AnyOf[String,num]), `status:EntityStatus=0`.
**`PaymentMethodOptionUpdate`**: every field optional (partial update).

---

## 2. Taxpayer Issuers — `TaxpayerIssuersApi` — RBAC `taxpayers(24)`

| Op | Method | Verb / Path | Returns |
|---|---|---|---|
| List | `listTaxpayerIssuers…Get(search?, skip?, limit?)` | GET `/api/v1/taxpayer-issuers` | `ListResponseTaxpayerIssuerResponse` |
| Get | `getTaxpayerIssuer…Get(rfc)` | GET `/…/{rfc}` | `TaxpayerIssuerResponse` |
| Create | `createTaxpayerIssuer…Post(TaxpayerIssuerCreate)` | POST `/…` | `TaxpayerIssuerResponse` |
| Update | `updateTaxpayerIssuer…Put(rfc, TaxpayerIssuerUpdate)` | PUT `/…/{rfc}` | `TaxpayerIssuerResponse` |
| Delete | `deleteTaxpayerIssuer…Delete(rfc)` | DELETE `/…/{rfc}` | void |

**List filter**: `search (String?)` — ✅ functional. No backend facets (issuer has no
status/type field), so the screen is search-only and §VI-compliant.

**Primary key is the RFC** (`taxpayerIssuerId:String`) — the `{rfc}` path param for
get/update/delete. Entered on create, **immutable** thereafter (no RFC in the update body).

**`TaxpayerIssuerResponse`**: `taxpayerIssuerId:String(RFC)`, `name:String`,
`regime:SatCatalogResponse`, `provider:FiscalCertificationProvider`,
`postalCode:SatCatalogResponse`, `comment:String`. `regime`/`postalCode`
**pre-expanded** (code+description) → no N+1.

**`TaxpayerIssuerCreate`**: `taxpayerIssuerId:String`(req), `name:String?`,
`regime:String`(req, SAT code), `provider:FiscalCertificationProvider?=0`,
`postalCode:String?`(SAT code), `comment:String?`.
**`TaxpayerIssuerUpdate`**: `name?`, `regime?`, `provider?`, `postalCode?`, `comment?`.

---

## 3. Taxpayer Certificates — `TaxpayerCertificatesApi` — RBAC `taxpayers(24)`

| Op | Method | Verb / Path | Returns |
|---|---|---|---|
| List | `listTaxpayerCertificates…Get(taxpayer?, status?, skip?, limit?)` | GET `/api/v1/taxpayer-certificates` | `ListResponseTaxpayerCertificateResponse` |
| Get | `getTaxpayerCertificate…Get(certificateId)` | GET `/…/{certificate_id}` | `TaxpayerCertificateResponse` |
| Upload | `uploadTaxpayerCertificate…Post(taxpayer, certificate, key, keyPassword)` | POST `/api/v1/taxpayer-certificates` (multipart/form-data) | `TaxpayerCertificateResponse` |

**⚠️ No `update`, no `delete` method** — intentional (research §9). Consumed **only**
as a per-issuer child section of the Taxpayer Issuer detail (not a standalone
catalog): the section calls `list(taxpayer: <open issuer RFC>)` and `upload`, and
offers no edit/delete affordance. The `taxpayer` filter scopes the list to the open
issuer; `status`/`skip`/`limit` are available but unused by the bounded section.
**No `search` param exists, and none is needed** — a per-issuer collection is bounded
(FR-020), so the §VI search-box rule does not apply here (research §15).

**`TaxpayerCertificateResponse`**: `taxpayerCertificateId:String`, `taxpayer:String(RFC)`,
`validFrom:DateTime`, `validTo:DateTime`, `status:EntityStatus`. `validFrom`/`validTo`
and the certificate number are **server-derived from the uploaded certificate** — never
user input (FR-022).

**Upload** (`multipart/form-data`, all `String`, all required): `taxpayer`(RFC),
`certificate`(DER-encoded `.cer`), `key`(DER-encoded, password-protected `.key`),
`keyPassword`. Files selected via `file_picker`; bytes encoded to the string fields
(base64-of-DER default; confirm in quickstart — research §8).

---

## Shared / reused

- **`FacilitySummary`, `WarehouseSummary`** — pre-expanded FK projections on the payment-method-option response (already mapped by spec-014 Warehouse/PointSale entities).
- **`SatCatalogResponse`** → `SatCatalogItem` (code + description) — issuer regime/postal-code; `SatCatalogsApi.listTaxRegimes` / `listPostalCodes` back the pickers (already used by the Taxpayer Recipient form).
- **`EntityStatus`** — status field/filter/cell on Payment Method Options and Taxpayer Certificates.
- **`Commission`** (`AnyOf[String,num]`) — payment-method-option commission, submitted as a decimal string.
- **`FiscalCertificationProvider`** — generated int enum, unnamed members; display-label mapped (research §7).
- **No SAT `c_FormaPago` endpoint exists** — `paymentMethod` uses a hand-named `PaymentMethod` lookup (research §5).

## Error mapping

All operations surface failures through the shared `AppError`/`ErrorBanner` path the
catalogs already use: duplicate RFC on issuer create, invalid CSD pair / wrong password
/ expired / mismatched taxpayer on certificate upload, and delete-while-referenced
rejections are shown on the form without losing user input (FR-017, FR-023, FR-027).
