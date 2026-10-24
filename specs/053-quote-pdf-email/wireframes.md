# Wireframes: Quotation PDF and Email

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-10-24 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive — every
dimension, colour and spacing resolves through the design tokens, per constitution §V.

Two surfaces change: the existing quote screen gains two header actions, and a new email
dialog opens from one of them. The document preview itself is the shared one from spec 044
and is not redrawn here — it gains no new state.

## Screen: Quote (`/sales/quotes/:id`)

The header strip is `QuoteHeaderPanel`'s always-visible row, rendered by `FactStripRow`
with `CompactField` facts. The new actions go in its `trailing` slot, in front of the
existing "Más detalles" toggle — the same place `OrderHeaderPanel` puts "Ver pedido".
Totals-bar actions (Cancelar / Duplicar / Convertir) are unchanged.

### State: confirmed quote (both actions)

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ ←  Cotizaciones                                                                          │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Referencia   Estado       Fecha              Vigencia                                    │
│ 1234         Confirmada   24/10/2026 09:10   31/10/2026 09:10                             │
│                               [▤ Ver cotización] [✉ Enviar por correo] [Más detalles ▾] │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Cliente: FERRETERÍA LA PAZ  ·  Contacto: Juan Pérez                                      │
│ ┌──────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ lines (read-only once confirmed)                                                     │ │
│ └──────────────────────────────────────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Total $12,345.00        [Cancelar] [Duplicar] [Convertir a pedido]                       │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- Header strip: `FactStripRow` + `CompactField` (existing). Trailing slot: a `Wrap` of
  `OutlinedButton.icon`s plus the existing toggle, exactly as in `OrderHeaderPanel`.
- "Ver cotización" — FR-001, FR-002. Opens the shared document preview (spec 044).
- "Enviar por correo" — FR-006, FR-015. Opens the email dialog below.
- Both gated by sales quotes Read (FR-016) — absent, not greyed, without it.

### State: draft quote (view only)

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ Referencia   Estado     Fecha              Vigencia ✎                                    │
│ #A1B2        Borrador   24/10/2026 09:10   31/10/2026 09:10                               │
│                                            [▤ Ver cotización] [Más detalles ▾]           │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ … editable lines …                                                                       │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Total $12,345.00                  [Cancelar] [Duplicar] [Confirmar]                      │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- No "Enviar por correo" — FR-006 (confirmed only).
- "Ver cotización" is disabled while a write is in flight, and on tap first runs the
  screen's existing keep/discard prompt for unconfirmed typed text — FR-005. Same gate as
  "Ver pedido".

### State: cancelled quote

```
│ Referencia   Estado      Fecha              Vigencia                                     │
│ 1234         Cancelada   24/10/2026 09:10   31/10/2026 09:10                              │
│                                            [▤ Ver cotización] [Más detalles ▾]           │
```

- View only — FR-001 (any state), FR-006 (not sendable once cancelled, even if it was
  confirmed).

### State: loading / error

Unchanged — the screen's existing spinner and `ErrorBanner`. The actions belong to the
header strip, which does not render until the quote loads.

### Compact tier

```
┌──────────────────────────────────┐
│ ←  Cotizaciones                  │
├──────────────────────────────────┤
│ Referencia  Estado               │
│ 1234        Confirmada           │
│ Fecha              Vigencia      │
│ 24/10/2026 09:10   31/10/2026 …  │
│              [Más detalles ▾] [⋮]│
├──────────────────────────────────┤      ┌───────────────────────┐
│ … lines …                        │  ⋮ → │ ▤ Ver cotización      │
├──────────────────────────────────┤      │ ✉ Enviar por correo   │
│ Total $12,345.00                 │      └───────────────────────┘
│ [Cancelar] [Duplicar] [Convertir]│
└──────────────────────────────────┘
```

- On compact, the two document actions move into an overflow menu (`MenuAnchor` /
  `PopupMenuButton`) at the end of the trailing slot; "Más detalles" stays a button —
  FR-015a. The menu holds the same items, gates and disabled states as the buttons (a
  draft's menu has only "Ver cotización", disabled while a write is in flight).
- Nothing is dropped. The order screen's "Ver pedido" is untouched (it is one button and
  still wraps).

## Dialog: Enviar cotización por correo

Opened from "Enviar por correo". A modal over the quote screen. The "1234" in its title is
the same reference the header strip shows (the quote's serial). Recipients are the
selected chips — there is no separate recipient list (Clarifications, FR-008/FR-009).

### State: suggestions loaded, none selected (initial)

```
┌──────────────────────────────────────────────────────────────────────┐
│ Enviar cotización 1234                                               │
│                                                                      │
│ Destinatarios                                                        │
│ ┌──────────────────────────────────┐ ┌─────────────────────────────┐ │
│ │ Juan Pérez · juan@lapaz.mx       │ │ Compras · compras@lapaz.mx  │ │
│ └──────────────────────────────────┘ └─────────────────────────────┘ │
│ ┌──────────────────────────────────────────────┐                     │
│ │ FERRETERÍA LA PAZ SA DE CV · fact@lapaz.mx   │                     │
│ └──────────────────────────────────────────────┘                     │
│                                                                      │
│ ┌────────────────────────────────────────────────────┐ [Agregar]     │
│ │ Otro correo                                        │               │
│ └────────────────────────────────────────────────────┘               │
│ Hasta 10 destinatarios.                                              │
│                                                                      │
│                                        [Cancelar]  [Enviar] (off)    │
└──────────────────────────────────────────────────────────────────────┘
```

- Chips: Material `FilterChip`s in a `Wrap`, styled as the "Falta …" chips in
  `pricing_grid_screen.dart` — FR-008. Label "owner · address". Customer contacts first,
  then fiscal recipients; an address shared by both appears once (edge case: duplicate).
- "Otro correo" field + "Agregar" (and Enter) — FR-009a. A plain themed `TextField`.
- "Enviar" disabled with nothing selected — FR-009a.
- Dialog shell: a **new shared responsive dialog** in `lib/core/widgets/` — regular
  dialog on wide screens, `Dialog.fullscreen` on compact — FR-015b. This is the one new
  shared component the feature adds; nothing equivalent exists today.

### State: some selected, one typed

```
│ Destinatarios                                                        │
│ ┌────────────────────────────────────┐ ┌─────────────────────────────┐│
│ │ ✓ Juan Pérez · juan@lapaz.mx       │ │ Compras · compras@lapaz.mx  ││
│ └────────────────────────────────────┘ └─────────────────────────────┘│
│ ┌──────────────────────────────────────────────┐ ┌─────────────────┐  │
│ │ FERRETERÍA LA PAZ SA DE CV · fact@lapaz.mx   │ │ ✓ pedro@gmail.com│ │
│ └──────────────────────────────────────────────┘ └─────────────────┘  │
│                                                                      │
│ ┌────────────────────────────────────────────────────┐ [Agregar]     │
│ │                                                    │               │
│ └────────────────────────────────────────────────────┘               │
│ 2 de 10 destinatarios.                                               │
│                                                    [Cancelar] [Enviar]│
```

- Typed `pedro@gmail.com` became a chip, already selected, labelled with the address only
  (no owner) — FR-009a. Deselecting it keeps the chip, unselected (Open Question 4).
- Counter replaces the hint once anything is selected — FR-010.

### State: invalid typed address

```
│ ┌────────────────────────────────────────────────────┐ [Agregar]     │
│ │ pedro@                                             │               │
│ └────────────────────────────────────────────────────┘               │
│ ⚠ No es un correo válido.                                            │
```

- Field error text; no chip is added — FR-010.

### State: limit reached

```
│ … 10 chips selected …                                                │
│ 10 de 10 destinatarios. No se pueden agregar más.                    │
```

- Unselected chips stay tappable but a tap does nothing except show the limit message;
  "Agregar" is disabled — FR-010, edge case: address limit.

### State: no known addresses

```
│ Destinatarios                                                        │
│ Este cliente no tiene correos registrados.                           │
│ ┌────────────────────────────────────────────────────┐ [Agregar]     │
│ │ Otro correo                                        │               │
│ └────────────────────────────────────────────────────┘               │
```

- Edge case: customer with no known addresses. Typing still works.

### State: suggestions loading / failed to load

```
│ Destinatarios                                                        │
│ ◌ Cargando correos del cliente…                                      │
│ ┌────────────────────────────────────────────────────┐ [Agregar]     │
│ │ Otro correo                                        │               │
│ └────────────────────────────────────────────────────┘               │
```

```
│ Destinatarios                                                        │
│ No se pudieron cargar los correos del cliente. [Reintentar]          │
│ ┌────────────────────────────────────────────────────┐ [Agregar]     │
```

- The typed-address field is usable in both — a failed or forbidden suggestions load never
  blocks a send (spec Assumptions: no read access to contacts → no chips).

### State: sending

```
│ ┌──────────────────────────┐ ┌──────────────────────────┐            │
│ │ ✓ Juan Pérez · juan@…    │ │ ✓ pedro@gmail.com        │  (disabled)│
│ └──────────────────────────┘ └──────────────────────────┘            │
│                                                                      │
│                                            [Cancelar] [◌ Enviando…]  │
```

- Chips, field and both buttons disabled; the dialog cannot be dismissed while waiting —
  FR-011, edge case: slow mail server.

### State: send failed

```
┌──────────────────────────────────────────────────────────────────────┐
│ Enviar cotización 1234                                               │
│ ┌──────────────────────────────────────────────────────────────────┐ │
│ │ ⚠ El servidor de correo rechazó el envío. Intenta de nuevo o     │ │
│ │   descarga la cotización.                                        │ │
│ └──────────────────────────────────────────────────────────────────┘ │
│ Destinatarios                                                        │
│ ┌──────────────────────────┐ ┌──────────────────────────┐            │
│ │ ✓ Juan Pérez · juan@…    │ │ ✓ pedro@gmail.com        │            │
│ └──────────────────────────┘ └──────────────────────────┘            │
│                                                    [Cancelar] [Enviar]│
└──────────────────────────────────────────────────────────────────────┘
```

- `ErrorBanner` at the top of the dialog; selection kept — FR-013. One message per cause:

  | Cause | Message (es) |
  |---|---|
  | quote no longer sendable | La cotización ya no se puede enviar. |
  | invalid recipients | the server's reason |
  | mail server refused | El servidor de correo rechazó el envío. Intenta de nuevo o descarga la cotización. |
  | mail not configured | El envío de correo no está disponible. Descarga la cotización para enviarla. |
  | connection / other | the app's standard connection/server error text |

- On "quote no longer sendable", closing the dialog refreshes the quote screen — FR-014.
  "Enviar" stays enabled for the other causes (retry).

### State: sent

```
┌──────────────────────────────────────────────────────────────────────┐
│ … quote screen …                                                     │
│                                                                      │
│ ┌──────────────────────────────────────────────────────────────────┐ │
│ │ Cotización enviada a juan@lapaz.mx, pedro@gmail.com              │ │
│ └──────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

- Dialog closes; a `SnackBar` lists the recipients the server confirmed — FR-012.

### Compact tier

```
┌──────────────────────────────────┐
│ ✕  Enviar cotización 1234 [Enviar]│
├──────────────────────────────────┤
│ Destinatarios                    │
│ ┌──────────────────────────────┐ │
│ │ ✓ Juan Pérez · juan@lapaz.mx │ │
│ └──────────────────────────────┘ │
│ ┌──────────────────────────────┐ │
│ │ Compras · compras@lapaz.mx   │ │
│ └──────────────────────────────┘ │
│ ┌──────────────────────────────┐ │
│ │ FERRETERÍA LA PAZ SA DE … ·  │ │
│ │ fact@lapaz.mx                │ │
│ └──────────────────────────────┘ │
│ ┌──────────────────────┐[Agregar]│
│ │ Otro correo          │         │
│ └──────────────────────┘         │
│ 1 de 10 destinatarios.           │
└──────────────────────────────────┘
```

- Full-screen dialog, as the document preview is on compact (spec 044) — close in the
  leading slot, "Enviar" in the app bar. Chips take one per row; the owner name ellipsizes
  before the address does, so the address always stays readable. Nothing is dropped.

## Open Questions

All seven resolved 2026-10-24 and recorded in the spec's Clarifications (wireframe review).

1. **Where does "Enviar por correo" live?** → Header strip beside "Ver cotización"
   (FR-015).
2. **Compact header: three stacked buttons?** → **Changed from the drawing's first
   assumption:** an overflow menu holds the two document actions on compact; "Más
   detalles" stays a button (FR-015a). Compact tier redrawn above.
3. **Dialog shell.** → **Changed:** a new shared responsive dialog in
   `lib/core/widgets/`, not one built inside the feature (FR-015b).
4. **Typed chip deselected?** → Stays as an unselected chip (FR-008).
5. **Chip label and order.** → "owner · address"; contacts, then fiscal recipients, then
   typed; the contact's name wins on a shared address (FR-008).
6. **Dismiss mid-send?** → No (FR-011).
7. **Success message with many recipients.** → Lists them all, wrapping (FR-012).
