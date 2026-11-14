# Research: Payment Verification

**Spec**: [spec.md](./spec.md) | **Date**: 2026-11-14

Every endpoint used already exists in the generated client (`CustomerPaymentsApi`). No codegen is needed.

## R1 — Rights, route and navigation

**Decision:**
- **Rights:** the queue route and its nav entry are gated on `PaymentsVerification` (108) read. Verify and reject, in the queue and on the payment view, need `PaymentsVerification` update. Customer Payments rights are not checked for the queue.
- **Route:** `/sales/payment-verification`, a new shell branch `NavBranch.paymentVerification = 25`, listed right after Pagos in Ventas.
- **Guard:** a new clause in the router's privilege gate, placed above the `/sales/payments` clause.

**Rationale:**
- **Rights:** this mirrors the server. `/unverified` depends on `_VERIFY_READ`, and verify and reject depend on `_VERIFY_UPDATE`. None of them uses `_visible_payment_or_404`, so they act on every facility.
- **Path:** the path must not sit under `/sales/payments`. `/sales/payments/verification` would be caught by the `:paymentId` route and by the `startsWith('/sales/payments')` Customer Payments gate. `'/sales/payment-verification'.startsWith('/sales/payments')` is false (`payment-` ≠ `payments`). The clause still goes first, so the order doesn't depend on that string comparison.

**Alternatives rejected:**
- A tab inside Pagos. Pagos is gated on Customer Payments and facility-scoped, while the queue is company-wide under a different right.

## R2 — Repository and entity

**Decision:** add three methods to `CustomerPaymentRepository`, and map their results to the existing `CustomerPayment` entity:

```dart
Future<CustomerPaymentListResult> listUnverified({int? facilityId, DateTime? dateFrom, DateTime? dateTo, int? methodCode, int skip = 0, int limit = 20});
Future<CustomerPayment> verify({required int customerPaymentId});
Future<CustomerPayment> reject({required int customerPaymentId, required String reason});
```

They wrap `listUnverifiedPaymentsApiV1CustomerPaymentsUnverifiedGet`, `verifyCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdVerifyPost` and `rejectCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdRejectPost`. Dates go through the same wall-clock conversion as `list` (spec 043). The amount parameters are never sent (spec clarification).

**"Folio" is `customerPaymentId`,** as in the Pagos list and payment view (spec 054). The DTO's `serial` isn't mapped. Showing a different number here than in Pagos would make the same payment look like two.

**Alternatives rejected:**
- A separate `UnverifiedPayment` entity. The response is the same `CustomerPaymentResponse`.

## R3 — Filter state and its address

**Decision:** a freezed `PaymentVerificationFilter` (facility, dateFrom, dateTo, method, pageIndex), read from and written to the URL through `ListQuery`, as Pagos does. The facets are `facility`, `date-from`, `date-to` and `method`.

**The method facet:**

| Address | Meaning |
|---|---|
| `method` absent | Transfer (`PaymentMethod.eft`, code 3) |
| `method=all` | no method filter |
| `method=<code>` | that code |

**What follows from that:**
- "Limpiar todo" and "Quitar filtros" both go to the bare path, which is the opening state (clarification Q3).
- `activeFilterCount` counts the method whenever it isn't `all`, so the badge reads ① on open.
- `differsFromDefault` decides whether the empty state offers "Quitar filtros". It is true when the method isn't Transfer, or a facility or date is set.

**Alternatives rejected:**
- Putting `method=3` in the default URL. A bookmark would then freeze the default, and "clear" would need a non-empty target.

## R4 — Writes, refresh and refusals

**Decision:** a keep-alive `PaymentVerification` notifier with two methods, `verify(paymentId)` and `reject(paymentId, reason)`. Both return `AppError?`, as spec 059's `PaymentEditor` does.

After either call, success or refusal, it invalidates:
- `verificationQueueControllerProvider` (the whole family);
- `paymentDetailProvider(paymentId)`;
- `paymentsListControllerProvider`.

**Refusals:**
- **`payment.already_verified`** has its own message. The row disappears on reload.
- **`NetworkError` or a timeout** shows the "unknown result" wording (spec edge case). Nothing in the dialog claims failure.
- **A page left empty** after the last row is verified is handled by the controller's existing `fetchClampedPage`, which steps back a page.

**Alternatives rejected:**
- Removing the row optimistically. The server's total and order should stay the only source.

## R5 — Two direct row icons: extend `buildCatalogRowActions`

**Decision:** add an optional `CatalogRowAction? primaryAction` parameter.
- **Placement:** when there is no Edit, the primary action renders as the first direct icon, in Edit's slot. An assert forbids passing both `onEdit` and `primaryAction`.
- **Extras:** with a primary action present, one extra renders direct and two or more still collapse into ⋮.
- **Limit:** the row stays at two icons (§VI v1.7.0).
- **Existing callers:** they don't pass `primaryAction`, so their behaviour is unchanged. The existing `catalog_action_icons_test.dart` keeps passing, and new cases cover the parameter.

**Rationale:** this keeps the two-icon rule built once in `core/widgets/`. Building two `IconButton`s by hand in the screen would bypass the shared rule.

## R6 — Read-only panel from row data (§VI deviation)

**Decision:** a row tap calls `showRecordSheet(title: 'Pago <id>', isDirty: () => false, form: …)`.
- **Content:** a read-only `ResponsiveFormGrid` of the row's own `CustomerPayment`, with no request.
- **Names:** the facility name from `facilityDisplayNameProvider` and the employee and option names from the existing providers, each falling back as Pagos does.
- **Cash session:** plain `#id`, not a link, because the link's target has its own gate.
- **Actions:** none (clarification).

This is a second surface for an entity whose surface is the Pagos full screen. §VI is not amended (user decision, 2026-11-14), and the [plan](./plan.md) records it under Complexity Tracking.

## R7 — Facility names and the facility facet need Facilities (29) read

**Finding:** both `facilityDisplayNameProvider` and the facility picker call `/facilities`, which mbe-api gates on Facilities (29) read. A verifier may not hold it.

**Decision:**
- **Names:** fall back to `#<id>`, as the Pagos list's `_FacilityNameCell` already does.
- **Facility facet:** shown only with `can(facilities, read)`. Without that right the queue still spans every facility, but can't be narrowed to one.
- **Recording it:** noted as a dependency and risk in the plan. It isn't worth an mbe-api change for now.

**Alternatives rejected:**
- Gating the whole queue on Facilities read. That would add a right the server doesn't require.

## R8 — Localized errors

**Decision:**
- **Message:** add `apiErrorPaymentAlreadyVerified` in both `.arb` files.
- **Mapping:** add `payment.already_verified` to `localizedErrorCodes` and to `localizeProblem`.
- **Fixtures:** add a fixture to `problem_fixtures.dart`.
- **Coverage:** flip the `payment.already_verified` row of `specs/058-localized-api-errors/contracts/code-scope.tsv` to `IN`, with the routes `POST /customer-payments/{}/verify` and the note "spec 060". `catalog_coverage_test.dart`'s count rises from 104 to 105.

The other codes the three endpoints can return already have messages: `incidence.reason_required`, `resource.not_found` and `auth.forbidden`.

## R9 — Payment view actions

**Decision:**
- **Buttons:** two `OutlinedButton.icon`s in the header `Wrap` after `PaymentVerifiedChip`, shown when `payment.verifierId == null` and `can(paymentsVerification, update)`.
- **Dialogs:** the same verify and reject dialogs as the queue.

The view itself is still gated on Customer Payments read (spec 054). This feature doesn't change who can open it.

## R10 — Tests and the live walkthrough

**Unit tests:**
- the filter's URL round trip and its defaults;
- the repository methods' parameters and mapping;
- the notifier's refusal returns and invalidations;
- the helper's `primaryAction`.

**Widget tests:**
- **Queue:** columns, badge ①, icons gated by right, no icons for read only, empty state with and without "Quitar filtros", and the row tap opening the panel with no request.
- **Dialogs:** verify and reject, including disabled confirm, the 500-character limit, and the refusal and unknown banners.
- **Payment view:** the buttons.
- **Navigation:** the entry is hidden without 108 read.

**Live test:** `integration_test/payment_verification_quickstart_test.dart`, run as the admin account.
- **Read steps** are always on.
- **Write steps** run only with `--dart-define=MBE_WRITE=true`. Verification can't be undone, so each write uses a fresh 1.00 transfer, recorded as a credit payment (`PaymentType.creditPayment`, `PaymentMethod.eft`), which needs no cash session (spec 059 FR-015). One is verified from the queue, one is rejected and stays in the queue, and one is verified from the payment view. Each run leaves two verified 1.00 transfers and one rejected, still-unverified one behind.

**Text size:** the largest of the four text sizes is checked in the live walkthrough, at desktop width with real fonts (§V). The queue has 8 columns.

## R11 — Upstream dependency (FR-016)

**Decision:** file an mbe-api issue asking it to expose rejections, through either of these:
- a `rejections` read for a payment, with reason, who and when;
- a `last_rejection` summary or a `rejected` filter on `/customer-payments/unverified`.

It must be filed before the PR, but it doesn't block this feature. Until it ships, the queue makes no claim about rejection (FR-012).
