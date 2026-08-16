# Contract: App Settings & User Display Preferences

**Feature**: 027-app-user-settings

Two levels of configuration that must never be conflated (constitution §V):
what a **deployment** fixes at build time, and what a **user** chooses on
their device.

---

## Level 1 — App settings (deployment, build-time, not UI-mutable)

### How they are supplied

```bash
flutter run  --dart-define-from-file=.env
flutter build web --dart-define-from-file=.env
```

The same mechanism the repo already uses for integration tests. There is no
runtime-parsed config file and no `flutter_dotenv` dependency: values are
compile-time constants, so they const-fold and tree-shake, and the white-label
build seam stays where constitution §V puts it.

**One format, one mechanism, two files** — `.env` is gitignored and already
owned by integration-test credentials:

| File | Audience | Contents |
|---|---|---|
| `.env` | the developer, gitignored | test credentials + any local overrides |
| `deploy/<customer>.env` | the deployment | that customer's endpoints, brand, formats |
| `.env.template` | documentation | **both** sections, every key with its default |

A test that asserts formatted output overrides `appSettingsProvider` rather
than depending on whatever the developer's `.env` happens to say.

### How they are read

```dart
final settings = ref.watch(appSettingsProvider);
settings.apiBaseUrl
settings.formatting.currencySymbol
settings.brand.displayName        // BrandConfig, composed unchanged
```

Never `String.fromEnvironment` at a feature call site. The four existing sites
(`dio_client.dart`, `photo_url.dart`, `pos_defaults.dart`,
`brand_config.dart`) consolidate here.

### The keys

Existing keys and defaults are **preserved exactly** — current deployment
scripts keep working with no edit.

| Key | Default | Status |
|---|---|---|
| `API_BASE_URL` | `http://127.0.0.1:8000` | existing |
| `PHOTOS_BASE_URL` | *= `API_BASE_URL`* | existing |
| `POS_DEFAULT_CUSTOMER_ID` | `1` | existing |
| `BRAND_DISPLAY_NAME` | `Mictlanix Business Essentials` | existing |
| `BRAND_SEED_COLOR` | *(unset ⇒ XBE palette)* | existing |
| `BRAND_WELCOME_ASSET` | *(unset)* | existing |
| `BRAND_LOCKUP_ASSET` | `assets/brand/login_lockup.png` | existing |
| `BRAND_MARK_ASSET` | `assets/brand/nav_lockup.png` | existing |
| `ENABLE_FLUTTER_DRIVER_EXTENSION` | `true` | existing |
| `DEFAULT_LOCALE` | `es_MX` | **new** |
| `CURRENCY_SYMBOL` | `$` | **new** |
| `CURRENCY_CODE` | `MXN` | **new** |
| `CURRENCY_DECIMAL_DIGITS` | `2` | **new** |
| `DATE_FORMAT` | `yMd` | **new** |
| `DATE_TIME_FORMAT` | `yMd Hm` | **new** |
| `PERCENT_DECIMAL_DIGITS` | `2` | **new** |
| `QUANTITY_DECIMAL_DIGITS` | `0` | **new** |

`PHOTOS_BASE_URL` defaulting to `API_BASE_URL` is a **const cross-reference**;
both must remain compile-time constants for that defaulting to resolve.

### Guarantees

- **No `.env` required.** A build with none runs on the defaults above.
- **A malformed value never bricks startup.** It falls back to its default —
  the rule `BrandConfig._parseSeedColor` already applies to a bad hex colour.
- **`.env.template` is the documentation.** Every key above appears there with
  its default and a one-line description; that file is the single source, not
  a duplicate of this table.
- **Not reachable from the UI.** No screen reads or writes app settings.

---

## Level 2 — User display preferences (personal, device-local)

### How they are read

```dart
final prefs = ref.watch(userDisplayPreferencesProvider);
prefs.themeMode        // ThemeMode.light | dark | system
prefs.textSizeLevel    // TextSizeLevel.small | normal | large | extraLarge
prefs.localeOverride   // Locale?  — null means follow the deployment default
```

### The settings screen

Reached from the user menu (`core/widgets/user_menu_button.dart`), beside the
existing change-password entry. **No RBAC gate** — display preferences are
personal, available to every signed-in user. Follows the standard screen
conventions: shared responsive form grid, empty `AppBar.actions`.

| Control | Options | Effect |
|---|---|---|
| Appearance | Light / Dark / System | `MaterialApp.themeMode` |
| Text size | four levels | `MediaQuery.textScaler` |
| Language | Español / English / follow system | `MaterialApp.locale` **and** formatting |

Every change applies **immediately** — no restart, no re-login — and persists
on that device.

### Storage

`shared_preferences`, loaded **once in `main()` before `runApp`** and injected
through a `ProviderScope` override. Preference reads are therefore synchronous
and the first frame is already correct.

This fixes an existing defect: `ThemeModeController` currently returns the
default and restores asynchronously, so a user who chose Dark sees a flash of
light theme on every launch. Adding locale to that pattern would be worse — a
locale flash re-runs the localization delegates.

**Existing key `theme_mode` is reused**, so choices already stored survive the
upgrade (FR-017). A corrupt or unreadable value is treated as absent and falls
back to the default — never a startup error.

### What these are *not*

They are **not** the server-side `UserSettings` in
`core/access/user_settings.dart`, which carries the user's cash drawer and
point of sale. Those are operational assignments that follow the user across
machines; these are display taste that does not. The type is named
`UserDisplayPreferences` precisely so the two never get confused, and nothing
here is sent to mbe-api.

**Accepted consequence**: preferences do not follow a user to another machine.

---

## Text scaling

The chosen level **composes with** the platform's own text scaler rather than
replacing it:

```
effective.scale(size) == platform.scale(size * level.factor)
```

- A user who scaled text at the OS level keeps that scaling, with the app
  level applied on top. Replacing it would mean someone on a 1.5× system who
  picks "Grande" (1.15×) gets *smaller* text than before.
- At `normal` (1.0) the composition is the identity, so the default rendering
  — and every golden and screenshot baseline — is unchanged.
- Delegating to `platform.scale` rather than multiplying a number keeps
  non-linear platform scalers correct.

Applied via `MediaQuery` in `App.build`'s existing `builder`, above
`DesignTheme.forTier`, so every route, dialog and sheet inherits it.

**Largest level**: no screen may clip, overflow or hide content at supported
desktop widths. The POS capture surface is the screen this actually constrains
— see [screen-structure.md](screen-structure.md).
