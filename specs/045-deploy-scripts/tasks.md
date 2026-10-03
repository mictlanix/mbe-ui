---
description: "Task list for 045-deploy-scripts"
---

# Tasks: Deployment Scripts

**Input**: Design documents from `specs/045-deploy-scripts/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The spec requests no automated test suite. Verification is
ShellCheck plus the runnable scenarios V1–V7 in [quickstart.md](quickstart.md),
which appear below as explicit verification tasks. `flutter test` must stay
green after any native change.

**Organization**: Grouped by user story (US1–US5, spec.md). All scripts are
Bash under `tool/`; per-deployment data under `deploy/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 web demo · US2 iOS TestFlight · US3 Android build · US4 brand onboarding · US5 unattended/CI-ready

## Operator prerequisites (not tasks — the user does these)

- ASC API key + app record + distribution cert: **done 2026-10-02**
  (`MBE_ASC_KEY_ID=9SRYTMY8Z8`, key in `~/.private_keys/`).
- Needed before V2: a web server to copy `build/web/` to (rsync to the private
  Mictlanix server today) with SPA fallback and the wasm MIME type.
- Needed before V4: Android upload keystore (`keytool` command in
  `deploy/RELEASING.md`, T041) and the four `MBE_ANDROID_*` variables.
- Needed for any sign-in check: `test.api.mbe.mictlanix.com` live and allowing
  the web origin (research R10) — builds and uploads do not wait on it.

---

## Phase 1: Setup

**Purpose**: scaffolding that every later task writes into.

- [X] T001 [P] Add to `.gitignore`: `ios/Flutter/Brand.xcconfig`, `android/brand.properties`, `*.jks`, `*.keystore`, `*.p8`, `AuthKey_*.p8`, `key.properties`, `build/ios/ipa/` (FR-018); do not touch existing entries
- [X] T002 [P] Create directories `tool/release/` and `deploy/brands/mbe/` (empty placeholders become real files in later tasks)
- [X] T003 [P] Install ShellCheck locally (`brew install shellcheck`) and record in `deploy/RELEASING.md` stub header that scripts must be ShellCheck-clean (full doc is T041)

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the native identity seam, the white-label deployment definition, and the shared script library. No behaviour change for `flutter run`.

### Native seam (white-label only)

- [X] T004 In `ios/Flutter/Debug.xcconfig` and `ios/Flutter/Release.xcconfig` append white-label defaults (`PRODUCT_BUNDLE_IDENTIFIER = com.mictlanix.mbe`, `BRAND_DISPLAY_NAME = Mictlanix Business Essentials`, `DEVELOPMENT_TEAM = 4ZJ2FWD2BR`) followed by `#include? "Brand.xcconfig"` as the **last** line (research R1)
- [X] T005 In `ios/Runner.xcodeproj/project.pbxproj` remove the Runner **app** target's `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM` from Debug/Release/Profile build settings so xcconfig values take effect; leave `RunnerTests` (`com.mictlanix.mbe.RunnerTests`) and the macOS project untouched. This absorbs the currently uncommitted team change (`27A9BJM65R`→`4ZJ2FWD2BR`). Do not "fix" the unrelated `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon` lines — mention them in the PR instead
- [X] T006 In `ios/Runner/Info.plist` change `CFBundleDisplayName` to `$(BRAND_DISPLAY_NAME)`
- [X] T007 [P] In `android/app/build.gradle.kts` read optional `android/brand.properties` (keys `APPLICATION_ID`, `DISPLAY_NAME`); default to `com.mictlanix.mbe` / `Mictlanix Business Essentials`; set `applicationId` and `resValue("string", "app_name", …)`; keep `namespace = "com.mictlanix.mbe_ui"`
- [X] T008 [P] In `android/app/src/main/AndroidManifest.xml` set `android:label="@string/app_name"`
- [X] T009 Verify the seam: `flutter build ios --debug --no-codesign` and `flutter build apk --debug` succeed, resulting app id/name are white-label, `flutter test` green. (Checkpoint — nothing below proceeds if white-label identity changed)

### White-label deployment definition

- [X] T010 [P] Create `deploy/brands/mbe/brand.properties` with `BUNDLE_ID`, `APPLICATION_ID`, `DISPLAY_NAME`, `IOS_TEAM_ID=4ZJ2FWD2BR`, `WEB_TITLE`, `WEB_THEME_COLOR=#14120F` per data-model.md (no `src/`/`overlay/` — repo is its baseline)
- [X] T011 [P] Create `deploy/demo.env` with `API_BASE_URL=https://test.api.mbe.mictlanix.com` plus the white-label values from `.env.template` that differ from code defaults (none required; keep it minimal)
- [X] T012 [P] Create `deploy/demo.release` with `BRAND=mbe`, `WEB_DEPLOY_REPO=git@github.com:mictlanix/mbe-ui-web-deploy.git`, `WEB_DEPLOY_BRANCH=web/demo`

### Shared library and entry point

- [X] T013 Create `tool/release/lib.sh` (sourced, no top-level side effects): `err`/`warn`/`info` helpers that never echo secrets; problem accumulator (`problem "msg"`, `fail_if_problems` → exit 3); `.properties`/`.release` parser (no `eval`); deployment + brand resolution and validation per data-model.md field rules; `version_name` from `pubspec.yaml` (before `+`); `build_number` = minutes since 2026-01-01T00:00Z (research R8); git helpers (`is_dirty`, `head_sha`); `require_tool`; `require_env`/`require_file_env` (checks path readable and **outside** the repo) (FR-004/019)
- [X] T014 In `tool/release/lib.sh` add brand staging: `write_brand_files <brand>` (writes `ios/Flutter/Brand.xcconfig` + `android/brand.properties` from `brand.properties`), `clear_brand_files`, and an EXIT/INT/TERM trap that calls `clear_brand_files`; every run calls `clear_brand_files` at start so stale files from a killed run never leak (research R2 risks)
- [X] T015 Create `tool/release.sh`: parse `<platform> <deployment>` + `--build-only --allow-dirty --push-tag --list --status`; run stdin from `/dev/null`; dispatch to `tool/release/{web,ios,android}.sh` (functions `preflight_<p>`, `build_<p>`, `publish_<p>`); exit codes 0/1/2/3 per [contracts/release-cli.md](contracts/release-cli.md); `--list` and `--status` implemented here; `all` is a stub that errors "not yet" until T040
- [X] T016 Make `tool/release.sh` and `tool/release/*.sh` executable (`chmod +x`) and ShellCheck-clean

**Checkpoint**: `tool/release.sh --list` shows `demo (brand mbe)`; `--status` reports white-label; unknown deployment exits 3.

---

## Phase 3: User Story 1 — White-label web demo (P1) 🎯 MVP

**Goal**: one command builds the wasm web bundle (hosting descoped 2026-10-02).

**Independent Test**: quickstart V2.

- [X] T017 [P] [US1] ~~Create `deploy/demo.app.yaml`~~ (removed 2026-10-02: hosting out of scope) (App Platform spec: `name: mbe-web-demo`, `static_sites[web]` from `github.repo`/`branch: web/demo`, `deploy_on_push: false`, `output_dir: /`, `index_document: index.html`, `catchall_document: index.html`) per research R6
- [X] T018 [US1] Create `tool/release/web.sh` `preflight_web`: tools (`flutter`, `git`, `doctl` unless `--build-only`); files (`demo.env`, `demo.app.yaml`); `API_BASE_URL` is https (FR-010) — put this shared check in `lib.sh` so ios/android preflights reuse it; for publish: `DIGITALOCEAN_ACCESS_TOKEN` set and `doctl account get` succeeds, `git ls-remote "$WEB_DEPLOY_REPO"` succeeds
- [X] T019 [US1] In `tool/release/web.sh` `build_web`: `flutter build web --release --wasm --no-web-resources-cdn --build-name <v> --build-number <n> --dart-define-from-file=deploy/<deployment>.env`; fail if `build/web/main.dart.wasm` or `main.dart.js` is missing (so a silent loss of wasm is caught); print bundle size
- [X] T020 [US1] ~~DigitalOcean publish~~ — replaced 2026-10-02 by a no-op `publish_web` (hosting out of scope). Original: In `tool/release/web.sh` `publish_web`: in a temp clone dir, replace contents with `build/web/`, commit with message `<deployment> <version>+<build> from <sha>`, force-push to `WEB_DEPLOY_BRANCH`; then `doctl apps spec validate`, `doctl apps create --spec … --upsert --wait` (first run) or `doctl apps update <id> --spec … --wait`, then `doctl apps create-deployment <id> --wait`; read the URL from `doctl apps get <id> --format DefaultIngress --no-header`; print summary row (FR-007). Temp dir removed by trap
- [X] T021 [US1] Add tagging to `tool/release.sh` after a successful publish: annotated tag `<deployment>/<platform>/v<version>-<build>` (message states `--allow-dirty` if used), pushed only with `--push-tag` (FR-017); build-only runs are never tagged
- [X] T022 [US1] **Verify V2** (operator-assisted): run `tool/release.sh web demo`; check wasm in Chrome, JS in Safari/Firefox, sign-in, PDF preview + file picker under wasm, deep-link reload, `curl -I` MIME + 304, second release picked up on one reload, sign-in screen < 5 s. If PDF preview or file picker fails under wasm, drop `--wasm` in `web.sh` and record the incompatibility in `research.md` R5 (FR-026)

**Checkpoint**: the white-label web demo is live at a public URL.

---

## Phase 4: User Story 2 — iOS TestFlight (P1)

**Goal**: one command uploads a signed white-label build to TestFlight.

**Independent Test**: quickstart V3.

- [X] T023 [P] [US2] In `ios/Runner/Info.plist` add `ITSAppUsesNonExemptEncryption` = `false` (FR-022; research R3)
- [X] T024 [US2] Create `tool/release/ios.sh` `preflight_ios`: tools (`flutter`, `xcodebuild`, `xcrun`); for publish require `MBE_ASC_KEY_ID`, `MBE_ASC_ISSUER_ID` (UUID shape), `MBE_ASC_KEY_PATH` (readable, outside repo); check `xcodebuild -version` ≥ 26 (Apple upload rule since 2026-04-28); `--build-only` needs no credentials
- [X] T025 [US2] In `tool/release/ios.sh` `build_ios`: `write_brand_files`, then `flutter build ipa --release --no-codesign --build-name <v> --build-number <n> --dart-define-from-file=deploy/<deployment>.env`; locate `build/ios/archive/Runner.xcarchive`; assert the archive's `Info.plist` `CFBundleIdentifier` equals the brand's `BUNDLE_ID` and `CFBundleVersion` equals the build number
- [X] T026 [US2] In `tool/release/ios.sh` `publish_ios`: generate an `ExportOptions.plist` in a temp dir (`method=app-store-connect`, `destination=upload`, `teamID`, `signingStyle=automatic`, `manageAppVersionAndBuildNumber=false`); run `xcodebuild -exportArchive -archivePath … -exportOptionsPlist … -allowProvisioningUpdates -authenticationKeyPath "$MBE_ASC_KEY_PATH" -authenticationKeyID "$MBE_ASC_KEY_ID" -authenticationKeyIssuerID "$MBE_ASC_ISSUER_ID"`; on success print the summary row and say "upload accepted; Apple processing continues" (spec edge case)
- [X] T027 [US2] **Spike + verify V3** (operator-assisted, first real upload): run `tool/release.sh ios demo`. If export fails on the unsigned archive, implement the sign-at-archive fallback in `ios.sh` (`xcodebuild archive -allowProvisioningUpdates -authenticationKey…`, then export) and update plan.md/research.md R3 with the outcome. Confirm build appears in TestFlight with no export-compliance prompt; second run gets a higher build number
- [X] T028 [US2] Add `--build-only` semantics note to `ios.sh`/`release-cli.md`: it yields the **unsigned** archive (plan risk); if a signed `.ipa` without upload is wanted, add `destination=export` — leave as a documented follow-up, do not build it

**Checkpoint**: the white-label iOS beta is installable from TestFlight.

---

## Phase 5: User Story 3 — Android store-ready bundle (P2)

**Goal**: one command produces a signed `.aab` and `.apk`; nothing is uploaded.

**Independent Test**: quickstart V4.

- [X] T029 [US3] In `android/app/build.gradle.kts` replace the debug-key release signing with a `release` signingConfig read from `MBE_ANDROID_KEYSTORE_PATH`, `MBE_ANDROID_KEYSTORE_PASSWORD`, `MBE_ANDROID_KEY_ALIAS`, `MBE_ANDROID_KEY_PASSWORD`; throw a `GradleException` naming every missing variable **only when a release task is in the task graph**; remove `signingConfigs.getByName("debug")` for release (FR-023). Debug builds unaffected; remove the stale TODO comment
- [X] T030 [P] [US3] Create `tool/release/android.sh` `preflight_android`: tools (`flutter`, `keytool`, `apksigner` from the SDK build-tools, resolved via `ANDROID_HOME`); the four `MBE_ANDROID_*` variables, keystore path readable and outside repo
- [X] T031 [US3] In `tool/release/android.sh` `build_android`: `write_brand_files`; `flutter build appbundle --release …` and `flutter build apk --release …` (same `--build-name/--build-number/--dart-define-from-file`); verify with `apksigner verify --print-certs` that the signer is the upload key (compare SHA-256 to `keytool -list` of the keystore) and fail if it is a debug cert; assert application id and `targetSdk ≥ 36` from the built manifest (`aapt2 dump badging`) (FR-025); print `.aab`/`.apk` paths + version/build; `publish_android` is a no-op that says "not published (out of scope)" (FR-024)
- [ ] T032 [US3] **Verify V4** (operator-assisted): generate the upload key (command in `deploy/RELEASING.md`, T041); run `tool/release.sh android demo`; side-load the APK and sign in; confirm `env -u MBE_ANDROID_KEYSTORE_PATH flutter build appbundle` fails naming the variable and `flutter run` (debug) still works

**Checkpoint**: signed Android artifacts exist locally; no Play dependency.

---

## Phase 6: User Story 4 — Branded customer as its own app (P3)

**Goal**: add brand #2 by adding files only; same commands.

**Independent Test**: quickstart V6 with a throwaway brand.

- [X] T033 [P] [US4] Create `tool/release/overlay-manifest.txt` listing every required overlay path (iOS `AppIcon.appiconset/*`, `LaunchImage.imageset/*`, `LaunchBackground.imageset/*`; Android `mipmap-*/ic_launcher*`, `drawable*/launch_background.xml` + splash PNGs, `values-v31/styles.xml`; web `favicon.png`, `icons/*`, `manifest.json`) — derive the concrete list from what `flutter_launcher_icons`/`flutter_native_splash` generate today in this repo
- [X] T034 [US4] Create `tool/release/brand_artwork.sh <brand>`: validate `deploy/brands/<brand>/src/` PNGs exist; make a temp `git worktree`; write a generated `flutter_launcher_icons` + `flutter_native_splash` config pointing at the brand's `src/`; run both in **non-flavor** mode there; copy only manifest paths into `deploy/brands/<brand>/overlay/`; remove the worktree (trap); never touch the live tree (research R2)
- [X] T035 [US4] In `tool/release/lib.sh` add `stage_overlay <brand>` (validate against the manifest — missing path → problem naming it, FR-013; then copy the overlay over the tree) and extend the T014 trap to restore the staged paths (`git checkout -- <paths>` + `git clean -fd` on overlay-only paths); skip entirely for a brand with no `overlay/` (the white-label default); call it from `build_ios`, `build_android`, `build_web`
- [X] T036 [US4] In `tool/release/web.sh` after `build_web`: for any brand, rewrite `<title>`, `apple-mobile-web-app-title` in `build/web/index.html` from `WEB_TITLE` and `theme_color`/`name`/`short_name` in `build/web/manifest.json` from `brand.properties` — operate on `build/web/` only, never `web/` (research R5/§5)
- [X] T037 [US4] **Verify V6**: create throwaway brand `zz-test` (id `com.mictlanix.zztest`, own name/icon/seed color) + `deploy/zz-test.env`/`.release`; run `brand_artwork.sh zz-test`; `tool/release.sh all zz-test --build-only` after T040, or each platform separately; confirm artifacts' id/name/icon/splash/colors, `git status --porcelain` empty afterwards, white-label rebuild byte-for-byte unaffected, deleting one overlay file fails naming it; install both APKs side by side. Remove the throwaway brand and confirm no file outside `deploy/` changed (SC-006)

**Checkpoint**: adding a brand touched only `deploy/`.

---

## Phase 7: User Story 5 — Unattended / CI-ready (P3)

**Goal**: every command runs with no terminal and leaks no secret.

**Independent Test**: quickstart V1 and V7.

- [X] T038 [US5] Audit all `tool/release*.sh`/`lib.sh`: no `read`, no interactive child tools (pass `--non-interactive`/`</dev/null`/`CI=true` equivalents where a tool prompts, e.g. `doctl`, `git` credential prompts via `GIT_TERMINAL_PROMPT=0`); never `set -x`; never echo any `MBE_*` secret, token or the `.p8`/keystore contents; ASC key is only ever referenced by path
- [X] T039 [US5] **Verify V1 and V7**: V1 scenarios (unknown deployment, missing credential, dirty tree, http API, stdin closed — each fails < 30 s with exit 3 before any build output) and V7 (`grep -F` of password/token in a captured full log finds nothing; `git ls-files | grep -E '\.(jks|keystore|p8)$'` empty; `shellcheck tool/release.sh tool/release/*.sh` clean)

---

## Phase 8: Polish & cross-cutting

- [X] T040 Implement `all` in `tool/release.sh`: run web, ios, android in order, continue past failure, print one summary row per platform, exit non-zero if any failed (FR-002); **verify V5** (unset `MBE_ASC_KEY_ID` → iOS row fails, web and Android succeed)
- [X] T041 [P] Write `deploy/RELEASING.md`: one-time setup per platform (Apple API key + app record + distribution cert; Android `keytool` command from research R4 and the four variables; `doctl` + token; deploy repo + DigitalOcean GitHub app; optional custom domain; test-API CORS prerequisite), a ready-to-copy `~/.config/mbe/release.env` template using the real variable names, the per-release procedure, `--build-only`/`--allow-dirty`/`--push-tag`, and the "Adding a brand" checklist (FR-030/031)
- [X] T042 [P] Update `deploy/README.md` to point at `RELEASING.md` and describe the `.release` and `.app.yaml` files; update `.env.template` with a one-line pointer that release credentials are in `deploy/RELEASING.md` (not in `.env`)
- [X] T043 [P] Amend `DESIGN.md` (§4.x brand configuration — find the section citing flavors) to record that native brand identity is selected by generated build config, not `--flavor`; then bump `.specify/memory/constitution.md` §V wording and version 1.13.1 → 1.13.2 (PATCH) per its Governance order, updating the "Last Amended" date and any Sync Impact header
- [ ] T044 Run the full quickstart V1–V7 once end to end on a clean checkout; run `flutter analyze` and `flutter test` to confirm no Dart regressions; update `plan.md` risks with outcomes (iOS signing path, wasm runtime result, App Platform size)
- [ ] T045 Open a PR for `045-deploy-scripts`; description lists the operator one-time steps, the iOS signing outcome, the pre-existing pbxproj `ASSETCATALOG_…SYMBOL_EXTENSIONS = AppIcon` oddity (not fixed), and the open decision about an Organization developer account before public release

---

## Implementation notes (2026-10-02)

Done and verified locally: T001–T021, T023–T026, T028–T031, T033–T043. Deviations
and findings:

- **Xcode 27 requires iOS deployment target ≥ 15.0** (research R3 had wrongly
  said keep 13.0). Raised to 15.0 in the Runner project with the owner's
  agreement (2026-10-02); iOS 13 and 14 are no longer supported.
- **CocoaPods removed; Swift Package Manager only.** Every plugin was already a
  Swift Package and CocoaPods only carried the `Flutter` stub pod (whose
  generated podspec pins 13.0). The owner ran `pod deintegrate`, deleted
  `ios/Podfile` and the two `Pods-Runner` xcconfig includes. Flutter's SwiftPM
  integration (scheme "Prepare Flutter Framework Script" pre-action,
  `FlutterGeneratedPluginSwiftPackage` references in the pbxproj, the two
  `xcshareddata/swiftpm/Package.resolved` folders) is now required and is part
  of this change.
- **Flutter 3.44 UIScene migration** (`AppDelegate` → `FlutterImplicitEngineDelegate`,
  `UIApplicationSceneManifest` in Info.plist, `MinimumOSVersion` dropped from
  `AppFrameworkInfo.plist`) is applied by `flutter build` automatically and kept:
  the two files must move together (a mismatched pair was caught and fixed).
  Info.plist's large diff is Flutter's rewrite of the file.
- `WEB_SHORT_NAME` was added to `brand.properties` so the white-label web output
  is unchanged ("MBE" short name / Apple title).
- T022 (web V2), T027 (iOS V3 first real upload) and T032's side-load/sign-in
  steps need operator credentials/devices and are **not done**. T026
  (`publish_ios`) is written but **unexercised**: no App Store Connect upload has
  been run.
- **T027 verified 2026-10-02**: `tool/release.sh ios demo` uploaded build
  396256 (commit 8239f77, tag `demo/ios/v1.0.0-396256`) on the first attempt.
  The **primary path works** — unsigned `flutter build ipa --no-codesign`, then
  `xcodebuild -exportArchive` cloud-signing with the Admin API key — so the
  sign-at-archive fallback was not needed. No ITMS/privacy-manifest warnings.
- **T022 verified 2026-10-02** on https://test.mbe.mictlanix.com (nginx on
  xolotl, rsync of `build/web/`): build 396230 with wasm + JS, local CanvasKit,
  deep links 200, `.wasm` → `application/wasm`; sign-in against the test API and
  the PDF preview work. Two fixes were needed: (1) a script bug left
  `index.html`/`manifest.json` mode 600 (`mktemp`+`mv`), giving 403 — fixed in
  `rewrite_web_brand`, plus a world-readable guard in `build_web`; (2) Ubuntu's
  nginx `mime.types` lacked `.mjs`, so `main.dart.mjs` and the pdf.js modules
  were `application/octet-stream` — fixed on the server and documented in
  `deploy/RELEASING.md`.
- **Web hosting descoped (2026-10-02)**: the DigitalOcean publish path, its app
  spec and the deploy-repo settings were removed; `web` is build-only like
  Android, and only iOS uploads/tags. The operator publishes with rsync.
- T044/T045 remain.

## Dependencies & Execution Order

- **Phase 1** → **Phase 2** → user stories. T004–T009 (native seam) gate iOS/Android stories; T013–T016 (lib/entry) gate all stories.
- **US1 (web)** needs T013–T016, T010–T012; independent of the native seam (T004–T009), so it can start as soon as the library exists.
- **US2 (iOS)** needs the native seam (T004–T006, T009) and T013–T016.
- **US3 (Android)** needs T007–T009 and T013–T016.
- **US4** needs US1–US3 build functions to hook `stage_overlay` into (T035 edits all three scripts) — start after their `build_*` exist; T033/T034 can start earlier.
- **US5** audits everything — last before polish; T038 is cheap to apply incrementally while writing each script.
- **T040** (`all`) needs US1–US3; **T044/T045** last.

```text
Phase 1 ─► Phase 2 ─┬─► US1 web ──────────────┐
                    ├─► US2 iOS  ─────────────┼─► US4 brand ─► US5 audit ─► Polish
                    └─► US3 Android ──────────┘
```

### Parallel opportunities

- Phase 1: T001, T002, T003 together.
- Phase 2: T007+T008 (Android seam) alongside T004–T006 (iOS seam); T010, T011, T012 together; T013 and T004–T008 are different files.
- After Phase 2: US1, US2, US3 are different files (`web.sh`/`ios.sh`/`android.sh`) and can proceed in parallel; T023, T030, T033, T017 are all `[P]`.
- Polish: T041, T042, T043 together.

## Implementation Strategy

- **MVP = Phase 1 + 2 + US1** (T001–T022): a public white-label web demo customers can open. That alone satisfies the first release's lowest-friction channel and needs no Apple/Google setup.
- **Increment 2 = US2** (T023–T028): TestFlight, the iPad demo channel.
- **Increment 3 = US3**, then **US4**, **US5**, polish.
- The two operator-assisted spikes — wasm runtime in T022 and the first real iOS upload in T027 — are where the plan's open risks resolve; do them as early as the prerequisites allow, since a failure changes `web.sh`/`ios.sh` (both have a documented fallback).

## Notes

- Commit after each task or logical group; the white-label `flutter run` must stay green at every commit.
- No task adds Dart code; only native build config, Bash, and `deploy/` data change.
- Not in scope and deliberately absent: Play upload, CI workflows, macOS/Windows/Linux, store metadata/screenshots.
