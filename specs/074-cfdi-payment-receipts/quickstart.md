# Quickstart: CFDI Payment Receipts (REP)

How to check the feature end to end. Contracts are in
[contracts/ui-contracts.md](./contracts/ui-contracts.md); the rules are in
[research.md](./research.md).

## Prerequisites

- mbe-api on the dev tenant with `PAC_PROVIDER=simulated` (spec 072).
- An issuer with an invoice series **and a payment receipt series** (type 200). If it has
  none, add one with spec 065's batch dialog.
- An admin account (`reference_dev_tenant_accounts`), plus a read-only user (`qareadonly`)
  for the rights checks.

## Automated

```sh
flutter analyze
flutter test test/unit/features/invoicing test/widget/features/invoicing \
  test/widget/features/sales test/unit/core/errors
# Live, dev only, consumes an invoice and a receipt folio — ask first:
MBE_WRITE=true flutter test test/integration/fiscal_documents_live_test.dart \
  --name "Payment receipt against the simulated PAC"
```

Expected: everything green, and `catalog_coverage_test` counts 191.

## Manual walk

1. **PPD invoice.** Facturas → Nueva factura for a customer with an open order. Set terms to
   PPD, add the order, confirm, Timbrar. It shows Timbrado.
2. **Payment.** Ventas → Pagos: record a payment for that customer for part of the invoice's
   total and apply it to the order.
3. **From the payment.** Open the payment → "Emitir complemento de pago" → pick the RFC →
   Crear. The draft opens with the payment's date, amount, form and reference, "Pago de
   origen #id", and the invoice proposed with installment 1, its balance, the amount and the
   remaining. Por asignar 0.00.
4. **Duplicate.** Back on the payment, issue again: refused with "Abrir complemento", which
   opens the draft from step 3.
5. **Amounts.** Edit the paid invoice's amount above the balance → refused with the balance.
   Lower it → Por asignar turns red. Confirm → refused (amounts must equal the payment).
   Restore it.
6. **Header.** Editar → lower the payment amount below the assigned sum → refused inline.
   Set an operation number of 51 characters → blocked by the counter. Form list has no 99.
7. **Confirm & stamp.** Confirmar → Sellado with a CP folio. Reabrir → draft with the same
   folio. Confirmar → Timbrar → Timbrado with a UUID; PDF and XML download.
8. **Invoice locked.** Open the invoice → Cancelar CFDI → refused, naming the receipt.
9. **By hand.** Facturas → "Nuevo complemento de pago" → same customer and RFC. Draft with
   no date or amount and form 01. Confirm → "Captura la fecha y el monto…". Agregar factura
   → pick a PUE invoice → refused (not payable). Pick the PPD invoice → added with
   installment 2 and the balance left after step 7.
10. **Navigation.** From the receipt, open the invoice through its folio link and the
    payment through "Pago de origen". In Facturas, filter Tipo "Complemento de pago".
11. **Rights.** As `qareadonly`: no buttons on the payment or the list; the receipt shows
    read-only with working links.
12. **Compact tier.** Narrow the window to phone width: paid invoices become cards, the
    summary stacks, nothing overflows. Repeat at the largest text size (§V).
13. **Cleanup.** Cancel the stamped receipt (spec 072), then the invoice if needed.
