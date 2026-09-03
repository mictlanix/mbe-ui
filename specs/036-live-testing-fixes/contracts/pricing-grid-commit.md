# Contract: Pricing Grid Cell Commit

**Feature**: 036-live-testing-fixes | **Screen**: `pricing_grid_screen.dart` / `price_cell.dart`

## C1 — Commit-before-switch

`PricingGridController.openCell(GlobalKey? next)` MUST, before changing `state.active`:

1. If `state.active` is non-null and `state.activeDraft` differs from that cell's last committed
   value, call the same commit path (`commitCell`) that a keyboard-triggered move already uses.
2. Only then set `state.active = next`.

This applies uniformly regardless of *why* `openCell` was called — a mouse click into another
cell, a keyboard Tab/Enter/arrow move, or any future caller — because the commit lives in the
controller, not in a widget lifecycle callback.

## C2 — No silent loss, no double-commit

- **No case** may exist in which the active cell's typed-but-uncommitted value is discarded
  without either (a) being saved, or (b) the user having explicitly discarded it via Escape.
- Escape MUST discard `activeDraft` without invoking commit, then behave exactly as it does
  today (close the cell, no server call).
- A commit already in flight for a given cell MUST NOT be issued a second time as a side effect
  of `openCell` also trying to commit it — compare against the value already in flight, not only
  against `state.rows` (which updates only once the server responds).
- A validation failure on commit MUST render exactly as it does today (red text, error icon,
  reason tooltip) regardless of which path (keyboard or `openCell`) triggered the commit.

## C3 — What does not change

- The wire format, endpoint, and per-cell validation rules for a price commit are unchanged.
- Keyboard traversal (Enter/Tab/arrows) keeps its existing `_commitAndMove` behavior; C1 makes it
  a special case of the same underlying guarantee rather than a separately-maintained path.
