# Tasks: Sales Order Refinements — Header, Customer Bar & Navigation

**Input**: Design documents from `/specs/037-sales-order-refinements/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Not explicitly requested as TDD, but this project's own established practice (specs
035/036) is to include test tasks per story, immediately after implementation — followed here.
US2 in particular ships no test coverage otherwise for behaviour that overturns a prior spec's
explicit rule (023 FR-028/029/030), which is exactly the kind of change a passing suite should be
guarding.

**Organization**: Phases 3+ follow spec.md's priority order (P1: US1, US2; P2: US3, US4; P3: US5).
This is **not** the same order as plan.md's "Implementation Sequencing" (which groups US1+US3 as
"mechanical corrections" ahead of US2's risk and gates US4 on the mock) — both are valid; see
Implementation Strategy below for how to reconcile them. US4 additionally depends on US1 and US3
being complete, noted in its own phase.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US5, matching spec.md
- Every description carries its exact file path

---

## Phase 1: Setup

**Purpose**: Nothing to initialize — this feature edits existing, fully configured files. No new
dependency, no scaffolding, no codegen.

- [X] T001 Confirm the working tree is clean and `flutter analyze && flutter test` pass before any
      change, as the pre-change baseline for every later regression check. *(2026-09-04: analyze
      clean; test suite has one pre-existing, unrelated failure —
      `repository_list_params_audit_test.dart`, a Products repository params audit — predating
      this branch. Recorded as baseline, not touched.)*

---

## Phase 2: Foundational

**Purpose**: No primitive is shared by more than one story here — unlike spec 036, there is no
single blocking task. The one cross-story relationship (US4 depends on US1 and US3 having already
changed the fields it converts) is a **story dependency**, not a foundational one, and is recorded
in US4's phase below instead.

**Proceed directly to the user stories.**

---

## Phase 3: User Story 1 — Each fact appears once, and it is the live one (Priority: P1)

**Goal**: The order screen shows exactly one balance (the customer's, live, in the customer bar)
and exactly one payment-terms control (the customer bar's dropdown, captioned "Payment terms").

**Independent Test**: Open a saved order for a customer with an outstanding balance. Exactly one
balance is on screen, in the customer bar. Exactly one payment-terms control is on screen, in the
customer bar, captioned "Payment terms" / "Forma de pago" — on both the back-office screen and the
POS register.

### Implementation for User Story 1

- [X] T002 [US1] In `lib/features/sales/presentation/orders/order_header_panel.dart`, remove the
      balance fact from `_factStrip`'s `Wrap` (the `_fact(context, l10n.salesOrdersColumnBalance,
      fmt.display.currency(sale.balance), style: typeRoles.money)` call, ~lines 432-437). The strip
      keeps reference, status and date only (FR-001, contract `order-header-surface.md` C2).
- [X] T003 [US1] In the same file, remove the read-only payment-terms `FormGridChild` from the
      always-visible `ResponsiveFormGrid` (the block wrapping `l10n.salesOrderPaymentTermsLabel`,
      ~lines 232-239). The row now carries three fields: due date, promise date, salesperson
      (FR-003, contract C3).
- [X] T004 [US1] In `lib/features/sales/presentation/capture/customer_bar.dart`, change
      `_TermsFact`'s caption (~line 437) from `l10n.posCustomerCreditLabel` to
      `l10n.salesOrderPaymentTermsLabel`. The credit-limit supporting text beneath it is unchanged
      (FR-004, FR-005, contract C7).
- [X] T005 [P] [US1] Retire `posCustomerCreditLabel` from `lib/l10n/app_en.arb` and
      `lib/l10n/app_es.arb` — delete the key and its `@`-metadata entry from both files. Its only
      use was removed in T004 (data-model.md §5).

### Tests for User Story 1

- [X] T006 [P] [US1] In `test/widget/features/sales/order_header_disclosure_test.dart`, update the
      `'the fact strip (US1, FR-002)'` group: drop `salesOrdersColumnBalance` from the asserted
      list, and add a negative assertion —
      `find.descendant(of: find.byType(OrderHeaderPanel), matching:
      find.text(l10n.salesOrdersColumnBalance))` finds nothing, in both disclosure states.
- [X] T007 [P] [US1] In the same file, replace the unscoped
      `expect(find.text(l10n.salesOrderPaymentTermsLabel), findsOneWidget)` (~line 153, in the
      `'the disclosure'` group) with a scoped negative assertion — the string now legitimately
      appears in `CustomerBar`, so an unscoped finder proves nothing (research R9).
- [X] T008 [P] [US1] In `test/widget/features/sales/customer_bar_test.dart`, update the
      `'the payment-terms dropdown'` group's caption assertion to expect
      `l10n.salesOrderPaymentTermsLabel`. Confirm (do not assume) that no case in this file asserts
      `posCustomerCreditLabel` directly — research R9 found none, but this file is exactly where
      one would live if it existed.
- [X] T009 [US1] Re-baseline `test/golden/pos_capture_golden_test.dart`'s four
      `pos_customer_bar_{light,dark}_{narrow,wide}.png` files and
      `test/screenshots/pos_screens_screenshot_test.dart` shots `02`–`07` via
      `flutter test --update-goldens`. Review every changed PNG before committing — no golden
      outside this set should move (research R9); if one does, stop and find out why rather than
      accepting it.

**Checkpoint**: US1 is independently shippable and testable.

---

## Phase 4: User Story 2 — A credit customer's order opens on credit terms (Priority: P1)

**Goal**: Attaching a customer with a non-zero credit line leaves the order on credit terms with no
further action, on both POS and the back-office screen — without ever letting that default block
the customer from attaching.

**Independent Test**: Attach a credit-line customer to a new order. Without further action, the
order is on credit terms and stays there after reload. Attach a zero-limit customer to an order
that was on credit terms — it falls back to immediate.

**⚠️ Read `contracts/payment-terms-default.md` before starting** — the three routes (C2.1/C2.2/C2.3)
are not interchangeable, and the wrong one silently regresses a path that already works today.

### Implementation for User Story 2

- [X] T010 [US2] In `lib/features/sales/presentation/capture/customer_bar.dart`, add a small pure
      predicate — `bool _hasCreditLine(CustomerListItem c) => !isZeroAmount(c.creditLimit)` — next
      to the existing `_terms` getter, reusing `isZeroAmount` from `features/sales/domain/money.dart`
      (data-model.md §2, research R2).
- [X] T011 [US2] In the same file, change `_SearchingView`'s `onSelected` wiring (currently
      `_updateHeader(customer: customer.customerId, salesperson: customer.salesperson?.id)`,
      ~lines 243-246) to branch on `widget.sale` and T010's predicate, implementing contract
      `payment-terms-default.md` **exactly**:
      - `widget.sale == null` → call `_updateHeader(customer:, salesperson:)` **unchanged, with no
        `paymentTerms`** — this preserves the spec-036 fast path (`sale_editing.dart:93-108`) that
        lets the server derive terms on order creation (C2.1). **Do not add `paymentTerms` here** —
        doing so disables the fast path and turns one request into two, for no gain (research R1).
      - `widget.sale != null && !_hasCreditLine(customer)` → one call,
        `_updateHeader(customer:, salesperson:, paymentTerms: PaymentTerms.immediate)` (C2.2). This
        is what makes FR-007 true — the server never revisits terms on its own.
      - `widget.sale != null && _hasCreditLine(customer)` → the attach call **unchanged, still with
        no `paymentTerms`**, awaited; then a **separate** follow-up write of
        `paymentTerms: PaymentTerms.netD`, whose failure MUST NOT surface as an error banner and
        MUST NOT be attributed to the customer attach, which already succeeded (C2.3/C3, FR-010a).
        The existing `_updateHeader` sets `_error` on any `AppError`, so the follow-up write needs
        its own path that swallows a refusal silently (e.g. a `silent` parameter, or a second
        private method) — reusing `_updateHeader` as-is for this call would show a banner the
        contract forbids.
- [X] T012 [US2] Confirm `_busy` is `false` again once both writes in the credit branch (T011)
      settle, however either one ends — a stuck spinner would be a regression `_updateHeader`'s
      existing `finally` block does not automatically cover across two sequential calls.

### Tests for User Story 2

- [X] T013 [P] [US2] Add a widget-test group to `customer_bar_test.dart` (fake or mock
      `saleEditorProvider`, capturing call arguments — follow `pos_test_harness.dart`'s existing
      mocking pattern) covering contract C2's four rows:
      (a) no sale open, credit customer → **exactly one** call, `paymentTerms` absent;
      (b) sale open, zero-limit customer → one call carrying `paymentTerms: immediate`;
      (c) sale open, credit customer → two calls, the second carrying `paymentTerms: netD`;
      (d) sale open, credit customer, second call throws `AppError` → the customer stays attached,
      the terms end up immediate, and **no error banner renders**.
- [X] T014 [P] [US2] Row (a) above is the regression guard for the working path research R1 found —
      give it its own explicit assertion (not folded into a broader test) that the call count is
      exactly one and carries no `paymentTerms`, so a future change that "fixes" this path by adding
      terms unconditionally fails loudly.
- [X] T015 [P] [US2] Add a test (in `order_header_disclosure_test.dart` or alongside T013) asserting
      FR-008: after the user sets terms explicitly, editing the comment, currency or priority via
      `OrderHeaderPanel` sends no `paymentTerms` in those writes.

**Checkpoint**: US2 is independently shippable and testable — run quickstart.md §3's four rows
against a live tenant before moving on, including the one-request assertion on the first row.

---

## Phase 5: User Story 3 — The header reads in a deliberate order, below the customer (Priority: P2)

**Goal**: The customer bar renders above the header panel, and the disclosed fields appear in a
deliberate order: Priority, Currency, Exchange rate, Tax ID, Delivery details, Contact, Comment.

**Independent Test**: Open an order and expand the disclosure. The customer bar is above the header
panel; the disclosed fields appear in the stated order; nothing else has moved or changed.

### Implementation for User Story 3

- [X] T016 [US3] In `lib/features/sales/presentation/orders/order_header_panel.dart`, reorder the
      disclosed `ResponsiveFormGrid`'s `FormGridChild` entries (currently Priority, Contact,
      Recipient, Currency, Exchange rate, Ship-to, Comment, ~lines 267-372) to: Priority, Currency,
      Exchange rate, Recipient ("Tax ID"), Ship-to ("Delivery details"), Contact, Comment. Move the
      existing blocks — do not rewrite their contents (FR-012, contract C4).
- [X] T017 [US3] In `lib/features/sales/presentation/orders/order_screen.dart`, swap the order of
      the `OrderHeaderPanel` and `CustomerBar` `Padding` entries in the `header` list (~lines
      232-254) so `CustomerBar` renders first and `OrderHeaderPanel` second, at every breakpoint
      (FR-011, contract C1).

### Tests for User Story 3

- [X] T018 [P] [US3] In `order_header_disclosure_test.dart`, update the disclosure group to assert
      field **order** by position (e.g. comparing `tester.getTopLeft(...).dy` across the seven
      fields), not merely presence — matching T016's order exactly.
- [X] T019 [P] [US3] Add a case (in `order_header_disclosure_test.dart` or `order_screen_test.dart`)
      asserting `tester.getTopLeft(find.byType(CustomerBar)).dy <
      tester.getTopLeft(find.byType(OrderHeaderPanel)).dy`.
- [X] T020 [US3] Re-run `test/widget/features/sales/sales_orders_compact_test.dart`'s scroll-to-find
      loop for `SaleLineCard`/the keyed disclosed fields now that `OrderHeaderPanel` follows
      `CustomerBar` in the compact `ListView` — adjust the scroll amount only if it now fails to
      locate them (research R9).

**Checkpoint**: US3 is independently shippable and testable.

---

## Phase 6: User Story 4 — The header wastes less vertical space (Priority: P2)

**⚠️ Depends on US1 (Phase 3) and US3 (Phase 5) being complete** — converting a field that is about
to be deleted or relocated wastes the conversion. **Also depends on FR-015's mock being produced and
approved before any task after T021.**

**Goal**: Every field in the header panel but the comment adopts a compact, caption-over-control
presentation, making the expanded panel measurably shorter with no field lost or made less usable.

**Independent Test**: With the mock approved, compare the expanded panel against its pre-feature
self at the same width and text scale — materially shorter, every field still readable, gated and
writing exactly as before.

### Mock (gates everything below)

- [X] T021 [US4] Produce a design canvas covering the header stack — collapsed and expanded, at the
      expanded and compact tiers — reflecting the US1/US3 changes already made, styled from the
      local `ds-bundle/` tokens so it reads as this application. Present it to the user for
      approval (FR-015, research R11). **Do not start T022 onward until approved.** *(2026-09-04:
      mock published at https://claude.ai/code/artifact/05f23e1a-8700-4160-8e29-e6b5e998ab6c —
      4 artboards (expanded/compact × collapsed/expanded), styled from ds-bundle/_ds_bundle.css's
      light-theme tokens (DesignSync unavailable in this headless session; spec 032's reference
      artboard could not be pulled).)*
      *(2026-09-05: **approved by the requester**, after review revisions — due date, promise date
      and salesperson moved onto the first header row; the six disclosed fields shown one-up;
      one caption rule and one value rule throughout (no uppercase); mono narrowed to the order
      reference; and the picker chevron dropped from the two date fields only, where it was
      pushing the datetime value into an ellipsis. Archived at `artifacts/sales_order_header/`
      per the `artifacts/<feature>/` convention — filenames there are lowercase and single-dot at
      the requester's instruction, so the artboards must be renamed back to `<name>.dc.html`
      before they can be re-seeded. **T022 onward is unblocked, but the approved design departs
      from this spec's own contracts in four places — see the note below.**)*

### Implementation for User Story 4

> **The approved mock supersedes parts of this feature's own contracts.** Before T022 onward is
> implemented, `spec.md` and `contracts/order-header-surface.md` need updating to match what was
> actually approved, in four places:
>
> 1. **C2/C3** — the fact strip absorbs due date, promise date and salesperson, so the strip is no
>    longer "read-only facts only" and there is no separate always-visible row.
> 2. **C5** — the disclosed group is six-across on one line. `ResponsiveFormGrid` caps at
>    `maxColumns = 3` today, so this needs that cap raised (for this panel, or at the large tier
>    generally) — a change to a shared component every form renders through.
> 3. **C2** — captions are sentence case, not uppercase; one caption rule and one value rule for
>    every field.
> 4. **C2** — monospace narrows to the order reference; the strip date is no longer mono.
>
> Item 2 is the only one with blast radius beyond this panel.

- [X] T022 [US4] Create `lib/core/widgets/compact_field.dart`: a `CompactField` widget per
      data-model.md §4 — `label` (through `typeRoles.metricLabel`, not raw `labelSmall`), `child`,
      optional `supportingText`, `enabled`; **no fixed width**; symmetric vertical padding from
      `core/design/spacing.dart` tokens only; height driven by content (contract C5, constitution
      §VI).
- [X] T023 [US4] In `order_header_panel.dart`, convert every field except Comment — due date,
      promise date, salesperson, priority, currency, exchange rate, recipient, contact, ship-to —
      from `InputDecorator`/`DropdownButtonFormField`/`_PickerField` to `CompactField`, per the
      approved mock. Dropdowns inside it use `isExpanded: true`; none gets a fixed width (FR-016,
      FR-016a, research R5/R7). The comment field keeps its existing `ConfirmableTextField`
      presentation, unconverted.
      **`CompactField` MUST wrap the existing control, not replace it**: the widget carrying each
      field's `Key` stays the same type it is today (`DropdownButtonFormField<Currency>`,
      `DropdownButtonFormField<Priority>`, `CatalogEntityPicker<EmployeeListItem>`, …), with
      `CompactField` supplying only the caption, supporting text and spacing around it.
      `test/widget/features/sales/order_screen_readonly_test.dart` type-casts exactly those three
      widgets by `Key` to assert FR-017's edit gating (research R9a); replacing the control type
      breaks those casts and silently removes the only gating coverage this panel has.
- [X] T024 [US4] In `customer_bar.dart`, convert `_TermsFact` to use T022's `CompactField`, removing
      its hand-rolled `Column` + `SizedBox(width: 132)` and the raw `labelSmall` token bypass. Rely
      on `CompactField`'s fill-cell + `isExpanded: true` behaviour instead of a fixed width
      (research R7) — the 132 px workaround does not survive into a grid cell that can be narrower.

### Tests for User Story 4

- [X] T025 [P] [US4] Add `test/widget/features/sales/order_header_density_test.dart`: measure the
      expanded panel's height against a recorded pre-feature baseline and assert at least a 20%
      reduction (SC-004); assert symmetric vertical padding and a caption/control baseline
      relationship, measured against the real app theme — not a bare `MaterialApp` (research R4,
      constitution §VI's measuring-test rule; spec 027's T031 is the cautionary precedent for
      getting this wrong).
- [X] T026 [US4] Extend `test/widget/features/sales/sales_orders_compact_test.dart` into a loop over
      all four `TextSizeLevel` factors (0.9 / 1.0 / 1.15 / 1.3), asserting no overflow or clipping at
      both the compact and expanded tiers — mirroring the `group('at text-scale factor $level')`
      pattern already established in `test/widget/features/sales/sale_line_symmetry_test.dart`
      (research R8, constitution §V's largest-text-size requirement).
- [X] T027 [US4] Re-verify `customer_bar_test.dart`'s 390 px-width case (the existing `Wrap`
      re-wrap scenario referenced in contract C7) still passes with the wider "Forma de pago"
      caption and the `CompactField` conversion.
- [X] T034 [US4] *(added post-`/speckit-analyze`, closes the FR-017 coverage gap)* Re-run
      `test/widget/features/sales/order_screen_readonly_test.dart` after T023/T024 and confirm its
      four typed assertions still hold: `DropdownButtonFormField<Currency>.onChanged` is null for a
      non-editable order (~line 143), `CatalogEntityPicker<EmployeeListItem>.enabled` is false
      (~line 148), and `DropdownButtonFormField<Priority>.onChanged` is non-null for an updater but
      null for a reader (~lines 169, 188). This file is the **only** gating coverage
      `OrderHeaderPanel` has — `order_header_disclosure_test.dart` tests disclosure mechanics and
      field presence, never `canEdit`. If T023 was implemented as specified (wrap, don't replace)
      this task is a no-op verification; if the casts throw, fix the widget structure rather than
      loosening the test, since the cast is what pins FR-017.

**Checkpoint**: US4 is independently shippable and testable, and was gated correctly — no
implementation task ran ahead of mock approval.

---

## Phase 7: User Story 5 — Sales Orders sits after Point of Sale in the menu (Priority: P3)

**Goal**: The Sales Orders destination appears immediately after Point of Sale in the Sales nav
group, for every user who can see either.

**Independent Test**: Sign in as a user with access to both. Sales Orders appears immediately after
Point of Sale. Sign in as a user with Sales Orders access only — it is still visible.

### Implementation for User Story 5

- [X] T028 [US5] In `lib/core/navigation/nav_destinations.dart`, move the `'sales-orders'`
      `NavDestination` block (~lines 264-272) to immediately after the `'pos'` `NavDestination`
      block (~lines 273-281) within the Sales `NavGroup`'s `children`. `NavBranch.salesOrders` and
      `NavBranch.pos` stay untouched — display order comes from tree position, not branch index
      (FR-020, FR-021).
- [X] T029 [US5] Rewrite the comment at ~lines 260-263 (which currently justifies placing Sales
      Orders *before* Point of Sale) to record the new rationale instead of arguing for the
      placement the code no longer has (research R10).

### Tests for User Story 5

- [X] T030 [P] [US5] In `test/unit/app/router/app_router_test.dart`, reusing its existing
      `_flattenDestinations` helper, add an assertion that the flattened Sales-group order has
      `'pos'` immediately followed by `'sales-orders'` — nothing asserts nav order today, so this is
      new coverage, not an update (research R10).

**Checkpoint**: US5 is independently shippable and testable.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T031 Run `quickstart.md`'s full manual validation (all five sections) against a live mbe-api
      tenant with a credit-line customer who has **no** overdue orders and a zero-limit customer —
      per quickstart's Prerequisites, the wrong tenant state validates the refusal path instead of
      the happy path.
- [X] T032 Run `flutter analyze && flutter test` for the full suite and confirm **only** the goldens
      and screenshots named in T009 changed — any other golden moving means something in this
      feature has a visible effect it should not have (research R9). *(2026-09-04: analyze clean;
      full suite 2565/2566 passing, the one failure being the pre-existing, unrelated baseline
      failure recorded in T001. Exactly 4 goldens
      (`pos_customer_bar_{light,dark}_{narrow,wide}.png`) and 5 screenshots (`02`, `03`, `04`, `05`,
      `07`) re-baselined — nothing outside that set moved.)*
- [ ] T033 [P] File the two discovered-but-out-of-scope issues from research.md's closing section as
      tracked follow-ups (do not fix them on this branch): string-detail 422 messages being silently
      discarded by the error-mapping layer, and mbe-api refusing to create an order for a credit
      customer with overdue orders. The second needs an mbe-api issue per constitution §III, not a
      client-side change.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: empty — nothing blocks more than one story here.
- **US1, US2, US3, US5**: each depends only on Setup, and are mutually independent — any order, or
  in parallel.
- **US4 (Phase 6)**: depends on **US1 and US3 being complete** (T002-T009, T016-T020), plus the
  mock (T021) being approved before T022 onward.
- **Polish (Phase 8)**: depends on every story you intend to ship being complete.

### Within Each User Story

- Implementation before its own tests, except where a test is itself the regression guard for an
  existing behaviour (T014).
- US4's mock (T021) is a hard gate — do not begin T022 until it is approved.

### Parallel Opportunities

- US1, US2, US3, US5 can be staffed in parallel — they touch overlapping files
  (`order_header_panel.dart`, `customer_bar.dart`) but disjoint regions of them; coordinate merges
  rather than serializing the work.
- Within a story, every `[P]`-marked task can run in parallel with its siblings.
- US4 cannot start its implementation tasks until US1 and US3 land and the mock is approved, but its
  mock (T021) can be drafted in parallel with US1/US2/US3/US5's implementation.

---

## Parallel Example: User Story 1

```bash
# T002 and T003 touch the same file (order_header_panel.dart) in different regions — sequence them.
# T004 and T005 can run alongside T002/T003:
Task: "Change _TermsFact's caption in customer_bar.dart (T004)"
Task: "Retire posCustomerCreditLabel from both .arb files (T005)"

# Tests, once implementation lands:
Task: "Update the fact-strip test group (T006)"
Task: "Scope the payment-terms finder (T007)"
Task: "Update customer_bar_test.dart's caption assertion (T008)"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1 (T001).
2. Complete Phase 3 (US1) — T002-T009.
3. **STOP and VALIDATE**: quickstart.md §1, independently.
4. This alone fixes the reported defect (duplicated, distrusted balance) and is safely shippable on
   its own.

### Recommended Order (reconciling priority order with risk)

Priority order (P1 → P2 → P3) says US1, US2, US3, US4, US5. Plan.md's risk-based sequencing instead
front-loads the six mechanical items (US1 + US3) before the one with real logic (US2), on the theory
that the simple, high-confidence changes should land — and be reviewed — before the change that
overturns a prior spec's explicit rule. Either order is valid; if working alone, consider:

1. US1 (Phase 3) — mechanical, fixes the most visible complaint.
2. US3 (Phase 5) — mechanical, unblocks US4.
3. US5 (Phase 7) — mechanical, fully independent, good to interleave whenever convenient.
4. US2 (Phase 4) — the one with real risk; contracts/payment-terms-default.md and research R1-R3
   are required reading first.
5. US4 (Phase 6) — last, because it is gated on US1, US3, and the mock.

### Incremental Delivery

Each story's Checkpoint is a real ship/demo point — none depends on another except US4's stated
dependency on US1 and US3. Deliver in whatever order suits review bandwidth; US4 simply cannot be
first.

---

## Notes

- `[P]` tasks touch different files, or different regions of the same file with no ordering
  requirement between them — verify before parallelizing within a story.
- Every task cites the contract or research finding it implements; when in doubt about *why*, read
  that section before changing the approach.
- T011 is the task most likely to be "obviously" simplified in a way that quietly breaks something —
  re-read contracts/payment-terms-default.md C2.1-C2.3 before touching it.
- Commit after each task or logical group; stop at any Checkpoint to validate a story independently.
