# Research: Deployment Scripts (045)

Three parallel investigations (native per-brand identity; web/WebAssembly +
DigitalOcean; iOS upload + Android signing), 2026-10-02, against Flutter
3.44.2 / Xcode 27.0 on the release Mac. Local verification is marked
**[verified]**; claims from docs carry their source.

---

## R1. Per-brand native identity: generated build config, not Flutter flavors

**Decision**: Native identity (bundle id / application id, display name, iOS
team) is chosen per build by two **generated, gitignored** files the release
script writes before building and deletes afterwards:

- `ios/Flutter/Brand.xcconfig`, pulled in by `#include? "Brand.xcconfig"` as
  the last line of `ios/Flutter/Debug.xcconfig` and `Release.xcconfig`
  (Profile already includes Release). Those two xcconfigs carry the
  white-label defaults (`PRODUCT_BUNDLE_IDENTIFIER=com.mictlanix.mbe`,
  `BRAND_DISPLAY_NAME=Mictlanix Business Essentials`,
  `DEVELOPMENT_TEAM=4ZJ2FWD2BR`).
- `android/brand.properties`, read by `android/app/build.gradle.kts` if
  present, else the same white-label defaults; sets `applicationId` and a
  `resValue("string", "app_name", …)`.

One-time edits so the generated values can take effect:

- `ios/Runner.xcodeproj/project.pbxproj`: remove the Runner target's
  `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM` from Debug/Release/Profile
  (target settings override xcconfig values). RunnerTests keep their own id.
- `ios/Runner/Info.plist`: `CFBundleDisplayName` → `$(BRAND_DISPLAY_NAME)`.
- `android/app/src/main/AndroidManifest.xml`: `android:label="@string/app_name"`.

With no generated file present, every build — including plain `flutter run` —
is the white-label app.

**Rationale**: Adding brand #2 must be "add files, run the script" (spec
US4). Real flavors make every brand edit shared native files: three new build
configurations and a scheme per brand in the pbxproj (`--flavor` fails
without a matching scheme — docs.flutter.dev/deployment/flavors-ios), Podfile
entries, an Android `productFlavors` block; flutter_native_splash 2.4.8's
flavor mode writes a new `LaunchScreen<Brand>.storyboard` that the old-style
project must reference by hand, and flutter_launcher_icons 0.14.4's flavor
mode only patches configurations whose xcconfig name contains `-<flavor>`.

**Alternatives considered**:

- *Real flavors* — rejected, above.
- *Reading Flutter's `dart-defines` natively* — works on Android
  (`FlutterPlugin.kt` exposes the `dart-defines` Gradle property) but on iOS
  `DART_DEFINES` reaches `Generated.xcconfig` only base64-encoded and cannot
  feed `PRODUCT_BUNDLE_IDENTIFIER` or `Info.plist`. Two mechanisms for one
  concept; rejected.
- *`FLUTTER_XCODE_<SETTING>` env vars* (passed by flutter_tools as xcodebuild
  build-setting arguments) — would work for command-line iOS builds but is
  invisible when a developer opens Xcode to run a brand, and has no Android
  counterpart. Kept as a fallback only.

**Constitution**: §V says brand tokens are configured "via build-time Flutter
flavors (`--dart-define`/flavor-specific entry points)". In-app tokens still
come from `--dart-define-from-file`; native identity now comes from generated
build config. Intent satisfied, wording misleading → PATCH amendment
(1.13.1 → 1.13.2) clarifying that "flavor" means a build-time brand selection,
not Gradle/Xcode `--flavor`. No Complexity Tracking entry needed.

---

## R2. Per-brand artwork: committed overlay, staged into the tree for the build

**Decision**: A branded customer's native and web artwork lives in
`deploy/brands/<brand>/overlay/`, mirroring repo paths (iOS
`AppIcon.appiconset`, `LaunchImage.imageset`, `LaunchBackground.imageset`;
Android `mipmap-*`, `drawable*`, `values*` splash resources; web `favicon.png`,
`icons/*`, `manifest.json`). The release script copies the overlay over the
working tree, builds, and **always restores** the tree on exit (trap:
`git checkout -- <paths>` + `git clean` on the overlay paths), including on
failure. The overlay is validated against a required-files manifest before the
build (FR-013).

**The white-label brand has no overlay**: the artwork already committed in the
repository *is* the `mbe` brand's artwork. Its `brand.properties` is defined
exactly like any other brand's (FR-008), but there is nothing to stage, which
keeps the first release free of any tree mutation. This is a deliberate
reading of FR-008: identity is defined uniformly; artwork has one baseline.

Overlays are produced once, at brand onboarding, by `tool/release/brand_artwork.sh
<brand>`: it runs flutter_launcher_icons and flutter_native_splash (non-flavor
mode, generated config pointing at `deploy/brands/<brand>/src/*.png`) inside a
temporary `git worktree`, then copies only the artwork paths into `overlay/`.
It never runs in the live tree, because both generators also rewrite pbxproj,
Info.plist, index.html and desktop icons.

**Rationale**: Splash resources have fixed names (storyboard,
`launch_background.xml`, `values-v31/styles.xml`), so they cannot be selected
by a build setting; overlaying is the only flavor-free option, and overlaying
the iOS AppIcon set too removes the need for per-brand
`ASSETCATALOG_COMPILER_APPICON_NAME`.

**Alternatives considered**: per-brand AppIcon sets selected by build setting
(works for icons only, not splash; two mechanisms); building in a throwaway
worktree every time (isolated and SIGKILL-proof, but pays `pub get` + CocoaPods
on every release — kept as the fallback if staging proves fragile).

**Risks**: a SIGKILLed build leaves overlay files staged; the next run's
dirty-tree check (FR-006) catches it. A leftover gitignored `Brand.xcconfig` /
`brand.properties` would not be caught by that check, so every release run
rewrites or deletes both at start, and `--status` prints which brand the tree
is configured for.

---

## R3. iOS: no fastlane; unsigned archive, cloud-signed export with upload

**Decision**:

1. `flutter build ipa --release --no-codesign --build-name <v>
   --build-number <n> --dart-define-from-file=deploy/<deployment>.env`
   → unsigned `build/ios/archive/Runner.xcarchive`.
2. `xcodebuild -exportArchive -archivePath … -exportOptionsPlist <generated>
   -allowProvisioningUpdates -authenticationKeyPath "$MBE_ASC_KEY_PATH"
   -authenticationKeyID "$MBE_ASC_KEY_ID" -authenticationKeyIssuerID
   "$MBE_ASC_ISSUER_ID"` with ExportOptions `method=app-store-connect`,
   `destination=upload`, `teamID`, `signingStyle=automatic`,
   `manageAppVersionAndBuildNumber=false` (default YES would rewrite our build
   number). This signs with an Apple-managed (cloud) distribution certificate
   and uploads to App Store Connect in one step.

The API key needs the **Admin** role for cloud-managed distribution signing.
No distribution certificate is needed in the keychain.

**Rationale**: only Xcode is required (no Ruby toolchain), and it is fully
headless. `flutter build ipa` alone cannot run headless: it passes
`-allowProvisioningUpdates` but never the `-authenticationKey*` flags
(flutter_tools `build_ios.dart`, `mac.dart`), so it signs only on a Mac with
an Xcode account signed in. (The only local signing identity today is an
individual's *Apple Development* certificate that may not belong to team
4ZJ2FWD2BR — another reason not to depend on local signing.)

**Disagreement surfaced, not averaged**: the native-identity investigation
proposed instead `flutter build ios --config-only` + `xcodebuild archive
-allowProvisioningUpdates -authenticationKey…` (sign at archive time), then
export. The iOS investigation rejected signing at archive time because on CI
Xcode would mint a new *Development* certificate per run and exhaust the
account's limit. **Primary path: unsigned archive + cloud-signed export.
Fallback: sign at archive time.** The first real upload (quickstart V3) decides;
the plan's first iOS task is that spike. Known caveat of the primary path: an
unsigned archive carries no entitlements — harmless today (Runner has none),
to be revisited if a brand ever adds push or app groups.

**Declarations (FR-022)**:

- `Info.plist`: add `ITSAppUsesNonExemptEncryption = false` — the app only
  uses HTTPS and the Keychain, both exempt
  (developer.apple.com/documentation/security/complying-with-encryption-export-regulations).
- Privacy manifests: the Flutter engine, `shared_preferences_foundation`,
  `flutter_secure_storage_darwin` and `file_picker` ship their own;
  `path_provider_foundation` is FFI-only; `printing` uses no required-reason
  API. **No Runner `PrivacyInfo.xcprivacy` now**; add one only if App Store
  Connect returns ITMS-91053.
- **Deployment target must be ≥ 15.0** (corrected during implementation: Xcode 27
  rejects 13.0 with "supported deployment target versions is 15.0 to 27.0"; the
  earlier "keep 13.0" was wrong). Uploads since 2026-04-28 must be built with
  Xcode 26+ / iOS 26 SDK; Xcode 27 qualifies
  (developer.apple.com/news/upcoming-requirements/).

**Alternatives considered**: fastlane (installed locally, but adds a Ruby
toolchain to every future CI image for no capability we need);
`xcrun altool --upload-package` (still shipped, `--upload-app` deprecated;
kept as a fallback uploader); Transporter (separate app).

---

## R4. Android: upload-key signing from the environment; build only

**Decision**: `android/app/build.gradle.kts` gains a `release` signingConfig
reading `MBE_ANDROID_KEYSTORE_PATH`, `MBE_ANDROID_KEYSTORE_PASSWORD`,
`MBE_ANDROID_KEY_ALIAS`, `MBE_ANDROID_KEY_PASSWORD`. When a release task is in
the task graph and any is missing, Gradle throws naming the missing variables;
the `signingConfigs.getByName("debug")` fallback is removed (FR-023). Debug
builds (`flutter run`) are unaffected. The script runs `flutter build
appbundle` (→ `build/app/outputs/bundle/release/app-release.aab`) and
`flutter build apk` (→ `build/app/outputs/flutter-apk/app-release.apk`), then
verifies both with `apksigner verify --print-certs` / `jarsigner -verify`
against the expected upload-key fingerprint. Nothing is uploaded (spec 3a).

Upload key generation (one-time, documented):
`keytool -genkeypair -v -keystore upload-keystore.jks -storetype PKCS12
-keyalg RSA -keysize 2048 -validity 10000 -alias upload`, kept outside the
repo. Play App Signing is assumed when publishing is added later.

**Target SDK (FR-025)**: Play requires targetSdk 36 for new apps/updates from
2026-08-31 (developer.android.com/google/play/requirements/target-sdk).
Flutter 3.44.2's `FlutterExtension` defaults to target/compile SDK 36, minSdk
24; `build.gradle.kts` already uses `flutter.targetSdkVersion`, so it
complies. The preflight asserts the built bundle's targetSdk ≥ 36.

**Alternatives considered**: a `key.properties` file at a path from an env var
(equivalent; four env vars are simpler for CI secret stores).

---

## R5. Web: WebAssembly ships; single-threaded; no third-party CDN

**Decision**: `flutter build web --release --wasm --no-web-resources-cdn
--dart-define-from-file=deploy/<deployment>.env --build-name … --build-number …`.

- **[verified]** `flutter build web --wasm --release` succeeds in ~41 s with no
  incompatibility warnings; no `dart:html`/`package:js`/`dart:js_util` in
  `lib/`; dio, go_router, flutter_secure_storage, shared_preferences,
  file_picker 8, printing 5.15 + pdf, data_table_2 and the generated OpenAPI
  client all compile. Output carries `main.dart.wasm`/`.mjs` (skwasm) and
  `main.dart.js` (canvaskit); the bootstrap picks wasm when
  `supportsWasmGC && webGLVersion > 0`, else JS — the automatic fallback.
- **Browser reality**: per docs.flutter.dev/platform-integration/web/wasm,
  Firefox, Safari and all iOS browsers currently get the JS build; only
  Chromium browsers run wasm. Spec US1 scenario 2's "loads using the
  WebAssembly build" is verified in Chrome/Edge; scenario 3 covers the rest.
- **`--no-web-resources-cdn`**: by default the loader fetches
  CanvasKit/skwasm from `www.gstatic.com`. Serving them from the site keeps the
  app on one origin, consistent with spec 044 FR-014's no-third-party-CDN rule
  for the preview. Cost: larger bundle (~53 MB, 37 MB of it `canvaskit/`).
- **Not yet verified at runtime**: PDF preview (pdf.js under
  `web/pdfjs/`) and file picker under wasm → quickstart V2 smoke test. If
  either fails, FR-026 applies: ship JS-only (drop `--wasm`) and record it.

**Threads**: App Platform static sites cannot set custom response headers
(app spec `static_sites` has only deprecated `cors`/`routes` —
docs.digitalocean.com/products/app-platform/reference/app-spec/), so no
COOP/COEP. **[verified]** The 3.44 bootstrap sets `skwasmSingleThreaded` when
`!crossOriginIsolated`, so the app runs single-threaded wasm. Accepted per the
locked decision. Side benefit: no COEP, so cross-origin product photos from
the API are unaffected.

---

## R6. Web hosting: prebuilt bundle pushed to a deploy repo, deployed with doctl

> **Superseded 2026-10-02**: web hosting is out of scope; the script stops at
> `build/web/` and the operator copies it to a server (rsync today).

**Decision**: App Platform static sites build only from a git source (no
direct upload, no container image for static sites —
docs.digitalocean.com/products/app-platform/how-to/deploy-from-container-images/).
So the script:

1. builds locally (the bundle that was verified is the bundle that ships);
2. force-pushes `build/web/` as a single commit (message: source commit,
   version, build number) to branch `web/<deployment>` of a **separate private
   deploy repository** (`WEB_DEPLOY_REPO` in the deployment file; proposed
   `github.com/mictlanix/mbe-ui-web-deploy`);
3. `doctl apps create --spec deploy/<deployment>.app.yaml --upsert --wait`
   (creates on first run, updates the spec afterwards), resolves the app id
   by name, then `doctl apps create-deployment <id> --wait`;
4. prints the URL from `doctl apps get <id> --format DefaultIngress`.

App spec per deployment (in repo, FR-029):

```yaml
name: mbe-web-demo
static_sites:
  - name: web
    github: { repo: mictlanix/mbe-ui-web-deploy, branch: web/demo, deploy_on_push: false }
    output_dir: /
    index_document: index.html
    catchall_document: index.html   # every go_router path reloads (FR-027)
```

`catchall_document`, not `error_document` (which would answer deep links with
HTTP 404) — docs.digitalocean.com/products/app-platform/how-to/manage-static-sites/.

**Why a separate private repo**: mbe-ui is MIT-licensed and public; a
branded customer's bundle (and its `deploy/<name>.env`, which deploy/README.md
allows to stay private) must not be published through an orphan branch here.
It also keeps hundreds of MB of build commits out of this repo's history.

**One-time manual steps** (documented, FR-030): create the deploy repo; grant
the DigitalOcean GitHub app access to it; optional custom domain.

**Alternatives considered**: building on App Platform via Dockerfile with a
Flutter image (multi-GB image, slow, cannot see uncommitted env files, ships a
different bundle than the one verified); Spaces + CDN (only option allowing
COOP/COEP and per-file Cache-Control, but departs from the locked host).

---

## R7. Web caching: App Platform defaults suffice

> **Superseded 2026-10-02** with R6: caching is the web server's concern.

**Decision**: add nothing. Static sites always get `Cache-Control:
public,max-age=10,s-maxage=86400`, and each deployment purges the CDN edge
cache (docs.digitalocean.com/products/app-platform/how-to/cache-content). A
returning visitor gets the new release on their next load (≤10 s after
deploy) — FR-028 / SC-007. Flutter 3.44 emits no content-hashed filenames, so a
short max-age is what we want; unchanged assets revalidate (304) rather than
staying immutably cached. **[verified]** Since 3.41 `flutter_service_worker.js`
is a 784-byte self-unregistering stub — no stale offline cache.

Post-deploy check (quickstart V2): `curl -I` confirms ETag/304 revalidation
and `application/wasm` for `.wasm`.

---

## R8. Versioning and tagging

**Decision**:

- **Version name**: the `x.y.z` part of `pubspec.yaml`'s `version:`; the
  `+n` part is ignored. Same for all platforms (FR-015).
- **Build number**: minutes since `2026-01-01T00:00Z`, UTC, computed by the
  script and passed as `--build-number` to every platform. Monotonic across
  machines with no network; re-releasing the same commit still gets a new
  number; ~525,600/year, far under Android's 2,100,000,000 cap (FR-016).
- **Tag** (FR-017): on a successful publish, an annotated tag
  `<deployment>/<platform>/v<version>-<build>` (e.g.
  `demo/ios/v1.0.0-39390270`) on the released commit; pushed only with
  `--push-tag`. Build-only runs are not tagged.

**Alternatives considered**: git commit count (same number for a re-release;
can go backwards across branches/shallow clones); querying App Store Connect
for the latest build (JWT signing in shell; no Android equivalent).

**Risks**: two releases of the same deployment and platform in the same
minute, or a badly skewed clock — Apple rejects the duplicate loudly; on
Android it would surface at the future Play upload. Accepted.

---

## R9. Script language and layout

**Decision**: Bash (`set -euo pipefail`), matching `tool/generate_api_client.sh`.
One entry point `tool/release.sh` dispatching to `tool/release/{web,ios,android}.sh`
with shared `tool/release/lib.sh` (preflight, versioning, brand staging,
cleanup trap, secret-safe logging). ShellCheck-clean (`brew install
shellcheck`; not installed today). Tools the scripts require and check for
but do not install: flutter, xcodebuild, git, doctl (not installed today),
keytool/apksigner.

**Alternatives considered**: a Dart CLI under `tool/` (testable, but slower
to iterate for what is mostly orchestration of external commands; revisit if
the bash grows past ~600 lines); fastlane (R3).

---

## R10. External dependencies (blocking the first *release*, not the build)

1. **`test.api.mbe.mictlanix.com` does not resolve** (DNS lookup 2026-10-02
   returned nothing; `mbe.mictlanix.com` resolves to 38.34.183.153). The
   white-label demo cannot pass SC-001 until the test API is live. Owned
   outside mbe-ui.
2. **CORS**: the test API must allow the web demo's origin (initially
   `https://mbe-web-demo-<hash>.ondigitalocean.app`, or the custom domain).
   If it does not, file an mbe-api/infrastructure issue (constitution §III);
   never work around it in the client.
3. **App Store Connect API key with Admin role**, the App Store Connect app
   record for `com.mictlanix.mbe`, and confirmation that team `4ZJ2FWD2BR`
   owns the registered App ID.
4. **Deploy repo + DigitalOcean GitHub app access** (R6).
