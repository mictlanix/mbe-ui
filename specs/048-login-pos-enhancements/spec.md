# Feature Specification: Login & POS Sales Enhancements

**Feature Branch**: `048-login-pos-enhancements`

**Created**: 2026-10-18

**Status**: Draft

**Input**: User description: "Login: ask new users to change password on first login. Enforce strong password. Add a verify password field when a password change is performed. POS Sales: paid sales should show details in read-only mode, currently it's redirecting to the payment step. Show stock from other facilities. File issues for mbe-api if we need API changes."

## Context & Findings

These findings come from an audit of mbe-ui and mbe-api done on 2026-10-18. They explain the current behavior and set the scope.

- **Password-setting forms.** The app has four places where a password is set:
  - *Change password*: a signed-in user changes their own password.
  - *Forgot password*: a user enters an administrator-issued recovery token plus a new password.
  - *New user*: an administrator types the initial password in the user form.
  - *Forced change*: new in this spec.

  None of the forms asks the user to type the new password twice. The only rule enforced is length: 6 characters on change and recovery, and 1 character on user creation.
- **First login.** The system has no record of whether a user still has the password an administrator gave them. Login and the current-user profile carry no such information, and nothing in the app checks for it.
- **Administrator "reset".** An administrator doesn't set a new password for a user. They issue a one-time recovery token, and the user then chooses their own new password with it. So after a reset, the password is already one the user chose. A forced change only matters for users whose password an administrator typed, which today means newly created users.
- **Paid POS sales.** Opening any POS sale from the list resumes the sale workspace on a step chosen from the sale's state. A paid counter sale resumes on the payment step (*Cobro*), even though nothing is left to collect. The capture step already has a read-only rendering for non-draft sales. The payment step has none.
- **Stock in other facilities.** The product lookup the POS already uses returns available stock for every warehouse in every facility. The capture line's warehouse pop-up (spec 047) lists only the sale's own facility, so stock elsewhere is never shown. The stock rows don't say which facility a warehouse belongs to. A cashier usually can't look that up separately, because they don't have warehouse read access.
- **Backend changes filed.** The changes this spec needs from mbe-api are filed as:
  - mictlanix/mbe-api#240: *must change password* flag;
  - mictlanix/mbe-api#241: configurable password policy, enforced and published;
  - mictlanix/mbe-api#242: facility on each stock row.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Confirm the new password (Priority: P1)

Whenever someone sets a password (their own change, recovery, a forced change, or an administrator creating a user), they type the new password twice. The form doesn't submit until the two entries match.

**Why this priority**: A mistyped password locks the user out and costs an administrator a recovery round-trip. This needs no backend change, so it can ship first.

**Independent Test**: Open each password-setting form, type two different values, and confirm submission is blocked with a mismatch message. Type matching values and confirm it submits.

**Acceptance Scenarios**:

1. **Given** the change-password form, **When** the new password and the confirmation differ, **Then** the form shows "passwords don't match" on the confirmation field and does not submit.
2. **Given** the forgot-password form with a valid recovery token, **When** both entries match and meet the rules, **Then** the password is set.
3. **Given** an administrator creating a user, **When** the password and confirmation differ, **Then** the user is not saved.
4. **Given** the confirmation already matches, **When** the user edits the new-password field, **Then** the match is checked again.

---

### User Story 2 - Paid sales open read-only (Priority: P1)

A cashier opens a fully paid POS sale from the sales list. They see its details: customer, date, register, salesperson, lines, totals and the payments that settled it. The view has no editing or payment controls. They can still preview or print the ticket.

**Why this priority**: Today a cashier looking up a past sale lands on a payment screen with nothing to pay. That is confusing, and it invites accidental actions. This needs no backend change.

**Independent Test**: Open a paid counter sale from the POS sales list. Confirm the read-only detail appears with lines, totals and payments, that no edit or payment action is offered, and that the ticket can be previewed.

**Acceptance Scenarios**:

1. **Given** a paid counter sale with a zero balance, **When** the cashier opens it from the list, **Then** the read-only detail is shown, not the payment step.
2. **Given** the read-only detail, **When** the cashier looks for actions, **Then** only the ticket preview/print and navigation back to the list are available.
3. **Given** a completed sale with a balance due, **When** it is opened, **Then** it resumes on the payment step as today.
4. **Given** a paid delivery sale with distribution still pending, **When** it is opened, **Then** it resumes on the delivery step as today.
5. **Given** a paid delivery sale whose distribution is finished, **When** it is opened, **Then** the read-only detail is shown.
6. **Given** a cashier who lacks permission to read customer payments, **When** they open a paid sale, **Then** the detail shows everything except the payments section, which says payments can't be shown. The rest of the view still works.

---

### User Story 3 - Stock in other facilities (Priority: P2)

While capturing a sale line, the cashier opens the warehouse pop-up. They see the sale facility's warehouses as today, and they can select them. Below those, a read-only section lists other facilities' warehouses that have the product available, grouped by facility, with the available quantity. These rows can't be selected.

**Why this priority**: When the local facility is short, the cashier can tell the customer where the product is, without calling around. It depends on a small backend change (mbe-api#242).

**Independent Test**: For a product stocked in a second facility, open the line's warehouse pop-up and confirm a section shows that facility, its warehouse and the available quantity. Confirm those rows can't be chosen.

**Acceptance Scenarios**:

1. **Given** a product with available stock in two other facilities, **When** the pop-up opens, **Then** both facilities appear under an "Other facilities" section, each with its warehouses and available quantities.
2. **Given** an other-facility row, **When** the cashier taps it, **Then** nothing is selected and the line's warehouse is unchanged.
3. **Given** a product with no available stock outside the sale's facility, **When** the pop-up opens, **Then** the section says it isn't available in other facilities.
4. **Given** a product that isn't stock-tracked, **When** the pop-up opens, **Then** the other-facilities section is not shown.

---

### User Story 4 - Strong passwords (Priority: P2)

Every password-setting form shows the deployment's password rules as a checklist that updates as the user types, for example "at least 8 characters", "an uppercase letter", "a lowercase letter" and "a number". The form submits only when all rules are met. If the server rejects a password anyway, the reason appears in the user's language.

**Why this priority**: It closes a real security gap, but it depends on mbe-api#241 for the rules and their enforcement.

**Independent Test**: With the default policy, type `abc12345` and confirm the uppercase rule shows as unmet and submission is blocked. Type `Abc12345` and confirm all rules show as met and the password is accepted.

**Acceptance Scenarios**:

1. **Given** the default policy, **When** the user types a password, **Then** each rule shows met or unmet as they type.
2. **Given** a deployment configured to also require a symbol, **When** the form opens, **Then** the checklist includes the symbol rule, with no app update.
3. **Given** a password the client considers valid, **When** the server rejects it for a policy rule, **Then** the failed rule is shown in the user's language.
4. **Given** an existing user whose current password doesn't meet the policy, **When** they log in, **Then** login succeeds. The policy applies only when a password is set.

---

### User Story 5 - Change password on first login (Priority: P3)

A user an administrator just created logs in for the first time. Before they reach any other screen, they are asked to choose a new password, which must follow the confirmation and strength rules above. They can't skip this, but they can log out instead. Once the change succeeds, they continue into the app.

**Why this priority**: It stops administrator-chosen passwords from staying in use, but it depends on mbe-api#240, and it builds on Stories 1 and 4.

**Independent Test**: Create a user as an administrator, log in as that user, and confirm the forced-change screen appears and every other route redirects to it. Change the password and confirm the app opens normally. Log out and in again and confirm the screen no longer appears.

**Acceptance Scenarios**:

1. **Given** a newly created user, **When** they log in, **Then** the forced-change screen is shown before anything else.
2. **Given** the forced-change screen, **When** the user tries to navigate elsewhere, for example by typing a URL, **Then** they are returned to it.
3. **Given** the forced-change screen, **When** the user chooses to log out, **Then** they are logged out.
4. **Given** a successful change, **When** the screen closes, **Then** the user lands where a normal login would have taken them, and later logins don't show the screen.
5. **Given** the server refuses a request because a password change is required, **When** that happens anywhere in the app, **Then** the user is taken to the forced-change screen rather than shown a generic error.

---

### Edge Cases

- **Mismatch after a fix:** the user types the confirmation first and then the new password. The match is re-evaluated whenever either field changes.
- **Policy unavailable:** if the password rules can't be loaded (network error), the form still works. It shows the rules as unknown, and the server's rejection becomes the source of truth.
- **Forced change and the old password:** the forced-change form asks for the current password, which is the one the administrator gave the user. This proves the user knows it, just like the normal change form does.
- **Sale paid while open:** a sale on the payment step becomes paid. The workspace keeps its existing post-payment behavior. The read-only view applies when a paid sale is opened.
- **Cancelled sales** keep today's behavior (an "unreachable" notice). This spec doesn't change them.
- **Sales from another register** keep today's notice. This spec doesn't change them.
- **Stock in a transit warehouse** is never listed, because the lookup already excludes transit warehouses.
- **Zero or negative available stock** in another facility's warehouse: the warehouse is omitted from the other-facilities section.

## Requirements *(mandatory)*

### Functional Requirements

**Password confirmation**

- **FR-001**: Every password-setting form (change password, forgot password, forced change, administrator new user) MUST have a "confirm new password" field.
- **FR-002**: A form MUST NOT submit while the confirmation differs from the new password, and MUST show a localized mismatch message on the confirmation field.
- **FR-003**: The match MUST be re-evaluated when either field changes.

**Paid sale read-only detail**

- **FR-010**: Opening a POS sale that is paid, has a zero balance, and has no pending distribution work MUST show a read-only detail instead of resuming a workspace step.
- **FR-011**: The read-only detail MUST show:
  - the customer, sale date, register and salesperson;
  - the lines, each with product, quantity, warehouse, price and line total;
  - the sale totals;
  - the payments applied, each with method, amount, change given and date.
- **FR-012**: The read-only detail MUST NOT offer any edit, payment, cancellation or line action. It MUST offer the existing ticket preview/print.
- **FR-013**: When the user may not read customer payments, the payments section MUST say so, and the rest of the detail MUST still render.
- **FR-014**: Completed sales with a balance, and paid delivery sales with pending distribution, MUST keep opening where they do today.

**Stock in other facilities**

- **FR-020**: For stock-tracked products, the warehouse pop-up MUST show a read-only "Other facilities" section below the sale facility's warehouses.
- **FR-021**: The section MUST group warehouses by facility, show each warehouse's available quantity, and include only warehouses with available stock greater than zero.
- **FR-022**: Rows in the section MUST NOT be selectable. They MUST be visibly distinct from selectable rows.
- **FR-023**: When no other facility has available stock, the section MUST say so.
- **FR-024**: The section MUST NOT need any privilege beyond what the POS capture step already needs.

**Password strength**

- **FR-030**: Password-setting forms MUST validate against the deployment's published password policy, not rules fixed in the app.
- **FR-031**: Forms MUST show each policy rule with a met/unmet state that updates as the user types, and MUST block submission while any rule is unmet.
- **FR-032**: Server rejections for policy reasons MUST be shown as localized, per-rule messages.
- **FR-033**: Logging in with an existing password MUST NOT be affected by the policy.

**Forced password change**

- **FR-040**: A user flagged by the server as needing a password change MUST be sent to a forced-change screen after login. Every other route MUST redirect there until the change succeeds.
- **FR-041**: The forced-change screen MUST ask for the current password, a new password and its confirmation. It MUST apply FR-002 and FR-031.
- **FR-042**: The forced-change screen MUST offer logout and MUST NOT offer any other way out.
- **FR-043**: After a successful change, the user MUST continue to their normal post-login destination.
- **FR-044**: A server refusal that indicates a required password change MUST take the user to the forced-change screen.

### Key Entities

- **Password policy**: the deployment's rules for new passwords. It has a minimum length plus a required/not-required setting for each of: uppercase letter, lowercase letter, number, symbol. It is owned by the backend.
- **User password state**: whether a user must change their password before using the app. It is set when an administrator creates the user and cleared when the user changes their password.
- **Facility stock row**: available quantity of a product in one warehouse, along with that warehouse's facility.
- **Sale payment application**: one payment applied to a sale, with method, amount, change and date.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of password-setting forms refuse a mismatched confirmation.
- **SC-002**: Opening a paid sale from the POS list never lands on the payment step. A cashier can find its payment method in one screen.
- **SC-003**: For a product short in the local facility, a cashier can name another facility that has it without leaving the sale, in under 10 seconds.
- **SC-004**: No password that breaks the deployment's policy can be set from any form. Changing the policy changes the form's rules with no app release.
- **SC-005**: A newly created user can't reach any screen other than the forced change, or logout, until they have replaced their initial password.

## Assumptions

- **Delivery order.** Stories ship independently. Stories 1 and 2 need no backend change. Stories 3, 4 and 5 are blocked on mbe-api#242, #241 and #240 respectively, and are consumed once those ship and the API client is regenerated (constitution III).
- **Interim password rule.** Until mbe-api#241 ships, the forms keep today's 6-character minimum, plus the new confirmation field. The plan decides whether to stage the strength checklist behind the policy's arrival.
- **Who is forced to change.** The forced change applies to administrator-created users, and to any user the backend flags. An administrator's recovery token doesn't trigger it, because the user already picks their own password there.
- **Forced-change enforcement.** The client redirect is the user-facing gate. Server-side enforcement (mbe-api#240, item 5) is what makes it impossible to bypass. The client also handles the server's refusal (FR-044).
- **Finished delivery sales.** A paid delivery sale whose distribution is complete gets the read-only detail too. The workspace's own comment already intends that "finished" sales open read-only.
- **Other-facility stock isn't access-scoped.** Showing other facilities' availability to a cashier is the purpose. The product lookup is intentionally not limited to the user's facilities.
- **Out of scope:**
  - changing how passwords are stored;
  - ending other sessions after a password change;
  - read-only changes to the back-office *Pedidos* screen;
  - selling from, or transferring between, other facilities' warehouses.
