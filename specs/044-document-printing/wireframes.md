# Wireframes: Document Printing

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-09-30 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive — every
dimension, colour and spacing resolves through the design tokens, per constitution §V.

Six surfaces: one new (the shared document preview) and five existing screens or dialogs
that gain an entry point.

**Revised 2026-09-30** after review. The preview is now a modal dialog (full-screen on
Compact), not a side sheet. It gains zoom controls alongside pinch zoom. Open Questions 1,
2, 4, 6, 7 and 9 are resolved. A second pass resolved 3, 5 and 8, and replaced 6's
info strip with resolving edits first. None remain open.

---

## Screen: Shared document preview (modal over any caller)

A **modal dialog** on the Medium and Expanded tiers: large, centred, and capped at a maximum
size so the caller stays visible dimmed around it. On Compact it becomes a **full-screen
dialog**. Neither is a route, so closing it always returns to the caller unchanged (US2-7).
It has three regions: a title bar (title + close), a scrollable page area, and an action bar
(zoom controls + Descargar + Imprimir). The dialog frame and the page area are new shared
pieces, because nothing in `core/widgets/` fits (Open Question 1).

### State: loading

```
   ┌──────────────────────────────────────────────────────────────────────────┐
   │ Ticket · Folio #1234                                                 [×] │
   ├──────────────────────────────────────────────────────────────────────────┤
   │                                                                          │
   │                                   ◌                                      │
   │                          Cargando documento…                             │
   │                                                                          │
   ├──────────────────────────────────────────────────────────────────────────┤
   │ [−] 100 % [+] [⤢]          Página – / –        [Descargar]  [▣ Imprimir] │
   │  (disabled)                                     (disabled)   (disabled)  │
   └──────────────────────────────────────────────────────────────────────────┘
         (caller screen dimmed behind, barrier tap or Esc closes)
```

- Title bar: the title comes from the document reference ("Ticket · Folio #…",
  "Pedido · 00001234", "Corte de caja · 000123") plus a close icon button.
- Body: a centred progress indicator and message (FR-013).
- Action bar: zoom controls on the left; on the right, `OutlinedButton.icon` Descargar and
  `FilledButton.icon` Imprimir, with the primary action last, as in `RecordFormActions`.
  Everything is disabled while loading (FR-012, FR-013).

### State: loaded — ticket (72 mm, one long page)

```
   ┌──────────────────────────────────────────────────────────────────────────┐
   │ Ticket · Folio #1234                                                 [×] │
   ├──────────────────────────────────────────────────────────────────────────┤
   │ ░░░░░░░░░░░░░░░░░░░░░░░┌──────────────────────┐░░░░░░░░░░░░░░░░░░░░░░░ ▲ │
   │ ░░░░░░░░░░░░░░░░░░░░░░░│   [logo] Tienda      │░░░░░░░░░░░░░░░░░░░░░░░ █ │
   │ ░░░░░░░░░░░░░░░░░░░░░░░│   Ticket de Venta    │░░░░░░░░░░░░░░░░░░░░░░░   │
   │ ░░░░░░░░░░░░░░░░░░░░░░░│   1 × 10.00   ...    │░░░░░░░░░░░░░░░░░░░░░░░   │
   │ ░░░░░░░░░░░░░░░░░░░░░░░│   Total     $10.00   │░░░░░░░░░░░░░░░░░░░░░░░   │
   │ ░░░░░░░░░░░░░░░░░░░░░░░│   ||||||||||||||||   │░░░░░░░░░░░░░░░░░░░░░░░ ▼ │
   │ ░░░░░░░░░░░░░░░░░░░░░░░└──────────────────────┘░░░░░░░░░░░░░░░░░░░░░░░   │
   ├──────────────────────────────────────────────────────────────────────────┤
   │ [−] 100 % [+] [⤢]          Página 1 / 1          [Descargar]  [Imprimir] │
   └──────────────────────────────────────────────────────────────────────────┘
```

- The page is drawn at its true aspect ratio (FR-011). A 72 mm ticket stays narrow and
  centred on a neutral surround, never stretched to the dialog's width.
- A ticket is one tall page (its height is fitted server-side). The page area scrolls
  vertically.
- Imprimir opens the device print dialog with the same bytes (FR-012, FR-020). Cancelling
  that dialog is silent (FR-031).
- Descargar saves under the server's file name, e.g. `ticket-00001234.pdf` (FR-012).

### State: loaded — letter document (multi-page), zoomed in

```
   ┌──────────────────────────────────────────────────────────────────────────┐
   │ Pedido · 00001234                                                    [×] │
   ├──────────────────────────────────────────────────────────────────────────┤
   │  ┌───────────────────────────────────────────────────────────────────── ▲ │
   │  │ [logo] Tienda                                     Pedido - 00001234  █ │
   │  │ Cliente  Juan Pérez            Fecha 2026-09-30   Términos Crédito     │
   │  │ ┌────┬────────┬──────────────────────────────┬───────────┬──────────   │
   │  │ │Cant│Código  │Descripción                   │ P. Unit.  │ Importe     │
   │  │ └────┴────────┴──────────────────────────────┴───────────┴──────────   │
   │  └─────────────────────────────────────────────────────────────────────   │
   │  ◄════════════════════════════════════════════════►                    ▼ │
   ├──────────────────────────────────────────────────────────────────────────┤
   │ [−] 150 % [+] [⤢]          Página 1 / 2          [Descargar]  [Imprimir] │
   └──────────────────────────────────────────────────────────────────────────┘
```

- Pages are stacked vertically; every page is reachable by scrolling (FR-011, US2-6).
- **Zoom** (FR-011, US2-8):
  - `[−]` and `[+]` step through fixed levels, and the current level is shown between them.
  - `[⤢]` fits the page to width, which is the level every document opens at.
  - Pinch zoom works on touch, and Ctrl/⌘ + scroll works on desktop.
  - Once zoomed wider than the viewport, the page area pans both ways. This panning is
    *inside* the document canvas, not a table scrolling sideways, so §VI's
    horizontal-scroll rule does not apply.
- The page indicator ("Página n / N") is always shown, for the page in view, including
  "Página 1 / 1" on tickets and cuts. It reads "– / –" until the document has loaded (FR-011).

### State: error

```
   ┌──────────────────────────────────────────────────────────────────────────┐
   │ Corte de caja · 000123                                               [×] │
   ├──────────────────────────────────────────────────────────────────────────┤
   │ ┌──────────────────────────────────────────────────────────────────────┐ │
   │ │ ⚠ No se pudo cargar el documento.                                    │ │
   │ │   Cash session is not closed                                         │ │
   │ │                                                      [Reintentar]    │ │
   │ └──────────────────────────────────────────────────────────────────────┘ │
   ├──────────────────────────────────────────────────────────────────────────┤
   │ [−] ── [+] [⤢]             Página – / –          [Descargar]  [Imprimir] │
   │  (disabled)                                       (disabled)  (disabled) │
   └──────────────────────────────────────────────────────────────────────────┘
```

- `ErrorBanner` (`core/widgets/error_banner.dart`) shows the server's own reason when there
  is one (FR-013, FR-030, SC-005), e.g. not found, not closed, insufficient privileges.
- Reintentar reuses the existing `retryButton` key. Each retry fetches again, since nothing
  is cached (FR-022).
- An expired session goes through the normal sign-in redirect. The dialog never shows a
  partial document.

### ~~State: print hand-off failed~~ (removed)

Dropped at planning (research R5). On a phone or tablet browser, printing opens the PDF in a
new tab, and the package gives the app no signal when a pop-up blocker refuses it. There is
no state to draw: Descargar stays enabled in the loaded state as the fallback.

### Compact tier — full-screen dialog

```
┌──────────────────────────────┐
│ [×]  Ticket · Folio #1234    │
├──────────────────────────────┤
│  ░░░┌──────────────────┐░░░  │
│  ░░░│ Ticket de Venta  │░░░  │
│  ░░░│ ...              │░░░  │
│  ░░░└──────────────────┘░░░  │
│                              │
├──────────────────────────────┤
│ [−] [+] [⤢]     Página 1 / 1 │
│ [Descargar]      [Imprimir]  │
└──────────────────────────────┘
```

- On Compact the dialog fills the screen, and the close button moves to the leading edge of
  the title bar.
- The action bar wraps onto two lines: zoom and the page indicator first, then Descargar
  and Imprimir. The zoom level readout is dropped to save width, while pinch zoom stays; the
  page indicator is kept.
- A letter page opens fitted to width, which is small on a phone, and is read with pinch
  zoom or `[+]`.

---

## Screen: POS "Venta completada" dialog (`pos_workspace_screen.dart` `_finish`)

`AlertDialog`, as today.

### State: idle

```
┌────────────────────────────────────────────┐
│ Venta completada                           │
│                                            │
│ Folio #1234                                │
│                                            │
│              [▣ Imprimir ticket] [Nueva venta] │
└────────────────────────────────────────────┘
```

- New `OutlinedButton.icon` "Imprimir ticket", placed before the existing `FilledButton`
  "Nueva venta" (FR-002). "Nueva venta" stays the primary action, because starting the
  next sale is still the most common thing to do next.
- It goes straight to the device print dialog with no preview (Clarification 1). The
  dialog stays open afterwards (US1-2).
- The button is absent without `salesOrders` read (FR-040, US1-5).

### State: fetching

```
│              [◌ Imprimir ticket] [Nueva venta] │
│                (busy, disabled)                │
```

- The button shows progress and ignores further presses (US1-3, FR-032). "Nueva venta"
  stays enabled.

### State: error

```
┌────────────────────────────────────────────┐
│ Venta completada                           │
│                                            │
│ Folio #1234                                │
│ ┌────────────────────────────────────────┐ │
│ │ ⚠ No se pudo imprimir el ticket.       │ │
│ │   <server reason, if any>              │ │
│ └────────────────────────────────────────┘ │
│              [▣ Reintentar]    [Nueva venta] │
└────────────────────────────────────────────┘
```

- `ErrorBanner` goes in the dialog content. The print button is relabelled Reintentar
  (US1-4). The cashier can still start a new sale.

### Compact tier

- `AlertDialog` actions wrap onto two lines, with "Nueva venta" on its own line. Nothing
  is dropped.

---

## Screen: POS sales list (`pos_sales_list_screen.dart`)

`CatalogFilterBar` + `DataTableView` + `CatalogPagination`. Only the row actions change.

### State: populated

```
┌───────────────────────────────────────────────────────────────────────────────────────────┐
│ [🔍 Buscar venta…            ]  [⚲ Filtros(1)]                           [+ Nueva venta]  │
├──────────┬────────────┬───────────────────────┬────────────┬────────────┬─────────────────┤
│ Folio    │ Fecha      │ Cliente               │     Total  │ Estado     │    Acciones     │
├──────────┼────────────┼───────────────────────┼────────────┼────────────┼─────────────────┤
│ —        │ 2026-09-30 │ Público en general    │   $120.00  │ (Borrador) │   [✎]  [🧾]     │
│ 1234     │ 2026-09-30 │ Juan Pérez            │   $540.00  │ (Pagado)   │        [🧾]     │
│ 1233     │ 2026-09-29 │ Público en general    │    $80.00  │ (Cancelado)│        [🧾]     │
└──────────┴────────────┴───────────────────────┴────────────┴────────────┴─────────────────┘
                                                                  [‹] 1–25 de 212 [›]
```

- A new direct row icon "Ver ticket" (🧾) is built through `buildCatalogRowActions`
  (`core/widgets/catalog_action_icons.dart`). It is the one extra action allowed beyond
  Edit, so a row has at most two icons and no kebab is needed (FR-003, US4-4).
- It opens the shared preview. A draft gets the pre-payment ticket and a completed sale
  gets the receipt; the server decides which (US4-2, US4-3).
- Tooltip "Ver ticket" (key `documentPrintAction` family). The icon is absent without
  `salesOrders` read (FR-040, SC-008).
- A row tap still opens the sale, as today.

### Compact tier

- The actions column stays, since it is two icons at most. The existing column-drop rules
  for this table are unchanged.

---

## Screen: Cash session detail (`cash_session_detail_screen.dart`)

### State: closed session

```
┌────────────────────────────────────────────────────────────────────┐
│ ← Sesión de caja 000123                                            │
├────────────────────────────────────────────────────────────────────┤
│ (Cerrada)                                                          │
│                                                                    │
│ Caja             Caja 1              Cajero       Ana López       │
│ Inicio           2026-09-30 08:00    Fin          2026-09-30 20:05 │
│ Cerrada por      Luis Díaz           Fondo        $500.00          │
│                                                                    │
│ Pagos por forma de pago                                            │
│   Efectivo ................................... $4,210.00          │
│   Tarjeta de crédito .......................... $1,880.00          │
│ ────────────────────────────────────────────────────────────────── │
│                                              [🧾 Ver corte]        │
└────────────────────────────────────────────────────────────────────┘
```

- The existing `ResponsiveFormGrid` (max 2 columns) + `CashSessionStatusChip` are
  unchanged.
- New `OutlinedButton.icon` "Ver corte" in the body, in the slot that `_CloseSection`
  occupies for an open session. It is never in `AppBar.actions` (FR-006). It opens the
  shared preview.
- It is absent without `pos` read (FR-040).

### State: open session

```
│ (Abierta)                                                          │
│ ...fields...                                                       │
│ ────────────────────────────────────────────────────────────────── │
│ Cerrar sesión                                                      │
│ [denomination count …]                        [Cerrar sesión]      │
```

- There is no "Ver corte" (FR-006, US3-5). The close section is unchanged.

### State: just closed (after dismissing the close dialog)

- The screen re-reads the session and renders the **closed** state above, "Ver corte"
  included, without the user leaving (FR-007, US3-4).

### Compact tier

- The grid collapses to one column (existing behaviour). "Ver corte" goes full width at
  the end of the body.

---

## Screen: "Sesión cerrada" dialog (`cash_session_detail_screen.dart` close flow)

```
┌──────────────────────────────────────────────────────┐
│ Sesión cerrada                                       │
│                                                      │
│ Contado $4,700.00, esperado $4,710.00,               │
│ diferencia $10.00.                                   │
│                                                      │
│                          [🧾 Ver corte]      [OK]    │
└──────────────────────────────────────────────────────┘
```

- The message drops "Estas cifras no se mostrarán de nuevo" (FR-008, US3-2). The new
  wording can point at the reprint, e.g. "…Puedes volver a ver el corte desde esta
  sesión."
- New `OutlinedButton.icon` "Ver corte" (FR-005). Pressing it closes this dialog, then
  opens the shared preview over the refreshed detail screen. Only one dialog is ever open.
- "OK" stays as today.
- "Ver corte" is absent without `pos` read. A supervisor who can close usually has it,
  but that isn't guaranteed (Open Question 7).

---

## Screen: Back-office order workspace (`orders/order_workspace_screen.dart`)

### State: saved order, any step

```
┌───────────────────────────────────────────────────────────────────────────────────────┐
│ ← Pedido 00001234 · Venta ● ─ ○ Entrega                                               │
├───────────────────────────────────────────────────────────────────────────────────────┤
│ ┌ OrderHeaderPanel ─────────────────────────────────────────────────────────────────┐ │
│ │ Cliente  Juan Pérez     Términos  Crédito 30d    Entrega  2026-10-02   [🗎 Ver pedido] │
│ └───────────────────────────────────────────────────────────────────────────────────┘ │
│ ┌ lines ────────────────────────────────────────────────────────────────────────────┐ │
│ │ ...                                                                               │ │
│ └───────────────────────────────────────────────────────────────────────────────────┘ │
│ ┌ SaleTotalsBar ────────────────────────────────────────────────────────────────────┐ │
│ │ [Cancelar pedido]            Subtotal ... IVA ... Total $1,234.50   [Continuar →] │ │
│ └───────────────────────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

- New `OutlinedButton.icon` "Ver pedido", at the trailing edge of `OrderHeaderPanel`
  (FR-004). The app bar stays empty.
- It is offered for draft, completed, paid and cancelled orders (US5-1). It is present on
  both steps, Venta and Entrega, because the header panel renders on both, read-only on
  Entrega.
- It is absent before the order has been saved once (no id), and without `salesOrders`
  read.
- Before fetching, it lets in-flight edits finish and runs the workspace's existing
  keep/discard prompt for unconfirmed typed text, the one other critical actions already use
  (FR-016, US5-3). "Seguir editando" cancels. The pedido then matches the screen, so there
  is no "saved version" strip.

```
┌──────────────────────────────────────────────────────┐
│ Cambios sin confirmar                                │  ← existing prompt
│                                                      │    (showUnconfirmedChangesDialog),
│ Hay valores escritos que no se han confirmado.       │    reused as-is
│ ¿Qué deseas hacer?                                   │
│                                                      │
│ [Seguir editando]      [Descartar]    [Conservar]    │
└──────────────────────────────────────────────────────┘
        ↓ Conservar / Descartar
   pending writes settle → preview opens
```

### Compact tier

- The header panel's fields wrap. "Ver pedido" drops to its own line below them and is
  never hidden.

---

## Open Questions

1. ~~**The preview surface.**~~ **Resolved 2026-09-30:** a modal dialog on Medium and
   Expanded, and a full-screen dialog on Compact. It is not a side sheet and not a route.
   Nothing in `core/widgets/` provides this frame or draws PDF pages. Both are new shared
   pieces under `core/documents/`, which is the one surface research §8.1 anticipated, so
   the plan must name them as a deliberate addition to the vocabulary.
2. ~~**Constitution fit.**~~ **Resolved by 1:** a modal dialog does not touch §VI's
   record-surface rule, which covers side sheets and detail routes. No amendment is needed.
   The plan's constitution check should still mention it.
3. ~~**"Ver corte" from the close dialog: stack or replace?**~~ **Resolved 2026-09-30:**
   the close dialog closes, then the preview opens over the refreshed detail screen. Only one
   dialog is ever open (FR-005).
4. ~~**A letter page on a phone.**~~ **Resolved 2026-09-30:** pinch zoom **and** zoom
   controls (`[−]`, the current level, `[+]`, fit to width). Every document opens fitted to
   width. Recorded in the spec as FR-011 and US2-8.
5. ~~**Page indicator.**~~ **Resolved 2026-09-30:** always shown, as "Página n / N" for the
   page in view, including on one-page tickets and cuts (FR-011). It stays in the compact
   action bar.
6. ~~**The "saved version" note.**~~ **Resolved 2026-09-30, strip dropped:** the workspace
   saves every edit as it happens (`order_header_panel.dart:50-52`, `sale_editing.dart`),
   so there is no lasting unsaved state. The only transient states are unconfirmed typed
   text and writes in flight. "Ver pedido" resolves both first, with the existing
   unconfirmed-edits prompt and pending-writes tracking, and the document then matches the
   screen (FR-016).
7. ~~**The close gate differs from the cut gate.**~~ **Resolved 2026-09-30:** added to the
   spec as an edge case. A user who can close a session but lacks `pos` read gets no
   "Ver corte" button, and the close dialog's figures are all they see.
8. ~~**Where the ticket icon sits relative to Edit.**~~ **Resolved by the code:**
   `buildCatalogRowActions` (`core/widgets/catalog_action_icons.dart`) already renders Edit
   first and the single extra action second, omitting Edit when it isn't allowed. The row
   passes "Ver ticket" as its one `CatalogRowAction`, with no custom ordering. How the icons
   align within the column is the shared table's concern, not this feature's.
9. ~~**Which button is primary in the completion dialog.**~~ **Resolved 2026-09-30:**
   "Imprimir ticket" is an outlined secondary button and "Nueva venta" stays filled and
   primary, so Enter still starts the next sale.
