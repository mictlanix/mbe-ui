# Data Model: CFDI Credit Notes

This spec adds no new entity. It extends spec 066/072's `FiscalDocument`
(`lib/features/invoicing/domain/entities/fiscal_document.dart`) and adds two inputs.

## FiscalDocument: new and changed getters

| Getter | Definition | Used by |
|---|---|---|
| `isCreditNote` (new) | `summary.typeCode == 100` | detail, header dialog, banner |
| `isEditableDraft` | `(isInvoice \|\| isCreditNote) && status == draft` | detail edit gates (FR-015) |
| `canReopen` | `(isInvoice \|\| isCreditNote) && status == sealed` | Reabrir (FR-011) |
| `canIssueCreditNote` (new) | `isInvoice && status == issued` | "Emitir nota de crédito" (FR-001), plus Create on 23 |
| `creditedInvoice` (new) | `isCreditNote ? relations.where((r) => r.type == creditNoteOf).firstOrNull : null` | relation link, exceeds refusal (FR-003, FR-012) |
| `needsPaymentForm` (new) | `isCreditNote && status == draft && paymentForm == 99` | banner (FR-010) |

The existing fields need no change:
- `relations[].documentId`, `series` and `serial` give the invoice's id and folio.
- `paymentTerms` already maps the server's IMMEDIATE to PUE.
- `lines[].orderLineId` is kept, but the "Pedido" chip ignores it on credit notes
  (research R3).

## Inputs

### Credit-note creation

`int invoiceId` only. This is the server's `CreditNoteCreate {invoice}`. No freezed type is
needed.

### Invoice-line copy

```text
CreditNoteLineCopy (record, presentation → actions)
  lineId: int          # the invoice's line id (FiscalDocumentLine.fiscal_document_detail_id)
  quantity: Decimal    # 0 < quantity ≤ invoice line quantity
```

On the wire this is `InvoiceLineCopy {line, quantity}`. The quantity is always sent,
including when it equals the default.

## Lifecycle (unchanged from 072, now reachable for type 100)

```text
(issued invoice) ──Emitir nota de crédito──▶ draft ──confirm──▶ sealed ──stamp──▶ issued
                                               ▲                  │                 │
                                               └──────reopen──────┘          cancel (072)
```

## Validation (client side, the server re-checks everything)

| Rule | Where | Source |
|---|---|---|
| Copy quantity is > 0 and ≤ the invoice line's | copy dialog | server `add_invoice_line` |
| The payment form is never 99 in the header dialog | header dialog, credit-note mode | server `_prepare_credit_note` |
| The issue date is within 72 h and not in the future | header dialog (existing) | spec 066 |

These rules are left to the server:
- a line edit above the largest invoiced quantity of that product
  (`credit_quantity_exceeds_line`);
- a total above what remains of the invoice (`credit_exceeds_invoice`);
- the invoice no longer being creditable (`invoice_not_creditable`).
