# Contract: Delivery step additions

**Feature**: 030-pos-sales-refinements | Satisfies FR-017…FR-030

Two additions to the surface spec 026 built: an edit action on each addressed
destination, and an expandable store row. Nothing else on the step moves.

---

## 1. Destination card header

Trailing controls, left to right, matching the mock's own order
(`POS_Adaptativo.dc.html` lines 774–776, 872–874):

| Order | Control | Key | Icon | Tooltip | Shown when |
|---|---|---|---|---|---|
| 1 | Edit | `destination_edit_<id>` | `CatalogAction.edit.icon` (`Icons.edit_outlined`) | `editActionTooltip` | `enabled && onEdit != null` |
| 2 | Remove | `destination_remove_<id>` | `Icons.delete_outline`, `colorScheme.error` | `posRemoveDestination` | unchanged from today |
| 3 | Expand | — | `Icons.expand_more` / `expand_less` | — | always |

- The edit icon comes from the shared `CatalogAction` vocabulary
  (constitution §VI: "A module MUST NOT invent its own icon for Edit"), even
  though this card is not a catalog row and does not use
  `buildCatalogRowActions` — see the plan's Complexity Tracking for the
  three-control header.
- `onEdit` is a plain `VoidCallback?` on `DestinationCard`, wired by
  `delivery_step.dart`, exactly as `onRemove` already is — the widget stays
  provider-free for assignment/removal/editing alike.
- Unavailable while the step is closing (`enabled: !_closing`, FR-024).
- **Never on the store row**, which uses `DestinationCounterRow` and has no
  such callback (FR-023).
- The header must still fit a phone width with three trailing controls: the
  identity block already ellipsizes its address and subtitle
  (`maxLines: 1`), and the counts sit on their own line. Asserted at the
  compact tier by `pos_compact_delivery_test.dart`.

---

## 2. The edit sheet

### Presentation

One opener, used by both paths (research R10):

```dart
Future<void> _openDestinationSheet({Destination? destination})
```

| Width | Presentation | Title |
|---|---|---|
| ≥ `LayoutBreakpoints.large` (1200) | right-anchored `showGeneralDialog`, 400 px, slide-in from the trailing edge, `useRootNavigator: true` | `posAddDestinationSheetTitle` / `posEditDestinationSheetTitle` |
| below | `showModalBottomSheet`, `isScrollControlled`, drag handle, `useRootNavigator: true` | (sheet's own header) |

`useRootNavigator: true` is mandatory in both: the POS lives inside a
`StatefulShellBranch` with a nested `Navigator` that would tear the sheet down
when the step's state changes (spec 026 research R10).

### `DestinationEditor` in edit mode

| Aspect | Add (today) | Edit (new) |
|---|---|---|
| Parameter | — | `Destination? destination` (non-null ⇒ edit) |
| Address button label | `posDeliveryAddressTitle` | `destination.addressSummary` ?? the same placeholder |
| Contact button label | `posDeliveryContactTitle` | `destination.contactName` ?? the same placeholder |
| Date button label | `posDeliveryDateLabel` | `fmt.display.date(destination.date)` when set |
| Instructions field | empty | `destination.comment ?? ''` |
| Confirm label | `posAddDestination` | `saveButton` |
| Confirm enabled | `_shipTo != null && !_submitting` | same rule; prefilled, so enabled on open |
| Submit | `DeliveryController.addDestination` | `DeliveryController.updateDestination` |
| Refusal | banner in sheet, sheet stays open, nothing created | banner in sheet, sheet stays open, destination unchanged (FR-022) |
| Keys | `destination_editor`, `destination_address_button`, `destination_contact_button`, `destination_date_button`, `destination_comment_field`, `destination_save_button`, `destination_editor_error` | **unchanged** — the same widget, so existing tests keep resolving |

Prefilling the two picker *labels* needs the ids the destination already
carries (`shipTo`, `contact`) plus the labels the controller's `_labelled`
join already put on it (`addressSummary`, `contactName`) — no extra fetch. A
destination whose `shipTo` no longer exists among the customer's addresses
opens with the placeholder and cannot be saved until one is chosen (spec Edge
Cases).

### Controller

```dart
Future<Destination> updateDestination({
  required int destinationId,
  int? shipTo,
  int? contact,
  DateTime? date,
  String? comment,
});
```

Calls the existing `DeliveryOrderRepository.updateHeader`, then `_replace`
(which re-runs `_labelled`), so one entry of the list changes and nothing is
refetched (FR-020, FR-021). `null` means *unchanged* at every layer —
client serializer and server alike (research R9); clearing a field is not
offered.

`_justCreatedId` keeps its current meaning: an **edited** destination does not
auto-expand, since it already holds assignments and the cashier was not asked
to fill it.

---

## 3. The store row, expanded

`DestinationCounterRow` becomes a `ConsumerStatefulWidget`.

### Header (collapsed and expanded)

| Element | Today | After |
|---|---|---|
| Leading | `Icons.store_outlined` in a 34 px tile | unchanged |
| Title | `posCounterPickupRemainder` | unchanged |
| Counts | `posDestinationCounts(lines, units)` from *either* the recorded destination *or* the preview | same string, figures from the single derived source (data-model §3, FR-027/FR-028) |
| Trailing | nothing | `Icons.expand_more` / `expand_less` |
| Tap target | none | whole header row, `InkWell`, `borderRadius: shapes.lgRadius` — as `DestinationCard` |
| Actions | none | still none: no edit, no remove (FR-023, FR-029) |

### Body

| Element | Specification |
|---|---|
| Reveal | `AnimatedSize`, 200 ms, `Divider(height: 1, color: outlineVariant)` above — the same treatment `DestinationCard` uses |
| Heading | `posCounterPickupLinesTitle` ("Cantidad que se queda en tienda"), `typeRoles.metricLabel` |
| Rows | one per **sale line**, in `distribution` order, zeros included (FR-026) |
| Row shape | product name (`typeRoles.tableCell`, one line, ellipsized) + store share (`typeRoles.recordId`), formatted via `fmt.field.quantity` — the shape `DestinationCard._readOnlyRow` already draws |
| Row key | `counter_line_<saleLineId>` |
| Root key | `destination_counter_row` (unchanged, so existing finders keep working) |
| Interaction | none — read-only text (FR-029) |
| Live updates | rebuilds with the step's `distribution`, so an assignment elsewhere moves these figures without collapsing the row (FR-030) |

**Reuse note**: lift `DestinationCard._readOnlyRow` into a small shared
`destination_line_row.dart` (or a top-level function in
`destination_counter_row.dart`'s neighbourhood) rather than duplicating the
layout — research R11.

---

## 4. New l10n keys

Both `.arb` files, `es-MX` authored first, `l10n_parity_test.dart` enforces the
pair.

| Key | es-MX | en |
|---|---|---|
| `posEditDestinationSheetTitle` | "Editar destino" | "Edit destination" |
| `posCounterPickupLinesTitle` | "Cantidad que se queda en tienda" | "Quantity staying at the store" |

Reused, not duplicated: `editActionTooltip` ("Editar"), `saveButton`
("Guardar"), `cancelButton`, `posDestinationCounts`,
`posCounterPickupRemainder`, `posRemoveDestination`,
`posAddDestinationSheetTitle`, every picker label the add sheet already uses.

---

## 5. Test contract

| File | Addition |
|---|---|
| `destination_card_test.dart` | edit action present/absent (`enabled`, `onEdit == null`), and its position before the remove action |
| `destination_editor_error_test.dart` | edit mode: prefilled labels, `saveButton` label, refusal keeps the sheet open with the destination unchanged |
| `delivery_step_layout_test.dart` | edit opens the sheet at both tiers with the right presentation; the store row's chevron and expansion |
| new `destination_counter_row_test.dart` | all lines listed with zeros; both sources (recorded destination, preview) and the case where **both** contribute; header/body agreement; no interactive control inside |
| `pos_compact_delivery_test.dart` | three trailing controls do not overflow a phone-width card |
| integration (live backend) | edit a destination's date and address on a real sale, confirm the header updates and the assignments survive |
