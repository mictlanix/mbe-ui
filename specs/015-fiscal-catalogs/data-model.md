# Phase 1 Data Model: Fiscal Catalogs

**Feature**: `015-fiscal-catalogs` | **Date**: 2026-07-21 | **Spec**: [spec.md](./spec.md)

Domain entities (feature layer) and the shared-kernel value(s) this feature
adds. All are hand-written `freezed` types mapped from generated
`*Response` DTOs — the generated types are **never** consumed directly by the
presentation layer (constitution §III). "List rows reuse the detail entity"
except where a lighter picker projection already exists.

---

## 1. PaymentMethodOption (detail entity + list row)

**Source DTO**: `PaymentMethodOptionResponse`
**File**: `lib/features/catalog/domain/entities/payment_method_option.dart`

| Field | Type | Notes |
|---|---|---|
| `paymentMethodOptionId` | `int` | Server-assigned primary key. |
| `facility` | `FacilitySummary`-derived value (id + name) | Required FK, **pre-expanded**. Reuse the summary projection the Warehouse entity already uses for its facility. |
| `warehouse` | nullable (id + name) | Optional FK, **pre-expanded** when present. |
| `name` | `String` | Required. |
| `numberOfPayments` | `int` | Default 1. |
| `displayOnTicket` | `bool` | Default true. |
| `paymentMethod` | `int` (SAT `c_FormaPago` code) | Rendered via the `PaymentForm` lookup (§ shared-kernel below). |
| `commission` | `String?` (decimal) | Optional; from `Commission` `AnyOf[String,num]`, normalized to a string. |
| `status` | `EntityStatus` | Shared enum. |

**Display helpers**: `facilityDisplayName(fallback)`, `warehouseDisplayName(fallback)`,
`paymentFormLabel` (via `PaymentForm`).
**Validation** (form): `facility` required; `name` required (non-empty);
`numberOfPayments` ≥ 1; `commission` parses as a non-negative decimal when present.

**Create payload** → `PaymentMethodOptionCreate`: `facility (int)`, `warehouse (int?)`,
`name`, `numberOfPayments`, `displayOnTicket`, `paymentMethod (int)`,
`commission (String?)`, `status`.
**Update payload** → `PaymentMethodOptionUpdate`: all optional (partial update).

---

## 2. TaxpayerIssuer (detail entity)

**Source DTO**: `TaxpayerIssuerResponse`
**File**: `lib/features/catalog/domain/entities/taxpayer_issuer.dart`
*(new — distinct from the existing lightweight `taxpayer_issuer_list_item.dart`)*

| Field | Type | Notes |
|---|---|---|
| `rfc` | `String` | Primary key (`taxpayerIssuerId`). **Identity; immutable after create.** |
| `name` | `String` | Falls back to empty if absent on the wire (recipient precedent). |
| `regime` | `SatCatalogItem?` | **Pre-expanded** `SatCatalogResponse` (code + description). |
| `provider` | `FiscalCertificationProvider` | Generated enum; labeled for display (research §7). |
| `postalCode` | `SatCatalogItem?` | **Pre-expanded** `SatCatalogResponse`. |
| `comment` | `String?` | Optional. |

**List row**: the catalog list reuses this detail entity for its rows (columns:
RFC, postal-code, name, regime). The **existing** `TaxpayerIssuerListItem`
(`{rfc, name}`) is retained unchanged for the spec-014 facility autocomplete and
this feature's certificate-form issuer picker — it is a picker projection, not
the catalog row.
**Validation** (form): `rfc` required (non-empty; server validates format/uniqueness);
`regime` required; `name` required before save.

**Create payload** → `TaxpayerIssuerCreate`: `taxpayerIssuerId (rfc)`, `name?`,
`regime (String code)`, `provider?`, `postalCode (String code)?`, `comment?`.
**Update payload** → `TaxpayerIssuerUpdate`: `name?`, `regime?`, `provider?`,
`postalCode?`, `comment?` — **RFC is the path param, never in the body**.

---

## 3. TaxpayerCertificate (detail entity + list row)

**Source DTO**: `TaxpayerCertificateResponse`
**File**: `lib/features/catalog/domain/entities/taxpayer_certificate.dart`

| Field | Type | Notes |
|---|---|---|
| `taxpayerCertificateId` | `String` | Primary key (the certificate serial number). Server-assigned/derived. |
| `taxpayer` | `String` | Issuer RFC (FK to a TaxpayerIssuer). Displayed directly (no resolve). |
| `validFrom` | `DateTime` | **Server-derived from the certificate.** Read-only. |
| `validTo` | `DateTime` | **Server-derived from the certificate.** Read-only. |
| `status` | `EntityStatus` | Shared enum. |

**No create/update entity from user fields** — registration is an *upload*, not a
field-mapped create. The upload input is a separate value:

**CertificateUpload (form input, not persisted)**:
| Field | Type | Notes |
|---|---|---|
| `taxpayer` | `String` (RFC) | Selected via issuer picker (`TaxpayerIssuerListItem`). |
| `certificate` | file bytes → encoded `String` | `.cer`, DER (research §8). |
| `key` | file bytes → encoded `String` | `.key`, DER, password-protected. |
| `keyPassword` | `String` | The key password. |

→ `TaxpayerCertificatesApi.upload(taxpayer, certificate, key, keyPassword)`.
**Validation**: all four present before submit; server validates the pair,
password, validity, and taxpayer match, surfaced on rejection.
**No update, no delete entity** — the catalog offers neither (research §9).

---

## Shared-kernel additions

### PaymentForm (new — `lib/core/domain/payment_form.dart`)

A hand-named `{code: label}` lookup over mbe's legacy `PaymentMethod` integer
codes, following the `EntityStatus`/`Gender`/`FacilityType` precedent (research
§5). Maps each code to a display label and back for the dropdown; unmapped codes
fall back to their raw value. **Member set confirmed** (research §5 table):
`0 N/A` (default), `1 Efectivo`, `2 Cheque`, `3 Transferencia Electrónica`,
`4 T. de Crédito`, `5 Monedero Electrónico`, `6 Dinero Electrónico`,
`8 Vales de Despensa`, `12 Dación`, `27 A Satisfacción Del Acreedor`,
`28 T. de Débito`, `29 Tarjeta de Servicio`, `30 Aplicación de Anticipos`,
`99 Por Definir`, `1001 FONACOT`. Codes are **non-contiguous** → an explicit map,
not an ordinal list. The `1001 FONACOT` entry carries a `// FIXME(payment-form):`
comment (provisional; isolated on its own line for one-line removal) — research §5.

### FiscalCertificationProvider label mapping (no new type)

A display-label extension/helper over the **generated**
`FiscalCertificationProvider` enum (research §7) — not a new domain enum. Lives
alongside the issuer presentation (or as a small `core/domain` label map,
matching how `EntityStatus`/`Gender` labels are surfaced today).

---

## Reused, unchanged

- `FacilityListItem` + `facilityRepositoryProvider` (spec 014) — payment-method-option facility picker & filter.
- `warehouseRepositoryProvider` (spec 014) — payment-method-option warehouse picker.
- `SatCatalogItem` + `satCatalogRepositoryProvider` (`listTaxRegimes`, `listPostalCodes`) — issuer regime/postal-code pickers.
- `TaxpayerIssuerListItem` + `TaxpayerIssuerRepository.list` (spec 014) — certificate-form issuer picker & certificate-filter facet.
- `EntityStatus` + `EntityStatusControls`/`EntityStatusFilterChips`/`EntityStatusCell` — status field, filter, and cell across all three catalogs.

## Repository interfaces (feature layer)

- **`PaymentMethodOptionRepository`** (new): `list({search?, facility?, status?, skip, limit})→Page`, `get(id)`, `create(...)`, `update(id, ...)`, `delete(id)`. *(Note: the generated `list` exposes `facility`+`status` but **no** `search`; see contracts.)*
- **`TaxpayerIssuerRepository`** (extend existing): keep `list({search?, skip, limit})` + lightweight `get(rfc)→TaxpayerIssuerListItem`; add `getDetail(rfc)→TaxpayerIssuer`, `create(...)`, `update(rfc, ...)`, `delete(rfc)`.
- **`TaxpayerCertificateRepository`** (new): `list({taxpayer?, status?, skip, limit})→Page`, `get(id)→TaxpayerCertificate`, `upload({taxpayer, certificate, key, keyPassword})→TaxpayerCertificate`. **No `update`, no `delete`.**
