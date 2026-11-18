# Contract: Error Messages (§III coverage)

These are the codes the three routes (`GET /stock`, `GET /stock/products/{product}`, `GET /kardex`) can return, measured from mbe-api's `stock.py`, `kardex.py`, `stock_query_service.py`, `kardex_service.py` and `warehouse_service.assert_sellable`.

## New codes (2)

Each is added to `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb` and `app_en.arb`, and its row in `specs/058-localized-api-errors/contracts/code-scope.tsv` becomes `IN` (coverage 163 → 165).

| Code | Params | es | en |
|---|---|---|---|
| `kardex.range_reversed` | — | La fecha final no puede ser anterior a la inicial. | The end date cannot be before the start date. |
| `kardex.range_too_long` | `max_days: int` | El rango no puede pasar de {max_days} días. | The range cannot exceed {max_days} days. |

The Kardex screen checks both conditions before calling, so these are a fallback. The client-side texts reuse the same wording, with 366 for the limit.

## Existing codes

| Code | Where |
|---|---|
| `warehouse.in_transit_location` | `GET /stock` with an in-transit warehouse |
| `resource.not_found` (`product`, `warehouse`) | an unknown product or warehouse |
| `auth.forbidden` | a missing right |
| `request.*` | parameter validation |
