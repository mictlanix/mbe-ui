# Feature Specification: App Settings, User Settings & Cross-Widget Consistency

**Feature Branch**: `027-app-user-settings`

**Created**: 2026-08-16

**Status**: Draft

**Input**: User description: "Let's create a spec to enforce consistency across every widget from the app. (1) I've noticed some texts that show dates and currency data with different formatting. (2) Some list screens don't align with the catalogs established design — `cash_sessions_screen.dart` has a form built in at the top, `pos_sales_list_screen.dart` has filter chips on the first row and I think it should instead show the filters icon button that other screens show, and display the right drawer that shows the filters. (3) I'd like to also enforce that UI elements are built aligned and have symmetry on their margins/paddings — there is more bottom padding on the sales order lines, and a baseline mismatch; if they were aligned to the total price baseline, the bottom padding would be symmetrical. To tackle the first issue, I'd like to introduce app settings and user settings to the project. App settings should include data type formatting, app localization, and other customizable options implemented through environment variables, loaded through `.env` files. User settings needs a screen to let the user choose displayed app theme (dark/light) and overall font sizes for accessibility (maybe 4 levels). For the other points, I think updating `constitution.md` can do the job."

## Clarifications

### Session 2026-08-16

- Q: Should this feature also fix the non-compliant screens, or only establish the settings and the constitution rules? → A: Settings **and** remediation of the two named screens (`cash_sessions_screen.dart`, `pos_sales_list_screen.dart`) plus the reported POS sale-line padding/baseline defect. Every other screen is audited and listed, but corrected when next touched — not swept here.
- Q: How should app settings load from `.env`? → A: Build-time only, via `--dart-define-from-file=.env` feeding compile-time constants — the pattern `brand_config.dart`, `dio_client.dart`, `photo_url.dart` and `pos_defaults.dart` already use, and the mechanism the existing `.env`/`.env.template` already serve for integration tests. No runtime-parsed config file, no new dependency; constitution §V's build-time rule stays intact.
- Q: Where do the user's display preferences (theme, text size, language) live? → A: Device-local, extending the existing `shared_preferences`-backed `ThemeModeController`. Not server-side: mbe-api's `UserSettingsResponse` carries no display fields and this feature must ship with **zero** backend dependency.
- Q: Should the user be able to pick a language? → A: Yes, at both levels — the deployment's default locale becomes an app setting (replacing the hard-coded `Locale('es', 'MX')` in `lib/app/app.dart`), and the user settings screen offers a per-user override (Español / English / follow system). Both `app_es.arb` and `app_en.arb` already exist.
- Q: The alignment/symmetry rule is described as a constitution change. Is the constitution amendment part of this feature? → A: The amendment is authored alongside this spec (constitution §VI, plus the configuration-levels and text-size rules under §V) and governs future work; this feature's own scope is the code that makes the amendment true for the named screens. *(The formatting rule originally included here was withdrawn when formatting was descoped — see the entry below.)*
- Q: Where does the open/close-shift panel go once it comes off the cash-sessions list? → A: Into a dialog or side sheet launched from a toolbar action beside the search row, leaving the route a pure list screen that conforms to every other catalog. The cost — one click to reach a many-times-daily action, and the shift's state no longer visible at a glance — is accepted, with the mitigation that the toolbar action itself must communicate the current shift state rather than reading as a neutral button (FR-028a).
- Q: **Descope (decided after planning, 2026-08-16.)** Planning sized the formatting work at ≈78 call sites across 22 files — larger than the rest of the feature combined, and a single indivisible change, since the guard test cannot land until the last call site moves. Should it stay in this feature? → A: **No.** Value formatting moves to a future spec. Removed from this feature: US1, FR-008…FR-015, SC-001/002/010, and the formatting keys FR-002 would have added to app settings. The audit and the design work survive in `research.md` R3/R4, `contracts/formatting-surface.md` and `data-model.md` §2, all marked as carried forward, so the future spec starts from a finished design rather than re-deriving it. Two consequences follow: app settings ships covering the deployment default locale and the consolidation of existing environment values only (formatting keys would otherwise be configuration nothing reads), and the formatting-surface rule comes **back out** of constitution v1.11.0 — a rule requiring every screen to use a surface that does not exist yet is unsatisfiable, and this repo's own governance lands a rule with the first code that complies with it.

## User Scenarios & Testing *(mandatory)*

> **Numbering note.** US1 and FR-008…FR-015 covered value formatting and were
> **descoped on 2026-08-16** (see Clarifications) into a future spec. The
> remaining stories and requirements keep their original numbers rather than
> being renumbered, so the cross-references in `plan.md`, `research.md` and
> `contracts/` stay valid. The gaps are deliberate.

---

### User Story 2 - A deployment is configured without touching source (Priority: P2)

Someone deploying MBE for a customer sets that deployment's default locale, API endpoints and brand tokens in one `.env` file, builds, and gets a correctly-configured app. They can see every available option, and its default, in one documented place.

**Why this priority**: Consolidates the deployment options currently scattered across four unrelated files, which is what makes "what can I configure?" answerable at all, and gives the deployment's default locale a home — the value US3's language override falls back to. With formatting descoped, this is the highest-value story remaining.

**Independent Test**: Build with a `.env` that changes the default locale and the API base URL; confirm the app comes up in that language against that host. Build with no `.env` at all; confirm it starts on the documented defaults.

**Acceptance Scenarios**:

1. **Given** a `.env` setting a non-default API base URL, **When** the app is built with it, **Then** every request targets that host — the consolidation changes where the value is read from, never what it is.
2. **Given** a `.env` setting the default locale to English, **When** a user with no personal language override opens the app, **Then** the interface renders in English.
3. **Given** no `.env` file is supplied at build time, **When** the app starts, **Then** it runs with documented defaults and no missing-configuration error.
4. **Given** a `.env` with a malformed value (e.g. an unsupported locale code or a non-numeric customer id), **When** the app starts, **Then** it falls back to that option's default rather than failing to start.
5. **Given** `.env.template`, **When** a deployer reads it, **Then** every configurable option is listed with its default and a one-line description.

---

### User Story 3 - A user adjusts theme, text size and language (Priority: P2)

A signed-in user opens their settings from the user menu and chooses a light or dark appearance, one of four overall text sizes, and their preferred language. Every choice applies immediately and survives a restart of the app on that device.

**Why this priority**: This is the accessibility half of the request and the only net-new screen. It is independent of US2 apart from the default locale it falls back to — the theme preference already exists and is already persisted; this exposes it, adds text size and language beside it, and gives the app a home for future per-user display preferences.

**Independent Test**: Open the settings screen, change each control, observe the app update without a reload, restart, and confirm the choices persisted.

**Acceptance Scenarios**:

1. **Given** the settings screen, **When** the user selects Light, Dark or System, **Then** the whole app's appearance updates immediately and the choice persists across a restart.
2. **Given** the settings screen, **When** the user selects one of four text-size levels, **Then** text throughout the app scales accordingly, remains legible, and no screen at the target desktop width clips, overflows or hides content at the largest level.
3. **Given** the settings screen, **When** the user selects Español, English or "follow system", **Then** the interface language and all formatted dates/numbers change accordingly and the choice persists across a restart.
4. **Given** a user who has never opened the settings screen, **When** they use the app, **Then** they get the deployment's configured defaults (US2), not a hard-coded fallback.
5. **Given** the user menu, **When** the user opens it, **Then** a settings entry is present alongside the existing change-password entry and leads to this screen.

---

### User Story 4 - The POS sales list filters like every other list (Priority: P3)

A cashier filtering the register's sales finds the same filters control they use on every other list screen: one filters icon button, badged with the number of active filters, opening the right-hand filter drawer.

**Why this priority**: A visible, self-contained inconsistency the user named directly. Low risk and independently shippable, but it changes no data and blocks nothing else.

**Independent Test**: Open `/sales/pos`, confirm the first row shows a search box plus the badged filters icon button (no inline date-range or status chips), open the drawer, apply a date range and a status, confirm the list and the URL both reflect them and the badge count updates.

**Acceptance Scenarios**:

1. **Given** the POS sales list, **When** it is displayed, **Then** the filter row shows the search box, the primary action, and one badged filters icon button — no inline facet chips.
2. **Given** the filters drawer, **When** the cashier sets a date range and a status and applies them, **Then** the list filters accordingly and the URL carries both facets, exactly as before this change.
3. **Given** active filters, **When** the cashier chooses clear-all, **Then** every facet resets to the screen's default (today's range, no status) and the badge disappears.

---

### User Story 5 - The cash-sessions screen matches the catalog list structure (Priority: P3)

A cashier opening or closing a shift, and a supervisor reviewing shift history, each get a screen that follows the app's established structure rather than a form stacked on top of a list. The shift itself opens and closes in a sheet launched from the list's toolbar, and that toolbar action says at a glance whether a shift is open.

**Why this priority**: The second inconsistency the user named. Ranked below US4 because the remedy is not purely cosmetic — opening a shift is this route's most frequent action, so moving it into a sheet is only safe if the toolbar action carries the state the inline panel used to show.

**Independent Test**: Open the cash-sessions route with no open shift, with an open shift, and with a stale shift; confirm the route is a standard list screen in all three, that the toolbar action reflects the shift state in each, and that opening and closing a shift each complete in at most one interaction more than today.

**Acceptance Scenarios**:

1. **Given** the cash-sessions route, **When** it is displayed, **Then** it is a standard list screen — filter row, list, pagination — with no form embedded above it.
2. **Given** a cashier with no open shift, **When** they reach the route, **Then** a toolbar action reading as "open a shift" is visible without scrolling, and activating it opens the shift panel as a dialog or side sheet.
3. **Given** a cashier with an open or stale shift, **When** they reach the route, **Then** the toolbar action communicates that state — including staleness — rather than reading as a neutral button, and opening it shows the shift's drawer, start time, opening amount, payments by method, stale warning and other-open-sessions note, with the close action, losing nothing the current inline panel shows.
4. **Given** the shift sheet is open and the cashier opens or closes a shift, **When** the operation succeeds, **Then** the sheet dismisses, the history list reflects the change without a manual reload, and the toolbar action updates to the new state.
5. **Given** a user without the privilege to open a shift, **When** they reach the route, **Then** they see the history list and no shift toolbar action — never a disabled one.
6. **Given** a list screen whose endpoint has no free-text search, **When** it renders its filter row, **Then** it omits the search control cleanly rather than reserving empty space for one.

---

### User Story 6 - Rows and cards are vertically symmetric and baseline-aligned (Priority: P3)

A user scanning a list of sale lines sees each line's controls and its line total sitting on one baseline, with equal space above and below the row's content — not a row that reads as bottom-heavy.

**Why this priority**: The specific defect the user reported with a screenshot. Self-contained and verifiable, but it is one screen; the durable win is the constitution rule it establishes for every screen after it.

**Independent Test**: Render a POS sale line at the single-row layout width and assert that top and bottom insets are equal and that the control band's text baseline and the line-total's baseline agree.

**Acceptance Scenarios**:

1. **Given** a POS sale line in the single-row layout, **When** it is rendered, **Then** the space above its content equals the space below it.
2. **Given** the same line, **When** it is rendered, **Then** the text baseline of the control band (warehouse, quantity, price, discount, tax) and the baseline of the line total coincide.
3. **Given** a product name long enough to wrap to two lines, **When** the line is rendered, **Then** vertical symmetry and baseline agreement both still hold and the line's height is unchanged.
4. **Given** the two-row and card layouts of the same line, **When** each is rendered, **Then** vertical symmetry holds in each.
5. **Given** any padding or margin introduced by this feature, **When** the source is reviewed, **Then** its value comes from the shared design-token scale, not an ad-hoc literal.

---

### Edge Cases

- **A locale with no bundled translations.** A `.env` naming a locale outside the supported set must fall back to the deployment default, not render untranslated keys.
- **Largest text size on the densest screen.** The POS capture screen's fixed-width column budget was tuned at a specific text size; the largest accessibility level must not silently push it into overflow or into the fallback two-row layout. This must be verified, and the resolution recorded — either the layout absorbs it or the level's ceiling is bounded.
- **Preference set on one device only.** Device-local persistence means a user signing in elsewhere gets the deployment defaults, not their choices. Expected, and must not be presented as a sync failure.
- **Preference storage unavailable or corrupt.** Unreadable stored preferences must fall back to defaults silently, never block startup.
- **Language changed mid-task.** Changing the language while a form holds unsaved input must not discard that input.
- **Clearing filters on a screen with a default filter.** The POS sales list defaults to today's range; "clear all" must return to that default, not to an unbounded range.
- **Navigating out of the shift sheet.** The open-shift form can surface a blocked-by-another-session error whose remedy navigates to that session's detail screen; from inside a sheet, that navigation must dismiss the sheet cleanly rather than leaving it stranded over a new route.
- **The shift sheet at the largest text size.** The sheet is a new surface carrying a form; it must satisfy FR-024 at the largest text-size level like every other screen.

## Requirements *(mandatory)*

### Functional Requirements

#### App settings (deployment-level)

- **FR-001**: The app MUST resolve a single, centrally-defined app-settings value at startup, from build-time environment values supplied by a `.env` file.
- **FR-002**: App settings MUST cover the deployment's default locale. *(Formatting options — currency symbol/code/decimal digits, date, date-time, percentage and quantity patterns — were descoped with the formatting work on 2026-08-16; adding keys nothing reads would be configuration without a consumer. The future formatting spec adds them here.)*
- **FR-003**: App settings MUST consolidate the deployment options currently defined at scattered call sites — API base URL, photos base URL, brand tokens (display name, seed color, welcome/lockup/mark assets), and POS defaults — so one place lists every deployment-configurable option. Existing option names and defaults MUST be preserved so current deployment scripts keep working.
- **FR-004**: Every app setting MUST have a documented default; the app MUST start and function with no `.env` supplied.
- **FR-005**: A malformed or unrecognized value for any app setting MUST fall back to that setting's default rather than preventing startup.
- **FR-006**: `.env.template` MUST list every app setting with its default and a one-line description, and MUST remain the single source of that documentation.
- **FR-007**: App settings MUST NOT be reachable or mutable from the user interface — they are deployment configuration, not preferences.

#### Formatting — **descoped 2026-08-16, moved to a future spec**

FR-008 … FR-015 covered the single formatting surface, its read-only/editable
split, its round-trip guarantee and its guard test. They are **not** part of
this feature. The finished design is carried forward in
[contracts/formatting-surface.md](contracts/formatting-surface.md),
[research.md](research.md) R3/R4 and [data-model.md](data-model.md) §2 for the
spec that takes it on; the audit that sized it (≈78 call sites across 22
files, in three divergent paths) is in research.md R8.

This feature therefore does **not** change how any value is currently
rendered.

#### User settings (device-level)

- **FR-016**: The app MUST provide a settings screen for the signed-in user, reachable from the existing user menu.
- **FR-017**: The screen MUST let the user choose appearance: Light, Dark, or follow system. This MUST supersede the current theme preference without losing an already-persisted choice.
- **FR-018**: The screen MUST let the user choose a language among the supported locales plus "follow system"; the deployment default (FR-002) applies when the user has expressed no choice.
- **FR-019**: The screen MUST let the user choose among exactly four overall text-size levels, applied app-wide.
- **FR-020**: Every user setting MUST apply immediately on selection — no restart, no re-login.
- **FR-021**: Every user setting MUST persist on the device and be restored on next launch.
- **FR-022**: Unreadable or corrupt stored preferences MUST fall back to defaults silently.
- **FR-023**: The settings screen MUST follow the established screen and form conventions (shared responsive form grid, shared action area, empty app-bar actions).
- **FR-024**: At the largest text-size level, no screen at the supported desktop widths may clip, overflow, or hide content. Where a fixed-width layout cannot absorb the largest level, the resolution MUST be recorded in the plan rather than left to chance.

#### List-screen structure

- **FR-025**: Every list screen MUST present its facet filters through the shared filters icon button — badged with the active-filter count — opening the shared filter drawer. Facet controls MUST NOT be placed inline in the filter row.
- **FR-026**: The POS sales list MUST be converted to FR-025, preserving its current facets (date range, status), its URL-driven state, its default of today's range, and its clear-all behavior.
- **FR-027**: The cash-sessions route MUST become a standard list screen, with no form embedded above the history list. The open/close-shift panel MUST move into a dialog or side sheet launched from a toolbar action in the list's filter row.
- **FR-028**: The shift sheet MUST preserve every piece of information and every action the current inline panel provides: drawer selection (or the assigned-drawer static label when the user cannot browse drawers), opening amount, validation and blocking-session errors, and — for an open or stale shift — drawer name, start time, opening amount, payments by method, the stale warning, the other-open-sessions note, and the close action.
- **FR-028a**: The toolbar action that launches the sheet MUST communicate the current shift state — no shift, open, or stale — rather than reading as a neutral button, since the state is no longer visible inline.
- **FR-028b**: Completing an open or close from the sheet MUST dismiss it, refresh the history list without a manual reload, and update the toolbar action to the new state.
- **FR-028c**: Opening or closing a shift MUST take at most one interaction more than it does today, and the toolbar action MUST be visible without scrolling.
- **FR-029**: The shared filter row MUST support a list screen that has no free-text search, omitting the control rather than requiring each screen to pass an empty placeholder.
- **FR-030**: Screens outside this feature's scope that violate FR-025 MUST be inventoried in the plan, with the inventory naming each screen and its violation, for correction when next touched.

#### Alignment & symmetry

- **FR-031**: Within a row or card, vertical padding MUST be symmetric — the space above the content equals the space below it.
- **FR-032**: Controls and text sharing a horizontal band MUST share a text baseline.
- **FR-033**: The POS sale line MUST satisfy FR-031 and FR-032 in each of its three layouts, with the control band aligned to the line-total baseline, and MUST NOT regress its existing guarantees: fixed line height independent of product-name wrapping, and no overflow at the tablet width the current tests pin.
- **FR-034**: Padding and margin values introduced or changed by this feature MUST come from the shared design-token scale, not ad-hoc literals.
- **FR-035**: Compliance with FR-031 and FR-032 for the POS sale line MUST be verified by automated tests that assert measured insets and baselines, not by inspection.

#### Governance

- **FR-036**: The project constitution MUST be amended to state, as binding rules: the two-levels-of-configuration and text-size rules (FR-001/FR-007, FR-019/FR-024), the list-screen filter-drawer rule (FR-025), the no-embedded-form rule (FR-027), and the symmetry/baseline rules (FR-031/FR-032/FR-034). The amendment MUST follow the constitution's own governance process, including the DESIGN.md update that precedes it. The single-formatting-surface rule MUST NOT be included: it requires a surface this feature no longer builds, and this repo's governance lands a rule together with the first code that complies with it. It belongs to the future formatting spec.

### Key Entities

- **App Settings**: The deployment's fixed configuration — default locale, endpoints, brand tokens, POS defaults. Resolved once at startup from build-time values; immutable for the life of the process; never user-editable.
- **User Display Preferences**: The signed-in user's device-local choices — appearance, text size, language. Mutable at any time, applied immediately, persisted per device, independent of the server-side user settings that already carry the user's cash drawer and point of sale.
- **Text Size Level**: One of exactly four named accessibility steps, each mapping to a defined app-wide text scale.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-003**: A deployer can change the default locale, endpoints and brand for a whole deployment by editing one file, with no source change.
- **SC-004**: Every deployment-configurable option is discoverable from one document, with its default stated.
- **SC-005**: A user can change appearance, text size and language and see each take effect in under 3 seconds, with no restart, and finds all three choices intact after restarting the app.
- **SC-006**: At the largest text-size level, zero screens clip, overflow or hide content at supported desktop widths.
- **SC-007**: 100% of list screens in this feature's scope present facet filters through the badged filters button and drawer; zero present them inline.
- **SC-008**: Opening or closing a shift takes no more interactions than it does today, plus at most one.
- **SC-009**: A POS sale line's measured top and bottom insets are equal, and its control-band and line-total baselines coincide, in all three of its layouts.
- **SC-010**: No value anywhere in the app renders differently after this feature than before it — formatting is untouched.
- **SC-011**: No mbe-api change is required; the feature ships against the current backend.

## Assumptions

- **Reuse over replacement for existing behavior**: existing environment keys and defaults are preserved exactly, so nothing a current deployment does changes unless its `.env` says so. The consolidation is about where a value comes from, not what it is.
- **Text-size levels**: four levels spanning roughly 0.9× to 1.3× of the base scale, with the second level as the default (1.0×). Exact factors are a planning decision; the count (four) and the "applies app-wide, immediately" behavior are the requirement.
- **Language coverage**: the supported set is the two locales that already have translation files (`es`, `en`). Adding locales is out of scope; the settings screen must simply list whatever is supported rather than hard-coding two options.
- **Settings screen placement**: a route beside the existing account/password route, entered from the user menu. No new navigation section.
- **No RBAC gate on user settings**: display preferences are personal, available to every signed-in user; no privilege check applies.
- **The server-side `UserSettings` (cash drawer, point of sale) is untouched.** The new preferences are a separate, device-local concern that must not be confused with it — naming in the implementation should keep the two distinguishable.
- **The constitution amendment is authored in the same change as the first screens that comply with it**, per the governance precedent of not leaving shipped screens between two rules.
- **The POS capture screen's column budget is the main text-size risk.** Its widths were tuned against specific text sizes and a documented minimum width; FR-024's verification should start there.

## Dependencies

- **None on mbe-api.** This feature must ship against the current backend (SC-011).
- **Existing design tokens** (the shared spacing scale and tier-resolved theme) are the source for FR-034 and are already in place.
- **Existing shared list components** (filter bar, filter drawer, search bar, table view, list state views) are the target structure for FR-025 through FR-029 and are already in place.
- **The constitution amendment (FR-036)** and its preceding DESIGN.md update are authored as part of this feature.

## Out of Scope

- **All value formatting** — the single formatting surface, its guard test, and the ≈78-call-site migration. Descoped 2026-08-16 into a future spec, which inherits the finished design in `contracts/formatting-surface.md`, `research.md` R3/R4/R8 and `data-model.md` §2.
- Sweeping every remaining screen for filter-drawer compliance. Screens outside the named two are inventoried (FR-030) and corrected when next touched.
- Any mbe-api change, including syncing display preferences to the server.
- Adding new locales or new translations beyond what the existing translation files carry.
- Compact/phone-tier redesign work beyond what the settings screen itself and FR-024's text-size verification require.
- Per-user overrides of app settings (formats, endpoints, brand). The two levels stay distinct: deployment configuration versus personal display preferences.
- Reworking the POS capture screen's layout beyond the symmetry and baseline fix in FR-033.
