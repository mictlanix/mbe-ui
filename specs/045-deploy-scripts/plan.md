# Implementation Plan: Deployment Scripts

**Branch**: `045-deploy-scripts` | **Date**: 2026-10-02 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/045-deploy-scripts/spec.md`

## Summary

One Bash entry point, `tool/release.sh <web|ios|android|all> <deployment>`,
releases a *deployment* (a brand + its app settings) to each platform: the web
build (WebAssembly with JS fallback) is left in `build/web/` for the operator
to copy to a server (hosting descoped 2026-10-02); the iOS build is archived unsigned,
cloud-signed and uploaded to TestFlight by `xcodebuild -exportArchive`; the
Android build is signed with an environment-supplied upload key and left on
disk (no Play upload). Per-brand native identity comes from two generated,
gitignored build files (iOS xcconfig, Android properties) rather than Flutter
`--flavor`, and per-brand artwork from a committed overlay staged into the tree
for the build. The first deployment, `demo`, is the white-label `mbe` brand
against `https://test.api.mbe.mictlanix.com`. Details and evidence:
[research.md](research.md).

## Technical Context

**Language/Version**: Bash 3.2+ (macOS default) for scripts; Kotlin DSL
(Gradle) and xcconfig for native build changes; Flutter 3.44.2 / Dart ^3.10.

**Primary Dependencies**: Flutter CLI, Xcode 26+ (`xcodebuild`), Android SDK
(`apksigner`), git. No fastlane, no Ruby (research R3).

**Storage**: N/A — configuration files in `deploy/`.

**Testing**: ShellCheck for scripts; validation scenarios V1–V7 in
[quickstart.md](quickstart.md). Existing `flutter test` suite must stay green
(native-config changes must not affect Dart).

**Target Platform**: release machine macOS; outputs for iOS 13+, Android
minSdk 24 / targetSdk 36, web (Chromium → wasm, others → JS).

**Project Type**: mobile + web app (existing Flutter project) gaining release
tooling.

**Performance Goals**: preflight verdict < 30 s (SC-003); published site
reaches sign-in < 5 s on broadband (SC-008).

**Constraints**: non-interactive; no secret in repo or logs; release must
leave the working tree as it found it; white-label `flutter run` unaffected.

**Scale/Scope**: 1 brand / 1 deployment now; structure for N brands.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | Notes |
|---|---|---|
| I. Feature-first layered architecture | N/A | No `lib/` code. |
| II. Riverpod | N/A | — |
| III. Contract-driven API integration | PASS | No API change. CORS for the web origin and the test API's availability are external dependencies; if CORS is missing, file an mbe-api/infra issue, never patch around it (research R10). |
| IV. Deny-by-default RBAC | N/A | — |
| V. White-labeled design system | PASS with PATCH amendment | App settings still resolve from `--dart-define-from-file` (unchanged). Native identity per brand comes from generated build config, not `--flavor`; §V's "build-time Flutter flavors" wording gets a clarifying PATCH (1.13.1 → 1.13.2), proposed against DESIGN.md §4.x first per Governance (research R1). |
| VI. Desktop/web-first | PASS | Web is P1; wasm preferred. |
| VII. Online-only, server-rendered documents | PASS | `--no-web-resources-cdn` keeps the web app on one origin, consistent with spec 044 FR-014. |
| Tech stack defaults | PASS | No new runtime dependency. |
| Quality gates | PASS | Scripts verified by ShellCheck + quickstart; `flutter test` stays green. |

**Post-design re-check**: unchanged — no violations; Complexity Tracking empty.

## Project Structure

### Documentation (this feature)

```text
specs/045-deploy-scripts/
├── plan.md
├── research.md          # R1–R10
├── data-model.md        # Brand, Deployment, Release, generated files
├── quickstart.md        # V1–V7
├── contracts/
│   ├── release-cli.md   # tool/release.sh arguments, behaviour, exit codes
│   └── environment.md   # credential variables
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
tool/
├── release.sh                     # NEW entry point
└── release/
    ├── lib.sh                     # NEW preflight, versioning, staging, trap, logging
    ├── web.sh                     # NEW wasm build + per-brand web metadata
    ├── ios.sh                     # NEW unsigned archive + export/upload
    ├── android.sh                 # NEW aab + apk + signature verification
    ├── brand_artwork.sh           # NEW one-time overlay generation (temp worktree)
    └── overlay-manifest.txt       # NEW required overlay paths (FR-013)

deploy/
├── README.md                      # UPDATED: points to RELEASING.md
├── RELEASING.md                   # NEW one-time setup, per-release steps, adding a brand (FR-030/031)
├── demo.env                       # NEW API_BASE_URL=https://test.api.mbe.mictlanix.com
├── demo.release                   # NEW BRAND=mbe
└── brands/
    └── mbe/
        └── brand.properties       # NEW white-label identity (no overlay: repo baseline)

ios/
├── Flutter/Debug.xcconfig         # UPDATED white-label defaults + #include? "Brand.xcconfig"
├── Flutter/Release.xcconfig       # UPDATED same
├── Runner/Info.plist              # UPDATED CFBundleDisplayName=$(BRAND_DISPLAY_NAME); ITSAppUsesNonExemptEncryption=false
└── Runner.xcodeproj/project.pbxproj   # UPDATED drop Runner-target PRODUCT_BUNDLE_IDENTIFIER/DEVELOPMENT_TEAM

android/app/
├── build.gradle.kts               # UPDATED brand.properties → applicationId/app_name; env-based release signing, no debug fallback
└── src/main/AndroidManifest.xml   # UPDATED android:label=@string/app_name

.gitignore                         # UPDATED Brand.xcconfig, android/brand.properties, *.jks, *.keystore, *.p8, key.properties
.env.template                      # UPDATED pointer to deploy/RELEASING.md for release credentials
.specify/memory/constitution.md    # UPDATED §V PATCH wording (1.13.2)
DESIGN.md                          # UPDATED §4.x: brand selection mechanism (precedes the amendment)
```

**Structure Decision**: release tooling lives under `tool/` next to the
existing `generate_api_client.sh`; all per-deployment and per-brand data lives
under `deploy/`, extending the convention deploy/README.md already
established. Adding a brand touches only `deploy/` (SC-006).

## Implementation Order

1. **Native seams, white-label only** (no behaviour change): xcconfig defaults
   + `#include?`, pbxproj cleanup, Info.plist, Gradle brand properties,
   manifest label, gitignore. Verify `flutter run` (iOS + Android) still
   white-label, `flutter test` green.
2. **Shared lib + preflight + versioning** (`lib.sh`, `release.sh`, `--list`,
   `--status`) → quickstart V1.
3. **Web** (`web.sh`, `demo.*`) → V2. P1.
4. **iOS** spike then script (`ios.sh`, Info.plist encryption key) → V3. P1.
   The spike settles research R3's disagreement on the first real upload.
5. **Android** signing config + `android.sh` → V4.
6. **`all` mode** → V5.
7. **Brand overlay + `brand_artwork.sh` + manifest** → V6 with a throwaway brand.
8. **Docs** (`RELEASING.md`, README, `.env.template`), DESIGN.md + constitution
   PATCH → V7 final sweep.

Steps 3 and 4 are independent after step 2; web is not blocked on Apple
setup, and iOS is not blocked on the test API being reachable (upload works;
only the sign-in check waits).

## Risks & Open Items

- **Test API not live**: `test.api.mbe.mictlanix.com` did not resolve on
  2026-10-02 (research R10). Scripts and builds proceed; SC-001 waits on it.
- **CORS** for the web origin — external; issue if missing.
- **iOS signing path** (research R3): unsigned-archive + cloud-signed export is
  primary; sign-at-archive is the fallback. Team `4ZJ2FWD2BR` confirmed
  2026-10-02: an *Apple Distribution* certificate for it is in the release
  Mac's keychain (so local sign-at-archive is also available), and the App
  Store Connect record "Mictlanix Business Essentials" exists. It is an
  individual developer account (José Augusto González Reyes), so the store
  seller name is the individual's, not Mictlanix's. **Decided 2026-10-04: the
  individual account stays** — it suits the current small team; no
  organization account (D-U-N-S) is planned.
- **iOS `--build-only`** yields an *unsigned* archive (signing happens at
  export). This is a narrow reading of FR-003 ("signed artifact"); producing a
  signed `.ipa` without uploading would need the same credentials via
  `destination=export` — add only if needed.
- **wasm runtime** of PDF preview and file picker unverified until V2; JS-only
  fallback per FR-026.
- **Web hosting descoped** (2026-10-02): research R6/R7 (DigitalOcean) are
  superseded; the server's SPA fallback and wasm MIME type are the operator's
  (documented in `deploy/RELEASING.md`).
- **Staging interrupted by SIGKILL** leaves overlay files in the tree; caught by
  the next run's dirty-tree check (FR-006); generated gitignored files are
  rewritten/removed at every start.

## Complexity Tracking

No constitution violations.
