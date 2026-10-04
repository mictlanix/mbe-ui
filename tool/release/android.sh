#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154  # shares variables with tool/release.sh
# Android build (spec 045 US3): signed store bundle + installable APK.
# Nothing is uploaded to Google Play (spec decision 3a).

find_build_tool() { # find_build_tool NAME -> path of the newest SDK build-tools copy
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}" d
  for d in $(printf '%s\n' "$sdk"/build-tools/*/ | sort -V -r); do
    [[ -x "${d}$1" ]] && {
      printf '%s' "${d}$1"
      return 0
    }
  done
  return 1
}

preflight_android() {
  require_tool keytool
  find_build_tool apksigner >/dev/null || problem "apksigner not found in the Android SDK build-tools (set ANDROID_HOME)"
  find_build_tool aapt2 >/dev/null || problem "aapt2 not found in the Android SDK build-tools (set ANDROID_HOME)"
  require_file_env MBE_ANDROID_KEYSTORE_PATH
  require_env MBE_ANDROID_KEYSTORE_PASSWORD
  require_env MBE_ANDROID_KEY_ALIAS
  require_env MBE_ANDROID_KEY_PASSWORD
}

build_android() {
  info "building Android bundle and APK"
  flutter build appbundle --release \
    --build-name "$VERSION" --build-number "$BUILD" \
    --dart-define-from-file="$ENV_FILE"
  flutter build apk --release \
    --build-name "$VERSION" --build-number "$BUILD" \
    --dart-define-from-file="$ENV_FILE"

  local aab="build/app/outputs/bundle/release/app-release.aab"
  local apk="build/app/outputs/flutter-apk/app-release.apk"
  [[ -f "$aab" && -f "$apk" ]] || die "expected Android artifacts not found"

  # The signer must be our upload key, never a debug key (FR-023).
  local expected got
  expected="$(keytool -list -v -keystore "$MBE_ANDROID_KEYSTORE_PATH" \
    -storepass "$MBE_ANDROID_KEYSTORE_PASSWORD" -alias "$MBE_ANDROID_KEY_ALIAS" 2>/dev/null |
    sed -n 's/^[[:space:]]*SHA256:[[:space:]]*//p' | head -1 | tr -d ':' | tr 'A-F' 'a-f')"
  got="$("$(find_build_tool apksigner)" verify --print-certs "$apk" 2>/dev/null |
    sed -n 's/^Signer #1 certificate SHA-256 digest: *//p' | head -1)"
  [[ -n "$expected" && "$got" == "$expected" ]] || die "APK is not signed with the upload key (signer ${got:-unknown})"

  local badging pkg target
  badging="$("$(find_build_tool aapt2)" dump badging "$apk")"
  pkg="$(sed -n "s/^package: name='\([^']*\)'.*/\1/p" <<<"$badging")"
  target="$(sed -n "s/^targetSdkVersion:'\([0-9]*\)'.*/\1/p" <<<"$badging")"
  [[ "$pkg" == "$APPLICATION_ID" ]] || die "APK application id is '$pkg', expected '$APPLICATION_ID'"
  [[ "${target:-0}" -ge 36 ]] || die "APK targetSdk is ${target:-unknown}; Google Play requires 36 or newer"
  grep -q "^uses-permission: name='android.permission.INTERNET'" <<<"$badging" ||
    die "APK does not request android.permission.INTERNET: it could not reach the API"
  DESTINATION="$aab and $apk (signed with upload key; not published)"
}

publish_android() {
  info "Android is build-only in this release: nothing is uploaded to Google Play"
}
