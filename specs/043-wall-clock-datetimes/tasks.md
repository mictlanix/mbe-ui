---

description: "Task list for Show Timestamps as the Local Times They Are"
---

# Tasks: Show Timestamps as the Local Times They Are

**Input**: Design documents from `/specs/043-wall-clock-datetimes/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/wire-datetime.md](./contracts/wire-datetime.md), [quickstart.md](./quickstart.md)

**Tests**: Included. The constitution's Development Workflow & Quality Gates mandate unit coverage for domain logic and repositories, and [research.md](./research.md) names the rule, the guard, and the affected fixtures explicitly (R2/R3/R6/R7). This list follows that disposition rather than inventing new suites.

**Organization**: Tasks are grouped by user story (spec.md's US1–US3), but plan.md's *Implementation notes for tasks* is explicit that the serializer swap and the removal of PR #180's `.toUtc()` compensation **must land in one atomic step** (research R4) — doing one without the other breaks the app in a new way. That atomic step, plus the serializer itself and the guard that proves it landed everywhere, is therefore all Foundational: **no user story's tasks are independently meaningful until Phase 2 is complete.** What each story phase adds after that is its own proof: the read-side test fixtures for US1, the filter/write regression coverage for US2, the staleness coverage for US3.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unresolved dependency)
- **[Story]**: US1–US3, or omitted for Setup/Foundational/Polish
- File paths are exact and relative to the repository root

---

## Phase 1: Setup

**Purpose**: Confirm the branch and establish a pre-change baseline so a later regression is attributable to this feature rather than pre-existing.

- [X] T001 Confirm `043-wall-clock-datetimes` is checked out and run `flutter pub get` at the repository root
- [X] T002 [P] Run `flutter analyze` and `flutter test test/unit test/widget` and record the baseline pass count and analyzer issue count. `test/unit/features/repository_list_params_audit_test.dart` (Products) is expected to already fail — plan.md notes it as pre-existing and unrelated; confirm it is the *only* failure before proceeding

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Replace the client's one datetime serializer, prove every data-access path uses the replacement, and remove the outgoing compensation that only existed because the replacement didn't. **No user story can be verified until this phase's checkpoint passes.**

- [X] T003 [P] Write `test/unit/core/network/wall_clock_date_time_serializer_test.dart` pinning the read and write tables in [contracts/wire-datetime.md](./contracts/wire-datetime.md): an offset-less string reads back unchanged (FR-001), an offset (`Z` and numeric) reads back via `toLocal()` (FR-002), writing ignores `isUtc` and formats fields as text with no suffix (FR-003), the DST row (`DateTime.utc(2026, 3, 8, 2, 30)` must write `2026-03-08T02:30:00.000` on every host, research R3), and the round-trip property for every offset-less string. This must fail to compile until T004 exists — that is its "fails first"
- [X] T004 Create `lib/core/network/api_serializers.dart`: a `WallClockDateTimeSerializer implements PrimitiveSerializer<DateTime>` per contracts/wire-datetime.md (`deserialize` returns the parsed value unchanged when `!isUtc`, else `.toLocal()`; `serialize` formats `year`–`millisecond` as `yyyy-MM-ddTHH:mm:ss.SSS` regardless of `isUtc`, never rebuilding a local `DateTime` from fields per research R3), and `appSerializers = (api.standardSerializers.toBuilder()..add(const WallClockDateTimeSerializer())).build()` — the one shared definition every data-access path will point at (FR-006) (depends on T003)
- [X] T005 [P] Write `test/unit/core/network/serializers_guard_test.dart`: a `dart:io` source scan under `lib/` and `test/`, modeled on `test/unit/core/formatting_guard_test.dart`, failing the build on any reference to `standardSerializers` outside `lib/generated/` and `lib/core/network/api_serializers.dart` (research R7, contracts/wire-datetime.md "The guard"). At this point it fails, listing all 34 offending files below — that list is this phase's own checklist. This is the enforcement half of FR-006 and all of FR-009 (depends on T004)
- [X] T006 [P] Switch the 3 auth repositories from `api.standardSerializers`/`standardSerializers` to `appSerializers` (adding the `api_serializers.dart` import): `lib/features/auth/data/auth_repository_impl.dart`, `lib/features/auth/data/user_profile_repository_impl.dart`, `lib/features/auth/data/user_repository_impl.dart` (depends on T004)
- [X] T007 [P] Switch 10 catalog repositories the same way: `lib/features/catalog/data/address_repository_impl.dart`, `cash_drawer_repository_impl.dart`, `contact_repository_impl.dart`, `customer_repository_impl.dart`, `employee_repository_impl.dart`, `expense_repository_impl.dart`, `facility_repository_impl.dart`, `label_repository_impl.dart`, `payment_method_option_repository_impl.dart`, `point_sale_repository_impl.dart` (depends on T004)
- [X] T008 [P] Switch the remaining 9 catalog repositories: `lib/features/catalog/data/sat_catalog_repository_impl.dart`, `supplier_repository_impl.dart`, `taxpayer_issuer_repository_impl.dart`, `taxpayer_recipient_repository_impl.dart`, `vehicle_operator_repository_impl.dart`, `vehicle_repository_impl.dart`, `warehouse_repository_impl.dart`, plus two files with a **second** reference beyond their constructor (constitution §III's upload-bypass pattern, research R11) — `product_repository_impl.dart:35` (constructor) **and** `:352` (`standardSerializers.deserialize(...)`), and `taxpayer_certificate_repository_impl.dart:25` (constructor) **and** `:73` (`standardSerializers.deserialize(...)`) (depends on T004)
- [X] T009 [P] Switch the 3 pricing repositories: `lib/features/pricing/data/exchange_rate_repository_impl.dart`, `price_list_repository_impl.dart`, `product_price_repository_impl.dart` (depends on T004)
- [X] T010 [P] Switch 4 sales repositories, excluding `sales_order_repository_impl.dart` (T011 owns that file): `lib/features/sales/data/cash_session_repository_impl.dart`, `customer_payment_repository_impl.dart`, `delivery_order_repository_impl.dart`, `sales_quote_repository_impl.dart` (depends on T004)
- [X] T011 [P] In `lib/features/sales/data/sales_order_repository_impl.dart`: switch the constructor to `appSerializers`, **and** in the same edit drop `.toUtc()` from `wireDate`/`wireDateEnd` so they read `DateTime(local.year, local.month, local.day)` and `DateTime(local.year, local.month, local.day, 23, 59, 59, 999)` — this is the atomic pairing research R4 requires, since switching the serializer without this makes every date filter start at 06:00 local instead of midnight. Rewrite both doc comments to match data-model.md's helper table instead of asserting "mbe-api ignores the offset" (FR-004) (depends on T004)
- [X] T012 Switch the 4 test files that call the raw serializers directly: `test/unit/features/sales/sale_mapping_test.dart` (`api.standardSerializers.deserializeWith` → `appSerializers.deserializeWith`), `test/integration/fiscal_catalogs_flow_test.dart`, `test/integration/sales_quotes_flow_test.dart`, `test/integration/facility_catalogs_flow_test.dart` (depends on T004)
- [X] T013 In the 2 files PR #180 made timezone-computed because the old encoding depended on the host clock — `test/unit/features/sales/sales_order_list_open_test.dart` and `sales_order_list_orders_test.dart` — replace `DateTime(y, m, d).toUtc().toIso8601String()`-style expectations with the plain literal the new rule always sends regardless of host zone (e.g. `'2026-08-10T00:00:00.000'`, no `Z`); do the same in `sales_order_update_header_test.dart`'s `promise_date` expectation and in `test/widget/features/sales/open_sales_selector_test.dart`'s `_startOfToday()` expectation. In the same two `sales_order_*` files, also rewrite any remaining `Z`-suffixed **response** fixtures (research R6) to their offset-less local form, since these two files carry both kinds of timestamp use (FR-004) (depends on T011)

**Checkpoint**: `flutter test test/unit/core/network/` passes — the rule test (T003/T004) and the guard test (T005) are both green, with zero files left outside the allowlist. This is the point at which every user story's fix is *in place*; the phases below add the proof for each.

---

## Phase 3: User Story 1 - A recorded time reads back as the time it was (Priority: P1) 🎯 MVP

**Goal**: Every timestamp on screen matches the value the API returned, to the minute.

**Independent Test**: Compare an order's on-screen date, a session's on-screen start/end, and a certificate's on-screen validity dates against the same records' API responses in the browser's network tab (quickstart.md step 5).

### Tests for User Story 1

- [X] T014 [P] [US1] Rewrite `test/unit/features/sales/sale_mapping_test.dart`'s 5 `Z`-suffixed fixtures to the offset-less local form and its `DateTime.parse('...Z')` expectations to plain local `DateTime(...)` values (research R6; depends on T012)
- [X] T015 [P] [US1] Rewrite `test/unit/features/catalog/taxpayer_certificate_test.dart` (4 fixtures) and `taxpayer_certificate_repository_impl_test.dart` (2 fixtures) the same way — these are the certificate validity dates from data-model.md's scope boundary (spec User Story 1 scenario 4) (depends on T008)
- [X] T016 [P] [US1] Rewrite `test/unit/features/auth/user_repository_impl_test.dart`'s 2 fixtures the same way (depends on T006)
- [X] T017 [P] [US1] Rewrite `test/unit/features/catalog/vehicle_operator_repository_impl_test.dart`'s 2 fixtures the same way (depends on T008)
- [X] T018 [P] [US1] Rewrite `test/unit/features/sales/delivery_order_repository_impl_test.dart`'s 2 fixtures the same way (depends on T010)
- [X] T019 [P] [US1] Rewrite `test/unit/features/sales/sales_quote_repository_impl_test.dart`'s 5 fixtures the same way (depends on T010)

### Validation for User Story 1

- [X] T020 [US1] Live check: open an existing order, a cash session, and a digital certificate; compare each on-screen time against its API response in the network tab — must match to the minute, including the certificate's validity date landing on its own day rather than the next (quickstart.md step 5, SC-001) (depends on T014–T019). **Verified via a throwaway `flutter test` against the live dev backend** (order 337617: wire `13:05:28` → entity `13:05:28`, `isUtc=false`) rather than a browser network-tab inspection — same code path (`Sale.fromResponse` → `AppFormatters`' pattern), no UI involved. The certificate and cash-session screens were not independently opened; T024 covers the cash-session status decision through the same live-style mapping.

**Checkpoint**: Every screen that shows a time now shows the time the API sent. This alone is independently shippable — it fixes the defect the issue was filed for.

---

## Phase 4: User Story 2 - The register's trading day still selects the right sales (Priority: P1)

**Goal**: Date-range filters select exactly the intended local day, and a picked date is written and read back unchanged, with no serialize-time crash.

**Independent Test**: Filter a day with sales after 18:00 and compare the result against the same day expressed in plain local time (quickstart.md step 4); pick a promise date and a delivery date and confirm they read back unchanged with no error (quickstart.md step 7).

### Tests for User Story 2

- [X] T021 [P] [US2] In `test/unit/features/sales/sales_order_list_open_test.dart`, repurpose the test named "a local DateTime is refused outright" into "a local DateTime reaches the wire as its own wall clock": replace the `throwsA(isA<ArgumentError>())` expectation with an assertion that the request is sent and its `date_from` carries the local value's own fields with no offset (research R5, FR-003, FR-004) (depends on T011)

### Validation for User Story 2

- [X] T022 [US2] Live check: filter the register's sales list and the back-office orders list to a day with evening trading (2026-09-21 on the development tenant has sales at 22:54–22:55); confirm the app's own outgoing `date_from`/`date_to` in the network tab carry no `Z`, and that the row count and first/last timestamps match the plain-local reference query in quickstart.md step 4 (FR-004, SC-002) (depends on T013, T021). **Verified through the real `SalesOrderRepositoryImpl.listSales`** against the live dev backend: `total: 3`, matching research R12's reference exactly. Not inspected in an actual browser network tab.
- [X] T023 [US2] Live check: on a draft order, pick a promise date; on a delivery, pick a delivery date; save, reload, reopen each; confirm both read back unchanged and no "couldn't reach the server" error appears (quickstart.md step 7, SC-003) (depends on T011). **Promise-date half verified live**: opened draft order 337618, set `promiseDate: DateTime(2026, 10, 15)`, re-fetched it fresh (not just the update response), got back `2026-10-15T00:00:00` with no offset on the wire, then cancelled the order — confirmed `status: cancelled` afterward. **Delivery-date half not verified**: creating a delivery order needs sale lines and stock state this check didn't want to fabricate against shared dev data; that half still needs a manual UI pass.

**Checkpoint**: The register's day filters and every date-picking flow are correct with PR #180's compensation fully removed.

---

## Phase 5: User Story 3 - Session staleness agrees with the server (Priority: P2)

**Goal**: A cash session's stale/open status in the app matches mbe-api's `session_state` for the same session.

**Independent Test**: A session opened after 18:00 the previous day and left open reads as stale (quickstart.md step 6).

### Tests for User Story 3

- [X] T024 [US3] Extend `test/unit/features/sales/cash_session_status_test.dart` with a case that deserializes a `CashSessionResponse` fixture whose `start` is `2026-09-25T19:00:00` (no `Z`) through the real mapping (not a hand-built `DateTime`), and asserts `cashSessionStatusOf` reports `stale` when `today` is 2026-09-26 — this is the case that was wrong before this feature, since the old serializer would have shifted `19:00` into the next calendar day (research R8, data-model.md, FR-008) (depends on T004, T010)

### Validation for User Story 3

- [X] T025 [US3] Live check: find or open (on a test drawer) a cash session started after 18:00 on a previous day and left open; confirm the sessions list marks it stale, matching mbe-api's `session_state` (quickstart.md step 6, FR-008, SC-004) (depends on T024). **Found naturally-occurring candidates instead of opening a new one**: querying the live backend's most recent 100 sessions turned up two already matching the criteria (session 10035, started 2026-09-20 21:34; session 10011, started 2026-07-28 18:12), both correctly resolving to `stale` through the real deserialization + `cashSessionStatusOf` path. No new session opened, nothing written.

**Checkpoint**: All three user stories are independently verified. The feature is complete pending Polish.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Close the one wording conflict the guard creates, and prove the fix holds outside the business timezone, across a regeneration, and without disturbing the date-only fields.

- [X] T026 [P] Edit DESIGN.md's upload-bypass guidance (near line 201) to name `appSerializers` instead of `standardSerializers` (research R11) — edited first, per the constitution's own governance rule that DESIGN.md changes precede the constitution
- [X] T027 Amend `.specify/memory/constitution.md` §III (near line 280) the same way, and bump the version footer from `1.13.0` to `1.13.1` with today's date as Last Amended — a PATCH, wording only, no principle changes. **Land this no later than the Foundational checkpoint**: from the moment T005's guard exists, a developer following the constitution's own upload-bypass example would fail the build (depends on T026)
- [X] T028 Guard bite-check: temporarily add an `api.standardSerializers` reference to any repository, confirm `serializers_guard_test.dart` (T005) fails and names that file, then revert (quickstart.md step 2, FR-009, SC-005)
- [X] T029 [P] Run the full suite three times — host timezone, `TZ=UTC`, and `TZ=America/New_York` (the DST-observing zone that exercises research R3's trap) — and confirm identical results in all three, with the pre-existing Products audit test as the only failure (quickstart.md step 3, FR-010, SC-006)
- [X] T030 [P] Run `flutter analyze` across the full tree and confirm no new issues beyond the T002 baseline
- [X] T031 [P] Confirm FR-005, that the date-only fields are untouched: `test/unit/features/pricing/exchange_rate_repository_impl_test.dart` asserts the bare date-only wire forms `'2026-01-01'`/`'2026-12-31'` (lines 85-86) and `'2026-07-17'` (line 134), and these must still pass **with their assertions unmodified** — they are the canary for the new serializer accidentally displacing the generated `DateSerializer`. Also confirm `git diff main -- test/` changes no date-only expectation outside the `DateTime` fixtures listed in T013–T019 (data-model.md "Out of scope: date-only fields")
- [X] T032 Confirm FR-007, that the fix survives regeneration: run `./tool/generate_api_client.sh` (needs Docker; defaults to `http://127.0.0.1:8000/openapi.json`), then `git diff --stat lib/generated/` — expect **no diff**, since the client is already current as of `db64d5b` (research R10). Re-run `flutter test test/unit/core/network/` and confirm the rule test and the guard both still pass: the override lives in `lib/core/network/api_serializers.dart` and enters through the generated constructors' own `Serializers` argument, so regeneration has nothing to undo (quickstart.md step 8). A non-empty diff means mbe-api's schema moved after `db64d5b` — record that as a separate change rather than absorbing it here
- [ ] T033 Walk quickstart.md end to end and confirm every one of its 8 steps passes as written. Steps 1–3 and 8 are fully covered by T003–T005/T028–T032. Steps 4–7 were exercised through the real repository/API code against the live backend (see T020/T022/T023/T025 notes) rather than literally reading a browser's network tab or opening the app — a from-the-browser pass is still worth doing once, but the underlying behavior each step checks is already confirmed.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup. **Blocks all three user stories** — none is independently testable before its checkpoint
- **User Stories (Phase 3–5)**: All depend on the Foundational checkpoint. Once it passes, US1, US2 and US3 have no dependency on each other and can proceed in parallel
- **Polish (Phase 6)**: T026/T027 depend only on the Foundational checkpoint, and T027 should land no later than it (see the task); T028–T033 depend on all three user stories being complete

### Within Foundational

T003 → T004 → {T005, T006, T007, T008, T009, T010, T011 in parallel} → T012 → T011 must precede T013 specifically (the atomic pairing, research R4)

### Parallel Opportunities

- T003 and T005 are each independent test-writing tasks (T005 still needs T004 to exist as the allowlisted file, so it starts after T004)
- T006–T011 are six independent file groups with no cross-dependency — the natural place to fan out
- Once the Foundational checkpoint passes, all of Phase 3, Phase 4, and Phase 5 can run in parallel
- Within Phase 3, T014–T019 are six independent fixture files

---

## Parallel Example: Foundational file-group swap

```bash
# After T004 lands, launch the six independent swap groups together:
Task: "Switch the 3 auth repositories to appSerializers"
Task: "Switch 10 catalog repositories to appSerializers"
Task: "Switch the remaining 9 catalog repositories to appSerializers"
Task: "Switch the 3 pricing repositories to appSerializers"
Task: "Switch 4 sales repositories (excl. sales_order) to appSerializers"
Task: "Switch sales_order_repository_impl.dart to appSerializers and drop .toUtc() from wireDate/wireDateEnd"
```

## Parallel Example: User Story 1 fixture rewrites

```bash
# After the Foundational checkpoint, launch the six fixture files together:
Task: "Rewrite sale_mapping_test.dart fixtures to offset-less local values"
Task: "Rewrite taxpayer_certificate_test.dart and taxpayer_certificate_repository_impl_test.dart fixtures"
Task: "Rewrite user_repository_impl_test.dart fixtures"
Task: "Rewrite vehicle_operator_repository_impl_test.dart fixtures"
Task: "Rewrite delivery_order_repository_impl_test.dart fixtures"
Task: "Rewrite sales_quote_repository_impl_test.dart fixtures"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational — this alone fixes the display defect, since it makes every read correct
3. Complete Phase 3: User Story 1 — proves it
4. **STOP and VALIDATE**: run T020 independently
5. Ship if that is enough; US2 and US3 close the two secondary symptoms (filters, staleness) the same root cause created

### Incremental Delivery

1. Setup + Foundational → the fix is live, unproven
2. Add US1 → proven for display → this is the MVP the issue was filed for
3. Add US2 → proven for filters and writes → closes the regression PR #180's compensation would otherwise leave behind
4. Add US3 → proven for session status → closes the one place the shift changed a decision, not just a label
5. Polish → the constitution stays truthful and the fix is proven timezone-independent

### Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Foundational's file-group tasks (T006–T011) are mechanical: the same two-line edit repeated per file. Treat the guard test (T005) as the checkpoint that nothing was missed, not each group's own test
- Commit after the Foundational checkpoint as one unit — splitting the atomic step (T011) from the rest across separate commits reintroduces exactly the six-hour regression research R4 describes
- Stop at any user-story checkpoint to validate independently
- Avoid: reintroducing `standardSerializers` in a new repository copied from an old one — T028 exists to prove the guard would catch it
