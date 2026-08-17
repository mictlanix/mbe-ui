# Contract: Flex Spacing Conversion

**Feature**: 028-presentation-consistency (US2)

Deliberately short. This story is a mechanical cleanup with no user-visible
effect; the whole contract is one rule and its exceptions.

---

## The rule

Convert a `Row`/`Column` to the `spacing` property **only when a spacer sits
between every adjacent pair of children and all spacers are the same size.**

`spacing` inserts its gap between every adjacent pair and never at the leading
or trailing edge. Every exception below follows from that.

| Children | Convert? | Why |
|---|---|---|
| `[A, g8, B, g8, C]` | ✅ `spacing: 8` | uniform, between every pair — identical output |
| `[A, g8, B, g16, C]` | ❌ | `spacing` cannot vary |
| `[A, g8, B, C]` | ❌ | would **add** a gap between B and C |
| `[g8, A, B]` or `[A, B, g8]` | ❌ | edge pad, not a gap |
| `[A]` | ❌ | no adjacent pair |

**Keep the literal value.** `SizedBox(height: 8)` becomes `spacing: 8`, not
`spacing: theme.spacing.xs`. Design-token adoption is out of scope: the
tier-dependent `fieldGapVertical`/`fieldGapHorizontal` would change layout at
some tiers, and adopting tokens at some sites but not others is worse than
adopting none.

**Record every skip** — site, kind, and reason — so a later reader can tell a
deliberate skip from an unexamined site.

---

## The collection-`if` case

A conditionally-present child is the one case worth calling out, because it is
where conversion does more than delete spacers, and where an automated scan
gets it wrong.

`sale_line_card.dart`'s outer `Column` has four uniform `SizedBox(height: 8)`
and a trailing `if (shortfall != null)` child wrapped in
`Padding(EdgeInsets.only(top: 8))`. That wrapper exists **only** because a
collection-`if` child cannot take a preceding spacer.

`spacing` handles it natively: when the condition is false the child never
enters the list, so no gap is left dangling. Converting therefore removes the
four spacers **and** the `Padding` wrapper.

A scan that counts list elements reads this `Column` as having partial gaps and
skips it. It is convertible. **Read these by hand** — a scan narrows where to
look, it does not decide.

---

## Acceptance

Every golden and screenshot baseline passes **unchanged**, against the
baselines as re-recorded by US1.

A baseline that moves during US2 is a bug in the conversion, not a baseline
needing an update. No new tests: the correctness criterion is the existing
suites, and testing further would be testing Flutter's `Flex`, not this repo.
