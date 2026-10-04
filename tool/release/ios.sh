#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154  # shares variables with tool/release.sh
# iOS release (spec 045 US2): unsigned archive, then a cloud-signed export that
# uploads to App Store Connect / TestFlight (research R3).

ARCHIVE="build/ios/archive/Runner.xcarchive"

preflight_ios() {
  require_tool xcodebuild
  require_tool xcrun
  if command -v xcodebuild >/dev/null 2>&1; then
    local major
    major="$(xcodebuild -version 2>/dev/null | sed -n 's/^Xcode \([0-9]*\).*/\1/p')"
    [[ "${major:-0}" -ge 26 ]] || problem "Xcode 26 or newer is required for App Store uploads (found ${major:-none})"
  fi
  if [[ $BUILD_ONLY -eq 0 ]]; then
    require_env MBE_ASC_KEY_ID
    require_env MBE_ASC_ISSUER_ID
    if [[ -n "${MBE_ASC_ISSUER_ID:-}" && ! "$MBE_ASC_ISSUER_ID" =~ ^[0-9a-fA-F-]{36}$ ]]; then
      problem "MBE_ASC_ISSUER_ID is not a UUID"
    fi
    require_file_env MBE_ASC_KEY_PATH
  fi
}

build_ios() {
  info "building unsigned iOS archive"
  rm -rf "$ARCHIVE"
  flutter build ipa --release --no-codesign \
    --build-name "$VERSION" --build-number "$BUILD" \
    --dart-define-from-file="$ENV_FILE"
  [[ -d "$ARCHIVE" ]] || die "expected archive not found: $ARCHIVE"
  local plist="$ARCHIVE/Products/Applications/Runner.app/Info.plist" got
  got="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")"
  [[ "$got" == "$BUNDLE_ID" ]] || die "archive bundle id is '$got', expected '$BUNDLE_ID'"
  got="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")"
  [[ "$got" == "$BUILD" ]] || die "archive build number is '$got', expected '$BUILD'"
  DESTINATION="$ARCHIVE (unsigned)"
}

publish_ios() {
  local work options
  work="$(make_tmp_dir)"
  options="$work/ExportOptions.plist"
  cat >"$options" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>upload</string>
  <key>teamID</key><string>$IOS_TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
PLIST
  info "signing with Apple-managed distribution certificate and uploading"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE" \
    -exportOptionsPlist "$options" \
    -exportPath "$work/export" \
    -allowProvisioningUpdates \
    -authenticationKeyPath "$MBE_ASC_KEY_PATH" \
    -authenticationKeyID "$MBE_ASC_KEY_ID" \
    -authenticationKeyIssuerID "$MBE_ASC_ISSUER_ID"
  DESTINATION="App Store Connect / TestFlight (upload accepted; Apple processing continues)"
}
