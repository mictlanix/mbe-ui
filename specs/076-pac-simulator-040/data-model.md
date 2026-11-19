# Data Model: Pick Up the Real-PAC Simulator (spec 076)

No domain entity changes shape. What changes is what the server sends in existing fields, and one generated test-only DTO.

## PacSimulationResponse (generated, test-only)

| Field | Before | After (mbe-api 040) |
|---|---|---|
| `uuid` | nullable string | nullable string, null before the stamp |
| `sat_status` | string | string, `not_found` before the stamp |
| `cancellation_status` | string | string, `none` before any cancel |
| `next_stamp` | nullable string | **removed** |
| `next_cancellation` | nullable string | **removed** |

It is not mapped to a domain entity (§III allows that for a DTO only tests use), and nothing reads it.

## Simulator outcome rules (test-only, enforced by the server)

```text
sealed ──(PUT stamp outcome)──► sealed + outcome ──stamp──► per outcome
   ▲                                   │
   └──── reopen + seal discards ◄──────┘
stamping: PUT stamp outcome → 409 fiscal_document.stamping
issued ──(PUT cancellation outcome)──► issued + outcome ──cancel──► per outcome
unstamped: PUT cancellation outcome → 409 fiscal_document.not_stamped
not_cancellable once → every later cancel of that document → 409 fiscal_document.not_cancellable
```

## FiscalStamp (domain, unchanged shape)

- `providerRfc`: `SIM010101SI0` for simulated stamps from 2026-11-19 on, and `SIM010101SIM` for migrated older ones. Real Multifacturas stamps carry the PAC's own RFC.
- `simulated`: the only input to the simulated badge and the "(simulado)" snackbar.

## FiscalCancellation / document status (domain, unchanged shape)

An open request (`requested` or `pending`) on a `cancellationPending` document now settles in one of these ways:

| Event | Document | Request outcome |
|---|---|---|
| SAT shows it cancelled (with or without acceptance, or expired) | `cancelled` | `accepted` / `expired` |
| Receiver rejects | `issued` | `rejected` |
| Refresh < 72 h after the PAC's answer, SAT shows nothing | `cancellationPending` (unchanged) | still open |
| Refresh ≥ 72 h after it, SAT shows nothing | `issued` | `failed` ("not received by SAT") |

The UI reacts by status alone (research R3, R6).

## Localization (new key)

| Key | Use |
|---|---|
| `fiscalDocumentCancellationStillPending` | The "still in process" notice when the refreshed document is `cancellationPending` (FR-009) |
