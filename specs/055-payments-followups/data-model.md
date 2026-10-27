# Data Model: Payments Follow-ups

Changes to the spec 054 model ([../054-payments-list-search/data-model.md](../054-payments-list-search/data-model.md)). Nothing new is persisted; everything below is client-side.

## 1. `CustomerPayment` (edited)

`lib/features/sales/domain/entities/customer_payment.dart`

| Field | Type | Source | Notes |
|---|---|---|---|
| `customerName` | `String?` | `CustomerPaymentResponse.customerDisplayName` | **New.** `null` only when the customer row is missing (mbe-api PR #274). A blank string is treated as `null`. |

All other fields are unchanged. `unapplied` is still shown as it arrives; its meaning is under review in mbe-api#276.

## 2. `PaymentType` (edited)

`lib/features/sales/domain/payment_type.dart`

| Member | Rule |
|---|---|
| `bool get hasTicket` | **New.** `true` for `creditPayment` and `paymentInAdvance`, `false` for `na`, `immediate`, `creditNote` and `expense` (R5). |

## 3. `PaymentsFilter` (edited)

`lib/features/sales/presentation/payments/payments_filter.dart`

| Field | Type | URL | Scope | Notes |
|---|---|---|---|---|
| `customerSearch` | `String?` | `ListQuery.search` | facility only | **New.** Trimmed. Empty becomes `null`. Ignored in the all-facilities scope. |
| `reference` | `String?` | `ListQuery.search` | all facilities only | Unchanged. |

Derived getters:

- `activeFilterCount`: unchanged. The search box isn't a drawer facet.
- `isNarrowed`: now `hasActiveFilters || reference != null || customerSearch != null`.

Scope switch: `paymentsQueryForScope` is unchanged, and it already drops `search` (FR-012).

## 4. `CustomerPaymentRepository.list` (edited)

| Parameter | Type | Maps to |
|---|---|---|
| `search` | `String?` | `search` on `GET /customer-payments` (customer-name substring, case-insensitive, combined with the other filters). |

## 5. `DocumentKind` (edited)

`lib/core/documents/domain/document_kind.dart`

| Value | Gate | Fallback filename | Endpoint |
|---|---|---|---|
| `customerPaymentTicket` | `customerPayments` (8), read | `pago-%08d.pdf` | `GET /customer-payments/{id}/ticket` |

`DocumentRef(kind: customerPaymentTicket, recordId: <payment id>, title: documentPaymentTicketTitle(id))`.

## 6. Seed fixture (dev tenant only)

Created by `tool/seed_payment_fixtures.py` (R8):

- A `CREDIT_PAYMENT` customer payment with reference `QA055-SEED`, owned by the admin's facility.
- One live application of that payment to a completed back-office order (origin 1).
- The script is idempotent: if any payment is already applied to a back-office order, it creates nothing.
