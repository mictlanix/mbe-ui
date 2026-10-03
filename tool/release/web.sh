#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154  # shares variables with tool/release.sh
# Web release (spec 045 US1): WebAssembly build, pushed to a private deploy
# repository branch that DigitalOcean App Platform serves as a static site.

preflight_web() {
  [[ -f "$APP_YAML" ]] || problem "missing $APP_YAML"
  if [[ $BUILD_ONLY -eq 0 ]]; then
    require_tool doctl
    require_env DIGITALOCEAN_ACCESS_TOKEN
    [[ -n "$WEB_DEPLOY_REPO" ]] || problem "$REL_FILE: WEB_DEPLOY_REPO is not set"
    if command -v doctl >/dev/null 2>&1 && [[ -n "${DIGITALOCEAN_ACCESS_TOKEN:-}" ]]; then
      doctl account get >/dev/null 2>&1 || problem "DIGITALOCEAN_ACCESS_TOKEN was rejected by DigitalOcean"
    fi
    if [[ -n "$WEB_DEPLOY_REPO" ]]; then
      git ls-remote "$WEB_DEPLOY_REPO" >/dev/null 2>&1 || problem "cannot reach WEB_DEPLOY_REPO $WEB_DEPLOY_REPO (access/credentials)"
    fi
  fi
}

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
  info "bundle: $(du -sh build/web | cut -f1)"
  DESTINATION="build/web"
}

publish_web() {
  local work app_name app_id
  work="$(make_tmp_dir)"
  info "pushing bundle to $WEB_DEPLOY_REPO ($WEB_DEPLOY_BRANCH)"
  cp -R build/web/. "$work/"
  (
    cd "$work" || exit 1
    git init -q
    git checkout -q -b "$WEB_DEPLOY_BRANCH"
    git add -A
    git -c "user.name=${GIT_AUTHOR_NAME:-mbe-release}" \
      -c "user.email=${GIT_AUTHOR_EMAIL:-mbe-release@users.noreply.github.com}" \
      commit -q -m "$DEPLOYMENT $VERSION+$BUILD from $SHA"
    git push -q --force "$WEB_DEPLOY_REPO" "$WEB_DEPLOY_BRANCH"
  )

  app_name="$(sed -n 's/^name: *//p' "$APP_YAML" | head -1)"
  [[ -n "$app_name" ]] || die "$APP_YAML has no top-level name"
  doctl apps spec validate "$APP_YAML" >/dev/null
  app_id="$(doctl apps list --format ID,Spec.Name --no-header | awk -v n="$app_name" '$2 == n { print $1 }')"
  if [[ -z "$app_id" ]]; then
    info "creating App Platform app $app_name"
    app_id="$(doctl apps create --spec "$APP_YAML" --wait --format ID --no-header)"
  else
    info "updating App Platform app $app_name"
    doctl apps update "$app_id" --spec "$APP_YAML" --wait >/dev/null
    doctl apps create-deployment "$app_id" --wait >/dev/null
  fi
  DESTINATION="$(doctl apps get "$app_id" --format DefaultIngress --no-header)"
}
