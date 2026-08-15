# Quickstart: validating User Profiles as Permission Templates

**Feature**: `024-user-profiles` | **Date**: 2026-08-14

How to prove the feature works. *What* to build lives in [plan.md](./plan.md),
[data-model.md](./data-model.md) and [contracts/](./contracts/); this file is
the run-and-validate guide.

---

## Prerequisites

- Flutter stable, Dart 3.10.3+
- mbe-api reachable — default `http://127.0.0.1:8000`, override with
  `--dart-define=API_BASE_URL=https://...`. The server must include mbe-api
  `014-user-profiles` (merged in `cb7a188`) and migration `014_user_profiles.sql`.
- **An administrator account** — every profile endpoint is administrator-only.
- **A non-administrator account holding `USERS (1)` READ** — the account that
  proves the gate. This is the case most easily missed: it can reach `/users`
  but must see no profile navigation entry, no route, no picker and no apply
  action (FR-031–FR-034).
- At least one employee record, so a user can be created.
- A throwaway user account to apply profiles to. Do **not** use the account you
  are signed in as for the ordinary apply walkthrough — applying ends its
  sessions.

## Build and check

Run in order; the codegen steps are not optional, since entities, controllers
and localizations are all generated.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

`flutter analyze` must be clean and `flutter test` green. The l10n parity test
reads relative paths — **run from the repo root** or it fails spuriously.

## Unit and widget tests

```bash
flutter test test/unit/features/auth/
flutter test test/widget/features/auth/
flutter test test/unit/app/router/app_router_test.dart
flutter test test/unit/core/l10n_parity_test.dart
```

The five carrying the most risk:

| Test | Proves |
|---|---|
| `user_profile_repository_impl_test.dart` | A zero mask is **not** submitted, and a sparse response maps back to a `List<Privilege>` missing those objects. This is the sparse-write rule (FR-010/FR-012) both directions. |
| `user_profiles_controller_test.dart` | `applyProfile` **replaces** form privileges from the response rather than merging, and a failed apply leaves state untouched (FR-022/FR-023). |
| `users_controller_test.dart` | A create with a profile issues **exactly one** call — no follow-up privileges `PUT` (research §7). The single most damaging slip in this feature. |
| `app_router_test.dart` | The administrator gate allows an administrator and redirects a `users:read` non-administrator, and `AppShell.navigationShell.currentIndex == NavBranch.userProfiles`. The branch-index assertion is all that stands between a renumbering slip and a silently wrong screen. |
| `user_detail_screen_test.dart` | Both consequence strings render in the confirmation, and the self-apply warning appears **only** when the target is the signed-in user (FR-020/FR-024). |

**If unrelated auth tests fail at teardown**, check for a missing
`userProfileRepositoryProvider` override: the users list and detail screens now
fetch profiles, so any pump of those screens needs the fake wired in — the same
trap spec 021 hit when it added a branch.

## Manual walkthrough

Run the app against a live server, signed in as an administrator.

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### A. Author a profile (US1)

1. Confirm **User Profiles** appears in the navigation beside **Users**.
2. Open it. On an empty install the list reads as "none yet", not as an error.
3. Create a profile named `Cashier`, description `Front counter`, granting read
   on Products and create+read on Sales Orders. Leave everything else unticked.
4. Reopen it. Exactly those three checkboxes are ticked; every other row is
   unticked, across all pages of the grid. → **FR-012, SC-007**
5. Create a second profile named `cashier`. The save is refused, the name field
   explains the conflict, and the permissions you ticked are still there.
   → **FR-013**
6. Search `cash` — both matching profiles listed. Filter by status. Reload the
   page: search, filter and page all survive. → **FR-002, FR-003, FR-004**
7. Create `Empty Role` with nothing ticked. It saves. → **FR-011**
8. Delete `Empty Role` — confirmation first, then gone. → **FR-008**

### B. Provision from a profile (US2)

9. Create a user, choosing `Cashier` in the profile picker. Note the permission
   grid disappears while a profile is selected. Save.
10. Open the new account. Its permissions match `Cashier` exactly, and it shows
    *provisioned from Cashier*. → **FR-017, SC-003**
11. Open the throwaway account. Hand-tick several unrelated permissions and
    save.
12. Apply `Cashier` to it. Read the confirmation: it must name the profile and
    state both that permissions are replaced and that sessions end. Cancel —
    nothing changes. → **FR-020, FR-021**
13. Apply again and confirm. Without reloading, the grid now matches `Cashier`
    and the hand-ticked permissions are gone. → **FR-013 (api), FR-022, SC-004**
14. Retire `Cashier` (status → inactive). It is still readable in the catalog
    but no longer offered by either picker. → **FR-015, FR-016, FR-019**

### C. Find and re-provision (US3)

15. Reactivate `Cashier` and provision a second account from it.
16. On the users list, both rows show `Cashier`; hand-built accounts show
    nothing. → **FR-027**
17. Filter the users list by `Cashier` — exactly those two accounts. Copy the
    URL, open it in a new tab: the filter is still applied and the picker shows
    the profile's **name**, not its id. → **FR-028**
18. Edit `Cashier` to drop a permission. Neither account changes. Re-apply to
    one; only that one changes. → **US3 scenario 6, SC-006**

### D. Access control

19. Sign in as the `users:read` non-administrator.
20. No **User Profiles** navigation entry. → **FR-033**
21. Navigate to `/user-profiles` directly — redirected to `/`. → **FR-032**
22. Open `/users/new` — no profile picker. Open an existing user — no apply
    action. → **FR-034, SC-007**

### E. Self-apply (the one to do last)

23. Sign back in as an administrator. Create a profile granting anything.
24. Apply it **to your own account**. The confirmation carries the extra warning
    that your own session will end.
25. Confirm. The apply succeeds. On your next navigation you land on
    `/auth/login` — signed out, **not** shown an error. → **FR-024**
26. Sign back in. Your account still works: administrators bypass per-object
    checks, so a restrictive profile does not lock you out.

## Expected outcomes

| Criterion | Validated by |
|---|---|
| SC-001, SC-002 | Step 9 — one picker instead of the per-object walk |
| SC-003 | Steps 10 + 15 — two accounts, identical grids |
| SC-004 | Step 13 — grid matches the profile with no reload |
| SC-005 | Steps 8 + 12 — both irreversible actions confirm first |
| SC-006 | Step 17 — one filter action finds every provisioned account |
| SC-007 | Steps 20–22 — no path anywhere for a non-administrator |
| SC-008 | `flutter test` — existing user tests pass unmodified |
| SC-009 | `l10n_parity_test.dart` + switching locale on any new screen |
