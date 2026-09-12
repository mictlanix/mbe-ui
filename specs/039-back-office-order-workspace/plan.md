# Implementation Plan: Back-Office Order Workspace — Customer, Capture, Delivery

**Branch**: `039-back-office-order-workspace` | **Date**: 2026-09-11 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/039-back-office-order-workspace/spec.md`

## Summary

Replace the single-screen back-office order editor with a three-step workspace —
**Cliente → Venta → Entrega** — that renders the *actual* point-of-sale
`CaptureStep` and `DeliveryStep` widgets rather than copies of them.

The technical core is not the new screen; it is finishing a seam that already
exists. `saleEditorProvider` and `saleWritesScopeProvider`
(`lib/features/sales/presentation/sale_editor.dart`) already let a shared
capture widget serve two hosts, and the existing order screen already installs
them through a nested `ProviderScope`. But eleven call sites across the capture
and delivery surfaces still reach the register's own singletons directly, so
only the *leaf* widgets are genuinely shared today. This feature routes those
eleven through the seam, adds one more indirection for the confirm helper, and
then the two step widgets can simply be rendered by a second host.

The new screen is the cheap part. The risk is concentrated entirely in making
the shared surfaces host-agnostic without any register-visible change.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (codegen),
`go_router`, `freezed`, `dio` via the generated `mbe_api_client`
(`lib/generated/openapi`), `flutter_localizations` + `intl`

**Storage**: None client-side (constitution VII — online only). All state is
mbe-api's.

**Testing**: `flutter_test` (unit + widget), `integration_test`, golden tests via
the existing `test/golden` harness

**Target Platform**: Web and desktop first, compact (phone) tier supported —
constitution VI

**Project Type**: Single Flutter application; feature-first layering under
`lib/features/sales/`

**Performance Goals**: No new budget. The workspace must not add a server round
trip to any step transition; step reconstruction on resume must be derivable
without an extra fetch (see research R2).

**Constraints**:
- Point-of-sale behaviour must be observably unchanged (FR-046, SC-007).
- No mbe-api source may be edited from this repo (constitution, Development
  Workflow). Server gaps are filed as issues and recorded as dependencies.

**Scale/Scope**: One workspace screen, one step controller, ~11 call-site
migrations across 6 existing files, 4 files deleted or rewritten, ~16 existing
test files affected. The "Pedidos" list is explicitly untouched (spec OS-2).

**External dependencies (blocking, filed per constitution §Development Workflow)**:

| Issue | What it blocks | Status |
|---|---|---|
| [mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209) — `sales_order` records no origin | FR-051 – FR-054, SC-010 – SC-012, and User Story 5 entirely | Open. Needs the field **and** its backfill policy decided. |
| [mbe-api#210](https://github.com/mictlanix/mbe-api/issues/210) — expiry sweep cancels scheduled orders | Nothing at build time; breaks the feature at run time if the sweep is scheduled (spec A13) | Open. **Verify against the target deployment before release.** |
| [mbe-api#211](https://github.com/mictlanix/mbe-api/issues/211) — delivery gated on payment | Nothing if left at its default (`false`); blocks every non-credit order if enabled (spec A14) | Open. Deployment check only. |

Only #209 blocks code. Research R5 sets out how the other work proceeds without
it and what the interim behaviour is.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1.*

| Principle | Verdict | Notes |
|---|---|---|
| **I. Feature-first layered architecture** | PASS | Everything lands under `lib/features/sales/`. `presentation` continues to depend only on `domain`. No new entity is redefined — `Sale`, `Destination`, `Customer` are reused as-is. |
| **II. Riverpod for state & DI** | PASS | The seam *is* Riverpod: plain (non-family) providers overridden in a nested `ProviderScope`. The new step machine is a `Notifier` holding UI-only state, matching `PosStepController`. No new DI mechanism. |
| **III. Contract-driven API integration** | PASS with a recorded dependency | No hand-written DTO is added. When #209 lands, this feature MUST re-run codegen and extend the `Sale` mapping — recorded as a task, per the constitution's rule that an mbe-api change relevant to a feature entails regenerating and updating the domain mapping. |
| **IV. Deny-by-default RBAC** | PASS | Unchanged: `SystemObject.salesOrders` gates the route and the actions, deliberately *not* `pos` (FR-047). |
| **V. Material 3, white-labeled design system** | PASS | The workspace composes existing themed components and reads spacing from `Theme.of(context).spacing`. No new hard-coded colours, sizes or formatting paths. |
| **VI. Desktop/web-first, compact-ready** | PASS | Both reused steps already implement their own compact tier; the new step indicator and the Cliente step must do the same. Covered by a dedicated compact widget test. |
| **VII. Online-only, server-rendered documents** | PASS | No caching or offline behaviour. No document output is added (spec OS-4). |
| **Quality gates** (unit / widget / integration) | PASS | Three layers planned: unit for step reconstruction, widget for each step and the host-isolation guard, integration for the end-to-end flow. |

**No violations. Complexity Tracking is therefore omitted.**

One point deserves explicit note rather than a silent pass. Making the shared
surfaces host-agnostic touches point-of-sale files, which could read as scope
creep against "surgical changes". It is not: every one of those edits is
*required* by FR-041 – FR-045, each replaces a hard-coded singleton with the
seam that already exists for exactly this purpose, and none changes
register-visible behaviour. The blast radius is enumerated in research R1 and
pinned by SC-007.

## Project Structure

### Documentation (this feature)

```text
specs/039-back-office-order-workspace/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── order-workspace.md      # The screen, its steps and their gates
│   └── shared-step-seam.md     # The host contract the two reused steps obey
├── checklists/
│   └── requirements.md  # Written by /speckit-specify
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source code (repository root)

```text
lib/features/sales/presentation/
├── sale_editor.dart                    # CHANGED: two more indirections
├── sale_editing.dart                   # unchanged (shared mutation bodies)
├── pos_confirm.dart                    # CHANGED: host-agnostic confirm
├── pos_sale_controller.dart            # unchanged (the register's host)
├── pos_step_controller.dart            # unchanged (POS vocabulary stays POS)
├── pos_workspace_screen.dart           # CHANGED: supplies its own step wiring
├── capture/
│   ├── capture_step.dart               # CHANGED: host-supplied action + scope
│   ├── fulfillment_mode_selector.dart  # CHANGED: onto the seam
│   ├── customer_bar.dart               # CHANGED: one singleton read
│   └── …leaf widgets                   # unchanged
├── delivery/
│   ├── delivery_step.dart              # CHANGED: scope from the seam
│   ├── delivery_controller.dart        # CHANGED: scope + confirm from the seam
│   └── line_distribution_panel.dart    # CHANGED: close-button label parameter
└── orders/
    ├── order_workspace_screen.dart     # NEW: the three-step host
    ├── order_step_controller.dart      # NEW: Cliente/Venta/Entrega + resume
    ├── customer_step.dart              # NEW: the Cliente step
    ├── order_editor_controller.dart    # KEPT, extended (origin + intent)
    ├── order_header_panel.dart         # KEPT, minus ship-to and contact (FR-050)
    ├── order_screen.dart               # DELETED (replaced by the workspace)
    └── order_no_register_notice.dart   # KEPT (list-side blocked state)

lib/features/sales/presentation/
    sales_orders_list_screen.dart       # UNCHANGED (spec A1, OS-2)
```

### Post-design constitution re-check

Re-evaluated after Phase 1. **Still no violations**, with two findings from the
design worth recording:

- **III (contract-driven)** — reconfirmed. Phase 1 surfaced one client-side gap
  that is *not* a server gap: `SalesOrderRepository.open()` does not pass
  `fulfillment_intent`, though `SalesOrderCreate` accepts it. That is a
  two-line client fix requiring no codegen and no mbe-api change (research R3).
  The only codegen this feature needs is when #209 lands.
- **VI (compact-ready)** — the design adds a step indicator, which is new
  chrome that must survive the compact tier. Covered by a dedicated compact
  widget test rather than assumed (contract §6).

One scope observation, recorded rather than hidden: the test inventory showed
`sales_orders_compact_test.dart` exercises the *editor*, not the list, despite
its name. It is therefore in scope even though "the list is untouched" — a
reminder that file names are not a scope boundary.

**Structure Decision**: The feature stays entirely inside the existing
`lib/features/sales/` module and adds no new top-level directory. The new files
sit in `presentation/orders/` beside the controller and header panel they
reuse, mirroring how `pos_workspace_screen.dart` sits beside the POS step
machine. The reused steps stay where they are — in `capture/` and `delivery/` —
because moving them to a neutral folder would be a large rename that changes no
behaviour and would obscure the diff that matters.
