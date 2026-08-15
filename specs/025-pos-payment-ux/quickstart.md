# Quickstart: validating the payment step's new look & feel

**Feature**: `025-pos-payment-ux` | **Date**: 2026-08-15

How to prove the feature works. *What* to build is in [plan.md](./plan.md),
[research.md](./research.md), [data-model.md](./data-model.md) and
[contracts/payment-surface.md](./contracts/payment-surface.md); this file is the
run and validation guide.

---

## Prerequisites

- Flutter stable, Dart 3.10.3+
- mbe-api reachable — default `http://127.0.0.1:8000`, override with
  `--dart-define=API_BASE_URL=https://...`
- A user with `POS (44)` READ and a `point_sale` assigned, plus an **open cash
  session** for that register (spec 021) — without one, no sale can be confirmed
  and the step is unreachable
- A facility with **at least three** active payment method options configured,
  including one that requires a reference and one that does not — the tiles'
  secondary line is only interesting when both exist
- A second facility with **no** options configured, to exercise the fallback
  tiles
- A confirmed sale with an outstanding balance, and a second one already
  part-paid, so the rail has rows to draw

## Build and check

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

`flutter analyze` must be clean and `flutter test` green. Run from the repo
root: the l10n parity test reads relative paths and fails spuriously elsewhere.

`gen-l10n` is required — this feature adds five keys and removes one
(research R10).

## Unit and widget tests

```bash
flutter test test/widget/features/sales/
flutter test test/widget/core/widgets/number_pad_test.dart
flutter test test/unit/core/l10n_parity_test.dart
```

The checks carrying the most risk:

| Test | Proves |
|---|---|
| `payment_step_gate_test.dart` (existing, must stay green untouched except where noted) | The close gate, the submit gate and the fallback method keys still behave — the regression net for FR-001/FR-031 |
| `payment_step_layout_test.dart` *(new)* | Two panes at 1280 px with the summary and the close button in the rail; one column with a pinned footer at 1024 px and at 390 px; no horizontal overflow at 320/390/600/1024/1280/1920 |
| `payment_step_layout_test.dart` — reflow case | An amount, a method and a reference keyed at 1280 px all survive a resize to 1024 px and back (research R5 — this fails before the controller is seeded) |
| `payment_summary_panel_test.dart` *(new)* | All four figures present at once; the change row reads zero with no tender and the excess with an over-tender; the gate hint appears only while the action is disabled with a balance |
| `payment_method_grid_test.dart` *(new)* | Tile per option with its icon and its reference line; selection marked by border **and** check; the reference field appears only for an option that requires one; the fallback set renders as tiles with today's keys |
| `number_pad_test.dart` (existing, untouched) | The pad's keys did not grow — the one guarantee this feature is most likely to break by accident |
| `pos_compact_layout_test.dart` (existing, rewritten for the phone case) | The close button is reachable **without** scrolling now that the footer is pinned, and the surface still never scrolls horizontally |
| `l10n_parity_test.dart` | The five new keys exist in both locales and the removed one is gone from both |

## Golden images

None added, and none should change. If `number_pad_*.png` fails, `NumberPad`
was edited — research R3 says it must not be.

## Driving the real screen

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Open the register, add a line, confirm to reach Cobro, then walk this list. The
window widths matter — resize the browser rather than trusting one size.

| At | Do | Expect |
|---|---|---|
| 1440 px | Land on the step | Two panes. Amount, quick amounts, tiles **and** keypad side by side, apply at the pane's foot; rail with the payments, the four figures and Continuar. Nothing scrolls |
| 1440 px | Key `500` on the touch keypad | The digits appear right-aligned in the large figure; keys stay the size they were — they do not fill the pane's height |
| 1440 px | Type into the amount with the physical keyboard | Same field, same figure — the two paths are interchangeable |
| 1440 px | Pick a card option | Tile takes a 2 px border and a check; the reference field appears beneath the tiles if that option requires one |
| 1440 px | Key more than the balance | The rail's Cambio row shows the excess; it returns to `$0.00` when the amount is cleared |
| 1440 px | Apply a partial payment | It appears in the rail, Pagado and Restante move, Continuar stays disabled with the hint beneath it |
| 1440 px | Apply the remainder | Restante reaches zero, the hint disappears, Continuar becomes available |
| 1440 px | Reverse a payment (with a reason) | It stays listed, struck through, and the figures follow |
| 1200 px → 1199 px | Drag the window edge across the threshold mid-tender | The layout switches to one column with the footer pinned, and the keyed amount, method and reference are all still there |
| 1024 px | Look at the capture area | One column; the keypad sits beneath the tiles, not beside them; the footer band carries the four figures and Continuar |
| 390 px (device toolbar) | Scroll the step | Everything above the footer scrolls as one; the footer never moves; nothing is clipped and nothing scrolls sideways |
| Any width | A facility with no options configured | Four fallback tiles, no reference line demanding anything, applying still works |
| Any width | Force a refusal (e.g. an amount the server rejects) | The banner appears in the capture pane above the controls, and the keyed draft is still there |

## What "done" looks like

- SC-001/SC-002: a full-balance payment at 1440×900 with **zero** scroll
  gestures.
- SC-004: `number_pad_test.dart` green, unedited.
- SC-005: no horizontal overflow at any width from 320 px to 1920 px.
- SC-006: `git diff` of the changed widgets contains no literal colour, radius,
  spacing or font-size — every value reads from `Theme.of(context)`.
- SC-009: the network panel shows the same requests, in the same order, as
  before the change — one `POST /customer-payments`, one `/applications` per
  tender, one listing refresh after.
