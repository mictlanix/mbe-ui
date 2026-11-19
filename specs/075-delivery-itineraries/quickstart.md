# Quickstart: Delivery Itineraries (spec 075)

A walkthrough that proves the feature end to end against the dev mbe-api.

## Prerequisites

- mbe-api running locally at or after mbe-api#344 (#343), with migration 036 applied (done on mbe_dev 2026-11-18). The client is already regenerated (a8290511).
- `.env` with the dev tenant's admin account (see the memory on dev tenant accounts). A non-admin with Delivery Itineraries read only (`qareadonly`) for the rights check.
- Two delivery-type orders in **En preparación** at the admin's facility, each with two lines:
  - create the sales with delivery destinations in the POS;
  - confirm them on "Órdenes de entrega" (061);
  - approve them if approval is on (062).
- One vehicle, and one operator whose licence has expired (edit the expiry in Vehículos / Operadores).
- A jpg or png under 2 MB.

## Walkthrough

1. **Nav and rights**: As admin, Logística shows "Itinerarios" after "Por entregar". As `qareadonly`, it shows, but there's no "Nuevo itinerario" and no edit action anywhere. As `qanoaccess`, it doesn't show.
2. **Create**: Tap "Nuevo itinerario", pick the vehicle and the expired-licence operator, and leave the warehouse blank. The trip opens as Abierto with today's date, the point of sale's warehouse, and the licence warning.
3. **Same vehicle twice**: Create another trip with the same vehicle. The dialog stays open with "Este vehículo ya tiene abierto el itinerario N."
4. **Stops and loading**: "Agregar parada" → order A, then "Cargar todo". "Agregar parada" → order B, then "Cargar línea" → its first line at half the open quantity. Order B's other line isn't loaded. "Por entregar" now shows B's remainder.
5. **Adjust and release**: ✎ B's line up to its open + loaded maximum. A larger value is refused in the field. 🗑 releases it, then load it again.
6. **Departure guard**: Add order C as a stop and don't load it. "Dar salida" is disabled with a caption naming stop 3. "Quitar parada" on stop 3 enables it.
7. **Depart**: Confirm "Dar salida". The trip shows En ruta with its departure time and the sent quantities. Orders A and B show En tránsito on their 061 screens. No edit, stop or load action remains.
8. **Print**: "Imprimir ticket" and "Imprimir notas de entrega" each open the preview.
9. **Close stop 1 with an image**: Enter the receiver and ID, keep everything delivered, and upload the image. The stop shows Entregada. Order A shows Entregada, and its proof is on the 061 screen.
10. **Close stop 2 with a signature and a shortfall**: Enter delivered below sent with no reason. Confirm is disabled until "Mercancía dañada" is picked. Draw a signature, then confirm. The stop shows Entregada parcialmente with returned quantities. The trip shows **Cerrado** with its return time without a reload. Order B shows Entregada parcialmente, and a child order with the remainder exists.
11. **Reload**: Reload the trip in a fresh session. The stops still show folio, customer, ship-to, products and units, and the list rows show vehicle, operator and warehouse names.
12. **Cancel**: Create a trip, load something, and cancel it. It shows Cancelado, the order's open quantity is back, and print isn't offered.
13. **Largest text size**: At the largest text level, the trip screen and the close dialog don't clip or overflow at 1280 px.

## Automated checks

- `flutter test test/unit/features/sales/ test/widget/features/sales/ test/unit/core/errors/`: all pass, including `catalog_coverage_test` at 206.
- `MBE_WRITE=true flutter test test/integration/delivery_itineraries_live_test.dart`: steps 2–10 and 12 against the live server, including both proof kinds (R12).
- `caffeinate -dimsu flutter test integration_test/delivery_itineraries_quickstart_test.dart -d macos`: the device walkthrough.
