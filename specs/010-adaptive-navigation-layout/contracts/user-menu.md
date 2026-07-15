# Contract: UserMenuButton — `core/widgets/user_menu_button.dart`

The app bar's single trailing control representing the signed-in user (FR-009–FR-014).

## Signature

```dart
class UserMenuButton extends ConsumerWidget {
  const UserMenuButton({super.key});
}
```

## Behavior

- Trigger: a single icon/avatar button (`Key('user_menu_button')`). Renders nothing (or a disabled placeholder) when the session is not `AuthAuthenticated`.
- On activation, opens a menu (`MenuAnchor`/`PopupMenuButton`) containing, top-to-bottom:
  1. **Identity header** — `user.email` (`Key('user_menu_identity')`). Non-interactive.
  2. **Location context** — one line each for store / point of sale / cash drawer, read from `user.settings` (own-profile `/auth/me` data): the **name** (store) or **name (code)** (POS/cash drawer) when present. A line whose id is null (or `settings == null`) is **omitted** (FR-014); a line whose id is present but has no name (before the mbe-api `/auth/me` enrichment ships, or a null name) shows the **labeled-ID fallback** — "Store {id}" / "POS {id}" / "Drawer {id}" (localized) — without error (FR-011). No RBAC and no network call — this is own-profile session data. Keys: `user_menu_store`, `user_menu_pos`, `user_menu_cash_drawer`.
  3. Divider.
  4. **Change Password** (`Key('user_menu_change_password')`) → `context.push('/auth/account/password')` (FR-012).
  5. **Logout** (`Key('user_menu_logout')`) → `ref.read(authNotifierProvider.notifier).signOut()` (FR-013).
- All labels localized (`AppLocalizations`); no hardcoded strings.
- Long email/ID strings wrap or ellipsize without breaking the menu layout (edge case).

## Acceptance (widget test `user_menu_button_test.dart`)

1. Exactly one trigger button renders for an authenticated session.
2. Opening the menu shows the email and the three location lines for a user whose `settings` include names — store as `name`, POS/cash drawer as `name (code)`.
3. A user with `settings == null` shows the identity + Change Password + Logout, and **no** location lines, without error (FR-014).
6. With `settings` holding ids but **no names** (pre-enrichment state), the three lines render the labeled-ID fallback ("Store 51", "POS 18", "Drawer 14") without error (FR-011).
4. Tapping Change Password pushes `/auth/account/password`.
5. Tapping Logout invokes `signOut()` on the auth notifier (verify via overridden provider/mock).
