# Quickstart / Validation: Deployment Scripts (045)

Runnable checks that prove the feature end to end. Command and option details:
[contracts/release-cli.md](contracts/release-cli.md); credentials:
[contracts/environment.md](contracts/environment.md); files:
[data-model.md](data-model.md).

## Prerequisites

- Release Mac with Flutter 3.44.x, Xcode 26+ (27 today), Android SDK, `doctl`,
  `shellcheck` (`brew install doctl shellcheck`).
- One-time setup done per `deploy/RELEASING.md` (written by this feature):
  App Store Connect API key (Admin) + app record for `com.mictlanix.mbe`;
  Android upload keystore; deploy repo + DigitalOcean GitHub app access.
- External: `test.api.mbe.mictlanix.com` live and allowing the web demo's
  origin (research R10). V1/V4/V6 do not need it; V2/V3/V5 sign-in steps do.

## V1 — Preflight fails fast and names everything (SC-003, FR-004/005/006/010)

```bash
tool/release.sh ios nosuch                       # exit 3, lists valid deployments
env -u MBE_ASC_KEY_ID tool/release.sh ios demo   # exit 3, names MBE_ASC_KEY_ID
touch scratch.txt && tool/release.sh web demo --build-only   # exit 3, dirty tree
rm scratch.txt
# a throwaway deployment whose .env has API_BASE_URL=http://… → exit 3
tool/release.sh web demo </dev/null              # never blocks on input
```

Each failure appears in under 30 s, before any `flutter build` output.

## V2 — Web demo (US1, SC-007, SC-008, FR-026–029)

```bash
tool/release.sh web demo
```

Expect: summary with version, build number, commit and the public URL; tag
`demo/web/v<version>-<build>` exists locally.

Then:

1. Chrome, fresh profile: open the URL → app loads; DevTools shows
   `main.dart.wasm` fetched; no request to `gstatic.com`.
2. Safari or Firefox: app loads (JS build).
3. Sign in against the test API; open a sales order, open its PDF preview,
   attach a file via the file picker (wasm runtime smoke test, research R5).
4. Navigate to a deep route, reload → same screen (no host 404).
5. `curl -sI <url>/main.dart.wasm` → `content-type: application/wasm`;
   repeat with `If-None-Match` → `304`.
6. Release again; in the open tab reload once → new build number visible
   (e.g. in the about/settings screen or `version.json`).
7. Cold load to sign-in screen in < 5 s on broadband (DevTools, cache disabled).

If step 3 fails under wasm: rebuild without `--wasm`, record the
incompatibility (FR-026).

## V3 — iOS TestFlight (US2, FR-021/022)

```bash
tool/release.sh ios demo
```

Expect: unsigned archive → cloud-signed export → upload; summary reports
version/build. In App Store Connect → TestFlight, the build finishes
processing **without** an export-compliance prompt; install on a device via
TestFlight; home-screen name "Mictlanix Business Essentials"; sign in against
the test API. Run again → higher build number, accepted.

This is also the research R3 spike: if export fails on the unsigned archive,
switch to the sign-at-archive fallback and record it.

## V4 — Android bundle (US3, FR-023/024/025)

```bash
tool/release.sh android demo
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

Expect: `.aab` and `.apk` paths reported; certificate fingerprint equals the
upload key's; application id `com.mictlanix.mbe`; targetSdk ≥ 36. Side-load the
APK, sign in against the test API. Then:

```bash
env -u MBE_ANDROID_KEYSTORE_PATH flutter build appbundle   # fails naming the variable
flutter run -d <android device>                            # debug still works
```

Nothing appears in Google Play.

## V5 — All platforms in one command (SC-002, FR-002)

```bash
tool/release.sh all demo
```

Expect three summary rows. With `MBE_ASC_KEY_ID` unset: the iOS row fails,
web and Android rows still succeed, exit code non-zero.

## V6 — Add a throwaway brand (US4, SC-006, FR-011–013)

Following `deploy/RELEASING.md` § "Adding a brand", create brand `zz-test`
(id `com.mictlanix.zztest`, distinct name/icon/seed color) and deployment
`zz-test`; run `tool/release/brand_artwork.sh zz-test`, then:

```bash
tool/release.sh all zz-test --build-only
git status --porcelain       # empty: tree restored
tool/release.sh --status     # white-label
```

Expect: each artifact shows the test brand's id, name, icon, splash and
colors; installing the zz-test APK next to the demo APK gives two apps.
Delete one overlay file → build fails naming it. Rebuild `demo` → white-label
unchanged. Remove the throwaway brand afterwards. No file outside `deploy/`
changed (`git diff --stat` before removal).

## V7 — No secrets anywhere (SC-005, FR-018/019)

```bash
tool/release.sh all demo 2>&1 | tee /tmp/release.log
grep -F "$MBE_ANDROID_KEYSTORE_PASSWORD" /tmp/release.log   # no match
grep -F "$DIGITALOCEAN_ACCESS_TOKEN" /tmp/release.log       # no match
git ls-files | grep -E '\.(jks|keystore|p8)$'               # no match
shellcheck tool/release.sh tool/release/*.sh                # clean
```
