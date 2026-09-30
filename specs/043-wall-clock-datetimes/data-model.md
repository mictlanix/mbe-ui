# Data Model: Show Timestamps as the Local Times They Are

**Feature**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

This feature adds no entity, field, or storage. It changes what one existing kind of value *means* while it is in the app. This document pins that meaning and the exact boundary of what is affected.

## Business timestamp

A moment the business recorded, as local wall-clock time in the business timezone (`America/Mexico_City`), carrying no UTC offset. mbe-api stores and returns it this way, the legacy system sharing the database writes it this way, and after this feature the app reads and writes it this way too.

It exists in three forms. The feature's whole purpose is that all three agree.

| Form | Where | Shape | Before | After |
|---|---|---|---|---|
| **Wire** | JSON to and from mbe-api | `2026-09-26T13:05:28` | unchanged | unchanged |
| **In memory** | Dart `DateTime` in DTOs and domain entities | `isUtc`, fields | `isUtc=true`, fields **13:05 + 6 h** | `isUtc=false`, fields **13:05** |
| **On screen** | `DisplayFormatters.date`/`dateTime` | `2026-09-26 13:05` | `19:05` | `13:05` |

The display surface (`lib/core/formatting/`, spec 028) is unchanged. It already prints a value's own fields; it was printing the wrong fields.

### Invariants

- **I-1**: A timestamp read without an offset has the wire's fields exactly, and `isUtc == false` (FR-001).
- **I-2**: A timestamp read with an offset is the same instant, expressed in the host's local zone, `isUtc == false` (FR-002).
- **I-3**: A timestamp written carries the value's own fields and no offset, whatever its `isUtc` flag (FR-003).
- **I-4**: No value leaves the app UTC-flagged by design. A UTC-flagged value is still written correctly by I-3, but nothing in `lib/` should construct one to talk to the API. The helpers below no longer do.

The exact input-to-output mapping is the [wire contract](./contracts/wire-datetime.md).

## The day helpers

`wireDate` and `wireDateEnd` in `lib/features/sales/data/sales_order_repository_impl.dart` encode a *calendar day* for a date filter or a picked date.

| Helper | Meaning | Now (PR #180 stopgap) | After |
|---|---|---|---|
| `wireDate(d)` | start of `d`'s day | `DateTime(y, m, d).toUtc()` | `DateTime(y, m, d)` |
| `wireDateEnd(d)` | last instant of `d`'s day, inclusive | `DateTime(y, m, d, 23, 59, 59, 999).toUtc()` | `DateTime(y, m, d, 23, 59, 59, 999)` |

The stopgap forms must not survive the serializer swap. Under I-3 they would serialize as `…T06:00:00.000` and be read as 06:00 local, research R4.

Call sites, unchanged by this feature: `listSales` and `listOrders` (`date_from`/`date_to`), both delivery-order write paths, `updateHeader` (`promise_date`), and `_startOfToday()` in `open_sales_selector_controller.dart`.

## Scope boundary

### In scope: 45 date-time fields across 29 generated models

Every field the generated client types as `DateTime`. By model:

| Fields | Models |
|---:|---|
| 3 | `SalesOrderResponse`, `DeliveryOrderResponse` |
| 2 | `SalesOrderSummary`, `SalesOrderCreate`, `SalesQuoteResponse`, `SalesQuoteSummary`, `SalesQuoteCreate`, `CashSessionResponse`, `TaxpayerCertificateResponse`, `VehicleOperatorResponse`, `OutstandingOrderResponse`, `OrderApplicationResponse`, `ItinerarySummary`, `ItineraryResponse` |
| 1 | `SalesOrderUpdate`, `SalesQuoteUpdate`, `DeliveryOrderCreate`, `DeliveryOrderUpdate`, `DeliveryOrderSummary`, `DeliveryOrderEventResponse`, `ProofOfDeliveryResponse`, `PendingDeliveryLine`, `ItineraryStopResponse`, `CustomerPaymentCreate`, `CustomerPaymentResponse`, `CustomerRefundResponse`, `CustomerRefundSummary`, `CreditNoteResponse`, `ApplicationResponse` |

None needs individual attention. They all pass through the one serializer, which is the point of FR-006.

Two are worth naming because the shift changes a *decision* or a *calendar day*, not only a label:

- `CashSessionResponse.start` feeds `cashSessionStatusOf`, which compares its calendar day to today's. Shifted, an evening start lands on tomorrow and a stale session reads open (User Story 3).
- `TaxpayerCertificateResponse.validFrom`/`validTo` are displayed as dates only. Shifted, a validity ending after 18:00 displays as the following day (User Story 1, scenario 4).

### Out of scope: date-only fields

Typed as the generated `Date` and read by the separate `DateSerializer`, which takes year, month and day with no zone conversion. Already correct, unchanged (FR-005):

`birthday` (contacts, employees), `startJobDate` (employees), `date` (exchange rates, itineraries, pending delivery buckets), `issueDate`/`expirationDate` (vehicle operators).
