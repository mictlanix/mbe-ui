# Feature Specification: User Authentication & Access Control

**Feature Branch**: `001-user-authentication`

**Created**: 2026-06-14

**Status**: Draft

**Input**: User description: "auth/login — users sign in to MBE-UI with a
username and password, stay signed in for a working session, are
automatically signed out when their session is no longer valid, see only the
modules and actions they're permitted to use, can manage their own password,
and administrators can manage user accounts and permissions."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sign In and Work Within a Session (Priority: P1)

A user opens MBE-UI, signs in with their username and password, and is taken
to a screen showing only the modules and actions their role permits. They
remain signed in for the rest of their working session. If their session
becomes invalid (it expires, or an administrator changes their access while
they're signed in), they're returned to the sign-in screen the next time they
try to do something.

**Why this priority**: Nothing else in the application is usable without
this — it is the foundation every other module depends on, and it's the
first capability mbe-api exposes.

**Independent Test**: Can be fully tested on its own by signing in with valid
and invalid credentials, confirming the post-login screen only shows
permitted modules/actions, and confirming that an expired or revoked session
returns the user to the sign-in screen.

**Acceptance Scenarios**:

1. **Given** a user with valid credentials and an active account, **When**
   they submit the sign-in form, **Then** they are signed in and taken to a
   screen reflecting the modules and actions they are permitted to use.
2. **Given** a user enters an incorrect username or password, **When** they
   submit the sign-in form, **Then** they see a clear error message and
   remain on the sign-in screen, without being told which field was wrong.
3. **Given** a signed-in user whose session has expired, **When** they next
   attempt any action, **Then** they are returned to the sign-in screen and
   can sign in again to continue.
4. **Given** a signed-in user whose access was changed or revoked by an
   administrator, **When** they next attempt any action, **Then** they are
   treated as no longer signed in and returned to the sign-in screen.
5. **Given** a signed-in user, **When** they choose to sign out, **Then**
   their session ends immediately and they are returned to the sign-in
   screen.
6. **Given** a signed-in user, **When** they navigate the application,
   **Then** modules and actions (view/create/edit/delete) they do not have
   permission for are hidden or disabled.
7. **Given** a signed-in user with administrator status, **When** they
   navigate the application, **Then** all modules and actions are available
   to them regardless of any individual permission entries.

---

### User Story 2 - Manage My Own Password (Priority: P2)

A signed-in user changes their own password by providing their current
password and a new one. A user who has forgotten their password can request
help recovering access to their account.

**Why this priority**: Important for account security and reducing reliance
on administrators for routine password changes, but the application is
usable end-to-end without it (an administrator can act as a stopgap).

**Independent Test**: Can be tested independently by signing in, changing the
password, signing out, and signing back in with the new password; and by
exercising the "forgotten password" recovery request flow without needing any
other module.

**Acceptance Scenarios**:

1. **Given** a signed-in user, **When** they submit their current password
   and a new password through the password-change form, **Then** their
   password is updated and they can subsequently sign in with the new
   password.
2. **Given** a signed-in user, **When** they submit an incorrect current
   password while attempting to change it, **Then** the change is rejected
   with a clear error and their password remains unchanged.
3. **Given** a user who cannot sign in because they forgot their password,
   **When** they request account recovery, **Then** they are informed that
   an administrator will provide them with a way to regain access.
4. **Given** a user who has received a recovery credential from an
   administrator, **When** they use it, **Then** they are able to set a new
   password and sign in with it.

---

### User Story 3 - Administer User Accounts and Permissions (Priority: P3)

An administrator views the list of user accounts, creates new accounts,
edits existing accounts (including deactivating them), and manages each
user's per-module permissions (view/create/edit/delete) through a
permissions grid. Changing a user's permissions or deactivating their account
takes effect immediately, even if that user is currently signed in.

**Why this priority**: Required for onboarding/offboarding staff and keeping
access current, but day-to-day use of the application (Stories 1-2) does not
depend on it, and a small initial set of accounts can be provisioned manually
as a stopgap.

**Independent Test**: Can be tested independently by an administrator signing
in, creating a test account, granting/revoking specific module permissions,
and confirming those changes are reflected for that account (including a
forced sign-out if the account was active).

**Acceptance Scenarios**:

1. **Given** an administrator, **When** they open the user management
   screen, **Then** they see a list of all user accounts with their status
   (active/inactive) and administrator flag.
2. **Given** an administrator, **When** they create a new user account with a
   username, display name, and initial password, **Then** the account
   appears in the list and can be used to sign in.
3. **Given** an administrator, **When** they edit a user's per-module
   permissions in the permissions grid, **Then** those changes are saved and
   immediately govern what that user can see and do.
4. **Given** an administrator, **When** they deactivate a user's account,
   **Then** that user can no longer sign in, and if they were already signed
   in, their next action returns them to the sign-in screen.
5. **Given** a non-administrator, **When** they attempt to reach the user
   management screen, **Then** it is hidden or inaccessible to them.

---

### Edge Cases

- What happens when a user's session expires while they are filling out a
  form? They are returned to the sign-in screen on their next action;
  unsaved changes may be lost, and they can sign back in to continue.
- What happens if a user has no permission entries at all for a module they
  try to reach (e.g., via a direct link)? They are treated as having no
  access — the module is hidden or the attempt is blocked.
- What happens if an administrator deactivates their own account or removes
  their own administrator status? The change is applied like any other
  account change; the system does not need to prevent administrators from
  changing their own accounts.
- What happens if a user repeatedly enters the wrong password? They continue
  to see the same generic error message; this specification does not require
  a lockout after a number of attempts.
- What happens if two administrators edit the same user's permissions at the
  same time? The most recently saved change takes effect.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow a user to sign in using a username and
  password.
- **FR-002**: The system MUST keep a signed-in user authenticated for the
  duration of a normal working session without requiring them to re-enter
  credentials for every action.
- **FR-003**: The system MUST treat a user as signed out — and return them to
  the sign-in screen on their next action — once their session has expired or
  has been invalidated (e.g., due to an administrator changing their account).
- **FR-004**: The system MUST allow a signed-in user to sign out on demand,
  ending their session immediately.
- **FR-005**: The system MUST show a signed-in user only the modules and
  actions (view/create/edit/delete) that their account is permitted to use,
  based on their per-module permissions.
- **FR-006**: The system MUST grant users flagged as administrators access to
  all modules and actions, regardless of individual permission entries.
- **FR-007**: The system MUST treat a module for which a user has no
  permission entry as fully inaccessible to that user (no view, create, edit,
  or delete).
- **FR-008**: The system MUST display a clear, non-specific error message
  when sign-in fails due to incorrect credentials, without indicating whether
  the username or password was the cause.
- **FR-009**: The system MUST allow a signed-in user to change their own
  password by providing their current password and a new password, rejecting
  the change if the current password is incorrect.
- **FR-010**: The system MUST provide a way for a user who cannot sign in to
  request account recovery, and for an administrator to issue that user a
  means of regaining access and setting a new password.
- **FR-011**: The system MUST allow administrators to view a list of all user
  accounts, including each account's status (active/inactive) and
  administrator flag.
- **FR-012**: The system MUST allow administrators to create new user
  accounts and edit existing ones, including activating/deactivating them.
- **FR-013**: The system MUST allow administrators to view and edit each
  user's per-module permissions (view/create/edit/delete) through a
  permissions grid.
- **FR-014**: The system MUST apply permission and account-status changes
  made by an administrator immediately, including ending an affected user's
  current session if it is active.
- **FR-015**: The system MUST restrict access to the user account management
  screens to administrators; non-administrators MUST NOT be able to view or
  reach them.

### Key Entities

- **User Account**: a person who can sign into MBE-UI. Has a username,
  display name, password, active/inactive status, and an administrator flag.
- **Session**: represents a user's signed-in state after a successful
  sign-in. Has a limited lifetime and can become invalid before that lifetime
  ends (e.g., because an administrator changed the account).
- **Module Permission**: for a given user and a given business module
  (e.g., Products, Sales Orders, Invoices, User Accounts), records whether
  that user may view, create, edit, and/or delete within that module. A user
  with no entry for a module has no access to it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user with valid credentials can sign in and reach a screen
  reflecting their permitted modules within 5 seconds under normal network
  conditions.
- **SC-002**: 100% of modules and actions a signed-in user is not permitted to
  use are hidden or disabled — no unauthorized action is reachable from the
  interface.
- **SC-003**: A user whose session has expired or been revoked is returned to
  the sign-in screen on their very next interaction, with no broken or blank
  screens.
- **SC-004**: A signed-in user can change their own password, sign out, and
  sign back in with the new password, end to end, in under 2 minutes.
- **SC-005**: An administrator can change a user's permissions or deactivate
  their account, and that change governs the user's access on their very next
  interaction — without anyone restarting the application.
- **SC-006**: An administrator can create a new, working user account and
  grant it permissions to at least one module in under 5 minutes.

## Assumptions

- New user accounts are created only by administrators; there is no public
  self-registration flow.
- Account-recovery for a forgotten password is mediated by an administrator
  (they issue the user a means to regain access); this iteration does not
  assume automated email delivery of recovery links.
- A normal working session is long enough to cover a typical workday without
  re-authentication; users are expected to sign in again at the start of a
  new session rather than remain signed in indefinitely.
- There is no requirement in this iteration to lock an account after repeated
  failed sign-in attempts.
- The same view/create/edit/delete permission model applies uniformly across
  all business modules (sales, inventory, invoicing, accounting, master data,
  and user administration itself).
- This feature depends on mbe-api's authentication and user-management
  endpoints being available in the target environment.
