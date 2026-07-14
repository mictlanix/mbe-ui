# Feature Specification: Adaptive Navigation Layout

**Feature Branch**: `010-adaptive-navigation-layout`

**Created**: 2026-07-14

**Status**: Draft

**Input**: User description: "I want to perform the following changes to the layout on the app, for tablet screens or larger: navigation rail (rail on tablet+, drawer on smaller form factors, menus with one level of grouping); home welcome screen with per-flavor image/message and a default placeholder; app bar with a single trailing user-menu button (Change Password, Location settings, Logout, plus current store/POS/cash-drawer info); catalog action buttons moved from the app bar to the right of the search bar, with the Add action highlighted as a primary function."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Persistent, grouped navigation that adapts to screen size (Priority: P1)

A signed-in user needs to move between the app's areas (Home, and the catalogs they are allowed to see — Users, Products) from any screen, without returning to a separate landing page first. On a tablet or larger display the navigation is always visible as a side navigation rail; on a smaller display the same navigation is reachable from a menu button that opens a navigation drawer. Menu entries may be organized under a single level of grouping (for example, a **Catalogs** group containing **Users** and **Products**).

**Why this priority**: This is the structural backbone of the change. Every other item in this feature (home content, user menu, catalog toolbars) sits inside the new shell. Without persistent navigation the app forces users back to the Home screen to change sections, which is the core problem being solved.

**Independent Test**: Sign in on a wide window and confirm a navigation rail lists the permitted destinations grouped correctly and lets you jump between Home, Users, and Products from any screen; then narrow the window and confirm the same destinations are reachable through a drawer opened from a menu button. Destinations the user lacks permission for never appear in either presentation.

**Acceptance Scenarios**:

1. **Given** a signed-in user on a tablet-or-larger display, **When** any authenticated screen is shown, **Then** a persistent navigation rail is visible listing every destination the user is permitted to access, with grouped entries shown under their group.
2. **Given** a signed-in user on a smaller-than-tablet display, **When** any authenticated screen is shown, **Then** navigation is not permanently on screen but is reachable via a menu affordance that opens a navigation drawer containing the same destinations and grouping.
3. **Given** the navigation is visible (rail or drawer), **When** the user selects a destination, **Then** the app navigates to that destination and the navigation indicates which destination is currently active.
4. **Given** a user lacking permission for a destination, **When** the navigation is shown, **Then** that destination is omitted (not shown disabled), and an empty group (all children hidden) is not shown as an empty header.
5. **Given** the user is on the sign-in screen or otherwise unauthenticated, **When** that screen is shown, **Then** no navigation rail or drawer is presented.

---

### User Story 2 - Consolidated user menu in the app bar (Priority: P1)

The app bar exposes exactly one trailing button that represents the currently signed-in user. Pressing it opens a menu that shows the user's identity, their current location context (store, point of sale, cash drawer), and account actions: **Change Password** and **Logout**.

**Why this priority**: The current app bar surfaces sign-out (and, on catalog screens, entity actions) directly. Consolidating all user-scoped functions behind one predictable control is a prerequisite for freeing the app bar's trailing area and for moving catalog actions elsewhere (User Story 4). It also matches the legacy reference behavior users already know.

**Independent Test**: Sign in, open the single trailing user control in the app bar, and confirm it shows the user's name/email, the current store/POS/cash-drawer context, and working Change Password and Logout actions — and that no other trailing buttons compete with it in the app bar.

**Acceptance Scenarios**:

1. **Given** a signed-in user on any authenticated screen, **When** the app bar is shown, **Then** it presents exactly one trailing button representing the current user.
2. **Given** the user opens that control, **When** the menu appears, **Then** it displays the user's identifying information (display name and/or email) and the current location context: store, point of sale, and cash drawer.
3. **Given** the menu is open, **When** the user selects **Change Password**, **Then** the app navigates to the change-password flow.
4. **Given** the menu is open, **When** the user selects **Logout**, **Then** the user is signed out and returned to the sign-in screen.
5. **Given** the signed-in user has no assigned location context, **When** the menu is opened, **Then** the location lines are gracefully omitted or shown as empty/placeholder rather than displaying an error.

---

### User Story 3 - Branded Home welcome screen (Priority: P2)

After signing in, the Home destination shows a welcome experience — a brand image and/or welcome message — appropriate to the deployment's configured brand (flavor). When a deployment supplies no brand welcome asset, a neutral default placeholder image/message is shown instead so the Home screen is never blank.

**Why this priority**: This makes Home a purposeful landing area rather than a bare navigation list, and reinforces per-customer branding. It depends on the navigation shell (US1) so that Home is one destination among several, but delivers independent visible value.

**Independent Test**: Launch a branded deployment and confirm the configured welcome image/message appears on Home; launch a deployment with no configured brand asset and confirm a default placeholder appears in its place — in both cases with no broken/missing-image state.

**Acceptance Scenarios**:

1. **Given** a deployment configured with a brand welcome asset, **When** the user lands on Home, **Then** that brand image and/or welcome message is displayed.
2. **Given** a deployment with no brand welcome asset configured, **When** the user lands on Home, **Then** a default placeholder image and/or message is displayed instead.
3. **Given** the Home screen is displayed on any supported screen size, **When** it renders, **Then** the welcome content scales appropriately without overflow or clipping.

---

### User Story 4 - Catalog actions relocated beside the search bar (Priority: P2)

On catalog list screens, the actions currently shown as trailing icon buttons in the app bar (for example, **Add** and, on the product catalog, **Merge**) are moved to the right side of the search bar — the same location as the product catalog's Filters button. The **Add** action is visually emphasized as the primary action.

**Why this priority**: This completes the app-bar cleanup started by User Story 2 and puts creation/entity actions next to the search/filter controls users are already working with. It depends on the app bar being reserved for the user menu (US2) but is otherwise independently demonstrable per catalog.

**Independent Test**: Open the product catalog and confirm Add and Merge appear to the right of the search bar (not in the app bar), Add is styled as the primary action, both respect the user's permissions, and both still perform their original navigation. Repeat for the Users catalog for the Add action.

**Acceptance Scenarios**:

1. **Given** a catalog list screen, **When** it renders, **Then** its entity actions (e.g. Add, Merge) appear to the right of the search bar rather than in the app bar's trailing area.
2. **Given** a catalog list screen, **When** the action row renders, **Then** the **Add** action is visually distinguished as the primary action relative to the other actions.
3. **Given** a user lacking the create permission for a catalog, **When** the screen renders, **Then** the Add action is omitted (consistent with existing permission-based hiding), and likewise for any other permission-gated action (e.g. Merge).
4. **Given** the relocated actions, **When** the user activates one, **Then** it performs the same navigation/behavior it previously performed from the app bar.
5. **Given** the search bar with adjacent actions on a narrower supported width, **When** it renders, **Then** the search field and its action buttons remain usable without horizontal overflow.

---

### Edge Cases

- **No permitted destinations beyond Home**: navigation still renders Home; empty groups are not shown.
- **Single-child group**: a group with exactly one visible child still renders sensibly without an empty or misleading header.
- **Very wide displays**: the navigation rail and content area remain balanced (rail does not stretch to consume excessive width).
- **Missing/broken brand asset**: a configured-but-unloadable brand image falls back to the default placeholder rather than showing a broken-image state.
- **Long user identity or location strings**: the user menu handles long email/store names without breaking layout (wrap or truncate with reveal).
- **Active-destination sync**: navigating via in-content links (not the rail/drawer) still updates the active-destination indicator.
- **Deep-linking / direct URL** to a permitted destination shows the shell with that destination marked active; direct URL to a forbidden destination continues to redirect as it does today.

## Requirements *(mandatory)*

### Functional Requirements

**Navigation shell**

- **FR-001**: The app MUST present authenticated screens inside a shared navigation shell that hosts the app bar, the primary navigation, and the destination content.
- **FR-002**: On tablet-or-larger displays, the shell MUST present primary navigation as a persistent, always-visible navigation rail.
- **FR-003**: On smaller-than-tablet displays, the shell MUST present primary navigation inside a navigation drawer reachable from a menu affordance in the app bar, not permanently occupying screen space.
- **FR-004**: The navigation MUST support one level of grouping, where a group has a label and contains one or more destinations (e.g. **Catalogs** → **Users**, **Products**).
- **FR-005**: The navigation MUST list only destinations the current user is permitted to access, hiding (not disabling) forbidden destinations, consistent with the existing access-control rules.
- **FR-006**: A group whose visible destinations are all hidden by permissions MUST NOT render (no empty group header).
- **FR-007**: The navigation MUST indicate the currently active destination and keep this indication in sync with the actual location, including navigations triggered from outside the navigation control.
- **FR-008**: The navigation shell MUST NOT be presented on unauthenticated screens (e.g. sign-in, password recovery).

**User menu**

- **FR-009**: The app bar MUST present exactly one trailing control, representing the current user, on authenticated screens.
- **FR-010**: Activating the user control MUST open a menu that displays the user's identifying information (display name and/or email).
- **FR-011**: The user menu MUST display the current location context: store, point of sale, and cash drawer, derived from the signed-in user's settings.
- **FR-012**: The user menu MUST provide a **Change Password** action that navigates to the existing change-password flow.
- **FR-013**: The user menu MUST provide a **Logout** action that signs the user out and returns them to the sign-in screen.
- **FR-014**: When the user has no location context (no store/POS/cash-drawer settings), the menu MUST omit or placeholder those lines without error.

**Home welcome**

- **FR-015**: The Home destination MUST display a welcome experience consisting of a brand image and/or welcome message sourced from the active deployment brand (flavor).
- **FR-016**: When the active deployment provides no brand welcome asset, Home MUST display a default placeholder image and/or message instead of a blank area.
- **FR-017**: Home MUST no longer serve as the app's navigation list; navigation entries previously listed on Home (Users, Products, Change Password) MUST instead be provided by the navigation shell and user menu.

**Catalog action relocation**

- **FR-018**: Catalog list screens MUST render their entity actions (at minimum **Add**; and **Merge** where it applies) to the right of the search bar, in the same region as the existing Filters control, and MUST NOT render those actions in the app bar's trailing area.
- **FR-019**: The **Add** action MUST be visually emphasized as the primary action relative to other actions in that region.
- **FR-020**: Relocated actions MUST continue to respect the user's permissions (hidden when the user lacks the corresponding right) and MUST preserve their existing behavior/navigation.
- **FR-021**: The search bar and its adjacent actions MUST remain usable without horizontal overflow across supported display widths.

### Key Entities *(include if data involved)*

- **Navigation destination**: A reachable area of the app — a label, an icon, a target location, and the access right that gates its visibility. May belong to a group.
- **Navigation group**: A single-level grouping with a label and an ordered set of destinations; visible only when at least one child is visible.
- **User location context**: The signed-in user's store, point of sale, and cash drawer identifiers, shown in the user menu (display-only in this feature).
- **Brand welcome asset**: A per-deployment (flavor) image and/or welcome message shown on Home, with a default placeholder when unset.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From any authenticated screen on a tablet-or-larger display, a user can reach any other permitted destination in a single interaction (one tap on the rail), with no intermediate return to Home.
- **SC-002**: On smaller displays, a user can reach any permitted destination in at most two interactions (open drawer, then select).
- **SC-003**: The app bar on authenticated screens shows exactly one trailing control (the user menu) across every screen — verifiable by inspection on Home, Users, and Products.
- **SC-004**: 100% of destinations and actions the user lacks permission for are absent from the navigation and catalog toolbars (none shown disabled).
- **SC-005**: The Home screen always shows non-blank welcome content — branded when configured, default placeholder otherwise — in both configured and unconfigured deployments.
- **SC-006**: On every catalog list screen, Add (and Merge where applicable) appears beside the search bar and not in the app bar, with Add visibly distinguished as primary.
- **SC-007**: Switching a window from wide to narrow (crossing the tablet threshold) swaps rail↔drawer presentation with no loss of available destinations and no layout overflow.

## Assumptions

- **Tablet threshold**: "Tablet screens or larger" maps to the existing centralized breakpoints — the navigation rail is used at the **Medium** tier and wider (window width ≥ 600), and the navigation drawer is used at the **Compact** tier (width < 600). This can be adjusted if a different rail/drawer cutoff is preferred.
- **Destination set**: Navigation reflects only currently implemented areas — **Home** plus a **Catalogs** group containing **Users** and **Products** — rather than the full legacy menu (Ventas, Producción, etc.), which is not yet built. New destinations are added to the shell as their features ship.
- **Grouping example**: The **Catalogs → Users, Products** grouping follows the example in the request; exact group membership/labels can be tuned without changing the shell mechanism.
- **Location context is display-only**: The user menu shows the current store/point-of-sale/cash-drawer as read-only information (as in the legacy reference). Changing/switching the active location is **out of scope** for this feature.
- **Change Password relocation**: Change Password moves from the Home navigation list into the user menu; the underlying change-password screen/flow is unchanged.
- **Brand assets via flavors**: Per-deployment brand welcome assets are supplied through the project's build-time flavor mechanism (per the constitution's white-labeled design-system principle). This feature consumes that mechanism and provides a default placeholder; defining new customer flavors is out of scope beyond wiring the Home welcome asset and default.
- **Catalog scope**: The catalogs affected are the existing Products and Users list screens. The relocation pattern is intended to be reused by future catalogs.
- **Localization**: All new labels (group names, menu items, welcome message) are provided through the existing `es-MX`-first localization setup.
- **Reference behavior**: The attached legacy screenshots (Casa Maestra) illustrate the target user-menu contents and Home welcome, not a pixel-exact visual spec; Material 3 presentation conventions apply.
