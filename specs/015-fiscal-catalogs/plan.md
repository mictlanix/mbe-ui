# Implementation Plan: Fiscal Catalogs (Payment Method Options, Taxpayer Issuers, Taxpayer Certificates)

**Branch**: `015-fiscal-catalogs` | **Date**: 2026-07-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/015-fiscal-catalogs/spec.md`

## Summary

Deliver three catalog UIs for mbe-api fiscal entities the app does not consume
today, each already backed by a fully generated OpenAPI client:

1. **Payment Method Options** (Catálogos group) — **full CRUD**. A facility+
   warehouse+status-scoped catalog, structurally the spec-014 Warehouse catalog
   plus four scalar fields (`numberOfPayments`, `displayOnTicket`, `paymentMethod`,
   `commission`).
2. **Taxpayer Issuers** / "Razones Sociales (Emisores de Facturas)" (Ventas
   group) — **full CRUD keyed by RFC** (a String primary key, immutable on edit),
   structurally the shipped spec-012 **Taxpayer Recipient** catalog (also RFC-keyed,
   with SAT regime/postal-code pickers) minus `email`, plus `provider` and `comment`.
3. **Taxpayer Certificates** (Ventas group) — **partial: list + read-only view +
   upload only** (no edit, no delete). A CSD (`.cer`/`.key`) multipart upload whose
   validity window and number are server-derived.

All work lands **inside the existing `lib/features/catalog/` module** (constitution
§I shared master-data module), extended one sub-tree per entity, exactly as specs
012/013/014 did. This is the follow-up spec 014's plan explicitly deferred.

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
4. **`paymentMethod` has no SAT endpoint** — it becomes a hand-named `PaymentForm`
   (`c_FormaPago`) labeled lookup in `core/domain/`, the `FacilityType`/`Gender`
   precedent; the member set is confirmed at implementation (research §5, Risks).
5. **`FiscalCertificationProvider`** is a generated unnamed int enum → display-label
   map only, no replacement type (research §7).
6. **Taxpayer Certificates is upload-plus-read-only** — the API has no update/delete;
   the detail screen is always read-only with no edit toggle and no delete action,
   and the "create" route is the upload form (research §9). The upload picks two
   files via `file_picker`, encodes bytes to the string fields, and posts multipart
   (research §8; encoding confirmed in quickstart).
7. **Search on two facet-only endpoints is a tracked dependency** — Payment Method
   Options and Taxpayer Certificates lists expose facets but no `search`; each ships
   a search box wired to the expected upstream capability (spec-013/014 precedent),
   filed upstream, **not** a §VI deviation and **not** client-side filtering
   (research §15). Taxpayer Issuers `search` is functional today.

Consequently this feature modifies `app_router.dart`, `nav_destinations.dart`, and
the two `.arb` files; adds one shared-kernel lookup (`PaymentForm`); and everything
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

**Performance Goals**: Each list renders one paginated page (`skip`/`limit`, default 20)
per fetch. Every displayed FK is **pre-expanded** on the response
(`PaymentMethodOptionResponse.facility`/`.warehouse`, `TaxpayerIssuerResponse.regime`/
`.postalCode`; the certificate's taxpayer is a displayed RFC) — **no N+1 per-row lookup**
on any screen (research §11). Pickers debounce at 300 ms via `CatalogEntityPicker`.

**Constraints**: Deny-by-default RBAC on `paymentMethodOptions(84)` (Payment Method
Options) and `taxpayers(24)` (both Taxpayer catalogs). Client-side gating only,
consistent with shipped catalogs; the server remains authoritative and its
rejections are surfaced. Free-text search is server-side where available
(Issuers today; Payment Method Options + Certificates pending upstream, research §15).
CSD validity/number are server-derived and never user-entered (FR-022).

**Scale/Scope**: 3 list screens + 3 detail/upload screens = **6 screens**; ~3 list
controllers + 2 filter controllers (Payment Method Options: facility+status;
Certificates: taxpayer+status; Issuers: search-only, no filter controller) + 3 form/
upload controllers; 3 new repositories (PaymentMethodOption new, TaxpayerCertificate
new, TaxpayerIssuer **extended** from list-only to full CRUD) + reuse of Facility/
Warehouse/Sat repositories; 3 `freezed` detail entities (+ a certificate-upload input
value) + 1 new shared-kernel `PaymentForm` lookup + 1 provider label map; 3 router
branches + 6 sub-routes; 3 nav destinations; **no** RBAC-mirror edit; ~80–90 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | Extends `lib/features/catalog/{data,domain,presentation}` one sub-tree per entity; `presentation` imports only `domain`; `data` implements `domain` repository interfaces. The one new lookup (`PaymentForm`) is shared-kernel (`core/domain/`), like `FacilityType`. |
| II. Riverpod for State & DI | ✅ PASS | Each entity gets `Notifier`-based list + form/upload controllers exposing `AsyncValue`; Payment Method Options and Certificates add a filter `Notifier`; all three repositories exposed as providers for test overrides. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes the already-generated `PaymentMethodOptions`/`TaxpayerIssuers`/`TaxpayerCertificates` APIs; **no hand-written DTOs**, generated files not edited. Errors map via `ErrorBanner`. The two missing list `search` params are filed upstream as tracked dependencies per §III/precedent (research §15) — zero *blocking* dependency. |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(...)`; both objects pre-exist (no mirror edit). Routes gated via `_routeGate`, nav via `navDestinationsProvider`, actions **hidden** (not disabled) without privilege. Certificates exposes only a create/upload action (no update/delete to gate). |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming. Status via existing `EntityStatusCell`/`EntityStatusControls`/`EntityStatusFilterChips`; dates on the certificate detail via the shared date formatting. All new strings in both `.arb` files; no manual/hard-coded strings. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS (with tracked search dependency) | All three lists reuse `DataTableView`, `CatalogPagination`, `CatalogFilterBar`/`CatalogSearchBar`; Payment Method Options + Certificates add a `CatalogFilterSheet` drawer (real backend facets); Issuers is search-only (no backend facets). Single Edit row action via `catalog_action_icons`; row-click → read-only view; toolbar `FilledButton` Create; delete-in-form-body. Detail/upload forms use `ResponsiveFormGrid`. **Certificates deliberately has no Edit/Delete row or detail action** — the entity's API has neither (research §9). The two facet-only lists' search boxes are wired to an expected upstream `search` (research §15) — a tracked dependency, not a deviation. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence, no caching. The CSD upload sends file bytes to the server; nothing is stored client-side and no document is generated locally. |

**On §VI and the Certificates read-only exception**: the standard catalog detail
offers Edit + Delete; Taxpayer Certificates offers neither because
`TaxpayerCertificatesApi` has no update and no delete method (research §9) — a CSD is
an immutable government artifact, superseded by uploading a newer one. This is
dictated by the entity's real API surface, not a layout choice, and is therefore not
a §VI deviation. The read-only detail carries no read-only→edit toggle in
`AppBar.actions` precisely because there is no editable form to switch to.

**On §VI and search**: see research §15 — the two facet-only endpoints follow the
spec-013/014 tracked-dependency posture (search box present and wired, gap filed
upstream), explicitly classified there as **not** a constitution deviation. No
Complexity Tracking entry is required.

**Post-Phase 1 re-check**: ✅ still passing. Phase 1 introduced no new dependency, no
generated-file edits, no local persistence, and no `system_object.dart` change; the
one new shared-kernel lookup (`PaymentForm`) follows the `FacilityType`/`Gender`
precedent, and the certificate read-only exception is API-mandated.

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
│       └── app_router.dart              # MODIFIED: 3 shell branches + 6 sub-routes + 3 _routeGate entries
├── core/
│   ├── navigation/
│   │   └── nav_destinations.dart        # MODIFIED: 3 NavDestinations + 3 NavBranch indices (order MUST match router)
│   └── domain/
│       └── payment_form.dart            # NEW: SAT c_FormaPago labeled lookup — hand-named, FacilityType/Gender pattern
│   # NOTE: system_object.dart is NOT modified — both RBAC objects already exist.
├── l10n/
│   └── app_*.arb                        # MODIFIED: nav titles, column headers, field labels, validation, empty states, provider/payment-form labels
└── features/
    └── catalog/                         # EXTENDED (existing module)
        ├── data/
        │   ├── payment_method_option_repository_impl.dart   # NEW: wraps PaymentMethodOptionsApi
        │   ├── taxpayer_certificate_repository_impl.dart    # NEW: wraps TaxpayerCertificatesApi (list/get/upload)
        │   └── taxpayer_issuer_repository_impl.dart         # MODIFIED: extend list-only → full CRUD
        ├── domain/
        │   ├── entities/
        │   │   ├── payment_method_option.dart               # NEW (list rows reuse detail entity)
        │   │   ├── taxpayer_issuer.dart                     # NEW detail entity (list_item retained for pickers)
        │   │   └── taxpayer_certificate.dart                # NEW (+ a small certificate-upload input value)
        │   └── repositories/
        │       ├── payment_method_option_repository.dart    # NEW
        │       ├── taxpayer_certificate_repository.dart      # NEW (no update/delete)
        │       └── taxpayer_issuer_repository.dart           # MODIFIED: add getDetail/create/update/delete
        └── presentation/
            ├── payment_method_options_list_screen.dart + _list_controller.dart (+ filter controller)
            ├── payment_method_option_detail_screen.dart + _form_controller.dart
            ├── taxpayer_issuers_list_screen.dart + _list_controller.dart          # search-only, no filter controller
            ├── taxpayer_issuer_detail_screen.dart + _form_controller.dart
            ├── taxpayer_certificates_list_screen.dart + _list_controller.dart (+ filter controller)
            ├── taxpayer_certificate_detail_screen.dart                            # read-only view
            └── taxpayer_certificate_upload_screen.dart + _upload_controller.dart  # create/upload (file pickers)

lib/generated/openapi/                   # UNCHANGED — consumed, not edited

test/
├── unit/features/catalog/               # mapping (FK/SAT expansion, PaymentForm round-trip, provider label), validators, cert-upload encode
├── widget/features/catalog/             # 6 screens: read-only vs editable, filters, empty states, RBAC hiding, cert form validation & no-edit/no-delete
└── integration/fiscal_catalogs_flow_test.dart  # create issuer → upload its certificate → create a payment method option
```

**Structure Decision**: **Extend the existing `lib/features/catalog/` module**,
identical to specs 012/013/014 and for the same reason: constitution §I designates
`catalog` as the shared master-data module, and Payment Method Options / Taxpayer
Issuers / Taxpayer Certificates are master-data catalogs of exactly that kind. The
feature modifies `app_router.dart`, `nav_destinations.dart`, and the `.arb` files;
adds one `core/domain/` lookup; and reuses `core/network`, `core/errors`,
`core/access`, and every `core/widgets/` component (`CatalogEntityPicker`,
`CatalogFilterSheet`, `EntityStatusControls`, `ResponsiveFormGrid`,
`catalog_action_icons`, `DataTableView`, `CatalogPagination`) unmodified, plus the
spec-014 Facility/Warehouse repositories and the SAT-catalog repository.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **`paymentMethod` has no SAT endpoint and no generated enum** — its member set must be hand-listed. | The payment-form dropdown could show wrong/incomplete labels. | **Resolved** — the mbe legacy `PaymentMethod` member set + es-MX labels are confirmed (research §5 table: 0 N/A default … 1001 FONACOT). Model as a `PaymentForm` `{code:label}` lookup (`FacilityType`/`Gender` precedent); non-contiguous codes → explicit map; unmapped codes fall back to the raw value. Unit-tested round-trip. |
| **CSD file byte→string encoding for the multipart upload is unspecified** (`certificate`/`key` are `String` "DER encoded"). | A valid CSD pair could be rejected if the encoding is wrong. | Default to base64-of-DER (research §8); confirm against one real CSD test pair in quickstart before finalizing; the pick+submit flow is unaffected by the encoding choice. |
| **Missing list `search` on Payment Method Options & Certificates** | Search box present but inert until upstream ships it. | Wire the box to the expected `search` param (spec-013/014 precedent, research §15); file the upstream requests; never fall back to client-side page filtering. |
| **Extending the shared `TaxpayerIssuerRepository`** (spec 014's facility autocomplete consumes it) | A signature change could break the facility form. | The extension is **additive** (keep `list` + lightweight `get`; add `getDetail`/`create`/`update`/`delete`); a repo-wide grep for existing issuer-repo consumers gates the edit (research §13). |
| **NavBranch indices drift from router branch order** | Wrong nav item highlighted | Append the three branches in the same order (18/19/20) in both `nav_destinations.dart` and `app_router.dart`; invariant documented at `nav_destinations.dart` and honored by specs 012/013/014 (contracts/routes.md). |
| **RFC immutability regressions** | A saved edit could change identity or 404 | The RFC field is create-only (`enabled && !_isEdit`, recipient precedent); update posts the RFC only as the path param, never in the body (contracts §2). Widget-tested. |
| **Certificate detail accidentally exposes edit/delete** | A user could trigger a nonexistent endpoint | The detail screen is a distinct read-only widget with no toggle and no delete button; the repository has no update/delete methods to call. Widget-tested for their absence. |

## Follow-ups (not blocking)

- **Upstream (tracked)**: add `search` to the Payment Method Options and Taxpayer
  Certificates list endpoints (research §15); the search boxes light up automatically.
- **Confirm at implementation**: the CSD string encoding (research §8) —
  mechanism-fixed, one value pending. *(The `paymentMethod` member set is now
  confirmed — research §5.)*
- **Possible upstream nicety**: expanding `TaxpayerCertificateResponse.taxpayer` to
  the issuer object (as facility's address/location already are) would let the
  certificate list show the issuer name; not needed here — the RFC is displayed
  directly (FR-026, spec-014 FR-034b precedent).

## Complexity Tracking

*No constitution violations — this section is intentionally empty.* The §VI notes
(Certificates' API-mandated read-only detail; the two facet-only lists' tracked
search dependency) are scope clarifications with precedent from specs 013/014, not
deviations. The one new shared-kernel lookup (`PaymentForm`) follows the existing
`FacilityType`/`Gender` precedent and is mandated by a generated contract that hands
over a bare `int` with no picker, not optional complexity.
