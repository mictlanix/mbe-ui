# Implementation Plan: Fiscal Catalogs (Payment Method Options, Taxpayer Issuers, Taxpayer Certificates)

**Branch**: `015-fiscal-catalogs` | **Date**: 2026-07-21 (revised 2026-07-22) | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/015-fiscal-catalogs/spec.md`

## Summary

Deliver UIs for three mbe-api fiscal entities the app does not consume today —
two standalone catalogs and one issuer-embedded section — each already backed by a
fully generated OpenAPI client:

1. **Payment Method Options** (Catálogos group) — **full CRUD**. A facility+
   warehouse+status-scoped catalog, structurally the spec-014 Warehouse catalog
   plus four scalar fields (`numberOfPayments`, `displayOnTicket`, `paymentMethod`,
   `commission`).
2. **Taxpayer Issuers** / "Razones Sociales (Emisores de Facturas)" (Ventas
   group) — **full CRUD keyed by RFC** (a String primary key, immutable on edit),
   structurally the shipped spec-012 **Taxpayer Recipient** catalog (also RFC-keyed,
   with SAT regime/postal-code pickers) minus `email`, plus `provider` and `comment`.
3. **Taxpayer Certificates** — **a child section of the Taxpayer Issuer detail**,
   not a standalone catalog (revised 2026-07-22). An existing issuer's detail
   renders a read-only Certificates section (certificate number, validity, active
   status) scoped to that issuer's RFC, plus an **Agregar** action opening a CSD
   (`.cer`/`.key`) multipart upload dialog; validity/number are server-derived. No
   edit, no delete, and **no** standalone screen/route/nav destination.

All work lands **inside the existing `lib/features/catalog/` module** (constitution
§I shared master-data module), extended per entity, exactly as specs 012/013/014
did. This is the follow-up spec 014's plan explicitly deferred.

Planning decisions that shape the work (full detail in [research.md](./research.md)):

1. **No codegen, no new dependency, no RBAC-mirror edit.** All three API clients
   are already generated and present (research §1); `paymentMethodOptions(84)` and
   `taxpayers(24)` already exist in `system_object.dart` (research §2) — unlike
   spec 014, there is **no** `system_object.dart` correction. `file_picker: ^8.1.2`
   already ships for the CSD upload (research §8).
2. **Payment Method Options is the Warehouse template** (facility picker, facility+
   status filter drawer) plus a second optional `warehouse` FK and four scalars
   (research §3). The warehouse FK is a plain optional picker — **no** point-of-sale
   facility↔warehouse coupling.
3. **Taxpayer Issuers is the Taxpayer Recipient template** — the RFC-as-identity,
   immutable-on-edit String key and the SAT regime/postal-code pickers already
   exist there verbatim (research §4). The existing list-only `TaxpayerIssuerRepository`
   (spec 014's facility autocomplete) is **extended** to full CRUD additively, so
   its current consumer keeps working (research §13).
4. **`paymentMethod` has no SAT endpoint** — it becomes a hand-named `PaymentMethod`
   labeled lookup in `core/domain/`, the `FacilityType`/`Gender` precedent, mirroring
   mbe-api's authoritative `PaymentMethod` constant (`mbe-api/docs/constants.md`;
   research §5).
5. **`FiscalCertificationProvider`** is a generated unnamed int enum → display-label
   map only, no replacement type (research §7).
6. **Taxpayer Certificates is a child section of the issuer detail** (revised
   2026-07-22) — not a standalone catalog. The issuer detail renders a read-only
   Certificates section scoped to the open issuer's RFC, plus an Agregar upload
   dialog; **no** standalone screen/route/nav, **no** edit/delete (research §9). This
   **resolves the earlier §VI Edit-row tension**: certificates are now a delimited
   sub-section (spec 014 inline-address / product-pricing sub-panel precedent), not
   a top-level catalog, so §VI's catalog-row rules do not apply. The upload picks two
   files via `file_picker`, encodes bytes to the string fields, and posts multipart
   (research §8; encoding confirmed in quickstart).
7. **Search on the one remaining facet-only standalone catalog is a tracked
   dependency** — Payment Method Options exposes facets but no `search`; it ships a
   search box wired to the expected upstream capability (spec-013/014 precedent),
   filed upstream, **not** a §VI deviation and **not** client-side filtering
   (research §15). Taxpayer Issuers `search` is functional today. Taxpayer
   Certificates, being a bounded per-issuer child section, needs no search box.

Consequently this feature modifies `app_router.dart`, `nav_destinations.dart`, and
the two `.arb` files; adds one shared-kernel lookup (`PaymentMethod`); and everything
else is new files under `lib/features/catalog/`. It does **not** touch
`system_object.dart`.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable matching
that SDK constraint — same as specs 011/012/013/014.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`,
`go_router`, `dio`, `freezed`/`freezed_annotation` + `json_serializable`, `intl`
(`es-MX`), `data_table_2`, and **`file_picker` (already present, `^8.1.2`)** for the
CSD upload. **No new dependency is introduced.**

**Storage**: N/A — no local database/cache (constitution §VII). All list/form state
is in-memory.

**Testing**: `flutter_test` for unit/widget, `mocktail` for repository fakes,
`integration_test` for the golden-path flows against a local mbe-api (quickstart.md).

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) tier,
Compact tier inherited from spec 010's adaptive shell.

**Project Type**: Single Flutter project, feature-first — **extends** the existing
`lib/features/catalog/` module (see Structure Decision).

**Performance Goals**: Each standalone list renders one paginated page (`skip`/`limit`,
default 20) per fetch. Every displayed FK is **pre-expanded** on the response
(`PaymentMethodOptionResponse.facility`/`.warehouse`, `TaxpayerIssuerResponse.regime`/
`.postalCode`; the certificate section's rows are the taxpayer-scoped list payload) —
**no N+1 per-row lookup** on any screen (research §11). Pickers debounce at 300 ms via
`CatalogEntityPicker`.

**Constraints**: Deny-by-default RBAC on `paymentMethodOptions(84)` (Payment Method
Options) and `taxpayers(24)` (Taxpayer Issuers + its embedded certificate section).
Client-side gating only, consistent with shipped catalogs; the server remains
authoritative and its rejections are surfaced. Free-text search is server-side where
available (Issuers today; Payment Method Options pending upstream, research §15).
CSD validity/number are server-derived and never user-entered (FR-022).

**Scale/Scope**: **2 standalone list screens** (Payment Method Options, Taxpayer
Issuers) + 2 detail screens + **1 certificate sub-section (with an upload dialog)**
embedded in the issuer detail; ~2 list controllers + 1 filter controller (Payment
Method Options: facility+status; Issuers: search-only) + 2 form controllers + 2
certificate sub-controllers (list-for-issuer section + upload dialog); 3 new/extended repositories
(PaymentMethodOption new, TaxpayerCertificate new [list-for-issuer + upload only],
TaxpayerIssuer **extended** from list-only to full CRUD) + reuse of Facility/Warehouse/
Sat repositories; 3 `freezed` entities (+ a certificate-upload input value) + 1 new
shared-kernel `PaymentMethod` lookup + 1 provider label map; **2 router branches + 4
sub-routes; 2 nav destinations**; **no** RBAC-mirror edit; ~75–85 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | Extends `lib/features/catalog/{data,domain,presentation}` one sub-tree per entity; `presentation` imports only `domain`; `data` implements `domain` repository interfaces. The one new lookup (`PaymentMethod`) is shared-kernel (`core/domain/`), like `FacilityType`. |
| II. Riverpod for State & DI | ✅ PASS | Each entity gets `Notifier`-based list + form controllers exposing `AsyncValue`; Payment Method Options adds a filter `Notifier`; the issuer form hosts a certificate sub-controller (list + upload) exposing `AsyncValue`; all three repositories exposed as providers for test overrides. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes the already-generated `PaymentMethodOptions`/`TaxpayerIssuers`/`TaxpayerCertificates` APIs; **no hand-written DTOs**, generated files not edited. Errors map via `ErrorBanner`. The one missing list `search` param (Payment Method Options) is filed upstream as a tracked dependency per §III/precedent (research §15) — zero *blocking* dependency. |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(...)`; both objects pre-exist (no mirror edit). Routes gated via `_routeGate`, nav via `navDestinationsProvider`, actions **hidden** (not disabled) without privilege. The certificate section's Agregar (upload) is gated on `taxpayers` create **and** the issuer detail's read-only flag (`can(taxpayers,create) && !readOnly`) so a row-click/View render never exposes it, even to a create-privileged user (FR-025, §VI row-click-is-read-only); it exposes no update/delete to gate. |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming. Status via existing `EntityStatusCell`/`EntityStatusControls`/`EntityStatusFilterChips`; certificate validity dates via the shared date formatting. All new strings in both `.arb` files; no manual/hard-coded strings. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS (with tracked search dependency) | The two standalone lists reuse `DataTableView`, `CatalogPagination`, `CatalogFilterBar`/`CatalogSearchBar`; Payment Method Options adds a `CatalogFilterSheet` drawer (facility+status facets); Issuers is search-only (no backend facets). Single Edit row action via `catalog_action_icons`; row-click → read-only view; toolbar `FilledButton` Create; delete-in-form-body. Detail forms and the certificate upload dialog use `ResponsiveFormGrid`. **Certificates is a delimited sub-section of the issuer detail** (divider-delimited group per §VI's group guidance), not a top-level catalog — so §VI's catalog-list-row Edit rule does not apply to it (research §9). Payment Method Options' search box is wired to an expected upstream `search` (research §15) — a tracked dependency, not a deviation. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence, no caching. The CSD upload sends file bytes to the server; nothing is stored client-side and no document is generated locally. |

**On §VI and the certificate section (resolves the earlier Edit-row concern)**:
Taxpayer Certificates is **not** a standalone catalog list screen — it is a
divider-delimited child section of the Taxpayer Issuer detail (research §9), the
same shape as spec 014's facility inline-address sub-form and the product-pricing
sub-panel. §VI's "every catalog/list screen's row MUST expose Edit" rule governs
*top-level catalog screens*; a read-only child collection inside a detail form is
not one, so there is no §VI exception to justify and **no Complexity Tracking entry
is needed**. Certificates genuinely cannot be edited/deleted anyway
(`TaxpayerCertificatesApi` has no such method — a CSD is immutable, superseded by
uploading a newer one).

**On §VI and search**: see research §15 — Payment Method Options (the one facet-only
standalone catalog) follows the spec-013/014 tracked-dependency posture (search box
present and wired, gap filed upstream), explicitly classified there as **not** a
constitution deviation. No Complexity Tracking entry is required.

**Post-Phase 1 re-check**: ✅ still passing. Phase 1 introduced no new dependency, no
generated-file edits, no local persistence, and no `system_object.dart` change; the
one new shared-kernel lookup (`PaymentMethod`) follows the `FacilityType`/`Gender`
precedent, and moving certificates into the issuer detail as a sub-section (2026-07-22)
removed the only §VI question the earlier design raised — no exception remains to log.

## Project Structure

### Documentation (this feature)

```text
specs/015-fiscal-catalogs/
├── plan.md                       # This file
├── spec.md                       # Feature spec
├── research.md                   # Phase 0 output (§1–§15)
├── data-model.md                 # Phase 1 output
├── quickstart.md                 # Phase 1 output
├── contracts/                    # Phase 1 output
│   ├── mbe-api-catalogs.md        # endpoint/DTO contract per entity
│   └── routes.md                  # routes, nav, RBAC gating, NavBranch invariant
├── checklists/
│   └── requirements.md           # spec quality checklist (created by /speckit-specify)
└── tasks.md                      # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── router/
│       └── app_router.dart              # MODIFIED: 2 shell branches + 4 sub-routes + 2 _routeGate entries (NO cert route)
├── core/
│   ├── navigation/
│   │   └── nav_destinations.dart        # MODIFIED: 2 NavDestinations + 2 NavBranch indices (18/19; order MUST match router)
│   └── domain/
│       └── payment_method.dart            # NEW: PaymentMethod labeled lookup (mirrors mbe-api constants.md) — hand-named, FacilityType/Gender pattern
│   # NOTE: system_object.dart is NOT modified — both RBAC objects already exist.
├── l10n/
│   └── app_*.arb                        # MODIFIED: nav titles, column headers, field labels, validation, empty states, provider/payment-method labels
└── features/
    └── catalog/                         # EXTENDED (existing module)
        ├── data/
        │   ├── payment_method_option_repository_impl.dart   # NEW: wraps PaymentMethodOptionsApi
        │   ├── taxpayer_certificate_repository_impl.dart    # NEW: wraps TaxpayerCertificatesApi (list-for-issuer + upload only)
        │   └── taxpayer_issuer_repository_impl.dart         # MODIFIED: extend list-only → full CRUD
        ├── domain/
        │   ├── entities/
        │   │   ├── payment_method_option.dart               # NEW (list rows reuse detail entity)
        │   │   ├── taxpayer_issuer.dart                     # NEW detail entity (list_item retained for pickers)
        │   │   └── taxpayer_certificate.dart                # NEW (+ a small certificate-upload input value)
        │   └── repositories/
        │       ├── payment_method_option_repository.dart    # NEW
        │       ├── taxpayer_certificate_repository.dart      # NEW (listForIssuer + upload; no update/delete/standalone screen)
        │       └── taxpayer_issuer_repository.dart           # MODIFIED: add getDetail/create/update/delete
        └── presentation/
            ├── payment_method_options_list_screen.dart + _list_controller.dart (+ filter controller)
            ├── payment_method_option_detail_screen.dart + _form_controller.dart
            ├── taxpayer_issuers_list_screen.dart + _list_controller.dart          # search-only, no filter controller
            ├── taxpayer_issuer_detail_screen.dart + _form_controller.dart         # HOSTS the certificate section (existing-issuer only)
            ├── taxpayer_certificates_section.dart + _certificates_controller.dart # NEW: read-only child list of the open issuer's certs
            └── taxpayer_certificate_upload_dialog.dart + _upload_controller.dart  # NEW: Agregar upload dialog (file pickers), not a route

lib/generated/openapi/                   # UNCHANGED — consumed, not edited

test/
├── unit/features/catalog/               # mapping (FK/SAT expansion, PaymentMethod round-trip, provider label), validators, cert-upload encode
├── widget/features/catalog/             # 2 standalone screens (list+detail each) + the issuer detail's certificate section & upload dialog: read-only vs editable, filters, empty states, RBAC hiding, cert no-edit/no-delete & section-absent-on-create
└── integration/fiscal_catalogs_flow_test.dart  # create issuer → add its certificate from the issuer detail → create a payment method option
```

**Structure Decision**: **Extend the existing `lib/features/catalog/` module**,
identical to specs 012/013/014 and for the same reason: constitution §I designates
`catalog` as the shared master-data module, and Payment Method Options / Taxpayer
Issuers (with its embedded certificates) are master-data catalogs of exactly that
kind. The feature modifies `app_router.dart`, `nav_destinations.dart`, and the `.arb`
files; adds one `core/domain/` lookup; and reuses `core/network`, `core/errors`,
`core/access`, and every `core/widgets/` component (`CatalogEntityPicker`,
`CatalogFilterSheet`, `EntityStatusControls`, `ResponsiveFormGrid`,
`catalog_action_icons`, `DataTableView`, `CatalogPagination`) unmodified, plus the
spec-014 Facility/Warehouse repositories, the SAT-catalog repository, and the
inline-dialog pattern (facility inline-address create) for the certificate upload.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **`paymentMethod` has no SAT endpoint and no generated enum** — its member set must be hand-listed. | The payment-method dropdown could show wrong/incomplete labels. | **Resolved** — mirror mbe-api's authoritative `PaymentMethod` constant (`mbe-api/docs/constants.md`; research §5 table: `0 NA` default … `1001 GovernmentFunding`). Model as a `PaymentMethod` `{code:(name,label)}` lookup (`FacilityType`/`Gender` precedent); non-contiguous codes → explicit map; unmapped codes fall back to the raw value. Unit-tested round-trip. |
| **CSD file byte→string encoding for the multipart upload is unspecified** (`certificate`/`key` are `String` "DER encoded"). | A valid CSD pair could be rejected if the encoding is wrong. | Default to base64-of-DER (research §8); confirm against one real CSD test pair in quickstart before finalizing; the pick+submit flow is unaffected by the encoding choice. |
| **Missing list `search` on Payment Method Options** | Search box present but inert until upstream ships it. | Wire the box to the expected `search` param (spec-013/014 precedent, research §15); file the upstream request; never fall back to client-side page filtering. (Certificates no longer a standalone list — no search box needed.) |
| **Extending the shared `TaxpayerIssuerRepository`** (spec 014's facility autocomplete consumes it) | A signature change could break the facility form. | The extension is **additive** (keep `list` + lightweight `get`; add `getDetail`/`create`/`update`/`delete`); a repo-wide grep for existing issuer-repo consumers gates the edit (research §13). |
| **Certificate section must not render on the issuer create form** | A certificate needs a persisted issuer (RFC) to belong to; showing it pre-save would let a user attempt an orphan upload. | Gate the section on `_isEdit` (issuer persisted) exactly as the RFC-immutability check does; widget-tested that create-mode omits the section (FR-025, Acceptance Scenario 2). |
| **NavBranch indices drift from router branch order** | Wrong nav item highlighted | Append the **two** branches in the same order (18/19) in both `nav_destinations.dart` and `app_router.dart`; invariant documented at `nav_destinations.dart` and honored by specs 012/013/014 (contracts/routes.md). |
| **RFC immutability regressions** | A saved edit could change identity or 404 | The RFC field is create-only (`enabled && !_isEdit`, recipient precedent); update posts the RFC only as the path param, never in the body (contracts §2). Widget-tested. |
| **Certificate section accidentally exposes edit/delete** | A user could trigger a nonexistent endpoint | The section is a read-only child table with no per-row action; the repository has no update/delete methods to call. Widget-tested for their absence. |

## Follow-ups (not blocking)

- **Upstream (tracked)**: add `search` to the Payment Method Options list endpoint
  (research §15); the search box lights up automatically.
- **Confirm at implementation**: the CSD string encoding (research §8) —
  mechanism-fixed, one value pending. *(The `paymentMethod` member set is confirmed
  against mbe-api's `PaymentMethod` constant — research §5.)*
- **Possible upstream nicety**: expanding `TaxpayerCertificateResponse.taxpayer` to
  the issuer object — not needed here — the certificate section is already scoped to
  a single issuer, so the RFC is implied (research §9, §11).

## Complexity Tracking

*No constitution violations — this section is intentionally empty.* The §VI notes
are scope clarifications with precedent from specs 012/013/014, not deviations:
(a) Taxpayer Certificates is a divider-delimited **child section** of the issuer
detail (spec-014 inline-address / product-pricing sub-panel precedent), not a
top-level catalog, so §VI's catalog-row Edit rule does not apply — the earlier
Edit-row concern is dissolved, not justified; (b) Payment Method Options' tracked
search dependency follows the spec-013/014 posture. The one new shared-kernel lookup
(`PaymentMethod`) follows the existing `FacilityType`/`Gender` precedent and is
mandated by a generated contract that hands over a bare `int` with no picker, not
optional complexity.
