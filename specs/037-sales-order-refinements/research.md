# Phase 0 Research: Sales Order Refinements

**Feature**: 037-sales-order-refinements | **Date**: 2026-09-04

Findings come from direct code reading (two parallel research passes plus follow-ups) and, for
R1–R3, a **read-only** look at the sibling `mbe-api` checkout's service layer — never edited, per
constitution §III.

The headline: the credit-terms ask (US2) is not the change the spec assumed it was. mbe-api
already derives credit terms in the one place the spec's own wording pointed at, and the real gap
is somewhere else entirely. R1–R3 work that out; the rest is presentation.

---

## R1 — Why credit customers land on immediate terms, and where the gap actually is

**Findings.** mbe-api derives payment terms **on create** but never on update:

- `POST /sales-orders` with `payment_terms` omitted derives it server-side
  (`app/services/sales_order_service.py:481-493`): `NET_D` when `customer.credit_limit > 0` **and**
  the customer is not `settings.default_customer_id`; otherwise `IMMEDIATE`.
- `PUT /sales-orders/{id}` re-prices lines and syncs the salesperson on a customer change, but
  **never touches `payment_terms`** (`sales_order_service.py:646-670`). Terms move only when
  `payment_terms` is explicitly in the payload.

Neither screen opens a sale eagerly — both controllers build to `null` and write nothing until the
first action (`pos_sale_controller.dart:38`, `orders/order_editor_controller.dart:26-29`). So which
request comes first decides everything, and the two surfaces differ:

- **Back-office, new order.** Spec 036 made the customer genuinely first: the product search field
  is *absent* until a non-generic customer is attached (`order_screen.dart:200-203`, `:255-260`),
  and `OrderHeaderPanel` renders only `if (sale != null)` (`:232`). The only possible first action
  is the customer pick → `_updateHeader(customer:, salesperson:)` (`customer_bar.dart:243-246`) →
  the fast path at `sale_editing.dart:93-108` (it qualifies, since nothing else is passed) →
  `repository.open(customer:, salesperson:)` → one POST → **the server derives `NET_D` already**.
- **POS register.** The first action is typically a scan → `product_lookup_controller.dart:26`
  `ensureOpen()` → `repository.open()` with **no** customer → the server falls back to
  `settings.default_customer_id` (`sales_order_service.py:471-473`), which is explicitly excluded
  from `NET_D` → `IMMEDIATE`. The customer attached afterwards arrives by PUT, which never revisits
  terms.

**Decision.** Send `paymentTerms` on the customer-attach write **only when a sale already exists**.
When it does not, leave the existing fast path alone and let the server derive.

This splits cleanly by case:

| Case | Behaviour after this feature |
|---|---|
| Back-office, new order, credit customer | **Unchanged** — one POST, server derives `NET_D`. Already correct today. |
| Back-office, new order, cash customer | **Unchanged** — one POST, server derives `IMMEDIATE`. |
| POS, customer attached to an open sale | PUT now carries derived terms — **this is the reported bug's fix**. |
| Either surface, customer *changed* on an existing order | PUT now carries derived terms — satisfies FR-007's fall-back-to-immediate too. |

**Rationale.** Adding `paymentTerms` unconditionally would disable the spec-036 fast path
(`sale_editing.dart:93-108` runs only when `customer`/`salesperson` alone are requested), turning
the back-office new-order flow from one POST into POST + PUT — two round trips to reach a state the
single POST already reaches correctly. That is a pure regression bought for nothing. Extending
`open()` to accept terms was considered (the DTO supports it —
`lib/generated/openapi/lib/src/model/sales_order_create.dart:44`) and rejected for the same reason:
the server's own derivation is already the behaviour we want, so mirroring it client-side adds a
second source of truth for no gain.

## R2 — The client already knows the credit limit at attach time

**Findings.** `CustomerListItem` carries `required String creditLimit` and `creditDays`
(`lib/features/catalog/domain/entities/customer_list_item.dart:22-23`, mapped at `:34-35`), and the
picker's `onSelected` hands the whole item over (`customer_bar.dart:243-246`). So `hasCredit` is
computable **synchronously at the moment of attach** — no extra fetch, no round trip, no flicker,
no "attach now, correct it later" window.

Do **not** reach for `saleCustomerControllerProvider` here: it fetches a fuller record but is
autodispose-keyed by customer id and will not be warm for a customer just picked
(`capture/sale_customer_controller.dart:15-18`).

`Customer.creditLimit` and `CustomerListItem.creditLimit` are both **non-nullable `String`**
(`catalog/domain/entities/customer.dart:46`), and mbe-api's `credit_limit` is a `Decimal`
defaulting to `0`, non-null on both response schemas (`app/schemas/customer.py:51,94,112`). There is
therefore **no null-vs-zero distinction**: "no credit line" means exactly zero. The existing
`creditLimit != null` guard at `customer_bar.dart:430` guards `AsyncValue.valueOrNull`, not a
nullable field. `isZeroAmount` is an exact `Decimal` comparison that throws on malformed input
(`features/sales/domain/money.dart:110`).

**Decision.** Derive the terms from the picked `CustomerListItem.creditLimit` in
`CustomerBar._updateHeader`'s caller, using the same `isZeroAmount` predicate `_TermsFact` already
uses, so the dropdown's enablement rule and the write's defaulting rule can never disagree.

**Rationale.** One predicate, one source, evaluated at the one moment the answer is already in hand.

## R3 — The overdue-credit refusal, and why a retry cannot detect it

**Findings.** `NET_D` is validated by `_assert_credit_allowed`
(`app/services/sales_order_service.py:419-450`), which raises **422** when the customer is the
default walk-in customer, when `credit_limit is None or <= 0`, **or when the customer has any
overdue completed/unpaid order**. The check sits at outer indentation (`:491-492`), so it runs for
the server's own *derived* value too, not only for an explicit one.

Two consequences:

1. **A latent bug that predates this feature.** A credit customer with an overdue order cannot be
   attached to a new back-office order at all — the POST 422s outright, before spec 037 changes
   anything. Recorded here; see "Discovered, out of scope" below.
2. **Client-side `hasCredit` cannot predict acceptance.** We know the credit limit; we do not know
   the overdue state. So a combined write carrying `netD` can be refused, and — because the customer
   rides in the same payload — the refusal would take the customer attach down with it. That would
   be a real regression: today that customer attaches fine, since the PUT simply never mentions
   terms.

A "try credit, fall back to immediate on refusal" retry was considered and **rejected**. The 422
body is prose only — `{"detail": "<string>"}`, three distinct English strings
(`sales_order_service.py:422-449`), no code, no `loc`, no type. Worse, our own network layer
discards it: `auth_interceptor.dart:56-57` routes every 422 through `_fieldErrorsFrom`, which
returns `const []` unless `detail` is a **List** (`:86-89`), so a string-detail 422 becomes
`ValidationError([])`; `serverMessage` is hardcoded `null` for that type
(`core/errors/app_error.dart:47`) and `ErrorBanner` falls back to the generic
`errorValidationGeneric` (`core/widgets/error_banner.dart:66-68`). A retry could therefore only
catch 422 *broadly*, which would silently swallow unrelated validation failures.

**Decision.** Never let the terms default endanger the customer attach:

- **Cash customer** (`creditLimit` is zero): terms ride **in the same PUT** as the customer. Sending
  `immediate` is never asserted against, so it cannot be refused. This is what satisfies FR-007.
- **Credit customer** (`creditLimit` greater than zero): attach the customer **first**, unchanged,
  then issue a **separate follow-up** `updateHeader(paymentTerms: netD)`. If the server refuses it,
  the refusal is swallowed and the order stays on immediate terms — the customer is already
  attached, and the dropdown then shows Contado, which is the truth about what the server will
  accept.

**Rationale.** The asymmetry is not arbitrary: it follows exactly which value the server validates.
`immediate` is unconditionally acceptable, so it costs nothing to bundle; `netD` is conditionally
acceptable, so it must not be bundled with anything whose failure would matter. The cost is one
extra round trip when attaching a credit customer to an already-open sale — the POS path, where the
alternative is the manual step this feature exists to remove. Swallowing that one refusal is not
error-hiding: the user is left in the state the server insists on, with a control that still says so
and still lets them try credit explicitly (and get the same message they get today).

## R4 — The wasted vertical space is not a theme gap

**Findings.** The design system **already** renders dense inputs on pointer platforms:
`inputDecorationTheme` sets `isDense: density.inputIsDense`
(`core/design/component_themes.dart:61-84`), and `Density._pointer` sets `inputIsDense: true`
alongside `VisualDensity.compact` and a 40 px minimum target (`core/design/density.dart:46-54`),
keyed on input modality rather than width. So the panel is already as dense as
`InputDecorationTheme` can make it.

What remains is the **chrome itself**: every field is `filled: true` over `surfaceContainer` with a
full `OutlineInputBorder` on all four sides and a floating label inside the box. That is the
affordance for typing a value — and most of this panel is not typed into at all. Of the ten
controls, one is a text field (comment), two are read-only values (due date, exchange rate), three
launch pickers (contact, ship-to, salesperson/recipient), and two are dropdowns.

**Decision.** Treat the density work as **local to `OrderHeaderPanel`**. Do not widen
`InputDecorationTheme`.

**Rationale.** Changing the shared input theme would restyle every form in the application — a blast
radius far beyond the eight items asked for, and a change nobody asked for on screens that *are*
data entry. The panel's problem is that it dresses read-only facts and picker launchers as text
inputs, which is a per-panel authoring choice, not a theme defect.

**Cautionary precedent.** Spec 027's T031 (`specs/027-app-user-settings/tasks.md:133`) records a
layout "fix" that was verified against a bare `MaterialApp`, turned out to be an artifact of testing
without the real theme, and was reverted. Every density measurement for this feature must be taken
against the app's real theme.

## R5 — A grid run is as tall as its tallest child

**Findings.** `ResponsiveFormGrid` (`core/widgets/responsive_form_grid.dart:54-86`) lays children
out in a `Wrap` (`spacing: 16`, `runSpacing: 16`), each wrapped in a `SizedBox(width: cellWidth)` —
**width only, no height constraint**. Wrap sizes each run to its tallest child. Columns come from
`columnsForWidth` (compact 1, medium/expanded 2, large 3, capped by `maxColumns`), measured by
`LayoutBuilder` against the grid's own inner width, not `MediaQuery` — a subtlety the compact test
already documents (`test/widget/features/sales/sales_orders_compact_test.dart:131-135`).
`FormGridSpan.full` sets `width: inner` and works as expected for the comment field; note that at
`columns == 1` every child gets `inner`, so `full` is a no-op at the compact tier.

**Decision.** Convert **every** control in the disclosed group and the always-visible row to the
compact shape — not only the selection fields the user named.

**Rationale.** This is the finding that most changes the shape of the work. Because a run is as tall
as its tallest child, leaving even one full outlined `InputDecorator` in a row pins that row's
height and the panel gets **no shorter at all**. The user asked for selections specifically, but
selections alone cannot deliver SC-004; the read-only values and picker launchers sharing their rows
have to come along or the change buys nothing measurable.

The comment field is the deliberate exception: it is genuinely typed into, it spans the full width
on its own run, so its box neither pins another field's row nor misrepresents what it is. It keeps
`ConfirmableTextField` as-is.

## R6 — One compact field widget, and where it has to live

**Findings.** There is **no** shared label-over-value widget. `core/widgets/` has 24 files
(`responsive_form_grid`, `confirmable_text_field`, `catalog_entity_picker`, …) and none is this
shape; `core/design/` is tokens only. Meanwhile the shape is hand-rolled in at least five places,
in two competing styles:

| Site | Shape |
|---|---|
| `capture/customer_bar.dart:551-563` `_CustomerBarFact.fact` | `Column(labelSmall, bodyMedium)` |
| `capture/customer_bar.dart:433-477` `_TermsFact` | `Column(labelSmall, SizedBox(132, DropdownButton), labelSmall+outline)` — **the shape the user pointed at** |
| `orders/order_header_panel.dart:460-476` `_fact` | `Column(metricLabel + uppercase + 0.8 letterspacing, fieldInput)` |
| `widgets/sale_totals_bar.dart:260-283` | byte-identical to `_fact`, value defaults to `typeRoles.money` |
| `cash_session_detail_screen.dart:133-147` `_LabeledText` | `Column(labelSmall, Text)` |

Constitution §VI is explicit that "form-field wrappers MUST live in `core/widgets/` rather than being
reimplemented per module."

Note also that `_TermsFact`'s caption and supporting text both use raw `theme.textTheme.labelSmall`,
which is **not** a token — `typeRoles` has no `caption`/`supportingText` role
(`core/design/type_roles.dart:50-78`). Copying that shape verbatim would copy a token bypass.

**Decision.** Extract one widget into `core/widgets/` carrying the caption-over-control shape with
an optional supporting-text slot, and adopt it in exactly two places: `OrderHeaderPanel`'s fields and
`CustomerBar._TermsFact`. Its caption resolves through `typeRoles.metricLabel` (the closest existing
role), not raw `labelSmall`. The uppercase fact strip keeps its own existing treatment.

**Rationale.** Two adopters and a constitutional requirement make this a genuine extraction rather
than speculative abstraction. It is also the literal reading of the user's ask — the header's
selections should use "a similar widget to the formerly labeled 'Credit line'", and the honest way
to make two things similar is for them to be the same thing.

**Explicitly not migrated**: `_CustomerBarFact.fact`, `sale_totals_bar`'s block, and
`_LabeledText`. They are the *uppercase-metric* convention or live on untouched screens; folding
them in would be a five-file refactor nobody asked for. They are noted here, not deleted.

## R7 — The 132 px trap must not be carried into a grid cell

**Findings.** `customer_bar.dart:438-447` hard-codes `SizedBox(width: 132)` around the terms
dropdown, with a comment explaining why: `DropdownButton`'s widest-item measurement pass "is known to
overflow its own render box by a sub-pixel hair at some text scales (a longstanding Flutter framework
quirk)… 132 px comfortably fits 'Crédito'/'Contado' plus the built-in dropdown arrow." Nothing else
in the repo uses this workaround.

Two risks follow:

- **From the rename (FR-004).** 132 px was sized for the *items*, not the caption. "Forma de pago" /
  "Payment terms" is wider than "Crédito". The caption sits in a `CrossAxisAlignment.start` column
  and is unconstrained, so it will not overflow itself — but the column's intrinsic width grows, and
  `_FactsView`'s `Wrap(spacing: 24)` may re-wrap at compact widths. The file already records exactly
  this failure mode once (`customer_bar.dart:373-377`).
- **From reuse (FR-016).** Inside `ResponsiveFormGrid`, the enclosing `SizedBox(width: cellWidth)`
  can be **narrower** than 132 px at the compact tier — a fixed width there overflows rather than
  shrinking.

**Decision.** The extracted widget takes **no fixed width**. It fills its cell and uses
`isExpanded: true` on the dropdown (the mechanism `OrderHeaderPanel` already relies on for currency,
`:337`). `CustomerBar`'s own use keeps a width floor so its `Wrap` layout is unchanged, expressed
through spacing tokens rather than a bare literal, and is re-verified at 390 px.

**Rationale.** The quirk the 132 px guards against is real, but `isExpanded` addresses it by giving
the dropdown a bounded width from the outside — which is precisely what a grid cell already
provides.

## R8 — Text scaling: height is free, width is not

**Findings.** Spec 027 shipped four text-size levels (0.9 / 1.0 / 1.15 / 1.3,
`core/design/text_scale.dart`) composing over the platform scaler.
`specs/027-app-user-settings/research.md:89-114` (R2) is the trap writeup: vertical constants derived
from a line height must scale, since "at 1.3× the body line becomes ~26 px, so a 52 px band would
clip its own text". `tasks.md:127` (T028) records the empirical outcome — width thresholds did **not**
need scaling, because "width and text-driven height are independent, and nothing constrains the row's
height from outside, so a taller row is never an overflow."

That is reassuring for anything inside `ResponsiveFormGrid`, whose cells constrain width only (R5).
It does **not** cover `_TermsFact`'s hard 132 px, which is a width and *is* constrained — see R7.

Constitution §V requires that no screen clip, overflow or hide content at the largest level, and
that a screen with a fixed column budget be *verified* there rather than assumed to absorb it.
Constitution §VI requires that a non-trivial control band assert its insets and baselines with
widget tests "measuring real insets and baselines, not by inspection."

**Decision.** Extend `sales_orders_compact_test.dart` into a loop over all four `TextSizeLevel`
factors, following the pattern spec 027's T028 established in
`test/widget/features/sales/sale_line_symmetry_test.dart`, and add a measuring test that asserts the
panel's symmetric vertical padding and the caption/control baseline relationship.

**Rationale.** Both constitutional requirements are satisfied by the same pair of tests, and the
pattern already exists in this feature's own test tree.

## R9 — Test blast radius, and one finder that turns ambiguous

**Findings.** Three assertions break, and one breaks in a non-obvious direction:

| File | What it asserts | Effect |
|---|---|---|
| `order_header_disclosure_test.dart:112-143` | loops `[reference, status, date, salesOrdersColumnBalance]` scoped by `find.descendant(of: find.byType(OrderHeaderPanel), …)` | **Breaks** on FR-001. Drop balance from the list; add a negative assertion that it is absent in-panel. |
| `order_header_disclosure_test.dart:147-163` | `expect(find.text(l10n.salesOrderPaymentTermsLabel), findsOneWidget)` at `:153`, **unscoped** | **Breaks twice over.** FR-003 removes the field; and FR-004 gives the *same* string to `CustomerBar`, so an unscoped finder would go from one match to a different one. Must be scoped by ancestor, not merely deleted. |
| `order_header_disclosure_test.dart:165-187` | presence of 4 keyed + 3 label fields, not order | Survives — the reorder is safe. |

Goldens and screenshots: `test/golden/pos_capture_golden_test.dart:91-102` baselines
`pos_customer_bar_{light,dark}_{narrow,wide}.png` and **all four re-baseline** on the label rename
(the string is wider); `test/screenshots/pos_screens_screenshot_test.dart` shots `02`–`07` render the
capture surface and re-baseline too. No golden covers `OrderScreen`, so the header changes are
golden-free. `test/golden/core_widgets_golden_test.dart:97`'s `app_navigation` golden uses a
synthetic two-item fixture, **not** `kNavigationTree`, so the nav move does not touch it.

`customer_bar_test.dart` addresses the dropdown by `Key('pos_payment_terms_dropdown')` throughout
(`:86`, `:236`, `:255`) and never by its caption, so FR-004 breaks **no** customer-bar test.

`sales_orders_compact_test.dart:107-160` is order-agnostic and key-based, so it survives the reorder
— but it is the **overflow guard** for the density work and for moving the panel, and its scroll
loop must be re-run once the panel sits below the customer bar.

**Decision.** Scope every ambiguous finder to its panel via `find.descendant`, exactly as spec 032's
own note prescribes, and treat the golden/screenshot re-baseline as expected output of FR-004 rather
than as breakage.

## R9a — The gating coverage R9 missed, and why the density work threatens it

**Findings.** R9's pass above was scoped to the *label and ordering* changes and, in being so scoped,
missed a file that the *density* change puts squarely in its path.
`test/widget/features/sales/order_screen_readonly_test.dart` reaches three of `OrderHeaderPanel`'s
fields by `Key` and immediately **type-casts** them:

| Line | Cast | Asserts |
|---|---|---|
| ~143 | `tester.widget<DropdownButtonFormField<Currency>>` | `onChanged` is null on a non-editable order |
| ~148 | `tester.widget<CatalogEntityPicker<EmployeeListItem>>` | `enabled` is false |
| ~169, ~188 | `tester.widget<DropdownButtonFormField<Priority>>` | `onChanged` non-null for an updater, null for a reader |

Only two test files reference `OrderHeaderPanel` at all
(`order_header_disclosure_test.dart`, `sales_orders_compact_test.dart`), and **neither tests
`canEdit`** — the disclosure test covers open/close mechanics and field presence only. So
`order_screen_readonly_test.dart` is the *sole* coverage of FR-017's "edit gating unchanged"
requirement for this panel, and it is coverage that lives outside the file set R9 enumerated.

The exposure is specific: a `tester.widget<T>` cast throws if the widget at that `Key` is no longer a
`T`. Converting the panel to a caption-over-control presentation invites exactly that substitution —
"dense dropdown" reads as an instruction to stop using `DropdownButtonFormField`.

**Decision.** `CompactField` **wraps** the existing control rather than replacing it. The widget
carrying each field's `Key` keeps its current type; `CompactField` contributes the caption,
supporting text and spacing around it. T034 re-runs this file after the conversion as an explicit
verification step.

**Rationale.** Preserving the type costs nothing — the caption-over-control look is achieved by what
surrounds the control, not by what the control is — and it keeps a gating assertion that nothing else
in the suite duplicates. Loosening the cast to make a replacement widget fit would trade the panel's
only FR-017 coverage for a cosmetic preference.

## R10 — The nav reorder asserts nothing today, and one comment lies afterwards

**Findings.** Nothing asserts nav display order. `app_router_test.dart:1022-1053` iterates
`_flattenDestinations(kNavigationTree)` but filters to three unrelated destinations and asserts
`branchIndex` ↔ shell-branch correspondence, not tree position; the two read-denied tests read
`navDestinationsProvider` for presence only. Moving the `sales-orders` destination
(`nav_destinations.dart:261-272`) after `pos` (`:273-281`) is a pure list reorder —
`NavBranch.salesOrders = 20` and `NavBranch.pos = 18` are untouched, and the file's own comment at
`:39-56` states that display order comes from tree position, not index.

The doc comment at `:260-263` currently *justifies the opposite placement* ("placed before Point of
Sale — the back-office order screen is the more general entry point").

**Decision.** Reorder the destination, rewrite that comment to record the new rationale, and add the
order assertion that does not exist today.

**Rationale.** A comment that argues for the opposite of what the code does is worse than no comment.
And an ordering nobody asserts is an ordering that silently regresses.

## R11 — Producing the mock (FR-015)

**Findings.** Spec 032 was built against `Sales Order - Header.dc.html` in the Claude Design project
*Backoffice Sales Screen Redesign* (`ae78abac-31d5-48e1-b8fd-c75e2a4efeaa`), read through the
`DesignSync` tool. That project's token bundle is the same one checked into `ds-bundle/` in this
repo. Artboards are HTML/CSS while the app is Flutter, so pixel values, palette and control markup
are a *presentation*, not a requirement — everything resolves through the spec 022 tokens per
constitution §V.

The difference this time: spec 032 implemented an artboard the user had already produced, whereas
FR-015 asks for a mock to be **created** for review.

**Decision.** Draft the mock as a design canvas covering four artboards — the header stack collapsed
and expanded, at the expanded tier and at the compact tier — styled from the local `ds-bundle/`
tokens so it reads as this application rather than as a generic mock. Present it for approval before
any of FR-016 is implemented; FR-016's tasks stay blocked until then.

**Rationale.** The user asked for a mock before implementation, and the density decision (R5 — every
control in a run, not only selections) is exactly the kind of thing that is cheaper to settle in a
picture than in a diff.

---

## Discovered, out of scope

Two real defects surfaced during this research. Neither is in scope for the eight items asked for,
and neither is being fixed here; both are recorded so they are not lost.

1. **String-detail 422s lose the server's explanation** (`auth_interceptor.dart:56-57`, `:86-89`;
   `core/errors/app_error.dart:47`). FastAPI raises `{"detail": "<string>"}` for business-rule
   refusals, and our mapping only understands the list form, so the user sees a generic validation
   message where the server sent a specific one ("Customer has 3 overdue credit order(s)"). Fixing
   it is a small change in one place that would improve every 422 in the application — and it is a
   cross-cutting change to error handling, which is why it does not belong in this feature.
2. **A credit customer with an overdue order cannot be attached to a new back-office order at all**
   — the POST 422s because `_assert_credit_allowed` runs against the server's own derived `NET_D`
   (`sales_order_service.py:491-492`). This predates spec 037 and is an mbe-api behaviour; per
   constitution §III it would need an issue filed against mbe-api rather than a client-side
   workaround. Worth confirming against the live backend before filing, since it may be intentional.
