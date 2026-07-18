# Specification Quality Checklist: Product Pricing

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-07-14
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- Endpoint paths appear only in the Input verbatim, the Dependencies section, and Assumptions (as external-system references), not woven into requirements — kept there deliberately so planning can trace the backing API without leaking implementation into the requirements themselves.
- RBAC gating is resolved in Assumptions from `mbe/docs/constants.md`: price-list catalog → `PriceLists` (5), product-price editing → `Pricing` (106, distinct from both the product and price-list-catalog privileges), exchange rates → `ExchangeRates` (43). Only presence of these codes in mbe-api's `UserResponse.privileges` remains a planning confirmation.
- **Revalidated 2026-07-14 after planning decisions**: US2 was rewritten from a product-form sub-panel to a standalone pricing screen (new FR-007a explicitly preserves feature 007's FR-012/FR-013 rather than superseding them), and the codegen dependency was updated to reflect that the pricing client is already generated. All items still pass.
- **Revalidated 2026-07-14 after `/speckit-analyze`**: two findings fixed. (U1) FR-018's "shared locale-aware date input" was a false claim — no such widget exists in the codebase; reworded, and the Assumptions bullet corrected to say exchange-rate date fields call Flutter's built-in `showDatePicker`/`showDateRangePicker` directly (research.md §10). (I1) FR-020 read as applying to all three pricing screens, contradicting plan.md's deliberate exemption of `/pricing` from the row-action/row-click rules; split into FR-020 (price-lists and exchange-rates only) and new FR-020a (the `/pricing` exemption, with its rationale). All items still pass.
- **Remaining `/speckit-analyze` findings resolved 2026-07-14**: (U2) research.md §4 and data-model.md now document that every Update DTO (`PriceListUpdate`, `ProductPriceUpdate`, `ExchangeRateUpdate`) uses a separately-generated `*1` wrapper class (`Price1`/`LowProfit1`/`HighProfit1`/`Rate1`/`HighProfitMargin1`/`LowProfitMargin1`) distinct from the create-side class for the same field; tasks.md T013/T026/T039/T020 updated accordingly. (I2) quickstart.md's broken `flutter test integration_test/` command corrected to the repo's actual `test/integration/` path. (G1) T022/T027 extended to cover a product deleted mid-session while the pricing screen is open. (G2) new task T005a adds dedicated unit tests for the validators/formatters, including a high-precision decimal round-trip. All 6 analysis findings are now closed; spec/plan/tasks are consistent.
- All items pass; spec is planned (see [plan.md](../plan.md)) and ready for `/speckit-tasks`.
