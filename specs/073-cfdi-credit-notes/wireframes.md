# Wireframes: CFDI Credit Notes

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-18 | **Fidelity**: low

> **Superseded in part** (research.md, 2026-11-18): the title stays "Nota de crédito #id"
> without "· Borrador" (R2), and a credit-note draft with a real payment form has **no**
> "Borrador. Agrega las partidas…" banner (R7). Every other frame still applies.

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every
dimension, colour and spacing comes from the design tokens (constitution §V).

This feature adds **no new screen or route**. It changes the existing fiscal document
detail (specs 066/072) and adds three dialogs:

| Surface | Route / host | Change |
|---|---|---|
| Fiscal document detail, **invoice** | `/invoicing/fiscal-documents/:id` | "Emitir nota de crédito" in the action row when issued |
| Fiscal document detail, **credit note** | `/invoicing/fiscal-documents/:id` | Editable as a draft: lines from the invoice, header, confirm, reopen |
| Emitir nota de crédito | dialog over the invoice | New confirmation |
| Agregar de la factura | dialog over the credit note | New: pick invoice lines and quantities |
| Encabezado | dialog over the credit note | Existing `InvoiceHeaderDialog`, limited to the credit-note fields |
| Facturas list | `/invoicing/fiscal-documents` | Unchanged; the type filter already offers "Nota de crédito" |

The detail keeps its structure: an empty `AppBar.actions` and every action in the body's
action row (`Wrap`, end-aligned, primary action last). Order: banner → header facts →
lines → relations → cancellations → totals → notice/refusal → action row.

---

## Screen: Invoice detail (`/invoicing/fiscal-documents/:id`, type Factura)

### State: issued, user with Create + Update on 23

```text
┌ ← Factura A5238 ────────────────────────────────────────────────────────────────────────┐
│ Folio A5238   Estado (Timbrado)   Emisión 17/11/2026 09:12   Receptor FSO… · Ferretería │
│ UUID 6F1C…9A2E   Timbrado 17/11/2026 09:13   Cert. SAT 3000…   RFC PAC SIM010101SIM     │
│ …lines, relations, cancellations, totals (unchanged)…                                   │
│                                                                                         │
│      [PDF] [XML] [Cancelar CFDI]                              [Emitir nota de crédito]  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Action row: new `OutlinedButton` "Emitir nota de crédito", last in the row. Issued invoices
  have no filled primary today, so it takes the trailing slot without being a
  `FilledButton`. **FR-001**
- Shown only when: type is Factura, state is issued, and the user has Create on 23. Absent
  (not disabled) otherwise. **FR-001, FR-017**
- Cancellation pending, cancelled, sealed, stamping, draft: action absent (spec US1 sc. 2).

### State: issued, read-only or Update-only user

```text
│      [PDF] [XML] [Cancelar CFDI]                                                        │
```

- Update without Create keeps 072's actions only. Read-only users keep PDF/XML only.

### Dialog: Emitir nota de crédito (confirmation)

```text
┌ Emitir nota de crédito ──────────────────────────────────┐
│ Se creará un borrador de nota de crédito para la factura │
│ A5238 (Ferretería Sol · FSO…), relacionada con tipo 01.  │
│                                                          │
│ Tomará el cliente, el receptor, la forma de pago y el    │
│ uso CFDI de la factura. Después agregas las partidas.    │
│                                                          │
│ ┌ ⚠ No hay serie de notas de crédito para este emisor. ┐ │  ← refusal, only on failure
│ └──────────────────────────────────────────────────────┘ │
│                                       [Cancelar] [Crear] │
└──────────────────────────────────────────────────────────┘
```

- `ResponsiveDialog`, as `showStampFiscalDocumentDialog` (072). On success the dialog
  closes and the app navigates to the new credit note. **FR-001, FR-002**
- Refusal inside the dialog with `FormErrorBanner`, localized from the code:
  `issuer_has_no_series` (type credit note), `invoice_not_creditable`,
  `cancellation_open`. **FR-016**
- While the request runs, both buttons are disabled. **FR-018**

---

## Screen: Credit note detail (`/invoicing/fiscal-documents/:id`, type Nota de crédito)

### State: new draft, no lines, payment form 99 (Update on 23 + Create on 56)

```text
┌ ← Nota de crédito · Borrador #63930 ────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⚠ La factura tiene forma de pago 99 (Por definir). Elige la forma de pago real en el │ │
│ │   encabezado antes de confirmar.                                                    │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│ Tipo Nota de crédito   Folio (al confirmar)   Estado (Borrador)               [Editar] │
│ Receptor FSO… · Ferretería Sol   Cliente Ferretería Sol   Emisor MIC010101AAA          │
│ Método PUE   Forma de pago 99 Por definir   Uso G03   Emisión (al confirmar)            │
│                                                                                         │
│ Partidas                              [Agregar de la factura] [Agregar producto]        │
│   Sin partidas.                                                                         │
│                                                                                         │
│ Documentos relacionados                                                                 │
│   01 · Nota de crédito   A5238 ↗   6F1C…9A2E                                            │
│                                                                                         │
│                                              Subtotal 0.00   IVA 0.00   Total 0.00     │
│                                                                           [Confirmar]   │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Banner: `_StatusBanner`. Draft credit notes with payment form 99 get the warning text
  above; with a real form, the usual draft banner. **FR-010**
- Header facts: `_HeaderFacts` with "Editar" opening the header dialog. Método shows PUE,
  read-only. **FR-009**
- Lines: `_LinesSection`. "Agregar pedido" is replaced by **"Agregar de la factura"**;
  "Agregar producto" stays, gated on Create on 56. **FR-004, FR-005, FR-007**
- Relations: `_RelationsSection` with the type-01 row, **no add, no remove**. The folio is a
  link to the invoice (↗, see Open Question 4). **FR-003, FR-007**
- Totals: `InvoiceTotals`, unchanged computation. **FR-008**
- Action row: `FilledButton` Confirmar. **FR-011**

### State: draft with lines (Update on 23, no Create on 56)

```text
┌ ← Nota de crédito · Borrador #63930 ────────────────────────────────────────────────────┐
│ ⓘ Borrador. Agrega las partidas que acreditas y confírmala para sellarla.               │
│ Tipo Nota de crédito   Folio (al confirmar)   Estado (Borrador)               [Editar] │
│ Método PUE   Forma de pago 03 Transferencia   Uso G03   Emisión (al confirmar)          │
│                                                                                         │
│ Partidas                                                     [Agregar de la factura]    │
│ Código   Descripción             Cant.  Unidad  Precio    Desc.  IVA   Importe          │
│ TOR-12   Tornillo 1/2" caja      2      Caja    150.00    —      16 %  300.00   ✎ 🗑   │
│ CEM-50   Cemento gris 50 kg      1      Saco    210.00    5 %    16 %  199.50   ✎ 🗑   │
│                                                                                         │
│ Documentos relacionados                                                                 │
│   01 · Nota de crédito   A5238 ↗   6F1C…9A2E                                            │
│                                         Subtotal 499.50   IVA 79.92   Total 579.42     │
│                                                                           [Confirmar]   │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- No "Agregar producto": the user lacks Create on 56. **FR-005, FR-017**
- Line ✎ opens the existing `InvoiceLineDialog` (quantity, price, discount, description).
  🗑 uses `showRemoveInvoiceLineDialog`. **FR-006**
- Copied lines show **no "Pedido" chip** even though they carry an order line (Open
  Question 3).

### State: confirm refused (over the invoice's remaining total)

```text
│                                         Subtotal 499.50   IVA 79.92   Total 579.42     │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⚠ La nota de crédito excede lo que queda de la factura A5238: 400.00.               │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                           [Confirmar]   │
```

- `FiscalDocumentRefusal`, localized from `credit_exceeds_invoice` with series+folio and the
  remaining amount. Same slot for `payment_form_required` and the reused 066 codes
  (`no_lines`, `issue_date_out_of_range`, `no_valid_certificate`, …). **FR-012, FR-016**

### State: sealed

```text
┌ ← Nota de crédito NC118 ────────────────────────────────────────────────────────────────┐
│ ⓘ Sellada, sin validez fiscal todavía. Timbrala para emitirla, o reábrela si            │
│   necesitas corregirla (conserva el folio).                                             │
│ Tipo Nota de crédito   Folio NC118   Estado (Sellado)   Emisión 18/11/2026 10:05        │
│ …lines (no actions), relation 01 → A5238 ↗, totals…                                     │
│                                                              [Reabrir]  [■ Timbrar]     │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Same banner and actions as a sealed invoice (072). Reabrir is new for this type.
  **FR-011, FR-014**

### State: issued / stamping / cancellation pending / cancelled

Exactly spec 072's states for any document, plus the relation row to the invoice. No
"Emitir nota de crédito" here (a credit note is not an invoice). **FR-013, FR-014**

### State: read-only user (Read on 23), any state

```text
│ Tipo Nota de crédito   Folio NC118   Estado (Sellado)                                   │
│ …lines (no actions), relation 01 → A5238 ↗, totals…                                     │
│                                                                    (no action row)      │
```

- No Editar, no line actions, no Confirmar/Reabrir/Timbrar. The invoice link still works. **FR-017**

### State: legacy credit note without a relation

```text
│ ⓘ Este tipo de documento solo se puede consultar.          ← only if it is not a draft  │
│ Tipo Nota de crédito   Folio NC12   Estado (Timbrado)                                   │
│ …lines, totals…   (no "Documentos relacionados" section)                                │
```

- `_RelationsSection` hidden when empty and not editable, as today. US4 sc. 3.

### State: loading / not found / load failed

Unchanged from spec 066 (`_NotFound`, `_LoadFailed`).

### Compact tier

```text
┌ ← NC · Borrador #63930 ───────┐
│ ⓘ Borrador. Agrega las        │
│   partidas que acreditas…     │
│ Tipo Nota de crédito          │
│ Estado (Borrador)    [Editar] │
│ Forma de pago 03 · Uso G03    │
├───────────────────────────────┤
│ Partidas                      │
│ [Agregar de la factura]       │
│ [Agregar producto]            │
│ Tornillo 1/2" caja      ✎ 🗑  │
│ Cant. 2 Caja · Precio 150.00  │
│ IVA 16 % · Importe 300.00     │
├───────────────────────────────┤
│ Relacionados                  │
│ 01 · A5238 ↗                  │
│ 6F1C…9A2E                     │
├───────────────────────────────┤
│ Total 579.42                  │
│                   [Confirmar] │
└───────────────────────────────┘
```

- Lines use the existing compact line cards. The two add buttons wrap to their own rows.
- The AppBar title shortens "Nota de crédito" to "NC" only if the full title overflows
  (Open Question 2).

---

## Dialog: Agregar de la factura

### State: populated

```text
┌ Agregar de la factura A5238 ────────────────────────────────────────────────────────────┐
│ Elige las partidas que acreditas y la cantidad de cada una.                              │
│                                                                                          │
│ ☐  Código   Descripción             Cant. factura   Precio    Desc.  IVA   Cantidad      │
│ ☑  TOR-12   Tornillo 1/2" caja      10              150.00    —      16 %  [  2      ]   │
│ ☐  CEM-50   Cemento gris 50 kg      4               210.00    5 %    16 %  [  4      ]   │
│ ☑  VAR-38   Varilla 3/8"            20              95.00     —      16 %  [ 25      ]   │
│                                                    ↳ Máximo 20 (la cantidad facturada)  │
│                                                                                          │
│                                                           [Cancelar] [Agregar (2)]      │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- `ResponsiveDialog` hosting a `DataTableView` with a checkbox column and a per-row
  quantity field (`CompactField`). Checking a row enables its quantity, defaulting to the
  invoice line's. **FR-004**
- Client-side check: quantity > 0 and ≤ invoice quantity, shown under the field; "Agregar"
  disabled while any checked row is invalid. The server's `credit_quantity_exceeds_line`
  is mapped too, in case of a race. **FR-004, FR-016**
- All invoice lines are offered, including ones already copied (spec assumption: the
  server doesn't trace a copy to its source).
- Sending: one request per checked line, in order (Open Question 1).

### State: loading / error

```text
┌ Agregar de la factura A5238 ─────────────────┐
│               ◌  Cargando partidas…          │     ← ListStateViews loading
│ ⚠ No se pudo cargar la factura. [Reintentar] │     ← ListStateViews error
│                                   [Cerrar]   │
└──────────────────────────────────────────────┘
```

- The lines come from loading the related invoice. `ListStateViews` covers loading and error.

### Compact tier

```text
┌ Agregar de la factura A5238 ──┐
│ ☑ Tornillo 1/2" caja          │
│   Factura 10 · 150.00 · 16 %  │
│   Cantidad [  2   ]           │
│ ☐ Cemento gris 50 kg          │
│   Factura 4 · 210.00 · 5 %    │
├───────────────────────────────┤
│      [Cancelar] [Agregar (1)] │
└───────────────────────────────┘
```

- Rows become two-line cards. The code, discount and tax columns move into the second line,
  and the quantity field shows only for checked rows. Full-screen on phone, per
  `ResponsiveDialog`.

---

## Dialog: Encabezado (credit note)

```text
┌ Encabezado ───────────────────────────────────────┐
│ Forma de pago   [03 Transferencia electrónica  ▾] │
│ Uso CFDI        [G03 Gastos en general          ▾] │
│ Fecha de emisión [            ] (vacío = al confirmar)│
│ Referencia      [______________________________]  │
│ Notas           [______________________________]  │
│                                                   │
│ Método de pago  PUE (fijo en notas de crédito)    │
│                              [Cancelar] [Guardar] │
└───────────────────────────────────────────────────┘
```

- Existing `InvoiceHeaderDialog` in a credit-note mode: only these five fields, laid out
  with `ResponsiveFormGrid`. Terms, currency and other invoice fields are not shown.
  **FR-009**
- Forma de pago excludes 99, so the dialog cannot reintroduce it. **FR-010**
- `field_not_for_type` is mapped in case the server and app disagree. **FR-016**

---

## Screen: Facturas list (`/invoicing/fiscal-documents`)

No change. The Tipo filter already lists "Nota de crédito", and new credit notes appear
with their state chip. The list's "Nueva factura" still creates invoices only (spec
assumption). **US4 sc. 2**

---

## Open Questions

1. **Several lines from the invoice: one request each, or one at a time?** The server
   copies one line per request. Options: (a) multi-select, sent one after another,
   stopping at the first refusal, keeping the lines already added, and saying which line
   failed; (b) one line per dialog. The wireframe assumes (a), because returns usually span
   several lines.
2. **Draft title.** Today any draft is titled "Borrador #id", which hides that it is a credit
   note. Options: (a) "Nota de crédito · Borrador #id"; (b) keep "Borrador #id" and rely on
   the Tipo fact. The wireframe assumes (a) for credit notes only, leaving invoice drafts as
   they are.
3. **"Pedido" chip on copied lines.** Copied lines keep their order line, so today's marker
   would read "Pedido" on a credit note. Options: (a) no chip on credit notes; (b) a
   "Factura" chip on every line that has an order line. The wireframe assumes (a): the chip
   would claim a source it can't actually trace.
4. **Link from a relation to its document.** Relation rows are plain text today. FR-003 needs
   the credit note → invoice link. Options: (a) make every relation row's folio a link, on
   all document types (also helps 066's 04/07 relations); (b) only the type-01 row on credit
   notes. The wireframe assumes (a), since it's the same widget, but that touches 066's
   surface.
5. **Where to ask for the real payment form when the invoice is PPD (99).** Options: (a) a
   draft banner pointing to Editar (drawn); (b) ask for it in the create confirmation. The
   wireframe assumes (a), because the create route takes only the invoice, so (b) would need
   a second request right after creation.
6. **No reference amount on the draft.** The clerk can't see the invoice's total or what
   remains to credit until confirm refuses. The relation row could show the invoice's total
   by loading the invoice (the copy dialog loads it anyway), but not what remains. The
   wireframe shows nothing: the spec's assumption stands, and what remains to credit is an
   mbe-api follow-up.
