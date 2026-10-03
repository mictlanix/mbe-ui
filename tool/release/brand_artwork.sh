#!/usr/bin/env bash
# Generate a brand's native + web artwork overlay (spec 045 US4, research R2).
#
#   tool/release/brand_artwork.sh <brand>
#
# Reads deploy/brands/<brand>/src/{app_icon_1024.png,
# android_adaptive_foreground_1024.png, splash_1024.png} and brand.properties,
# runs flutter_launcher_icons and flutter_native_splash inside a temporary git
# worktree (they also rewrite pbxproj, Info.plist and index.html, so they must
# never run in the live tree), and copies only the artwork listed in
# tool/release/overlay-manifest.txt into deploy/brands/<brand>/overlay/.
# Commit the overlay; tool/release.sh stages it for the build.
set -euo pipefail
exec </dev/null
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
# shellcheck source-path=SCRIPTDIR source=lib.sh
source tool/release/lib.sh

[[ $# -eq 1 ]] || {
  echo "usage: tool/release/brand_artwork.sh <brand>" >&2
  exit 2
}
BRAND="$1"
BRAND_DIR="deploy/brands/$BRAND"
BRAND_PROPS="$BRAND_DIR/brand.properties"
[[ -f "$BRAND_PROPS" ]] || die "$BRAND_PROPS not found"
[[ "$BRAND" != "mbe" ]] || die "the white-label brand has no overlay: the repository is its baseline"

SRC="$REPO_ROOT/$BRAND_DIR/src"
for f in app_icon_1024.png android_adaptive_foreground_1024.png splash_1024.png; do
  [[ -f "$SRC/$f" ]] || problem "$BRAND_DIR/src/$f is missing"
done
THEME="$(prop "$BRAND_PROPS" WEB_THEME_COLOR)"
[[ "$THEME" =~ ^#[0-9A-Fa-f]{6}$ ]] || problem "$BRAND_PROPS: WEB_THEME_COLOR must be #RRGGBB"
fail_if_problems

WORK="$(make_tmp_dir)/tree"
trap 'git -C "$REPO_ROOT" worktree remove --force "$WORK" 2>/dev/null || true; cleanup' EXIT
info "creating temporary worktree"
git worktree add --detach -q "$WORK" HEAD

cat >"$WORK/brand_icons.yaml" <<YAML
flutter_launcher_icons:
  image_path: "$SRC/app_icon_1024.png"
  android: true
  adaptive_icon_background: "$THEME"
  adaptive_icon_foreground: "$SRC/android_adaptive_foreground_1024.png"
  ios: true
  remove_alpha_ios: true
  web:
    generate: true
    image_path: "$SRC/app_icon_1024.png"
    background_color: "$THEME"
    theme_color: "$THEME"
YAML
cat >"$WORK/brand_splash.yaml" <<YAML
flutter_native_splash:
  color: "$THEME"
  image: "$SRC/splash_1024.png"
  android_12:
    color: "$THEME"
    image: "$SRC/splash_1024.png"
  android: true
  ios: true
  web: true
YAML

(
  cd "$WORK" || exit 1
  flutter pub get >/dev/null
  dart run flutter_launcher_icons -f brand_icons.yaml
  dart run flutter_native_splash:create --path=brand_splash.yaml
)

OUT="$REPO_ROOT/$BRAND_DIR/overlay"
rm -rf "$OUT"
copied=0
while IFS= read -r pat; do
  [[ -z "$pat" || "$pat" == \#* ]] && continue
  for f in "$WORK"/$pat; do
    [[ -f "$f" ]] || continue
    rel="${f#"$WORK"/}"
    mkdir -p "$OUT/$(dirname "$rel")"
    cp "$f" "$OUT/$rel"
    copied=$((copied + 1))
  done
done <"$REPO_ROOT/$OVERLAY_MANIFEST"
info "wrote $copied artwork files to $BRAND_DIR/overlay (commit them)"
