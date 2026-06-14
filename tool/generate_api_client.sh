#!/usr/bin/env bash
# Regenerate the dart-dio OpenAPI client for mbe-api's `auth`/`users` endpoints.
#
# Usage:
#   tool/generate_api_client.sh [SPEC_URL_OR_PATH]
#
# SPEC_URL_OR_PATH defaults to mbe-api's local dev server openapi.json.
# Requires Docker (uses the openapitools/openapi-generator-cli image).
set -euo pipefail

SPEC_SOURCE="${1:-http://127.0.0.1:8000/openapi.json}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="lib/generated/openapi"
GENERATOR_IMAGE="openapitools/openapi-generator-cli"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

if [[ "$SPEC_SOURCE" == http://* || "$SPEC_SOURCE" == https://* ]]; then
  echo "Fetching OpenAPI spec from $SPEC_SOURCE ..."
  curl -fsSL "$SPEC_SOURCE" -o "$WORKDIR/openapi.json"
else
  cp "$SPEC_SOURCE" "$WORKDIR/openapi.json"
fi

rm -rf "${REPO_ROOT:?}/${OUTPUT_DIR}"
mkdir -p "${REPO_ROOT}/${OUTPUT_DIR}"

echo "Generating dart-dio client into ${OUTPUT_DIR} ..."
docker run --rm \
  -v "${WORKDIR}:/spec:ro" \
  -v "${REPO_ROOT}:/local" \
  "${GENERATOR_IMAGE}" generate \
  -i /spec/openapi.json \
  -g dart-dio \
  -o "/local/${OUTPUT_DIR}" \
  --additional-properties=pubName=mbe_api_client,pubAuthor=Mictlanix,pubDescription="mbe-api OpenAPI client (generated)"

# The generator defaults to `sdk: '>=2.18.0 <4.0.0'`, which gives this
# nested package a different language version than mbe_ui (its parent
# package). Since lib/generated/openapi sits under mbe_ui's own lib/, a
# language version mismatch between the two breaks part-file resolution
# (`flutter test`/`flutter run` fail with "language version override has to
# be the same in the library and its part(s)"), even though `flutter
# analyze` doesn't catch it (lib/generated/** is excluded from analysis).
# Align it with mbe_ui's pubspec.yaml sdk lower bound.
ROOT_SDK_LOWER_BOUND="$(grep -m1 -oE '[0-9]+\.[0-9]+\.[0-9]+' "${REPO_ROOT}/pubspec.yaml")"
sed -i.bak "s/sdk: '>=2.18.0 <4.0.0'/sdk: '>=${ROOT_SDK_LOWER_BOUND%.*}.0 <4.0.0'/" \
  "${REPO_ROOT}/${OUTPUT_DIR}/pubspec.yaml"
rm -f "${REPO_ROOT}/${OUTPUT_DIR}/pubspec.yaml.bak"

echo "Done. Generated client is at ${OUTPUT_DIR}"
