# Feature Specification: Localized API Messages from Error Codes

**Feature Branch**: `058-localized-api-errors`

**Created**: 2026-11-09

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#148. Design doc: [mbe-ui: Localized API messages](https://claude.ai/artifact/7zNdHW5xENQGZCBCP2fJnr), written 2026-10-21 before the server side shipped and adapted here to what shipped. Server side: mbe-api spec 036, PR #289, closing mictlanix/mbe-roadmap#147 on 2026-11-04. Contract: mbe-api `specs/036-localizable-error-codes/contracts/api.md` and `error-codes.md`. Weight: 0 (maturity, not parity).

When the server refuses something, the app shows a generic headline in the user's language, then the server's explanation in English under it. For business rules that English line is the only useful part. A clerk in `es-MX`, the default locale, reads "Customer is on credit hold: 4 overdue credit order(s) must be settled before a new order can be raised" and has to translate it in their head.

The server now sends a stable `code` and raw `params` with every error, next to the English text. This feature makes the app build its own message from them, in the user's language, with amounts, dates and names formatted the way the rest of the app formats them. When the app does not know a code, it keeps today's behaviour. That way a newer server never breaks an older app.

This is the foundation for every later screen. A feature spec that builds screens for a new area adds that area's messages in the same way.

## Clarifications

### Session 2026-11-09

- Q: Which of the server's 251 codes does this spec localize? → A: The generic codes, plus every code an endpoint the app calls today can return. Codes for areas with no screens yet are localized later, by the spec that builds their screens: fiscal documents, deliveries, itineraries, purchasing, inventory, commissions, supplier payments and analytics.
- Q: Do the forms move to the new messages in this spec, or later? → A: In this spec. Forms are where most users meet server refusals. Without this step they would keep showing English after the rest ships.
- Q: When the app has a message for a code, is the server's English text still shown? → A: No. Users see only the localized message, and the English text still goes to the log for support. Unknown codes keep today's headline plus the English line.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Server refusals read in the user's language (Priority: P1)

A clerk raises a credit order for a customer with overdue orders. Today the error panel shows a Spanish headline and an English sentence. With this feature it shows one Spanish sentence: "Este cliente tiene 4 pedidos a crédito vencidos. Liquídelos antes de crear un pedido nuevo." No English is shown. The same happens for every refusal the app knows, on every screen that shows server errors through the shared error panel: a missing record, a record still in use, a document no longer editable, a closed cash session, a payment over its balance, and so on.

When the server sends a code the app does not know, the panel looks exactly as it does today. The same happens when the server sends no code, or a param is missing.

**Why this priority**: This is the feature. It removes English from the default locale for the refusals users actually hit.

**Independent Test**: Against a live server, raise a credit order for a customer on credit hold with the app in `es-MX`, then in English. Each time the panel shows one sentence in that language with the overdue count, and no server text. Then point the app at a refusal with an unknown code (a test double) and check that the panel matches today's.

**Acceptance Scenarios**:

1. **Given** the app in `es-MX` and a refusal whose code the app knows, **When** the error panel shows it, **Then** it shows only the localized message built from the code and its params, and not the server's English text.
2. **Given** the same refusal with the app in English, **When** it is shown, **Then** the message is the English version from the app's own text, not the server's.
3. **Given** a refusal whose params carry an amount, a quantity or a date, **When** it is shown, **Then** the value is formatted as the app formats it everywhere else. For example, `"18450.00"` shows as `$18,450.00`, and a date follows the user's date-format setting.
4. **Given** a refusal naming a record kind (`resource: "customer"`), **When** it is shown, **Then** the kind appears as a localized noun ("cliente"), never as the server's internal name.
5. **Given** a refusal whose code the app does not know, or with no code, **When** it is shown, **Then** the panel shows today's generic headline plus the server's English text, unchanged.
6. **Given** a known code whose expected param is missing or has the wrong type, **When** it is shown, **Then** the panel falls back as in scenario 5, and nothing fails.
7. **Given** a known code was shown, **When** support reads the app log, **Then** the log has the code, the params and the server's English text.

---

### User Story 2 - Forms explain server refusals in the user's language (Priority: P1)

A manager saves a facility, a price list, a vehicle operator, or opens a cash session. The server refuses it, for example because a record with that name already exists or the drawer already has an open session. Today the form shows its own Spanish headline plus the server's English sentence, captured when the error happened. With this feature the form shows the localized message for the code. If the user switches language while the error is on screen, the message follows the switch.

**Why this priority**: Forms are where most server refusals appear. Without this story, Story 1 changes the panels but leaves the most-used screens in English.

**Independent Test**: Open a form and trigger a server refusal with a known code, such as a duplicate name on a catalog form or a busy drawer on opening a session. Check that the message is localized, then switch language and check that the message changes with it.

**Acceptance Scenarios**:

1. **Given** a form that the server refuses with a known code, **When** the form shows the error, **Then** it shows the localized message for that code and no server text.
2. **Given** that error on screen, **When** the user changes the app language, **Then** the message re-renders in the new language without resubmitting.
3. **Given** a form refusal with an unknown code, **When** it is shown, **Then** the form shows what it shows today: its own headline plus the server's English text.
4. **Given** a form error the app raises itself, without the server (a required field, an invalid quantity), **When** it is shown, **Then** it is unchanged by this feature.
5. **Given** a field-level validation refusal from the server whose `type` the app knows, **When** it is shown, **Then** the field shows the localized message for that type, with any values from its context formatted. Password rules keep today's per-rule messages.

---

### User Story 3 - Special handling relies on codes, not on wording (Priority: P2)

Some refusals do more than show a message. A pending password change sends the user to the change-password screen. A credit hold disables credit terms on the order. A busy drawer or busy cashier on opening a session gets its own message. Insufficient stock and zero-priced lines list the affected lines in the POS. Today each of these recognizes the refusal by its English text, its status code, or a second request. With this feature each one recognizes the code first and keeps the old check only as a fallback. Recognition no longer depends on wording.

The structured line refusals also accept both the shape the server sends today and the shape it will send after its announced breaking change (mbe-api spec 036, phase 3). That way the app is ready before the server switches.

**Why this priority**: These paths already work today. The value is robustness, and readiness for the server's breaking change, rather than a new visible message.

**Independent Test**: For each special path, feed a response that has only the code and generic English text, then one that has only the old signal and no code. Check that the same behaviour happens in both. For the line refusals, feed both the current and the future shape and check that the same lines are listed.

**Acceptance Scenarios**:

1. **Given** a 403 with code `auth.password_change_required`, **When** it arrives on any request, **Then** the user is sent to change their password, as today.
2. **Given** a refusal with code `customer.credit_hold`, **When** it arrives from creating, updating, confirming or converting an order or quote, **Then** the app treats it as a credit hold, as today, and shows its localized message.
3. **Given** opening a cash session is refused with `cash_session.drawer_busy` or `cash_session.user_busy`, **When** it is shown, **Then** the matching message appears without an extra request to the server.
4. **Given** a confirm refused for insufficient stock or zero-priced lines, **When** the server sends today's detail with lines, or the future string detail with a list of per-line parts, **Then** the POS lists the same lines with localized per-line reasons in both cases.
5. **Given** any of these responses from a server that sends no code, **When** it arrives, **Then** the app behaves as it does today.

---

### Edge Cases

- **Code newer than the app**: the server adds a code after this release. The app shows the generic headline plus English text, as in Story 1 scenario 5. It never fails to read the response.
- **Removed or renamed codes**: the server never renames or reuses a code; a retired code stays in its catalog. When a regenerated client drops a code the app still maps, the build fails, so the mapping is updated on purpose.
- **Record kind the app has no noun for**: the message uses a generic noun ("registro" / "record") rather than the server's internal name.
- **Lists in params**: a record still referenced by several kinds of records (`references`), or a permission refusal listing the grants that would open it (`required`). The message stays readable when the list is long, and counts use proper plural forms.
- **Plural counts**: one overdue order vs four. Every count uses the language's plural forms.
- **Byte-typed responses**: print and export requests receive their error bodies as bytes. Their code is read the same way as for any other request.
- **Errors the app shows in places other than the panel**: a delivery destination card puts server text inside its own sentence, and a price cell shows a server message as a tooltip. Both use the localized message when the code is known.
- **Network failures and timeouts**: no response, no code. Unchanged.
- **Validation `type` the app does not know**: the field keeps showing the server's `msg`, as today.

## Requirements *(mandatory)*

### Functional Requirements

**Reading the error**

- **FR-001**: The app MUST read `code`, `params` and the per-part list from every error response body. This applies to JSON bodies and to bodies received as bytes. A body without them MUST map exactly as it does today.
- **FR-002**: A `code` the app does not recognize MUST NOT cause a failure. The error MUST be kept with no known code, and shown with today's fallback.
- **FR-003**: Every error the app shows MUST keep the server's English text, for the fallback and for the log, alongside the code and params.

**Building the message**

- **FR-004**: There MUST be one shared place that turns a code and its params into a message in the current language. It returns nothing when the code is unknown, a param it needs is missing, or a param has the wrong type.
- **FR-005**: The messages MUST come from the app's own translation files, one entry per code in both Spanish and English. Each entry MUST be named after the code, so a code can be found by text search, and MUST note which code it renders.
- **FR-006**: Amounts, quantities and dates in params MUST be formatted through the app's shared formatting (spec 028), following the user's settings. Counts MUST use plural forms.
- **FR-007**: Record kinds (`resource`) MUST be shown as localized nouns, with a generic noun for kinds the app has none for.
- **FR-008**: The localized message MUST replace the generic headline plus English text wherever the app has one. When there is none, the display MUST be today's.

**Scope of codes**

- **FR-009**: The app MUST provide messages for:
  - every generic code: record not found, already exists, still referenced, conflict; server error; invalid state transition; document not editable; record locked; unsupported status filter; malformed request; the authentication and permission codes;
  - every code that an endpoint the app calls today can return, per the server's error catalog and raise map.
- **FR-010**: Codes that only endpoints the app does not call can return are out of scope. They fall back as in FR-002 until the spec that builds their screens adds them.
- **FR-011**: Field-level validation types that the in-scope endpoints can return MUST have localized messages, using the values in their context. Password rules keep their existing messages.

**Where messages show**

- **FR-012**: The shared error panel MUST show the localized message when there is one, and MUST NOT show the server's English text in that case.
- **FR-013**: Form screens MUST keep the error itself and build its text when they show it, rather than storing server text when the error happens. That way the message follows a language change while on screen. Form messages for errors the app raises itself (`_localizeFormError`) stay as they are.
- **FR-014**: No screen may show the server's English text directly. It MUST always go through the shared message, which falls back to the English text only when there is no localized one.
- **FR-015**: The delivery destination card and the price cell tooltip MUST use the shared message.

**Special paths**

- **FR-016**: A pending password change MUST be recognized by its code, with today's text match kept as a fallback.
- **FR-017**: A credit hold MUST be recognized by its code on order and quote create, update, confirm and convert. Today's "string detail on a 422" check stays as a fallback.
- **FR-018**: Opening a cash session MUST tell a busy drawer from a busy cashier by code. The extra request stays only as a fallback when there is no code.
- **FR-019**: The structured refusals MUST accept both the current shape (a dict detail with a message and lines or missing items) and the announced future shape (a string detail plus a list of parts, each with its own code and params). Both shapes MUST give the same lines and reasons. This covers insufficient stock, zero-priced lines, missing delivery details and over-committed itinerary lines.

**Logging**

- **FR-020**: When a localized message is shown, the code, params and English text MUST be written to the app log.

### Key Entities

- **Problem**: what the server says went wrong. It holds a status, a `code` from the server's catalog, raw `params`, the English `detail`, and optionally a list of parts.
- **Problem part**: one item of a structured refusal, such as one stock line. It has its own code and params.
- **Localized message**: the text a user sees for a problem, in their language with formatted values. It is built when shown, never stored.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every code in scope (FR-009) has a Spanish and an English message. A check against the server's catalog lists none missing.
- **SC-002**: In `es-MX`, a refusal with any in-scope code shows no English text. Every in-scope code is covered by a check of its rendered message in both languages.
- **SC-003**: A refusal with an unknown code, no code, or a broken param shows exactly what it shows today, on the panel and on forms. No such case fails.
- **SC-004**: No screen shows server text except through the shared message, checked by a code search that finds zero direct uses.
- **SC-005**: Against the live dev server, three checks pass in `es-MX`:
  - a credit hold on an order shows the Spanish sentence with the overdue count;
  - a pending password change still lands on the change-password screen;
  - a zero-priced confirm still lists the affected lines.
- **SC-006**: Every existing error-handling test passes unchanged, other than tests that assert the English line is shown for a now-localized code.

## Assumptions

- **The server contract is stable**: mbe-api never renames or reuses a code (`error-codes.md`). Params hold raw values: ints, decimal strings at the stored scale, ISO dates, enum values, and plain strings only for values the client already knows.
- **The generated client defines the catalog**: the regenerated client already has the 251-code enum and the problem shapes. Mapping codes against it means a removed code fails the build, while an unknown incoming code is still read safely (FR-002).
- **Phase 3 is not scheduled**: the server's breaking move of the four dict details to `errors[]` is announced but not dated. This spec reads both shapes so the app ships first. No minimum-version check is needed for that.
- **Spanish copy is a draft**: the Spanish messages are written as part of this spec and reviewed with the rest. The existing parity check keeps Spanish and English in step.
- **"Calls today" is measured at planning**: the plan lists the endpoints the app calls and the codes each can return, from the server's raise map. That list is the exact scope of FR-009.

## Out of Scope

- Messages for codes only returned by areas with no screens yet: fiscal documents, delivery orders and itineraries, purchasing, inventory, commissions, supplier payments, analytics.
- Showing the code or the English text to users behind an expander.
- Any change to the server, which already ships what this spec needs.
- Changing how the app's own (client-side) form errors are worded.
- A constitution rule for showing server errors. It can be proposed once this lands.
