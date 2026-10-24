# Data Model: Supplier Sub-Panels

**Feature**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

These are client-side domain entities and presentation state only. The server schema is owned by mbe-api (#251), and the wire types are the generated `mbe_api_client` models; this layer does not hand-write any DTOs (§III).

## Domain entities (`lib/features/catalog/domain/entities/`)

### Supplier (changed)

| Field | Type | Source (`SupplierDetailResponse`) |
|---|---|---|
| supplierId, code, name, zone, creditLimit, creditDays, comment | unchanged | unchanged |
| **addresses** | `List<AddressListItem>` | `addresses ?? []`, mapped with `AddressListItem.fromResponse` |
| **contacts** | `List<Contact>` | `contacts ?? []`, mapped with `Contact.fromResponse` |
| **bankAccounts** | `List<BankAccount>` | `bankAccounts ?? []`, mapped with `BankAccount.fromResponse` |

- `Supplier.fromDetailResponse` maps the three lists, and its doc comment is updated to match.
- `agreements` is **not** mapped. It is loaded separately (research R4).
- `Supplier.fromResponse`, used by the list, keeps the three lists empty.

### BankAccount (new)

| Field | Type | Rule (from the server schema, FR-007) |
|---|---|---|
| bankAccountId | `int` | — |
| bankName | `String` | required, ≤ 250 |
| accountNumber | `String` | required, ≤ 20 |
| reference | `String?` | ≤ 20 |
| routingNumber | `String?` | ≤ 18 |
| comment | `String?` | ≤ 500 |

- `factory BankAccount.fromResponse(BankAccountResponse r)`.
- Section rendering: the label is `"$bankName · $accountNumber"`, and the subtitle is `reference`.

### SupplierAgreement (new)

| Field | Type | Rule (FR-013) |
|---|---|---|
| supplierAgreementId | `int` | — |
| supplierId | `int` | from `SupplierAgreementResponse.supplier` |
| start | `DateTime` | required; from `Date.toDateTime()` |
| end | `DateTime` | required; `end >= start` (equal dates allowed) |
| comment | `String?` | ≤ 500 |

- `factory SupplierAgreement.fromResponse(SupplierAgreementResponse r)`.
- Lists are sorted by `start` descending (FR-016).
- Agreements are always listed, whether expired or not, with no status (spec Assumptions).

## Repositories (`domain/repositories/` and `data/`)

| Repository | Methods | Generated API |
|---|---|---|
| `SupplierRepository` (changed) | `create` and `update` gain `addressIds`, `contactIds` and `bankAccountIds` (`List<int>?`). The rule is null = leave out, `[]` = clear. `get` returns `Supplier` with its lists. | `SuppliersApi` create, update and get |
| `SupplierRepository` (changed) | `listAgreements(supplierId)`, `createAgreement(supplierId, start, end, comment)`, `updateAgreement(supplierId, agreementId, start, end, comment)` and `deleteAgreement(supplierId, agreementId)` | the four `…Agreements…` methods on `SuppliersApi` |
| `BankAccountRepository` (new) | `list({search, skip, limit})` returns `BankAccountListResult(items, total)`; `create(...)` returns `BankAccount` | `BankAccountsApi` list and create |

Errors map as they do today (`_toAppError` → `mapDioException`). A 409 arrives as `ServerError(statusCode: 409)`.

## Presentation state

### SupplierFormState (changed, freezed)

These fields are added. The rest are unchanged (`supplier_form_controller.dart:34-50`).

| Field | Type | Notes |
|---|---|---|
| addresses | `List<AddressListItem>` | `@Default([])` |
| contacts | `List<Contact>` | `@Default([])` |
| bankAccounts | `List<BankAccount>` | `@Default([])` |
| supplierId | `int?` | now also set after a successful create (research R5) |

These error codes are added to `SupplierFormErrorCode`:
- `saveConflict`: a 409 on create or update (FR-011).
- `deleteConflict`: a 409 on delete (FR-017).

**State transitions**

```
load(id)      → loading → {fields, addresses, contacts, bankAccounts}
xAdded/xRemoved → list changes in memory only (FR-008); dirty = true
submitCreate  → submitting → saved + supplierId
                           | fieldErrors (422) | error=saveConflict (409) | createFailed
submitUpdate  → submitting → saved | fieldErrors | error=saveConflict | updateFailed
delete        → submitting → deleted | error=deleteConflict | deleteFailed
```

A conflict leaves every field and list unchanged (FR-011).

### SupplierAgreementsController (new; `@riverpod` family `int supplierId`)

`Future<List<SupplierAgreement>>`, sorted by start descending. It is invalidated after every agreement mutation.

### SupplierAgreementDialogState (new, freezed)

| Field | Type |
|---|---|
| start, end | `DateTime?` |
| comment | `String` (`@Default('')`) |
| submitting, done | `bool` |
| error, errorDetail | `String?` |
| fieldErrors | `Map<String, String>` |

`canSubmit` = `start != null && end != null && !end.isBefore(start) && comment.length <= 500 && !submitting`.

### BankAccountInlineCreateState (new, freezed)

The shape is the same as `ContactInlineCreateState`: string fields `bankName`, `accountNumber`, `reference`, `routingNumber` and `comment`, plus `submitting`, `created` (`BankAccount?`), `error`, `errorDetail` and `fieldErrors`.
