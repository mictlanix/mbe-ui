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
