# Data Model: CFDI Payment Receipts (REP)

Client-side shapes only; the server owns every rule (research R8–R10). All of them live in
`lib/features/invoicing/domain/entities/fiscal_document.dart`.

## FiscalDocument (extended)

| Field / getter | Type | Source | Notes |
|---|---|---|---|
| `paymentDate` | `DateTime?` (date only) | `payment_date` | Receipts only |
| `paymentAmount` | `Decimal?` | `payment_amount` | Receipts only; null on a fresh by-hand draft |
| `paymentReference` | `String?` | `payment_reference` | SAT `NumOperacion`, ≤ 50 |
| `customerPaymentId` | `int?` | `customer_payment` | Set when the receipt came from a payment |
| `paidInvoices` | `List<PaidInvoice>` | `paid_invoices` | Empty for other types. Live on drafts, stored once sealed |
| `isPaymentReceipt` | getter | `typeCode == 200` | |
| `orderingBank` | getter | `reference` on a receipt | The server stores `ordering_bank` in `reference` (R7) |
| `assignedAmount` | getter | Σ `paidInvoices.amount` | |
| `unassignedAmount` | getter | `paymentAmount − assignedAmount`, or null when `paymentAmount` is null | Never negative (R8) |
| `isEditableKind` | widened | + `isPaymentReceipt` | Every receipt, legacy included |
| `needsPaymentForm` | widened | + receipts | Draft on form 99 (legacy only, R10) |
| `showsNoProposalBanner` | getter | receipt draft, `customerPaymentId != null`, `paidInvoices` empty | C38 |

`hasRelations` and `amounts` are unchanged; the detail screen simply doesn't render lines,
relations or `InvoiceTotals` for a receipt (R3, R4).

## PaidInvoice (new, freezed)

| Field | Type | Source |
|---|---|---|
| `relationId` | `int` | `fiscal_document_relation_id` (the id the PUT/DELETE routes take) |
| `invoiceId` | `int` | `invoice` |
| `series` | `String?` | `batch` |
| `serial` | `int?` | `serial` |
| `stampUuid` | `String?` | `stamp_uuid` |
| `installment` | `int` | `installment` |
| `previousBalance` | `Decimal` | `previous_balance` |
| `amount` | `Decimal` | `amount` |
| `remaining` | `Decimal` | `remaining` |
| `folioLabel` | getter | `'${series ?? ''}$serial'`, or `#invoiceId` without a serial |

## InvoiceHeaderPatch (extended)

Adds `paymentDate` (date), `paymentAmount` (Decimal), `paymentReference` and `orderingBank`.
The repository sends only the non-null fields. The receipt header dialog sets only
`paymentDate`, `paymentAmount`, `paymentForm`, `paymentReference`, `orderingBank`, `issued`
and `comment` (server `_HEADER_FIELDS[200]`).

## NewPaymentReceipt (new)

| Field | Type | Notes |
|---|---|---|
| `customerId` | `int` | |
| `recipientRfc` | `String` | |
| `customerPaymentId` | `int?` | Set from the payment detail |

`issuer` and `batch` are left to the server's defaults.

## State transitions

Unchanged from specs 066/072: draft ⇄ sealed (confirm / reopen) → stamping → issued →
cancellation pending → cancelled. Only a draft accepts header and paid-invoice writes.
