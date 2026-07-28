# Feature Specification: XBE Default Branding

**Feature Branch**: `019-xbe-default-branding`

**Created**: 2026-07-28

**Status**: Draft

**Input**: User description: "Implement XBE Business Essentials branding on the app's default flavor (i.e. the build produced with no per-deployment brand override set), replacing today's unbranded placeholders: the hardcoded generic Material seed color, the stock app icon/splash, and the generic app labels/titles across platforms. Source: the 'XBE Look and Feel' brand guide — Material 3 dark-mode-first color tokens (gold primary, orange accent, red reserved for error states, warm neutrals), Archivo/Roboto/Roboto Mono typography, and an SVG/PNG lockup+isologo asset set with documented placement, clear-space, and minimum-size rules for login, navigation, splash, app icon, and watermark placements. The existing per-deployment white-label override mechanism must be unaffected — this only changes what a deployment sees when it sets no brand override."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Cohesive in-app brand experience (Priority: P1)

A user of the default (non-customer-specific) deployment opens the app and
navigates through core screens (login, home, a data list). Instead of the
current generic Material indigo color scheme, they see a cohesive, on-brand
color palette and typography applied consistently across every screen, in
both light and dark mode.

**Why this priority**: This is the core deliverable — without it, nothing
else in this feature has any visible effect. It also touches every screen in
the app, so it's the riskiest and most valuable piece to get right first.

**Independent Test**: Launch the default build (no brand override
configured), toggle between Light, Dark, and System theme mode, and confirm
every screen renders the brand color palette and typeface — no leftover
default Material indigo or default system font anywhere.

**Acceptance Scenarios**:

1. **Given** the app is built with no per-deployment brand override
   configured, **When** a user opens any screen, **Then** the screen's
   colors (primary actions, containers, surfaces) reflect the brand's gold
   primary / orange accent / warm-neutral surfaces, not the previous generic
   indigo scheme.
2. **Given** a user is viewing the app, **When** they switch their theme
   preference between Light, Dark, and System, **Then** both the light and
   dark presentations use the same brand color identity (not just an
   inverted generic scheme).
3. **Given** any screen showing a headline, section title, or label,
   **When** it renders, **Then** it uses the brand display typeface, while
   body text and tables continue to use the existing readable body typeface
   and item codes/SKUs render in a monospaced typeface.
4. **Given** the brand's red is reserved for error/critical states,
   **When** a user views any non-error UI (buttons, active nav items,
   charts), **Then** red never appears as a decorative or primary
   interactive color.

---

### User Story 2 - Branded first impression (app icon, splash, browser tab) (Priority: P1)

A user installs or opens the app for the first time. Before they ever reach
a screen, the app icon on their device, the splash screen shown while the
app loads, and (on web) the browser tab icon and title already look
on-brand, instead of the current generic/default placeholders.

**Why this priority**: This is the first thing any user or evaluator sees,
and today it's completely unbranded (stock template icon, no splash
configured, default browser tab icon) — a highly visible gap independent of
the in-app theming work in User Story 1.

**Independent Test**: Install/launch a fresh default build on at least one
mobile or desktop target and load the web build; confirm the app icon,
loading splash, and (web) browser tab icon/title are all branded, with no
manual in-app navigation required to observe this.

**Acceptance Scenarios**:

1. **Given** a freshly installed default build, **When** the user views the
   app icon on their home screen/dock/taskbar, **Then** it shows the brand
   mark, not the current generic template icon.
2. **Given** the app is launching, **When** the splash screen is visible,
   **Then** it shows the brand lockup centered on the brand's dark
   background, not a blank or generic screen.
3. **Given** the web build is open in a browser, **When** the user looks at
   the browser tab, **Then** the tab shows the brand favicon and the brand's
   page title instead of the current generic Flutter defaults.

---

### User Story 3 - Correctly placed and sized logo across the app (Priority: P2)

A user sees the brand logo used consistently and correctly at every point it
appears in the app — full lockup on the login screen, the compact mark next
to the app name in the navigation, and the mark alone when navigation is
collapsed — always readable, never distorted, cropped, or crowded by other
UI elements.

**Why this priority**: Builds on User Story 1's palette work with the
brand's specific logo-usage rules; incorrect logo placement (too small,
crowded, wrong variant on a given background) undermines the brand
consistency established by Stories 1 and 2, but the app is still usable and
mostly on-brand without this level of polish.

**Independent Test**: Walk through the login screen, the navigation in both
expanded and collapsed states, and confirm logo size, spacing, and variant
(full-color vs. single-ink vs. grayscale) match the documented rules for
each placement, independent of any other screen's styling.

**Acceptance Scenarios**:

1. **Given** the login screen, **When** it renders, **Then** the full brand
   lockup (icon + wordmark) appears at the top of the branding panel at its
   documented size, with its surrounding clear space free of any other
   content.
2. **Given** the navigation is in its expanded state, **When** it renders,
   **Then** the compact brand mark appears beside the app name at its
   documented minimum readable size.
3. **Given** the navigation is collapsed (icon-only), **When** it renders,
   **Then** only the brand mark appears (no wordmark), still at or above its
   documented minimum size — the logo is never rendered smaller than its
   defined minimum or with its clear space obstructed.
4. **Given** a decorative use of the mark as a background watermark (e.g. a
   dashboard header), **When** it renders, **Then** it appears at low
   opacity and never sits directly behind readable text.

---

### User Story 4 - Other deployments stay unaffected (Priority: P2)

An engineer building a white-labeled variant for a specific customer, with
that customer's own brand override configured, verifies that their
customer's branding still fully applies and nothing from the new default
branding leaks into their build.

**Why this priority**: Protects existing white-label deployments from
regressing; lower priority than Stories 1–3 only because it's a
non-regression check rather than new user-visible value for the default
deployment itself, but it gates whether this feature is safe to ship.

**Independent Test**: Build the app with an existing per-deployment brand
override configured and confirm every brand touchpoint (colors, logo, app
name, icon, splash) reflects that deployment's own branding, not the new
default.

**Acceptance Scenarios**:

1. **Given** a build configured with a specific deployment's brand override,
   **When** the app runs, **Then** none of the new default color palette,
   typography, logo, icon, or splash assets from this feature appear
   anywhere in that build.
2. **Given** a deployment configures only a subset of overridable brand
   values, **When** the app runs, **Then** any values that deployment did
   not override still resolve to this feature's new defaults, not to the
   previous unbranded placeholders.

### Edge Cases

- What happens when the navigation is narrow enough to force the collapsed
  (icon-only) state — does the mark render legibly and above its documented
  minimum size, or does the app fall back to no logo at all?
- How does the system handle a screen or component whose background is a
  brand color (e.g. a filled button or banner) — does the logo/mark switch
  to its single-ink white variant instead of the full-color version, per the
  documented "brand-color background" placement rule?
- How does the system handle print/export output (e.g. generated PDFs)? Out
  of scope for this feature — those are produced by a separate backend
  service, not this application (see Assumptions).
- What happens on a device or browser that cannot resolve the brand's web
  font(s) — does text remain legible using a reasonable system-font
  fallback rather than becoming invisible or broken?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST present the brand's color palette (gold
  primary, orange accent, warm-toned neutral surfaces) throughout the
  default build's light and dark themes whenever no per-deployment brand
  override is configured.
- **FR-002**: The system MUST render headline/title/label text in the
  brand's display typeface, keep body text and dense tables in the existing
  body typeface, and render item codes/SKUs in a monospaced typeface,
  across the default build.
- **FR-003**: The system MUST display the full brand lockup on the login
  screen at its documented size and position, with its documented clear
  space free of other content.
- **FR-004**: The system MUST display the brand mark beside the app name in
  the navigation when expanded, and the mark alone (no wordmark) when the
  navigation is collapsed — in both cases at or above the documented minimum
  size for that placement.
- **FR-005**: The system MUST replace the current unbranded native app icon
  (including the Android adaptive icon) and add a native splash screen using
  the brand lockup on the brand's dark background, for the default build.
- **FR-006**: The system MUST replace the current default browser tab
  icon/title and web app icons with brand-appropriate versions for the
  default web build.
- **FR-007**: When a deployment has a per-deployment brand override
  configured, the system MUST use that deployment's own values instead of
  this feature's new defaults, and MUST continue to do so unchanged by this
  feature; any brand value a deployment does not override MUST fall back to
  this feature's new defaults rather than to the previous unbranded
  placeholders.
- **FR-008**: The system MUST continue to let users choose Light, Dark, or
  System theme preference, applying the brand's identity consistently in
  both light and dark presentations.
- **FR-009**: The system MUST restrict the brand's red color to
  error/critical/destructive states only; it MUST NOT be used as a
  decorative or primary interactive color anywhere in the default build.
- **FR-010**: The system MUST support a low-opacity, monochrome placement of
  the brand mark for decorative watermark use, positioned so it never
  renders directly behind readable text.
- **FR-011**: This feature MUST NOT change the structure or layout of
  existing screens — customization is limited to color scheme, typography,
  and branding assets (per the project's existing white-labeling design
  decision); any layout ideas shown in the source brand guide's example
  screens are reference inspiration only, not a request to rebuild those
  screens' structure.
- **FR-012**: The system's default, non-overridden display name MUST remain
  "Mictlanix Business Essentials" — this feature changes only the visual
  brand (color palette, typography, logo, icon, splash), not the product
  name itself.
- **FR-013**: The default display name value MUST be defined in a single,
  easily-editable location so it can be changed later (e.g. if the product
  name itself is rebranded) without touching every app-name touchpoint
  (navigation label, splash, browser tab title, installed-app name,
  app-store-style metadata) individually.

### Key Entities

- **Brand Theme**: The bundle of color palette, typography choices, and
  logo/icon/splash assets that defines a deployment's visual identity. Every
  deployment already resolves to one Brand Theme, either its own configured
  override or the shared default; this feature replaces the content of the
  shared default with the new brand identity.
- **Default Brand Configuration**: The specific set of brand values (colors,
  fonts, logo, app name, icons) applied when a deployment sets no override.
  This is what this feature changes; per-deployment overrides remain a
  separate, unaffected concept.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every primary screen in the default build (login, home,
  navigation, at least one data list/detail screen) visually reflects the
  brand's color palette in both light and dark mode, with zero remaining
  instances of the previous generic indigo Material scheme, confirmed by
  visual review.
- **SC-002**: On first install/launch, the app icon, loading splash, and
  (web) browser tab icon/title are all recognizably on-brand, verified on at
  least one mobile or desktop target plus the web build, with no in-app
  navigation required to observe it.
- **SC-003**: A test build configured with an existing deployment's brand
  override shows zero instances of the new default's colors, logo, icon, or
  splash — confirming complete isolation between the new defaults and
  existing per-deployment overrides.
- **SC-004**: In a layout review of the login screen, expanded navigation,
  and collapsed navigation, the brand logo/mark never renders below its
  documented minimum size or with its documented clear space obstructed, in
  any of those three placements.
- **SC-005**: Text remains legible (meets standard accessibility contrast
  guidance) against its background in both the new light and new dark color
  schemes, across the screens reviewed in SC-001.

## Assumptions

- The scope of this feature is limited to color scheme, typography, and
  branding assets (icon, splash, logo placement) — it does not redesign the
  structure, layout, or information architecture of any existing screen.
  The brand guide's example screen mockups (a custom login split-panel, a
  dashboard with hero/tiles/activity feed, a pill-style navigation, a
  restyled data table, a facilities list with status chips) are read as
  visual inspiration for how the *existing* screens should look once
  restyled, not as a request to rebuild those screens from scratch. This
  reading follows the project's existing decision that white-label
  customization stays within consistent component structure across
  deployments.
- The brand guide's color tokens are fully specified for the dark theme;
  the light-theme counterpart is not given numerically and must be derived
  from the same brand hues using standard conventions for deriving a light
  companion from a dark, brand-specific scheme, preserving the same color
  roles (primary, accent, error-only red, neutral surfaces).
- Fonts are addressed as freely licensed, redistributable web fonts
  compatible with this project's existing tooling and offline-build
  practices — no new font licensing review is required.
- Print/export documents (e.g. generated PDFs) are out of scope: those are
  produced by a separate backend service, not by this application.
- No native platform-level build-flavor system (e.g. separate Android
  product flavors or iOS schemes) is introduced by this feature; "default
  flavor" refers to the existing fallback values used when a deployment
  configures no brand override, and that override mechanism itself is
  unchanged.
- Any grayscale/print-safe and single-ink white logo variants supplied by
  the brand guide are assumed sufficient for this feature's light-background
  and brand-color-background placements; no additional logo variants need
  to be produced.
