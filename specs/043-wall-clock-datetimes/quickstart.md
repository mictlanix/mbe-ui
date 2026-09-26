# Quickstart: Validating Wall-Clock Timestamps

**Feature**: [spec.md](./spec.md) | **Contract**: [contracts/wire-datetime.md](./contracts/wire-datetime.md) | **Data model**: [data-model.md](./data-model.md)

How to prove the feature works, from the fastest check to the live one. Each step names the requirement or success criterion it proves.

## Prerequisites

- On branch `043-wall-clock-datetimes`, dependencies fetched (`flutter pub get`).
- For the live checks: an mbe-api instance running mictlanix/mbe-api#228 or later, reachable at `API_BASE_URL` from `.env.settings`, and the `MBE_POS_USERNAME`/`MBE_POS_PASSWORD` pair from `.env`. Confirm the server is new enough: its `/openapi.json` describes every date-time field as "Local wall-clock time in America/Mexico_City".

## 1. The rule itself

```bash
flutter test test/unit/core/network/
```

Expected: every row of the reading and writing tables in the [contract](./contracts/wire-datetime.md) passes, including the DST row, plus the round-trip property. Proves FR-001, FR-002, FR-003.

## 2. The guard

The same run includes the source scan. To confirm it bites, temporarily add `api.standardSerializers` to any repository and rerun: it must fail and name the file. Revert. Proves FR-009, SC-005.

## 3. The whole suite, in three timezones

```bash
flutter test test/unit test/widget
TZ=UTC flutter test test/unit test/widget
TZ=America/New_York flutter test test/unit test/widget
```

Expected: identical results in all three. `TZ` is honored by the test process (verified: it reports `CST`, `UTC` and `EDT` respectively). New York matters most because it observes daylight saving, where the writing rule's trap lives (research R3). Proves FR-010, SC-006.

Known unrelated failure to ignore until it is fixed separately: `test/unit/features/repository_list_params_audit_test.dart` (Products), which reports that `ProductsApi` gained `perishable`, `seriable` and `invoiceable` upstream. It fails identically on `main`.

## 4. Live: the day filter

The check that proves the stopgap was removed correctly. Pick a day that has sales after 18:00 local (2026-09-21 does on the development tenant). In the app, filter the register's sales list and the orders list to that day.

Expected: the same rows as the plain-local reference query:

```bash
set -a; . ./.env; set +a
TOKEN=$(curl -s -X POST "$API_BASE_URL/api/v1/auth/login" \
  --data-urlencode "username=$MBE_POS_USERNAME" --data-urlencode "password=$MBE_POS_PASSWORD" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
curl -s -G "$API_BASE_URL/api/v1/sales-orders" -H "Authorization: Bearer $TOKEN" \
  --data-urlencode "date_from=2026-09-21T00:00:00.000" \
  --data-urlencode "date_to=2026-09-21T23:59:59.999" --data-urlencode "limit=100" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d["total"], sorted(i["date"] for i in d["items"]))'
```

On 2026-09-26 that reference returned 3 rows, 22:54:33 to 22:55:39, with no row from 2026-09-20. In the browser's network tab the app's own request must now carry `date_from=2026-09-21T00:00:00.000` with **no** `Z`. A `T06:00:00.000` with no `Z` means the stopgap survived: the register has lost the first six hours of its day. Proves FR-004, SC-002.

This check is read-only.

## 5. Live: what the screen says

Open any existing order, cash session, and digital certificate. For each, compare the times on screen with the API's response in the browser's network tab.

Expected: identical to the minute. An order whose response says `"date": "2026-09-26T13:05:28"` shows 13:05, not 19:05. A certificate whose `valid_to` falls after 18:00 shows its own calendar day, not the next. Proves FR-001, SC-001.

This check is read-only.

## 6. Live: session staleness

Find a cash session opened after 18:00 on a previous day and never closed, or open one on a test drawer late in the day and leave it.

Expected: the sessions list shows it as stale, which is what mbe-api's `session_state` says. Proves FR-008, SC-004.

Opening a session writes data. Use a test drawer.

## 7. Live: writing a date

On a draft order, pick a promise date. On a delivery, pick a delivery date. Save, reload the page, reopen each.

Expected: the picked dates read back unchanged, and no "couldn't reach the server" error appears. Proves FR-003, SC-003.

This check writes data. Use a draft order you can cancel afterwards.
