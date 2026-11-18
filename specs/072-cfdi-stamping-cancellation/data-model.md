# Data Model: CFDI Stamping, Refresh and Cancellation

Client-side domain entities in `lib/features/invoicing/domain/entities/`. They extend spec
066's model ([066 data-model](../066-invoice-list-editor/data-model.md)). Wire shapes are
the generated client's (`FiscalDocumentResponse`, `FiscalDocumentStamp`,
`FiscalDocumentCancellationResponse`, `FiscalDocumentCancelRequest`).

## FiscalDocumentStatus (changed enum)

| Domain value | Wire (`status`) | l10n label (es) | Chip colours (R10) |
|---|---|---|---|
| `draft` | `draft` | Borrador | surfaceContainerHighest |
| `sealed` | `sealed` | Sellado | primaryContainer |
| `stamping` **new** | `stamping` | Timbrando | tertiaryContainer |
| `issued` | `issued` | Timbrado (existing label, spec 066) | secondaryContainer |
| `cancellationPending` **new** | `cancellation_pending` | Cancelación pendiente | tertiaryContainer |
| `cancelled` | `cancelled` | Cancelado | errorContainer |

Mapped from both generated enums by constant, with no fallback (research R1). The list
filter writes the wire value into `status=`.

### Transitions (server-driven; the UI only triggers them)

```text
draft ──confirm──▶ sealed ──reopen──▶ draft            (spec 066, invoices only)
sealed ──stamp──▶ issued | stamping                   (stamping on pac.timeout)
stamping ──refresh/job──▶ issued | sealed
issued ──cancel──▶ cancelled | cancellationPending
cancellationPending ──refresh/job──▶ cancelled | issued
```

## FiscalDocument (changed)

New fields:

| Field | Type | From | Notes |
|---|---|---|---|
| `stamp` | `FiscalStamp?` | `stamp` | null before stamping (R4) |
| `stampingSince` | `DateTime?` | `stamping_since` | banner time while stamping |
| `cancellationSubstitution` | `String?` | `cancellation_substitution` | "Sustituida por" fact |
| `cancellations` | `List<FiscalCancellation>` | `cancellations` | newest first, as the server orders |

New and changed getters (R2):

| Getter | Status | Definition |
|---|---|---|
| `canStamp` | new | `status == sealed` |
| `canCancel` | new | `status == issued` |
| `canRefresh` | new | `status ∈ {stamping, cancellationPending}` |
| `hasDocuments` | changed | `status ∈ {issued, cancellationPending, cancelled}` |
| `openCancellation` | new | the first entry whose outcome is `requested` or `pending`, else null |

`openCancellation` supplies the request time for the cancellation-pending banner.

## FiscalStamp (new, freezed)

| Field | Type | From |
|---|---|---|
| `uuid` | `String` | `uuid` |
| `stamped` | `DateTime?` | `stamped` |
| `satCertificate` | `String?` | `sat_certificate` |
| `providerRfc` | `String?` | `provider_rfc` |
| `simulated` | `bool` | `simulated` |

## FiscalCancellation (new, freezed)

| Field | Type | From | Notes |
|---|---|---|---|
| `id` | `int` | `fiscal_document_cancellation_id` | row key |
| `reason` | `String` | `reason` | "01"–"04". Shown via `SatCancellationReason.fromCode`, else the raw code |
| `substitution` | `String?` | `substitution` | |
| `outcome` | `CancellationOutcome` | `status` (String) | see below |
| `pacCode` | `String?` | `pac_code` | shown verbatim |
| `pacMessage` | `String?` | `pac_message` | shown verbatim |
| `requestedBy` | `int` | `requested_by` | **employee** id → `employeeDisplayNameProvider` (R8) |
| `requestedAt` | `DateTime` | `requested_at` | |
| `answeredAt` | `DateTime?` | `answered_at` | |
| `resolvedAt` | `DateTime?` | `resolved_at` | |

`last_checked_at` is not mapped (wireframe WQ6).

### CancellationOutcome (new enum)

`requested, pending, accepted, expired, rejected, notCancellable, failed, unknown`. Mapped
from the wire string. An unrecognised string becomes `unknown` and keeps the raw value
(`rawOutcome`) for the "Desconocido ({value})" label (R10). `requested` and `pending` count
as open.

## SatCancellationReason (new enum)

| Value | Code | Label (es, SAT) | Needs substitute |
|---|---|---|---|
| `withRelation` | 01 | Comprobante emitido con errores con relación | yes |
| `withoutRelation` | 02 | Comprobante emitido con errores sin relación | no |
| `notCarriedOut` | 03 | No se llevó a cabo la operación | no |
| `globalInvoiceNominative` | 04 | Operación nominativa relacionada en una factura global | no |

## CancelRequest (repository input)

`({SatCancellationReason reason, String? substitution})`. The substitution is the picked
document's UUID. It is required when `reason.needsSubstitute`, and not sent otherwise.

## Validation (client-side, mirroring what the user sees)

- Cancel's "Enviar" stays disabled until a reason is picked, and for 01 until a substitute
  is picked.
- The substitute candidates are issued, from the same issuer, with the same recipient RFC,
  and not the document itself.
- The server enforces everything else, and its refusals map per research R9.
