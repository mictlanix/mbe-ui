# Feature Specification: Deployment Scripts

**Feature Branch**: `045-deploy-scripts`

**Created**: 2026-10-02

**Status**: Draft

**Input**: User description: "Deployment scripts for mbe-ui targeting iOS, Android and web, built to each platform's deployment best practices, with per-customer branding designed in but the first release being the white-label (unbranded "Mictlanix Business Essentials") app shown to prospective customers. API published at test.api.mbe.mictlanix.com but configurable."

## Context & Locked Decisions

These were decided with the user before this spec was written and are not open
for re-litigation in clarify/plan:

1. **Local first, CI-ready.** Scripts run on the developer's Mac. Every secret
   and credential comes from the environment or from files outside the
   repository, so a CI runner can later invoke the very same scripts
   unattended. Writing the CI workflows themselves is out of scope.
2. **Web hosting** is DigitalOcean App Platform, as a static site. The
   WebAssembly build is preferred for performance, with automatic fallback to
   the JavaScript build for browsers that cannot run it.
3. **iOS delivery stops at TestFlight.** Promoting a build to production
   remains a manual action in App Store Connect.
3a. **Android is built, not shipped** (decided 2026-10-02). The Android
   script produces a signed, store-ready bundle, but nothing is uploaded to
   Google Play in this feature; publishing to Play (internal testing or
   otherwise) is out of scope and can be added later without changing the
   build.
4. **Each branded customer gets its own store app** (own bundle identifier,
   name, icon, splash and store listing) built from this one codebase. The
   white-label app is simply the default brand, not a special case.

What already exists and is reused, not rebuilt:

- Per-deployment app settings (`deploy/<customer>.env`, consumed at build
  time; see `deploy/README.md` and `.env.template`), including the API
  endpoint and the in-app brand tokens (display name, seed color, logo and
  welcome assets).
- The white-label native identity `com.mictlanix.mbe`, already set in the
  iOS/macOS projects and as the Android application id, and already
  registered as an App ID with Apple.

## User Scenarios & Testing *(mandatory)*

Actors:

- **Release operator** — a Mictlanix developer who runs a release.
- **Prospective customer** — someone shown the white-label demo on the web,
  or on an iPhone/iPad via TestFlight.
- **Brand onboarder** — a Mictlanix developer setting up a new branded
  customer.
- **CI runner** — a future unattended machine running the same scripts.

### User Story 1 - Publish the white-label web demo (Priority: P1)

The release operator runs one command naming the white-label deployment. The
app is built for the web, uploaded to the hosting provider, and becomes
reachable at the deployment's public URL, talking to
`https://test.api.mbe.mictlanix.com`. The operator sends the URL to a
prospective customer, who opens it in a browser and signs in.

**Why this priority**: The web demo is the cheapest artifact to show a
customer: no store review, no device enrollment, no app install. It is the
first thing sales will use.

**Independent Test**: Run the web deploy for the white-label deployment from a
clean checkout; open the published URL in a fresh browser profile; sign in
against the test API; navigate to a deep link and reload it.

**Acceptance Scenarios**:

1. **Given** a clean checkout and the hosting credentials in the environment,
   **When** the operator runs the web deploy for the white-label deployment,
   **Then** the site is published and the command reports the public URL.
2. **Given** the published site, **When** a visitor opens it in a current
   browser, **Then** the app loads using the WebAssembly build, shows the
   white-label branding, and signs in against the test API.
3. **Given** a browser that cannot run the WebAssembly build, **When** the
   visitor opens the site, **Then** the app still loads (JavaScript build)
   with no visitor action.
4. **Given** the visitor is on any in-app route, **When** they reload the page
   or open that URL directly, **Then** the same screen loads (no "not found"
   page from the host).
5. **Given** a visitor who used a previous release, **When** a new release is
   published and they load the site again, **Then** they receive the new
   release without clearing their cache manually.

---

### User Story 2 - Ship the white-label iOS beta to TestFlight (Priority: P1)

The release operator runs one command for iOS. The app is built in release
mode with the white-label identity and configuration, signed for App Store
distribution, and uploaded to App Store Connect, where it appears under
TestFlight once Apple finishes processing it. Prospective customers invited as
testers install it from the TestFlight app.

**Why this priority**: iPads and iPhones are the expected demo devices for
in-person customer meetings; the App ID is already registered, so this is the
next-shortest path to a native demo.

**Independent Test**: Run the iOS release for the white-label deployment;
confirm the build appears in App Store Connect's TestFlight tab with the
expected version and build number; install it on a device and sign in
against the test API.

**Acceptance Scenarios**:

1. **Given** signing credentials and an App Store Connect API key in the
   environment, **When** the operator runs the iOS release, **Then** a signed
   build is uploaded and the command reports its version and build number.
2. **Given** an uploaded build, **When** Apple finishes processing it, **Then**
   it is ready for internal testers without a manual export-compliance
   answer in the console.
3. **Given** a build number was already uploaded, **When** the operator runs
   another release, **Then** the new build carries a higher build number and
   is accepted.

---

### User Story 3 - Build a store-ready white-label Android bundle (Priority: P2)

The release operator runs one command for Android. The app is built as a
store bundle with the white-label identity and configuration and signed with
the project's upload key (not a debug key). The bundle is left on disk; it is
not uploaded to Google Play. The same script can also produce an installable
package the operator side-loads onto a test device.

**Why this priority**: Android is not being published yet, but having a
working, correctly signed build now means publishing later is only a
Play Console setup and an upload step, not a build rework.

**Independent Test**: Run the Android build for the white-label deployment;
confirm the bundle is signed with the upload key and carries the expected
application id, version and build number; side-load the installable package
on a test device and sign in against the test API.

**Acceptance Scenarios**:

1. **Given** the upload key in the environment, **When** the operator runs the
   Android build, **Then** a bundle signed with the upload key is produced and
   the command reports its path, version and build number.
2. **Given** the upload key is missing from the environment, **When** the
   operator runs a release build, **Then** the build stops with a message
   naming what is missing, rather than silently signing with a debug key.
3. **Given** a previous build, **When** the operator builds again, **Then**
   the new bundle's version code is higher.

---

### User Story 4 - Onboard a branded customer as its own app (Priority: P3)

The brand onboarder adds a new brand: a native identity (bundle identifier /
application id, store display name), launcher icon and splash artwork, web
title/favicon/manifest, and an app-settings file with the customer's API
endpoint and in-app brand tokens. They then run the same release commands
naming that brand, and get a separate web site, a separate TestFlight app and
a separate Android bundle — with no change to shared application code.

**Why this priority**: Required for the business model, but no branded
customer exists yet; the first release ships only the white-label brand. The
structure must be in place from day one so the white-label app is "just the
default brand" and adding brand #2 is additive.

**Independent Test**: Create a throwaway test brand with a distinct
identifier, name, icon and seed color; build all three platforms for it
locally (no upload); verify each artifact shows that brand's name, icon and
identity, and that the white-label builds are unchanged.

**Acceptance Scenarios**:

1. **Given** a new brand's files are added, **When** the operator builds any
   platform naming that brand, **Then** the artifact carries that brand's
   identifier, display name, icon, splash and in-app branding.
2. **Given** two brands, **When** both are installed on the same device,
   **Then** they appear as two separate apps that do not share data.
3. **Given** a brand is added, **When** the white-label app is built again,
   **Then** it is byte-for-byte unaffected in identity and branding.
4. **Given** a brand is missing a required item (e.g. its icon), **When** the
   operator builds it, **Then** the build stops naming the missing item,
   rather than silently shipping white-label artwork under the brand's name.

---

### User Story 5 - Run unattended in a future CI (Priority: P3)

A CI runner invokes the same commands with credentials supplied as environment
variables and no interactive terminal. Every step that would prompt a human
either takes its answer from configuration or fails with a clear message.

**Why this priority**: CI itself is out of scope, but retrofitting
non-interactivity later is costly; it is cheap to require now.

**Independent Test**: Run each release command with standard input closed and
all credentials provided only through environment variables; confirm it
completes (or fails with a named reason) without waiting for input.

**Acceptance Scenarios**:

1. **Given** all credentials in environment variables and no terminal,
   **When** a release command runs, **Then** it never blocks on a prompt.
2. **Given** a release command's output is captured to a log, **When** the log
   is inspected, **Then** it contains no secret values.

---

### Edge Cases

- **Uncommitted changes** at release time: the release refuses to proceed by
  default, so every published build traces to a commit; an explicit override
  exists for emergencies and is recorded in the release output.
- **Unknown deployment/brand name**: fails immediately, listing the valid
  names.
- **API endpoint not HTTPS** for a release (as opposed to local dev) build:
  fails before building.
- **Web origin not allowed by the API** (cross-origin policy): the deploy
  cannot fix this itself; the published site would fail to sign in. The
  release documentation lists it as a prerequisite, and verification of a
  first deployment includes a sign-in.
- **Store processing delays/rejections** after upload (Apple processing):
  out of the script's control; the script's
  success means "upload accepted", and its output says so.
- **Concurrent releases** of the same brand/platform (two operators, or later
  operator + CI): build numbers must still not collide.
- **Expired or revoked credentials** (signing certificate, API key, service
  account, hosting token): fails with a message identifying which credential,
  not a raw tool error alone.
- **A dependency that cannot run under WebAssembly** (the PDF preview added in
  spec 044 is the first suspect): either it works in the WebAssembly build or
  the web release falls back to the JavaScript build for everyone — the
  operator is never left with a site where document preview silently breaks.

## Requirements *(mandatory)*

### Functional Requirements

**Release commands**

- **FR-001**: The project MUST provide a release command per platform (web,
  iOS, Android), each taking the deployment (brand + environment) to release
  as an argument.
- **FR-002**: The project MUST provide a way to run all three platforms
  (web and iOS published, Android built) for one deployment in a single
  invocation, reporting each platform's
  outcome separately; one platform's failure MUST NOT hide another's result.
- **FR-003**: Every release command MUST support a build-only mode that
  produces the signed artifact (web bundle, iOS archive, Android bundle)
  without uploading or publishing anything.
- **FR-004**: Every release command MUST validate its inputs before starting
  a build — deployment exists, its settings file and brand assets are
  present, required credentials are present — and fail fast naming every
  missing item.
- **FR-005**: Every release command MUST be runnable non-interactively, never
  prompting for input; anything a tool would prompt for MUST come from
  configuration or the environment.
- **FR-006**: By default a release MUST refuse to run with uncommitted changes
  in the working tree; an explicit override flag MUST exist, and its use MUST
  be stated in the release output.
- **FR-007**: A successful upload/publish MUST report what was released:
  deployment, platform, version name, build number, commit, and (for web) the
  public URL.

**Configuration and branding**

- **FR-008**: Each deployment MUST be defined by files in the repository
  (reusing the existing `deploy/<name>.env` app-settings mechanism) plus that
  brand's native identity and artwork; the white-label deployment MUST be
  defined the same way as any customer brand.
- **FR-009**: The API endpoint MUST be configurable per deployment and MUST
  NOT be hardcoded in the scripts. The white-label demo deployment MUST point
  at `https://test.api.mbe.mictlanix.com`.
- **FR-010**: A release build MUST require an HTTPS API endpoint.
- **FR-011**: Per brand, the following MUST be selectable at build time
  without editing shared application code: iOS bundle identifier, Android
  application id, home-screen/launcher display name, launcher icon, splash
  screen, web page title, favicon and web app manifest (name, icons, theme
  color), plus the existing in-app brand tokens.
- **FR-012**: Builds of different brands MUST install side by side on one
  device as independent apps.
- **FR-013**: A brand missing a required identity or artwork item MUST fail
  the build naming the item; it MUST NOT fall back to white-label artwork.
- **FR-014**: The white-label deployment MUST use bundle identifier /
  application id `com.mictlanix.mbe` and display name "Mictlanix Business
  Essentials".

**Versioning**

- **FR-015**: The version name MUST come from a single source in the
  repository and MUST be identical across platforms for the same release.
- **FR-016**: Build numbers MUST increase monotonically per brand and
  platform, so that no upload is ever rejected as a duplicate, including when
  releases run from different machines.
- **FR-017**: Each released commit MUST be identifiable afterwards from its
  version and build number (e.g. through a tag or equivalent record).

**Secrets**

- **FR-018**: No secret (signing keys and their passwords, store API keys,
  service account credentials, hosting tokens) MUST ever be committed; the
  repository MUST ignore the conventional local locations for them.
- **FR-019**: The scripts MUST read secrets only from environment variables or
  from files whose paths come from environment variables, and MUST NOT print
  secret values in their output.
- **FR-020**: The project MUST document every secret a release needs, where
  to obtain it, and the environment variable that supplies it.

**iOS**

- **FR-021**: iOS releases MUST be signed for App Store distribution and
  uploaded to App Store Connect for TestFlight.
- **FR-022**: iOS builds MUST carry the declarations App Store Connect
  requires (e.g. export compliance, privacy manifest) so a build becomes
  testable without manual answers in the console.

**Android**

- **FR-023**: Android release builds MUST be signed with the project's upload
  key, assuming Play App Signing; signing a release build with the debug key
  MUST no longer be possible.
- **FR-024**: The Android script MUST produce a store bundle (for a future
  Play upload) and an installable package (for side-loading onto test
  devices), and MUST NOT upload anything to Google Play.
- **FR-025**: Android builds MUST meet Google Play's current target-API-level
  requirement for new uploads.

**Web**

- **FR-026**: The web release MUST prefer the WebAssembly build with automatic
  fallback to the JavaScript build. If a dependency proves incompatible with
  WebAssembly, the release MUST ship the JavaScript build rather than a site
  with a broken feature, and the incompatibility MUST be recorded.
- **FR-027**: The hosted site MUST serve the app for every in-app route
  (reload and direct links work).
- **FR-028**: The hosted site MUST be configured so returning visitors get a
  new release on their next load, while unchanged static assets are cached.
- **FR-029**: The hosting configuration for a deployment MUST be kept in the
  repository, so a site can be recreated from the repository plus
  credentials.

**Documentation**

- **FR-030**: The project MUST document the one-time setup per platform
  (Apple certificates/API key, App Store Connect app record, Android upload
  key generation, hosting app creation, custom domain if any) and the
  per-release procedure.
- **FR-031**: The project MUST document how to add a new brand, as a
  checklist the brand onboarder can follow end to end.

### Key Entities

- **Brand**: a customer identity — native identifiers per platform, display
  name, launcher icon, splash artwork, web title/favicon/manifest, in-app
  brand tokens. The white-label brand is the default one.
- **Deployment**: a brand released against a particular environment — the
  brand plus its app settings (API endpoint, locale, formatting, etc.) and its
  web hosting target. The first one is "white-label demo against the test
  API".
- **Release**: one build of one deployment for one platform — version name,
  build number, source commit, artifact, and destination (TestFlight, web
  URL, or a local Android bundle).
- **Credential**: a secret a release needs (Apple distribution signing, App
  Store Connect API key, Android upload key, hosting token) — never in the repository, always supplied by the environment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The white-label demo is available to prospective customers on
  a public web URL and on TestFlight, and a sign-in against the test API
  succeeds on each; a side-loaded white-label Android build also signs in.
- **SC-002**: Once one-time setup is done, a release operator publishes a
  deployment to web and TestFlight and builds its Android bundle with a
  single command and no manual steps other than waiting for store
  processing.
- **SC-003**: Misconfiguration (missing credential, missing brand item,
  unknown deployment, non-HTTPS endpoint) is reported within 30 seconds of
  starting a command, before any build work begins.
- **SC-004**: Ten consecutive releases of the same deployment produce zero
  store rejections for duplicate build numbers.
- **SC-005**: A secret scan of the repository and of captured release logs
  finds zero secret values.
- **SC-006**: A brand onboarder adds a new brand by following the
  documentation, with no change to shared application code, and produces
  build-only artifacts for all three platforms in under one hour (excluding
  store-account and design-artwork lead time).
- **SC-007**: On the published site, every in-app route survives a reload,
  and a returning visitor sees a new release after one reload.
- **SC-008**: In a current desktop browser on a typical broadband
  connection, the published white-label site reaches the sign-in screen in
  under 5 seconds on first visit.

## Assumptions

- The release machine is a Mac with the toolchains already used for
  development (Flutter, Xcode, Android SDK); the scripts check for them but
  do not install them.
- An Apple Developer Program account exists under Mictlanix; creating the
  App Store Connect app record is a one-time manual step the scripts document
  but do not perform. No Google Play Console setup is needed for this
  feature.
- The white-label web demo initially uses the host-assigned URL; a custom
  domain (e.g. under `mbe.mictlanix.com`) is a documented, optional one-time
  step, not a requirement for the first release.
- The test API at `test.api.mbe.mictlanix.com` is deployed and maintained
  separately, and will allow the web demo's origin for cross-origin requests.
  If it does not, an mbe-api/infrastructure issue is filed (constitution
  §III) rather than worked around in the client.
- "Environment" (test vs. production API) is part of the deployment choice,
  not a separate dimension in this release; only the test environment is
  exercised now, but nothing assumes there will only ever be one.
- Store listing metadata and screenshots are maintained by hand in App Store
  Connect for now.
- Brand artwork (icons, splash, lockups) is supplied by design; producing it
  is out of scope.

## Out of Scope

- CI workflows (GitHub Actions or otherwise) — only CI-readiness is in scope.
- macOS, Windows and Linux releases.
- Any Google Play upload or publishing (internal testing, closed/open
  testing, production), and the Play Console app record. The Android build
  is kept store-ready so this can be added later.
- Promotion to production / public store release.
- Store listing metadata, screenshots and review submission automation.
- Deploying or configuring mbe-api.
- Over-the-air/code-push updates.
