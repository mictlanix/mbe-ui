# Feature Specification: Casa Maestra Branding

**Feature Branch**: `077-casa-maestra-branding`
**Created**: 2026-11-20
**Status**: Draft
**Input**: Implement the Casa Maestra deployment branding from the Casa Maestra design system (https://claude.ai/artifact/XqxMRRyKYvf5auFTjWZ24t). No roadmap issue (user's decision).

## Clarifications

### Session 2026-11-20

- Q: How are today's catalog screens split across the four navigation sections? → A: Split by use (Option A). Customers go to Operación; products, price lists, suppliers and labels to Inventario; taxpayers, exchange rates, payment methods and expenses to Finanzas; users, profiles, employees and facilities to Sistema.
- Q: What are Casa Maestra's iOS bundle ID and Android application ID? → A: `com.mictlanix.xbe.cm` for both.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Casa Maestra build looks like Casa Maestra (Priority: P1)

Counter staff, warehouse crews and administrators at Casa Maestra open an app built for their deployment. They see the Casa Maestra lockup on the login screen, the Casa Maestra mark in the navigation header, navy actions and selections, Bitter titles, Roboto text and Roboto Mono record IDs. This works in both light and dark themes. A build made for any other deployment, or with no deployment chosen, still shows the XBE brand.

**Why this priority**: This is the reason for the spec. Casa Maestra cannot go live under another company's brand.

**Independent Test**: Build the app with the Casa Maestra brand selected. Open login, home and one list screen in each theme. Compare colors, fonts and logos with the design system.

**Acceptance Scenarios**:

1. **Given** a build with the Casa Maestra brand selected, **When** the login screen opens in the light theme, **Then** the branding pane shows the primary Casa Maestra lockup and filled buttons are navy `#00325F` with white text.
2. **Given** the same build in the dark theme, **When** the login screen opens, **Then** the branding pane shows the reversed lockup and every color role takes its dark value from the design system.
3. **Given** the same build, **When** any screen with a title opens, **Then** display, headline and title text uses Bitter, body and label text uses Roboto, and record IDs, folios, RFCs, SKUs and timestamps use Roboto Mono.
4. **Given** the same build at Expanded width or wider, **When** the navigation rail shows, **Then** its header shows the Casa Maestra mark and the name "Casa Maestra".
5. **Given** a build with no brand selected, **When** any screen opens, **Then** its colors, fonts and logos are the same as before this feature.

---

### User Story 2 - Status reads by icon and word, in every brand (Priority: P1)

A user scans a list of orders, payments or documents and reads each record's state at a glance. Every status chip shows an icon and a word, in a tone that matches its meaning: success, warning, error, info, neutral or promo. Because Casa Maestra's brand color is red, an error is never shown by red alone, and brand red never marks an error.

**Why this priority**: Without it, the Casa Maestra palette makes "Cancelado" and brand decoration look the same. The rule also helps color-blind users in every deployment.

**Independent Test**: Open each list screen that shows a status chip, in both brands and both themes. Check every status has an icon, a word and the tone for its meaning.

**Acceptance Scenarios**:

1. **Given** any list with a paid, active or completed record, **When** it renders, **Then** that record's chip uses the success tone with an icon and a word.
2. **Given** a pending, low-stock or credit-limit state, **When** it renders, **Then** its chip uses the warning tone with an icon and a word.
3. **Given** a cancelled or rejected record, **When** it renders, **Then** its chip uses the error tone with an icon and a word, and that tone's color differs from the brand accent.
4. **Given** the Compact width tier, **When** a status shows in a list row, **Then** it can show as a colored dot whose tooltip and accessible name give the word.

---

### User Story 3 - App chrome carries the brand rule and grouped navigation (Priority: P2)

A user moving around the app sees a thin accent rule under the app bar and finds destinations under four sections: Operación, Inventario, Finanzas and Sistema. This applies to every deployment.

**Why this priority**: It completes the Casa Maestra look and shortens the menu. The app works without it.

**Independent Test**: Open the app in either brand at each width tier. Check the app-bar rule and that every destination the user can reach sits under one of the four sections.

**Acceptance Scenarios**:

1. **Given** any screen with an app bar, **When** it renders, **Then** a 3px rule in the brand's accent color shows directly below it.
2. **Given** the navigation rail or drawer, **When** it opens, **Then** destinations are grouped under Operación, Inventario, Finanzas and Sistema, in that order, and no destination the user could reach before is missing.
3. **Given** a user without rights to any destination in a section, **When** navigation shows, **Then** that section header is hidden.

---

### User Story 4 - Casa Maestra ships as its own app (Priority: P2)

The release manager runs the existing release scripts with the Casa Maestra brand. The scripts produce iOS, Android and web builds with Casa Maestra's own app ID, name, icons, splash, web title and theme color.

**Why this priority**: Casa Maestra needs its own store app, but the in-app branding can be tested before packaging exists.

**Independent Test**: Run the release scripts for the Casa Maestra brand in build-only mode. Inspect the produced builds' app ID, display name, icons, splash and web manifest.

**Acceptance Scenarios**:

1. **Given** the Casa Maestra brand, **When** the release scripts build Android, **Then** the build has Casa Maestra's application ID, display name and launcher icons made from the mark.
2. **Given** the Casa Maestra brand, **When** the release scripts build iOS, **Then** the build has Casa Maestra's bundle ID, display name, app icon and splash.
3. **Given** the Casa Maestra brand, **When** the release scripts build web, **Then** the page title, short name, favicon and theme color are Casa Maestra's.
4. **Given** the existing `mbe` brand, **When** its release runs, **Then** its output is unchanged.

---

### Edge Cases

- An unknown brand ID is given at build time: the build falls back to the default XBE brand and says so in debug output. It never fails to start.
- A brand ID and the older seed-color setting are both given: the brand ID wins.
- The user turns on large text (scale 1.3 and up): Bitter titles and Roboto Mono IDs must not overflow where today's fonts fit.
- Brand red `#FF2014` with white text is 3.84:1: it is used only for the logo and marks, never behind small text.
- The reversed lockup is a recolor of the primary file, not a file from the brand owner: it is fine on screen, but print use waits for brand-owner confirmation.
- A status the server adds later and the app does not know: it shows in the neutral tone with its raw word, never unstyled.
- A destination added later with no section: the build or a test catches it, so it never silently disappears.

## Requirements *(mandatory)*

### Functional Requirements

**Brand selection**

- **FR-001**: A build MUST select its brand by a brand ID set at build time. With no brand ID, the build MUST use the default XBE brand.
- **FR-002**: Each brand MUST define, in reviewed code, its exact color for every color role in both light and dark themes, its font families, and its logo assets. Values MUST be copied from the brand's source, never derived by algorithm.
- **FR-003**: An unknown brand ID MUST fall back to the default brand without failing startup.
- **FR-004**: The default brand's colors, fonts and logos MUST stay the same as before this feature. The only visible changes to a default build are those required by FR-013 to FR-019.
- **FR-005**: A brand MAY override only color, typography and logo assets. Spacing, shape, elevation, density and breakpoints MUST stay shared by all brands.

**Casa Maestra brand**

- **FR-006**: The Casa Maestra brand MUST use the design system's exact values for every color role in both themes, listed under Verbatim Constraints.
- **FR-007**: Casa Maestra MUST use Bitter for display, headline and title styles, Roboto for body and label styles, and Roboto Mono for the mono styles. All three MUST be bundled with the app, so no font loads from the network.
- **FR-008**: Casa Maestra's type styles MUST use the design system's sizes, line heights, weights and letter spacing.
- **FR-009**: Casa Maestra MUST show the primary lockup on the login branding pane in the light theme and the reversed lockup in the dark theme. The mark MUST show in the navigation header.
- **FR-010**: Logo files MUST be the design system's own files, never redrawn or approximated.
- **FR-011**: Brand red MUST NOT fill any interactive control. The only red-filled button is the destructive action inside a confirmation dialog, and it uses the error color, not the brand red.
- **FR-012**: The navigation header MUST show the mark alone at Compact and Medium, and the mark plus the brand's display name at Expanded and Large.

**Shared chrome (every brand)**

- **FR-013**: The theme MUST offer accent, success and warning roles, each with an on-color, a container and an on-container color, in both themes, for every brand. The default brand's values for these roles are its own (see Assumptions).
- **FR-014**: Every status chip MUST show an icon and a word. Its tone MUST be one of success, warning, error, info, neutral or promo, picked by the status's meaning.
- **FR-015**: Only the promo tone MAY use the accent container. The error tone MUST be visibly different from the accent.
- **FR-016**: Error messages on fields and banners MUST carry an icon as well as text.
- **FR-017**: Every app bar MUST show a 3px rule in the accent color directly below it.
- **FR-018**: Navigation MUST group destinations under four sections, Operación, Inventario, Finanzas and Sistema, in that order. Every destination MUST belong to exactly one section, split by use:
  - **Operación**: customers, POS, sales orders, quotes, pricing, cash sessions, delivery orders, delivery order approval, for delivery, delivery itineraries, vehicles, vehicle operators.
  - **Inventario**: products, price lists, suppliers, labels, warehouse receipts, warehouse issues, transfers, physical counts, stock, kardex.
  - **Finanzas**: payments, payment verification, credit notes, refunds, fiscal documents, taxpayer issuers, taxpayer recipients, exchange rates, payment method options, expenses.
  - **Sistema**: users, user profiles, employees, facilities.
- **FR-019**: Record IDs, folios, RFCs, SKUs and timestamps shown in lists and detail screens MUST use the mono styles in every brand.
- **FR-020**: Every text and background pair used by a role MUST meet 4.5:1 contrast, or 3:1 for text 24px and larger, control borders, focus rings and icons, in both themes of every brand.

**Packaging**

- **FR-021**: The release scripts MUST accept a Casa Maestra brand with its own bundle ID, application ID, display name, web title, web short name and web theme color. Its iOS bundle ID and Android application ID are both `com.mictlanix.xbe.cm`.
- **FR-022**: The Casa Maestra app icons, adaptive icon, splash and favicons MUST be made from the mark file.
- **FR-023**: The Casa Maestra release MUST build the app with the Casa Maestra brand ID set.
- **FR-024**: The existing `mbe` brand's release output MUST not change.

### Key Entities

- **Brand**: one deployment's identity. It has an ID, a display name, a light and a dark color set, font families per style group, a lockup, a reversed lockup and a mark. Exactly one brand is active per build.
- **Color role**: a named slot in the theme (for example primary, accent, success-container) with a light and a dark value.
- **Status tone**: the meaning a status chip shows (success, warning, error, info, neutral, promo). Each tone maps to a pair of color roles and comes with an icon.
- **Navigation section**: one of the four top-level groups. Each destination belongs to exactly one.
- **Release brand**: the packaging record for one brand, holding app IDs, names, artwork and web settings.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a Casa Maestra build, 100% of the design system's color roles match their exact values in both themes.
- **SC-002**: A default build's golden screenshots of login, home and one list screen match their pre-feature versions, except for the app-bar rule, status chips and navigation sections.
- **SC-003**: 100% of status chips across all screens show an icon and a word.
- **SC-004**: 100% of role pairs pass the contrast thresholds in FR-020, in both themes of both brands.
- **SC-005**: Every destination reachable before this feature is reachable after it, under exactly one of the four sections.
- **SC-006**: The Casa Maestra build-only release completes for iOS, Android and web with no manual step beyond running the script.
- **SC-007**: No Casa Maestra screen at text scale 1.3 shows an overflow that the default brand does not show.

## Assumptions

- No mbe-roadmap issue covers this work. The user chose not to link one.
- The default XBE brand gets its own values for the new roles. Accent reuses the XBE orange (today's tertiary). Success and warning come from M3 green and amber tones, checked for contrast, because the XBE brand guide defines neither. These are recorded as product choices, not brand-guide values.
- Home stays the first destination, outside the four sections.
- The design system's per-slot type table matches the product's slot table in DESIGN-SYSTEM.md, so only family, weight and tracking differ by brand.
- Fonts come from their open-source releases (OFL / Apache 2.0) and ship with their license files.
- The reversed lockup may ship for on-screen use now. Printed documents keep the primary lockup until the brand owner confirms the reversed one.
- The old seed-color build setting keeps working for builds that do not set a brand ID.
- The Compact-tier card list for data tables, named in the design system as not built, stays out of scope.

## Verbatim Constraints

Brand ID, used both as the build setting and as the release brand's name: `xbe.cm`. iOS bundle ID and Android application ID: `com.mictlanix.xbe.cm`. Display name: `Casa Maestra`. Navigation sections: `Operación`, `Inventario`, `Finanzas`, `Sistema`.

Fonts: `Bitter`, `Roboto`, `Roboto Mono`.

Logo files: `casa-maestra-logo.png`, `casa-maestra-mark.png`, `casa-maestra-logo-reversed.png`.

Casa Maestra colors (light / dark):

| Role | Light | Dark |
| --- | --- | --- |
| `brand-navy` | `#00325F` | `#00325F` |
| `brand-red` | `#FF2014` | `#FF2014` |
| `primary` | `#00325F` | `#A9C7F0` |
| `on-primary` | `#FFFFFF` | `#002D55` |
| `primary-container` | `#D5E3F8` | `#1C4675` |
| `on-primary-container` | `#001B3A` | `#D5E3F8` |
| `accent` | `#D7190F` | `#FF8E7E` |
| `on-accent` | `#FFFFFF` | `#3B0400` |
| `accent-container` | `#FFDAD4` | `#7A1209` |
| `on-accent-container` | `#4A0500` | `#FFDAD4` |
| `surface` | `#F6F8FB` | `#0C1420` |
| `surface-container-lowest` | `#FFFFFF` | `#080E18` |
| `surface-container-low` | `#FFFFFF` | `#121B28` |
| `surface-container` | `#EEF2F7` | `#162030` |
| `surface-container-high` | `#E9EDF3` | `#1E2837` |
| `surface-container-highest` | `#E1E7EF` | `#283344` |
| `on-surface` | `#0F1C2E` | `#E2E8F1` |
| `on-surface-variant` | `#46536A` | `#B9C3D3` |
| `outline` | `#76839A` | `#8994A8` |
| `outline-variant` | `#C9D1DC` | `#334055` |
| `error` | `#BA1A1A` | `#FFB4AB` |
| `on-error` | `#FFFFFF` | `#690005` |
| `error-container` | `#FFDAD6` | `#93000A` |
| `on-error-container` | `#410002` | `#FFDAD6` |
| `success` | `#1B6B3A` | `#7FD69A` |
| `success-container` | `#C9EFD3` | `#0F4A26` |
| `on-success-container` | `#00210D` | `#C9EFD3` |
| `warning` | `#855300` | `#FFB95E` |
| `warning-container` | `#FFDDB3` | `#5A3A00` |
| `on-warning-container` | `#2A1700` | `#FFDDB3` |
| `scrim` | `#000000` | `#000000` |

Casa Maestra type styles (size / line height / weight / tracking):

| Style | Family | Size | Line | Weight | Tracking |
| --- | --- | --- | --- | --- | --- |
| `display-large` | Bitter | 57 | 64 | 700 | −0.75 |
| `display-medium` | Bitter | 45 | 52 | 700 | −0.5 |
| `display-small` | Bitter | 36 | 44 | 700 | −0.25 |
| `headline-large` | Bitter | 32 | 40 | 700 | −0.25 |
| `headline-medium` | Bitter | 28 | 36 | 600 | 0 |
| `headline-small` | Bitter | 24 | 32 | 600 | 0 |
| `title-large` | Bitter | 22 | 28 | 600 | 0 |
| `title-medium` | Bitter | 16 | 24 | 600 | 0.15 |
| `title-small` | Bitter | 14 | 20 | 600 | 0.1 |
| `body-large` | Roboto | 16 | 24 | 400 | 0.5 |
| `body-medium` | Roboto | 14 | 20 | 400 | 0.25 |
| `body-small` | Roboto | 12 | 16 | 400 | 0.4 |
| `label-large` | Roboto | 14 | 20 | 500 | 0.1 |
| `label-medium` | Roboto | 12 | 16 | 500 | 0.5 |
| `label-small` | Roboto | 11 | 16 | 500 | 0.5 |
| `mono-medium` | Roboto Mono | 14 | 20 | 400 | 0 |
| `mono-small` | Roboto Mono | 12 | 16 | 400 | 0 |

App-bar rule: `3px`, color `accent`.
