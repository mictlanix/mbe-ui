---
name: speckit-wireframes-draft
description: Draw low-fi wireframes for every screen and state the spec describes
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: github-spec-kit
  source: wireframes:commands/speckit.wireframes.draft.md
---

# Draft Wireframes

Produce `specs/<feature>/wireframes.md` — low-fidelity wireframes for every screen and
state the feature specification describes, drawn **before** `/speckit.plan` so that what
the drawing exposes can still change the spec.

Low-fidelity is the point. These are boxes, labels and states, not pixels. Fidelity that
the spec does not yet justify is worse than no drawing, because it invents decisions and
then hides them behind a confident-looking picture.

## Inputs

Resolve the active feature directory from `specs/*/.spec-context.json` (the one whose
`status` is not `completed`), falling back to the `specs/` directory matching the current
git branch. Read its `spec.md`. Do **not** read `plan.md` — it does not exist yet, and if
it does, this command is running out of order.

## Step 0 — UI gate

Decide whether the feature has a user-visible surface at all. Signals that it does not:
the user stories describe scoping, data-correctness or API-shape changes with no new
screen, field, action or state.

**If there is no UI surface, write nothing.** Report one line saying so and exit
successfully. A refactor spec does not need a wireframe, and an empty `wireframes.md` is
noise in the diff forever.

## Step 1 — Enumerate the surface

From the user stories, functional requirements and edge cases, list:

- Every **screen or route** the feature adds or changes.
- For each screen, every **state** it can be in: loading, empty, populated, error,
  permission-denied, and any feature-specific state the spec names (expired, cancelled,
  read-only after confirmation, …).
- Every **action** the user can take, and where it lives (app bar, row, totals bar, sheet).
- Every **field** the user reads or writes.

Enumerate states from the spec's Edge Cases section specifically — that section is where
the states that get forgotten in implementation are already written down.

## Step 2 — Bind to the real component vocabulary

This project composes existing themed components; the constitution forbids a bespoke
widget where a shared one exists, and forbids hard-coded colour, size and spacing.

Before drawing, list `lib/core/widgets/` and read the constitution at
`.specify/memory/constitution.md`. Draw with the components that already exist
(`CatalogFilterBar`, `DataTableView`, `CatalogPagination`, `StatusChip`,
`RecordSheet`, `ListStateViews`, `ResponsiveFormGrid`, …) and name each one in the
wireframe's annotations.

If a screen genuinely needs something the vocabulary does not have, **do not quietly
draw it** — draw the closest existing component and record the gap under Open Questions.
A wireframe that implies a new widget is a wireframe that cannot be built as drawn.

## Step 3 — Draw

One section per screen. Within a screen, one monospace block per state. Use plain ASCII
boxes in a fenced code block. Annotate below each block: which shared component renders
each region, which requirement (FR-xxx) the region satisfies, and what is interactive.

Draw the **regular tier** first, then a **compact (phone) tier** block for any screen
whose layout meaningfully reflows — the constitution requires compact support, and column
budgets are exactly the thing that gets discovered too late. If the compact tier drops
columns or actions, say which and why.

Keep blocks narrow enough to read in a terminal diff (≈100 columns).

## Step 4 — Open questions

End the file with an **Open Questions** section: everything the drawing forced that the
spec does not answer. Each entry states the question, the options, and which one the
wireframe assumed.

This section is the deliverable's real value. Feed it back into `spec.md` (or run
`/speckit.clarify`) before planning — that is the whole reason this runs before plan and
not after it.

## Output

Write `specs/<feature>/wireframes.md` with this shape:

```markdown
# Wireframes: <Feature Name>

**Spec**: [spec.md](./spec.md) | **Drawn**: <date> | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive — every
dimension, colour and spacing resolves through the design tokens, per constitution §V.

## Screen: <name> (`<route>`)

### State: populated
<fenced ascii block>

- Regions and the shared components that render them
- Requirements covered

### State: empty / loading / error
<blocks>

### Compact tier
<block, plus what reflows>

## Open Questions

1. **<question>** — options; wireframe assumed <X>.
```

Report the file path, the screen and state count, and the number of open questions raised.