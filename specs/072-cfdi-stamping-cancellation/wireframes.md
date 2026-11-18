# Wireframes: CFDI Stamping, Refresh and Cancellation

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-17 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every
dimension, colour and spacing comes from the design tokens (constitution §V).

This feature adds **no new screen or route**. It changes two existing ones from spec 066
and adds two dialogs:

| Surface | Route / host | Change |
|---|---|---|
| Facturas list | `/invoicing/fiscal-documents` | Six state chips; six options in the state filter |
| Fiscal document detail | `/invoicing/fiscal-documents/:id` | Banners, stamp facts, simulated badge, history section, actions |
| Stamp confirmation | dialog over the detail | New |
| Cancel CFDI | dialog over the detail | New, with a substitute picker for reason 01 |

The detail keeps spec 066's structure: an empty `AppBar.actions` and every action in the
body's action row. Order: banner → header facts → lines → relations → **cancellations
(new)** → totals → refusal → action row (primary action last).

---

## Screen: Facturas list (`/invoicing/fiscal-documents`)

### State: populated (regular)

```text
┌ Facturas ───────────────────────────────────────────────────────────────────────────────┐
│ [🔍 Serie y folio, UUID, RFC o nombre……………]   [Filtros (1)]            [+ Nueva factura] │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Folio    Tipo     Emisor        Receptor                Emisión       Estado        Total │
│ A5240    Factura  MIC010101AAA  Ferretería Sol · FSO…   17/11/2026    (Timbrando)    1,160│
│ A5239    Factura  MIC010101AAA  Juan Pérez · PEJ…       17/11/2026    (Cancelación   2,320│
│                                                                         pendiente)        │
│ A5238    Factura  MIC010101AAA  Público general         17/11/2026    (Emitido)        580│
│ A5237    Factura  MIC010101AAA  Ferretería Sol · FSO…   16/11/2026    (Cancelado)      464│
│ A5236    Factura  MIC010101AAA  Ferretería Sol · FSO…   16/11/2026    (Sellado)          —│
│ #63910   Factura  MIC010101AAA  Ferretería Sol · FSO…   —             (Borrador)         —│
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                               ‹  1  2  3 … ›   25 ▾      │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Search and filter: `CatalogFilterBar` / `CatalogSearchBar`, unchanged.
- Rows: `DataTableView`, unchanged columns (spec 066 FR-004).
- Estado: `FiscalDocumentStatusChip`, which renders the shared `StatusChip`. It gains two
  colour pairs: Timbrando and Cancelación pendiente use a "waiting" pair (tertiary
  container) that is neither the draft/sealed neutral nor the cancelled error. **FR-001**
- Pagination: `CatalogPagination`, unchanged.
- The list summary carries no stamp object, so the simulated badge does **not** appear on
  rows (detail only, FR-008).

### State: filter drawer open

```text
                                         ┌ Filtros ───────────────────────┐
                                         │ Emisor        [Todos        ▾] │
                                         │ Tipo          [Todos        ▾] │
                                         │ Estado        [Todos        ▾] │
                                         │   ├ Borrador                    │
                                         │   ├ Sellado                     │
                                         │   ├ Timbrando                   │
                                         │   ├ Emitido                     │
                                         │   ├ Cancelación pendiente       │
                                         │   └ Cancelado                   │
                                         │ Emisión       [dd/mm – dd/mm ] │
                                         │            [Limpiar] [Aplicar] │
                                         └────────────────────────────────┘
```

- `CatalogFilterSheet`; the state picker lists the six values in lifecycle order. **FR-002**
- The filter's state choice already lives in the URL. The two new values make
  "documents that need attention" a link anyone can share.

### State: empty / loading / error

Unchanged from spec 066 (`ListStateViews`). A filter on Timbrando that matches nothing uses
the existing "no results for these filters" empty state.

### Compact tier

```text
┌ Facturas ─────────────────────┐
│ [🔍 Buscar……]       [≡ (1)]  │
├───────────────────────────────┤
│ A5240 · Factura    (Timbrando)│
│ Ferretería Sol      17/11/2026│
│                       1,160.00│
├───────────────────────────────┤
│ A5239 · Factura  (Cancelación │
│                    pendiente) │
│ Juan Pérez          17/11/2026│
│                       2,320.00│
└───────────────────────────────┘
```

- Same compact row as spec 066. "Cancelación pendiente" is the longest chip label and wraps
  to two lines on phone width. See Open Question 5.

---

## Screen: Fiscal document detail (`/invoicing/fiscal-documents/:id`)

Each state below shows only what this feature changes. Lines, relations and totals are
spec 066's and are elided as `…`.

### State: sealed (Update on 23)

```text
┌ ← Factura A5236 ────────────────────────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⓘ Sellada, sin validez fiscal todavía. Timbrala para emitirla, o reábrela si        │ │
│ │   necesitas corregirla (conserva el folio).                                         │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│ Folio A5236   Estado (Sellado)   Emisión 16/11/2026 10:42   Receptor FSO… · Ferretería… │
│ …header facts, lines, totals…                                                           │
│                                                              [Reabrir]  [■ Timbrar]     │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Banner: `_StatusBanner`, new sealed text that replaces "stamping is not available yet".
  **FR-005**
- Action row: Reabrir stays (`OutlinedButton`). **Timbrar** is the new primary
  (`FilledButton`, last). Both are absent without Update on 23. **FR-006, FR-020**
- No PDF or XML yet (FR-005).

### State: sealed, read-only user (Read on 23 only)

```text
│ ⓘ Sellada, sin validez fiscal todavía.                                                  │
│ …header facts, lines, totals…                                                           │
│                                                                    (no action row)      │
```

- Read-only users get a shorter banner, without the "stamp or reopen" advice. **FR-020**

### State: stamping

```text
┌ ← Factura A5240 ────────────────────────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⏳ Timbrando desde 17/11/2026 11:05. El PAC aún no confirma el resultado; el         │ │
│ │   sistema lo consulta cada 10 minutos, o puedes consultarlo ahora.                  │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│ Folio A5240   Estado (Timbrando)   Emisión 17/11/2026 11:03   …                         │
│ …header facts, lines, totals (server total)…                                            │
│                                                                   [■ Consultar estado]  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Banner uses `stamping_since` for the time. Same "waiting" colour pair as the chip.
- No edit, confirm or reopen. Read-only. **FR-004, SC-003**
- **Consultar estado** (refresh) is the only action. **FR-015**

### State: refresh came back unchanged

```text
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⓘ Sigue en proceso. Vuelve a consultar en unos minutos.                     [ ✕ ]  │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                   [■ Consultar estado]  │
```

- An info notice in the refusal slot, not an error. The server answered 200 with the same
  state, so nothing failed. **FR-016**. See Open Question 3 on how this is told apart from
  `nothing_to_refresh`.

### State: issued (new-MBE stamp, simulated)

```text
┌ ← Factura A5238 ────────────────────────────────────────────────────────────────────────┐
│ Folio A5238   Estado (Emitido) [⚠ Timbrado simulado, sin validez fiscal]                │
│ Emisión 17/11/2026 09:12   Receptor PEJ800101AB1 · Juan Pérez   Uso G03   PUE · 01      │
│ UUID 6F1C2A9E-…-9B21          Timbrado 17/11/2026 09:13                                 │
│ Certificado SAT 00001000000509846663      PAC SIM010101SIM                              │
│ …lines, relations, totals…                                                              │
│                               [⎙ Ver PDF] [⇩ Descargar XML]   [Cancelar ante el SAT]    │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Header facts: the existing `CompactField` grid in `_HeaderFacts`. The UUID fact already
  exists. New facts: Timbrado (stamp date), Certificado SAT and PAC (provider RFC).
  **FR-007**
- Simulated badge: a warning-coloured chip beside the state chip, in the same fact. Shown
  only when `stamp.simulated`. **FR-008**. It needs a second `StatusChip` colour mapping,
  not a new widget.
- Action row: PDF and XML as today, plus **Cancelar ante el SAT**, an `OutlinedButton` in
  the error colour. It is not the primary action, since cancelling is the exception.
  **FR-010**
- No banner on an issued document, as in spec 066.

### State: issued (legacy stamp)

```text
│ Folio GR4776   Estado (Emitido)                                                         │
│ UUID 1A2B…   Timbrado 03/05/2025 13:20   Certificado SAT —   PAC —                     │
```

- No badge. Facts the server lacks for a legacy stamp show the `emptyValuePlaceholder`.
  Spec US5-5. See Open Question 4 on whether `stamp` is null for legacy documents.

### State: cancellation pending

```text
┌ ← Factura A5239 ────────────────────────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⏳ Cancelación solicitada el 17/11/2026 12:30. El SAT espera que el receptor la      │ │
│ │   acepte; mientras tanto la factura sigue vigente.                                  │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│ Folio A5239   Estado (Cancelación pendiente)   …stamp facts…                            │
│ …lines, relations…                                                                      │
│ Cancelaciones                                                                           │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ 02 Errores sin relación   (Pendiente)   Solicitó M. López · 17/11/2026 12:30        │ │
│ │                                         Respuesta del SAT —   Resuelta —            │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│ …totals…                                                                                │
│                              [⎙ Ver PDF] [⇩ Descargar XML]   [■ Consultar estado]       │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Banner: the open request's `requested_at`, and it says the document is still live. FR-013
  and the edge case.
- Cancel is absent while a request is open; Refresh is the primary. **FR-015, FR-020**
- PDF and XML stay available. **FR-005**

### State: cancelled, with history

```text
┌ ← Factura A5237 ────────────────────────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⊘ Cancelada el 17/11/2026.                                                          │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│ Folio A5237   Estado (Cancelado)   …stamp facts…                                        │
│ Sustituida por 9C3D…-77AF                                                               │
│ Cancelaciones                                                                           │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ 01 Errores con relación   (Aceptada)    Solicitó M. López · 17/11/2026 12:40        │ │
│ │   Sustituto 9C3D…-77AF                  Respuesta 17/11/2026 12:41                  │ │
│ │                                         Resuelta 17/11/2026 12:41                   │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 02 Errores sin relación   (Rechazada)   Solicitó M. López · 17/11/2026 12:30        │ │
│ │   PAC 2001 · "El receptor rechazó la    Respuesta 17/11/2026 12:35                  │ │
│ │   solicitud de cancelación"             Resuelta 17/11/2026 12:36                   │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│ …totals…                                                                                │
│                                            [⎙ Ver PDF] [⇩ Descargar XML]                │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Banner: the existing cancelled banner, unchanged.
- "Sustituida por" fact: `cancellation_substitution`, shown only when set. US5-4
- **Cancelaciones** section: new, newest first, built like `_RelationsSection` (section
  title plus a row per entry). It is not a `DataTableView`, because each entry has up to
  9 facts and wraps. Outcome chip via `StatusChip`. The PAC code and message are verbatim
  in quotes. **FR-017, FR-019**
- The section shows only when the document has at least one request.
- Raw times like `last_checked_at` are not drawn. See Open Question 6.

### State: issued again after a rejected request

```text
│ Folio A5235   Estado (Emitido)                                                          │
│ Cancelaciones                                                                           │
│ │ 03 No se llevó a cabo     (Rechazada)   Solicitó …                                    │ │
│ │   PAC 2001 · "…"                                                                    │ │
│                               [⎙ Ver PDF] [⇩ Descargar XML]   [Cancelar ante el SAT]    │
```

- Cancel is offered again. US4-5

### State: action running

```text
│                               [⎙ Ver PDF] [⇩ Descargar XML]   [ ◌ Cancelando… ]         │
```

- While stamp, cancel or refresh runs, every button in the action row is disabled and the
  running one shows progress. This is spec 066's existing pattern for confirm and reopen.
  **FR-021**

### State: refusal after an action

```text
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⚠ No se puede cancelar: primero cancela los documentos que dependen de esta         │ │
│ │   factura: P12, NC3.                                                                │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                               [⎙ Ver PDF] [⇩ Descargar XML]   [Cancelar ante el SAT]    │
```

```text
│ ⚠ El PAC rechazó el timbrado:                                                           │
│   "CFDI40145 - El campo RFC del receptor no se encuentra en la lista de RFC inscritos"  │
│                                                              [Reabrir]  [■ Timbrar]     │
```

```text
│ ⚠ El PAC no respondió a tiempo. El documento quedó en proceso; consulta su estado.      │
│ ⏳ Timbrando desde 17/11/2026 11:05 …                       (banner, after reload)       │
│                                                                   [■ Consultar estado]  │
```

- `FiscalDocumentRefusal`, the existing shared refusal slot above the action row. It shows
  the localized message for the code. **FR-018**. For `pac.rejected` the lead-in is
  localized and the PAC's text is quoted verbatim. **FR-019**
- After `pac.timeout`, `pac.unavailable` or `lock.busy`, the document is re-read, so the
  banner and actions match its real state. See Open Question 2.
- `issue_date_out_of_range` on stamp says "reábrela, cambia la fecha de emisión y
  confírmala otra vez". It does not add a shortcut button: Reabrir is already in the row.

### Compact tier

```text
┌ ← Factura A5239 ──────────────┐
│ ⏳ Cancelación solicitada el   │
│   17/11/2026 12:30. El SAT    │
│   espera al receptor…         │
│ Folio      A5239              │
│ Estado     (Cancelación       │
│             pendiente)        │
│ [⚠ Timbrado simulado…]        │
│ UUID       6F1C…9B21          │
│ Timbrado   17/11/2026 09:13   │
│ Cert. SAT  0000100000…        │
│ PAC        SIM010101SIM       │
│ …lines, totals…               │
│ Cancelaciones                 │
│ 02 Errores sin relación       │
│ (Pendiente)                   │
│ M. López · 17/11 12:30        │
│ ───────────────────────────── │
│ [⎙ PDF] [⇩ XML]               │
│ [■ Consultar estado         ] │
└───────────────────────────────┘
```

- The facts grid collapses to one column (`ResponsiveFormGrid` behaviour already in
  `_HeaderFacts`). The simulated badge drops to its own line under the state.
- The action row's `Wrap` breaks the primary action onto its own line. Nothing is dropped.
- The history entries stack their facts vertically.

---

## Dialog: Stamp confirmation

### Regular and compact

```text
┌ ¿Timbrar la factura A5236? ──────────────────────────┐
│ Se enviará al PAC para timbrarla ante el SAT. Una     │
│ vez timbrada ya no podrá reabrirse ni editarse; solo  │
│ podrá cancelarse.                                     │
│                                                       │
│ ⚠ Este sistema usa un PAC simulado: el timbre no      │
│   tendrá validez fiscal.                              │
│                                       [Volver] [■ Timbrar] │
└───────────────────────────────────────────────────────┘
```

- The existing confirmation dialog helper from `invoice_action_dialogs.dart`, the same one
  confirm and reopen use (`ResponsiveDialog`; full-screen on compact). **FR-006**
- The simulated-PAC line is conditional, and the app can't know about the simulator before
  the first stamp. See Open Question 1; the wireframe assumes the line is **not** shown.

---

## Dialog: Cancel CFDI

### State: choosing a reason (02–04)

```text
┌ Cancelar factura A5238 ante el SAT ───────────────────────────────┐
│ Motivo                                                             │
│ ( ) 01 Comprobante emitido con errores con relación                │
│ (•) 02 Comprobante emitido con errores sin relación                │
│ ( ) 03 No se llevó a cabo la operación                             │
│ ( ) 04 Operación nominativa relacionada en una factura global      │
│                                                                    │
│ La solicitud se envía al SAT y no se puede deshacer desde aquí.    │
│ Si el SAT requiere la aceptación del receptor, quedará pendiente.  │
│                                     [Volver] [■ Enviar cancelación] │
└────────────────────────────────────────────────────────────────────┘
```

- `ResponsiveDialog` with `hasUnsavedChanges` once a reason is picked. No reason is
  preselected, and Enviar is enabled only once one is chosen. **FR-010, FR-012**
- The dialog's own text is the confirmation (FR-012). There is no second confirmation
  dialog on top of it.
- Reason labels are SAT's official descriptions with their codes. See Open Question 7 on
  whether they come from the server catalogue or are fixed strings.

### State: reason 01, substitute not chosen

```text
┌ Cancelar factura A5238 ante el SAT ───────────────────────────────┐
│ Motivo                                                             │
│ (•) 01 Comprobante emitido con errores con relación                │
│ ( ) 02 …  ( ) 03 …  ( ) 04 …                                       │
│                                                                    │
│ Documento que la sustituye *                                       │
│ ┌────────────────────────────────────────────────────────────────┐ │
│ │ [🔍 PEJ800101AB1………………………… ]                                    │ │
│ │ A5241  Factura  17/11/2026  Juan Pérez   (Emitido)    2,320.00 │ │
│ │ A5199  Factura  10/11/2026  Juan Pérez   (Emitido)      580.00 │ │
│ └────────────────────────────────────────────────────────────────┘ │
│ Debe estar timbrado, vigente, y ser del mismo emisor y receptor.   │
│                                   [Volver] [ Enviar cancelación ]  │
└────────────────────────────────────────────────────────────────────┘
```

- Substitute picker: the document search from spec 066's add-relation dialog, prefilled
  with the recipient's RFC and limited to issued and cancellation-pending documents of the
  same issuer, excluding this document. It is currently private to
  `add_relation_dialog.dart`, so it needs extracting. Open Question 8. **FR-011**
- Enviar stays disabled until a substitute is picked.

### State: reason 01, substitute chosen

```text
│ Documento que la sustituye *                                       │
│ ┌────────────────────────────────────────────────────────────────┐ │
│ │ A5241 · 17/11/2026 · UUID 9C3D…-77AF                 [Cambiar] │ │
│ └────────────────────────────────────────────────────────────────┘ │
│                                 [Volver] [■ Enviar cancelación]    │
```

### State: reason 01, no candidate

```text
│ Documento que la sustituye *                                       │
│   No hay documentos timbrados de este receptor que puedan          │
│   sustituirla. Cancela con el motivo 02 y emite después la factura │
│   nueva relacionándola (04).                                       │
```

- From the edge case "the substitute must already be stamped and live".

### State: inline refusal (dialog stays open)

```text
│ ⚠ El documento sustituto no es válido: debe estar timbrado,        │
│   vigente y ser del mismo emisor y receptor.                       │
│                                 [Volver] [■ Enviar cancelación]    │
```

- `substitution_invalid`, `substitution_required` and `unknown_cancellation_reason` stay
  inline so the clerk can fix the choice. Every other refusal closes the dialog and shows
  in the detail's refusal slot. This is the same split spec 066 uses for the relation
  dialog. **FR-018**

### Compact tier

Full-screen `ResponsiveDialog`. The reasons stack one per line (already drawn that way).
The substitute rows drop Tipo and Total and keep folio, date and state.

---

## Open Questions

1. **Simulated-PAC warning before the first stamp.** The app learns about the simulator
   only from a stamp's `simulated` flag. Options: (a) say nothing before stamping; (b) a
   deployment setting; (c) read it from the last stamped document. *Wireframe assumed (a).*
   The badge after stamping is enough on dev and test, and production can never be
   simulated.
2. **Re-read after "nothing changed" errors.** After `pac.unavailable`, `lock.busy` or
   `pac.timeout`, should the detail re-fetch the document, or trust that it didn't change?
   Timeout does change the state (sealed → stamping), so at least that one must re-fetch.
   *Wireframe assumed: re-fetch after any PAC or lock error.* It is cheap and keeps the
   banner honest.
3. **"Still in process" vs. `nothing_to_refresh`.** Refresh on a document that is still
   waiting returns 200 unchanged. Refresh on one already resolved returns 409
   `nothing_to_refresh`. The first is an info notice and the second a refusal plus a
   re-read, which then shows the resolved state. *Wireframe assumed exactly that split.*
   Worth stating in FR-016.
4. **Legacy stamps' facts.** Does `stamp` come back non-null for legacy-stamped documents,
   with certificate and PAC RFC filled from the old fields? The spec says "as far as the
   server has them". *Wireframe assumed `stamp` may be null or partial, and empty facts
   show the placeholder.* Check on the dev tenant during plan.
5. **"Cancelación pendiente" chip length.** It wraps on compact rows. Options: allow the
   wrap; use a short label ("Canc. pendiente") on compact only; or "Por cancelar". *Wireframe
   assumed the wrap.* Changing the label is a terminology decision for you.
6. **History fields shown.** The server sends `last_checked_at` too. *Wireframe shows
   requested, answered and resolved, and leaves out last checked.* Last checked is
   operational noise for a clerk. Spec FR-017 already lists only the three, so this is
   consistent.
7. **Reason labels source.** Fixed localized strings for 01–04, or the server's
   `sat_reason_cancellation` catalogue (it exists in the SAT catalogue API)? *Wireframe
   assumed fixed localized strings.* The set is closed by SAT, the server rejects anything
   else, and English needs its own text anyway.
8. **Substitute picker extraction.** The candidate search lives inside the private
   `_AddRelationDialog`. Sharing it means extracting a picker widget within
   `lib/features/invoicing` (feature-local, not `core/widgets`). This isn't a gap in the
   shared vocabulary. It's noted so the plan budgets the extraction instead of
   duplicating the search.
9. **FR-003 "unknown state" is likely unreachable as written.** The generated client
   deserializes `status` into a closed enum. Per spec 066's finding, an unknown wire value
   throws and fails the whole load instead of reaching the mapper. What *is* reachable is
   a mapper that lets a known value fall through to draft, which is today's bug. Suggest
   rewording FR-003 to "the mapping from server states MUST be exhaustive, so no state
   falls through to draft", and dropping the "unknown" chip. *Wireframe drew no unknown
   chip.*
10. **Requester name.** `requested_by` is a user id. Showing a name needs a user lookup.
    Is there one the back office already uses, and does reading users need a right the
    clerk may lack? *Wireframe assumed a name, falling back to "Usuario #id".* The plan
    should confirm.
