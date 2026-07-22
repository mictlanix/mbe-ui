# Feature Specification: Fiscal Catalogs (Payment Method Options, Taxpayer Issuers, Taxpayer Certificates)

**Feature Branch**: `015-fiscal-catalogs`

**Created**: 2026-07-21

**Status**: Draft

**Input**: User description: "Let's create a spec to implement the following cruds: PaymentMethodOptions (on catalogsGroupTitle), TaxpayersIssuers (on salesGroupTitle), TaxpayerCertificates (on salesGroupTitle)."

## Clarifications

### Session 2026-07-21

- Q: Spec 014 explicitly deferred a standalone Taxpayer Issuers catalog and its CSD certificates as a follow-up. Is this that follow-up? → A: **Yes.** Spec 014 reached taxpayer issuers only as a read-only autocomplete inside the facility form (FR-034a) and named a dedicated Taxpayer Issuers catalog plus its `TaxpayerCertificatesApi` as a clean follow-up. This feature is that follow-up, and adds Payment Method Options alongside them.
- Q: The Taxpayer Certificates API exposes only list, get, and a multipart upload — no update and no delete. Is that a gap to file upstream, or the intended shape? → A: **Intended.** A CSD (Certificado de Sello Digital) is an immutable, government-issued artifact; it is registered (uploaded) and later superseded by uploading a newer one, never edited. The certificate number and validity window are read from the certificate file itself server-side, not entered. So this catalog is deliberately upload-plus-read-only: no edit form, no delete action. This is not a constitution deviation to be worked around — it is the entity's real lifecycle.
- Q: The certificate upload posts two binary files (`.cer` and `.key`) plus a key password. No prior catalog uploads binaries except spec 004 (product images). What is the file-selection approach and is a new dependency needed? → A: **No new dependency.** `file_picker: ^8.1.2` already ships in `pubspec.yaml`. The upload form uses two file pickers (one per file) restricted to the expected extensions, reads the bytes, and submits them with the password over the generated multipart client. No image-cropping/preview concerns apply (these are not images).
- Q: A Taxpayer Issuer's primary key is its RFC (a string), unlike the integer-keyed catalogs shipped so far. How does that affect create/edit? → A: The RFC **is** the identity: it is entered by the user on create, is the path parameter for get/update/delete, and is **immutable once created** (changing it means creating a different issuer). The edit form therefore shows the RFC read-only. This mirrors how the SAT identifies a taxpayer and matches the legacy "Razones Sociales" screen.
- Q: `FacilityResponse`-style expansion — do the list rows need per-row lookups? → A: **No.** Payment Method Options rows arrive with `facility` and `warehouse` pre-expanded as summaries; Taxpayer Issuer rows arrive with `regime` and `postalCode` pre-expanded as SAT catalog objects; Taxpayer Certificate rows carry the taxpayer RFC (human-meaningful) plus validity and status directly. No screen performs an N+1 per-row resolve.
- Q: The `paymentMethod` field on a Payment Method Option is an integer SAT payment-method code, and `commission` is a string/number amount. Are these free entry? → A: `paymentMethod` is chosen from a standard, fixed list of SAT payment methods presented with human-readable labels — **not** a free-typed code. *(Planning note: the SAT catalog service exposes no payment-methods endpoint, so this list is a fixed labeled lookup rather than a live picker; see plan research §5. The authoritative member set is mbe-api's `PaymentMethod` constant — see the 2026-07-22 clarification below and plan research §5.)* `commission` is an optional decimal amount entered on the form. `numberOfPayments` defaults to 1 and `displayOnTicket` defaults to true.
- Q: Do all three list endpoints expose free-text search, which the design system requires on every catalog? → A: Only the Taxpayer Issuers list does. The Payment Method Options and Taxpayer Certificates lists currently expose only their facet filters (facility/status and taxpayer/status respectively) with no free-text `search`. Following the spec-013/014 precedent, each screen still ships a search box wired to an expected server-side `search` capability, and the two gaps are filed upstream as a tracked dependency (see Dependencies). This is not a design-system deviation and not a client-side filtering workaround. *(Partially superseded by the 2026-07-22 clarification: Taxpayer Certificates is no longer a standalone list — it is a bounded per-issuer section needing no search box — so only the Payment Method Options search gap remains tracked.)*
- Q: `FiscalCertificationProvider` is a generated integer enum whose member names the generator leaves unnamed (`number0`, `number1`, …), like `FacilityType` in spec 014. Is a new hand-named enum in scope? → A: The issuer form must show human-readable provider labels, so display names are mapped for the provider values, following the exact `EntityStatus`/`Gender`/`FacilityType` precedent. This is display-label mapping over the **generated** enum, not a new domain enum replacing it, and stays within the "reuse the generated enum" boundary.

### Session 2026-07-22

- Q: Should Taxpayer Certificates be a standalone catalog under the Ventas group? → A: **No — corrected.** Certificates are a **child collection of a Taxpayer Issuer**, managed from **within the issuer's detail screen** (the legacy "Razones Sociales" detail shows a **Certificados** section/tab listing the issuer's certificates with an **Agregar** action). Consequently: there is **no** standalone Taxpayer Certificates list screen, **no** `/taxpayer-certificates` route, and **no** third navigation destination. The certificate section appears only once the issuer exists (view/edit mode, never on the issuer create form), because a certificate references the issuer's RFC. This also removes the earlier §VI concern about a catalog list screen without an Edit row action: certificates are now a delimited sub-section of the issuer form (like spec 014's inline-address sub-form and the product-pricing sub-panel), not a top-level catalog. The legacy detail's other tab, "Series y Folios", is explicitly **out of scope**.
- Q: The `paymentMethod` member set was sourced from a legacy HTML `<select>`. Is there a more authoritative definition? → A: **Yes.** Use mbe-api's `PaymentMethod` constant (`Model/Constants/PaymentMethod.cs`, documented at `mbe-api/docs/constants.md`) as the authoritative source: it is the SAT-aligned forma-de-pago catalog with canonical member names and SAT codes. Same integer codes as before, now with names and provenance: `0 NA`, `1 Cash (01)`, `2 Check (02)`, `3 EFT (03)`, `4 CreditCard (04)`, `5 ElectronicPurse (05)`, `6 ElectronicMoney (06)`, `8 FoodVouchers (08)`, `12 Giving (12)`, `27 ToTheSatisfactionOfTheCreditor (27)`, `28 DebitCard (28)`, `29 ServiceCard (29)`, `30 AdvancePayments (30)`, `99 ToBeDefined (99)`, `1001 GovernmentFunding (non-SAT extension)`. The `1001` member is explicitly documented upstream as a non-SAT mbe extension — it keeps its `// FIXME` marker for easy removal.

## User Scenarios & Testing *(mandatory)*

<!--
  User stories are PRIORITIZED as user journeys ordered by importance.
  Each is INDEPENDENTLY TESTABLE — implementing just one still yields a viable MVP slice.
-->

### User Story 1 - Manage the Payment Method Options catalog (Priority: P1)

A user with the appropriate privilege needs to see the list of payment method options across the organization, narrow it to a single facility or to active records only, open one to view its detail, create a new option under a chosen facility (optionally scoped to a warehouse), edit its name, number of payments, whether it shows on the ticket, its SAT payment method, its commission and its status, and delete one that is no longer in use — from a dedicated Payment Method Options screen under the Catálogos group, the same way the spec-013/014 catalogs are managed today.

**Why this priority**: It is a self-contained, full-CRUD catalog that depends on nothing else in this feature (only on the already-shipped Facilities and Warehouses catalogs for its two pickers). It is the lowest-risk slice and the closest in shape to catalogs already shipped, so it establishes the delivery pattern for the feature.

**Independent Test**: Can be fully tested by opening the Payment Method Options catalog, filtering to a single facility, creating a new option by picking a facility and entering a name and SAT payment method, editing its commission and "show on ticket" flag, changing its status, viewing it read-only, and deleting one — with no dependency on the other two catalogs.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on payment method options, **When** they open the catalog, **Then** they see a paginated list showing each option's facility, name, SAT payment method, number of payments, and status.
2. **Given** the list, **When** the user opens the filter controls, **Then** they can narrow it to a specific facility and/or a specific status, and the two filters combine.
3. **Given** a user with create privilege, **When** they select a facility, enter a name, choose a SAT payment method, and save, **Then** the new option appears in the list showing the facility's name (not a raw id).
4. **Given** a user creating an option, **When** they leave number of payments and "show on ticket" untouched, **Then** the option is saved with one payment and shown on the ticket by default.
5. **Given** a user with create privilege, **When** they additionally pick a warehouse, **Then** the option is scoped to that warehouse and the warehouse is shown wherever the option is displayed.
6. **Given** a user with update privilege viewing an option, **When** they edit any field and save, **Then** the change is reflected on the list and detail screen.
7. **Given** a user with delete privilege viewing an option's detail screen, **When** they confirm deletion, **Then** the option no longer appears in the catalog.
8. **Given** a user without update privilege, **When** they open an option's detail screen, **Then** it renders read-only with no edit or delete affordance.
9. **Given** a user without read privilege on payment method options, **When** they view the navigation, **Then** the Payment Method Options destination is not shown and its route is not reachable.

---

### User Story 2 - Manage the Taxpayer Issuers catalog ("Razones Sociales / Emisores de Facturas") (Priority: P1)

A user with the appropriate privilege needs to see the list of taxpayer issuers (the legal entities that issue the organization's invoices), open one to view its detail, register a new issuer by entering its RFC, name, fiscal regime, certification provider and postal code, edit the mutable fields of an existing issuer, and delete one that is no longer used — from a dedicated Taxpayer Issuers screen under the Ventas group. The list mirrors the legacy "Razones Sociales (Emisores de Facturas)" screen, showing RFC, postal code (C.P.), name, and fiscal regime.

**Why this priority**: Taxpayer issuers are the fiscal identity behind every invoice and are a prerequisite of Taxpayer Certificates (User Story 3), which reference an issuer by RFC. Delivering it first unblocks the certificates slice and, on its own, replaces the legacy Razones Sociales screen. It is independent of Payment Method Options.

**Independent Test**: Can be fully tested by opening the Taxpayer Issuers catalog, registering a new issuer with an RFC, name, regime and postal code, editing its name and comment, confirming the RFC is not editable, viewing it read-only, and deleting one — independent of the other two catalogs.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on taxpayers, **When** they open the Taxpayer Issuers catalog, **Then** they see a paginated list showing each issuer's RFC, postal code, name, and fiscal regime.
2. **Given** a user with create privilege, **When** they enter an RFC, a name, a fiscal regime, and a postal code and save, **Then** the new issuer appears in the list.
3. **Given** a user creating an issuer, **When** they choose a fiscal regime and a postal code, **Then** each is chosen from the standard SAT catalog (searchable), not typed as a raw code.
4. **Given** a user creating an issuer, **When** they choose a certification provider, **Then** the provider is presented with a human-readable label.
5. **Given** a user with update privilege viewing an existing issuer, **When** they open it for editing, **Then** the RFC is shown but cannot be changed, while name, regime, provider, postal code and comment can.
6. **Given** a user editing an issuer, **When** they change a mutable field and save, **Then** the change is reflected on the list and detail screen.
7. **Given** a user with delete privilege viewing an issuer's detail screen, **When** they confirm deletion, **Then** the issuer no longer appears in the catalog.
8. **Given** a user creating an issuer with an RFC that is already registered, **When** they save and the system rejects it, **Then** the rejection is shown clearly on the form and the user's other input is preserved.
9. **Given** a user without read privilege on taxpayers, **When** they view the navigation, **Then** the Taxpayer Issuers destination is not shown and its route is not reachable.

---

### User Story 3 - Manage a Taxpayer Issuer's CSD Certificates from its detail screen (Priority: P2)

A user with the appropriate privilege, viewing an existing Taxpayer Issuer's detail screen, needs to see that issuer's registered CSD (Certificado de Sello Digital) fiscal signing certificates in a **Certificates section** of the same screen — showing each certificate's number, valid-from, valid-to and active status — and to register a new certificate for that issuer by choosing its certificate (`.cer`) and key (`.key`) files and entering the key password, via an **Agregar** (Add) action that opens an upload form. Certificates are never edited or deleted; a superseding certificate is registered by adding a newer one. This mirrors the legacy "Razones Sociales" detail, whose "Certificados" tab lists the issuer's certificates with an Agregar button.

**Why this priority**: Certificates belong to a Taxpayer Issuer and are managed inside its detail screen, so this story builds directly on User Story 2's issuer detail. It is also the narrowest slice — a read-only child list plus an upload action — and the least frequently used, making it the right final increment.

**Independent Test**: Can be fully tested, once at least one taxpayer issuer exists, by opening that issuer's detail screen, viewing its Certificates section, using Agregar to register a new certificate by picking its two files and entering the password, and confirming the new certificate appears in the section with a validity window the user never typed — with no per-certificate edit or delete affordance present.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on taxpayers viewing an existing issuer's detail screen, **When** the screen renders, **Then** a Certificates section lists that issuer's certificates showing each one's certificate number, valid-from, valid-to and active status.
2. **Given** a user creating a new issuer (the issuer does not yet exist), **When** they view the create form, **Then** the Certificates section is not shown (a certificate needs a persisted issuer to belong to).
3. **Given** a user with create privilege on the issuer detail's Certificates section, **When** they choose Agregar, select a certificate file and a key file, enter the key password, and submit, **Then** the certificate is registered for that issuer and appears in the section with its validity window populated from the certificate itself.
4. **Given** a user adding a certificate, **When** they have not selected both files or have not entered a password, **Then** submission is blocked with a clear indication of what is missing.
5. **Given** a user adding a certificate whose files or password the system rejects (invalid pair, wrong password, expired, or mismatched taxpayer), **When** they submit, **Then** the rejection is shown clearly on the upload form and their selection is preserved.
6. **Given** a user viewing an issuer's Certificates section, **When** it renders, **Then** each certificate row is read-only and presents no edit and no delete affordance.
7. **Given** a user without create privilege on taxpayers viewing an issuer's Certificates section, **When** it renders, **Then** the Agregar action is not shown.
8. **Given** a user **with** create privilege who opened the issuer in read-only/View mode (via row-click, not Edit), **When** the Certificates section renders, **Then** the Agregar action is not shown — the read-only screen exposes no data-mutating control.

---

### Edge Cases

- **Certificate validity read server-side**: the valid-from/valid-to dates and the certificate number come from the uploaded certificate, not from user input; the form never asks for them and displays them only after a successful upload.
- **Wrong file type**: selecting a file that is not the expected `.cer`/`.key` is prevented at selection where possible, and any file the server rejects surfaces a clear error without losing the rest of the form.
- **Large or unreadable file**: a file that cannot be read or is rejected for size surfaces an error and the form remains usable.
- **Issuer referenced by a certificate**: deleting a taxpayer issuer that still has certificates may be rejected server-side; the UI surfaces the rejection and never pre-blocks the attempt.
- **RFC immutability**: attempting to change an RFC is not offered — the only way to "rename" is to create a new issuer and delete the old one.
- **Payment method option scoped to a warehouse of another facility**: if the backend rejects a warehouse that does not belong to the chosen facility, the rejection is surfaced on the form; the warehouse picker MAY be scoped to the selected facility as a UX convenience.
- **Empty catalogs**: each list shows a clear empty state when no records exist (or none match the active filters), distinct from the loading state.
- **Deletion while referenced**: any server-side rejection of a delete (a payment method option or issuer referenced elsewhere) is surfaced via the standard error banner and never silently swallowed.
- **Commission and number-of-payments bounds**: a non-numeric commission or a number of payments below one is rejected on the form before submission.

## Requirements *(mandatory)*

### Functional Requirements

**Payment Method Options (User Story 1)**

- **FR-001**: The system MUST provide a Payment Method Options catalog screen under the Catálogos navigation group, listing options in a paginated table showing facility, name, SAT payment method, number of payments, and status.
- **FR-002**: The list MUST offer a filter control combining a facility facet and a status facet, applied server-side.
- **FR-003**: Users with create privilege MUST be able to create a payment method option by selecting a facility (required), optionally selecting a warehouse, entering a name (required), choosing a SAT payment method (required) from a fixed list presented with human-readable labels, and optionally setting number of payments, "show on ticket", commission and status.
- **FR-004**: The facility and warehouse pickers MUST be searchable and MUST display each selected entity's name (not a raw id) wherever the option is shown.
- **FR-005**: Number of payments MUST default to 1 and "show on ticket" MUST default to true when not set by the user.
- **FR-006**: Users with update privilege MUST be able to edit every field of an existing option and save the change.
- **FR-007**: Users with delete privilege MUST be able to delete an option from its detail screen, with confirmation.
- **FR-008**: An option's detail screen MUST render read-only, with no edit or delete affordance, for users lacking update/delete privilege.
- **FR-009**: The Payment Method Options destination and route MUST be gated on read privilege for the `paymentMethodOptions` access object; the create/update/delete affordances MUST be gated on the corresponding rights and hidden (not merely disabled) when absent.

**Taxpayer Issuers (User Story 2)**

- **FR-010**: The system MUST provide a Taxpayer Issuers catalog screen under the Ventas navigation group, listing issuers in a paginated table showing RFC, postal code, name, and fiscal regime.
- **FR-011**: Users with create privilege MUST be able to register an issuer by entering an RFC (required), a name, a fiscal regime (required, chosen from the SAT catalog), a certification provider, and a postal code (chosen from the SAT catalog), plus an optional comment.
- **FR-012**: The RFC MUST be the issuer's identity: entered on create and shown read-only on edit; it MUST NOT be changeable after creation.
- **FR-013**: The fiscal regime and postal code MUST each be selected from the standard SAT catalog via a searchable picker, and each MUST be displayed by its human-readable catalog value wherever shown.
- **FR-014**: The certification provider MUST be presented and stored using the values the generated fiscal-certification-provider enum defines, shown with human-readable labels.
- **FR-015**: Users with update privilege MUST be able to edit an issuer's mutable fields (name, regime, provider, postal code, comment) and save.
- **FR-016**: Users with delete privilege MUST be able to delete an issuer from its detail screen, with confirmation.
- **FR-017**: The system MUST surface a server rejection of a duplicate RFC on create clearly, preserving the user's other input.
- **FR-018**: The Taxpayer Issuers destination and route MUST be gated on read privilege for the `taxpayers` access object; create/update/delete affordances MUST be gated on the corresponding rights and hidden when absent.

**Taxpayer Certificates (User Story 3) — a child section of the Taxpayer Issuer detail**

- **FR-019**: The Taxpayer Issuer detail screen MUST, for an existing (persisted) issuer, present a Certificates section listing that issuer's certificates showing each one's certificate number, valid-from, valid-to and active status. There MUST be no standalone Taxpayer Certificates catalog screen, route, or navigation destination.
- **FR-020**: The Certificates section MUST show the certificates of the currently open issuer only (scoped to that issuer's RFC); it needs no taxpayer selector and no separate search box, being a bounded per-issuer child collection.
- **FR-021**: Users with the create privilege MUST be able to register a certificate for the open issuer via an Agregar (Add) action that opens an upload form: choosing a certificate (`.cer`) file and a key (`.key`) file and entering the key password. The file selection MUST use the existing file-picker capability and restrict to the expected file types where the platform allows. The issuer (taxpayer RFC) is taken from the open issuer and is not re-selected.
- **FR-022**: The certificate upload form MUST NOT request the certificate number or validity dates; those MUST be populated from the uploaded certificate and shown in the section only after a successful registration.
- **FR-023**: The system MUST block submission until both files are selected and a password is entered, and MUST surface any server rejection (invalid pair, wrong password, expired, mismatched taxpayer) clearly on the upload form while preserving the selection.
- **FR-024**: The Certificates section MUST NOT offer a per-certificate edit or delete action; each certificate row is read-only. Superseding a certificate is done by adding a newer one.
- **FR-025**: The Certificates section MUST appear only within the issuer detail (itself gated on `taxpayers` read); the Agregar affordance MUST be gated on the `taxpayers` create right AND hidden whenever the issuer detail is rendering read-only (opened via row-click/View, or when the user lacks the issuer's update privilege) — it MUST derive from the same read-only flag as every other body mutation action (per constitution §VI's row-click-is-read-only rule), so a read-only view never exposes a data-mutating control even to a create-privileged user. The section MUST NOT appear on the issuer create form (no persisted issuer to own a certificate).

**Cross-cutting**

- **FR-026**: The two standalone list screens (Payment Method Options, Taxpayer Issuers) and the issuer detail's Certificates section MUST NOT perform a per-row lookup to display any referenced entity (facility, warehouse, SAT regime, SAT postal code, or taxpayer): every displayed reference MUST come from data already present on the list/section response. The two standalone lists MUST paginate one server page at a time.
- **FR-027**: Each list and the Certificates section MUST distinguish loading, empty, error, and populated states, and MUST present server and validation errors through the app's standard error surface without losing user input.
- **FR-028**: Both new navigation destinations (Payment Method Options, Taxpayer Issuers) MUST appear only for users whose access permits reading them, and a navigation group left with no visible children MUST NOT render an empty header (existing navigation behavior).
- **FR-029**: All new user-facing strings (navigation titles, column headers, field labels, validation messages, empty states, provider/status/payment-method labels) MUST be added to both application language resource files; no user-facing string may be hard-coded.
- **FR-030**: The feature MUST consume the already-generated API clients for these three entities and MUST NOT introduce hand-written data-transfer objects, edit generated files, or add a new third-party dependency (the file-picker capability already present is reused).
- **FR-031**: Both standalone list screens (Payment Method Options, Taxpayer Issuers) MUST present a free-text search box per the shared filter pattern. The Taxpayer Issuers search operates server-side today; the Payment Method Options search box is wired to an expected server-side search capability tracked as an upstream dependency (see Dependencies) and MUST NOT be implemented as client-side filtering of the current page. (The issuer's Certificates section is a bounded per-issuer child collection and needs no search box — FR-020.)

### Key Entities *(include if feature involves data)*

- **Payment Method Option**: A configurable payment tender available at a facility (and optionally a specific warehouse). Attributes: facility (required reference), warehouse (optional reference), name, number of payments (default 1), show-on-ticket flag (default true), SAT payment method code, commission amount (optional), status. Referenced facility and warehouse arrive pre-expanded for display.
- **Taxpayer Issuer** ("Razón Social" / invoice emitter): A legal entity authorized to issue the organization's invoices, identified by its RFC. Attributes: RFC (identity, immutable), name, fiscal regime (SAT catalog), certification provider, postal code (SAT catalog), comment. Regime and postal code arrive pre-expanded as SAT catalog objects. Referenced by Taxpayer Certificates.
- **Taxpayer Certificate (CSD)**: A government-issued digital seal certificate used to sign fiscal documents, belonging to a taxpayer issuer and **managed within that issuer's detail screen** (not a standalone catalog). Attributes: certificate identifier/number, taxpayer (owning issuer's RFC), valid-from, valid-to, status. Registered by uploading a `.cer`/`.key` pair with a key password; number and validity are derived from the certificate. Immutable — never edited or deleted through this feature; superseded by registering a newer certificate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a payment method option — pick a facility, enter a name, choose a SAT payment method, and save — in under one minute, and see it in the list immediately, without leaving the catalog.
- **SC-002**: A user can register a new taxpayer issuer with RFC, name, regime and postal code, and the new issuer appears in the list on the next fetch; attempting to reuse an existing RFC is clearly rejected without losing entered data.
- **SC-003**: A user cannot change an issuer's RFC after creation through any path in the UI.
- **SC-004**: From an existing issuer's detail screen, a user can register a CSD certificate by choosing its two files and entering the password, and the new certificate appears in the issuer's Certificates section showing a validity window the user never typed.
- **SC-005**: Certificates are reachable only within a Taxpayer Issuer's detail screen; there is no standalone Taxpayer Certificates screen/route/destination, and the Certificates section exposes no per-certificate edit or delete action anywhere in the UI.
- **SC-006**: The two standalone list screens render their first page from a single server request, and neither they nor the issuer's Certificates section perform per-row requests to display referenced entities.
- **SC-007**: A user lacking read privilege on a given catalog (or on `taxpayers`) never sees its navigation destination and cannot reach its route directly.
- **SC-008**: 100% of new user-facing strings render from the localization resources in both supported languages, with none hard-coded.
- **SC-009**: Every server or validation error on any of the three forms is shown to the user through the standard error surface, and the user's other input is preserved across the error.

## Assumptions

- The three generated API clients (payment method options, taxpayer issuers, taxpayer certificates) are already present in the generated client and expose the operations described; no upstream backend change is required for this feature. (Payment method options: full CRUD with facility/status list filters. Taxpayer issuers: full CRUD keyed by RFC. Taxpayer certificates: list (filterable by taxpayer RFC), get, and multipart upload only — no update, no delete; consumed here only to populate and add to an issuer's Certificates section, scoped to that issuer's RFC.)
- The Facilities and Warehouses catalogs shipped in spec 014 provide the searchable sources for the payment-method-option facility and warehouse pickers; this feature reuses them and does not re-implement them.
- The SAT catalog picker path already used by the product and facility forms (fiscal regime, postal code) is reused unchanged for the issuer form. The SAT payment method has no catalog endpoint, so the payment-method-option form presents it as a fixed labeled list — mbe's legacy PaymentMethod enum — rather than a live picker (plan research §5).
- The `paymentMethodOptions` and `taxpayers` access-control objects already exist in the application's access mirror; no access-object correction is required by this feature.
- The `file_picker` dependency already present in the project is sufficient for selecting the certificate and key files; no image-specific handling (crop/preview) applies because these are not images.
- The certification-provider values are those the generated enum defines; this feature only maps human-readable display labels onto them, following the existing status/gender/facility-type label precedent, and introduces no replacement domain enum.
- Client-side privilege gating (hide-not-disable) is consistent with the posture the shipped catalogs already record; the server remains the authority and its rejections are surfaced.
- The commission value is an optional decimal amount entered on the payment-method-option form; the SAT payment method is an integer code selected from a fixed labeled list (mbe's legacy PaymentMethod enum; no live SAT endpoint), per plan research §5.
- This feature extends the existing shared master-data catalog module (as specs 012/013/014 did) and modifies only the navigation tree, the router, and the language resource files outside that module.

## Dependencies

- **Upstream (resolved)**: The taxpayer-issuers, taxpayer-certificates, and payment-method-options endpoints and their generated clients shipped upstream (the same 2026-07-21 regeneration that closed spec 014's dependencies). The core CRUD/upload operations have no open cross-repo dependency.
- **Upstream (tracked, non-blocking)**: The Payment Method Options list endpoint does not yet accept a free-text `search` parameter (only its facet filters). Following the spec-013/014 precedent, a request is filed upstream to add `search`; the screen ships its search box wired to that expected capability, activating automatically once it lands. This is a tracked dependency, not a design-system deviation. The Taxpayer Issuers list already accepts `search`. (The Taxpayer Certificates list needs no search box — it is a bounded per-issuer child collection, FR-020.)
- **Internal**: Reuses spec 014's Facilities/Warehouses catalogs (pickers), the shared SAT-catalog picker path, the shared catalog list/detail/filter widgets, the inline sub-form/dialog pattern (spec 014's facility inline-address create), the access-control service, and the navigation/router infrastructure.
- **Sequencing**: Taxpayer Certificates (User Story 3) is managed inside the Taxpayer Issuer detail (User Story 2), so it builds on US2's detail screen and requires a persisted issuer to attach to. Payment Method Options (User Story 1) is independent of both.

## Out of Scope

- Editing or deleting a taxpayer certificate, or entering its number/validity by hand (all server-derived and immutable).
- A standalone Taxpayer Certificates catalog screen, route, or navigation destination (certificates live inside the issuer detail — 2026-07-22 clarification).
- The legacy issuer detail's "Series y Folios" (series/folios) tab — a separate entity, not in scope.
- Creating a taxpayer issuer inline from another form (spec 014 already reaches issuers read-only from the facility form; issuer creation lives only in this feature's own catalog).
- Any new hand-named domain enum replacing the generated fiscal-certification-provider or entity-status enums (only display-label mapping is in scope).
- A standalone Addresses catalog or any change to the Facilities/Warehouses catalogs shipped in spec 014.
- Consuming, rendering, or generating fiscal documents (invoices) signed with these certificates — a separate concern.
