# Feature Specification: Design System Tokens & Component Theming

**Feature Branch**: `022-design-system-tokens`

**Created**: 2026-08-08

**Status**: Draft

**Input**: User description: "Complete the MBE-UI design system's missing token layers and Material 3 component theming, targeting desktop, tablets and smartphones, honoring the decisions already persisted in spec 019, DESIGN.md and DESIGN-SYSTEM.md, and preserving the ability to customize per customer branding colors."

## Clarifications

### Session 2026-08-08

- Q: Should the product fail the build when a deployment's own brand colour cannot meet the accessibility contrast threshold as a foreground, or only warn? → A: Fail the build.
- Q: Should the monospaced type role extend to product codes and identifiers in table cells, or narrow the contract to timestamps and record identifiers only, matching what is actually built today? → A: Narrow the contract to match what's actually built — timestamps and record identifiers only; product codes and SKUs stay on the standard body role.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Text and surfaces show the brand's real colors (Priority: P1)

Today a user reading any screen sees text drawn in Material's stock ink rather than the brand's own — a cool lavender-white in dark mode where the approved brand guide specifies a warm off-white, and a slightly-off near-black in light mode. Separately, one of the surface tones that cards sit on is only defined for dark mode, so light mode falls back to a generated colour nobody approved. This story makes every piece of text and every card surface show the colour the brand guide actually specifies, in both light and dark mode.

**Why this priority**: It is the smallest slice that is independently visible to an end user, it corrects a defect rather than adding scope, and the surface-tone gap blocks the elevation model every later story depends on.

**Independent Test**: Open any screen in light mode and again in dark mode; sample the colour of body text and of a card's background and confirm both match the approved brand values. No other work in this feature needs to exist.

**Acceptance Scenarios**:

1. **Given** the application runs with the default brand, **When** any screen renders in dark mode, **Then** body and heading text is drawn in the brand's warm off-white rather than Material's stock light ink.
2. **Given** the application runs with the default brand, **When** any screen renders in light mode, **Then** body and heading text is drawn in the brand's near-black rather than Material's stock dark ink.
3. **Given** the application runs in light mode, **When** a card or panel renders, **Then** its background is the brand's approved raised surface tone, matching its dark-mode counterpart in role.
4. **Given** a deployment that supplied its own brand colour, **When** any screen renders, **Then** text and surfaces follow that deployment's generated colours and show no trace of the default brand's values.

---

### User Story 2 - One vocabulary for spacing, shape, elevation and density (Priority: P1)

A designer or developer asking "how much space goes between these two fields?" or "what corner radius does a card use?" currently has no answer to look up, so every screen answers it again by hand — which is why gaps and radii differ between screens that should match. This story establishes a single named set of spacing steps, corner radii, elevation levels and density settings, available everywhere in the product, with a defined value for every form factor. Nothing on screen changes yet; the vocabulary simply comes into existence.

**Why this priority**: Every later story consumes this vocabulary, and because it changes no existing screen it can land with essentially no risk of visual regression.

**Independent Test**: Ask for each token by name in a throwaway screen and confirm it returns the documented value for the current form factor, at all four form factors, in both light and dark mode.

**Acceptance Scenarios**:

1. **Given** the vocabulary exists, **When** any part of the product asks for a named spacing, radius, elevation or density value, **Then** it receives the documented value without needing to know which brand is deployed.
2. **Given** the product is displayed at any of the four supported widths, **When** a form-factor-dependent value such as screen margin is requested, **Then** the value documented for that width is returned.
3. **Given** two different customer deployments with different brand colours, **When** the same spacing, radius, elevation or density value is requested in each, **Then** both return identical values, because product structure is not customisable per customer.
4. **Given** any screen in the product, **When** it needs a spacing or radius value, **Then** it can obtain it from the active theme without importing a constant directly.

---

### User Story 3 - A safety net before anything is restyled (Priority: P2)

Before component appearance is centralised, the team needs a way to see exactly what a styling change does to every screen. Today there is no such net, so a single change to how cards look would silently alter eighteen record screens with nothing to flag it. This story captures reference images of every shared component in light and dark mode at a narrow and a wide form factor, so any later change surfaces as a visible difference to approve or reject.

**Why this priority**: It delivers value alone by protecting the current appearance, and it is a hard prerequisite for the component-theming story — doing that story first would mean restyling the product blind.

**Independent Test**: Deliberately alter one shared component's appearance and confirm the reference comparison reports the difference and identifies the affected component.

**Acceptance Scenarios**:

1. **Given** the reference images exist, **When** no styling has changed, **Then** the comparison passes for every shared component in all four light/dark × narrow/wide combinations.
2. **Given** a shared component's appearance is changed, **When** the comparison runs, **Then** it fails and names the component and the combination that differs.
3. **Given** a new shared component is added, **When** the comparison runs, **Then** the absence of a reference image for it is reported rather than silently passing.

---

### User Story 4 - Components look the same everywhere without per-screen styling (Priority: P2)

A user moving between the product catalog, pricing, sales and administration areas currently meets small inconsistencies — a chip here has a slightly different label treatment from the same chip there, a divider is a different weight, a navigation highlight is shaped by hand. This happens because each screen restates appearance itself. This story moves appearance for every shared control into one place, so the same control looks identical everywhere and a future change is made once.

**Why this priority**: It is the story that actually stops the drift, but it changes how much of the product looks, so it must follow the safety net.

**Independent Test**: Compare the same control — a status chip, a divider, a card, a form field, a navigation item — across at least three different feature areas and confirm they are visually identical.

**Acceptance Scenarios**:

1. **Given** appearance is centralised, **When** the same kind of control renders in two different feature areas, **Then** the two are visually identical.
2. **Given** a shared control's appearance is changed in the one central place, **When** the product is viewed, **Then** every occurrence of that control reflects the change without any screen being edited.
3. **Given** the status indicator used by cash sessions and the one used by catalog records, **When** both render, **Then** they are produced by a single shared control rather than two near-identical copies.
4. **Given** a control renders on a pointer-driven display and again on a touch display, **Then** its size and spacing follow the density documented for that input type.

---

### User Story 5 - Type is chosen by role, not typed in by hand (Priority: P3)

A few screens currently name a typeface and a size directly instead of using the product's type hierarchy, so those pieces of text do not move when the hierarchy changes and can drift out of step with the rest. This story replaces every hand-specified typeface and size with a named role drawn from the product's type hierarchy, and records which role each kind of text uses at each form factor.

**Why this priority**: Real but contained — a small number of places are affected, and the visible outcome is subtle compared with stories 1 and 4.

**Independent Test**: Search the product's source for hand-specified typefaces and text sizes and confirm none remain outside the central type definition; confirm the affected screens still render at the intended visual weight.

**Acceptance Scenarios**:

1. **Given** the role assignment is defined, **When** a screen needs a heading, label, table cell or code value, **Then** it selects a named role rather than stating a typeface or size.
2. **Given** the product is displayed at a narrow and then a wide width, **When** a heading renders, **Then** it uses the role documented for that width.
3. **Given** the type hierarchy is adjusted centrally, **When** the product is viewed, **Then** every screen reflects the adjustment.
4. **Given** a value that is a record identifier or a timestamp, **When** it renders, **Then** it uses the product's monospaced role so that characters align in columns; an ordinary product code or SKU shown in a table cell uses the standard body role instead, matching current behaviour.

---

### User Story 6 - Ready for tablets and phones without a token redesign (Priority: P3)

The product targets desktop today, with tablet and phone planned. This story ensures every token and per-form-factor value is decided and recorded for all four supported widths now — including the two narrower ones — so that when the phone and tablet layouts are built, no token has to be renegotiated. Controls already respond to width for the tablet and desktop widths in this feature; the narrow-width layouts themselves remain a separate future effort.

**Why this priority**: It is insurance rather than immediate user value, but it is far cheaper to decide these values while the tokens are being written than to retrofit them later.

**Independent Test**: For every form-factor-dependent value in the specification, confirm a decided value exists for all four widths, and confirm controls visibly adapt between the tablet and desktop widths.

**Acceptance Scenarios**:

1. **Given** the token definitions, **When** any width-dependent value is inspected, **Then** a decided value exists for each of the four supported widths.
2. **Given** the product is resized between the tablet and desktop widths, **When** shared controls render, **Then** their spacing and density change to the documented values for that width.
3. **Given** the narrow phone width, **When** token values are requested, **Then** documented values are returned even though the phone-specific layouts are not yet built.

---

### Edge Cases

- What happens when a customer deployment supplies its own brand colour — do any default-brand values leak into spacing, shape, elevation, density, or the contrast-safe foreground colour? They must not.
- What happens when a control renders outside the product's own theme, such as in an isolated test harness? It must fall back to sensible values rather than failing.
- What happens on a large touch-driven tablet whose width falls in the desktop range — does it get touch-sized targets or pointer-sized ones?
- What happens to a screen whose current spacing does not match any step on the new scale — is it snapped to the nearest step, and who approves the visible change?
- What happens when the brand guide's own measurements do not fall on the product's spacing grid?
- What happens when a shared control has no reference image yet — does the comparison pass silently or report the gap?
- A customer's chosen brand colour is verified for foreground contrast exactly like the default brand's, and a deployment build MUST fail rather than ship if that colour cannot meet the threshold.
- How does a screen behave if a form-factor-dependent value is requested before the display size is known?

## Requirements *(mandatory)*

### Functional Requirements

**Foundations and correctness**

- **FR-001**: The product MUST draw all text in the colours defined by the active brand's own colour set, in both light and dark mode, rather than the framework's stock text colours.
- **FR-002**: The product MUST define the raised surface tone used by cards and panels for light mode as well as dark mode, so both modes resolve it from approved values.
- **FR-003**: The product MUST continue to guarantee that a deployment supplying its own brand colour receives no default-brand-specific values of any kind, including the contrast-safe foreground colour introduced previously.

**Token vocabulary**

- **FR-004**: The product MUST define a named spacing scale whose steps are all multiples of the four-unit grid the design language is built on.
- **FR-005**: The product MUST define a named corner-radius scale covering the full range from square to fully rounded.
- **FR-006**: The product MUST define a named elevation model that expresses depth primarily through surface tone, reserving shadow for temporary overlays such as menus, dialogs and dragged items.
- **FR-007**: The product MUST define named density and minimum interactive-target settings, selected by whether the user is interacting by touch or by pointer rather than by display width alone.
- **FR-008**: The product MUST define, for every kind of text in the product, which role of the type hierarchy it uses at each supported width.
- **FR-009**: Every token defined by this feature MUST be obtainable from the product's active theme, and no screen or control may obtain one by referring to a definition directly.
- **FR-010**: Spacing, corner radius, elevation, density and type role assignments MUST be identical across all customer deployments and MUST NOT be customisable per deployment.
- **FR-011**: Token definitions MUST be organised so that customisable brand values and non-customisable product values are separated, making the distinction in FR-010 evident from the structure rather than only from documentation.

**Per-form-factor values**

- **FR-012**: The product MUST define a value for every width-dependent measurement — including screen margin, gutter between panes, card padding, gaps between fields and between sections, and maximum content width — for all four supported widths.
- **FR-013**: Shared controls MUST visibly adapt their spacing and density between the tablet and desktop widths.
- **FR-014**: Width-dependent values for the narrow phone width MUST be decided and recorded even though phone-specific layouts are out of scope for this feature.

**Component appearance**

- **FR-015**: The appearance of every shared control MUST be defined centrally, so that the same control renders identically wherever it appears.
- **FR-016**: The centrally-defined appearance MUST cover, at minimum: top bars, cards, form fields, chips, data tables, dividers, dialogs, navigation rails and drawers, buttons, list rows, segmented controls, bottom sheets, notifications, tooltips, menus, switches and progress indicators.
- **FR-017**: Screens MUST NOT restate the appearance of a shared control locally once that control's appearance is defined centrally.
- **FR-018**: The two near-identical status indicators used today by cash sessions and by catalog records MUST be replaced by a single shared control.
- **FR-019**: No screen or control may specify a typeface or a text size directly; all text MUST select a role from the type hierarchy.

**Verification**

- **FR-020**: The product MUST hold reference images for every shared control, captured in light and dark mode at a narrow and a wide width, and MUST report any difference against them.
- **FR-021**: The reference images MUST exist and pass before any change to centrally-defined component appearance is made.
- **FR-022**: The product MUST verify that text colours meet the accessibility contrast threshold against the surface they are drawn on, in both light and dark mode, for the default brand.
- **FR-023**: The product MUST report, rather than silently accept, a shared control that has no reference image.

**Boundaries**

- **FR-024**: Controls MUST fall back to sensible values when rendered outside the product's theme, rather than failing.
- **FR-025**: Phone-specific layout components — a bottom navigation bar, the conversion of data tables into card lists, filters presented as bottom sheets, pinned action bars and full-screen dialogs — MUST NOT be built by this feature.
- **FR-026**: Where the brand guide's own measurements do not fall on the product's spacing grid, the product MUST use the nearest grid step and the discrepancy MUST be raised with the brand owner rather than resolved silently.
- **FR-027**: The product MUST verify, for any deployment's own brand colour and not only the default brand's, that every foreground role produced from it meets the accessibility contrast threshold against the surface it renders on, and MUST fail that deployment's build rather than ship it when the threshold is not met. *(Clarified 2026-08-08.)*
- **FR-028**: The monospaced type role MUST be used only for record identifiers and timestamps; an ordinary product code or SKU rendered in a table cell MUST use the standard body role, narrowing spec 019's typography contract to match this behaviour rather than extending the product to monospace codes. *(Clarified 2026-08-08.)*

### Key Entities

- **Spacing scale**: the named steps of empty space the product uses, from tightest to widest, each a multiple of the four-unit grid; plus the width-dependent layout measurements derived from them.
- **Corner-radius scale**: the named roundness values, from square through to fully rounded, and which kind of surface each applies to.
- **Elevation model**: the ordered levels of apparent depth, each mapping to a surface tone and stating whether a shadow accompanies it.
- **Density profile**: the compactness and minimum interactive-target size for touch interaction and for pointer interaction.
- **Type role assignment**: the mapping from a kind of text in the product to a role of the type hierarchy, per supported width — including which values (record identifiers, timestamps) use the monospaced role and which (ordinary product codes and SKUs) explicitly do not.
- **Brand values**: the per-deployment customisable set — colours, typefaces, logo assets — already established and unchanged by this feature, kept separate from the above.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero occurrences remain in the product's own source of a directly-specified typeface or text size, excluding generated code and the central type definition.
- **SC-002**: Zero occurrences remain of a colour value written into a screen or control, excluding the token definitions themselves.
- **SC-003**: For the default brand, every text role meets or exceeds a 4.5:1 contrast ratio against the surface it renders on, and every meaningful non-text indicator meets or exceeds 3:1, in both light and dark mode.
- **SC-004**: A deployment supplying its own brand colour contains zero values traceable to the default brand, verified automatically.
- **SC-005**: Every width-dependent measurement has a decided value for all four supported widths — 100% coverage, no gaps.
- **SC-006**: 100% of shared controls have reference images in all four light/dark × narrow/wide combinations, and the comparison passes before component appearance is changed.
- **SC-007**: The same shared control rendered in at least three different feature areas is pixel-identical in each.
- **SC-008**: Requesting any token requires no knowledge of which brand is deployed — verified by the token values being identical under two different brand configurations.
- **SC-009**: A change to one shared control's central appearance definition propagates to every occurrence with zero screen files edited.
- **SC-010**: The number of near-duplicate status indicator implementations drops from two to one.
- **SC-011**: A deployment build using a brand colour that fails the accessibility contrast threshold as a foreground does not complete successfully — verified with at least one deliberately-failing colour, for the default brand's mechanism and for an overridden deployment colour alike.

## Verbatim Constraints

Values the request pinned that must match exactly:

- Token directory for non-customisable product tokens: `lib/core/design/`
- Token directory for customisable brand tokens: `lib/core/branding/`
- Theme assembly location: `lib/app/theme/app_theme.dart`
- Deployment override flag governing brand isolation: `BRAND_SEED_COLOR`
- Default-brand gate: `BrandConfig.usesDefaultPalette`
- Surface role missing its light-mode definition: `surfaceContainerLow`
- Framework stock text colours that must stop reaching the product: `#1D1B20` (light), `#E6E0E9` (dark)
- Approved brand text colours that must replace them: `#1C1A16` (light), `#EFE9DF` (dark)
- Supported width tiers, exactly as already defined in `LayoutBreakpoints`: compact `<600`, medium `600-839`, expanded `840-1199`, large `>=1200`
- Card and panel corner radius: `16`
- Layering rule that must remain true: nothing in `lib/features/` or `lib/core/` imports `lib/app/`

## Assumptions

- Spec 019's colour roles, typography contract and brand assets are settled and are not reopened by this feature; this feature consumes them.
- The design language's existing type ramp — sizes, line heights and letter spacing — is inherited as-is. Only the assignment of roles to kinds of text is new. Adjusting the letter spacing of the largest headings for the brand typeface is treated as a measurement task during planning, not a value invented here.
- Density is selected by input type rather than display width, so a large touch-driven tablet receives touch-sized targets.
- The brand guide's most common gap measurement does not sit on the product's four-unit grid; the nearest grid step is used and the discrepancy is raised with the brand owner (FR-026).
- Screens whose current spacing does not match a step on the new scale are snapped to the nearest step; where this produces a visible change it is approved through the reference-image comparison rather than screen by screen.
- Reference-image tooling does not exist in the product today; selecting it is part of planning.
- The maximum content width at the widest tier is a new constraint not present today; it is introduced as part of this feature.
- The contrast verification in FR-022 covers the default brand; FR-027 extends the same verification, and the same fail-the-build consequence, to any deployment's own brand colour (Clarified 2026-08-08).
- The monospaced role currently applies only to timestamps despite spec 019's typography contract assigning it to codes and identifiers. FR-028 resolves this by narrowing the contract to match current behaviour — record identifiers and timestamps only — rather than extending monospacing to ordinary product codes and SKUs (Clarified 2026-08-08). Updating spec 019's `brand-tokens.md` wording to reflect this narrower contract is a documentation correction bundled into this feature's scope, not a new capability.
- Whether the brand's heavier weight overrides remain on the smallest label roles, or revert to the design language's lighter default for legibility at small sizes, is treated as a brand decision defaulted to reverting the two smallest label roles, recorded here for the brand owner to confirm.
