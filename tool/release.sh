#!/usr/bin/env bash
# Release a deployment (a brand + its app settings) to a platform. Spec 045.
#
#   tool/release.sh <web|ios|android|all> <deployment> [options]
#   tool/release.sh --list | --status
#
# See specs/045-deploy-scripts/contracts/release-cli.md and deploy/RELEASING.md.
# Never prompts for input and never prints a secret value.
set -euo pipefail
exec </dev/null
export GIT_TERMINAL_PROMPT=0

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
cd "$(dirname "$SELF")/.."
# shellcheck source-path=SCRIPTDIR source=release/lib.sh
source tool/release/lib.sh

BUILD_ONLY=0
ALLOW_DIRTY=0
PUSH_TAG=0

usage() {
  cat >&2 <<'USAGE'
usage: tool/release.sh <web|ios|android|all> <deployment> [options]
       tool/release.sh --list | --status

options:
  --build-only   build (and sign) the artifact; never upload, publish or tag
  --allow-dirty  proceed with uncommitted changes (stated in the output)
  --push-tag     push the release tag to origin after tagging
  --list         list valid deployments
  --status       show which brand the working tree is configured for
USAGE
  exit 2
}

show_status() {
  printf 'branch:      %s\n' "$(git branch --show-current)"
  if [[ -f ios/Flutter/Brand.xcconfig ]]; then
    printf 'iOS brand:   generated (%s)\n' "$(prop ios/Flutter/Brand.xcconfig PRODUCT_BUNDLE_IDENTIFIER | tr -d ' ' || true)"
  else
    printf 'iOS brand:   white-label defaults (no generated Brand.xcconfig)\n'
  fi
  if [[ -f android/brand.properties ]]; then
    printf 'Android:     generated (%s)\n' "$(prop android/brand.properties APPLICATION_ID)"
  else
    printf 'Android:     white-label defaults (no generated brand.properties)\n'
  fi
}

PLATFORM=""
DEPLOY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only) BUILD_ONLY=1 ;;
    --allow-dirty) ALLOW_DIRTY=1 ;;
    --push-tag) PUSH_TAG=1 ;;
    --list)
      describe_deployments
      exit 0
      ;;
    --status)
      show_status
      exit 0
      ;;
    -h | --help) usage ;;
    -*) usage ;;
    *)
      if [[ -z "$PLATFORM" ]]; then
        PLATFORM="$1"
      elif [[ -z "$DEPLOY" ]]; then
        DEPLOY="$1"
      else usage; fi
      ;;
  esac
  shift
done
[[ -n "$PLATFORM" && -n "$DEPLOY" ]] || usage
case "$PLATFORM" in web | ios | android | all) ;; *) usage ;; esac

# One build number per invocation so every platform of an `all` run agrees.
BUILD="${MBE_BUILD_NUMBER:-$(build_number)}"
export MBE_BUILD_NUMBER="$BUILD"

# `all`: run each platform as its own process so one failure never hides
# another's result (FR-002).
if [[ "$PLATFORM" == "all" ]]; then
  child_args=("$DEPLOY")
  [[ $BUILD_ONLY -eq 1 ]] && child_args+=(--build-only)
  [[ $ALLOW_DIRTY -eq 1 ]] && child_args+=(--allow-dirty)
  [[ $PUSH_TAG -eq 1 ]] && child_args+=(--push-tag)
  failed=0
  rows=()
  for p in web ios android; do
    if "$SELF" "$p" "${child_args[@]}"; then
      rows+=("$p: ok")
    else
      rows+=("$p: FAILED (exit $?)")
      failed=1
    fi
  done
  printf '\n[release] summary for %s (build %s)\n' "$DEPLOY" "$BUILD"
  printf '  %s\n' "${rows[@]}"
  exit "$failed"
fi

# --- single platform --------------------------------------------------------

load_deployment "$DEPLOY"
if [[ $ALLOW_DIRTY -eq 0 ]] && tree_is_dirty; then
  problem "working tree has uncommitted changes (commit them, or pass --allow-dirty)"
fi
# A deployment that failed to load has no brand fields; report and stop.
[[ -n "${BUNDLE_ID:-}" ]] || fail_if_problems
check_api_url
check_overlay
require_tool flutter
require_tool git

# shellcheck source=/dev/null
source "tool/release/$PLATFORM.sh"
"preflight_$PLATFORM"
fail_if_problems

VERSION="$(version_name)"
SHA="$(head_sha)"
[[ $ALLOW_DIRTY -eq 1 ]] && tree_is_dirty && SHA="$SHA-dirty" && warn "releasing from a dirty tree (--allow-dirty)"
info "$DEPLOYMENT/$PLATFORM: version $VERSION, build $BUILD, commit $SHA"

clear_brand_files
trap cleanup EXIT
write_brand_files
stage_overlay

DESTINATION=""
"build_$PLATFORM"
if [[ $BUILD_ONLY -eq 0 ]]; then
  "publish_$PLATFORM"
  TAG="$DEPLOYMENT/$PLATFORM/v$VERSION-$BUILD"
  if [[ "$PLATFORM" == "ios" ]]; then
    git tag -a "$TAG" -m "$DEPLOYMENT $PLATFORM $VERSION+$BUILD (commit $SHA)"
    info "tagged $TAG"
    [[ $PUSH_TAG -eq 1 ]] && git push origin "$TAG"
  fi
fi

printf 'RELEASED deployment=%s platform=%s version=%s build=%s commit=%s destination=%s\n' \
  "$DEPLOYMENT" "$PLATFORM" "$VERSION" "$BUILD" "$SHA" "$DESTINATION"
