# Releasing

`tool/release.sh` builds a **deployment** (a brand + its app settings) and
publishes it. One command per platform, or all three:

```bash
tool/release.sh web     demo     # WebAssembly build -> DigitalOcean App Platform
tool/release.sh ios     demo     # unsigned archive -> cloud-signed upload -> TestFlight
tool/release.sh android demo     # signed .aab + .apk, NOT published
tool/release.sh all     demo     # all three; one platform failing never hides the others

tool/release.sh ios demo --build-only    # build, never upload/publish/tag
tool/release.sh web demo --allow-dirty   # release from an uncommitted tree (stated in output)
tool/release.sh web demo --push-tag      # also push the release tag to origin
tool/release.sh --list                   # valid deployments
tool/release.sh --status                 # which brand the tree is configured for
```

Every run starts with a preflight that lists *all* problems (missing
credential, unknown deployment, dirty tree, non-HTTPS API URL, missing brand
artwork) and exits `3` before building anything. Exit codes: `0` ok, `1` build
or publish failed, `2` usage, `3` preflight failed. Commands never prompt and
never print a secret.

Version name comes from `pubspec.yaml` (`1.0.0` of `1.0.0+1`; the `+n` is
ignored). The build number is minutes since 2026-01-01 UTC, so it only ever
goes up. A successful web/iOS publish is tagged `<deployment>/<platform>/v<version>-<build>`.

## Files

| File | Purpose |
|---|---|
| `deploy/<deployment>.env` | app settings (`API_BASE_URL`, locale, formatting, brand tokens) passed with `--dart-define-from-file`; see `deploy/README.md` |
| `deploy/<deployment>.release` | release settings: `BRAND`, `WEB_DEPLOY_REPO`, `WEB_DEPLOY_BRANCH` |
| `deploy/<deployment>.app.yaml` | DigitalOcean App Platform spec for the deployment's web site |
| `deploy/brands/<brand>/brand.properties` | native identity: bundle/application id, display name, iOS team, web title/short name/theme color |
| `deploy/brands/<brand>/overlay/` | the brand's icons and splash (non-default brands only) |

The white-label brand is `mbe` and the first deployment is `demo`
(`API_BASE_URL=https://test.api.mbe.mictlanix.com`). The API URL must be
`https://` for a release.

## Credentials

Never committed, never in `.env`. Keep them outside the repo and export them
before releasing, for example from `~/.config/mbe/release.env` (mode 600) that
you `source`:

```bash
# iOS (TestFlight)
export MBE_ASC_KEY_ID=...        # App Store Connect API key id
export MBE_ASC_ISSUER_ID=...     # issuer id (UUID)
export MBE_ASC_KEY_PATH=~/.private_keys/AuthKey_<KEYID>.p8

# Android upload key
export MBE_ANDROID_KEYSTORE_PATH=~/.config/mbe/upload-keystore.jks
export MBE_ANDROID_KEYSTORE_PASSWORD=...
export MBE_ANDROID_KEY_ALIAS=upload
export MBE_ANDROID_KEY_PASSWORD=...

# Web (DigitalOcean)
export DIGITALOCEAN_ACCESS_TOKEN=...
```

Key and keystore files must live **outside** the repository; the preflight
rejects a path inside it.

## One-time setup

**iOS**
1. Register the App ID `com.mictlanix.mbe` and create the App Store Connect app
   record (done for the white-label app).
2. Users and Access → Integrations → App Store Connect API → Team Keys →
   generate a key with the **Admin** role (cloud-managed distribution signing
   needs it). Download the `.p8` once; keep it in `~/.private_keys/` mode 600.
3. Xcode 26 or newer. No distribution certificate has to be in the keychain.

**Android** (build only; Google Play publishing is not part of this release)
1. Generate the upload key, once, outside the repo:
   `keytool -genkeypair -v -keystore ~/.config/mbe/upload-keystore.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Back the keystore and its passwords up somewhere safe (a password manager).
3. Release builds fail without the four `MBE_ANDROID_*` variables; they are
   never signed with the debug key.

**Web**
1. `brew install doctl`; create a DigitalOcean API token.
2. Create a **private** GitHub repository for the built sites,
   `mictlanix/mbe-ui-web-deploy` (a public mbe-ui must not host a customer's
   build). The script force-pushes each deployment's bundle to its own branch
   (`web/<deployment>`).
3. Grant the DigitalOcean GitHub app access to that repository
   (DigitalOcean → Apps → Create → GitHub → Configure).
4. First `tool/release.sh web <deployment>` creates the App Platform app from
   `deploy/<deployment>.app.yaml`; later runs update and redeploy it.
5. Optional: add a custom domain to the app spec.
6. The API must allow the web origin for cross-origin requests (CORS). If it
   does not, file an mbe-api issue; do not work around it in the client.

## What the web build does

`flutter build web --wasm --no-web-resources-cdn`: WebAssembly where the
browser supports it (Chromium browsers today), the JavaScript build otherwise,
chosen by the loader. Everything is served from the site's own origin. App
Platform cannot send the cross-origin-isolation headers, so WebAssembly runs
single-threaded. If a dependency ever breaks under WebAssembly, drop `--wasm`
in `tool/release/web.sh` and note it in `specs/045-deploy-scripts/research.md`.

## Adding a brand

Adding a customer touches only `deploy/` (plus a one-time artwork generation):

1. Create `deploy/brands/<brand>/brand.properties` (copy `mbe`'s; every field
   is required and validated).
2. Add the source artwork in `deploy/brands/<brand>/src/`:
   `app_icon_1024.png`, `android_adaptive_foreground_1024.png`,
   `splash_1024.png`.
3. Run `tool/release/brand_artwork.sh <brand>` and commit the generated
   `deploy/brands/<brand>/overlay/`. It runs the icon and splash generators in
   a temporary worktree, so your working tree is never touched.
4. Create `deploy/<deployment>.env`, `.release` (`BRAND=<brand>`) and
   `.app.yaml` (a new app name and branch).
5. Register the new bundle id with Apple and create its App Store Connect
   record.
6. `tool/release.sh all <deployment> --build-only` and check each artifact's
   name, id and icon; installing two brands side by side gives two apps.

During a build the overlay is copied over the tree and restored afterwards
(including on failure). A brand missing any artwork listed in
`tool/release/overlay-manifest.txt` fails the preflight by name; it never
falls back to white-label artwork.

## Troubleshooting

- *Preflight: uncommitted changes* — commit, or pass `--allow-dirty`.
- *A killed run left brand files behind* — `tool/release.sh --status` shows
  generated files; the next run clears them. Overlay files left by a killed run
  show up in `git status`: `git checkout -- . && git clean -fd deploy/ ios android web`
  only after checking they are overlay files.
- *iOS export fails on the unsigned archive* — switch `tool/release/ios.sh` to
  sign at archive time (see `specs/045-deploy-scripts/research.md` R3).
