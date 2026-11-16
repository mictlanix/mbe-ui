# Quickstart: Invoice List, View, PDF and Editor

**Spec**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md) | **Data model**: [data-model.md](./data-model.md)

## Prerequisites

- mbe-api is running locally with the dev tenant. `.env` holds `MBE_POS_*`, which is the admin account (see `test/integration/TEST_ACCOUNTS.md`).
- After a DB reset, run `python3 tool/seed_test_accounts.py`. Step 1 uses `qanoaccess`.
- **Issued documents** come from legacy data. The live test finds them at run time with `status=issued` (and `cancelled` for step 5), not from fixed ids.
- **Sealing** needs an issuer with an active certificate valid now, and an invoice series. Spec 065's quickstart used `CAG190523ES5`. The live test discovers the store's issuer and skips sealing with a printed reason when confirm returns `no_valid_certificate`.
- **Draft source**: a customer with at least one taxpayer (RFC) and a completed sales order with invoiceable products. The live test discovers one: a recent `status=completed` order whose customer has taxpayers.

## Automated

```bash
flutter test test/unit test/widget
# Live, against a running mbe-api (read-only by default)
flutter test integration_test/fiscal_documents_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings \
  --dart-define=MBE_POS_USERNAME=... --dart-define=MBE_POS_PASSWORD=...
# ...add this to also create, edit, seal and reopen an invoice
  --dart-define=MBE_WRITE=true
```

Each write run leaves on the tenant:
- one draft invoice that holds a folio from the seal and reopen in steps 9 and 10;
- the folio itself, which is consumed. The next confirm of that draft reuses it, but a new invoice takes the next number.

Run writes only against the dev tenant.

## Manual walkthrough

1. **Access (US1-4, SC-004).**
   - As admin, the side nav shows a "Facturación" group with "Facturas".
   - As `qanoaccess`, the group is missing, and typing `/invoicing/fiscal-documents` is refused.
2. **List (US1, FR-001..004).**
   - The list opens newest first, with every type and the badge at 0.
   - Search a legacy invoice by series+folio (e.g. `GR4776`), then by its UUID, then by recipient RFC. Each finds it.
   - Filter by Estado = Timbrado, Tipo = Nota de crédito, an issuer, and a date range. Each one narrows the list.
   - With a date range set, drafts disappear, as the helper text under the facet says.
   - "Limpiar" keeps the search.
3. **Type names (research R2).**
   - A payment receipt (type 200) reads "Recibo de pago". Code 101 reads "Aplicación de anticipos".
   - On a taxpayer issuer's Series section, the same names show.
4. **View and PDF/XML (US2).**
   - Open an issued invoice. Header, lines and totals show, and Total equals the list's total.
   - "Ver PDF" previews the document. Print and Descargar work.
   - "Descargar XML" opens a save dialog named `{RFC}-{serie}{folio:000000}.xml`, and the saved file is byte-identical to `GET /fiscal-documents/{id}/xml`.
5. **Refusals (US2-5).**
   - Open a cancelled legacy document. The PDF shows the cancellation mark.
   - Open a pre-4.0 document if the tenant has one. Ver PDF shows "versión no imprimible" in Spanish.
6. **Create (US3-1..3).**
   - "Nueva factura": pick the discovered customer, then an RFC. The detail opens as "Borrador #id" with issuer, series, PUE/PPD default, uso G01 and forma 99.
   - Edit the header: set Fecha de emisión to one hour ago and save. Reopen the page, and the time reads the same (round trip, research R3).
   - A customer without taxpayers can't be created ("no tiene RFC registrado").
7. **Add a sales order (US3-4..6).**
   - "Agregar pedido": pick the completed order. Its lines appear with the Pedido marker.
   - Add it again, and nothing is duplicated (the line count is unchanged).
   - Pick an order with nothing left. The inline message says so.
8. **Edit lines and header (US4).**
   - ✎ on a line: set the quantity above the order's quantity, and the message gives what remains. Set a 10 % discount and IVA Exento, and the totals block updates.
   - Clear the description, and it comes back as the product name.
   - "Agregar producto" (admin has 56): pick a product, and it is added at quantity 1.
   - Header: choose PPD, and Forma de pago locks at 99. Set the date 4 days ago, and it is refused inline.
   - 🗑 a line and confirm. The line is gone.
9. **Confirm (US5-1, US5-2).**
   - Confirm a draft with no lines. It shows "La factura no tiene partidas" and stays a draft.
   - Confirm the real draft. It reads Sellado with "Factura {serie}{folio}", has no edit controls, and shows the "pendiente de timbrar" banner.
   - The list shows its total, and it equals the "Total (estimado)" the draft showed (research R11). The live test asserts this.
10. **Reopen (US5-3).** Reabrir: the invoice is a draft again with the same folio, and the Serie field is locked.
11. **Relations (US6).** On the draft, "Agregar relación", 07, then pick an issued invoice of the same recipient.
    - It is listed. A 04 is now locked out by the type lock.
    - Remove it.
    - If the tenant has a cancelled stamped invoice of that recipient, add it as 04.
12. **Read-only user (C9).** As a user with 23 read but not update (give one in User Profiles), open a draft. No edit control or action shows. Ver PDF still works on an issued document.
13. **Compact tier.** At phone width, list rows stack, the line table becomes cards, and the action buttons wrap.
14. **Largest text size (§V).** At desktop width, set the largest text size. The status chip, folio, amounts and totals don't clip.
