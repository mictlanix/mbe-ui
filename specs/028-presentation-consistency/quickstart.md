# Quickstart: Validating Presentation Consistency

**Feature**: 028-presentation-consistency | **Date**: 2026-08-17

How to prove this feature works. Scenarios map to the spec's success criteria;
design details live in [contracts/formatting-surface.md](contracts/formatting-surface.md),
[contracts/spacing-conversion.md](contracts/spacing-conversion.md) and
[data-model.md](data-model.md).

## Prerequisites

- Flutter 3.44.2 stable (the version the golden baselines were generated on).
- No mbe-api instance required — this feature has no backend dependency.
- No `.env` required; the app runs on documented defaults.

---

## 1. The ISO default renders everywhere *(SC-001, FR-011)*

```bash
flutter run            # no --dart-define-from-file
```

**Expect**: every date reads `2026-08-17`, every date-time `2026-08-17 14:30`.
Check at least one screen per formatting path so all three migrated sources are
covered:

| Screen | Was formatted by |
|---|---|
| POS sales list, cash sessions | `MoneyFormatters.date` / `.dateTime` |
| A sale's capture lines (quantity, price, tax rate) | `money.dart` display helpers |
| Taxpayer certificates section | the inline `DateFormat.yMd()` |

Amounts read `$1,234.50` and tax rates `16.00 %` — note the percent form, which
**changed** at the `MoneyFormatters.percent` call sites (research R4). That is
expected, not a regression.

## 2. A deployment opts out of ISO *(SC-003)*

```bash
cat > /tmp/local-dates.env <<'EOF'
DATE_FORMAT=d/M/yyyy
DATE_TIME_FORMAT=d/M/yyyy HH:mm
EOF
flutter run --dart-define-from-file=/tmp/local-dates.env
```

**Expect**: every date switches to `17/8/2026` together. Walk the same three
screens from scenario 1 — **any screen still showing `2026-08-17` is a missed
call site**, which is exactly the failure mode this feature exists to remove.

## 3. Absent values render one way *(SC-004)*

Open an open cash session (no end timestamp) and any record with a null amount.

**Expect**: `—` in both, and everywhere else. Not a formatted zero, not blank,
not raw text.

## 4. A malformed setting does not brick startup *(FR-013)*

```bash
printf 'CURRENCY_DECIMAL_DIGITS=abc\n' > /tmp/bad.env
flutter run --dart-define-from-file=/tmp/bad.env
```

**Expect**: the app starts and renders `$1,234.50` on the documented default of
`2`. No crash, no error screen.

## 5. `.env.template` answers the deployer's question *(SC-007)*

Open `.env.template` and read only that file.

**Expect**: every formatting key present with its default, a one-line
description, and commented worked examples showing one value under each
supported pattern — including the explicit-vs-skeleton distinction. If you have
to open source or this spec to learn what `DATE_FORMAT` accepts, FR-014 is not
met.

## 6. Round-trip safety *(SC-005)*

Open a sale line, focus the price / quantity / tax-rate fields, change nothing,
save.

**Expect**: the persisted values are byte-identical to what was loaded —
including values whose stored precision exceeds displayed precision
(`"50.0000000"` displays `50.00` and must save back as `"50.0000000"`).

```bash
flutter test test/unit/core/formatting     # the property test covering this
```

## 7. The guard actually guards *(SC-006)*

```bash
flutter test test/unit/core                # expect: green
```

Now plant a violation — add `import 'package:intl/intl.dart';` to any file under
`lib/features/`:

```bash
flutter test test/unit/core                # expect: RED, naming that file and line
```

Remove it. A guard that cannot be made to fail is not verified.

## 8. Goldens and screenshots *(SC-009, FR-021, FR-027)*

```bash
# After US1's migration, before re-recording — failures are the inventory:
flutter test test/golden

# Re-record once:
flutter test test/golden --update-goldens
flutter test test/screenshots --update-goldens
```

**Before trusting any output**, open one generated PNG and confirm headings are
real Archivo glyphs, not placeholder boxes. Boxes mean `loadGoldenFonts()` never
ran and the suite is verifying nothing (`test/golden/README.md`).

**CI is the source of truth** for goldens; a local `--update-goldens` is
advisory until it lands there.

Then, after US2's spacing conversion:

```bash
flutter test test/golden test/screenshots  # expect: green, zero baselines changed
```

A baseline that moves during US2 is a conversion bug, not a baseline to update.

## 9. Full suite

```bash
flutter analyze
flutter test
```

**Expect**: clean, with no `package:intl` import outside the allowlist and no
`toStringAsFixed` under `presentation/`.
