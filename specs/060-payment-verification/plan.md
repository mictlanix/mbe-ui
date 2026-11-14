# Implementation Plan: Payment Verification

**Branch**: `060-payment-verification` | **Date**: 2026-11-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/060-payment-verification/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#27.

Upstream: an mbe-api issue for rejection visibility must be filed before the PR (FR-016, R11). It doesn't block this feature. Every endpoint used already exists in the generated client.

## Summary

Supervisors get a company-wide "Verificación de pagos" queue of unverified payments. It starts on transfers and filters by facility, date and method. Each row has two direct icons, ✓ to verify (with an irreversibility confirmation) and ✕ to reject (with a reason). A row tap opens a read-only panel built from the row's own data. The Pagos payment view gets the same two actions.

**Technical approach:**
- **Data:** `CustomerPaymentRepository` gains `listUnverified`, `verify` and `reject`, all mapped to the existing `CustomerPayment` (R2).
- **State:** a URL-backed `PaymentVerificationFilter`. An absent `method` means Transfer, and `method=all` means no method filter, so clearing returns to the opening state (R3).
- **Writes:** a keep-alive `PaymentVerification` notifier. It returns `AppError?` and invalidates the queue, the payment and the Pagos list, as spec 059's `PaymentEditor` does (R4).
- **Row icons:** `buildCatalogRowActions` gains an optional `primaryAction` for the slot Edit usually holds, so the two-icon rule stays in `core/` (R5).
- **Panel:** `showRecordSheet`, read-only, from the row's data. This is a recorded §VI deviation (R6).
- **Errors:** one new localized code, `payment.already_verified` (R8).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed, `go_router`, `data_table_2`, and the generated `mbe_api_client`.
- No new packages, and no client regeneration.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Templates: `payments_list_screen_test.dart`, `payments_filter_test.dart`, `payment_editor_controller_test.dart`, `catalog_action_icons_test.dart`.
- One live quickstart test, `integration_test/payment_verification_quickstart_test.dart` (R10).

**Target Platform**: web and desktop first, with compact rows required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Queue | 1 page (20 rows) per filter change |
| Row panel | none |
| Verify / reject | 1 write, then the queue page refetches |

**Constraints**:
- Use `Decimal` and `formattersProvider` only.
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Format only the changed files.
- Verification can't be undone, so live write tests use fresh 1.00 payments.

**Scale/Scope**:

| | Files |
|---|---|
| **New (≈8 source)** | `presentation/payment_verification/{payment_verification_screen, payment_verification_filter, verification_queue_controller, payment_verification_controller, verify_payment_dialog, reject_payment_dialog, verification_payment_panel}.dart` and generated parts |
| **New tests** | unit: `payment_verification_filter_test`, `verification_queue_controller_test`, `payment_verification_controller_test`; widget: `payment_verification_screen_test`, `verify_payment_dialog_test`, `reject_payment_dialog_test`, `verification_payment_panel_test`; live: `integration_test/payment_verification_quickstart_test.dart` |
| **Edited (≈10 source)** | `domain/repositories/customer_payment_repository.dart`, `data/customer_payment_repository_impl.dart`, `presentation/payments/payment_detail_screen.dart`, `core/widgets/catalog_action_icons.dart`, `core/navigation/nav_destinations.dart`, `app/router/app_router.dart`, `core/errors/localize_problem.dart`, both `.arb` files, `specs/058-…/contracts/code-scope.tsv`; tests: `catalog_action_icons_test`, `customer_payment_repository_impl_test`, `payment_detail_screen_test`, `catalog_coverage_test` (104 → 105), `problem_fixtures` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything is in `features/sales/{domain,data,presentation}`. Presentation reaches data only through `customerPaymentRepositoryProvider`. |
| **II. Riverpod** | Pass | The queue is an `AsyncNotifier` family keyed by filter. Writes go through a keep-alive notifier, and the filter is URL state. |
| **III. Contract-driven API** | Pass | Only generated operations are used, mapped to `CustomerPayment`. **API error text:** of the codes the three newly called endpoints can return, only `payment.already_verified` lacks a message. It is added in both locales and flipped to `IN` in code-scope.tsv (R8). **Upstream:** the rejection-visibility change is an mbe-api issue, not a local patch (R11). |
| **IV. Deny-by-default RBAC** | Pass | The route and nav are gated on PaymentsVerification (108) read. Verify and reject need 108 update, in the queue and on the payment view, mirroring the server (R1). The route documents 108. |
| **V. Material 3 / design system** | Pass | Shared components only: `CatalogFilterBar`, `DataTableView`, `CatalogListStateView`, `ResponsiveDialog`, `FormErrorBanner`, `RecordSheet`, `ResponsiveFormGrid`. **Largest text level:** the 8-column queue is checked at the largest text size, desktop width, real fonts, in the live walkthrough (quickstart step 10). |
| **VI. List and record-surface rules** | **Deviation (justified)** | The rules that pass: filter row, list and pagination; no search box, because the endpoint has none; facets in the filter drawer; two row icons at most, with ✓ as the primary in Edit's slot through the shared helper; a row tap opens a read-only surface. **The deviation:** that surface is a second one for customer payments, beside the Pagos full screen. See Complexity Tracking. |
| **VII. Online-only** | Pass | Nothing is persisted. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R10. `flutter analyze` must be clean, and catalog coverage is enforced by `catalog_coverage_test.dart`. |

**Post-design re-check** (after Phase 1): unchanged. There are two `core/` touches:
- the `primaryAction` parameter, which is additive, with every existing caller unchanged and tested;
- `localize_problem.dart`, which the catalog rule requires.

The §VI deviation stays the only one.

## Project Structure

### Documentation (this feature)

```text
specs/060-payment-verification/
├── spec.md                # /speckit-specify + /speckit-clarify (2026-11-14)
├── wireframes.md          # /speckit-wireframes-draft
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R11)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C8)
├── checklists/
│   └── requirements.md
└── tasks.md               # /speckit-tasks (not yet)
```

### Source Code (repository root)

```text
lib/features/sales/
├── domain/repositories/customer_payment_repository.dart   # +listUnverified, +verify, +reject
├── data/customer_payment_repository_impl.dart             # same
└── presentation/
    ├── payment_verification/                              # new
    │   ├── payment_verification_screen.dart               # queue (C2)
    │   ├── payment_verification_filter.dart               # URL filter (data-model §2)
    │   ├── verification_queue_controller.dart             # page fetch
    │   ├── payment_verification_controller.dart           # verify/reject + invalidations
    │   ├── verify_payment_dialog.dart                     # C5
    │   ├── reject_payment_dialog.dart                     # C6
    │   └── verification_payment_panel.dart                # C4
    └── payments/payment_detail_screen.dart                # Verificar / Rechazar (C7)
lib/core/widgets/catalog_action_icons.dart                 # +primaryAction (C3)
lib/core/navigation/nav_destinations.dart                  # destination + NavBranch 25 (C1)
lib/app/router/app_router.dart                             # branch + gate clause (C1)
lib/core/errors/localize_problem.dart                      # payment.already_verified
lib/l10n/app_{es,en}.arb
specs/058-localized-api-errors/contracts/code-scope.tsv    # flip row to IN
test/unit/…, test/widget/…, integration_test/payment_verification_quickstart_test.dart
```

**Structure Decision**: a single Flutter app. The queue is its own presentation folder in `features/sales`, beside `payments/`, because it is a separate screen with a separate right. The payment view change stays in `payments/`.

## Dependencies and risks

- **Facilities (29) read (R7):** facility names and the facility facet call `/facilities`. A verifier without that right sees `#id` and gets no facility facet. The queue still works and still spans every facility.
- **Rejection visibility (R11, FR-012):** rejected payments look unchecked until mbe-api exposes rejections. The issue is filed before the PR.
- **Live writes are irreversible:** each `MBE_WRITE` run leaves a verified 1.00 transfer and a rejected 1.00 transfer on the dev tenant. Never verify a seeded fixture.
- **Core helper change (C3):** every list screen uses `buildCatalogRowActions`. The new parameter is optional and asserted exclusive with `onEdit`. The existing helper tests plus new cases pin the old behaviour.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI: a second record surface for customer payments (the queue's read-only `RecordSheet`, beside the Pagos full screen) | The queue spans every facility, but the Pagos screen 404s another facility's payment for a verifier without Payments Editor read. A row tap that opened Pagos would fail for many rows. The user chose a panel built from the row's own data that works for every row (clarification, 2026-11-14). | **Opening Pagos where allowed** leaves many rows inert and inconsistent. **No row tap** was the user's earlier answer, which they withdrew. **Amending §VI** was declined: this stays a one-off rather than a general rule. |
