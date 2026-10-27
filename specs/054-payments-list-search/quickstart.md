# Quickstart: Payments List and Search

How to prove the feature works end-to-end. The behaviour is defined in [contracts/ui-contracts.md](./contracts/ui-contracts.md) and the entities in [data-model.md](./data-model.md).

## Prerequisites

- mbe-api running locally (or the dev tenant) at `main` ≥ 6ee7d97.
- `.env` with `MBE_POS_USERNAME` / `MBE_POS_PASSWORD`. This is the admin account, so it has every privilege.
- A non-admin account **without** PaymentsEditor (100) read, for the gating checks. See `test/integration/TEST_ACCOUNTS.md`.
- At least one payment recorded through the POS today, applied to a sale, plus one reversed application. The live test discovers existing data, so nothing has to be seeded for it.

## Automated

```bash
# Unit + widget
flutter test test/unit/features/sales/payments* test/widget/features/sales/payment*

# Live repository test (skipped without credentials)
flutter test test/integration/payments_list_live_test.dart \
  --dart-define=MBE_POS_USERNAME=$MBE_POS_USERNAME \
  --dart-define=MBE_POS_PASSWORD=$MBE_POS_PASSWORD

flutter analyze
```

Expected: everything passes, and the live test reports the payment id it discovered.

## Manual walkthrough

| # | As | Do | Expect | Covers |
|---|---|---|---|---|
| 1 | Admin | Open **Ventas → Pagos** | Your facility's payments, newest first, paginated, with customer names | Story 1, FR-004/005/018 |
| 2 | Admin | Filter by customer, a date range, Transferencia, "Sin verificar", and a cash session found by typing its number | Each filter narrows the list, and the badge counts them | FR-006/006a/007 |
| 3 | Admin | Clear the filters | The unfiltered list returns, not limited to your shift | Story 1, scenarios 7–8 |
| 4 | Admin | Open a payment with a reversed application | Importe · Aplicado · Sin aplicar; the reversed row is muted and marked "Revertida", and it's excluded from Aplicado | Story 2, FR-013a/014, SC-003 |
| 5 | Admin | Click the order of a POS sale, then of a back-office order | The POS sale opens in `/sales/pos/:id`, the order in `/sales/orders/:id` | FR-015 |
| 6 | Admin | Switch to **Todas las sucursales** and search part of a transfer reference | Results from any facility, with a Sucursal column. Only the Cliente and Fecha facets remain | Story 3, FR-010–012 |
| 7 | Admin | Press Back from a payment opened in step 6 | Returns to the "Todas" mode, the same search and the same page | R5 |
| 8 | Non-editor | Open Pagos | No mode switch and no search box. `?scope=all` typed in the URL is ignored | FR-002, SC-004 |
| 9 | Non-editor | Open `/sales/payments/<id of another facility's payment>` | "El pago N no existe." | FR-013b, R4, SC-004 |
| 10 | User without POS read | Open the filter drawer | No "Sesión de caja" facet. On a payment, Sesión de caja is plain text | R7, FR-015 |
| 11 | Any | Look for verify, reverse or edit actions | None anywhere | FR-003, SC-006 |
| 12 | Any | Phone width | The filter row wraps and the tables scroll horizontally. Nothing overflows | FR-019 |
