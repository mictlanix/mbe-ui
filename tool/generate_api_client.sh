#!/usr/bin/env bash
# Regenerate the dart-dio OpenAPI client for mbe-api's `auth`/`users` endpoints.
#
# Usage:
#   tool/generate_api_client.sh [SPEC_URL_OR_PATH]
#
# SPEC_URL_OR_PATH defaults to mbe-api's local dev server openapi.json.
# Requires Docker (uses the openapitools/openapi-generator-cli image).
#
# tool/openapi-templates/dart-dio overrides the generator's query-param
# template: upstream skips the `if (param != null)` guard whenever a query
# param's schema itself is nullable (e.g. FastAPI `Optional[str] = None`
# filters), even though the param is optional and the guard is needed to
# omit it from the request when unset. See openapi-generator's
# dart/libraries/dio/api.mustache for the original logic.
set -euo pipefail

SPEC_SOURCE="${1:-http://127.0.0.1:8000/openapi.json}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="lib/generated/openapi"
GENERATOR_IMAGE="openapitools/openapi-generator-cli:v7.25.0"

# Keep the spec workdir inside the repo: VM-backed Docker runtimes (e.g. Colima)
# only share $HOME, so a /var/folders temp dir mounts as an empty directory.
WORKDIR="$(mktemp -d "${REPO_ROOT}/.openapi-spec.XXXXXX")"
trap 'rm -rf "$WORKDIR"' EXIT

if [[ "$SPEC_SOURCE" == http://* || "$SPEC_SOURCE" == https://* ]]; then
  echo "Fetching OpenAPI spec from $SPEC_SOURCE ..."
  curl -fsSL "$SPEC_SOURCE" -o "$WORKDIR/openapi.json"
else
  cp "$SPEC_SOURCE" "$WORKDIR/openapi.json"
fi

rm -rf "${REPO_ROOT:?}/${OUTPUT_DIR}"
mkdir -p "${REPO_ROOT}/${OUTPUT_DIR}"

# Which top-level artifacts to emit. apis/models/supportingFiles must stay
# bare: giving them a value (e.g. "apis=true") switches them into a different
# mode where the value is parsed as a filename filter, which skips everything
# since no file is literally named "true". apiDocs/modelDocs/apiTests/
# modelTests are plain booleans and are spelled out explicitly (all match the
# generator's defaults, apiTests/modelTests excepted) so a future bump of
# GENERATOR_IMAGE can't silently change what gets generated.
GLOBAL_PROPERTIES="apis,\
models,\
supportingFiles,\
apiDocs=true,\
modelDocs=true,\
apiTests=false,\
modelTests=false"

# Every dart-dio config option (`docker run $GENERATOR_IMAGE config-help -g
# dart-dio`), pinned to its documented default for v7.25.0 except
# pubName/pubAuthor/pubDescription, which carry this project's values.
# pubPublishTo and pubRepository are omitted: they have no default, and
# passing an empty value would add empty fields to the generated pubspec.yaml.
# serializationLibrary must stay built_value: the build_runner step below
# generates built_value's *.g.dart files.
# sortModelPropertiesByRequiredFlag is set to false even though config-help
# documents its default as true: verified against v7.25.0 that omitting it
# entirely (the prior behavior) keeps spec declaration order, so false is
# what actually reproduces the already-committed generated models.
ADDITIONAL_PROPERTIES="allowUnicodeIdentifiers=false,\
dateLibrary=core,\
disallowAdditionalPropertiesIfNotPresent=true,\
ensureUniqueParams=true,\
enumUnknownDefaultCase=false,\
equalityCheckMethod=default,\
finalProperties=true,\
legacyDiscriminatorBehavior=true,\
patchOnly=false,\
prependFormOrBodyParameters=false,\
pubAuthor=Mictlanix,\
pubAuthorEmail=author@homepage,\
pubDescription=mbe-api OpenAPI client (generated),\
pubHomepage=homepage,\
pubLibrary=openapi.api,\
pubName=mbe_api_client,\
pubVersion=1.0.0,\
serializationLibrary=built_value,\
skipCopyWith=false,\
sortModelPropertiesByRequiredFlag=false,\
sortParamsByRequiredFlag=true,\
sourceFolder=src,\
useEnumExtension=false,\
useOptional=false"

echo "Generating dart-dio client into ${OUTPUT_DIR} ..."
docker run --rm \
  -v "${WORKDIR}:/spec:ro" \
  -v "${REPO_ROOT}:/local" \
  "${GENERATOR_IMAGE}" generate \
  -i /spec/openapi.json \
  -g dart-dio \
  -o "/local/${OUTPUT_DIR}" \
  -t /local/tool/openapi-templates/dart-dio \
  --global-property="${GLOBAL_PROPERTIES}" \
  --additional-properties="${ADDITIONAL_PROPERTIES}"

# The generator may produce an sdk lower bound below 2.12.0 (e.g. '>=1.2.0'),
# which Dart 3 rejects outright ('pub get' fails: "The lower bound must be
# 2.12.0 or higher to enable null safety"). Also, since lib/generated/openapi
# sits under mbe_ui's own lib/, a language version mismatch between the two
# packages breaks part-file resolution at runtime even when analysis passes.
# Extract the lower bound from the sdk line specifically (not the package
# version line) and patch the generated pubspec to match.
ROOT_SDK_LOWER_BOUND="$(grep -E '^\s+sdk:' "${REPO_ROOT}/pubspec.yaml" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
sed -i.bak "s/sdk: '>=.*<4.0.0'/sdk: '>=${ROOT_SDK_LOWER_BOUND} <4.0.0'/" \
  "${REPO_ROOT}/${OUTPUT_DIR}/pubspec.yaml"
rm -f "${REPO_ROOT}/${OUTPUT_DIR}/pubspec.yaml.bak"

echo "Running build_runner to generate built_value *.g.dart files ..."
(cd "${REPO_ROOT}/${OUTPUT_DIR}" && dart pub get && dart run build_runner build)

echo "Done. Generated client is at ${OUTPUT_DIR}"

dart format ${OUTPUT_DIR}

echo "Generated client's code at ${OUTPUT_DIR} was formatted"