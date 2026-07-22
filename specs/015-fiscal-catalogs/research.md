# Phase 0 Research: Fiscal Catalogs

**Feature**: `015-fiscal-catalogs` | **Date**: 2026-07-21 | **Spec**: [spec.md](./spec.md)

This document resolves every unknown in the plan's Technical Context. Each
section states the **Decision**, its **Rationale**, and the **Alternatives
considered**. Findings were verified directly against the generated client
(`lib/generated/openapi/`), the shipped spec-012/013/014 catalogs, and the
core shared widgets.

## §1 — All three API clients are already generated and present (zero upstream dependency)

**Decision**: Consume the already-generated `PaymentMethodOptionsApi`,
`TaxpayerIssuersApi`, and `TaxpayerCertificatesApi` as-is. No mbe-api change,
no regeneration, and no codegen for this feature.

**Rationale**: Verified present under `lib/generated/openapi/lib/src/api/`:
- `payment_method_options_api.dart` — full CRUD: `create`, `get`, `list`, `update`, `delete`. `list` params: `facility (int?)`, `status (EntityStatus?)`, `skip`, `limit`.
- `taxpayer_issuers_api.dart` — full CRUD keyed by **RFC** (`{rfc}` path param): `create`, `get`, `list`, `update`, `delete`. `list` params: `search (String?)`, `skip`, `limit`.
- `taxpayer_certificates_api.dart` — **list, get, upload only** (no update, no delete). `list` params: `taxpayer (String?)`, `status (EntityStatus?)`, `skip`, `limit`. `upload` params (multipart): `taxpayer (String)`, `certificate (String)`, `key (String)`, `keyPassword (String)`.

The same 2026-07-21 regeneration that closed spec 014's dependencies brought
these in.

**Alternatives considered**: Filing upstream requests (as specs 013/014 did for
their gaps) — unnecessary; nothing is missing.

## §2 — RBAC objects already exist; no `system_object.dart` edit required

**Decision**: Gate Payment Method Options on `paymentMethodOptions(84)` and both
Taxpayer catalogs on `taxpayers(24)`. Make **no** edit to `system_object.dart`.

**Rationale**: Both constants already exist in `lib/core/access/system_object.dart`
(`paymentMethodOptions(84)`, `taxpayers(24)`). Unlike spec 014 (which had to
correct `stores(29)`→`facilities(29)`), this feature introduces no RBAC-mirror
change. Taxpayer Issuers and Taxpayer Certificates deliberately share the one
`taxpayers(24)` object — the backend governs both under the taxpayer domain, and
no separate certificate object exists.

**Alternatives considered**: A dedicated certificate access object — none exists
upstream; inventing one client-side would gate against an object the server does
not check.

## §3 — Payment Method Options is the warehouse/cash-drawer shape plus extra fields

**Decision**: Model Payment Method Options directly on the spec-014 Warehouse
catalog: reuse `warehouses_list_screen.dart` / `warehouses_list_controller.dart`
(facility + status filter drawer) and `warehouse_detail_screen.dart` /
`warehouse_form_controller.dart` (facility picker + status controls) as the
structural template, extended with the option-specific fields.

**Rationale**: `PaymentMethodOptionResponse` is `{facility: FacilitySummary,
warehouse: WarehouseSummary, name, numberOfPayments, displayOnTicket,
paymentMethod, commission, status}` with a `facility` + `status` list filter —
the Warehouse shape (`{facility, code, name, status}` + facility/status filter)
plus a second optional FK (`warehouse`) and four scalar fields
(`numberOfPayments` int, `displayOnTicket` bool, `paymentMethod` code,
`commission` amount). The facility picker, the facility-filter facet, and the
status facet are the exact `CatalogEntityPicker<FacilityListItem>` +
`EntityStatusFilterChips` constructions the Warehouse screen already uses.

**Alternatives considered**: Modeling on Points of Sale (which also carries a
second `warehouse` FK) — equivalent, but Warehouse is the simpler, more direct
template; the `warehouse` FK here is *optional* and unconstrained, so the
point-of-sale facility↔warehouse coupling logic is **not** wanted.

## §4 — Taxpayer Issuers is the Taxpayer Recipient (RFC-keyed) shape

**Decision**: Model the Taxpayer Issuers catalog on the shipped **Taxpayer
Recipients** catalog (`taxpayer_recipient_detail_screen.dart`,
`taxpayer_recipient_form_controller.dart`, `taxpayer_recipients_list_*`), which
is already an RFC-keyed (String primary key) full-CRUD catalog with SAT
`regime`/`postalCode` pickers and a create-only, immutable id field.

**Rationale**: `TaxpayerIssuerResponse` is `{taxpayerIssuerId: String (RFC),
name, regime: SatCatalogResponse, provider: FiscalCertificationProvider,
postalCode: SatCatalogResponse, comment}`. The Recipient catalog already solves
every hard part: a client-supplied String id editable only on create
(`taxpayer_recipient_id_field` uses `enabled: fieldsEnabled && !_isEdit`), SAT
regime/postal-code pickers (`CatalogEntityPicker<SatCatalogItem>` over
`satRepo.listTaxRegimes` / `listPostalCodes`), and String-path `get/update/delete`.
The Issuer differs only by: dropping `email`, adding `provider` (a labeled enum
dropdown, §7) and `comment`, and the list columns (RFC, C.P., Nombre, Régimen).

**Alternatives considered**: Modeling on an int-keyed catalog (Warehouse) — wrong
key type; the RFC-as-identity, immutable-on-edit behavior is exactly what
Recipient already encodes and what the SAT domain requires.

## §5 — `paymentMethod` has no SAT catalog endpoint: use a static `PaymentMethod` lookup

**Decision**: Represent `paymentMethod` as a **dropdown backed by a small,
hand-named static lookup** — integer code → human label — following the exact
`FacilityType`/`Gender` precedent (a fixed list the generator hands over as a
bare `int`). The lookup lives as a shared-kernel value in `core/domain/`
(`payment_method.dart`), mirroring mbe-api's **authoritative** `PaymentMethod`
constant (`Model/Constants/PaymentMethod.cs`, documented at
`mbe-api/docs/constants.md` — the SAT-aligned *forma de pago* catalog). Default
`0` (NA). Each entry carries the canonical member name, the SAT code, and an
es-MX display label:

| Code | Member name | SAT | es-MX label |
|---|---|---|---|
| 0 | NA *(default)* | — | No aplica |
| 1 | Cash | 01 | Efectivo |
| 2 | Check | 02 | Cheque nominativo |
| 3 | EFT | 03 | Transferencia electrónica de fondos |
| 4 | CreditCard | 04 | Tarjeta de crédito |
| 5 | ElectronicPurse | 05 | Monedero electrónico |
| 6 | ElectronicMoney | 06 | Dinero electrónico |
| 8 | FoodVouchers | 08 | Vales de despensa |
| 12 | Giving | 12 | Dación en pago |
| 27 | ToTheSatisfactionOfTheCreditor | 27 | A satisfacción del acreedor |
| 28 | DebitCard | 28 | Tarjeta de débito |
| 29 | ServiceCard | 29 | Tarjeta de servicio |
| 30 | AdvancePayments | 30 | Aplicación de anticipos |
| 99 | ToBeDefined | 99 | Por definir |
| 1001 | GovernmentFunding | — | Financiamiento gubernamental |

**Rationale**: `PaymentMethodOptionCreate.paymentMethod` is a required bare `int`
with **no** generated enum and **no** SAT endpoint to pick from. The SAT catalog
API (`SatCatalogsApi`) exposes only CfdiUsages, Countries, Currencies,
PostalCodes, ProductServices, ReasonCancellations, TaxRegimes, and
UnitsOfMeasurement — there is **no** payment-methods list. Spec 013 characterized
this field as "the `paymentMethod` SAT enum" (013 contracts/mbe-api-catalogs.md);
it is mbe-api's `PaymentMethod` constant — SAT-aligned but a **superset** (codes
`0 NA` and `1001 GovernmentFunding` are non-SAT extensions), authoritatively
defined at `mbe-api/docs/constants.md`. Because it is a small, stable,
non-contiguous list (gaps at 7, 9–11, 13–26, etc.), a hand-named lookup — the
established pattern for a generator-unnamed fixed enum — is the right fit; a live
picker is impossible without an endpoint.

**Implementation notes**: the codes are **non-contiguous**, so the lookup is an
explicit `{code: (name, label)}` map keyed by the SAT-aligned integer (not an
ordinal-indexed list); the dropdown lists them in the table's order; an unmapped
code (should the backend widen the set) falls back to rendering its raw value
rather than dropping the record. `0` (NA) is the default selection on the create
form. The es-MX labels are surfaced via `.arb` keys (carrying their future
translations) so nothing is hard-coded (FR-029).

The `1001 GovernmentFunding` entry MUST be annotated with a
`// FIXME(payment-method):` comment in the `PaymentMethod` map (and a matching
note beside its `.arb` label key): upstream documents it as a **non-SAT mbe
extension**, so it is the one member whose inclusion is uncertain — isolated on
its own line so a later deletion is a one-line change that touches nothing else.

**Alternatives considered**:
- *Plain integer text field* — rejected: leaks a raw code to the user, no validation, poor UX, inconsistent with every other coded field in the app (all of which resolve to a label).
- *Requesting a SAT payment-methods endpoint upstream* — heavier than warranted for a fixed ~15-entry government-aligned list already defined in `mbe-api/docs/constants.md`; noted as a possible future nicety, not a blocker.

## §6 — `commission` is an `AnyOf[String, num]`: optional decimal text field submitted as string

**Decision**: Render `commission` as an optional decimal `TextFormField`,
validate it as a non-negative number on the form, and submit it as the string
form the generated `Commission` (`AnyOf[String, num]`) accepts.

**Rationale**: `Commission` is `AnyOf[String, num]`; the app already submits
money/decimal values as strings elsewhere (pricing). A single optional text
field with numeric validation matches the field's optionality
(`PaymentMethodOptionCreate.commission` is optional).

**Alternatives considered**: A num-typed field — the `AnyOf` accepts either, but
string submission matches the existing decimal-entry precedent and avoids
float-format surprises.

## §7 — `FiscalCertificationProvider`: display-label map over the generated enum

**Decision**: Present and store the issuer's `provider` using the generated
`FiscalCertificationProvider` enum values, mapping each to a human-readable
label for the dropdown — the same display-label approach used for
`EntityStatus`, `Gender`, and `FacilityType`. No replacement domain enum.

**Rationale**: `FiscalCertificationProvider` is a generated int enum whose
members the generator leaves unnamed (`number0`, `number1`, `number2`,
`number3`, …). The app's convention for a generated-but-unnamed fixed enum is a
thin label map, keeping the generated type as the source of truth. This stays
inside the spec's Out-of-Scope boundary ("only display-label mapping").

> **OPEN ITEM (low risk)**: the human labels for each provider ordinal must be
> confirmed against mbe-api's `FiscalCertificationProvider` definition. Default:
> label from the provider's known certification-provider names; fall back to the
> ordinal if unmapped.

**Alternatives considered**: A new hand-named enum replacing the generated one —
explicitly out of scope and unnecessary.

## §8 — Certificate upload: two `file_picker` selections, bytes encoded to the `String` fields

**Decision**: The certificate registration form uses the already-present
`file_picker` package to select the `.cer` and `.key` files (with extension
filters where the platform allows), reads each file's bytes, encodes them to the
`String` form the generated multipart `upload(taxpayer, certificate, key,
keyPassword)` expects, and submits together with the password. **No new
dependency.**

**Rationale**: `pubspec.yaml` already declares `file_picker: ^8.1.2`. The
generated `uploadTaxpayerCertificateApiV1TaxpayerCertificatesPost` takes
`certificate`/`key` as `String` (documented "DER encoded .cer" / "DER encoded,
password protected .key") over `multipart/form-data`. The two files are not
images, so none of spec 004's image-crop/preview concerns apply — this is a
plain pick-bytes-and-submit flow.

> **OPEN ITEM (low risk)**: confirm the exact string encoding the server expects
> for the `certificate`/`key` fields — base64 of the raw DER bytes is the
> default assumption and the natural encoding for binary-in-a-string over
> multipart; verify against one real CSD pair in quickstart before wiring the
> final encode. The picker + submit mechanism is fixed regardless.

**Alternatives considered**: Adding a dedicated multipart/HTTP helper — the
generated client already performs the multipart POST; only the byte→string
encode is ours.

## §9 — Taxpayer Certificates is a child section of the Taxpayer Issuer detail (not a standalone catalog)

**Decision** *(revised 2026-07-22)*: Certificates are managed **inside the
Taxpayer Issuer detail screen**, not as a standalone catalog. For an existing
issuer, the detail screen renders a **Certificates section** — a read-only child
table (certificate number, valid-from, valid-to, active status) scoped to the
open issuer's RFC — plus an **Agregar** (Add) action opening an **upload
sub-form/dialog** (`.cer` + `.key` + key password; the taxpayer RFC comes from
the parent issuer). No standalone list screen, no `/taxpayer-certificates`
route, no navigation destination. No per-certificate edit or delete affordance.
The section is absent on the issuer **create** form (a certificate needs a
persisted issuer to belong to).

**Rationale**: This matches the legacy "Razones Sociales" detail, whose
"Certificados" tab lists the issuer's certificates with an Agregar button. It
also fits the API exactly: `TaxpayerCertificatesApi` has **no** `update`/`delete`
(a CSD is immutable, superseded by uploading a newer one), and its `list` accepts
a `taxpayer` (RFC) filter — precisely a per-issuer child collection.
`TaxpayerCertificateResponse` carries `validFrom`/`validTo` populated server-side
from the certificate, so the upload form never requests them (FR-022).
**This is the resolution of the prior §VI tension**: because certificates are now
a delimited sub-section of the issuer form — like spec 014's facility
inline-address create dialog and the product-pricing sub-panel — the
"every catalog list row must expose Edit" rule (which governs *top-level catalog
list screens*) simply does not apply. There is no standalone certificates catalog
to be "Edit-less," so no §VI exception and no Complexity Tracking entry is needed.

**Structure**: the section is rendered below the issuer's own fields, delimited
by a Material 3 divider (§VI's group-delimiter guidance); the legacy uses a tab
("Certificados"), but with the sibling "Series y Folios" tab out of scope, a
single delimited section is cleaner than a one-tab `TabBar`. The upload uses the
shared `ResponsiveFormGrid` dialog pattern (spec 014 inline-address precedent).
The Agregar action follows the **same read-only flag** the issuer detail already
computes for its save/delete gating (`forceReadOnly || !canUpdate`) in addition to
`can(taxpayers, create)` — so a read-only/View render (row-click) never exposes a
data-mutating control, honoring §VI's row-click-is-read-only rule (FR-025).

**Consumed API**: `TaxpayerCertificateRepository.listForIssuer(rfc)` (wraps
`list(taxpayer: rfc)`) + `upload(taxpayer, certificate, key, keyPassword)`. No
standalone `get`/detail screen is needed (the row data is fully in the list
payload); `get` may remain unused on the repository.

**Alternatives considered**:
- *A standalone Taxpayer Certificates catalog* (the pre-2026-07-22 design) — rejected by the user: certificates belong to an issuer and the legacy UI nests them; a standalone Edit-less catalog also strained §VI.
- *A one-tab `TabBar`* — rejected: needless chrome for a single in-scope section; a divider-delimited section reads better.
- *Client-side edit/delete that no-op or call a nonexistent endpoint* — impossible and wrong; the absence is intentional.

## §10 — SAT regime / postal-code pickers reuse the existing `SatCatalogRepository`

**Decision**: The Issuer form's `regime` and `postalCode` pickers reuse the
existing `satCatalogRepositoryProvider` (`listTaxRegimes`, `listPostalCodes`)
exactly as the Taxpayer Recipient form already does — unchanged.

**Rationale**: `sat_catalog_repository.dart` already exposes `listTaxRegimes`
and `listPostalCodes` returning `SatCatalogListResult` of `SatCatalogItem`, and
`taxpayer_recipient_detail_screen.dart` already wires both into
`CatalogEntityPicker<SatCatalogItem>`. The Issuer form is the same wiring.

**Alternatives considered**: New SAT repositories — redundant.

## §11 — No N+1: every displayed reference is pre-expanded on the list response

**Decision**: No list or detail screen performs a per-row lookup.

**Rationale**: `PaymentMethodOptionResponse.facility`/`.warehouse` arrive as
`FacilitySummary`/`WarehouseSummary`; `TaxpayerIssuerResponse.regime`/`.postalCode`
arrive as `SatCatalogResponse`; `TaxpayerCertificateResponse.taxpayer` is the RFC
string (human-meaningful) and `validFrom`/`validTo`/`status` are inline. Each row
renders entirely from the list payload (FR-026, SC-006).

**Alternatives considered**: Resolving the issuer name for a certificate's RFC
via a per-row `get` — rejected as an N+1; the RFC is displayed directly, matching
spec 014's FR-034b allowance for RFC-on-list.

## §12 — Facility / warehouse pickers reuse spec-014 repositories

**Decision**: The Payment Method Option form's facility picker reuses
`facilityRepositoryProvider` (`FacilityListItem`), and its warehouse picker
reuses `warehouseRepositoryProvider`, both shipped by spec 014.

**Rationale**: These providers and their list-item projections already exist and
are already consumed by the Warehouse/Cash-Drawer/Point-of-Sale screens. The
warehouse picker here is a plain optional FK with no facility-scoping constraint
(§3), so it needs no new coupling logic.

**Alternatives considered**: New repositories — redundant.

## §13 — Extend the existing list-only `TaxpayerIssuerRepository` to full CRUD

**Decision**: Grow the existing `TaxpayerIssuerRepository` (today `list` +
`get`→`TaxpayerIssuerListItem`, backing spec-014's facility autocomplete) into
the catalog's full-CRUD repository: keep `list` (picker/autocomplete + catalog
list) and the lightweight lookup `get`, and add a full-detail `get`, `create`,
`update`, and `delete` returning/consuming a new `TaxpayerIssuer` detail entity.
The spec-014 facility-form autocomplete keeps working unchanged.

**Rationale**: One repository per entity (constitution §I/§II); the issuer
repository already exists but was intentionally list-only for spec 014. Extending
it — rather than adding a second issuer repository — keeps a single source of
truth. The list-item `get(rfc)` used by the facility form to resolve a stored RFC
to a name is preserved; the catalog's detail screen uses a new
`getDetail(rfc)`→`TaxpayerIssuer`. The interface change is additive, so spec 014's
consumers are unaffected.

**Alternatives considered**: A separate `TaxpayerIssuerCatalogRepository` — two
repositories for one entity, rejected as duplication.

## §14 — Navigation and router: two appended branches, NavBranch↔router invariant

**Decision** *(revised 2026-07-22)*: Append **two** `NavBranch` indices —
`paymentMethodOptions(18)` and `taxpayerIssuers(19)` — and two shell branches in
**the same order** in `nav_destinations.dart` and `app_router.dart`, then the
four flat detail sub-routes (`/payment-method-options/new` + `/:id`;
`/taxpayer-issuers/new` + `/:rfc`). Payment Method Options goes in the `catalogs`
group; Taxpayer Issuers in the `sales` group. **No** Taxpayer Certificates
branch, route, or destination — certificates live inside the issuer detail (§9).

**Rationale**: `NavBranch` currently ends at `facilities(17)`; the router branch
order is positional and must match (documented at `nav_destinations.dart` and
honored by specs 012/013/014). Payment Method Options follows the int-keyed shape
(`/new` + `int.parse(:id)` + `?view=true`); Taxpayer Issuers follows the
String-keyed (RFC) shape (`/taxpayer-issuers/:rfc`, no `int.parse`, editable only
in create mode — Taxpayer Recipient precedent).

**Alternatives considered**: Reordering existing branches to group fiscal items —
rejected: it would renumber shipped branches and break the invariant for no gain
(nav display order is already independent of branch index).

## §15 — Server-side search on the Payment Method Options list is a tracked dependency (not a deviation)

**Decision** *(revised 2026-07-22)*: Payment Method Options ships the **search
box present and wired** to an expected server-side `search` capability, activating
the moment mbe-api adds it — the identical resolution specs 013/014 used for their
search-less endpoints. File the upstream request (Payment Method Options list
`search`). Taxpayer Issuers already exposes `search`, so its box is fully
functional today. Taxpayer Certificates is **no longer a standalone catalog** (it
is a bounded per-issuer child section — §9), so the §VI search-box rule does not
apply to it and no `search` param is needed there.

**Rationale**: Constitution §VI is absolute — "A catalog MUST NOT ship
search-less, even if pagination alone could make it 'usable.'" Verified against
the generated client:
- `listPaymentMethodOptions` params: `facility`, `status`, `skip`, `limit` — **no `search`** (standalone catalog → search box wired to the pending param).
- `listTaxpayerIssuers` params: `search`, `skip`, `limit` — **has `search`**, no backend facets (`TaxpayerIssuerResponse` carries no `status`/type field to facet on, so search-only is the correct, compliant shape for it).
- `listTaxpayerCertificates` params: `taxpayer`, `status`, `skip`, `limit` — consumed only as a per-issuer child section via the `taxpayer` filter (§9); **not** a catalog list screen, so §VI's search rule is out of scope for it.

Specs 013 (§III) and 014 established that a missing list `search` is a **tracked
external dependency**, not a constitution deviation and not a client-side
filtering workaround: the box is built against the expected capability and the
gap is filed upstream. This feature applies that posture to the one remaining
facet-only standalone catalog (Payment Method Options), which also ships its real
backend facets (`facility`+`status`) in a filter drawer, so it is not a bare
search-only screen.

**Alternatives considered**:
- *Client-side filtering of the fetched page* — explicitly rejected by the 013/014 precedent (filters only the current page, misleading across pagination).
- *Omitting the search box until the backend ships `search`* — violates §VI; the box must be present by construction so the screen is compliant and lights up automatically.
- *Treating it as a §VI deviation requiring Complexity Tracking justification* — the established precedent classifies it as a tracked dependency, not a deviation, so no justification entry is needed.
