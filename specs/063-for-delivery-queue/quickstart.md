# Quickstart: For Delivery Queue

**Feature**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md)

This guide proves the feature end to end against the dev tenant.

## Prerequisites

- **Backend.** mbe-api running with spec 012 US3 (`GET /delivery-itineraries/deliveries`).
- **Accounts.** The admin account from `.env` (`MBE_POS_*`) has every right, including 91 and 71. Rights checks (step 6) use a role edited in Seguridad, or the widget tests.
- **Data.** At least one delivery order (not pickup) in En preparación with open lines. Spec 062's live runs left 30240 and 30242 on the local tenant. Otherwise: create a delivery in POS → Entrega, confirm it in Órdenes de entrega, and approve it if the server requires approval.
- **DB tunnel.** A stable tunnel, as for spec 061's live test.

## Automated

```sh
flutter analyze
flutter test test/unit/features/sales test/widget/features/sales
flutter test test/unit/core test/widget/core   # nav and router

# Live, read-only
flutter test integration_test/for_delivery_quickstart_test.dart -d macos
```

## Manual walkthrough

1. Sign in as admin. Logística shows "Por entregar" after "Aprobación de entregas". Open it.
2. The list shows today's lines with no filter badge. Columns match C4. The footer total matches the API's `today` total.
3. Open the filters. "Periodo" lists six options in order, with counts; the four single-day ones show their dates. Counts match the API response.
4. Pick a period holding a known order (e.g. the one 30240 falls in). The badge shows 1, the list shows its lines with their scheduled date, page 1. The URL carries `period=…`.
5. Tap a row. Order detail opens. Go back: same period and page, reloaded.
6. With a role lacking DeliveryOrders read: rows don't respond to a tap. With a role lacking ForDeliver read: no nav entry, and `/sales/for-delivery` redirects.
7. Pick a period with no lines: the empty message and "Borrar filtros". Use it: back to Hoy, no badge.
8. Type `?period=bogus` in the URL: the list shows Hoy.
9. Cancel an in-preparation order from its detail screen (or approve a new one), return: its lines are gone (or appear).
10. Narrow the window to compact: rows become cards without Destino; the filter panel opens as a bottom sheet.
11. Set text size to the largest level: the panel items and table remain readable without overflow.
