# Phase 0 Research: Product Catalog (Products CRUD)

All items below were resolved by inspecting mbe-api's actual source
(sibling repo `mictlanix/mbe-api`) and the generated OpenAPI client already
committed in this repo. No `NEEDS CLARIFICATION` markers remain in the
Technical Context.

## 1. mbe-api `products` contract (confirmed against source + generated client)

**Decision**: Build against the live `products` endpoints already exposed by
mbe-api (`app/api/v1/endpoints/products.py`) and already codegen'd into
`lib/generated/openapi/lib/src/api/products_api.dart`:

- `GET /api/v1/products` — query params `search`, `label`, `deactivated`,
  `stockable`, `salable`, `purchasable`, `skip`, `limit` (default 20, max
  100) → `ListResponse[ProductListItem]` (`items`, `total`).
- `POST /api/v1/products` — `ProductCreate` → `201 ProductResponse`.
- `GET /api/v1/products/{product_id}` → `ProductResponse` or `404`.
- `PUT /api/v1/products/{product_id}` — `ProductUpdate` (all fields
  optional, includes `deactivated`) → `ProductResponse` or `404`.
- `DELETE /api/v1/products/{product_id}` → `204` (hard-deletes the row;
  see Decision 2 below — the spec's soft-delete requirement is satisfied
  by `PUT .../{id}` with `deactivated: true`, not by calling `DELETE`).
- `POST /api/v1/products/merge` — gated server-side by
  `SystemObject.PRODUCTS_MERGE` + `AccessRight.CREATE`; out of scope (see
  spec.md Assumptions).
- `POST /api/v1/products/{product_id}/image` — gated server-side by
  `SystemObject.PRODUCTS` + `AccessRight.UPDATE`; out of scope for this
  feature (spec.md explicitly defers photo upload), tracked separately in
  mbe-api's own `specs/003-product-image-upload`.

**Rationale**: avoids re-deriving a contract mbe-api already implements and
has already been codegen'd against; `ProductCreate`/`ProductUpdate`/
`ProductListItem`/`ProductResponse` field sets match the legacy
`Product.cs` constraints documented in `mbe/docs/specs/01-master-data.md`
(code 1–25 chars no whitespace, name 4–250 chars, EAN-13 barcode), enforced
server-side via Pydantic validators in `app/schemas/product.py`.

**Important gap found**: unlike `merge` and `image`, the core
`list/create/get/update/delete` endpoints are gated only by
`get_current_user` (any authenticated user), **not** by
`require_privilege(SystemObject.PRODUCTS, ...)`. The spec's deny-by-default
requirement (FR-012, FR-013, SC-004) is therefore enforced **client-side
only** for this feature — `AccessControlService.can(SystemObject.products,
...)` gates UI actions and routes, matching the pattern already used by
other features pending full server-side enforcement. This is a known,
pre-existing mbe-api gap (not introduced by this feature) and is called out
here so it isn't mistaken for a client bug; closing it is an mbe-api
follow-up, not part of this plan.

**Alternatives considered**: waiting for mbe-api to add
`require_privilege(SystemObject.PRODUCTS, ...)` before building the client
— rejected, the client-side gate still satisfies the spec's user-facing
acceptance criteria (FR-012/013) and server-side hardening can land
independently without a client change.

## 2. Soft delete vs. hard delete

**Decision**: The "Deactivate" action in this feature (spec.md User Story 4)
calls `PUT /api/v1/products/{product_id}` with `{"deactivated": true}`, not
`DELETE /api/v1/products/{product_id}`. The generated client's
`deleteProductApiV1ProductsProductIdDelete` is **not** wired to any UI
action in this feature.

**Rationale**: matches the legacy soft-delete business rule (spec.md
Assumptions — "no hard-delete action") and mbe-api's actual
`product_service.delete_product` behavior must be re-checked before any
future feature considers exposing hard delete; for this feature, the
`ProductUpdate.deactivated` field is the only mechanism used, consistent
with FR-010/FR-011.

**Alternatives considered**: exposing a true delete action mapped to the
`DELETE` endpoint — rejected, contradicts the spec's explicit soft-delete
requirement and the referential-integrity rationale in spec.md Assumptions.

## 3. OpenAPI client generation tooling

**Decision**: Reuse the existing `tool/generate_api_client.sh` /
`openapi-generator-cli` (`dart-dio` generator) pipeline established by the
auth feature (specs/001-user-authentication/research.md §2). The `products`
and `price-lists`-adjacent (`PriceListResponse`/`ProductPriceResponse`, read
within `ProductResponse.prices`) models are already present in
`lib/generated/openapi/` from a prior codegen run against mbe-api's current
`/openapi.json`; this feature should re-run the script once to confirm the
checked-in client is current before building the repository layer, per
constitution §III ("Codegen MUST be re-run whenever mbe-api's OpenAPI spec
changes").

**Rationale**: no new tooling decision needed; this feature is a consumer
of the same codegen pipeline, not a new integration point.

**Alternatives considered**: none — constitution §III already mandates this
approach.

## 4. Feature module placement

**Decision**: Place this feature under `lib/features/catalog/`, not
`lib/features/products/`.

**Rationale**: constitution §I explicitly calls out "a shared
`master_data`/`catalog` module for entities used across features" for
entities like Product that sales, inventory, and purchasing will all
reference. `Product` (and its read-only `ProductPrice`/`PriceListResponse`
projections) is exactly this kind of shared entity — keeping it in
`catalog/` from the start avoids a later move/rename when `sales` or
`inventory` features need to reference `Product` for order lines or stock
records.

**Alternatives considered**: `lib/features/products/` (feature-per-resource,
matching the auth feature's `lib/features/auth/`) — rejected per
constitution §I's explicit naming of `catalog` as the home for
cross-feature entities; `auth`/`users` were a reasonable exception because
session/RBAC entities are consumed via `core/access/`, not via the `auth`
feature folder itself.

## 5. Pagination strategy

**Decision**: Server-side offset pagination via `skip`/`limit` (already
supported by `GET /products`, default 20/max 100), surfaced in the UI as
infinite-scroll/"load more" within the existing `DataTableView` widget
(`lib/core/widgets/data_table_view.dart`), rather than a new pagination
widget.

**Rationale**: matches the API contract exactly (no client-side filtering
of an unbounded list) and satisfies spec.md's edge case on large catalogs
without inventing a new UI pattern.

**Alternatives considered**: fetching the full catalog client-side and
paginating in-memory — rejected, doesn't scale and ignores the API's
existing `skip`/`limit`/`total` contract.

## 6. Search/filter field mapping

**Decision**: The list screen's search box maps to the single `search` query
param (server-side searches code/name/brand/model per
`product_service.list_products`, confirmed against
`mbe/docs/specs/01-master-data.md` §1 "Search by: name, code, model, SKU,
brand" — note mbe-api's current implementation may not yet include `sku`;
treat as a search-relevance detail owned by the backend, not the client).
Filter chips map 1:1 to `deactivated`, `stockable`, `salable`, `purchasable`
booleans and `label` (int id, deferred — see spec.md Assumptions on Label
administration being out of scope; the filter itself can still be wired if
a label picker is trivially available, otherwise deferred to a follow-up).

**Rationale**: avoids inventing client-side search/filter logic that
duplicates what the server already does.

**Alternatives considered**: client-side substring filtering after fetching
a page — rejected, contradicts Decision 5 (server-side pagination) since
filtering only the current page would silently miss matches on other
pages.
