# Contract: mbe-api `products` endpoints

Source of truth: mbe-api `app/api/v1/endpoints/products.py` +
`app/schemas/product.py` (sibling repo `mictlanix/mbe-api`), already
codegen'd into `lib/generated/openapi/lib/src/api/products_api.dart`. This
file documents the subset this feature consumes; see research.md §1 for how
it was confirmed.

## Endpoints used by this feature

| Method | Path | Generated client method | Request | Response | Used by |
|---|---|---|---|---|---|
| GET | `/api/v1/products` | `listProductsApiV1ProductsGet` | query: `search`, `label`, `deactivated`, `stockable`, `salable`, `purchasable`, `skip`, `limit` | `ListResponse[ProductListItem]` | User Story 1 (browse/search/filter) |
| POST | `/api/v1/products` | `createProductApiV1ProductsPost` | `ProductCreate` | `201 ProductResponse` | User Story 2 (create) |
| GET | `/api/v1/products/{product_id}` | `getProductApiV1ProductsProductIdGet` | path: `product_id` | `ProductResponse` or `404` | User Story 1 (detail view), User Story 3 (load for edit) |
| PUT | `/api/v1/products/{product_id}` | `updateProductApiV1ProductsProductIdPut` | path: `product_id`, body: `ProductUpdate` (partial) | `ProductResponse` or `404` | User Story 3 (edit), User Story 4 (deactivate via `{"deactivated": true}`) |

## Endpoints explicitly NOT used by this feature

| Method | Path | Reason |
|---|---|---|
| DELETE | `/api/v1/products/{product_id}` | Hard-delete; contradicts the spec's soft-delete requirement (research.md §2). Not wired to any UI action. |
| POST | `/api/v1/products/merge` | Gated by a separate `SystemObject.PRODUCTS_MERGE` (73); out of scope (spec.md Assumptions). |
| POST | `/api/v1/products/{product_id}/image` | Photo upload explicitly deferred (spec.md Assumptions); tracked in mbe-api's own `specs/003-product-image-upload`. |

## Server-side RBAC gating (as currently implemented)

| Endpoint | Server-side gate |
|---|---|
| `GET /products`, `POST /products`, `GET /products/{id}`, `PUT /products/{id}` | `get_current_user` only — **no** `require_privilege` check today (research.md §1 gap). |
| `POST /products/merge` | `require_privilege(SystemObject.PRODUCTS_MERGE, AccessRight.CREATE)` |
| `POST /products/{id}/image` | `require_privilege(SystemObject.PRODUCTS, AccessRight.UPDATE)` |

This feature's client MUST still gate create/update/deactivate actions via
`AccessControlService.can(SystemObject.products, ...)` (constitution §IV) —
the absence of server-side enforcement on the core CRUD endpoints today is
a pre-existing mbe-api gap, not a reason to skip the client-side gate.

## Field validation enforced server-side (Pydantic, `app/schemas/product.py`)

| Field | Rule |
|---|---|
| `code` | `min_length=1, max_length=25`; no whitespace (`_validate_code`) |
| `name` | `min_length=4, max_length=250` |
| `bar_code` | empty or exactly 13 digits (`_validate_bar_code`) |

The client SHOULD mirror these in form validation (data-model.md) to fail
fast, but the server remains the authority — a `422` response must still be
mapped to `ValidationError` and surfaced per constitution §III.

## Response field notes

- `ProductResponse.stock_required` is populated from the server's
  `stock_verification` column via a Pydantic alias
  (`Field(alias="stock_verification")`); the generated Dart model already
  reflects the public `stock_required` JSON key, so no special handling is
  needed client-side.
- `ProductResponse.prices: list[ProductPriceResponse]` is read-only in this
  feature (data-model.md `ProductPrice`).
- `ProductListItem` is a distinct, smaller projection from `ProductResponse`
  — the list screen must request/use `ProductListItem`, not fetch full
  `ProductResponse` per row.
