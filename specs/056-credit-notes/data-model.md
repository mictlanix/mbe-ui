# Data Model: Credit Notes

Amounts are wire-decimal `String`s throughout, handled only through `features/sales/domain/money.dart`.

## 1. `CreditNote` (new, `features/sales/domain/entities/credit_note.dart`)

A freezed class built by `CreditNote.fromResponse(api.CreditNoteResponse)`.

| Field | Type | From | Notes |
|---|---|---|---|
| `id` | `int` | `creditNoteId` | |
| `customerId` | `int` | `customer` | No name on the wire (research R9) |
| `salesOrderId` | `int` | `salesOrder` | The order the refund came from |
| `customerRefundId` | `int` | `customerRefund` | |
| `customerPaymentId` | `int` | `customerPayment` | The backing payment. Its id is the ticket number |
| `issued` | `String` | `refunded` | Shown as-is (FR-015). Reads 0 on legacy notes until mbe-api#277 |
| `remaining` | `String` | `remaining` | The server's figure. Never recomputed |
| `date` | `DateTime?` | `date` | |

`cashSession` isn't mapped. The app applies no cash-session rule, because the server owns it (mbe-api#277).

Derived getter: `bool get isOpen => compareAmounts(remaining, '0') > 0`.

## 2. `CreditNoteListResult` (new, beside the repository)

`(List<CreditNote> items, int total)`. This is the same shape as `CustomerPaymentListResult`.

## 3. `CreditNoteRepository` (new, `features/sales/domain/repositories/credit_note_repository.dart`)

| Method | Calls | Returns |
|---|---|---|
| `list({int? customerId, required int skip, required int limit})` | `GET /credit-notes` (never `open_only`, R2/R8) | `CreditNoteListResult` |
| `listForCustomer(int customerId)` | `list` repeated until `total` is reached, limit 100 | every note, ordered oldest first |
| `findByPayment({required int customerPaymentId, required int customerId})` | `list(customerId:)` newest first, stopping at the first match (R4) | `CreditNote?` |

The implementation (`data/credit_note_repository_impl.dart`) wraps `api.CreditNotesApi(dio, appSerializers)` and maps `DioException` with the shared `_toAppError` pattern. It's exposed as `creditNoteRepositoryProvider`.

## 4. `SalePayment` (edited)

+ `required PaymentType type`, from `PaymentType.fromApi(r.paymentType)` (R6). Test fixtures that build a `SalePayment` get `type: PaymentType.immediate` by default through their helpers.

## 5. Payment step state (edited, `payment_controller.dart`)

**`PaymentIssue`** gains:
- `creditPartlyApplied`: some notes applied, then one failed. It carries the applied amount on the draft.
- `noteNotFound`, `noteUsedUp`, `noteAlreadyOnSale`, `noteOtherCustomer`: the ticket-lookup refusals (FR-006/006a). `noteOtherCustomer` carries the owner's name.

**`PaymentDraft`** gains:
- `String? creditApplied`, the amount for the partial message
- `String? issueSubject`, the owner's name for `noteOtherCustomer`

Both are cleared like `issue`.

**`TenderResult`** is unchanged. `refused` and `failed` cover the new outcomes.

## 6. Spendable credit (new provider, `presentation/payment/customer_credit_controller.dart`)

`customerCreditProvider(saleId)`, a `FutureProvider.family<CustomerCredit, int>`. It reads:
- the sale, from `posSaleControllerProvider`
- the sale's applications, from `orderPaymentsControllerProvider(saleId)`
- `listForCustomer(sale.customer)`

It returns `CustomerCredit(notes: open notes not already on the sale, oldest first; total: sum of their remaining)`. For the walk-in customer, or a user failing the R7 gates, it returns an empty value without any request. `tenderCreditNotes` invalidates it after every attempt (FR-008).

## 7. `CreditNotesFilter` (new, `presentation/credit_notes/credit_notes_filter.dart`)

A freezed class built from `ListQuery`:
- `customerId`, from facet `customer`
- `openOnly`, from facet `open` = `1`
- `pageIndex`

`activeFilterCount` counts `customerId` and `openOnly`. The URL is the only state, as on Pagos.

## 8. Validation rules

| Rule | Where | Source |
|---|---|---|
| Spend total ≤ entered amount, ≤ sale balance, ≤ spendable credit | `tenderCreditNotes` | FR-002 |
| Each note's application ≤ its `remaining` | `tenderCreditNotes` | FR-002 |
| `amountChange` is never sent | `tenderCreditNotes` | FR-003 |
| No credit tile or ticket redemption on a cancelled sale, or one with a zero balance | grid gate | FR-007 |
| A ticket's payment must be type `creditNote`, the sale's customer, and not already on the sale | ticket lookup | FR-006, FR-006a |
