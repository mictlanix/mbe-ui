# Data Model: Deployment Scripts (045)

No runtime data. The "entities" are files in the repository (and, for
credentials, in the environment). Paths are repo-relative.

## Brand

A customer identity. Directory `deploy/brands/<brand>/`.

| Item | Path | Required | Notes |
|---|---|---|---|
| Identity | `brand.properties` | yes, every brand | `KEY=VALUE`, see fields below |
| Source artwork | `src/app_icon_1024.png`, `src/android_adaptive_foreground_1024.png`, `src/splash_1024.png` | non-default brands | inputs to `tool/release/brand_artwork.sh` |
| Overlay | `overlay/<repo path>` | non-default brands | generated once from `src/`, committed; staged over the tree at build time (research R2) |

`brand.properties` fields:

| Key | Example (`mbe`) | Validation |
|---|---|---|
| `BUNDLE_ID` | `com.mictlanix.mbe` | reverse-DNS, `[A-Za-z0-9.-]` only (no `_`, iOS rule) |
| `APPLICATION_ID` | `com.mictlanix.mbe` | reverse-DNS, `[a-z0-9_.]`, each segment starts with a letter |
| `DISPLAY_NAME` | `Mictlanix Business Essentials` | non-empty; home-screen/launcher name |
| `IOS_TEAM_ID` | `4ZJ2FWD2BR` | 10 uppercase alphanumerics |
| `WEB_TITLE` | `Mictlanix Business Essentials` | non-empty; `<title>` and `apple-mobile-web-app-title` |
| `WEB_THEME_COLOR` | `#14120F` | `#RRGGBB`; manifest `theme_color` |

**Default brand**: `mbe` (white-label). It has `brand.properties` only — the
artwork committed in `ios/`, `android/` and `web/` *is* its artwork, so it has
no `src/` or `overlay/` (research R2). Its values equal the defaults written
into `ios/Flutter/{Debug,Release}.xcconfig` and `android/app/build.gradle.kts`.

**Required overlay manifest** (non-default brands; validated before any build,
FR-013): `tool/release/overlay-manifest.txt` lists every path a brand overlay
must contain — iOS `Runner/Assets.xcassets/AppIcon.appiconset/*`,
`LaunchImage.imageset/*`, `LaunchBackground.imageset/*`; Android
`res/mipmap-*/ic_launcher*.png`, `res/drawable*/launch_background.xml` and
splash PNGs, `res/values*-v31/styles.xml`; web `favicon.png`, `icons/*`,
`manifest.json`. A missing path fails the build naming it.

## Deployment

A brand released against an environment. Two files per deployment, plus a
web hosting spec.

| Item | Path | Committed | Notes |
|---|---|---|---|
| App settings | `deploy/<deployment>.env` | deployment's choice (deploy/README.md) | existing mechanism; passed as `--dart-define-from-file`; `API_BASE_URL` required for a release and MUST be `https://` (FR-010) |
| Release settings | `deploy/<deployment>.release` | yes | `KEY=VALUE`, see below; never passed to the app |
| Web hosting spec | `deploy/<deployment>.app.yaml` | yes | DigitalOcean App Platform app spec (research R6), FR-029 |

`deploy/<deployment>.release` fields:

| Key | Example (`demo`) | Validation |
|---|---|---|
| `BRAND` | `mbe` | must name an existing `deploy/brands/<brand>/` |
| `WEB_DEPLOY_REPO` | `git@github.com:mictlanix/mbe-ui-web-deploy.git` | required for web publish |
| `WEB_DEPLOY_BRANCH` | `web/demo` | default `web/<deployment>` |

**First deployment**: `demo` = brand `mbe` + `API_BASE_URL=https://test.api.mbe.mictlanix.com`.

Deployment names: `[a-z0-9-]+`. Unknown name → fail listing valid names
(those with both `.env` and `.release`).

## Release

One run of one platform for one deployment. Not persisted as a file; its
record is the output summary plus (on publish) a git tag.

| Field | Source |
|---|---|
| deployment, platform | command arguments |
| version name | `pubspec.yaml` `version:` before `+` (FR-015) |
| build number | minutes since 2026-01-01T00:00Z UTC (research R8, FR-016) |
| commit | `git rev-parse HEAD` (+ `-dirty` marker if `--allow-dirty` used) |
| artifact | web: `build/web/`; iOS: `build/ios/archive/Runner.xcarchive`; Android: `.aab` + `.apk` |
| destination | web URL / App Store Connect / local path |
| tag | `<deployment>/<platform>/v<version>-<build>` on successful publish (FR-017) |

State per run: `preflight → build → (publish) → tag → summary`; any failure
stops the run, restores the tree, and exits non-zero. In `all` mode each
platform runs this sequence independently (FR-002).

## Generated, gitignored build files

| Path | Written by | Removed |
|---|---|---|
| `ios/Flutter/Brand.xcconfig` | release script, from `brand.properties` | on exit (trap), and rewritten/removed at every start |
| `android/brand.properties` | release script, from `brand.properties` | same |

Absent ⇒ white-label defaults, so `flutter run` is always white-label.

## Credential

Never in the repository; supplied by the environment (FR-018/019). Full list
and validation in [contracts/environment.md](contracts/environment.md).
