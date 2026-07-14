# Quickstart: Adaptive Navigation Layout

Validation guide proving the feature end-to-end. See [plan.md](./plan.md), [data-model.md](./data-model.md), and [contracts/](./contracts/) for detail; this file is the run/verify path.

## Prerequisites

- Flutter stable, `dart`/`flutter` on PATH.
- `flutter pub get` clean.
- Run codegen once (freezed/riverpod for `BrandConfig`, `nav` providers):
  `dart run build_runner build --delete-conflicting-outputs`

## Build / run

```bash
# Default (unbranded) — Home shows the default placeholder welcome
flutter run -d chrome

# Branded flavor example — Home shows the configured welcome + display name
flutter run -d chrome \
  --dart-define=BRAND_DISPLAY_NAME="CASA MAESTRA" \
  --dart-define=BRAND_WELCOME_ASSET=assets/branding/default_welcome.png
```

## Manual validation scenarios

### US1 — Adaptive, grouped navigation
1. Sign in. On a wide window (≥ 600 px) confirm a **persistent side navigation** shows **Home** and a **Catalogs** group containing **Users** and **Products** (only those the account may read).
2. Click Products, then Users, then Home — each switches without returning to Home first; the active item is highlighted; the app-bar title matches the destination (SC-001).
3. Narrow the window below 600 px: the side nav disappears and an app-bar **menu button** opens a **drawer** with the same destinations/grouping (SC-002, SC-007).
4. Sign in as a user lacking Products read: Products is absent; lacking both Users and Products read: the **Catalogs** header is absent (SC-004, FR-006).
5. Visit `/auth/login` (sign out): **no** rail or drawer (FR-008).

### US2 — User menu
6. On any destination, confirm the app bar has **exactly one** trailing control (SC-003). Open it: it shows the email, the store/POS/cash-drawer lines as **names** (POS/drawer include their code, e.g. "PV ZUMPANGO (01)") when the profile carries them — else the labeled-ID fallback — plus **Change Password** and **Logout**.
7. Click Change Password → lands on the change-password screen. Reopen menu → Logout → returns to sign-in.
8. As a user with no location settings, the menu opens with identity + actions and **no** location lines, no error (FR-014).
8a. As a user **without catalog permissions** (e.g. a cashier), the location names still appear — they come from the own-profile `/auth/me` data, not catalog lookups. Before the mbe-api `/auth/me` name enrichment ships, all users see the labeled-ID fallback ("Store 51", "POS 18", "Drawer 14") — verify no error/logout.

### US3 — Home welcome
9. Default build: Home shows the default placeholder image + generic welcome (SC-005).
10. Branded build (`--dart-define` above): Home shows the configured asset + display name. Point `BRAND_WELCOME_ASSET` at a missing path → falls back to the placeholder (no broken-image box).
11. Resize Home from narrow to wide: content scales, no overflow/clipping.

### US4 — Catalog actions beside search
12. Open Products: **Add** and **Merge** appear to the **right of the search bar** (not in the app bar), with **Add** styled as primary (SC-006). Both still navigate as before.
13. Open Users: **Add** appears beside the search bar, primary-styled.
14. As a user without create (and without merge) privilege, those buttons are absent (FR-020). Narrow the window: the search field + buttons reflow without horizontal overflow (FR-021).

## Automated checks

```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test \
  test/widget/core/widgets/app_shell_test.dart \
  test/widget/core/widgets/app_navigation_test.dart \
  test/widget/core/widgets/user_menu_button_test.dart \
  test/widget/core/widgets/catalog_filter_bar_test.dart \
  test/widget/features/home_welcome_test.dart \
  test/widget/features/catalog/products_list_screen_test.dart \
  test/integration/navigation_shell_flow_test.dart
flutter test   # full suite (regression: existing catalog/list tests still green)
```

**Expected**: analyzer clean; all listed widget/integration tests pass; the pre-existing suite stays green after list screens lose their `Scaffold`/`AppBar` and gain filter-bar actions.
