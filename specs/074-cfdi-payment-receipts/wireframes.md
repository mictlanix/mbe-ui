# Wireframes: CFDI Payment Receipts (REP)

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-18 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every
dimension, colour and spacing comes from the design tokens (constitution §V).

This feature adds **no new screen or route**. It changes three existing surfaces and adds
or extends four dialogs:

| Surface | Route / host | Change |
|---|---|---|
| Customer payment detail | `/sales/payments/:id` (spec 054) | "Emitir complemento de pago" next to "Aplicar" |
| Emitir complemento de pago | dialog over the payment | New: pick the recipient RFC, create |
| Facturas list | `/invoicing/fiscal-documents` | "Nuevo complemento de pago" next to "Nueva factura" |
| Nuevo complemento de pago | dialog over the list | Existing `showNewInvoiceDialog`, receipt mode |
| Fiscal document detail, **receipt** | `/invoicing/fiscal-documents/:id` | Editable as a draft: payment data, paid invoices, confirm, reopen |
| Encabezado | dialog over the receipt | Existing `InvoiceHeaderDialog`, receipt fields |
| Agregar factura / Editar importe | dialogs over the receipt | New: pick a PPD invoice; change an amount |

The detail keeps 072/073's structure: an empty `AppBar.actions` and every action in the
body's action row (`Wrap`, end-aligned, primary last). Receipt order: banner → header facts
→ **payment** → **paid invoices** → cancellations → **payment summary** → notice/refusal →
action row. The receipt replaces Partidas, Documentos relacionados and `InvoiceTotals`
(Open Questions 3, 4).

---

## Screen: Customer payment detail (`/sales/payments/:id`)

### State: any payment, user with Create on 23

```text
┌ ← Pago ─────────────────────────────────────────────────────────────────────────────────┐
│ Pago #4127   (Verificado)                                                               │
│ Monto 11,600.00 MXN    Aplicado 11,600.00 MXN    Por aplicar 0.00 MXN                   │
│ [Aplicar]  [Emitir complemento de pago]                  ← Aplicar only when unapplied  │
│                                                                                         │
│ Cliente Ferretería Sol        Forma de pago 03 Transferencia   Referencia SPEI 99812    │
│ …facility, cashier, session (unchanged)…                                                │
│                                                                                         │
│ Aplicaciones                                                                            │
│ Pedido      Fecha        Importe                                                        │
│ #88213 ↗    10/11/2026   11,600.00                                                      │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- New `OutlinedButton.icon` "Emitir complemento de pago" in the same `Wrap` as "Aplicar",
  after it. **FR-001**
- Shown when the user has Create on 23, in every payment state (Open Question 1). Absent
  otherwise, not disabled. **FR-017**
- The payment does not know whether it already has a receipt (spec assumption). A second
  try is refused inside the dialog, which names the existing receipt. **FR-004**

### State: user without Create on 23

```text
│ [Aplicar]                                                                               │
```

- Unchanged from spec 059.

### Compact tier

```text
┌ ← Pago ───────────────────────┐
│ Pago #4127  (Verificado)      │
│ Monto 11,600.00 MXN           │
│ Aplicado 11,600.00 MXN        │
│ Por aplicar 0.00 MXN          │
│ [Aplicar]                     │
│ [Emitir complemento de pago]  │
└───────────────────────────────┘
```

- The `Wrap` breaks the two buttons onto separate rows. Nothing is dropped.

---

## Dialog: Emitir complemento de pago (from a payment)

### State: picking the recipient

```text
┌ Emitir complemento de pago ─────────────────────────────────┐
│ Pago #4127 · Ferretería Sol · 11,600.00 MXN · 12/11/2026    │
│                                                             │
│ RFC del receptor   [FSO010101AB1 · Ferretería Sol SA    ▾]  │
│                                                             │
│ Se creará un borrador con la fecha, el monto, la forma de   │
│ pago y la referencia del pago, y las facturas PPD de sus    │
│ pedidos.                                                    │
│                                          [Cancelar] [Crear] │
└─────────────────────────────────────────────────────────────┘
```

- `ResponsiveDialog`. The customer is fixed (the payment's). The RFC dropdown lists the
  customer's taxpayers, as in `showNewInvoiceDialog`; with a single RFC it is preselected.
  **FR-001**
- On success the dialog closes and the app opens the new receipt. **FR-003**
- While the request runs, both buttons are disabled. **FR-018**

### State: refused

```text
│ ┌ ⚠ Este pago ya tiene el complemento CP412. ─────────────┐ │
│ └─────────────────────────────────────────────────────────┘ │
```

- `FormErrorBanner`, localized from the code. Same slot for: payment already has a receipt
  (series+folio), issuer without a payment receipt series, recipient not linked, and user
  without a facility. **FR-004, FR-016**

### State: customer without tax data

```text
│ ⓘ El cliente no tiene RFC registrado. Agrégalo en su ficha  │
│   para emitir el complemento.                     [Cerrar]  │
```

- Same text and key pattern as `new_invoice_no_taxpayers`; no "Crear". US1 sc. 5.

### State: loading the customer

- `ListStateViews` loading in place of the dropdown. A failed load shows the error with
  "Reintentar".

---

## Screen: Facturas list (`/invoicing/fiscal-documents`)

### State: user with Create on 23

```text
┌ Facturas ───────────────────────────────────────────────────────────────────────────────┐
│ [🔍 Buscar folio, UUID, RFC…] [Emisor ▾] [Tipo ▾] [Estado ▾] [Fechas]                   │
│                                      [Nuevo complemento de pago] [+ Nueva factura]      │
│ …DataTableView unchanged; Tipo "Complemento de pago" already filterable…                │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- New `OutlinedButton` "Nuevo complemento de pago" before the existing `FilledButton.icon`
  "Nueva factura", which keeps the primary slot (Open Question 2). **FR-002**
- Both absent without Create on 23. **FR-017**
- The list rows, filters and pagination are unchanged. **US5 sc. 3**

### Compact tier

- Both buttons wrap under the filter bar, full width. Nothing else changes.

### Dialog: Nuevo complemento de pago (by hand)

```text
┌ Nuevo complemento de pago ──────────────────────────────────┐
│ Cliente            [🔍 Ferretería Sol                    ]  │
│ RFC del receptor   [FSO010101AB1 · Ferretería Sol SA    ▾]  │
│                                                             │
│ Captura el pago y las facturas que liquida en el borrador.  │
│                                          [Cancelar] [Crear] │
└─────────────────────────────────────────────────────────────┘
```

- Existing `showNewInvoiceDialog` with a receipt mode: title, hint text and create call
  change, and the refusals are the same as in the payment dialog. **FR-002, FR-016**

---

## Screen: Receipt detail (`/invoicing/fiscal-documents/:id`, type Complemento de pago)

### State: draft from a payment, proposals filled, amounts match (Update on 23)

```text
┌ ← Complemento de pago #63940 ───────────────────────────────────────────────────────────┐
│ ⓘ Borrador. Revisa el pago y las facturas que liquida y confírmalo para sellarlo.       │
│ Tipo Complemento de pago   Folio (al confirmar)   Estado (Borrador)           [Editar] │
│ Receptor FSO… · Ferretería Sol   Cliente Ferretería Sol   Emisor MIC010101AAA          │
│ Uso CP01   Moneda MXN   Emisión (al confirmar)                                          │
│                                                                                         │
│ Pago                                                                                    │
│ Fecha 12/11/2026   Monto 11,600.00   Forma 03 Transferencia   No. operación SPEI 99812 │
│ Banco ordenante —   Pago de origen #4127 ↗                                              │
│                                                                                         │
│ Facturas pagadas                                                    [Agregar factura]   │
│ Folio     UUID         Parcialidad  Saldo anterior  Importe pagado  Saldo insoluto      │
│ A5238 ↗   6F1C…9A2E    2            8,000.00        8,000.00        0.00        ✎ 🗑    │
│ A5301 ↗   0B7D…11C4    1            5,800.00        3,600.00        2,200.00    ✎ 🗑    │
│                                                                                         │
│                 Monto del pago 11,600.00   Asignado 11,600.00   Por asignar 0.00        │
│                                                                         [Confirmar]     │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Banner: `_StatusBanner` with receipt draft text. **FR-014**
- Header facts: `_HeaderFacts`; Uso CP01 and Moneda MXN read-only; "Editar" opens the
  header dialog. **FR-005**
- **Pago**: a facts row (`FactStripRow`) with the payment data. "Pago de origen" links to
  the payment for users with Read on customer payments, plain text otherwise; absent on
  by-hand receipts. **FR-015**
- **Facturas pagadas**: `DataTableView`. Folio links to the invoice. ✎ opens "Editar
  importe", 🗑 removes after confirmation. Draft values are live, sealed ones stored.
  **FR-007, FR-008, FR-009**
- **Payment summary** in place of `InvoiceTotals`: payment amount, assigned and
  unassigned. **FR-010**
- No Partidas, no Documentos relacionados, no "Agregar pedido/producto". **FR-011**
- Action row: `FilledButton` Confirmar. **FR-012**

### State: draft from a payment, no invoices proposed

```text
│ ⓘ No se encontraron facturas PPD timbradas de los pedidos de este pago para este        │
│   receptor. Agrégalas con "Agregar factura".                                            │
│ …header facts, Pago…                                                                    │
│ Facturas pagadas                                                    [Agregar factura]   │
│   Sin facturas.                                                                         │
│                 Monto del pago 11,600.00   Asignado 0.00   Por asignar 11,600.00 ⚠     │
│                                                                         [Confirmar]     │
```

- Banner shown only for a payment-backed draft with no paid invoices. **FR-003**
- "Por asignar" in the warning colour (`colorScheme.error` text) whenever it is not zero.
  **FR-010, SC-005**

### State: draft by hand, empty

```text
│ ⓘ Borrador. Captura el pago en el encabezado y agrega las facturas que liquida.         │
│ …header facts…                                                                          │
│ Pago                                                                                    │
│ Fecha —   Monto —   Forma —   No. operación —   Banco ordenante —                       │
│ ⚠ Elige la forma de pago real en el encabezado antes de confirmar.                      │
│ Facturas pagadas                                                    [Agregar factura]   │
│   Sin facturas.                                                                         │
│                      Monto del pago —   Asignado 0.00   Por asignar —                   │
│                                                                         [Confirmar]     │
```

- The payment-form warning shows while the form is empty or 99. **FR-006**
- "Agregar factura" is offered even with no payment amount; the server then defaults the
  amount to the balance capped by nothing (Open Question 5).

### State: amounts do not match (over-assigned after lowering the payment)

```text
│                 Monto del pago 10,000.00   Asignado 11,600.00   Por asignar -1,600.00 ⚠ │
```

- The negative remainder stays visible. Confirm is still offered; the server refuses it.
  Edge case "payment amount lowered".

### State: confirm or row action refused

```text
│                 Monto del pago 11,600.00   Asignado 9,000.00   Por asignar 2,600.00 ⚠   │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⚠ La suma de los importes pagados debe ser igual al monto del pago.                 │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                         [Confirmar]     │
```

- `FiscalDocumentRefusal`, localized from the code. Same slot for: payment form required,
  payment date out of range, amounts exceed the payment, and reused 066/072 codes
  (`issue_date_out_of_range`, `no_valid_certificate`, …). **FR-016**

### State: sealed

```text
┌ ← Complemento de pago CP413 ────────────────────────────────────────────────────────────┐
│ ⓘ Sellado, sin validez fiscal todavía. Tímbralo para emitirlo, o reábrelo si            │
│   necesitas corregirlo (conserva el folio).                                             │
│ Tipo Complemento de pago   Folio CP413   Estado (Sellado)   Emisión 18/11/2026 11:20    │
│ …Pago, Facturas pagadas (no ✎ 🗑, no Agregar; stored values), payment summary…          │
│                                                              [Reabrir]  [■ Timbrar]     │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Same banner and actions as a sealed invoice (072). Reabrir is new for this type.
  **FR-012, FR-014**

### State: issued / stamping / cancellation pending / cancelled

Spec 072's states for any document, with the Pago and Facturas pagadas sections read-only.
No receipt-specific actions. **FR-013**

### State: read-only user (Read on 23), any state

```text
│ Tipo Complemento de pago   Folio CP413   Estado (Sellado)                                │
│ …Pago, Facturas pagadas (links work, no row actions), payment summary…                  │
│                                                                    (no action row)      │
```

- No Editar, no Agregar factura, no ✎ 🗑, no Confirmar, Reabrir or Timbrar. **FR-017**

### State: legacy receipt

- Same frames as above in whatever state it is in. Not a draft, so read-only (no "only
  consultable" banner any more: type 200 becomes an editable kind). "Pago de origen" absent.

### State: loading / not found / load failed

Unchanged from spec 066 (`_NotFound`, `_LoadFailed`).

### Compact tier

```text
┌ ← CP · Borrador #63940 ───────┐
│ ⓘ Borrador. Revisa el pago…   │
│ Tipo Complemento de pago      │
│ Estado (Borrador)    [Editar] │
├───────────────────────────────┤
│ Pago                          │
│ 12/11/2026 · 11,600.00        │
│ 03 Transferencia              │
│ No. op. SPEI 99812            │
│ Pago de origen #4127 ↗        │
├───────────────────────────────┤
│ Facturas pagadas              │
│ [Agregar factura]             │
│ A5238 ↗              ✎ 🗑     │
│ Parcialidad 2                 │
│ Saldo ant. 8,000.00           │
│ Pagado 8,000.00 · Insoluto 0  │
├───────────────────────────────┤
│ Monto 11,600.00               │
│ Asignado 11,600.00            │
│ Por asignar 0.00              │
│                   [Confirmar] │
└───────────────────────────────┘
```

- Paid invoices become cards; the UUID is dropped from the card (it is on the invoice).
- The summary stacks vertically.
- The title shortens to "CP" only if the full title overflows, as decided for 073.

---

## Dialog: Encabezado (receipt)

```text
┌ Encabezado ─────────────────────────────────────────────────┐
│ Fecha del pago     [12/11/2026      📅]                     │
│ Monto del pago     [   11,600.00     ]                      │
│ Forma de pago      [03 Transferencia electrónica         ▾] │
│ No. de operación   [SPEI 99812                         ]    │
│ Banco ordenante    [                                   ]    │
│                    Solo si el banco ordenante es extranjero │
│ Fecha de emisión   [            ] (vacío = al confirmar)    │
│ Notas              [                                   ]    │
│                                                             │
│ Uso CFDI CP01 · Moneda MXN (fijos en complementos de pago)  │
│                                        [Cancelar] [Guardar] │
└─────────────────────────────────────────────────────────────┘
```

- Existing `InvoiceHeaderDialog`, receipt mode, laid out with `ResponsiveFormGrid`.
  **FR-005**
- No 99 in the payment form list, so the dialog cannot set it (073's initial-value trap
  applies: a 99 already stored must not crash the dropdown). **FR-006**
- No. de operación capped at 50 characters with a counter. Monto > 0.
- `field_not_for_type` mapped in case the server and app disagree. **FR-016**

---

## Dialog: Agregar factura

### State: searching

```text
┌ Agregar factura ────────────────────────────────────────────────────────────────────────┐
│ Facturas timbradas de MIC010101AAA para FSO010101AB1.                                   │
│ [🔍 FSO010101AB1                                     ]                                  │
│                                                                                         │
│ ○ A5301   18/10/2026   0B7D…11C4   Total 5,800.00                                       │
│ ● A5340   02/11/2026   77A2…D0E9   Total 3,480.00                                       │
│ ○ A5402   09/11/2026   C1E4…5B70   Total 1,160.00                                       │
│                                                    [Cargar más]                         │
│                                                                                         │
│ Importe pagado  [            ]  vacío = el saldo, hasta lo que falta asignar            │
│                                                                                         │
│                                                         [Cancelar] [Agregar]            │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- `ResponsiveDialog` hosting `FiscalDocumentCandidatePicker` (072) with issuer, status
  issued, type invoice, initial search = recipient RFC, other recipients dropped, and
  invoices already on the receipt excluded. **FR-007**
- The picker cannot tell PPD from PUE or show a balance (spec assumption). A PUE pick is
  refused by the server and shown inline. **FR-016**
- Optional amount: blank means the server's default (Open Question 5).

### State: refused

```text
│ ┌ ⚠ La factura A5340 no se puede pagar con este complemento (no es PPD, está     ┐ │
│ │   cancelada o tiene una cancelación en proceso).                               │ │
│ └────────────────────────────────────────────────────────────────────────────────┘ │
```

- `FormErrorBanner`; the dialog stays open to pick another. Same slot for amount above the
  balance (with the balance) and amounts above the payment.

### State: empty / loading / error

- Picker's own `_empty` ("No hay facturas timbradas para este receptor."), loading and
  retry states, unchanged from 072.

### Compact tier

- Full-screen per `ResponsiveDialog`; rows show folio and total on one line, date and UUID
  on a second.

---

## Dialog: Editar importe

```text
┌ Importe pagado · A5301 ─────────────────────┐
│ Saldo anterior 5,800.00                     │
│ Importe pagado [     3,600.00 ]             │
│ ↳ Máximo 5,800.00 (el saldo anterior)       │
│                         [Cancelar] [Guardar]│
└─────────────────────────────────────────────┘
```

- Client-side check: amount > 0 and ≤ previous balance; the server's balance and
  over-payment refusals show inline too. **FR-008, FR-016**

---

## Open Questions

1. **When to offer "Emitir complemento de pago" on a payment.** Options: (a) always, for
   Create on 23; (b) only once the payment is applied to orders; (c) only once verified
   (spec 060). The wireframe assumes (a): the server allows it, and an unapplied payment
   still yields a by-hand-style draft. (b) would hide it for legacy-order payments.
2. **Facturas list: two buttons or one "Nuevo ▾" menu.** Options: (a) a second
   `OutlinedButton` "Nuevo complemento de pago" (drawn); (b) turn "Nueva factura" into a
   menu of types. The wireframe assumes (a): no new widget, and credit notes don't start
   from the list anyway.
3. **Partidas section on a receipt.** A receipt has no product lines (the server writes the
   SAT "Pago" concept itself). Options: (a) hide Partidas and Documentos relacionados on
   receipts (drawn); (b) show them empty and read-only. The wireframe assumes (a). Plan
   should check what `lines` and `relations` the API returns for a receipt.
4. **Totals on a receipt.** `InvoiceTotals` would show 0.00. Options: (a) replace it with
   the payment summary (Monto del pago / Asignado / Por asignar) (drawn); (b) keep both.
   The wireframe assumes (a).
5. **Adding an invoice before the payment amount is set.** The server defaults the amount
   to min(balance, unassigned); with no payment amount, "unassigned" is unclear. Options:
   (a) let the server decide and show what comes back (drawn); (b) hide "Agregar factura"
   until the header has an amount. Plan should check the server's behaviour with a null
   amount.
6. **Banner text for a payment-backed draft with no proposals.** The server doesn't say
   why it proposed nothing (no PPD invoices, another recipient, or none stamped). The
   wireframe uses one generic sentence that covers all three.
7. **Ordering bank.** SAT's `NomBancoOrdExt` is only for foreign banks. Options: (a) a plain
   text field with a hint (drawn); (b) hide it. The wireframe assumes (a), because the
   server accepts it and legacy receipts may carry it.
