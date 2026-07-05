# Contract: Master-Data Picker Endpoints (005-catalog-master-data)

Read-only endpoints consumed by the new form pickers and label filter.
All require a valid bearer token (`Authorization: Bearer <token>`).
All return `{ "items": [...], "total": int }`.

---

## Suppliers

### `GET /api/v1/suppliers`

| Param | Type | Notes |
|---|---|---|
| `search` | `string` | Matches `code`, `name`, `zone` |
| `skip` | `int` | Default 0 |
| `limit` | `int` | Default 20, max 100 |

**Item shape** (`SupplierResponse`):

```json
{ "supplier_id": 3, "code": "SUP001", "name": "Aceros del Norte", "zone": null, "credit_limit": "0.0000", "credit_days": 0, "comment": null }
```

**Display in picker**: `"SUP001 — Aceros del Norte"`
**Submitted value**: `supplier_id` (int) as `supplier` in `ProductCreate`/`ProductUpdate`

---

## SAT Units of Measurement

### `GET /api/v1/sat/units-of-measurement`

| Param | Type | Notes |
|---|---|---|
| `search` | `string` | Matches code, name, or description |
| `skip` | `int` | Default 0 |
| `limit` | `int` | Default 20, max 100 |

**Item shape** (`SatCatalogResponse` on the generic endpoint, `SatUnitOfMeasurementResponse` when embedded in product):

```json
{ "id": "KGM", "description": "kilogram" }
```

**Display in picker**: `"KGM — kilogram"`
**Submitted value**: `id` (string) as `unit_of_measurement` in `ProductCreate`/`ProductUpdate`

---

## SAT Product/Service Keys

### `GET /api/v1/sat/product-services`

| Param | Type | Notes |
|---|---|---|
| `search` | `string` | Matches code or description |
| `skip` | `int` | Default 0 |
| `limit` | `int` | Default 20, max 100 |

**Item shape**:

```json
{ "id": "43211507", "description": "Laptops" }
```

**Display in picker**: `"43211507 — Laptops"`
**Submitted value**: `id` (string) as `key` in `ProductCreate`/`ProductUpdate`

---

## Labels

### `GET /api/v1/labels`

| Param | Type | Notes |
|---|---|---|
| `search` | `string` | Matches `name` |
| `skip` | `int` | Default 0 |
| `limit` | `int` | Default 100 (all loaded at once for multi-picker) |

**Item shape**:

```json
{ "label_id": 7, "name": "Featured", "comment": null }
```

**Used for**: `LabelMultiPicker` on product form (selection → `label_id` list in `ProductCreate`/`ProductUpdate.labels`), and label filter dropdown on products list (selection → `?label=<label_id>`).
