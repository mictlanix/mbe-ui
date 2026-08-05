# Phase 0 Research: Cash Session Open, Close and Count

**Feature**: `021-cash-sessions` | **Date**: 2026-08-04 | **Spec**: [spec.md](./spec.md)

Fifteen decisions. Six of them contradict the obvious reading of the spec or of the
existing codebase, and those are called out as such — they are the ones worth
reading before writing code.

---

## 1. Module placement and route scheme

**Decision**: The feature lives in `lib/features/sales/`, at route `/sales/cash-sessions`
(list + shift panel) and `/sales/cash-sessions/:cashSessionId` (detail). Not in
`lib/features/catalog/`.

**Rationale**: Constitution §I names `sales` as a first-class feature module, and the
Technology Stack section fixes the route scheme as mirroring feature folders
(`/auth`, `/sales`, `/inventory`, …). A cash session is an operational sales record,
not master data. The cash *drawer* stays in `catalog` where it already is.

**A route-scheme inconsistency this deliberately does not follow**: of the 17 existing
shell branches, only `/auth/*` is nested — every business route is flat (`/products`,
`/pricing`, `/facilities`, `/payment-method-options`). Notably `/pricing` sits in the
**Sales** nav group while its route is flat, so nav grouping and route nesting have
already diverged. This plan takes the nested form anyway, on two grounds: the
constitution's route scheme is listed under "Non-Negotiable Defaults", and spec 020
independently chose `/sales/pos`. Two specs plus the constitution outweigh legacy drift,
and a reviewer comparing this to `/pricing` should see the divergence recorded here
rather than assume it was an oversight. The flat routes are not renamed — that would be
a 17-branch refactor with no requirement behind it.

**Route gate**: `startsWith('/sales/cash-sessions')` →
`(object: SystemObject.pos, right: AccessRight.read)`. No new `SystemObject` value is
needed: `pos(44)` already exists (`system_object.dart:55`) and is exactly what mbe-api
gates the read and open routes on. There is no `cashSessions` object and none should be
invented — a `SystemObject` value must correspond to a real mbe-api integer.
`cashSessionClose(111)` (`:115`) gates only the close action, not the route, because a
cashier without it must still reach the screen to open and view a shift.

**Consequence worth noting**: `lib/features/sales/` does not exist yet, and spec 020
also creates it. Both specs creating the same module directory is additive, not a
conflict — see §15.

**Alternatives considered**: `lib/features/catalog/` alongside `cash_drawer_*`, rejected
because a session is a transaction, not a catalog record, and the constitution reserves
`catalog` for shared master data. A standalone `lib/features/cash/` module, rejected as
inventing a business domain the constitution does not name. A flat `/cash-sessions` route
matching the 15 catalog branches, rejected per the paragraph above. Gating the route on
`cashSessionClose(111)`, rejected because it would lock cashiers out of the screen whose
primary user they are.

---

## 2. Exact decimal arithmetic — add the `decimal` package

**Decision**: Add `decimal: ^3.2.6` (pulls `rational 2.2.3`) and put the arithmetic in
`lib/features/sales/domain/money.dart`. Monetary values stay `String` on domain
entities, exactly as the existing convention requires; `Decimal` is used only inside
the arithmetic helper.

**Rationale**: This contradicts the codebase's current posture, so it needs justifying.
Today mbe-ui carries decimals as `String` end to end and never parses them for
arithmetic — `ProductPrice.price` is a `String`, and the only `num.tryParse` calls sit
in display formatting and validators, both of which document "never parsed to `double`
for storage, only checked for validity here". That convention exists because nothing
until now has *computed* on money. This feature's entire purpose is computing on money:
a counted total, an expected figure, and the difference between them (FR-015 to FR-017).
`double` is disqualified — the difference is compared against zero to decide whether the
drawer reads over, short, or exact, and binary floating point cannot be trusted for
that. Verified with `flutter pub add --dry-run decimal`: resolves cleanly against the
current constraints, adding two small pure-Dart packages.

**The boundary that keeps this from spreading**: entities keep `String openingAmount` and
`String total`, matching every other entity in the repo. Only `money.dart` knows about
`Decimal`. Nothing else imports `package:decimal`.

**Alternatives considered**:
- **Hand-rolled integer minor units.** The denomination ladder is a client-owned constant
  and could be declared directly in centavos, making the counted total pure `int`
  arithmetic with no dependency at all. Rejected because the *expected* figure is built
  from server-supplied strings, and the underlying column is `decimal(18,4)` — so a
  bespoke string-to-scaled-integer parser would have to handle four decimal places and
  round-trip correctly. That is a small amount of code and a large amount of risk in the
  one place this feature can be wrong about money.
- **`double` with epsilon comparison.** Rejected outright for a cash-reconciliation figure.

---

## 3. Money and date formatting — promote the pricing formatter

**Decision**: Move `lib/features/pricing/presentation/pricing_formatters.dart` to
`lib/core/widgets/money_formatters.dart`, renaming the class `PricingFormatters` →
`MoneyFormatters`. Preserve its behavior exactly; update all call sites. Cash-session
call sites pass the context locale explicitly.

**Rationale**: The feature needs currency and date formatting, and it cannot legally
reach the existing formatter. Constitution §I forbids `presentation` importing another
feature's `presentation`; §VI requires shared formatted fields to live in `core/widgets/`.
The file is already de-facto shared and mis-located — `features/catalog` imports it from
`features/pricing` today. Promotion is the only option that violates nothing.

**Correct blast radius — larger than it looks**: 9 source files plus 2 test files, not the
"two call sites in `lib/features/pricing/`" that spec 020's equivalent task claims.
- `lib/features/pricing/presentation/`: `price_lists_list_screen.dart`,
  `pricing_screen.dart`, `exchange_rate_detail_screen.dart`,
  `exchange_rates_list_screen.dart`
- `lib/features/catalog/presentation/`: `employee_detail_screen.dart`,
  `vehicle_operator_detail_screen.dart`, `suppliers_list_screen.dart`
- `lib/main.dart` (a comment referencing why `initializeDateFormatting()` is called)
- `test/unit/features/pricing/pricing_formatters_test.dart`,
  `test/widget/features/pricing/exchange_rate_detail_screen_test.dart`

**Deliberately not fixed**: `MoneyFormatters.currency` hard-codes the `$` symbol and
defaults its locale to the literal `'es_MX'` rather than reading the context locale. Both
are pre-existing defects. Changing them would alter what every current pricing screen
renders, which is outside this feature. FR-038 is satisfied instead by cash-session call
sites passing `locale:` explicitly — the parameter already exists and no current caller
uses it.

**Alternatives considered**: importing across features (violates §I); duplicating the
formatter in `features/sales` (violates §VI); rewriting it as a currency-aware formatter
(scope creep into four pricing screens with no requirement asking for it).

---

## 4. Discriminating the two open conflicts — re-read state, do not match strings

**Decision**: On a 409 from open, re-read the current session. If the user now has an open
session, report the cashier-busy case and offer the close path (FR-010). Otherwise report
the drawer-busy case. Do **not** branch on the backend's `detail` text.

**Rationale**: This is the decision most likely to be got wrong, because the spec records
the two `detail` strings as the only server-side discriminator and the obvious
implementation is to match them. Matching them would couple the UI to untranslated
English server prose that no contract promises to keep stable. The client has a better
discriminator available: `GET /cash-sessions/current` is authoritative about whether *this
user* has an open session, which is exactly what separates the two cases. The remedies
also differ in a way that makes the re-read the right shape — cashier-busy needs the UI to
navigate to the blocking session, which requires fetching it anyway.

**Good news on plumbing**: no new error infrastructure is needed. `mapDioException`'s
`default:` branch already extracts FastAPI's `{"detail": "..."}` for any unhandled status,
so a 409 arrives as `ServerError(statusCode: 409, message: <detail>)` and
`e.serverMessage` exposes it. The detail string is still surfaced as the secondary line of
the error banner, matching the established `error` + `errorDetail` form-controller
pattern — it is just not *parsed*.

**Explicitly not doing**: adding an `AppError.conflict` variant. `AppError` is a `sealed`
union with two exhaustive switches (`app_error.dart` `serverMessage`, `error_banner.dart`
`_messagesFor`); a new variant breaks both and ripples to 76 `serverMessage` call sites,
for no gain over matching `statusCode == 409`.

**Alternatives considered**: string-matching `detail` (brittle, English-only); adding a
union variant (disproportionate); treating both 409s identically (fails FR-009, which
requires distinct remedies).

---

## 5. Resolving cashier and drawer ids to names

> **Superseded by §17.** mbe-api#141 shipped mid-implementation and expanded these FKs
> server-side. Kept below as the honest record of why the final design needs no resolution
> step at all — this section describes the workaround that is no longer necessary.

**Decision (as originally made — no longer the implementation)**: Two different strategies,
because the two catalogs have different size risk.
- **Cash drawers** — one `list(limit: 100)` call cached in a `FutureProvider`, exposed as
  an id→drawer map. Assert coverage against the returned `total`. This same provider
  backs the drawer filter picker.
- **Employees** (`cashier`, and `cash_supervisor` on detail only) — the *existing*
  `employeeDisplayNameProvider` family, one watch per distinct id. Riverpod's family
  dedupes identical ids, and it already degrades to `null` so the caller falls back to the
  raw id.

**Rationale**: `CashSessionResponse` returns three bare FK ints (`cash_drawer`, `cashier`,
`cash_supervisor`) where the repo's dominant precedent is a backend-expanded object —
`CashDrawerResponse.facility` is already `{facility_id, name}`. So this feature is paying
for an inconsistency on the mbe-api side. A "load all employees" map is not safe:
employees is a headcount-sized catalog, the hard page cap is 100 everywhere, and there is
no fetch-many-by-id filter. Cash drawers are physical stations and comfortably fit one
page, which is checkable rather than assumed.

**Honest cost**: labelling a 20-row page costs 1 (sessions) + 1 (drawers, cached across
pages) + N requests, where N is the number of *distinct* cashiers on the page — typically
1–3 for a drawer-filtered history, worst case 20. This is the first place in the codebase
that resolves an FK per row; every one of the 8 existing `*DisplayNameProvider` call sites
resolves exactly one id, for a filter chip or a detail field.

**The real fix is upstream** — see §14, issue A. Once `cashier`/`cash_drawer`/
`cash_supervisor` are expanded server-side, the drawer map and the per-row employee
watches both delete cleanly and the entity gains flattened `*Name` fields like
`CashDrawer` already has.

**Alternatives considered**: load-all employees (unsafe above 100, and silently wrong);
`Future.wait` over ids inside the controller (hides N requests behind one spinner and has
exactly one weak precedent in the repo); showing raw ids (fails FR-027's readability
intent).

---

## 6. The close surface is the session detail screen

**Decision**: One screen implements the count and the close: the session detail screen,
for a session that is open or stale and a viewer holding privilege 111. The shift panel
and the history list both *navigate* there. No close dialog, no `/close` route.

**Rationale**: This falls out of constitution §VI rather than being a style choice. Record
actions belong on the record's own detail screen, not on list rows — which also means the
history row needs no action icon at all, trivially satisfying the at-most-two-icons rule.
It gives FR-021's empty-count confirmation and FR-023's post-close summary a single home,
and it means the count is implemented once while being reachable from both entry points
(the cashier's own shift, and a supervisor recovering someone else's abandoned session,
User Story 4).

**Consequence for `RecordFormActions`**: the shared component does not fit. Its modes are
`create`/`view`/`edit` and its buttons are Delete/Edit/Save; Close is none of those, and a
cash session is never editable or deletable (FR-032). §VI's general rule still applies —
Close renders as a `FilledButton` in the record's action area in the screen body, never an
app-bar icon. `RecordFormActions` is correctly *not* used here, which a reviewer should
expect rather than flag.

**Alternatives considered**: a modal dialog holding 11 denomination rows plus three totals
(cramped on compact, and `pricing_screen.dart`'s `StatefulBuilder` dialog is the only
precedent for editable amounts in a dialog — workable but worse); a dedicated
`/close` sub-route (a third route and a third guard for one form).

---

## 7. The drawer picker needs a privilege the cashier may not have

**Decision**: Gate the drawer picker on `can(cashDrawers, read)`. When the user holds it,
render the standard `CatalogEntityPicker<CashDrawer>`. When they do not, render no picker
and use their assigned drawer, labelled from `userSettings.cashDrawerName` — which needs
no request. When they hold neither the privilege nor an assigned drawer, offer no way to open
a session and show an error directing them to their administrator.

**Rationale**: A finding the spec did not anticipate. `GET /cash-drawers` is gated on
`SystemObject.CASH_DRAWERS (10)` READ, a different object from the `POS (44)` that gates
session open. So a cashier provisioned only for counter work can open a session but cannot
list drawers — the picker would 403 and the screen would look broken. The saving grace is
that `user_settings` already carries `cashDrawerId` *and* `cashDrawerName`, resolved
server-side, so the common case needs no drawer lookup at all.

**Spec implication — RESOLVED 2026-08-04**: FR-007 originally said that a user with no
assigned drawer must be required to select one, which is unachievable without
`cashDrawers:read`. Raised with the requester during planning and settled: **the permission
is a real requirement, not an obstacle for the screen to route around.** FR-007 is now scoped
to users permitted to browse the drawer catalog, and the new **FR-007a** covers the third
case — no open affordance at all, plus an error stating a drawer must be assigned and
directing the user to their administrator. The same treatment covers a fourth case the fork
also produces: a permitted user facing an empty drawer catalog has nothing to select and the
remedy is equally administrative.

**Alternatives considered**: always rendering the picker (403s for a legitimate cashier);
gating the whole feature on `cashDrawers:read` (locks out exactly the cashiers it is for);
silently opening without a drawer and letting the server's 422 explain (surfaces a raw
backend string for a condition the client can detect up front).

---

## 8. The denomination ladder is a domain constant

**Decision**: A single ordered list of 11 distinct values in
`lib/features/sales/domain/denominations.dart`: 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1,
0.50 — descending, declared as strings and parsed by `money.dart`.

**Rationale**: There is no denomination catalog anywhere in mbe-api — no table, no
constant, no config, no SAT entry. Server validation is only `denomination > 0` and
`quantity >= 0`, so the API would accept `{denomination: 137.42}`. The ladder is therefore
client-owned by necessity, and the domain layer is where a currency fact belongs. The
20-peso value appears once even though it circulates as both a note and a coin, because
`cash_count.type` cannot distinguish notes from coins and a duplicated row would only
confuse the count (spec A-001).

**Alternatives considered**: splitting into notes and coins sections (the schema cannot
represent the distinction, so it would be presentation-only fiction over two rows with the
same value); a free-form "other denomination" row (nothing asks for it, and it invites the
`137.42` the API would accept).

---

## 9. Status is derived, and needs a new chip

**Decision**: A domain enum `CashSessionStatus { open, stale, closed }` plus a pure
function deriving it from `end` and `start` versus today, in the domain layer so it is
unit-testable without a widget. A feature-local `CashSessionStatusChip` renders it.

**Rationale**: `CashSessionResponse` carries no status — only `GET /current` returns a
state, and only for the caller's own session. So list rows and detail must replicate
mbe-api's `session_state` rule exactly (`end == null` → open; open and
`start.date() < today` → stale), which is FR-002. Putting it in the domain layer is what
makes "100% of sessions show a consistent status" (SC-006) testable as a property rather
than by driving three screens.

**Why a new chip**: `EntityStatusCell` is hard-wired to the three-value `EntityStatus`
enum (`active`/`inactive`/`archived`) and renders `active` as bare text with no chip. There
is no generic status badge in the codebase. The new one mirrors `EntityStatusCell`'s
colour-pair `switch` and `Chip` shape, and stays feature-local because the enum is
feature-specific.

**Alternatives considered**: mapping onto `EntityStatus` (three states that mean something
else entirely); computing status in each widget (three copies of a rule with a date
boundary — exactly what SC-006 guards against).

---

## 10. No number pad — plain numeric fields

**Decision**: The count uses one plain `TextFormField` per denomination with
`keyboardType: TextInputType.number`. No keypad widget.

**Rationale**: The app is desktop/web-first (§VI) where a hardware keyboard is present,
and 11 quantity fields with tab-order are faster to fill than any on-screen pad. It also
avoids creating `lib/core/widgets/number_pad.dart`, which spec 020 owns — so the two
features share no new widget. FR-040 is met by `keyboardType` on the compact tier.

**Note for implementation**: there are zero `TextInputFormatter` usages in non-generated
`lib` today, so whole-number validation (FR-022) follows the existing convention —
validate in the controller, not with an input formatter.

**Alternatives considered**: reusing 020's planned `NumberPad` (creates a dependency on an
unstarted spec, and the spec's own decision was that the two must ship in either order);
building a keypad here (a shared widget for one screen's benefit, and 020 would then
create a second one).

---

## 11. The empty-count confirmation is hand-rolled and local

**Decision**: A local `showDialog<bool>` + `AlertDialog` in the feature, for FR-021.

**Rationale**: The only shared confirmation helper is `RecordDeleteConfirmation`, wired
into `RecordFormActions` and specific to delete — unreachable here (§6). Every non-delete
confirmation in the codebase is hand-rolled locally (`merge_products_screen.dart`,
`pricing_screen.dart`, `taxpayer_certificate_upload_dialog.dart`,
`address_inline_create.dart`). Promoting a generic `showConfirmDialog` to `core/widgets/`
for a single new caller would be an abstraction for single-use code.

**Alternatives considered**: promoting a shared confirm helper (defensible, but four
existing hand-rolled sites means the promotion should be its own cleanup, not a rider on
this feature).

---

## 12. Filtering, paging and URL state — reuse wholesale

**Decision**: Reuse the established list stack unchanged: a freezed `CashSessionFilter`
built by `fromQuery(ListQuery)`, an `@riverpod` family list controller keyed on it,
`fetchClampedPage` for paging, `CatalogFilterBar` + `showCatalogFilterSheet` for the
drawer facet, `DataTableView` with `pagination:` for the table, and
`CatalogListStateView` for the four load states. Page size 20.

**Rationale**: Every piece FR-027 to FR-030 needs already exists and is uniform across
~15 catalog screens. Two specific payoffs: `fetchClampedPage` already handles the
shrinking-last-page edge case the spec lists, and filter state living in the URL means the
drawer facet survives a reload and a shared link for free. The drawer facet follows
`payment_method_options_list_screen.dart` exactly — a `CatalogEntityPicker` as a filter,
with a display-name provider to label a cold-loaded id.

**One deviation from the catalog pattern**: no search box. The endpoint has no `search`
parameter and a cash session has no free-text field to search on (see §14, issue B). The
`CatalogFilterBar.search` slot is required, so the drawer picker occupies the filter slot
and the search slot renders nothing — a departure from every other list screen that must
be visible in review, not buried.

**Alternatives considered**: client-side filtering over the fetched page (wrong across
page boundaries — explicitly rejected in the spec, D-003); a bespoke list implementation
(15 screens of precedent say no).

---

## 13. Payment-method labels need a small promotion

**Decision**: Promote the private `_paymentMethodLabel(AppLocalizations, PaymentMethod)`
from `payment_method_option_detail_screen.dart:364` to a shared function beside the enum in
`lib/core/domain/payment_method.dart`, and update its one existing caller.

**Rationale**: FR-031 renders per-method totals with localized labels. The ARB keys already
exist (`l10n.paymentMethodCash`, …) but the enum→label mapping is private to a catalog
screen. Copying a 15-arm switch is the kind of duplication that drifts the moment a method
is added; the enum's own file is where the mapping belongs. Small, mechanical, one caller.

**Note**: `PaymentMethod.fromCode` returns `null` for unrecognized codes with a documented
"render the raw code rather than crash" posture. The per-method rows follow it — a
`payments_by_method` entry with an unknown method shows the raw code, not an error.

**Alternatives considered**: duplicating the switch (drift); an extension in the feature
(same duplication, differently placed).

---

## 14. mbe-api gaps to file as issues — both RESOLVED 2026-08-05

Constitution §III forbids editing mbe-api from an mbe-ui session and requires each needed
backend change be filed as an issue and recorded as a plan dependency. Filing is established
practice — spec 020 filed eight. **Both were filed on 2026-08-04 and both shipped on
2026-08-05, mid-implementation.** See §17 for the full account of what changed and what it
deletes from this plan. The two entries below are kept as the historical record of what was
asked for and why — not as open work.

**Issue A — [mbe-api#141](https://github.com/mictlanix/mbe-api/issues/141) — expand the
cash-session FKs. RESOLVED.** `CashSessionResponse` returned `cash_drawer`, `cashier` and
`cash_supervisor` as bare ints, while `CashDrawerResponse.facility` was already expanded to
`{facility_id, name}`. Asked for these three to expand to match. **Shipped as**: `cash_drawer`
→ `CashDrawerSummary` (id/facility/code/name/comment/status), `cashier`/`cash_supervisor` →
full `EmployeeResponse`. The per-row lookups in §5 are deleted, not reduced.

**Issue B — [mbe-api#142](https://github.com/mictlanix/mbe-api/issues/142) — filters and
sort on `GET /cash-sessions`. RESOLVED.** Only `cash_drawer` was supported. Asked for a
cashier filter, a date-range filter, a status filter, and a sort choice — everything except
free-text search, which was deliberately not requested since a session has no text field.
**Shipped as**: `cashier`, `facility`, `status` (`CashSessionStatus`), `date_from`/`date_to`,
`sort` (`CashSessionSort`, default `-id`) — every facet asked for, plus a `facility` filter
that wasn't. The §VI "no search box" deviation in plan.md's Complexity Tracking narrows to
"no free-text search," which no requirement needs; cashier/status are now real UI facets
per §17.

**Not filed**: returning the closing denomination counts (spec D-004). No requirement in
this feature needs it — FR-033 explicitly declines to show it — so filing it would be
speculative.

---

## 15. Coordination with in-flight spec 020

Spec 020 (`origin/020-point-of-sale`) is `ready-to-implement` with **zero** hand-written
`lib/` changes — verified: `git diff --name-only main origin/020-point-of-sale -- lib/
pubspec.yaml` touches only `lib/generated/openapi/**`. Nothing is built, so nothing here
is blocked. Four planned overlaps, none of them a design conflict:

| Artifact | Overlap | Resolution |
|---|---|---|
| `lib/features/sales/` module dir | Both create it | Additive. Different files inside; no conflict. |
| `pubspec.yaml` — `decimal` | Both add it (020 T002) | Idempotent one-line addition. Second to land drops its task. |
| `lib/features/sales/domain/money.dart` | Both create it (020 T008) | **Same path, same responsibility** — parse/add/subtract/compare/isZero over `decimal`, values `String` at the boundary. Deliberately matched so the second to land merges or drops. Because both features live in `features/sales`, there is no cross-feature import problem and no reason to promote it to `core/`. |
| `money_formatters.dart` promotion | Both do it (020 T004) | Idempotent *if* both use the same target path and class name, which this plan does. Note 020's task under-scopes it to 2 files; the correct scope is 9 + 2 tests (§3). |
| `app_router.dart`, `nav_destinations.dart`, both `.arb` files | Both append entries (020 T015, T043/T044/…) | Textual merge conflicts, mechanically resolvable — all are append-to-list edits. Both branches re-run `flutter gen-l10n` after merge. |
| `lib/core/widgets/number_pad.dart` | 020 only | Avoided entirely by §10. |

**Recommendation, not a requirement**: landing the `money_formatters` promotion and the
`decimal` addition as one small prep PR on `main` before either feature branch would remove
the two most annoying overlaps and fix 020's under-scoped task once, for both features.

**No reverse dependency**: 020 lists cash sessions in its Out of Scope and its A-005 states
a payment does not require a session, so nothing in 020 waits on this feature, and this
feature touches nothing 020 needs.

---

## 16. Detecting "other open sessions" for FR-004 — a bounded heuristic, not a guarantee

**Decision**: When the shift panel loads an open or stale current session, issue one extra
call, `list(cashDrawer: session.cashDrawerId, limit: 100)`, and check it for another row with
the same `cashierId`, `end == null`, and a different `cashSessionId`. Show FR-004's "other
open sessions exist" note only on a match. Absence of a match is treated as "none found", not
proven as "none exist" — the note is simply not shown, silently.

**Why this needed deciding**: `GET /current` returns only the caller's single most recent
open session, by construction. FR-004 requires knowing whether *more* exist, and the list
endpoint has no cashier filter (issue B) — so the only exhaustive way to answer that is to
page the entire sessions table checking every row, which is unbounded and, worse, backwards
for the case that motivates the requirement: mbe-api sorts `cash_session_id DESC`, and the
legacy-migration orphans User Story 4 targets have old, low ids, so an exhaustive scan would
need to page through nearly the whole table before reaching them — while a scan capped to the
first few pages would systematically *miss* exactly the rows it exists to find.

**Why the same-drawer scope is the right compromise, not a shortcut**: it is cheap — one
bounded request, not a scan — and it is not vacuous. The uniqueness rule that stops the *same
drawer* from having two open sessions is enforced only at request time by
`open_cash_session`, not by a database constraint, so pre-invariant legacy rows can and do
violate it. A cashier who repeatedly opened and failed to close on one drawer, before the
current backend existed to refuse it, is caught by this exact query. A cashier whose orphans
are spread across *different* drawers is not — that gap is real and is not being papered over.

**What this is not**: not a substitute for the history list, which is where User Story 4's
Independent Test actually verifies recovery — by filtering to a drawer and reading the rows,
which needs no heuristic at all because a human is looking at the full, honest list. The panel
check is a proactive nudge for the common case, not the mechanism the spec depends on for
correctness.

**Closes cleanly with issue B**: once a cashier filter exists, this becomes
`list(cashier: myEmployeeId, limit: 100)` with no drawer restriction, and the same-drawer
caveat disappears. Nothing else about the shift panel changes.

**Alternatives considered**: an unbounded paged scan (unbounded cost, and backwards relative
to where the target rows live); capping a scan to the first N pages by recency (actively
wrong for the motivating case, for the reason above); never attempting detection and dropping
the note (fails FR-004 outright, and removes the only proactive signal a cashier gets before
being blocked by a stale session they didn't know they had).

> **Superseded by §17.** mbe-api#141/#142 shipped mid-implementation and removed the need for
> this heuristic entirely — see §17 for the direct replacement.

---

## 17. mbe-api#141 and #142 shipped mid-implementation — three planned workarounds deleted

**What changed**: both issues filed in §14 were resolved and the client regenerated
(commit `0a64bc7`/`cdd5193`) while this feature was already in progress. Confirmed by reading
the regenerated models directly, not by trusting the issue titles:

- `CashSessionResponse.cashDrawer` is now `CashDrawerSummary` (`cashDrawerId`, `facility`,
  `code`, `name`, `comment`, `status`) — a real object, not a bare int. `cashier` and
  `cashSupervisor` are now full `EmployeeResponse` (`employeeId`, `firstName`, `lastName`, …).
  This is issue A, closed exactly as filed.
- `GET /cash-sessions` gained five parameters: `cashier` (`int?`), `facility` (`int?`),
  `status` (`CashSessionStatus?` — a **generated** enum with members `open`/`stale`/`closed`,
  whose doc comment states it derives from `end`/`start` "exactly as `session_state` does" —
  the identical rule this plan's `cashSessionStatusOf` was written to replicate), `dateFrom`/
  `dateTo` (`DateTime?`), and `sort` (`CashSessionSort` — `-id` default, `start`, `-start`).
  This is issue B, closed for every facet except free-text search, which nothing in this
  feature needed in the first place (a session has no text field).
- The open and close request/response shapes (`CashSessionOpen`, `CashSessionClose`,
  `Denomination`, `OpeningAmount`, the `AnyOf` wrapper problem) are **untouched** — confirmed
  by diffing the two regeneration commits, which touch only `cash_sessions_api.dart`,
  `cash_session_response.dart`, and the two new model files. Nothing in §4, §6, or the
  close-flow contract changes.

**What this deletes outright:**

- **§5's per-row name resolution is gone.** There is nothing left to resolve — `cashDrawer`
  and `cashier` arrive already expanded. No cached drawer-name map, no
  `employeeDisplayNameProvider` watches per row, no "first per-row FK resolution in the
  codebase" finding. `CashSession.cashDrawerName`/`cashierName`/`cashSupervisorName` are
  populated directly from the response in `fromResponse`, the same shape `CashDrawer.
  facilityName` already uses.
- **§16's same-drawer heuristic is gone.** FR-004 ("indicate that further open sessions
  exist") is now answered by one direct, exact query — `list(cashier: myEmployeeId, status:
  CashSessionStatus.open)` — filtered server-side, not approximated client-side. It finds
  *every* open session for the cashier, on any drawer, not just the current session's own
  drawer. The entire "bounded, not exhaustive" caveat in §16 no longer applies to anything.
- **Issue A and issue B are both closed.** Remove them from any "file these" checklist —
  they are shipped, not pending.

**What this adds to scope, deliberately:** spec.md's D-003 stated the history list "ships the
drawer facet alone" because the endpoint supported nothing else — that premise is now false.
The history list filter sheet gains **cashier** and **status** facets alongside drawer,
matching the exact `CatalogEntityPicker` + `EntityStatusFilterChips`-style pattern
`payment_method_options_list_screen.dart` already uses for its facility+status pair. This is
not scope creep into a new story — it is User Story 3's own goal ("browse a paginated,
drawer-filterable list") filled out with facets the backend now actually offers, using
components already read and understood for this feature. A **date-range** facet is *not*
added: no user story or FR asks for one, and adding UI for a filter nothing requires would be
exactly the kind of speculative surface constitution and CLAUDE.md both warn against. The
repository method still accepts `dateFrom`/`dateTo` (cheap to expose, matches the endpoint),
but nothing in the UI wires them.

**What stays exactly as designed:** §1 (module placement), §2 (decimal), §3 (formatter
promotion), §4 (409 disambiguation via re-read — a list filter changes nothing about a
*write* conflict), §6 (count/close on the detail screen), §8 (denomination ladder), §10
(number pad decision), §11 (empty-count dialog), §13 (payment-method label promotion), §15
(spec-020 coordination). None of those depended on the old response shape or the old filter
set.

**Cost of not catching this before writing code**: none — this was caught during Foundational
implementation, before the repository, entities, or the US3/US4 tasks it invalidates were
written. The only casualty is time spent researching a heuristic (§16) and a name-resolution
scheme (§5) that turned out to be temporary scaffolding for an API gap that closed under the
feature. That research is kept, not deleted, because it is the honest record of why the
simpler final design is correct — a reader who only sees §17 might reasonably ask "why not
just resolve names server-side," and §5 is the answer: *now* it is; it wasn't when this
started.

---

## 18. Blocking build defect — [mbe-api#144](https://github.com/mictlanix/mbe-api/issues/144), filed 2026-08-05, open

**Not one of the two enhancement requests above** — a genuine regression, introduced by
#142's own fix, discovered immediately after regenerating for §17. `CashSessionSort`'s schema
declares `default: "-id"`; openapi-generator's dart-dio codegen renders that dash-prefixed
enum default as literal Dart (`CashSessionSort? sort = -id,`) instead of
`CashSessionSort.id`, which does not compile (`Undefined name 'id'`).

**Blast radius is the whole app, not this feature.** Confirmed by running
`test/unit/features/catalog/cash_drawer_test.dart` — unrelated to cash sessions — which fails
with the identical error, because every file importing `mbe_api_client.dart` transitively
pulls in the broken method signature. `flutter analyze` stays clean only because
`analysis_options.yaml` excludes `lib/generated/**`; the compiler used by `flutter test`/
`run`/`build` does not honor that exclusion.

**This feature is blocked on it, not working around it.** Per constitution §III, generated
files are never hand-edited, and no template/local fix survives the next real regeneration.
There is nothing to design around — the client must compile before any of this feature's code
can be analyzed or tested, and T006 onward hadn't started when this was found (T001–T005 are
complete, verified, and untouched by this — they have nothing to do with the cash-sessions
API surface).

**Resolution path**: filed with a proposed fix (drop the schema-level default on `sort`,
apply it in the service layer instead, matching how `skip`/`limit` are already defaulted).
Once merged and the client regenerated, resume at T006. No design decision in this plan
changes as a result of this issue — it is a pure build blocker, not a shape or scope question
like #141/#142.

---

## 19. Seeding an `autoDispose` controller from outside the widget that watches it — found during T020

**What happened**: `OpenSessionFormController` (`@riverpod`, therefore `autoDispose`) needs a
one-time seed — the cashier's assigned drawer, read off `authNotifierProvider` — before the
open form is useful. The obvious place to do that is `CashSessionsScreen`'s `initState`,
mirroring `CashDrawerDetailScreen`'s existing seeding pattern for a pre-selected facility.
That obvious placement is wrong here, and the widget test (T020) caught it: the seed call
landed on a transient controller instance with zero listeners, which Riverpod disposed
before `_OpenForm` — the widget that actually watches
`openSessionFormControllerProvider` — ever mounted. By the time `_OpenForm` built, it
created a *fresh* controller via `build() => const OpenSessionFormState()`, and the seed was
gone. `CashDrawerDetailScreen`'s precedent seeds `CashDrawerFormController`, which is exactly
the same shape (`@riverpod`, `autoDispose`) — that one likely survives only because its
consuming screen mounts and starts watching within the same frame the seed lands, which
`CashSessionsScreen`'s two-hop `currentAsync.when(... data: (current) => ... _OpenForm())`
does not guarantee.

**The fix**: seed from *inside* the `build()` that watches the target provider, not from a
lifecycle hook on a different widget above it:

```dart
// _OpenForm.build(context, ref) — already does ref.watch(openSessionFormControllerProvider)
if (formState.cashDrawerId == null && settings?.cashDrawerId != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.seedAssignedDrawer(settings?.cashDrawerId, settings?.cashDrawerName);
  });
}
```

The provider is guaranteed alive for the duration of this `build()` because this very call is
what's watching it — the disposal race cannot occur here by construction. The `cashDrawerId
== null` guard makes it idempotent: harmless to re-check every rebuild, and it never re-fires
once seeded or once the cashier makes their own pick.

**Consequence for `CashSessionsScreen` itself**: with the seed moved, the screen needed no
`initState`, no `dispose`, no subscription bookkeeping — it collapsed from a
`ConsumerStatefulWidget` to a plain `ConsumerWidget`. Simpler code was the *result* of finding
the right seed location, not a separate cleanup.

**Applies to the rest of this feature**: `CloseSessionFormController` (US2) and any
seeding `CashSessionDetailScreen`/`CashSessionsScreen`'s history region (US3/US4) do — check
whether the seed originates from the same widget that watches the target provider before
reaching for `initState`. If it doesn't, use this pattern instead.

**Also caught in the same test, unrelated**: a `RenderFlex` overflow from pumping
`CashSessionsScreen` directly as a route's `builder` return value with no `Scaffold`. Every
production screen renders inside `AppShell`'s `Scaffold`; a test route needs to provide one
explicitly (`GoRoute(builder: (c, s) => Scaffold(body: CashSessionsScreen(...)))`) or a
`SingleChildScrollView` with unbounded-height content can misbehave in ways that don't occur
in the real app shell.
