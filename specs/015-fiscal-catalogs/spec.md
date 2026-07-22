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
- Q: The `paymentMethod` field on a Payment Method Option is an integer SAT payment-method code (`c_FormaPago`), and `commission` is a string/number amount. Are these free entry? → A: `paymentMethod` is selected from the standard SAT payment-method list (the same SAT-catalog picker path the product/facility forms already use); `commission` is an optional decimal amount entered on the form. `numberOfPayments` defaults to 1 and `displayOnTicket` defaults to true.
- Q: `FiscalCertificationProvider` is a generated integer enum whose member names the generator leaves unnamed (`number0`, `number1`, …), like `FacilityType` in spec 014. Is a new hand-named enum in scope? → A: The issuer form must show human-readable provider labels, so display names are mapped for the provider values, following the exact `EntityStatus`/`Gender`/`FacilityType` precedent. This is display-label mapping over the **generated** enum, not a new domain enum replacing it, and stays within the "reuse the generated enum" boundary.

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

### User Story 3 - Register and review Taxpayer Certificates (CSD) (Priority: P2)

A user with the appropriate privilege needs to see the list of registered CSD (Certificado de Sello Digital) fiscal signing certificates, narrow it to a single taxpayer or to active records only, open one to view its detail (issuing taxpayer, validity window, status), and register a new certificate by selecting the taxpayer issuer it belongs to, choosing its certificate (`.cer`) and key (`.key`) files, and entering the key password — from a dedicated Taxpayer Certificates screen under the Ventas group. Certificates are never edited or deleted through this screen; a superseding certificate is registered by uploading a newer one.

**Why this priority**: Certificates depend on Taxpayer Issuers existing (they reference an issuer by RFC), so they follow User Story 2. They are also the narrowest slice — upload-plus-read-only — and the least frequently used, making them the right final increment.

**Independent Test**: Can be fully tested, once at least one taxpayer issuer exists, by opening the Taxpayer Certificates catalog, filtering to a single taxpayer, registering a new certificate by picking an issuer and its two files and entering the password, and viewing the resulting record's validity window read-only — with no edit or delete affordance present.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on taxpayers, **When** they open the Taxpayer Certificates catalog, **Then** they see a paginated list showing each certificate's identifier, taxpayer RFC, valid-from and valid-to dates, and status.
2. **Given** the list, **When** the user opens the filter controls, **Then** they can narrow it to a specific taxpayer and/or a specific status, and the two filters combine.
3. **Given** a user with the privilege to register a certificate, **When** they select a taxpayer issuer, choose a certificate file and a key file, enter the key password, and submit, **Then** the certificate is registered and appears in the list with its validity window populated from the certificate itself.
4. **Given** a user registering a certificate, **When** they have not selected both files or have not entered a password, **Then** submission is blocked with a clear indication of what is missing.
5. **Given** a user registering a certificate whose files or password the system rejects (invalid pair, wrong password, expired, or mismatched taxpayer), **When** they submit, **Then** the rejection is shown clearly on the form and their selection is preserved.
6. **Given** any user viewing a certificate's detail screen, **When** the screen renders, **Then** it is read-only and presents no edit and no delete affordance.
7. **Given** a user without read privilege on taxpayers, **When** they view the navigation, **Then** the Taxpayer Certificates destination is not shown and its route is not reachable.

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
- **FR-003**: Users with create privilege MUST be able to create a payment method option by selecting a facility (required), optionally selecting a warehouse, entering a name (required), choosing a SAT payment method (required), and optionally setting number of payments, "show on ticket", commission and status.
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

**Taxpayer Certificates (User Story 3)**

- **FR-019**: The system MUST provide a Taxpayer Certificates catalog screen under the Ventas navigation group, listing certificates in a paginated table showing the certificate identifier, taxpayer RFC, valid-from and valid-to dates, and status.
- **FR-020**: The list MUST offer a filter control combining a taxpayer facet and a status facet, applied server-side.
- **FR-021**: Users with the privilege to register a certificate MUST be able to do so by selecting a taxpayer issuer, choosing a certificate (`.cer`) file and a key (`.key`) file, entering the key password, and submitting; the file selection MUST use the existing file-picker capability and restrict to the expected file types where the platform allows.
- **FR-022**: The certificate registration form MUST NOT request the certificate number or validity dates; those MUST be populated from the uploaded certificate and shown only after a successful registration.
- **FR-023**: The system MUST block submission until both files are selected and a password is entered, and MUST surface any server rejection (invalid pair, wrong password, expired, mismatched taxpayer) clearly while preserving the selection.
- **FR-024**: The Taxpayer Certificates catalog MUST NOT offer an edit or a delete action; a certificate's detail screen MUST be read-only. Superseding a certificate is done by registering a newer one.
- **FR-025**: The Taxpayer Certificates destination and route MUST be gated on read privilege for the `taxpayers` access object; the register affordance MUST be gated on the create right and hidden when absent.

**Cross-cutting**

- **FR-026**: All three list screens MUST paginate one server page at a time and MUST NOT perform a per-row lookup to display any referenced entity (facility, warehouse, SAT regime, SAT postal code, or taxpayer): every displayed reference MUST come from data already present on the list response.
- **FR-027**: Each catalog MUST distinguish loading, empty, error, and populated list states, and MUST present server and validation errors through the app's standard error surface without losing user input.
- **FR-028**: All three destinations MUST appear only for users whose access permits reading them, and a navigation group left with no visible children MUST NOT render an empty header (existing navigation behavior).
- **FR-029**: All new user-facing strings (navigation titles, column headers, field labels, validation messages, empty states, provider/status labels) MUST be added to both application language resource files; no user-facing string may be hard-coded.
- **FR-030**: The feature MUST consume the already-generated API clients for these three entities and MUST NOT introduce hand-written data-transfer objects, edit generated files, or add a new third-party dependency (the file-picker capability already present is reused).

### Key Entities *(include if feature involves data)*

- **Payment Method Option**: A configurable payment tender available at a facility (and optionally a specific warehouse). Attributes: facility (required reference), warehouse (optional reference), name, number of payments (default 1), show-on-ticket flag (default true), SAT payment method code, commission amount (optional), status. Referenced facility and warehouse arrive pre-expanded for display.
- **Taxpayer Issuer** ("Razón Social" / invoice emitter): A legal entity authorized to issue the organization's invoices, identified by its RFC. Attributes: RFC (identity, immutable), name, fiscal regime (SAT catalog), certification provider, postal code (SAT catalog), comment. Regime and postal code arrive pre-expanded as SAT catalog objects. Referenced by Taxpayer Certificates.
- **Taxpayer Certificate (CSD)**: A government-issued digital seal certificate used to sign fiscal documents, belonging to a taxpayer issuer. Attributes: certificate identifier, taxpayer (issuer RFC), valid-from, valid-to, status. Registered by uploading a `.cer`/`.key` pair with a key password; number and validity are derived from the certificate. Immutable — never edited or deleted through this feature; superseded by registering a newer certificate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a payment method option — pick a facility, enter a name, choose a SAT payment method, and save — in under one minute, and see it in the list immediately, without leaving the catalog.
- **SC-002**: A user can register a new taxpayer issuer with RFC, name, regime and postal code, and the new issuer appears in the list on the next fetch; attempting to reuse an existing RFC is clearly rejected without losing entered data.
- **SC-003**: A user cannot change an issuer's RFC after creation through any path in the UI.
- **SC-004**: A user can register a CSD certificate by selecting an issuer and its two files and entering the password, and the resulting record shows a validity window the user never typed.
- **SC-005**: The Taxpayer Certificates catalog exposes no edit and no delete action anywhere in the UI.
- **SC-006**: Each of the three list screens renders its first page from a single server request, performing zero additional per-row requests to display referenced entities.
- **SC-007**: A user lacking read privilege on a given catalog never sees its navigation destination and cannot reach its route directly.
- **SC-008**: 100% of new user-facing strings render from the localization resources in both supported languages, with none hard-coded.
- **SC-009**: Every server or validation error on any of the three forms is shown to the user through the standard error surface, and the user's other input is preserved across the error.

## Assumptions

- The three generated API clients (payment method options, taxpayer issuers, taxpayer certificates) are already present in the generated client and expose the operations described; no upstream backend change is required for this feature. (Payment method options: full CRUD with facility/status list filters. Taxpayer issuers: full CRUD keyed by RFC. Taxpayer certificates: list, get, and multipart upload only — no update, no delete — with taxpayer/status list filters.)
- The Facilities and Warehouses catalogs shipped in spec 014 provide the searchable sources for the payment-method-option facility and warehouse pickers; this feature reuses them and does not re-implement them.
- The SAT catalog picker path already used by the product and facility forms (fiscal regime, postal code, payment method) is reused unchanged for the issuer and payment-method-option forms.
- The `paymentMethodOptions` and `taxpayers` access-control objects already exist in the application's access mirror; no access-object correction is required by this feature.
- The `file_picker` dependency already present in the project is sufficient for selecting the certificate and key files; no image-specific handling (crop/preview) applies because these are not images.
- The certification-provider values are those the generated enum defines; this feature only maps human-readable display labels onto them, following the existing status/gender/facility-type label precedent, and introduces no replacement domain enum.
- Client-side privilege gating (hide-not-disable) is consistent with the posture the shipped catalogs already record; the server remains the authority and its rejections are surfaced.
- The commission value is an optional decimal amount entered on the payment-method-option form; the SAT payment method is an integer code selected from the standard SAT list.
- This feature extends the existing shared master-data catalog module (as specs 012/013/014 did) and modifies only the navigation tree, the router, and the language resource files outside that module.

## Dependencies

- **Upstream (resolved)**: The taxpayer-issuers, taxpayer-certificates, and payment-method-options endpoints and their generated clients shipped upstream (the same 2026-07-21 regeneration that closed spec 014's dependencies). There is no open cross-repo dependency for this feature.
- **Internal**: Reuses spec 014's Facilities/Warehouses catalogs (pickers), the shared SAT-catalog picker path, the shared catalog list/detail/filter widgets, the access-control service, and the navigation/router infrastructure.
- **Sequencing**: Taxpayer Certificates (User Story 3) depends on Taxpayer Issuers (User Story 2) existing, because a certificate references an issuer by RFC. Payment Method Options (User Story 1) is independent of both.

## Out of Scope

- Editing or deleting a taxpayer certificate, or entering its number/validity by hand (all server-derived and immutable).
- Creating a taxpayer issuer inline from another form (spec 014 already reaches issuers read-only from the facility form; issuer creation lives only in this feature's own catalog).
- Any new hand-named domain enum replacing the generated fiscal-certification-provider or entity-status enums (only display-label mapping is in scope).
- A standalone Addresses catalog or any change to the Facilities/Warehouses catalogs shipped in spec 014.
- Consuming, rendering, or generating fiscal documents (invoices) signed with these certificates — a separate concern.
