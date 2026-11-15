# For delivery queue ("Por entregar")

## Summary

Once a delivery order is confirmed (and approved, where required) it sits in En preparación until its goods are loaded onto a truck. Until now nothing in the new app showed warehouse staff what is waiting to go out. This PR adds the queue.

- **Queue** in the Logística nav group, right after Aprobación de entregas. It lists every delivery line still waiting to be loaded, highest priority first, with folio, customer, ship-to, scheduled date, priority, product, warehouse and the quantity still open.
- **Period filter.** The legacy screen's date tabs are a single-select "Periodo" in the shared filter panel: Anteriores, Ayer, Hoy, Mañana, Pasado mañana, Posteriores. Hoy is the default. Each option shows its line count (and its date, for the single-day ones), kept while a newly picked period loads. The period and page live in the URL.
- **Row tap** opens the spec 061 order screen, and the queue reloads on return, on the same period and page.
- **Read-only.** No actions, and no search box (the server has none for this queue).

Spec: `specs/063-for-delivery-queue/` (spec, wireframes, plan, research R1–R12, contracts C1–C9, tasks).

## Roadmap

Closes mictlanix/mbe-roadmap#40

"Add to itinerary" from the legacy screen is deliberately not here: it goes with the itineraries feature (mictlanix/mbe-roadmap#41), which can add it to this queue. "Mark Picked Up" is gone because the server never lists pickups.

## Rights

| Right | What it gives |
|---|---|
| For Delivery (91) read | The nav entry, the route and the queue |
| Delivery Orders (71) read | A row tap opens the order. Without it, rows aren't tappable. |

Names (customer, ship-to, warehouse) need Customers and Warehouses read; without them the cell shows the number.

## Worth knowing

- **The queue spans every active facility,** as the legacy screen did. The server has no facility parameter for it, so scoping it to the user's facility would be an mbe-api change. Not filed.
- **Periods follow the server's date.** A screen left open past midnight shows yesterday's split until it reloads.
- **The server pages all six periods together** in one response; the app keeps the selected period's lines and the other five's totals.

## Also in this PR

- `DeliveryOrderShipTo`'s delivery branch is extracted into `DeliveryOrderCustomerAddress` (the queue's lines carry no facility). No visible change on the 061/062 screens.
- New `DeliveryItineraryRepository`, the start of the data layer roadmap#41 extends.
- `nav_destinations_test` now expects the new entry in Logística.

## Tests

- `flutter analyze`: no issues.
- `flutter test`: 4,647 passed, 76 skipped, 7 failed. The same 7 fail on main without this change (six `core_widgets_golden_test` goldens and the `pos_screens_screenshot_test` sales list). They are platform-rendering tests, tracked with the goldens in #209.
- New unit and widget tests cover: the repository's mapping (six buckets, null serial, ship-to and date, unknown bucket key); the filter's URL round trip; the controller (selected period only, summaries, the clamp judged on the selected period, no facility, summaries kept after a failed load); the screen (columns, "Sin fecha", `#id` fallbacks, empty on Hoy and on another period, error and retry, badge, the panel's counts and dates, picking a period and going to page 1, counts kept while loading, a page change keeping the period, row tap with and without Delivery Orders read, compact layout); the nav entry and the route gate.
- Live (`integration_test/for_delivery_quickstart_test.dart`, macOS, local mbe-api, read-only): 4 passed, 1 skipped. Passed: the nav entry; the panel's six counts match the API; picking a period with lines lists them with badge 1; a row opens its order and back returns to the same period. **Skipped: "Hoy lists the API's lines"**, because the local tenant has no line scheduled for today (only 2 lines, in Posteriores). The widget tests cover Hoy, but the live check of it hasn't run.

## Manual checks (quickstart.md)

**Not run yet**; tracked in #247:

- The compact tier and the filter bottom sheet on a real window.
- The largest text size.
- SC-001 (today's lines and every period's count within 5 seconds) and SC-005 (periods, order and remaining quantities against the legacy screen on the same data).
- Step 9: cancelling or approving an order, then returning to the queue.
- Hoy with real data: schedule a delivery order for today and check it.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
