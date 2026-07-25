# Contract: `RecordFormActions` — the shared record action area

**Feature**: `017-ui-consistency-filters` | Satisfies FR-001 – FR-008
**Requires**: constitution §VI amendment to v1.10.0 (FR-005) — see [../research.md](../research.md) §7

Replaces, on all 18 record detail screens, three copy-pasted pieces: the app-bar
edit `IconButton`, the Save/Delete `FilledButton`s wrapped in
`FormGridChild(span: FormGridSpan.full, …)`, and the `_confirmDelete` `AlertDialog`.

## 1. Placement

The **last** child of the record's `ResponsiveFormGrid`, spanning the full grid
width — but its **buttons are right-aligned and content-sized**, never stretched
(FR-004). On Compact widths the row wraps to stacked full-width buttons, which is
the one case where full width is correct.

`AppBar.actions` on a record screen becomes empty. The pre-existing allowance for a
record's own delete action in the app bar (for modules whose layout cannot host a
form-body delete) is retained by the amendment so no shipped screen becomes
retroactively non-compliant — but no screen uses it today and none should adopt it.

## 2. Rendering by mode

Fixed left-to-right order, identical on every screen (FR-001):

| Mode | Rendered | Styling |
|---|---|---|
| `create` | `[ Save ]` | Save = `FilledButton` |
| `view` | `[ Edit ]` | Edit = `OutlinedButton` with `CatalogAction.edit.icon` |
| `edit` | `[ Delete ]  [ Save ]` | Delete = `OutlinedButton` in `colorScheme.error`; Save = `FilledButton` |

**Order rationale**: the destructive action sits furthest from the primary one, and
the primary/confirming action is rightmost — matching the `AlertDialog` convention
the codebase already uses in `_confirmDelete`.

**Why Delete becomes outlined**: today it is a filled error-colored block, making
the loudest element on the form a destructive one. Outlined-in-error keeps it
unmistakable without dominating. *(A deliberate appearance change beyond a straight
move — recorded so it is a decision, not drift.)*

## 3. Interface

```dart
RecordFormActions({
  required RecordFormMode mode,      // create | view | edit
  required String saveLabel,
  required String editLabel,
  required String deleteLabel,
  VoidCallback? onEdit,              // null ⇒ action absent
  VoidCallback? onSave,              // null ⇒ action absent
  VoidCallback? onDelete,            // null ⇒ action absent
  required bool isSubmitting,
  RecordDeleteConfirmation? deleteConfirmation,
})
```

**`null` callback means the action is not rendered at all** — the widget has no
`enabled` flag for RBAC. This makes "hide, never disable" (FR-007) structurally
impossible to get wrong, and mirrors how `buildCatalogRowActions` already treats a
null `onEdit`.

**Labels are caller-supplied**, so `core/widgets/` keeps no localization dependency
— the convention established by `catalog_action_icons.dart`. Each screen passes its
existing keys (`l10n.saveButton`, `l10n.editRecordTooltip`,
`l10n.delete<Entity>Button`), so this widget adds **zero** new l10n keys.

## 4. Delete confirmation

`RecordDeleteConfirmation { title, message, confirmLabel, cancelLabel }` is passed
in; the widget owns showing the dialog and only invokes `onDelete` on confirmation
(FR-001's "same confirmation wording pattern on every screen"). Screens keep their
existing `delete<Entity>ConfirmTitle` / `…Message` keys — the *pattern* is shared,
the wording stays per-entity.

Dialog shape is preserved from the current `_confirmDelete`: `AlertDialog`, cancel
as `TextButton`, confirm as an error-colored button.

## 5. Submitting state

While `isSubmitting`:

- every callback is suppressed — no double submission (FR-008);
- Save shows an inline progress indicator in place of its label, matching the
  current `SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))`;
- Edit and Delete render disabled rather than disappearing — this is transient
  in-flight state, not an RBAC decision, and the distinction matters: RBAC hides,
  busy-state disables.

## 6. Widget keys

Preserved from today so existing tests need only relocate their expectation, not
re-derive it:

| Action | Key |
|---|---|
| Edit | `edit_<entity>_button` |
| Save | `save_button` |
| Delete | `delete_<entity>_button` |
| Confirm delete | `confirm_delete_<entity>_button` |

Keys are caller-supplied for the same reason labels are. **22 assertions across 15
widget test files** currently find `edit_<entity>_button` in the app bar; after the
move they find the same key in the form body — so most updates are an expectation
about *where*, not *whether*.

⚠️ `pricing_screen_test.dart:203`'s `edit_price_button_1` matches an
`edit_.*_button` grep but is a **pricing-table row action**, not a record edit
toggle. Leave it alone.

## 7. Test obligations

- Every mode × RBAC combination renders exactly the actions in §2's table, with
  absent actions **not found in the tree at all** (not found-but-disabled).
- `create` mode never renders Edit or Delete.
- `view` mode without update privilege renders no Edit.
- `edit` mode without delete privilege renders no Delete.
- `isSubmitting` suppresses every callback and shows Save's progress indicator.
- Delete invokes its callback only after confirmation; cancelling invokes nothing.
- Buttons are not stretched to the form width on an Expanded-tier layout.
- No record screen has a non-empty `AppBar.actions` after conversion.
