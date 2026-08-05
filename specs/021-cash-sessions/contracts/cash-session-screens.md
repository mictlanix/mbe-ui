# Contract: cash session screens

**Feature**: `021-cash-sessions` | **Date**: 2026-08-04

Two screens. The list screen carries the shift panel; the detail screen is the single
surface for counting and closing.

---

## 1. `CashSessionsScreen` — `/sales/cash-sessions`

Composed of two stacked regions in one scroll view: the shift panel, then the history list.

### 1a. Shift panel (top)

Watches the current-session provider. Three renderings, one per `SessionState`:

| State | Renders | Actions |
|---|---|---|
| `none` | "No open session" message + the open form | Open (if `pos`/`create`) |
| `open` | Drawer name, start time, opening amount, per-method payment totals | Close → navigates to detail |
| `stale` | Same, plus a warning that it started on an earlier day and must be closed | Close → navigates to detail |

**The panel never closes a session itself.** Both `open` and `stale` render a Close control
that navigates to `/sales/cash-sessions/:id`, where the count lives. This keeps one
implementation of the count reachable from two entry points (research §6).

When the caller has more than one open session, the panel additionally states that others
exist and need attention, with a link to the history list (FR-004). It cannot enumerate them
— `GET /current` returns only the newest.

#### Open form

| Field | Control | Notes |
|---|---|---|
| Cash drawer | `CatalogEntityPicker<CashDrawer>` **or** a static label | See the privilege fork below |
| Opening amount | `TextFormField`, `keyboardType: numberWithOptions(decimal: true)` | Defaults `0`; rejects negative before submit |

**The drawer control has three forms**, because listing drawers needs a privilege that
opening a session does not (research §7):

1. Holds `cashDrawers`/`read` → the standard picker, preselected to the user's assigned
   drawer and changeable.
2. Lacks it but has an assigned drawer → a **static, non-editable label** showing
   `userSettings.cashDrawerName`. No request is made; the name is already in the session.
3. Lacks both → no open affordance; a message explaining a drawer must be assigned to their
   user. This is the third case FR-007 does not currently describe.

Submit is absent entirely when the user lacks `pos`/`create` (FR-009's last scenario) —
absent, never disabled.

#### Open failure handling

| Outcome | Behavior |
|---|---|
| 409, and a re-read of current session now returns one | Cashier-busy message + a control that navigates to that session's detail to close it (FR-010) |
| 409, and the re-read returns none | Drawer-busy message; the picker stays open so another drawer can be chosen |
| 404 | Drawer-not-found message; picker stays open |
| 422 field errors | Mapped onto `fieldErrors` by `loc.last` |

The backend's `detail` string is rendered as the error banner's second line in all cases,
but is never parsed to choose between them.

### 1b. History list (below)

`DataTableView<CashSession>` with `pagination:` and `onPageChanged:`, wrapped in
`CatalogListStateView` for the four load states.

| Column | Content | Alignment |
|---|---|---|
| Cash drawer | Resolved name, falling back to `#<id>` | left |
| Cashier | Resolved employee name, falling back to `#<id>` | left |
| Start | Localized date + time | left |
| End | Localized date + time, or an em dash while open | left |
| Status | `CashSessionStatusChip` | left, fixed width |

- **No row action icons at all.** A session is not editable, so there is no Edit icon; close
  lives on the detail screen. This trivially satisfies the at-most-two-icons rule by having
  zero.
- **`onRowTap` → the detail screen**, read-only. The row's sole affordance (FR-030).
- Amounts are not shown in the list — the opening amount and totals belong to the detail.
  Per constitution §VI, monetary columns must never be ellipsized, and the four identity
  columns plus status already fill the width.
- Sorting is disabled by the shared table whenever `pagination != null`, which matches
  reality: the endpoint's sort is fixed and not overridable.

#### Filter bar

`CatalogFilterBar` with:
- `filters:` — the drawer facet, a `CatalogEntityPicker<CashDrawer>` behind the standard
  `Badge.count` + `Icons.tune` sheet, exactly as
  `payment_method_options_list_screen.dart` does for its facility facet. Changing it resets
  `pageIndex` to 0 (FR-028).
- `search:` — **renders nothing.** The slot is required by the widget, but the endpoint has
  no `search` parameter and a session has no free-text field. This is a visible departure
  from every other list screen and is recorded in research §12 and spec D-003, with the
  upstream fix as research §14 issue B.
- `actions:` — empty. Opening a session happens in the shift panel above, not from a
  toolbar button, because it is not a "create a record" action in the catalog sense.

---

## 2. `CashSessionDetailScreen` — `/sales/cash-sessions/:cashSessionId`

Read-only with respect to the record. One action, conditionally.

### Summary region (always)

Rendered in a `ResponsiveFormGrid`, `maxColumns: 2`:

| Field | Notes |
|---|---|
| Status | `CashSessionStatusChip` |
| Cash drawer | Resolved name |
| Cashier | Resolved employee name |
| Start | Localized date + time |
| End | Localized date + time, or absent while open |
| Closed by | Resolved employee name; **only when `cashSupervisorId != null`** |
| Opening amount | Localized currency |
| Payments by method | One row per entry: localized method label + localized amount. Unknown method codes render the raw code, per `PaymentMethod.fromCode`'s documented posture |

**Absent by design**: any edit, delete or reopen affordance (FR-032), and any denomination
breakdown (FR-033). `RecordFormActions` is deliberately **not** used — its modes are
create/view/edit and its buttons are Delete/Edit/Save, none of which apply. A reviewer
should expect its absence rather than flag it.

### Count and close region (conditional)

Rendered only when **both**: the session's derived status is `open` or `stale`, **and** the
viewer holds `cashSessionClose`/`update`.

When the status is open/stale but the viewer lacks the privilege, the region is replaced by
a message that a user with closing rights must close it (FR-025) — not a disabled button.

| Element | Behavior |
|---|---|
| Denomination rows | 11 rows from `kMxnDenominations`, descending, each a quantity `TextFormField` defaulting to 0, showing its extended amount |
| Counted total | Sum of denomination × quantity; updates on every change |
| Expected cash | Opening amount + cash-method payments only |
| Difference | Counted − expected, labelled over / short / zero; a zero difference is shown, not hidden |
| Advisory note | Plain-language statement that expected covers the opening amount and cash payments taken, and not other cash movements out of the drawer (FR-018) |
| Close button | `FilledButton` in the record's action area in the screen body — never an app-bar icon |

Rules:
- A non-zero difference **never** blocks the close, demands a justification, or requires an
  approval (FR-019). It is informational.
- Only rows with `quantity > 0` are submitted (FR-020).
- If every quantity is zero, Close first requires an explicit "counted and found empty"
  confirmation dialog (FR-021). This is a client-only rule — the server accepts an empty
  count.
- Quantities are validated as non-negative whole numbers in the controller, not by an input
  formatter (no `TextInputFormatter` exists anywhere in the codebase today).

### Close outcomes

| Outcome | Behavior |
|---|---|
| Success | Confirmation reporting the **counted total and the difference** — the only time either is visible, since neither can be re-read (FR-023). Then the shift panel and history list refresh |
| 409 already closed | Plain message, session state refreshed, **entered counts preserved** (FR-024) |
| 404 | Session-not-found message |

---

## 3. Cross-cutting

**Formatting.** All amounts through `MoneyFormatters.currency`, all timestamps through its
date/time helpers, with `locale:` passed explicitly from the context locale — the shared
formatter defaults to a hard-coded `'es_MX'` and no existing caller overrides it (research
§3). No manual string formatting (FR-038).

**Localization.** Every string is an ARB key in both `app_en.arb` (with an `@` block) and
`app_es.arb` (message only), lowerCamelCase, `cashSession…` prefixed. No ICU plurals — the
codebase has zero and uses plain interpolation. The l10n parity test enforces both files
carry the same keys.

**Widget keys.** Every interactive element carries a `Key`, per the repo's README, so widget
tests and the Flutter-Driver path can address it. At minimum:
`cash_session_open_button`, `cash_session_drawer_field`, `cash_session_opening_amount_field`,
`cash_session_close_button`, `cash_session_confirm_empty_count_button`,
`cash_session_denomination_field_<denomination>`, `cash_sessions_filter_button`,
`cash_session_status_chip_<status>`.

**Responsiveness.** `ResponsiveFormGrid` handles the summary; the denomination rows collapse
to one column on the compact tier via the same grid. `LayoutBreakpoints` is the only source
of tier decisions (FR-040).

**Loading and error states.** `CatalogListStateView` for the list;
`Center(CircularProgressIndicator())` inline for the detail, matching the 33 existing detail
screens; `ErrorBanner` fed a synthesized `AppError.validation` two-entry list for
controller errors, matching `cash_drawer_detail_screen.dart:120-138`.
