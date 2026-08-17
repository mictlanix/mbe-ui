# Feature Specification: Presentation Consistency — One Formatting Surface & Flex Spacing

**Feature Branch**: `028-presentation-consistency`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "Let's create a spec to enforce: (1) Text formatting for currencies, dates, date times, and other data types. I think that was audited on spec 027 and tasks were deferred because there were a lot of occurrences. When formatting, I expect to add some commented examples of valid formats for each data type, I'd like you to include iso format (YYYY-MM-DD) because it is my logical choice, but maybe customers will prefer a more local format (DD/MM/YYYY). And add valid formats for the tool that will perform formatting (intl formatter?). (2) This audit where spacing property can be used (discarding if there are any sized boxes of different sizes upon the same flex/row/column). Don't make this task too elaborated."

## Clarifications

### Session 2026-08-17

- Q: What should the default date format be out of the box? → A: **ISO.** `yyyy-MM-dd` for dates and `yyyy-MM-dd HH:mm` for date-times ship as the built-in defaults; a deployment preferring a local rendering opts out with `DATE_FORMAT=d/M/yyyy`. This **deliberately supersedes** the "defaults reproduce today's rendering byte-for-byte" guarantee written into the carried-forward contract, which assumed the locale-derived `16/8/2026`. The cost is accepted and in scope: every golden and screenshot baseline that renders a date must be re-recorded in this feature (FR-021).
- Q: Who can change the date and number formats? → A: **Deployment only.** Build-time keys on the existing `AppSettings` (spec 027), supplied per customer through `deploy/<customer>.env`. There is **no** per-user override and **no** change to the user settings screen — appearance, text size and language stay exactly as 027 shipped them. This keeps constitution §V's two configuration levels unblurred: formatting is a deployment concern, not a personal taste.
- Q: Should converted spacing sites adopt the `Spacing` design tokens? → A: **No — literals are preserved.** US2 stays a zero-visual-change mechanical conversion. The token swap is not free: `Spacing.fieldGapVertical` / `fieldGapHorizontal` are tier-dependent, so adopting them *would* change layout at some tiers, which is precisely what US2 promises not to do. Token adoption is out of scope and left to the specs that next touch those widgets.
- Q: Can the formatting migration be split into smaller increments? → A: **No.** The guard test that prevents regression only becomes satisfiable once the last call site has moved; landing it earlier fails the suite for the whole migration. The ≈78 call sites are one indivisible change. This is the reason the work was descoped from 027 rather than partially done there.

## User Scenarios & Testing *(mandatory)*

> **Relationship to spec 027.** Value formatting was scoped into 027, sized at
> ≈78 call sites, and descoped on 2026-08-16 with its design left finished.
> This feature takes it on. The carried-forward artifacts —
> `contracts/formatting-surface.md` and `research.md` R3/R4/R8 — are **copied
> into this feature's own directory** and are authoritative here; 027's copies
> become historical. Constitution §V names this feature explicitly: the
> single-formatting-surface rule was drafted for v1.11.0 and withheld because
> "a rule requiring every screen to use a component that does not exist yet is
> unsatisfiable", to be amended in "with the spec that builds the surface."

---

### User Story 1 - Every value reads the same way, everywhere (Priority: P1)

A cashier, an administrator and a deployer all see one consistent rendering of every date, amount, percentage and quantity in the product. A date on the sales list looks like a date on a cash session, a certificate, or a price list. An amount with no value shows the same placeholder wherever it appears, instead of a formatted zero on one screen and a blank on another. A deployer who wants dates in the local `16/8/2026` style instead of the ISO default changes one line in that customer's environment file and rebuilds — no source edit, no fork.

**Why this priority**: This is the defect the user reported, and it is the whole reason 027 existed. Three formatting implementations currently disagree with each other in ways users can see on one screen. It is also the larger and riskier of the two stories, and the only one that changes what the product looks like.

**Independent Test**: Build with no environment file and confirm every date in the app renders `2026-08-17` and every amount `$1,234.50`. Build again with `DATE_FORMAT=d/M/yyyy` and confirm every date — with no exceptions and no screen left behind — switches to `17/8/2026`. Open a record with a null date and a null amount and confirm both render the same placeholder.

**Acceptance Scenarios**:

1. **Given** no environment file is supplied at build time, **When** the app renders any date, **Then** it appears as `2026-08-17` and any date-time as `2026-08-17 14:30`.
2. **Given** a deployment sets `DATE_FORMAT=d/M/yyyy`, **When** the app is rebuilt, **Then** every displayed date across every feature module changes together, with no screen retaining the previous format.
3. **Given** a value that is absent or cannot be read, **When** any screen displays it, **Then** it renders as `—`, replacing the three behaviours that disagree today (a formatted zero, the raw unformatted input, and a hand-written dash).
4. **Given** a user opens a field containing a stored price and saves without editing it, **When** the record is written back, **Then** the stored value is byte-identical to what was loaded — formatting for display never alters a persisted value.
5. **Given** a deployment supplies a malformed format pattern, **When** the app starts, **Then** it falls back to that key's documented default and starts normally rather than failing or rendering broken text.
6. **Given** a deployer opens `.env.template`, **When** they look up any formatting key, **Then** they find its default, a one-line description, and worked examples showing the same value rendered under each valid pattern.
7. **Given** a developer adds a screen that formats a date without going through the shared surface, **When** the test suite runs, **Then** it fails and names the offending file and line.
8. **Given** the sales list's date query facet, **When** the migration completes, **Then** it still encodes `yyyy-MM-dd` independently of any deployment setting — it is a URL parameter, not a display path.

---

### User Story 2 - Uniform gaps are expressed as spacing, not spacer widgets (Priority: P2)

A developer reading a layout sees a single declared gap on the row or column instead of counting spacer widgets interleaved between children. Nothing about the running app changes.

**Why this priority**: Pure maintainability, no user-visible effect, and deliberately kept small at the user's request. It is fully independent of US1 and could ship first, alone, or not at all without affecting anything else.

**Independent Test**: Run the golden and screenshot suites before and after; every baseline passes unchanged. Confirm the converted files declare a gap once per row or column rather than repeating spacer widgets.

**Acceptance Scenarios**:

1. **Given** a row or column whose gaps between siblings are all the same size, **When** it is converted, **Then** the rendered output is pixel-identical and the spacer widgets are gone.
2. **Given** a row or column whose gaps between siblings differ in size, **When** the audit runs, **Then** it is left untouched and recorded as intentionally skipped.
3. **Given** a spacer acting as a leading or trailing pad rather than a gap between two children, **When** the audit runs, **Then** it is left untouched — a declared gap only ever falls between children.
4. **Given** a column with a uniform gap and a conditionally-present last child, **When** it is converted, **Then** the wrapper that existed only to pad that conditional child is removed and no gap is left dangling when the child is absent.
5. **Given** the full conversion, **When** the golden and screenshot suites run, **Then** every baseline passes with no re-recording.

---

### Edge Cases

- **A format pattern that is syntactically valid but semantically odd** (e.g. `yyyy` alone, or a pattern with no day field). It is accepted and used — the deployment owns that choice — but `.env.template` documents only the supported set.
- **A value that is present but unparseable** (a malformed decimal string from the API) renders the same `—` as an absent one, rather than surfacing raw text or crashing the row.
- **A quantity or price whose stored precision exceeds the configured display digits** is displayed rounded but never written back rounded; the round-trip guarantee is on the stored value, not the shown one.
- **Editable fields versus read-only display**: a field the user types into carries no currency symbol and no grouping that would break re-parsing, even when the read-only rendering of the same value has both.
- **A date-time crossing the 24-hour boundary in a 12-hour deployment pattern** — the documented set is 24-hour; a deployment choosing a 12-hour pattern gets it, but no examples are provided for it.
- **A row or column with exactly one child** has no gaps at all and is never converted, even if it contains a spacer.
- **Goldens re-recorded for the ISO default** must be re-recorded once, in US1. US2 must then leave them untouched — a US2 change that moves a baseline is a bug in the conversion, not a baseline that needs updating.

## Requirements *(mandatory)*

### Functional Requirements

**The formatting surface (US1)**

- **FR-001**: The product MUST expose exactly one way to format a value for display, reached identically from every feature module.
- **FR-002**: The formatting surface MUST own the active locale, so that no call site passes a locale and the interface language and formatted values cannot disagree.
- **FR-003**: The surface MUST be resolved once per screen build rather than reconstructed per value, so that a table of many rows does not rebuild a formatter for every cell.
- **FR-004**: The surface MUST cover, as read-only display: currency amounts, percentages, dates, date-times and quantities.
- **FR-005**: The surface MUST cover, as editable-field values: prices, rates and quantities — each carrying no currency symbol and each with an inverse that reads its own output back.
- **FR-006**: Every field formatter MUST round-trip: parsing its output MUST return the original stored value unchanged.
- **FR-007**: A field parser MUST return no value for input it cannot read, so the caller rejects the edit rather than persisting nonsense.
- **FR-008**: A value that is absent or unparseable MUST render as `—` everywhere, replacing the three divergent behaviours in use today.
- **FR-009**: Formatting MUST NOT round-trip a stored decimal through a floating-point type at any point.

**Deployment configuration (US1)**

- **FR-010**: Formatting MUST be configurable per deployment through build-time keys on the existing app settings: `DATE_FORMAT`, `DATE_TIME_FORMAT`, `CURRENCY_SYMBOL`, `CURRENCY_CODE`, `CURRENCY_DECIMAL_DIGITS`, `PERCENT_DECIMAL_DIGITS`, `QUANTITY_DECIMAL_DIGITS`.
- **FR-011**: The default date format MUST be ISO `yyyy-MM-dd` and the default date-time format `yyyy-MM-dd HH:mm`.
- **FR-012**: Formatting MUST NOT be user-configurable. No control is added to the user settings screen and no formatting preference is persisted per device or per account.
- **FR-013**: A malformed or unreadable format value MUST fall back to that key's documented default rather than failing startup, consistent with the existing rule for a bad brand colour.
- **FR-014**: `.env.template` MUST document every formatting key with its default, a one-line description, and commented worked examples showing one fixed value rendered under each supported pattern.
- **FR-015**: The documented pattern set MUST cover, at minimum, ISO `yyyy-MM-dd` and local `d/M/yyyy` and `dd/MM/yyyy` for dates; the corresponding date-time patterns including a 24-hour time part; and the digit-count knobs for currency, percent and quantity.
- **FR-016**: The same pattern reference MUST also appear in this feature's formatting contract, so the design document and the deployer-facing template do not drift apart.

**Migration and enforcement (US1)**

- **FR-017**: All display-formatting call sites MUST move to the surface — approximately 78 across 22 files — and the three superseded paths MUST be removed, not left alongside it.
- **FR-018**: A test MUST fail the suite when a file outside a named allowlist reaches for date or number formatting directly, naming the offending file and line.
- **FR-019**: The allowlist MUST cover the formatting surface itself, generated sources, the startup call that initialises date formatting, and the sales-list date query facet.
- **FR-020**: The sales-list date query facet MUST remain locale- and configuration-independent; it encodes a URL parameter and is not a display path.
- **FR-021**: Golden and screenshot baselines rendering a date MUST be re-recorded once, as part of this feature, to reflect the new ISO default.
- **FR-022**: The enforcement test MUST land only after the final call site has migrated.

**Flex spacing (US2)**

- **FR-023**: A row or column whose gaps between adjacent children are all the same size MUST declare that gap once on the row or column, and its spacer widgets MUST be removed.
- **FR-024**: A row or column whose gaps between adjacent children differ MUST be left unchanged.
- **FR-025**: A spacer acting as a leading or trailing pad, or standing beside a single child, MUST be left unchanged.
- **FR-026**: Converted sites MUST keep the numeric gap value they use today. Adopting the design-token scale is out of scope for this feature.
- **FR-027**: The conversion MUST NOT alter rendered output. Every golden and screenshot baseline MUST pass unchanged after US2, against the baselines as re-recorded by US1.
- **FR-028**: Rows and columns skipped under FR-024 and FR-025 MUST be recorded, so a later reader can tell a deliberate skip from an unexamined site.

**Governance**

- **FR-029**: The constitution MUST be amended to require every screen to reach formatting through the shared surface — the rule drafted for v1.11.0 and withheld pending this feature — and the amendment MUST land with the code that satisfies it.

### Key Entities

- **Formatting surface**: The single point through which every displayed value passes. Owns the active locale and the deployment's format configuration; exposes a read-only display family and an editable-field family, the latter with parsers inverse to its formatters.
- **Formatting configuration**: The set of deployment-level format options — date and date-time patterns, currency symbol and code, and decimal-digit counts for currency, percent and quantity. Resolved once at startup, never mutable from the UI, each with a documented default.
- **Pattern reference**: The deployer-facing catalogue of valid pattern strings per data type, each with a worked example against one fixed value. Lives in `.env.template` and mirrored in the feature's formatting contract.
- **Format-enforcement guard**: The suite-level check that no file outside the allowlist formats dates or numbers directly, plus the allowlist itself.
- **Spacing conversion inventory**: The audited list of rows and columns, each marked converted, or skipped with the reason (non-uniform gaps, edge pad, single child).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero screens disagree on how a date, amount, percentage or quantity is rendered — a single audit across every feature module finds one rendering per data type.
- **SC-002**: Zero call sites specify a locale when formatting a value; the count drops from its current level to none.
- **SC-003**: A deployment changes the date format for the entire product by editing one line and rebuilding, with no source file modified and no screen left on the previous format.
- **SC-004**: An absent or unreadable value renders identically on every screen — one placeholder, down from three competing behaviours today.
- **SC-005**: Every editable value survives a load-and-save with no edit, byte-identical, verified across prices, rates and quantities including values whose stored precision exceeds their displayed precision.
- **SC-006**: A newly written screen that formats a value directly is rejected by the test suite, which names the file and line — verified by deliberately introducing one.
- **SC-007**: A deployer can determine the valid values for every formatting option, and see what each produces, from `.env.template` alone, without reading source or this specification.
- **SC-008**: The three superseded formatting implementations no longer exist in the codebase.
- **SC-009**: Golden and screenshot baselines are re-recorded exactly once for the ISO default; the count of baselines changed by the spacing work afterwards is zero.
- **SC-010**: Every row and column carrying uniform spacer widgets either declares its gap once or appears in the skip list with a stated reason; none is left unexamined.

## Assumptions

- **The carried-forward design is accepted as-is.** `contracts/formatting-surface.md` and `research.md` R3/R4/R8 from spec 027 are treated as finished design and copied into this feature, not re-derived. The single documented departure is the ISO default (FR-011), which supersedes that contract's byte-for-byte-defaults guarantee.
- **The audit numbers remain accurate.** ≈78 call sites across 22 files, distributed as 53 / 24 / 1 across the three paths. They were measured on 2026-08-16; planning re-verifies rather than assumes.
- **App settings already exist.** Spec 027 shipped the settings object and its build-time loading; this feature adds keys to it and does not rebuild the mechanism.
- **The user settings screen is untouched.** Appearance, text size and language ship as 027 delivered them.
- **No backend dependency.** Nothing here requires a change to mbe-api; formatting is entirely a presentation concern.
- **Deployment environment files are the delivery mechanism** for per-customer formatting, following the existing `deploy/<customer>.env` pattern.
- **The two stories are independent.** US2 touches no formatting code and US1 touches no layout structure; either can ship without the other. Only their interaction with test baselines is ordered (FR-021 before FR-027).
- **US2 is bounded by uniformity, not by file count.** The 199 spacer occurrences across 56 files are an upper bound on candidates, not a work estimate — a majority are expected to be excluded by FR-024 and FR-025.
