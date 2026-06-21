# Contract: Shared catalog action icons & ordering

Defines the app-wide UI contract every catalog screen must follow for
Create/View/Edit/Delete (constitution §VI; spec.md FR-003 through FR-006,
FR-012). Implemented by `lib/core/widgets/catalog_action_icons.dart`.

## Icon & position table

| Action | Icon (`IconData`) | Location | Fixed order |
|---|---|---|---|
| Create | `Icons.add` | Screen toolbar (`AppBar.actions`) | n/a — single action |
| View | `Icons.visibility_outlined` | Row, trailing columns | 1st |
| Edit | `Icons.edit_outlined` | Row, trailing columns | 2nd |
| Delete | `Icons.delete_outline` | Row, trailing columns | 3rd (last) |

A catalog screen MUST render row actions in exactly `[View, Edit, Delete]`
order, omitting any entry the current target/user doesn't support, and
MUST NOT insert any other action between or after them. A catalog adding a
genuinely new action type (not covered by this contract) is out of scope
for this feature.

## RBAC visibility (delegates to constitution §IV)

| Action | Shown when |
|---|---|
| Create | `access.can(object, AccessRight.create)` |
| View | Row is visible at all (read access already implied) |
| Edit | `access.can(object, AccessRight.update)` |
| Delete | `access.can(object, AccessRight.delete)` AND the entity supports a delete/deactivate operation |

An action the user lacks privilege for is omitted entirely — never
rendered disabled (carries over specs/002's existing rule).

## View navigation contract

Invoking View MUST navigate to the same route/screen Edit uses, with an
explicit signal (e.g. `?view=true` query parameter) that forces read-only
rendering regardless of whether the user could otherwise edit the record.
It MUST NOT navigate to a separate view-only screen/widget tree.

## Consumers (this feature)

- `lib/features/auth/presentation/admin/users_list_screen.dart`
- `lib/features/catalog/presentation/products_list_screen.dart`

Any catalog screen added after this feature ships MUST import
`catalog_action_icons.dart` rather than constructing its own `IconButton`s
for these four actions.
