# Phase 0 Research: Merge Products

All Technical Context unknowns resolved. Decisions below are grounded in the current mbe-ui codebase, the generated client, and mbe-api's implementation.

## 1. Backend & generated client already exist — no codegen

- **Decision**: Consume the existing generated `ProductsApi.mergeProductsApiV1ProductsMergePost({required ProductMergeRequest productMergeRequest})` and the generated `ProductMergeRequest` (`product_id`, `duplicate_id`). No OpenAPI regeneration, no hand-written DTO.
- **Rationale**: Verified in `lib/generated/openapi/lib/src/api/products_api.dart:383` and `.../model/product_merge_request.dart`. mbe-api exposes `POST /api/v1/products/merge` (`app/api/v1/endpoints/products.py:74`) returning `204 No Content`, implemented by `app/services/product_service.py::merge_products`. Constitution §III forbids hand DTOs when a schema is published.
- **Alternatives considered**: A raw `dio` call (like `uploadPhoto`/`removePhoto`) — rejected; those bypass codegen only because the generated method is unusable (string-typed binary / null-clearing). The merge method is fully usable as generated.

## 2. Product search source for the two pickers

- **Decision**: Reuse `ProductRepository.list(search: query, deactivated: null, limit: 15)` and map `ProductListItem`s into the picker. Enforce a minimum query length (3 chars) before firing.
- **Rationale**: mbe-api's list search (`product_service.py:36-44`) already matches `code | name | model | sku | brand` via `ilike`, exactly the legacy `GetMergeSuggestions` field set. Passing `deactivated: null` applies no state filter, so products in **any** state are searchable — matching the legacy merge search (which, unlike the general product search, intentionally includes disabled products; see spec Clarifications). Reusing `list` avoids a new endpoint/method and inherits existing error mapping and pagination limits.
- **Alternatives considered**:
  - A dedicated `searchForMerge`/`GetMergeSuggestions`-style repo method — rejected; `list` already covers the fields and state semantics. Numeric-id lookup (a legacy nicety) is out of scope; operators identify products by name/code.
  - Reusing the general product-search provider that hides deactivated products — rejected; a duplicate to clean up may be deactivated.

## 3. Displaying SKU in suggestion rows

- **Decision (resolved)**: Suggestion rows show the product **photo thumbnail + name + code + model + SKU**. SKU was initially deferred — filed as an upstream mbe-api request, [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76), rather than dropped from the requirement or hand-patched — and has since landed; mbe-ui regenerated its client and wired the field through.
- **Rationale**: The generated `ProductListItem` projection (`lib/generated/openapi/.../product_list_item.dart`) and the domain `ProductListItem` initially had **no `sku` field** (only productId, code, name, photo, brand, model, taxRate, deactivated). Adding it required an mbe-api schema change (`app/schemas/product.py`'s `ProductListItem`) — outside mbe-ui's repo boundary, so mbe-ui filed the request rather than patching it directly (constitution §III also forbids hand-editing the generated Dart client to fake the field). FR-003 kept SKU as a required display field throughout; the interim fields (photo/name/code/model) identified a product well enough for the merge task until #76 landed.
- **Resolution**: mbe-api added `sku: str | None` to `ProductListItem` (mictlanix/mbe-api#76, merged); mbe-ui re-ran `tool/generate_api_client.sh`, added `sku` to the domain `ProductListItem` (`lib/features/catalog/domain/entities/product_list_item.dart`), and passed it into `CatalogEntityPicker`'s `optionSubtitle` alongside code/model (contracts/ui-contracts.md §1). No plan.md Complexity Tracking deviation remains outstanding for this item.
- **Alternatives considered**:
  - Hand-patching the generated Dart model — rejected; constitution §III forbids hand-editing generated files, and the change would have been silently lost on the next real regeneration.
  - Fetching the full `Product` per suggestion to get SKU — rejected; N detail fetches per keystroke is wasteful and defeats the list projection's purpose.
  - Dropping SKU from FR-003 entirely (an initially-considered resolution) — rejected on reconsideration; the requirement was legitimate, so the right fix was tracking the upstream dependency to resolution, not weakening the spec to match a temporary gap.

## 4. Photo thumbnails in the picker — extend vs. fork

- **Decision**: Extend the shared `CatalogEntityPicker<T>` with **optional** option-rendering hooks (a leading photo URL builder + a subtitle builder). When provided, the picker renders a custom `optionsViewBuilder` (Material `ListTile` with a `ProductPhoto`/thumbnail leading, name as title, code/model as subtitle); when omitted, it keeps today's text-only behavior. Backward compatible with the existing supplier and SAT-catalog pickers.
- **Rationale**: Constitution §VI mandates shared list/field widgets live in `core/widgets/` and behave identically across modules. The current `CatalogEntityPicker` uses Flutter's `Autocomplete` default option view (text only), which cannot show the photo FR-003 requires. A minimal optional extension keeps one shared widget rather than a catalog-only fork.
- **Alternatives considered**:
  - A dedicated `ProductMergePicker` in the feature — rejected; duplicates the debounce/enabled/clear logic and violates the "shared once" intent of §VI.
  - Text-only suggestions (no photo) — rejected; FR-003 explicitly requires the photo for visual confirmation, and the legacy screen showed it.

## 5. Route right — Create vs. the conventional Read

- **Decision**: Gate the `/products/merge` route, the products-list entry point, and the submit action on `can(SystemObject.productsMerge, AccessRight.create)`.
- **Rationale**: mbe-api enforces `require_privilege(SystemObject.PRODUCTS_MERGE, AccessRight.CREATE)` on the endpoint. The screen has no read-only mode — its only purpose is the create-gated action. Gating on Create keeps the client aligned with the server and never shows a screen the user cannot use. `SystemObject.productsMerge` already exists (value 73) in `core/access/system_object.dart:79`.
- **Implementation note**: `app_router.dart`'s `_routeSystemObject` maps any `/products*` prefix to `SystemObject.products` (Read). `/products/merge` must be matched **before** that generic rule and gated on `productsMerge`/Create. Because the shared `_redirect` currently hardcodes `AccessRight.read`, the merge route needs either a per-route right (extend `_routeSystemObject` to return a `(SystemObject, AccessRight)`) or a dedicated branch in `_redirect`. See `contracts/routes.md`.
- **Alternatives considered**: Gating the route on `productsMerge`/Read and only the submit on Create — rejected; a user with Create-but-not-Read (bitmasks are not guaranteed cumulative) would be blocked from a screen they're entitled to use, and a Read-but-not-Create user would reach a screen that always fails on submit.

## 6. Confirmation & error handling patterns

- **Decision**: Reuse the product-delete confirmation pattern — an inline `showDialog<bool>` + `AlertDialog` with an error-colored confirm action stating permanence (there is no shared confirm widget). Surface merge failures via the shared `error_banner`, mapping `DioException` through the existing `mapDioException`/`_toAppError` chain.
- **Rationale**: `product_detail_screen.dart:484` already implements exactly this dialog shape for the hard delete (`deleteProductConfirm*` keys). `mapDioException` (`auth_interceptor.dart:41`) maps 404→`NotFoundError(detail)`, 422→`ValidationError`, and everything else (incl. the 400 self-merge) →`ServerError(statusCode, message)` carrying mbe-api's `{"detail": …}` string — so the backend's "Cannot merge a product with itself" / "…not found" messages are displayable. Client-side guards make 400/404 backstops, not primary paths.
- **Alternatives considered**: Building a new shared confirm dialog widget — reasonable future cleanup but out of scope here; matching the established inline pattern keeps the diff small and consistent.

## 7. Post-success navigation

- **Decision**: On `204`, show a success confirmation (SnackBar) and `pop`/`go` back to `/products`; do not keep selections. (spec Clarifications.)
- **Rationale**: A merge is a rare, deliberate cleanup; leaving the screen pre-filled invites an accidental second destructive action against stale ids (the duplicate no longer exists). Returning to the list also lets the user immediately verify the duplicate is gone (US1 #2).
- **Alternatives considered**: Staying on the screen with cleared fields — rejected as lower-safety and not matching the legacy one-merge-per-visit flow.
