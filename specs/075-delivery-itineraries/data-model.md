# Data Model: Delivery Itineraries (spec 075)

Domain entities (`freezed`) in `lib/features/sales/domain/entities/delivery_itinerary.dart`, mapped from the generated DTOs in `data/` (§III). The fields marked **#343** stay null until mbe-api#343 ships and the client is regenerated. Until then they are filled by the fallbacks in research R2–R3, or left null.

## Enums

| Domain | Wire (int) | es | en |
|---|---|---|---|
| `ItineraryStatus.open` | 0 | Abierto | Open |
| `ItineraryStatus.departed` | 1 | En ruta | On the road |
| `ItineraryStatus.closed` | 2 | Cerrado | Closed |
| `ItineraryStatus.cancelled` | 3 | Cancelado | Cancelled |
| `StopOutcome.pending` | 0 | Pendiente | Pending |
| `StopOutcome.delivered` | 1 | Entregada | Delivered |
| `StopOutcome.partiallyDelivered` | 2 | Entregada parcialmente | Partially delivered |
| `StopOutcome.failed` | 3 | Fallida | Failed |
| `ShortfallReason.customerRefused` | 0 | Cliente rechazó | Customer refused |
| `ShortfallReason.nobodyPresent` | 1 | No había nadie | Nobody there |
| `ShortfallReason.wrongAddress` | 2 | Dirección incorrecta | Wrong address |
| `ShortfallReason.damagedGoods` | 3 | Mercancía dañada | Damaged goods |
| `ShortfallReason.other` | 4 | Otro | Other |

The mapping is exhaustive. An unknown wire value maps to a server error, as the 072 status mapper does.

## Entities

**ItinerarySummary** (list row): `id`, `date`, `vehicleId?`, `vehicleOperatorId?`, `warehouseId?`, `status`, `departedAt?`, `returnedAt?`, plus `vehicleName?`, `operatorName?` and `warehouseName?` (**#343**).

**ItineraryPage**: `items: List<ItinerarySummary>`, `total`.

**Itinerary** (trip screen): the summary fields plus `comment?` and `stops: List<ItineraryStop>` ordered by `sequence`. Derived:
- `loadedLineCount`: the lines across all stops.
- `emptyStops`: stops with no lines (R7).
- `canDepart`: `status == open && loadedLineCount > 0 && emptyStops.isEmpty`.
- `pendingStops`: stops with `outcome == pending`.

**ItineraryStop**: `id`, `sequence`, `outcome`, `arrivedAt?`, `proofId?`, `comment?`, `lines: List<ItineraryLine>`, plus `deliveryOrderId?`, `customerName?` and `shipToLabel?` (**#343**, else R2).

**ItineraryLine**: `id`, `deliveryOrderLineId`, `committed`, `sent`, `delivered`, `returned` (all `Decimal`), `reason?: ShortfallReason`, `comment?`, plus `deliveryOrderId?`, `productCode?`, `productName?` and `unitSymbol?` (**#343**, else R2 except the unit).

**StopClosure** (a value object, the close dialog's output): `receiverName`, `receiverIdShown` (both trimmed, not blank), `lines: List<StopClosureLine>`, and `proof: ProofImage`.
- **StopClosureLine**: `lineId`, `delivered` (0 ≤ delivered ≤ sent), and `reason?`, required when delivered < sent.
- **ProofImage**: `bytes`, `filename` (`firma.png` for a drawn signature).

## State transitions (server-owned; the app shows what comes back)

```
open ──depart──► departed ──(last pending stop closed)──► closed
  └──cancel──► cancelled
stop: pending ──close──► delivered | partiallyDelivered | failed
```

## Action availability

| Action | Trip status | Stop | Right (SystemObject 87) |
|---|---|---|---|
| Nuevo itinerario | n/a | n/a | create |
| Edit header (date, vehicle, operator, comment) | open | n/a | update |
| Agregar parada, Quitar parada | open | n/a | update |
| Cargar todo, Cargar línea, ✎ quantity, 🗑 release | open | order known (R2) | update |
| Dar salida | open, `canDepart` | n/a | update |
| Cancelar itinerario | open | n/a | update |
| Cerrar parada | departed | pending | update |
| Imprimir ticket, Imprimir notas de entrega | departed, closed | n/a | read |
| Open order link | any | order known | Delivery Orders (71) read |

A user without the right doesn't see the action (§IV). A disabled state is used only for Dar salida's guard, and its reason is shown.

## Validation (client side, mirrors the server)

- Load quantity: 0 < q ≤ open. Adjust: 0 < q ≤ open + already loaded.
- Close line: 0 ≤ delivered ≤ sent. A reason is required when delivered < sent.
- Proof image: jpg, jpeg or png, at most 2 MB. Signature: at least one stroke.
- Receiver name and ID shown: not blank after trimming.
