# Contracts: spec 076

## C1. "Still in process" notice (detail screen, FR-009, FR-010)

| Refreshed document's status | Notice key | Text |
|---|---|---|
| `stamping` | `fiscal_document_still_in_process` | `fiscalDocumentStillInProcess` (unchanged) |
| `cancellationPending` | `fiscal_document_still_in_process` | `fiscalDocumentCancellationStillPending` (new) |

- The notice shows only after a refresh that succeeded and left the status unchanged, as today.
- It can be dismissed (`fiscal_document_notice_dismiss`), as today.
- Both `.arb` files carry the new key, and the en entry has an `@` description citing spec 076.

## C2. Failed request after 72 hours (FR-011, unchanged behaviour, newly pinned)

The server answers `status: issued` with a newest cancellation `status: failed`. The screen shows:
- the issued state;
- a history row whose outcome reads "Falló" / "Failed";
- the "Cancelar" action for a user with 23 update.

## C3. Simulated badge (FR-012, FR-013)

| `stamp.simulated` | `stamp.provider_rfc` | Badge `fiscal_document_simulated_badge` | RFC shown |
|---|---|---|---|
| true | `SIM010101SI0` | shown | `SIM010101SI0` |
| true | `SIM010101SIM` | shown | `SIM010101SIM` |
| false | any | hidden | as sent |

## C4. Live test simulator probe (FR-007)

`GET /api/v1/pac-simulator/fiscal-documents/0`, run before any document is sealed in each simulated group (072, 073, 074):

| Answer | Meaning | Test |
|---|---|---|
| 404, `code: request.route_not_found` | simulator off | `markTestSkipped('the PAC simulator is off on this server …')` and return |
| 404 with another code (e.g. `not_found`), or 2xx | simulator on | continue |
| anything else | unexpected | rethrow: the test fails |

## C5. Live test ordering (FR-003 to FR-005, FR-008)

- A stamp outcome is set after the last `confirm`, never while the document is `stamping`.
- A cancellation outcome is set after `stamp` has returned `issued`.
- After `not_cancellable`, a successful cancel needs a new document. No such scenario exists today, but the rule is noted in the file's header.
- Every simulated stamp asserts `simulated == true` and `providerRfc == 'SIM010101SI0'`.
