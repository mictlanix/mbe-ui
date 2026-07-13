# Contract: `GET /api/v1/products/labels/facets` (mbe-api#78)

Mirrors [mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78). This is the external dependency; mbe-ui consumes it via generated client after it ships. Recorded here so the mbe-ui repository method, provider, and tests can be built against a stable shape.

## Request

`GET /api/v1/products/labels/facets`

Same filter query params as `GET /api/v1/products`, **without** pagination:

| Param | Type | Notes |
|-------|------|-------|
| `search` | `str?` | Matches `code\|name\|model\|sku\|brand` via `ilike`, identical to the list. |
| `label` | `int[]?` (repeatable) | AND ("contains all") — restricts the matching set to products carrying every given label. Includes the user's currently-selected labels. |
| `deactivated` | `bool?` | |
| `stockable` | `bool?` | |
| `salable` | `bool?` | |
| `purchasable` | `bool?` | |
| `supplier` | `int?` | Accepted for parity with the list; mbe-ui does not send it today. |
| ~~`skip` / `limit`~~ | — | **Not accepted** — the endpoint summarizes the whole matching set. |

## Response — `200 OK`

A plain array (minimal payload), one row per label present on ≥1 matching product:

```json
[
  { "label_id": 3, "count": 42 },
  { "label_id": 7, "count": 12 }
]
```

- `label_id` (`int`) — corresponds to `LabelResponse.label_id` / `LabelItem.labelId`.
- `count` (`int`, `> 0`) — number of matching products carrying that label.
- **Empty array** when no label co-occurs with the filter (e.g. the filtered set is empty, or matching products carry no labels).
- With selected labels present, each selected label appears with `count` == the current result-set size, alongside every co-occurring label. Labels **absent** from the array are the ones the drawer disables.

## Semantics that make the drawer correct

- The filter set **includes** the currently-selected `label` params, so under AND the response is exactly "labels reachable by narrowing the current results further" — plus the selected labels themselves. This is why selecting an enabled label can never yield an empty list (FR-005).

## Errors

- Standard mbe-api error envelope; mbe-ui maps via `mapDioException` → `AppError`. The provider **fails open** on any error (treats availability as absent → all chips enabled), so error surfacing here is non-blocking (FR-010).

## mbe-ui consumption

- Re-run `tool/generate_api_client.sh` after #78 ships → generated `ProductLabelFacet` model + facets API method.
- Map generated model → `ProductLabelFacet` domain entity (data-model.md).
- No `SystemObject` change (§IV) — this read rides on the existing products-list `Read` gate.
