#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154  # shares variables with tool/release.sh
# Web build (spec 045 US1): WebAssembly bundle with JavaScript fallback.
# Hosting is out of scope: copy build/web/ to the web server yourself.

preflight_web() { :; }

build_web() {
  info "building web (WebAssembly with JavaScript fallback)"
  flutter build web --release --wasm --no-web-resources-cdn \
    --build-name "$VERSION" --build-number "$BUILD" \
    --dart-define-from-file="$ENV_FILE"
  local f
  for f in main.dart.wasm main.dart.js flutter_bootstrap.js index.html; do
    [[ -f "build/web/$f" ]] || die "build/web/$f is missing: the bundle lacks the wasm build or its JS fallback"
  done
  rewrite_web_brand
  local unreadable
  unreadable="$(find build/web -type f ! -perm -004)"
  [[ -z "$unreadable" ]] || die "files in build/web are not world-readable (a web server could not serve them): $unreadable"
  info "bundle: $(du -sh build/web | cut -f1)"
  DESTINATION="build/web"
}

publish_web() {
  info "web is build-only: copy build/web/ to the web server (see deploy/RELEASING.md)"
}
