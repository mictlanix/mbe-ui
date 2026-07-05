# Contract: Products API — V2 Shape (005-catalog-master-data)

Describes the **changed** request/response shapes introduced by mbe-api commits
`4aba888` (FK expansion) and `2a1f309` (label assignment). The unchanged endpoints
(`DELETE`, `/merge`, `/image`) are unchanged; see `002-product-catalog/contracts/`.

---

## `GET /api/v1/products` — List Products

**New query parameter**:

| Param | Type | Default | Notes |
|---|---|---|---|
| `label` | `int` | — | Filter to products carrying this label id |

**Unchanged parameters**: `search`, `deactivated`, `stockable`, `salable`, `purchasable`, `skip`, `limit`.

**Response item** (`ProductListItem`) — changed fields:

| Field | Old | New |
|---|---|---|
| `unit_of_measurement` | `string` (SAT code) | `SatUnitOfMeasurementResponse` object |

`SatUnitOfMeasurementResponse`:

```json
{
  "id": "KGM",
  "name": "kilogram",
  "description": "A unit of mass equal to 1000 grams.",
  "symbol": "kg"
}
```

---

## `GET /api/v1/products/{product_id}` — Get Product Detail

**Response** (`ProductResponse`) — changed fields:

| Field | Old | New |
|---|---|---|
| `unit_of_measurement` | `string` (SAT code) | `SatUnitOfMeasurementResponse` object |
| `key` | `string \| null` (SAT code) | `SatCatalogResponse \| null` |
| `supplier` | `int \| null` (id) | `SupplierResponse \| null` |
| `labels` | *(absent)* | `LabelResponse[]` |

`SatCatalogResponse`:

```json
{ "id": "43211507", "description": "Laptops" }
```

`SupplierResponse` (relevant fields):

```json
{ "supplier_id": 3, "code": "SUP001", "name": "Aceros del Norte", ... }
```

`LabelResponse`:

```json
{ "label_id": 7, "name": "Featured", "comment": null }
```

Each `ProductPriceResponse.price_list` is now a `PriceListResponse` object instead of a bare `int`:

```json
{ "price_list_id": 1, "name": "Retail", "high_profit_margin": "0.3000", "low_profit_margin": "0.1500" }
```

---

## `POST /api/v1/products` — Create Product

**Request body** (`ProductCreate`) — new fields:

| Field | Type | Required | Notes |
|---|---|---|---|
| `supplier` | `int` | No | Supplier id |
| `key` | `string` | No | SAT product/service code (max 8 chars) |
| `labels` | `int[]` | No | List of label ids to assign; omit or `[]` for none |

---

## `PUT /api/v1/products/{product_id}` — Update Product

**Request body** (`ProductUpdate`) — new fields:

| Field | Type | Notes |
|---|---|---|
| `supplier` | `int \| null` | Set to remove supplier assignment |
| `key` | `string \| null` | Set to remove SAT key |
| `labels` | `int[]` | Replaces the product's full label set when present; omit to leave labels unchanged |
