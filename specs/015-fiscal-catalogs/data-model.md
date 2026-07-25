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
| `paymentMethod` | `int` (SAT `c_FormaPago` code) | Rendered via the `PaymentMethod` lookup (§ shared-kernel below). |
| `commission` | `String?` (decimal) | Optional; from `Commission` `AnyOf[String,num]`, normalized to a string. |
| `status` | `EntityStatus` | Shared enum. |

**Display helpers**: `facilityDisplayName(fallback)`, `warehouseDisplayName(fallback)`,
`paymentMethodLabel` (via `PaymentMethod`).
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

## 3. TaxpayerCertificate (child row of the issuer detail — not a standalone catalog)

**Source DTO**: `TaxpayerCertificateResponse`
**File**: `lib/features/catalog/domain/entities/taxpayer_certificate.dart`
*(Displayed only inside the Taxpayer Issuer detail's Certificates section, scoped
to the open issuer's RFC — research §9. No standalone list/detail screen.)*

| Field | Type | Notes |
|---|---|---|
| `taxpayerCertificateId` | `String` | Certificate number. Server-assigned/derived. |
| `taxpayer` | `String` | Owning issuer RFC. Equals the open issuer; not displayed as a column in the section (implied by context). |
| `validFrom` | `DateTime` | **Server-derived from the certificate.** Read-only. |
| `validTo` | `DateTime` | **Server-derived from the certificate.** Read-only. |
| `status` | `EntityStatus` | Shared enum (rendered as the "Activo" indicator). |

**No create/update entity from user fields** — registration is an *upload*, not a
field-mapped create. The upload input is a separate value:

**CertificateUpload (form input, not persisted)**:
| Field | Type | Notes |
|---|---|---|
| `taxpayer` | `String` (RFC) | **Taken from the open issuer** — not re-selected (FR-021). |
| `certificate` | file bytes → encoded `String` | `.cer`, DER (research §8). |
| `key` | file bytes → encoded `String` | `.key`, DER, password-protected. |
| `keyPassword` | `String` | The key password. |

→ `TaxpayerCertificatesApi.upload(taxpayer, certificate, key, keyPassword)`.
**Validation**: the two files + password present before submit; server validates
the pair, password, validity, and taxpayer match, surfaced on rejection.
**No update, no delete entity** — the section offers neither (research §9).

---

## Shared-kernel additions

### PaymentMethod (new — `lib/core/domain/payment_method.dart`)

A hand-named lookup mirroring mbe-api's authoritative `PaymentMethod` constant
(`Model/Constants/PaymentMethod.cs`; `mbe-api/docs/constants.md`), following the
`EntityStatus`/`Gender`/`FacilityType` precedent (research §5). An explicit
`{code: (member name, es-MX label)}` map keyed by the SAT-aligned integer; maps
each code to a display label and back for the dropdown; unmapped codes fall back
to their raw value. **Member set** (research §5 table): `0 NA` (default),
`1 Cash`, `2 Check`, `3 EFT`, `4 CreditCard`, `5 ElectronicPurse`,
`6 ElectronicMoney`, `8 FoodVouchers`, `12 Giving`,
`27 ToTheSatisfactionOfTheCreditor`, `28 DebitCard`, `29 ServiceCard`,
`30 AdvancePayments`, `99 ToBeDefined`, `1001 GovernmentFunding`. Codes are
**non-contiguous** → an explicit map, not an ordinal list. The
`1001 GovernmentFunding` entry (a non-SAT mbe extension) carries a
`// FIXME(payment-method):` comment (provisional; isolated on its own line for
one-line removal) — research §5.

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
- `TaxpayerIssuerListItem` + `TaxpayerIssuerRepository.list` (spec 014) — retained for the spec-014 facility-form issuer autocomplete (no longer needed by certificates, which take the RFC from the open issuer).
- `EntityStatus` + `EntityStatusControls`/`EntityStatusFilterChips`/`EntityStatusCell` — status field, filter, and cell on the two standalone catalogs; the certificate section renders status as an "Activo" indicator.
- Inline sub-form/dialog pattern (spec 014 facility inline-address create) — the certificate Agregar upload dialog reuses this shape.

## Repository interfaces (feature layer)

- **`PaymentMethodOptionRepository`** (new): `list({search?, facility?, status?, skip, limit})→Page`, `get(id)`, `create(...)`, `update(id, ...)`, `delete(id)`. *(Note: the generated `list` exposes `facility`+`status` but **no** `search`; see contracts.)*
- **`TaxpayerIssuerRepository`** (extend existing): keep `list({search?, skip, limit})` + lightweight `get(rfc)→TaxpayerIssuerListItem`; add `getDetail(rfc)→TaxpayerIssuer`, `create(...)`, `update(rfc, ...)`, `delete(rfc)`.
- **`TaxpayerCertificateRepository`** (new): `listForIssuer(rfc)→List<TaxpayerCertificate>` (wraps the generated `list(taxpayer: rfc)`), `upload({taxpayer, certificate, key, keyPassword})→TaxpayerCertificate`. **No `update`, no `delete`; no standalone list/detail screen** — consumed only by the issuer detail's Certificates section (research §9). (`get(id)` may exist on the generated API but is unused.)
