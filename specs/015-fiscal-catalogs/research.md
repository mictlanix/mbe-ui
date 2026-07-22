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

## §5 — `paymentMethod` has no SAT catalog endpoint: use a static SAT `c_FormaPago` lookup

**Decision**: Represent `paymentMethod` as a **dropdown backed by a small,
hand-named static lookup** — integer code → human label — following the exact
`FacilityType`/`Gender` precedent (a fixed list the generator hands over as a
bare `int`). The lookup lives as a shared-kernel value in `core/domain/`
(`payment_form.dart`) with the **confirmed** mbe legacy `PaymentMethod` members
(code → es-MX label), default `0` (N/A):

| Code | Label | Code | Label |
|---|---|---|---|
| 0 | N/A *(default)* | 27 | A Satisfacción Del Acreedor |
| 1 | Efectivo | 28 | T. de Débito |
| 2 | Cheque | 29 | Tarjeta de Servicio |
| 3 | Transferencia Electrónica | 30 | Aplicación de Anticipos |
| 4 | T. de Crédito | 99 | Por Definir |
| 5 | Monedero Electrónico | 1001 | FONACOT |
| 6 | Dinero Electrónico | | |
| 8 | Vales de Despensa | | |
| 12 | Dación | | |

**Rationale**: `PaymentMethodOptionCreate.paymentMethod` is a required bare `int`
with **no** generated enum and **no** SAT endpoint to pick from. The SAT catalog
API (`SatCatalogsApi`) exposes only CfdiUsages, Countries, Currencies,
PostalCodes, ProductServices, ReasonCancellations, TaxRegimes, and
UnitsOfMeasurement — there is **no** payment-forms list. Spec 013 characterized
this field as "the `paymentMethod` SAT enum" (013 contracts/mbe-api-catalogs.md),
but it is actually mbe's **legacy internal `PaymentMethod` enum** (a superset of
SAT `c_FormaPago` — e.g. `1001 FONACOT` is not a SAT code), whose members are the
table above, sourced from the legacy web app's `PaymentMethod` select. Because it
is a small, stable, non-contiguous list (gaps at 7, 9–11, 13–26, etc.), a
hand-named lookup — the established pattern for a generator-unnamed fixed enum —
is the right fit; a live picker is impossible without an endpoint.

**Implementation notes**: the codes are **non-contiguous**, so the lookup is an
explicit `{code: label}` map (not an ordinal-indexed list); the dropdown lists
them in the table's order; an unmapped code (should the backend widen the set)
falls back to rendering its raw value rather than dropping the record. `0` (N/A)
is the default selection on the create form, matching the legacy default. The
labels are already es-MX; the `.arb` keys carry them (and their future
translations) so nothing is hard-coded (FR-029).

The `1001 FONACOT` entry MUST be annotated with a `// FIXME(payment-form):`
comment in the `PaymentForm` map (and a matching note beside its `.arb` label
key) marking it as provisional / easily removable — it is the one member whose
inclusion is uncertain, so it is isolated on its own line so a later deletion is
a one-line change that touches nothing else.

**Alternatives considered**:
- *Plain integer text field* — rejected: leaks a raw SAT code to the user, no validation, poor UX, inconsistent with every other coded field in the app (all of which resolve to a label).
- *Requesting a SAT `c_FormaPago` endpoint upstream* — heavier than warranted for a fixed ~20-entry government list; noted as a possible future nicety, not a blocker.

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

## §9 — Taxpayer Certificates is upload-plus-read-only (no edit, no delete)

**Decision**: The Taxpayer Certificates catalog exposes a list, a read-only
detail view, and an upload (create) form only. No edit affordance, no delete
affordance anywhere. The detail screen shows the server-derived
`taxpayerCertificateId`, `taxpayer` (RFC), `validFrom`, `validTo`, `status`
read-only; the create form collects only issuer + two files + password.

**Rationale**: `TaxpayerCertificatesApi` has no `update` and no `delete` method —
a CSD is an immutable government artifact, superseded by uploading a newer one,
never edited (spec Clarifications). `TaxpayerCertificateResponse` carries
`validFrom`/`validTo` populated server-side from the certificate, so the form
never requests them (FR-022). This departs from the standard catalog detail
(which offers edit + delete) but is dictated by the entity's real API surface,
not a constitution deviation.

**Alternatives considered**: Adding client-side edit/delete that no-op or call a
nonexistent endpoint — impossible and wrong; the absence is intentional.

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

## §14 — Navigation and router: three appended branches, NavBranch↔router invariant

**Decision**: Append three `NavBranch` indices — `paymentMethodOptions(18)`,
`taxpayerIssuers(19)`, `taxpayerCertificates(20)` — and three shell branches in
**the same order** in `nav_destinations.dart` and `app_router.dart`, then the
six flat detail sub-routes. Payment Method Options is placed in the `catalogs`
group; Taxpayer Issuers and Taxpayer Certificates in the `sales` group.

**Rationale**: `NavBranch` currently ends at `facilities(17)`; the router branch
order is positional and must match (documented at `nav_destinations.dart` and
honored by specs 012/013/014). Certificates has no `/new` int route — its create
path is `/taxpayer-certificates/new` (the upload form) and its detail is
`/taxpayer-certificates/:taxpayerCertificateId` (String id, read-only), with no
edit route target.

**Alternatives considered**: Reordering existing branches to group fiscal items —
rejected: it would renumber shipped branches and break the invariant for no gain
(nav display order is already independent of branch index).

## §15 — Server-side search on the two facet-only list endpoints is a tracked dependency (not a deviation)

**Decision**: Payment Method Options and Taxpayer Certificates ship the **search
box present and wired** to an expected server-side `search` capability, activating
the moment mbe-api adds it — the identical resolution specs 013/014 used for their
search-less endpoints. File the upstream requests (Payment Method Options list
`search`; Taxpayer Certificates list `search`). Taxpayer Issuers already exposes
`search`, so its box is fully functional today.

**Rationale**: Constitution §VI is absolute — "A catalog MUST NOT ship
search-less, even if pagination alone could make it 'usable.'" Verified against
the generated client:
- `listPaymentMethodOptions` params: `facility`, `status`, `skip`, `limit` — **no `search`**.
- `listTaxpayerCertificates` params: `taxpayer`, `status`, `skip`, `limit` — **no `search`**.
- `listTaxpayerIssuers` params: `search`, `skip`, `limit` — **has `search`**, no backend facets (`TaxpayerIssuerResponse` carries no `status`/type field to facet on, so search-only is the correct, compliant shape for it).

Specs 013 (§III) and 014 established that a missing list `search` is a **tracked
external dependency**, not a constitution deviation and not a client-side
filtering workaround: the box is built against the expected capability and the
gap is filed upstream. This feature applies the same posture to the two
facet-only endpoints. Both already ship their real backend facets
(`facility`+`status`; `taxpayer`+`status`) in a filter drawer, so neither is a
bare search-only screen.

**Alternatives considered**:
- *Client-side filtering of the fetched page* — explicitly rejected by the 013/014 precedent (filters only the current page, misleading across pagination).
- *Omitting the search box until the backend ships `search`* — violates §VI; the box must be present by construction so the screen is compliant and lights up automatically.
- *Treating it as a §VI deviation requiring Complexity Tracking justification* — the established precedent classifies it as a tracked dependency, not a deviation, so no justification entry is needed.
