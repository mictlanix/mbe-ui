# Phase 1 Data Model: Product Catalog (Products CRUD)

Domain entities live in `lib/features/catalog/domain/entities/` (per
research.md §4 — `catalog` is the constitution's named shared module for
cross-feature master data), as immutable `freezed` classes mapped from the
generated OpenAPI DTOs in `lib/generated/openapi/` (see
[contracts/mbe-api-products.md](contracts/mbe-api-products.md)). No entity
here is persisted locally (constitution §VII).

`Product` is deliberately placed in `features/catalog/domain/`, not
`core/`, because — unlike `User`/`Privilege` in the auth feature — nothing
in `core/` consumes it directly; `core/access` only needs `SystemObject.
products` (already present) to gate routes/actions. Other features (sales,
inventory) will import `Product` from `catalog` when they need it, per
constitution §I's repository-interface boundary.

## Product (`lib/features/catalog/domain/entities/product.dart`)

Maps from `ProductResponse` (read) / `ProductCreate` (create) /
`ProductUpdate` (edit, all fields optional) per
contracts/mbe-api-products.md.

| Field | Type | Notes |
|---|---|---|
| `productId` | `int` | Server-assigned; absent on create. |
| `code` | `String` | Required. No whitespace, 1–25 chars, unique across all products (incl. disabled). FR-004, FR-005. |
| `name` | `String` | Required. 4–250 chars. FR-006. |
| `photo` | `String?` | Out of scope to edit in this feature (research.md §1); read-only display if present. |
| `sku` | `String?` | Manufacturer SKU, free text. |
| `brand` | `String?` | Free text. |
| `model` | `String?` | Free text. |
| `barCode` | `String?` | Empty or exactly 13 digits (EAN-13). FR-007. |
| `location` | `String?` | Bin/shelf location, free text. |
| `unitOfMeasurement` | `String` | Required. Free-text code in current contract (no FK picker UI in this feature — rendered as a text field; see Assumptions below). |
| `key` | `String?` | SAT product key; out of scope for required validation, optional field. |
| `taxRate` | `Decimal` (modeled as `double` or string-backed decimal per existing project convention) | Defaults server-side; editable. |
| `taxIncluded` | `bool` | Defaults server-side. |
| `priceType` | `int?` | Legacy enum (`Fixed`/`Variable`); out of scope to expose as a rich picker — editable as the raw legacy int with a small enum mapping in `presentation/`, not modeled as a `domain` enum unless mbe-api publishes named values. |
| `currency` | `int` | Defaults to `0` server-side. |
| `minOrderQty` | `int` | Server-defaulted to `1` on create; editable thereafter. |
| `supplier` | `int?` | Default-supplier FK id; out of scope to resolve to a name/picker in this feature (no supplier-catalog dependency) — stored/edited as a raw id if shown at all. |
| `stockable` | `bool` | |
| `perishable` | `bool` | |
| `seriable` | `bool` | |
| `purchasable` | `bool` | |
| `salable` | `bool` | |
| `invoiceable` | `bool` | |
| `stockRequired` | `bool` | Maps from `stock_verification` alias server-side (research.md, contracts). |
| `deactivated` | `bool` | The soft-delete flag (FR-010, FR-011). `false` by default on create (FR-015). |
| `comment` | `String?` | Free text notes. |
| `prices` | `List<ProductPrice>` | Read-only projection of `product_price` rows; displayed, not edited, in this feature (price-list administration is out of scope per spec.md Assumptions). |

**Validation** (client-side, mirroring server-side Pydantic validators so
the form fails fast before a round-trip):
- `code`: non-empty, no whitespace, length 1–25.
- `name`: length 4–250.
- `barCode`: empty string/`null`, or exactly 13 digits.

**State transitions**: `deactivated: false → true` (Deactivate action,
FR-010) via `PUT` with a partial `ProductUpdate`. There is no
`true → false` "reactivate" action specified by this feature (not in any
user story); if a future need arises it is the same `PUT` call with
`deactivated: false` and can be added without a data-model change.

## ProductPrice (`lib/features/catalog/domain/entities/product_price.dart`)

Read-only projection of `ProductPriceResponse`, displayed as a sub-section
of the product detail screen (spec.md Assumptions).

| Field | Type | Notes |
|---|---|---|
| `productPriceId` | `int` | |
| `priceList` | `int` | FK id to `price_list`; this feature does not resolve it to a name (no `PriceLists` API call) — shown as-is or, if trivially available, joined client-side from a cached list if another in-progress feature already fetches it. Otherwise deferred. |
| `price` | `Decimal` | |
| `lowProfit` | `Decimal` | |
| `highProfit` | `Decimal` | |

## ProductListItem (`lib/features/catalog/domain/entities/product_list_item.dart`)

Maps from `ProductListItem` (the list-row projection, distinct from the
full `Product` detail entity — mirrors the API's own split).

| Field | Type | Notes |
|---|---|---|
| `productId` | `int` | |
| `code` | `String` | |
| `name` | `String` | |
| `brand` | `String?` | |
| `model` | `String?` | |
| `unitOfMeasurement` | `String` | |
| `taxRate` | `Decimal` | |
| `deactivated` | `bool` | Drives the "inactive" badge in the list (FR-002, User Story 4 acceptance scenario 2). |

## ProductFilter (`lib/features/catalog/presentation/products_controller.dart` or co-located state file)

Not a `freezed` domain entity mapped from the API — local UI state
(constitution §II, "local UI state... MUST use plain `Notifier`/
`StateProvider`") representing the current list screen's search/filter
selection, translated 1:1 into `GET /products` query params
(research.md §6).

| Field | Type | Notes |
|---|---|---|
| `search` | `String?` | Free-text query. |
| `deactivated` | `bool?` | `null` = no filter (server default already excludes none unless specified — confirm against contracts/mbe-api-products.md); `false` = active only; `true` = disabled only. |
| `stockable` / `salable` / `purchasable` | `bool?` | Tri-state filters. |
| `label` | `int?` | Deferred per research.md §6 unless a label picker is trivially available. |
| `skip` / `limit` | `int` | Pagination cursor (research.md §5). |
