# Quickstart: CFDI Credit Notes

This guide checks the feature end to end against the local mbe-api with the simulated PAC.
The contracts are in [contracts/ui-contracts.md](./contracts/ui-contracts.md), and the
decisions behind them in [research.md](./research.md).

## Prerequisites

- mbe-api is running with `PAC_PROVIDER=simulated`. To check this without logging in,
  `GET /api/v1/pac-simulator/fiscal-documents/1` answers 401, not 404.
- The dev tenant has:
  - an issued, live invoice. 072 left #63920, #63925 and #63927;
  - an issuer with a **credit-note series** (Taxpayers → the issuer → Series, type Nota de
    crédito). Without one, step 2 shows the "no series" refusal, which is itself check 2b.
- Accounts:
  - an admin for the full flow;
  - `qareadonly` for the read-only checks (see the dev tenant accounts memory).
- Each full run consumes **one credit-note folio**. It is dev only, and the user is asked
  before it runs.

## Automated

```bash
flutter analyze
flutter test test/unit/features/invoicing test/widget/features/invoicing \
  test/unit/core/errors/catalog_coverage_test.dart
# live, dev only, after asking:
MBE_WRITE=true flutter test test/integration/fiscal_documents_live_test.dart \
  --plain-name "credit note"
```

The catalog test expects 181 `IN` codes.

## Manual walk

| # | Do | Expect |
|---|---|---|
| 1 | Open an issued invoice as admin | "Emitir nota de crédito" is last in the action row (C25) |
| 2 | Tap it, then Crear | A "Nota de crédito #id" draft opens, related 01 to the invoice, terms PUE (US1) |
| 2b | Same on an issuer without a credit-note series | The dialog stays open and shows the no-series refusal |
| 3 | The invoice was PPD (form 99) | The `credit_note_form` banner shows. Editar → the form list has no 99 (C30, C31) |
| 4 | Agregar de la factura → check two lines, set one above its quantity | An inline "Máximo…" appears and Agregar is disabled. Fix it, then Agregar (2): both lines appear, with no "Pedido" chip (C29, R3) |
| 5 | Agregar producto → a service product, renamed "Descuento" with a price | The line is added and the totals update (US2) |
| 6 | Edit a copied line's quantity above the invoice's | The dialog stays open with "máximo {max}" (C32) |
| 7 | Copy every line again at full quantity, then Confirmar | A refusal names the invoice's folio and the remaining amount (C32) |
| 8 | Remove the extra lines, then Confirmar | Sellado, with a folio from the credit-note series |
| 9 | Reabrir, then Confirmar | Same folio |
| 10 | Timbrar | Timbrado, with the simulated badge, PDF and XML (072) |
| 11 | Tap the relation's folio | The invoice opens. Back returns to the credit note (C28) |
| 12 | On the invoice, Cancelar ante el SAT | Refused, listing the credit note as a live document (072) |
| 13 | Cancel the credit note (reason 02) | It is cancelled. The invoice offers "Emitir nota de crédito" again and would now be cancellable (don't cancel it, it is a shared fixture) |
| 14 | Facturas → Tipo: Nota de crédito | The new credit note is listed with its state |
| 15 | Log in as `qareadonly` and open the invoice and the credit note | No create, line, header, confirm, reopen or stamp action. The relation link works |
| 16 | Compact width: steps 2–4 | The copy dialog goes full screen with card rows, and the add buttons wrap |
| 17 | Largest text scale: the copy dialog and the detail | Nothing is clipped |
