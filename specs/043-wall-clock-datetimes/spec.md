# Feature Specification: Show Timestamps as the Local Times They Are

**Feature Branch**: `043-wall-clock-datetimes`

**Created**: 2026-09-26

**Status**: Draft

**Input**: GitHub issue mictlanix/mbe-ui#176. Every timestamp the app reads back from mbe-api is displayed six hours ahead of the time the business recorded. A sale captured at 13:05 reads 19:05 on screen. The server half of the problem was settled in mictlanix/mbe-api#228, which pinned the API to local wall-clock time in the business timezone. PR #180 fixed the outgoing direction of this app as a stopgap. What remains is the incoming direction, which this feature covers.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A recorded time reads back as the time it was (Priority: P1)

A salesperson captures an order in the afternoon and looks at its date on screen. The time shown is the time it happened. The same holds for every other place a time appears: the order list, the order header's due and promise dates, the register's sales list, a cash session's opening and closing times, and a digital certificate's validity dates.

**Why this priority**: This is the defect. Every dated screen in the product is wrong today, by a fixed six hours, and a user comparing the screen to a printed ticket or to the legacy system sees two different answers.

**Independent Test**: Capture an order at a known local time. Compare the time on screen with the value the API returned for that order. They must be the same.

**Acceptance Scenarios**:

1. **Given** an order the API reports as `2026-09-26T13:05:28`, **When** a user opens its header, **Then** the date reads 13:05 on 26 September.
2. **Given** that same order, **When** a user finds it in the orders list, **Then** the list's date column reads the same 13:05.
3. **Given** a cash session opened at 19:30 and closed at 22:10, **When** a user opens the session, **Then** the two times read 19:30 and 22:10 on the day the session actually ran.
4. **Given** a certificate whose validity ends at 20:15 on 31 December, **When** a user views its validity, **Then** it reads 31 December, not 1 January. A time shown only as a date still moves to the next day when shifted, so this case fails even where no time is on screen.

### User Story 2 - The register's trading day still selects the right sales (Priority: P1)

A cashier opens the register's sales list and sees today's sales: all of them, including the ones made this evening, and none from yesterday. The same holds when a date range is chosen by hand, and when a delivery date is picked from a calendar.

**Why this priority**: The app currently compensates for the display problem on the way out. That compensation has to be removed as part of this change, and removing it without the rest would break every date filter by six hours in the opposite direction. This story exists so the removal is proven, not assumed. It is the highest-risk part of the work.

**Independent Test**: Filter a single day that has sales recorded after 18:00. Compare the rows returned against the same query expressed in plain local time. The two must match exactly.

**Acceptance Scenarios**:

1. **Given** a day with a sale recorded at 22:55, **When** the user filters the list to that day, **Then** the 22:55 sale is listed.
2. **Given** the previous day also had evening sales, **When** the user filters to today, **Then** none of yesterday's sales appear.
3. **Given** a user picks a delivery date from a calendar, **When** the delivery order is saved and reopened, **Then** it carries the date that was picked.
4. **Given** a user picks a promise date on an order, **When** the change is saved, **Then** the order shows that date and no error is reported.

### User Story 3 - Session staleness agrees with the server (Priority: P2)

A cash session opened yesterday evening and never closed is shown as stale, which is what the server considers it. Today's session is shown as open.

**Why this priority**: It is a correctness disagreement rather than a cosmetic one: the app and the API currently give different answers about the same session, and only for sessions opened after 18:00. It rides along with User Story 1 but deserves its own test, because it is the one place a shifted value changes a decision rather than a label.

**Independent Test**: Take a session opened after 18:00 on the previous day and confirm the app reports it stale.

**Acceptance Scenarios**:

1. **Given** a session opened yesterday at 19:00 and still open, **When** the sessions list is shown, **Then** that session reads as stale.
2. **Given** a session opened today at 09:00 and still open, **When** the sessions list is shown, **Then** that session reads as open.

## Edge Cases

- A value arrives carrying an explicit UTC offset, which the API does not send today but could in future. It must be shown as the equivalent local time, not shifted a second time.
- A value is sent back to the API, either as a filter or as a date the user picked. It must arrive as the wall-clock value the user meant.
- Fields that carry a date with no time, such as an employee's birthday or a vehicle operator's licence dates, are already correct. They must not change.
- The generated API client is rebuilt from the published schema. The fix must survive that rebuild without being reapplied by hand.
- A device whose clock is set to a timezone other than the facility's. See Assumptions.
- A test host running in a timezone other than the facility's, including one that observes daylight saving, where some wall-clock times do not exist on the night the clocks change.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A timestamp received from the API without a UTC offset MUST be displayed as that same wall-clock value, unchanged.
- **FR-002**: A timestamp received with a UTC offset MUST be displayed as the equivalent time in the viewer's local timezone.
- **FR-003**: A timestamp the app sends to the API, whether as a filter or as a value a user chose, MUST arrive as the wall-clock value the user meant.
- **FR-004**: The day-shifting compensation currently applied to outgoing dates MUST be removed as part of this change, and every date filter MUST still select exactly the intended local day.
- **FR-005**: Fields that carry a date without a time MUST keep behaving exactly as they do today.
- **FR-006**: The rule that converts between the API's timestamps and displayed times MUST live in one shared place that every data-access path uses, so no screen can hold a different opinion.
- **FR-007**: The change MUST survive a rebuild of the generated API client, without hand edits to generated files.
- **FR-008**: A cash session's status MUST match the rule the API applies to the same session.
- **FR-009**: An automated check MUST fail the build when a data-access path is added that bypasses the shared rule.
- **FR-010**: Automated tests covering timestamps MUST pass on a host in any timezone, not only the business one.

### Key Entities

- **Business timestamp**: a moment the business recorded, expressed as local wall-clock time in the business timezone and carrying no offset. The API stores and returns it that way, the legacy system that shares the database writes it that way, and the app must both read and write it that way. Its only two forms are the value on the wire and the value on screen, and this feature exists to make those two the same.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On every screen that shows a time, the displayed value matches the value the API returned, to the second, in 100% of cases checked.
- **SC-002**: For a day that includes trading after 18:00, a filtered list returns exactly the same records as the same query expressed in plain local time: same count, same first and last record.
- **SC-003**: A date chosen from a calendar and saved reads back as that same date, in 100% of cases checked.
- **SC-004**: For a session opened the previous evening and left open, the app's status matches the API's in 100% of cases.
- **SC-005**: No data-access path reaches the API without the shared conversion rule, enforced by a check that fails the build.
- **SC-006**: The full automated suite passes on a host whose timezone is not the business timezone.

## Assumptions

- **The viewer's timezone is the facility's timezone.** Wall-clock time with no offset is only unambiguous under that assumption. It holds for every deployment today, the API itself is pinned to a single business timezone, and the legacy system sharing the database assumes the same. If facilities ever span timezones, this approach stops being sufficient and the API would have to carry real offsets instead. Recorded here because it is the one assumption that would invalidate the whole design.
- **The API keeps the contract settled in mictlanix/mbe-api#228.** Timestamps stay local wall-clock with no offset, and an offset sent to the API is converted rather than dropped.
- **The outgoing stopgap from PR #180 is in place and is to be removed here.** Leaving it in place alongside this change would cancel both fixes out.
- **No stored data needs repairing.** Between the API change shipping and the stopgap landing, a date picked by a user could have been stored six hours early. A read-only check of the 100 most recent delivery orders found no record carrying that signature, so no backfill is planned. If plan finds evidence to the contrary, this assumption is what to revisit.
- **Date-only fields are out of scope.** They already read correctly and are handled by a different rule.
