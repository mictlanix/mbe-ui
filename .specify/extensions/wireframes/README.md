# UI Wireframes Extension

Draws low-fidelity wireframes from a feature spec, as a normal step of the spec-driven
pipeline rather than something you have to remember to ask for.

## Why before plan

A wireframe is only *design input* while the spec can still absorb what it exposes.
Drawn after planning, it documents decisions already made; drawn before, it surfaces the
layout and state questions — what the empty state looks like, where a status marker
lives, which columns survive the compact tier — while they are still cheap to answer.

The hook is on `before_plan` rather than `after_clarify` because `clarify` is optional
and, in this project, rarely run. `before_plan` fires in every pipeline, and still fires
after `clarify` when it is used.

It registers at `priority: 5` so it runs ahead of the `git.commit` hook already on
`before_plan`, and the wireframes land in that commit.

## Commands

| Command | Description |
|---------|-------------|
| `speckit.wireframes.draft` | Draw wireframes for every screen and state the spec describes. |

## Output

`specs/<feature>/wireframes.md` — one section per screen, one ASCII block per state, a
compact-tier block for anything that reflows, and an **Open Questions** section listing
what the drawing forced that the spec does not answer.

That last section is the point. Feed it back into `spec.md` before planning.

## Non-UI features

The command gates on whether the feature has a user-visible surface. A scoping fix or a
data-correctness spec gets no file and no empty placeholder. The hook is `optional: true`
as well, so it prompts and can simply be declined.

## Disabling

```
specify extension disable wireframes
```
