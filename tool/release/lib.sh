#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are consumed by release.sh and platform scripts
# Shared helpers for tool/release.sh (spec 045). Sourced; defines functions and
# variables only. Never prints a secret value, never reads stdin.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_EPOCH=1767225600 # 2026-01-01T00:00:00Z

PROBLEMS=()
TMP_DIRS=()

info() { printf '[release] %s\n' "$*"; }
warn() { printf '[release] warning: %s\n' "$*" >&2; }
die() {
  printf '[release] error: %s\n' "$*" >&2
  exit 1
}

# --- preflight accumulation -------------------------------------------------

problem() { PROBLEMS+=("$*"); }

fail_if_problems() {
  if [[ ${#PROBLEMS[@]} -gt 0 ]]; then
    printf '[release] preflight failed (nothing was built):\n' >&2
    local p
    for p in "${PROBLEMS[@]}"; do printf '  - %s\n' "$p" >&2; done
    exit 3
  fi
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || problem "required tool not found on PATH: $1"
}

require_env() {
  [[ -n "${!1:-}" ]] || problem "environment variable $1 is not set"
}

# A credential file whose path comes from the environment: must exist, be
# readable and live outside the repository (FR-018/019).
require_file_env() {
  local var="$1" path="${!1:-}"
  if [[ -z "$path" ]]; then
    problem "environment variable $var is not set"
  elif [[ ! -r "$path" ]]; then
    problem "$var points to a file that is missing or unreadable"
  elif [[ "$(cd "$(dirname "$path")" && pwd)/" == "$REPO_ROOT/"* ]]; then
    problem "$var points inside the repository; keep credential files outside it"
  fi
}

# --- .properties-style files (KEY=VALUE, no eval) ---------------------------

prop() { # prop FILE KEY [DEFAULT]
  local v
  v="$(grep -E "^$2=" "$1" 2>/dev/null | tail -1 | cut -d= -f2-)" || true
  v="${v%$'\r'}"
  printf '%s' "${v:-${3:-}}"
}

# --- deployments and brands -------------------------------------------------

list_deployments() {
  local f
  for f in "$REPO_ROOT"/deploy/*.release; do
    [[ -e "$f" ]] || continue
    basename "$f" .release
  done
}

describe_deployments() {
  local d
  for d in $(list_deployments); do
    printf '  %s (brand %s)\n' "$d" "$(prop "$REPO_ROOT/deploy/$d.release" BRAND)"
  done
}

check_field() { # check_field NAME VALUE REGEX
  if [[ -z "$2" ]]; then
    problem "$BRAND_PROPS: $1 is missing"
  elif [[ ! "$2" =~ $3 ]]; then
    problem "$BRAND_PROPS: $1 has an invalid value"
  fi
}

# Resolve and validate a deployment. Sets DEPLOYMENT, ENV_FILE, REL_FILE,
# APP_YAML, BRAND, BRAND_DIR, BRAND_PROPS, the brand fields and the web fields.
# Problems are accumulated; the caller runs fail_if_problems.
load_deployment() {
  DEPLOYMENT="$1"
  if [[ ! "$DEPLOYMENT" =~ ^[a-z0-9-]+$ ]] || [[ ! -f "$REPO_ROOT/deploy/$DEPLOYMENT.release" ]]; then
    problem "unknown deployment '$DEPLOYMENT'; valid deployments:"
    local line
    while IFS= read -r line; do problem "$line"; done < <(describe_deployments)
    return 0
  fi
  ENV_FILE="deploy/$DEPLOYMENT.env"
  REL_FILE="deploy/$DEPLOYMENT.release"
  APP_YAML="deploy/$DEPLOYMENT.app.yaml"
  [[ -f "$REPO_ROOT/$ENV_FILE" ]] || problem "missing $ENV_FILE"

  BRAND="$(prop "$REPO_ROOT/$REL_FILE" BRAND)"
  WEB_DEPLOY_REPO="$(prop "$REPO_ROOT/$REL_FILE" WEB_DEPLOY_REPO)"
  WEB_DEPLOY_BRANCH="$(prop "$REPO_ROOT/$REL_FILE" WEB_DEPLOY_BRANCH "web/$DEPLOYMENT")"
  BRAND_DIR="deploy/brands/$BRAND"
  BRAND_PROPS="$BRAND_DIR/brand.properties"
  if [[ -z "$BRAND" || ! -f "$REPO_ROOT/$BRAND_PROPS" ]]; then
    problem "$REL_FILE: BRAND '$BRAND' has no $BRAND_PROPS"
    return 0
  fi

  local p="$REPO_ROOT/$BRAND_PROPS"
  BUNDLE_ID="$(prop "$p" BUNDLE_ID)"
  APPLICATION_ID="$(prop "$p" APPLICATION_ID)"
  DISPLAY_NAME="$(prop "$p" DISPLAY_NAME)"
  IOS_TEAM_ID="$(prop "$p" IOS_TEAM_ID)"
  WEB_TITLE="$(prop "$p" WEB_TITLE)"
  WEB_SHORT_NAME="$(prop "$p" WEB_SHORT_NAME)"
  WEB_THEME_COLOR="$(prop "$p" WEB_THEME_COLOR)"
  check_field BUNDLE_ID "$BUNDLE_ID" '^[A-Za-z][A-Za-z0-9-]*(\.[A-Za-z][A-Za-z0-9-]*)+$'
  check_field APPLICATION_ID "$APPLICATION_ID" '^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$'
  # Values land in an xcconfig and a Java properties file: keep them inert.
  check_field DISPLAY_NAME "$DISPLAY_NAME" '^[^$"\\/]+$'
  check_field IOS_TEAM_ID "$IOS_TEAM_ID" '^[A-Z0-9]{10}$'
  check_field WEB_TITLE "$WEB_TITLE" '^[^<>&"|\\]+$'
  check_field WEB_SHORT_NAME "$WEB_SHORT_NAME" '^[^<>&"|\\]+$'
  check_field WEB_THEME_COLOR "$WEB_THEME_COLOR" '^#[0-9A-Fa-f]{6}$'
}

# API_BASE_URL must be an https URL for a release build (FR-010).
check_api_url() {
  [[ -f "$REPO_ROOT/$ENV_FILE" ]] || return 0
  API_BASE_URL="$(prop "$REPO_ROOT/$ENV_FILE" API_BASE_URL)"
  if [[ -z "$API_BASE_URL" ]]; then
    problem "$ENV_FILE: API_BASE_URL is not set"
  elif [[ "$API_BASE_URL" != https://* ]]; then
    problem "$ENV_FILE: API_BASE_URL must start with https:// for a release build"
  fi
}

# --- versioning (FR-015/016) ------------------------------------------------

version_name() {
  sed -n 's/^version: *\([0-9][0-9.]*\).*/\1/p' "$REPO_ROOT/pubspec.yaml" | head -1
}

build_number() {
  echo $((($(date -u +%s) - BUILD_EPOCH) / 60))
}

# --- git --------------------------------------------------------------------

tree_is_dirty() { [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; }
head_sha() { git -C "$REPO_ROOT" rev-parse --short HEAD; }

# --- brand staging (research R1/R2) -----------------------------------------

clear_brand_files() {
  rm -f "$REPO_ROOT/ios/Flutter/Brand.xcconfig" "$REPO_ROOT/android/brand.properties"
}

write_brand_files() {
  cat >"$REPO_ROOT/ios/Flutter/Brand.xcconfig" <<XCC
PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID
BRAND_DISPLAY_NAME = $DISPLAY_NAME
DEVELOPMENT_TEAM = $IOS_TEAM_ID
XCC
  cat >"$REPO_ROOT/android/brand.properties" <<PROPS
APPLICATION_ID=$APPLICATION_ID
DISPLAY_NAME=$DISPLAY_NAME
PROPS
}

make_tmp_dir() {
  local d
  d="$(mktemp -d)"
  TMP_DIRS+=("$d")
  printf '%s' "$d"
}

# Restore everything a release run changed in the tree or created in /tmp.
cleanup() {
  local rc=$?
  clear_brand_files
  unstage_overlay
  local d
  if [[ ${#TMP_DIRS[@]} -gt 0 ]]; then
    for d in "${TMP_DIRS[@]}"; do rm -rf "$d"; done
  fi
  return $rc
}

# --- overlay (non-default brands only; research R2) -------------------------
# A brand's native and web artwork lives in deploy/brands/<brand>/overlay/,
# mirroring repo paths. It is copied over the tree for the build and restored
# afterwards. The white-label brand has no overlay: the repo is its baseline.

OVERLAY_TRACKED=()
OVERLAY_NEW=()
OVERLAY_MANIFEST="tool/release/overlay-manifest.txt"

overlay_files() { # relative paths of every file in the brand's overlay
  local dir="$REPO_ROOT/$BRAND_DIR/overlay"
  [[ -d "$dir" ]] || return 0
  (cd "$dir" && find . -type f | sed 's|^\./||' | sort)
}

# Preflight: every manifest entry must be present (FR-013), and no file the
# overlay will replace may carry uncommitted edits (restoring would discard them).
check_overlay() {
  local dir="$REPO_ROOT/$BRAND_DIR/overlay" pat rel
  [[ -d "$dir" ]] || return 0
  while IFS= read -r pat; do
    [[ -z "$pat" || "$pat" == \#* ]] && continue
    # shellcheck disable=SC2086  # the manifest entry is a glob on purpose
    compgen -G "$dir/"$pat >/dev/null || problem "$BRAND_DIR/overlay is missing required artwork: $pat"
  done <"$REPO_ROOT/$OVERLAY_MANIFEST"
  while IFS= read -r rel; do
    if git -C "$REPO_ROOT" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1 &&
      [[ -n "$(git -C "$REPO_ROOT" status --porcelain -- "$rel")" ]]; then
      problem "uncommitted changes in $rel, which the $BRAND overlay replaces during the build"
    fi
  done < <(overlay_files)
}

stage_overlay() {
  local dir="$REPO_ROOT/$BRAND_DIR/overlay" rel
  [[ -d "$dir" ]] || return 0
  while IFS= read -r rel; do
    if git -C "$REPO_ROOT" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then
      OVERLAY_TRACKED+=("$rel")
    else
      OVERLAY_NEW+=("$rel")
    fi
  done < <(overlay_files)
  cp -R "$dir"/. "$REPO_ROOT"/
  info "staged $(overlay_files | wc -l | tr -d ' ') overlay files for brand $BRAND"
}

unstage_overlay() {
  if [[ ${#OVERLAY_TRACKED[@]} -gt 0 ]]; then
    git -C "$REPO_ROOT" checkout -- "${OVERLAY_TRACKED[@]}"
    OVERLAY_TRACKED=()
  fi
  if [[ ${#OVERLAY_NEW[@]} -gt 0 ]]; then
    local rel
    for rel in "${OVERLAY_NEW[@]}"; do rm -f "$REPO_ROOT/$rel"; done
    OVERLAY_NEW=()
  fi
}

# Web metadata comes from brand.properties and is applied to the BUILT bundle
# only; web/ in the repo is never modified (research R5).
rewrite_web_brand() {
  local idx="build/web/index.html" man="build/web/manifest.json" t
  t="$(mktemp)"
  sed -e "s|<title>.*</title>|<title>$WEB_TITLE</title>|" \
    -e "s|\(<meta name=\"apple-mobile-web-app-title\" content=\"\)[^\"]*|\1$WEB_SHORT_NAME|" \
    "$idx" >"$t" && mv "$t" "$idx"
  t="$(mktemp)"
  sed -e "s|\(\"name\": \"\)[^\"]*|\1$WEB_TITLE|" \
    -e "s|\(\"short_name\": \"\)[^\"]*|\1$WEB_SHORT_NAME|" \
    -e "s|\(\"theme_color\": \"\)[^\"]*|\1$WEB_THEME_COLOR|" \
    "$man" >"$t" && mv "$t" "$man"
}
