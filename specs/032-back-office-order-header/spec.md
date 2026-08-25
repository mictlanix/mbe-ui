# Feature Specification: Back-Office Order Header — Progressive Disclosure

**Feature Branch**: `032-back-office-order-header`

**Created**: 2026-08-24

**Status**: Draft

**Input**: User description: "Improve the back-office sales UI. Implement the
`Sales Order - Header.dc.html` artboard from the Claude Design project
*Backoffice Sales Screen Redesign*
(`ae78abac-31d5-48e1-b8fd-c75e2a4efeaa`). Only change the form and the cancel
button."

## Context

Spec 029 shipped `/sales/orders/:orderId` — the "Pedidos" screen — by reusing
the point-of-sale capture surface and adding one new piece of its own:
`OrderHeaderPanel`, a flat `ResponsiveFormGrid` of **fifteen** fields, every
one of them permanently on screen. Below the totals bar it added a second
action band holding nothing but "Cancel order", borrowed from
`RecordFormActions` with two empty labels to suppress Save and Edit.

The design artboard reworks exactly those two things:

- The fifteen-field wall becomes a **read-only fact strip** plus **four
  fields that are always relevant**, with the remaining seven behind a
  "More details" disclosure.
- The dedicated cancel band disappears; **cancel moves into the totals bar**
  beside Confirm, as a quiet text action.

Everything else on the screen — the customer bar, the product search field,
the line rows/cards, the totals figures themselves — is explicitly out of
scope and must render byte-for-byte as it does today.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Read an order's state at a glance (Priority: P1)

A clerk opens an existing order to answer a question about it — what it is,
what state it is in, when it was raised, what is still owed. Today those four
facts sit as four indistinguishable `InputDecorator` boxes among eleven other
boxes, all the same size and weight. The redesign lifts them out of the form
entirely into a compact strip of uppercase-label-over-value blocks across the
top of the header card, so nothing that cannot be typed into looks like a
field.

**Why this priority**: it is the most common reason the screen is opened at
all, and it needs no editing rights, so it delivers value to every user of the
screen including read-only ones.

**Independent Test**: open a saved order as a read-only user; reference,
status, creation date and balance are all legible without scrolling and none
of them is rendered as an input control.

**Acceptance Scenarios**:

1. **Given** a saved order, **When** the order screen renders, **Then** its
   reference, status, creation date and outstanding balance appear as a
   labelled read-only strip above the editable fields.
2. **Given** a cancelled order, **When** the order screen renders, **Then**
   the status shown in that strip reads "Cancelled".
3. **Given** an order not yet saved (`/sales/orders/new`), **When** the screen
   renders, **Then** no header card is shown at all — unchanged from today.

---

### User Story 2 - Edit only what usually needs editing (Priority: P1)

A clerk raising or amending an order changes the promise date and the
salesperson far more often than the tax ID or the exchange rate. The redesign
keeps due date, promise date, payment terms and salesperson permanently
visible, and folds priority, currency, exchange rate, contact, delivery
details, tax ID and comment behind a single "More details" toggle that is
closed on arrival.

**Why this priority**: it is the change that reclaims the vertical space —
without it the lines list still starts most of a screen down the page.

**Independent Test**: open a draft order with edit rights; four editable
fields are visible; pressing "More details" reveals the remaining seven and
relabels itself "Fewer details".

**Acceptance Scenarios**:

1. **Given** a draft order with edit rights, **When** the screen first
   renders, **Then** due date, promise date, payment terms and salesperson are
   visible and priority, currency, exchange rate, contact, delivery details,
   tax ID and comment are not.
2. **Given** the collapsed header, **When** the user activates the disclosure
   control, **Then** the seven further fields appear and the control's label
   becomes the collapse wording.
3. **Given** the expanded header, **When** the user activates the control
   again, **Then** those fields are hidden and the label returns to the expand
   wording.
4. **Given** the expanded header, **When** the user edits a field inside it,
   **Then** the edit is written through immediately, exactly as before — the
   disclosure changes visibility only, never write behaviour, never the
   live-surface rule that there is no Save button here.
5. **Given** a completed order and a user with update rights, **When** the
   user expands the header, **Then** priority is still editable and every
   other field is not (spec 029 FR-027 is unchanged by the move).

---

### User Story 3 - Cancel from the action bar (Priority: P2)

The cancel action stops being a band of its own beneath the totals and becomes
a quiet, low-emphasis text action inside the totals bar, immediately left of
"Confirm order" — the destructive twin of the primary action, in the same
place the eye already is.

**Why this priority**: it removes a whole horizontal band from the bottom of
the screen, but the action itself already works; this is placement, not
capability.

**Independent Test**: open a draft order with update rights; "Cancel order"
appears inside the totals bar next to "Confirm order", and pressing it still
raises the same confirmation dialog.

**Acceptance Scenarios**:

1. **Given** a draft order and a user with update rights, **When** the screen
   renders, **Then** "Cancel order" is inside the totals bar beside "Confirm
   order" and there is no separate action band beneath it.
2. **Given** that button, **When** it is pressed, **Then** the existing
   confirmation dialog appears and nothing is cancelled until it is confirmed.
3. **Given** a user without update rights, or an order that is no longer
   editable, **When** the screen renders, **Then** the cancel action is absent
   entirely — not present-but-disabled.
4. **Given** a cancel in flight, **When** the screen renders, **Then** the
   cancel action shows progress and cannot be pressed again.
5. **Given** any point-of-sale screen that uses the same totals bar, **When**
   it renders, **Then** it is unaffected — no cancel action, and the bar's
   layout is identical to before this feature.

### Edge Cases

- **A field the user needs is inside the collapsed section.** The disclosure
  is a single press away and its state is per-visit; nothing is unreachable.
  Deliberately *not* persisted — see Assumptions.
- **An error from a header write while the section is collapsed.** The error
  banner belongs to the card, not to the collapsible group, so a refusal
  raised by a field the user has since collapsed is still shown.
- **The compact tier.** The header card, the disclosure and the relocated
  cancel action all have to work on a phone-width layout, where the form grid
  is one column and the totals bar stacks.
- **An unconfirmed comment edit when the section is collapsed.** Collapsing
  must not silently drop a pending edit — the write-gating rules of spec 031
  continue to govern the comment field regardless of visibility.

## Requirements *(mandatory)*

### Functional Requirements

**The header card**

- **FR-001**: The order header MUST render as a single raised, outlined card
  rather than as bare fields on the screen background.
- **FR-002**: The card MUST open with a read-only fact strip carrying the
  order's reference, status, creation date and outstanding balance, each as an
  uppercase label above its value, and none of them as an input control.
- **FR-003**: The card MUST show, always and without disclosure, these four
  fields: due date (read-only), promise date, payment terms (read-only) and
  salesperson.
- **FR-004**: The card MUST place these seven fields behind a disclosure
  control: priority, currency, exchange rate (read-only), contact, delivery
  details, tax ID and comment.
- **FR-005**: The disclosure MUST be closed when the screen is first rendered.
- **FR-006**: The disclosure control MUST sit on the fact strip's trailing
  edge, and MUST state which way it will move — expand wording when closed,
  collapse wording when open.
- **FR-007**: The disclosed group MUST be visually separated from the
  always-visible fields by a rule.
- **FR-008**: The comment field MUST span the card's full width in every
  column count, as it does today.
- **FR-009**: Any error raised by a header write MUST render inside the card
  and outside the disclosed group, so it is visible whether the group is open
  or closed.
- **FR-010**: Every field MUST keep its current edit gating unchanged: all
  fields but priority require `can(salesOrders, update) && sale.isEditable`;
  priority requires `can(salesOrders, update)` alone.
- **FR-011**: Every field MUST keep writing through on change with no Save
  button, unchanged from spec 029.
- **FR-012**: No field present before this feature may be dropped. Currency
  stays an editable control (the artboard shows only a read-only currency
  summary; see Assumptions).

**The cancel action**

- **FR-013**: Cancel MUST render inside the totals bar, immediately preceding
  the primary confirm action.
- **FR-014**: The separate action band beneath the totals bar MUST be removed.
- **FR-015**: Cancel MUST be low-emphasis and destructively coloured — a text
  action in the error role, not a filled or outlined button.
- **FR-016**: Cancel MUST remain absent, never disabled, when the user lacks
  update rights or the order is not editable.
- **FR-017**: Cancel MUST keep its existing confirmation dialog, its existing
  widget key, and its existing refusal handling.
- **FR-018**: Cancel MUST show in-flight progress and refuse re-entry while a
  cancel is running.
- **FR-019**: The totals bar MUST render exactly as before for every caller
  that supplies no cancel action — the point-of-sale register in particular.

**Scope fence**

- **FR-020**: The customer bar, product search field, line rows and cards, and
  the totals figures themselves MUST NOT change.

### Key Entities

No new entities. The feature reads and writes the same `Sale` header fields
spec 029 already defined.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On first render of a saved order at the expanded tier, the
  header occupies at most **half** the vertical space it occupies today
  (fifteen fields in a 3-column grid → a one-line fact strip plus a single
  4-cell row).
- **SC-002**: The screen renders **one** bottom band instead of two; the
  action band beneath the totals bar is gone.
- **SC-003**: All four facts in the strip (reference, status, date, balance)
  are readable without any interaction, on every layout tier.
- **SC-004**: Every field editable before this feature is still editable
  after it, at most one interaction away.
- **SC-005**: Every existing point-of-sale test passes unchanged — the shared
  totals bar gains a slot, not a behaviour.

## Assumptions

- **The artboard's fact strip is a subset, not a ceiling.** It shows Created,
  Balance and a read-only "MXN · rate 1.0000". Reference and status have no
  home in the artboard (its app-bar carries only the title, and the app bar is
  out of scope), so they join the strip rather than being dropped — losing an
  order's identity and state would be a regression, not a redesign.
- **Currency stays editable.** The artboard renders currency read-only in the
  strip and offers an "Exchange rate" input in the disclosed group. This
  product has it the other way round: currency is editable, exchange rate is
  server-derived and read-only. Rather than duplicate currency in two places,
  the editable currency control moves into the disclosed group beside the
  read-only exchange rate, and currency is left out of the fact strip.
- **"Tax ID" and "Delivery details" are the artboard's names for the existing
  recipient and ship-to fields** — the localized labels already read that way.
- **The disclosure state is per-visit, not persisted.** Remembering it across
  navigations is a user-preference concern (spec 027's territory) and was not
  asked for.
- **The artboard's palette, pixel sizes and typography are a presentation, not
  a requirement.** Everything resolves through the spec 022 design tokens, per
  constitution §V — the same rule `SaleTotalsBar` already documents for its
  own mock.
- **The artboard is a single desktop-width frame.** Compact-tier behaviour is
  derived from the existing responsive rules, not from the artboard.
