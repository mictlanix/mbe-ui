# Implementation Plan: Live Testing Session Fixes

**Branch**: `036-live-testing-fixes` | **Date**: 2026-09-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/036-live-testing-fixes/spec.md`

## Summary

Nine issues from a live testing session, spanning five otherwise-unrelated parts of the product.
Six are contained, single-module fixes: a lost pricing-grid edit (a Focus-lifecycle bug, fixed by
lifting the draft into the controller rather than patching widget teardown timing), a currency
formatting bypass in two editable price fields, three Customer-form changes (optional `code`,
reordered, two dead fields removed), a three-state stock flag in the warehouse picker, a
one-call auto-assignment of the first delivery destination, and two new deployment settings
replacing three hardcoded debounce timers.

The other three are one connected change wearing three names. "Prevent walk-in customers on Sales
Orders", "let a cashier edit a sale before paying", and "gate delivery to customers who can
receive it" all resolve to the same underlying fact: nothing in this codebase currently has a
single, shared way to answer "is this the generic customer", and the POS sale's `confirm()` call
currently fires *before* payment, not because of it. Fixing the shared predicate once, and moving
the timing of one server call, is what most of the effort here actually is.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.44.2 (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router`
(navigation, unaffected), `freezed` (value types), generated `mbe_api_client` (OpenAPI dio
client) — no new dependency introduced.

**Storage**: none client-side; all record state is server-owned. Two new values
(`inputDebounce`, `quantityCommitDebounce`) join `AppSettings` as build-time deployment config,
same tier as the existing `currencyDecimalDigits`.

**Testing**: `flutter test` — `test/unit`, `test/widget`, `test/golden`, `test/screenshots`,
`test/integration` (live mbe-api, credentials in `.env`).

**Target Platform**: desktop and web first; compact tier supported (the POS step-pill
back-navigation affordance needs a second, compact-specific home per research R2).

**Project Type**: single Flutter application, feature-first layered architecture.

**Performance Goals**: no new network calls beyond what already exists — the delivery
auto-assignment (R12) reduces per-destination calls from N to 1; the POS `confirm()` move (R1)
relocates one existing call, it does not add one.

**Constraints**: two Customer-field changes depend on an mbe-api schema change already filed as
[mbe-api#198](https://github.com/mictlanix/mbe-api/issues/198) and
[mbe-api#199](https://github.com/mictlanix/mbe-api/issues/199) (§III repo-boundary rule — no
direct mbe-api edit from this session); every other change reuses already-documented mbe-api
endpoints exactly as they exist today, with no new/changed request or response shape.

**Scale/Scope**: 5 feature areas (catalog, POS capture, POS delivery, back-office sales orders,
pricing), 9 user stories, 30 functional requirements, 2 new `AppSettings` fields, 1 new shared
predicate (`isGenericCustomer`), 2 filed mbe-api issues.

## Constitution Check

*GATE: evaluated against `.specify/memory/constitution.md` v1.13.0.*

| Principle | Verdict | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | **PASS** | The one cross-cutting addition (`isGenericCustomer`) lives in `core/config`, shared correctly; every other change stays inside its owning feature module (catalog, sales, pricing). |
| II. Riverpod for State & DI | **PASS** | Reuses `appSettingsProvider`, `orderPaymentsControllerProvider`, and extends existing `Notifier`s (`PosStepController`, `PricingGridController`) rather than introducing a new state primitive. |
| III. Contract-Driven API Integration | **PASS** | The two blocked Customer-field changes were filed as mbe-api issues (#198, #199) rather than patched directly, exactly per this principle's repo-boundary rule. Every other change (confirm-timing, delivery auto-assign, salesperson autofill) uses endpoints and request/response shapes that already exist — no new codegen, no generated-file edit. |
| IV. Deny-by-Default RBAC | **PASS** | No new mutable action is introduced without an existing RBAC gate; every touched screen (Customers, Sales Orders, Pricing, POS capture) already gates create/update on its privilege, unchanged by this feature. |
| V. Material 3 Design System | **PASS** | The warehouse-picker stock flag uses existing tokens/iconography (§ research R11), not ad-hoc color. The two new settings are deployment-level app settings with no per-user override — this feature extends the existing app-settings/user-preference split (§V) to debounce rather than blurring it, matching how `currencyDecimalDigits` is already treated. |
| VI. Desktop/Web-First, Compact-Ready Layout | **PASS, with a follow-up to verify** | The new step-pill tap affordance (R2) needs its own compact-tier equivalent since pills render as plain text there — flagged for the design/implementation phase, not a gate failure. The stock-flag addition to the warehouse dropdown must not violate the existing row-height/baseline invariant (`sale_line_row_test.dart`, `sale_line_symmetry_test.dart`) — R11's `selectedItemBuilder` approach is chosen specifically to keep that invariant intact. |
| VII. Online-Only, Server-Rendered Documents | **N/A** | No document/PDF surface touched. |

No gate fails outright, so **Complexity Tracking carries no entries**. The two mbe-api
dependencies are handled the way this constitution requires (filed as issues, external-dependency
recorded in spec.md), which is compliance, not a violation needing justification.

### Deferred product decision (not a constitution gate, but blocks part of Stage 6) — RESOLVED 2026-09-04

Research R3 recommends merging the POS resume-selector's "Borrador" and "Sin pagar" buckets, a
direct consequence of R1 (a captured-but-unpaid sale is now indistinguishable from a draft in
progress). This is a user-visible change to a screen cashiers use constantly and had **not** been
confirmed with the requester (unlike the debounce-settings and mid-sale-switch decisions, which
were) — **sign-off given 2026-09-04, and the merge is implemented** (T016). It did not block
Stages 1-5 below; it blocked only the resume-selector relabeling inside
Stage 6.

## Project Structure

### Documentation (this feature)

```text
specs/036-live-testing-fixes/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — R1..R14
├── data-model.md         # Phase 1 output — entity/state/config changes
├── quickstart.md         # Phase 1 output — validation guide
├── contracts/
│   ├── pos-sale-lifecycle.md            # C1..C3 — confirm() timing, back-nav, resume buckets
│   ├── sales-order-customer-flow.md     # C1..C4 — customer-first, exclusion, autofill
│   ├── pricing-grid-commit.md            # C1..C3 — commit-before-switch
│   ├── customer-form-and-fulfillment.md # C1..C4 — form fields, shared predicate, gating
│   └── app-settings-additions.md         # C1..C3 — two new settings, currency-gap closure
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── config/
│   │   ├── app_settings.dart              # +inputDebounce, +quantityCommitDebounce,
│   │   │                                   #  +isGenericCustomer (R6, R8, R13)
│   │   └── app_settings_provider.dart      # +inputDebounceProvider,
│   │                                       #  +quantityCommitDebounceProvider
│   └── widgets/
│       └── catalog_entity_picker.dart      # → ConsumerStatefulWidget, reads
│                                            #  inputDebounceProvider (R13)
└── features/
    ├── catalog/
    │   ├── presentation/
    │   │   ├── customer_form.dart              # field reorder, remove shipping switches
    │   │   └── customer_form_controller.dart   # code optional, drop shipping state
    │   ├── domain/
    │   │   ├── entities/customer.dart          # drop shipping/shippingRequiredDocument
    │   │   └── repositories/customer_repository.dart
    │   └── data/customer_repository_impl.dart  # omit blank code on update; drop shipping
    │                                            #  payload fields
    ├── sales/
    │   ├── presentation/
    │   │   ├── pos_step_controller.dart        # +returnToVenta, +canReturnToCapture (R2)
    │   │   ├── sale_editing.dart                # confirm() call site removed from here
    │   │   ├── payment/payment_controller.dart  # confirm() called before createPayment (R1)
    │   │   ├── delivery/delivery_controller.dart# confirm() before first create; auto-assign
    │   │   │                                    #  first destination (R1, R12)
    │   │   ├── capture/customer_bar.dart        # excludeGenericCustomer, salesperson
    │   │   │                                    #  autofill, mid-sale demote (R6, R7, R8)
    │   │   ├── capture/fulfillment_mode_selector.dart # gate on isGenericCustomer (R8)
    │   │   ├── capture/sale_line_editing.dart   # 3-state warehouse stock flag (R11)
    │   │   ├── customer_inline_create.dart      # drop shipping switches
    │   │   ├── orders/order_screen.dart         # customer-first gate (R5)
    │   │   ├── orders/order_header_panel.dart   # salesperson initialDisplayText fix (R7)
    │   │   ├── open_sales_selector.dart          # bucket merge — implemented (R3)
    │   │   ├── open_sales_selector_controller.dart
    │   │   └── pos_workspace_screen.dart        # tappable step pill (R2)
    │   └── domain/repositories/sales_order_repository.dart # optional open(customer:,
    │                                                          #  salesperson:) (R5)
    └── pricing/
        └── presentation/
            ├── pricing_grid_controller.dart    # +activeDraft, commit-before-switch (R9)
            ├── price_cell.dart                  # seed/commit via AppFormatters.field.price (R10)
            └── pricing_screen.dart              # same fix, single-product dialog (R10)

test/
├── unit/features/{sales,catalog,pricing}/   # controller-level cases per research R1-R14
├── widget/features/{sales,catalog,pricing}/ # screen-level cases; several existing tests updated
├── golden/, test/screenshots/                # regenerated after visual changes reviewed
└── integration/                              # POS/order flow tests updated for new call ordering

.env.template          # +INPUT_DEBOUNCE_MS, +QUANTITY_COMMIT_DEBOUNCE_MS
```

**Structure Decision**: Unchanged feature-first layout. The one new cross-cutting piece
(`isGenericCustomer`) is deliberately small and lives in `core/config` beside the setting it
reads, exactly where `posDefaultCustomerId` already lives conceptually — no new shared-widgets
module or service layer is introduced for it.

## Implementation Sequencing

Ordered so the contained, low-risk fixes land first and the one large, connected change (the
`confirm()`-timing move) ships last, after its shared building block already exists and is
proven.

1. **Pricing grid commit fix + currency decimal audit** (US3, US8 — FR-009, FR-010, FR-026,
   FR-027). Fully isolated to `pricing/`. Highest-severity bug (silent data loss), smallest blast
   radius, no dependency on anything else here.
2. **Shared generic-customer predicate + Customer form changes + fulfillment-mode gating** (US4,
   FR-011..FR-016). Builds `isGenericCustomer` (needed by Stage 5) alongside the form-field work
   it's naturally paired with. Client-side pieces proceed regardless of mbe-api#198/#199 timing;
   wire-level `code` omission on create waits for regeneration.
3. **Warehouse stock visibility + delivery auto-assignment** (US6, US7 — FR-020..FR-025).
   Isolated to `sales/capture` and `sales/delivery`; independent of every other stage.
4. **Debounce settings** (US9 — FR-028..FR-030). Pure infrastructure addition; independent of
   every other stage, can land in parallel with 1-3.
5. **Sales Order customer-first + salesperson autofill** (US1, US5 — FR-001..FR-004, FR-017..
   FR-019). Depends on Stage 2's shared predicate for the generic-customer exclusion.
6. **POS edit-before-payment** (US2 — FR-005..FR-008 only; FR-016's mid-sale fulfillment demotion
   was already completed in Stage 2 and is not re-scoped here — it is mentioned only because it
   shares this stage's "customer/mode consistency" theme). The `confirm()`-timing move touches
   Payment, Delivery and credit-terms leave-Cobro paths together and is the one item requiring a
   genuinely new interaction pattern (back-navigation). Ships last, after Stages 1-5 have proven
   the smaller pieces stable. **The resume-selector bucket relabeling (R3) needed requester
   sign-off before its part of this stage shipped** — given 2026-09-04, implemented (T016) — the
   `confirm()`-timing move and back-navigation never depended on that sign-off.

## Risks

| Risk | Why it matters | Mitigation |
|---|---|---|
| Stock reservation now happens at confirm-just-before-payment instead of at capture | Two registers can race for the same stock during Cobro/Entrega, a window that didn't exist before | No code mitigation — flagged as an operational trade-off of the only mbe-api-change-free way to satisfy FR-008; revisit if it proves to matter in practice |
| `confirm()` failures (empty order / stock shortfall) now surface at payment or delivery time | Must be routed back to Venta's existing error rendering, not treated as a payment/delivery failure, or the error message will be wrong | Explicit contract requirement (`pos-sale-lifecycle.md` C1); test each of the three trigger points explicitly |
| "Sin pagar" resume bucket loses its meaning post-fix | A user-visible relabeling on a screen used constantly | **Resolved 2026-09-04**: sign-off given, bucket merged into "Borrador" (T016) |
| `posDefaultCustomerId` is a documented, drift-prone build-time constant | Was cosmetic before; under FR-015/FR-016 a stale value becomes a functional mis-gate (wrong customer blocked/allowed from shipping) | Not fixed by this feature — recorded as a known, now higher-stakes, existing issue |
| **Confirmed** (T046 live spike): product-lookup's `warehouse:` param filters `stock` to one warehouse | Every warehouse other than the one last looked up always shows "unknown" in the picker — the flag is still correct (never falsely "in stock"), but its practical coverage is narrower than the spec's intent | Not fixed by this feature — a per-warehouse stock fetch would be needed to close the gap; recorded as a known limitation for a future feature |
| The pricing-grid fix lifts commit ownership into the controller rather than patching the widget | Larger diff than the minimal patch; risk of regressing existing keyboard-traversal tests if the commit-before-switch call is wired incorrectly | `pricing-grid-commit.md` C1-C3 spell out the exact guarantee; existing `price_cell_test.dart` cases (Enter/Tab/Escape) must keep passing unchanged, with new cases added alongside |
| mbe-api#198/#199 may not land same-day as filed | Blocks only the wire-level halves (omitting `code` on create, dropping the shipping fields from generated DTOs) | research R14 already splits doable-now from regeneration-gated work; nothing in Stages 1-6 is blocked entirely on these landing |

## Complexity Tracking

> No constitution gate failed without resolution. The two mbe-api-dependent changes are handled
> exactly as §III requires (issues filed, external dependency recorded), which this constitution
> treats as compliance, not a deviation needing justification.
