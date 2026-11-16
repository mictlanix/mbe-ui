# Data Model: Taxpayer Batches

Phase 1 for [plan.md](plan.md). These are domain entities in `lib/features/catalog/domain/entities/`, freezed and mapped from the generated DTOs in the repository (§III).

## FiscalDocumentKind (enum)

`lib/features/catalog/domain/entities/fiscal_document_kind.dart`

| Value | `code` | es label | en label |
|---|---|---|---|
| `invoice` | 0 | Factura | Invoice |
| `expense` | 1 | Egreso | Expense |
| `payment` | 2 | Pago | Payment |
| `transfer` | 3 | Traslado | Transfer |
| `creditNote` | 100 | Nota de crédito | Credit note |
| `paymentReceipt` | 101 | Recibo de pago | Payment receipt |
| `advancePaymentsApplied` | 200 | Aplicación de anticipos | Advance payments applied |

- `static FiscalDocumentKind? fromCode(int code)`. Returns null for an unknown code.
- The declaration order is the sort order (research R5).
- Labels come from `.arb` keys `fiscalDocumentKind<Value>`. An unknown code uses `fiscalDocumentKindUnknown(code)`: "Tipo desconocido ({code})" / "Unknown type ({code})".

## TaxpayerBatch

`taxpayer_batch.dart`, mapped from `TaxpayerBatchResponse`.

| Field | Type | From | Notes |
|---|---|---|---|
| `taxpayerBatchId` | `int` | `taxpayer_batch_id` | Identity |
| `taxpayer` | `String` | `taxpayer` | The issuer's RFC |
| `series` | `String` | `batch` | 1–10 chars, unique per issuer |
| `typeCode` | `int` | `type` | Raw code, kept so an unknown type still renders |
| `kind` | `FiscalDocumentKind?` | `fromCode(type)` | Null means unknown |
| `template` | `TaxpayerBatchTemplate` | `template` | |
| `inUse` | `bool` | `in_use` | Locks series and type, and blocks delete |

## TaxpayerBatchTemplate

| Field | Type | From | Rule |
|---|---|---|---|
| `name` | `String` | `name` | Required, 1–50 after trim |
| `logo` | `String?` | `logo` | A file name. Blank is sent as null |
| `headerHeight` | `int` | `header_height ?? 0` | ≥ 0 |
| `footerHeight` | `int` | `footer_height ?? 15` | ≥ 0 |
| `accounts` | `List<TaxpayerBatchAccount>` | `extra_info ?? []` | Ordered |

## TaxpayerBatchAccount

| Field | Type | From |
|---|---|---|
| `bank` | `String` | `bank ?? ''` |
| `account` | `String` | `account ?? ''` |
| `clabe` | `String` | `clabe ?? ''` |
| `currency` | `String` | `currency ?? ''` |

`isBlank` is true when all four are empty after trim. Blank accounts are dropped on save.

## Draft (dialog state)

`TaxpayerBatchDialogState`, freezed, in `presentation/taxpayer_batch_dialog_controller.dart`. The provider is a family keyed by `(String rfc, TaxpayerBatch? existing)`.

| Field | Type | Notes |
|---|---|---|
| `mode` | `RecordFormMode` | `create` when there is no existing series. Otherwise starts as `view` or `edit` (the launcher passes which) |
| `series`, `templateName`, `logo`, `headerHeight`, `footerHeight` | `String` | Text as typed |
| `kind` | `FiscalDocumentKind?` | Null until picked. Null for an existing unknown type until the user picks one |
| `accounts` | `List<TaxpayerBatchAccount>` | Editable rows |
| `locked` | `bool` | Starts as `existing?.inUse ?? false`. Set true by the in-use race (R6) |
| `fieldErrors` | `Map<String, String>` | Keys: `batch`, `type`, `name`, `header_height`, `footer_height`. Values are client error codes, or a server validation type resolved at display time |
| `submitting` | `bool` | |
| `errorCause` | `AppError?` | Kept as the error, never its text (§III) |
| `done` | `bool` | Set after a successful save or delete. The dialog pops |
| `issuerGone` | `bool` | Set on `resource.not_found` for `taxpayer_issuer` (R8) |

### Client validation (before sending)

| Key | Error code | Condition |
|---|---|---|
| `batch` | `required` | Blank after trim |
| `batch` | `tooLong` | More than 10 characters after trim |
| `type` | `required` | `kind == null` |
| `name` | `required` | Blank after trim |
| `name` | `tooLong` | More than 50 characters after trim |
| `header_height`, `footer_height` | `invalid` | Not a whole number ≥ 0 |

When `locked`, `batch` and `type` are not validated or edited. The saved values are sent unchanged.

### State transitions

```text
create ──save ok──▶ done (pop, list invalidated)
view ──Edit toggle (can update, parent not read-only)──▶ edit
edit ──save ok──▶ done
edit ──delete confirmed ok──▶ done
edit/create ──409 taxpayer_batch.in_use──▶ edit, locked = true, series/type reset, list invalidated
create/edit ──404 taxpayer_issuer──▶ issuerGone (pop, go /taxpayer-issuers)
```

## Relationships

```text
TaxpayerIssuer (rfc) 1 ──── * TaxpayerBatch ── 1 TaxpayerBatchTemplate ── * TaxpayerBatchAccount
```
