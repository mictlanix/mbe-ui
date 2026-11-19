# Contract: Error Messages (§III coverage)

These are the codes the 15 itinerary routes and the order picker can return. They were measured from mbe-api's `app/services/delivery_itinerary_service.py`, `app/api/v1/endpoints/delivery_itineraries.py`, `app/services/image_service.py` and `app/core/errors.py` (research R13).

## New (add to `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb`, `app_en.arb`, `problem_fixtures.dart`; flip `code-scope.tsv` to `IN`)

| Code | Status | Params | Route | es |
|---|---|---|---|---|
| `itinerary.not_open` | 409 | `status` | header, stops, loads, depart, cancel | El itinerario ya no está abierto ({status}); no se puede modificar. |
| `itinerary.not_departed` | 409 | `status` | close stop, print | El itinerario aún no ha salido. |
| `itinerary.cancelled` | 409 | — | print | El itinerario está cancelado. |
| `itinerary.nothing_committed` | 409 | — | depart | No hay nada cargado en este itinerario. |
| `itinerary.lines_overcommitted` | 422 | dict `detail`: `lines` | depart | Estas partidas tienen cargado más de lo que queda por entregar: {lines}. |
| `itinerary.stop_already_resolved` | 409 | — | close stop | Esta parada ya se cerró. |
| `itinerary.stop_lines_incomplete` | 422 | — | close stop | Falta el resultado de alguna partida de la parada. |
| `itinerary.stop_lines_malformed` | 422 | — | close stop | El resultado de las partidas no es válido. |
| `itinerary.stop_delivered_exceeds_sent` | 422 | `line_id`, `sent`, `delivered` | close stop | {product}: se enviaron {sent} y se registran {delivered} entregados. |
| `itinerary.stop_shortfall_needs_reason` | 422 | `line_id` | close stop | {product}: indica el motivo de lo no entregado. |
| `vehicle.open_itinerary_exists` | 409 | `vehicle_id`, `itinerary_id` | create | Este vehículo ya tiene abierto el itinerario {itinerary_id}. |
| `delivery_order.not_in_preparation` | 409 | `status` | add stop, load | La orden de entrega está en {status}; solo se cargan órdenes en preparación. |
| `delivery_order.pickup_not_loadable` | 409 | — | add stop | Una orden para recoger en tienda no se carga en un itinerario. |
| `delivery_order_line.nothing_to_load` | 422 | — | load | Esta partida ya no tiene nada por cargar. |
| `delivery_order_line.quantity_unavailable` | 422 | `available`, `requested` | load, adjust | Pediste cargar {requested}, pero solo hay {available} disponibles. |

- `{status}` uses the `ItineraryStatus` labels (new) or the `DeliveryOrderStatus` labels (061).
- `{product}` and `{lines}` resolve each line id to its product name from the loaded trip, falling back to the number (research R13).
- Quantities go through `formattersProvider`.
- These codes join `needParams` in `catalog_coverage_test.dart`: `quantity_unavailable`, `stop_delivered_exceeds_sent`, `stop_shortfall_needs_reason`, `vehicle.open_itinerary_exists` and `not_in_preparation`. A missing param falls back to the generic message (§III resilience).
- `catalog_coverage_test.dart`: `expect(checked, 191)` → `206`.

## Resources (`resource.not_found` nouns)

| Resource | es (singular / plural) | Gender |
|---|---|---|
| `delivery_itinerary` | itinerario / itinerarios (it exists for `resource.still_referenced`; add the `resource.not_found` row) | m |
| `delivery_itinerary_stop` | parada / paradas (new) | f |
| `delivery_itinerary_line` | partida del itinerario / partidas del itinerario (new) | f |

## Already localized, reused

| Code | Where it arises |
|---|---|
| `resource.not_found` | unknown trip, stop, line, vehicle or delivery order |
| `auth.forbidden` | missing right |
| `facility.no_in_transit_location` | depart, close stop |
| `image.too_large`, `image.unsupported_format` | close stop |
| `lock.busy` | close stop (`facility` / `warehouse`) |

## As built (2026-11-19)

Three departures from the table above, all simplifications:
- `itinerary.not_open`, `itinerary.not_departed` and `delivery_order.not_in_preparation` are fixed sentences without `{status}`. `localizeProblem` lives in `core/` and can't reach the features' status labels. The status is visible on the screen anyway.
- `itinerary.stop_delivered_exceeds_sent` and `itinerary.stop_shortfall_needs_reason` name the line as "Partida {line_id}", not by product: `localizeProblem` takes no lookup. The close dialog checks both cases before sending, so the server's refusal is rare.
- `itinerary.lines_overcommitted` shows its headline, followed by the line ids from `detail.lines`.

So `needParams` gains four codes, not five: `not_in_preparation` is a fixed sentence. The `delivery_itinerary` noun is now "itinerario" (masculine), no longer "ruta de entrega".
