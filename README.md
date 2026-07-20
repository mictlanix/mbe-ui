# mbe-ui

Flutter frontend for **Mictlanix Business Essentials (MBE)** — sales, inventory, invoicing, and accounting.

Part of a ground-up rewrite that splits the legacy [`mbe`](../mbe) monolith into:

- **[mbe-api](../mbe-api)** — Python/FastAPI backend
- **mbe-ui** — this project, a Flutter client consuming mbe-api

See [DESIGN.md](DESIGN.md) for architecture decisions (state management, navigation, layering, RBAC, etc.).

---

## Target platforms

First delivery targets **desktop and web**: macOS, Windows, Linux, Web.
Android and iOS remain scaffold-only for now.

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter | stable, SDK `^3.10.3` | `flutter --version` |
| Dart | `^3.10.3` | bundled with Flutter |
| Docker | any recent | only needed to regenerate the OpenAPI client |
| mbe-api | running locally | `http://127.0.0.1:8000` — see mbe-api's README |

---

## Setup

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. Generate the OpenAPI client from a running mbe-api instance
#    (also runs build_runner inside the generated package)
./tool/generate_api_client.sh

# 3. Generate freezed / riverpod / json_serializable code
dart run build_runner build --delete-conflicting-outputs
```

### Re-running code generation

| When | Command |
|------|---------|
| mbe-api spec changed | `./tool/generate_api_client.sh` |
| Domain entities / providers changed (`*.dart` with `part '*.g.dart'`) | `dart run build_runner build --delete-conflicting-outputs` |

> **Note**: `*.g.dart` and `*.freezed.dart` files are gitignored — always regenerate locally before running or building.

---

## Run

```bash
flutter run -d chrome    # web
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

---

## Driving the running app (agent/automated testing)

`lib/main.dart` calls `enableFlutterDriverExtension()` before `runApp` in
every debug run, so any `flutter run` session (any target — `chrome`,
`macos`, etc.) can be inspected and driven programmatically instead of
requiring a human to click through the UI. This is how an AI coding agent
(or a script) verifies a change against the real running app and a live
mbe-api, beyond what the `flutter test` suite covers.

**Dev-only, by construction**: the call is wrapped in `if (kDebugMode)` in
`main.dart`. `kDebugMode` is a compile-time constant, so `flutter build`
(profile/release) tree-shakes the whole branch — `enableFlutterDriverExtension`
and the `flutter_driver` import never reach a shipped build. `flutter run`
(always debug by default) is the only path that enables it; nothing further
to configure.

**Connecting** (Claude Code with the `dart` MCP server, or any Dart Tooling
Daemon client):

1. Start the app: `flutter run -d chrome` (prints a `Debug service listening
   at: ws://127.0.0.1:PORT/...` line — that's the **app URI**, not the DTD
   URI).
2. Find the DTD URI: `mcp__dart__dtd` → `listDtdUris`. Pick the entry whose
   `Workspace Root` matches this repo and was started most recently.
3. Connect: `mcp__dart__dtd` → `connect` with that URI. The response lists
   connected app URIs (the same `ws://.../ws` printed in step 1).
4. Drive it:
   - `mcp__dart__get_runtime_errors` — check for uncaught exceptions
   - `mcp__dart__widget_inspector` (`get_widget_tree`) — inspect what's on
     screen; every interactive widget in this codebase carries a `Key(...)`
     for exactly this purpose
   - `mcp__dart__flutter_driver_command` — `tap` / `enter_text` / `waitFor`
     / `scroll` / `get_text` / `screenshot`, addressed by `ByValueKey` (the
     same keys used in `test/widget/`) or `ByText`
   - `mcp__dart__hot_reload` / `hot_restart` — apply code changes without
     relaunching (note: hot restart cannot pick up a **new pub dependency**;
     stop and re-run `flutter run` for that)

Example: navigate to a catalog screen and confirm it rendered —

```
tap        ByValueKey  nav_dest_expenses
waitFor    ByValueKey  expenses_table      # resolves once the list renders
```

---

## Project structure

```
lib/
  app/            # bootstrap, routing (go_router), theme
  core/           # shared: network (dio), error types, RBAC helpers, widgets, layout breakpoints
  features/
    auth/         # login, session, password management, admin Users screen ← implemented
  generated/
    openapi/      # dart-dio client generated from mbe-api's OpenAPI spec (do not edit)
  main.dart

specs/            # feature specs, implementation plans, and contracts
  001-user-authentication/
    spec.md       # requirements and acceptance scenarios
    plan.md       # implementation plan
    quickstart.md # manual validation steps against a live mbe-api
    tasks.md      # task breakdown

tool/
  generate_api_client.sh  # regenerates lib/generated/openapi/ from mbe-api's OpenAPI spec
```

---

## Current state

| Area | Status |
|------|--------|
| Core scaffolding (network, error mapping, token storage, theme, breakpoints, RBAC) | Done |
| Auth feature — login, session, password change/recovery, admin Users screen | In progress (`specs/001-user-authentication/`) |
| Sales, inventory, invoicing, accounting | Not started — unblocked once mbe-api publishes those endpoints |

---

## Key dependencies

| Package | Role |
|---------|------|
| `flutter_riverpod` + `riverpod_annotation` | State management and DI |
| `go_router` | Navigation and auth guards |
| `dio` | HTTP client with bearer-token interceptor |
| `freezed` + `json_annotation` | Immutable domain entities |
| `flutter_secure_storage` | Access token storage |
| `shared_preferences` | Theme-mode persistence |
| `flutter_localizations` + `intl` | es-MX locale and number/date formatting |
| `mbe_api_client` (path) | Generated dart-dio OpenAPI client |
