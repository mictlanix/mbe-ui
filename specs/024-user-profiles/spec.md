# Feature Specification: User Profiles as Permission Templates

**Feature Branch**: `024-user-profiles`

**Created**: 2026-08-14

**Status**: Draft

**Input**: User description: "Let's create a spec to implement new user profile api. Project mbe-api and generated code have recently been updated."

## Background

Provisioning a user account today means deciding a create/read/update/delete permission for each of more than a hundred system objects, one checkbox group at a time, in the permission grid on the user form. Every cashier is set up the same way as the last cashier, but nothing records that fact — the knowledge lives with whoever set up the previous account. The result is slow onboarding and silent inconsistency between people doing the same job.

The backend now offers **user profiles**: named, reusable permission templates — "Cashier", "Warehouse Clerk", "Branch Manager" — that an administrator maintains once and applies to as many accounts as needed. A profile is a *template*, not a live group. Applying one copies its permissions onto the account and replaces everything the account held; from that moment the permissions are the account's own, and later edits to the profile do not reach back. The account keeps a note of which profile it came from, so an administrator can find every account provisioned from a profile and re-apply a correction — but that note is provenance only, and nothing about how permissions are enforced changes.

Nothing in the application surfaces any of this. This feature is the client side of it: a catalog where profiles are authored and maintained, a way to provision an account from one, and enough visibility on the user list to find the accounts a profile produced.

## Clarifications

### Session 2026-08-14

- Q: How much of the backend capability should this feature cover — the profile catalog alone, or the user-side integration too? → A: **Both.** The catalog (list, view, create, edit, retire, delete) *and* the user-side pieces: a profile choice when creating a user, an apply action on an existing user, the origin profile shown on the user list, and a filter to find every account provisioned from a profile. A catalog with nothing to apply it to is inert, and this application is the only client that can author profiles at all.
- Q: How should access to the profile screens be gated? Every existing route is gated on a system object plus an access right, but profiles have no system object of their own. → A: **On the administrator flag**, matching what the backend actually enforces. Gating profiles under the existing users permission would show the screens to a non-administrator who holds `users:read` and then fail every request with a refusal they cannot act on.
- Q: Where does the profile catalog live in navigation? → A: **A top-level entry beside Users**, in the same navigation group Users already occupies, at the route `/user-profiles`.
- Q: Applying a profile signs the target account out of all its sessions. What if an administrator applies one to their own account? → A: **Permitted, with the consequence stated before it happens.** The backend allows it, and administrators bypass per-object permission checks anyway, so the account is not locked out — but the administrator's own session ends, so the confirmation must say so and the resulting sign-out must be handled as an ordinary expiry rather than an error.

## User Scenarios & Testing *(mandatory)*

<!--
  User stories are PRIORITIZED user journeys. Each is INDEPENDENTLY TESTABLE —
  implementing just one still yields a viable slice.
-->

### User Story 1 - Author and maintain the profile catalog (Priority: P1)

An administrator opens the profile catalog and sees which permission templates exist. They create a "Cashier" profile, giving it a name, a short description, and ticking the permissions the role needs across the system objects it touches — leaving every other object untouched, which means denied. Later they come back to inspect what "Warehouse Clerk" actually grants, correct a permission that was set too broadly, rename a profile whose job title changed, and retire a profile for a role the company no longer staffs.

**Why this priority**: This application is the only place a profile can be authored, so nothing else in the feature has anything to work with until the catalog exists. It is also a complete, shippable slice on its own — an administrator can express and maintain the company's roles even before anything is provisioned from them.

**Independent Test**: Sign in as an administrator, create several profiles with known permission sets, list and search them, filter by status, open one and confirm its permissions read back exactly as entered, edit its name and one permission and confirm both persist, retire one by marking it inactive, and delete one that has never been applied. Requires no other story.

**Acceptance Scenarios**:

1. **Given** an administrator, **When** they open the profile catalog, **Then** they see a paginated list of profiles showing each one's name, description and status.
2. **Given** more profiles than fit one page, **When** the administrator moves between pages, **Then** the list pages through them and the current page is reflected in the address so it survives a reload and can be shared.
3. **Given** a catalog of profiles, **When** the administrator searches by name, **Then** only matching profiles are listed and the search term survives a reload.
4. **Given** a catalog containing active and inactive profiles, **When** the administrator filters by status, **Then** only profiles with that status are listed, using the same status filter control every other catalog uses.
5. **Given** an administrator on the catalog, **When** they create a profile with a name and a set of ticked permissions, **Then** the profile is saved and appears in the list.
6. **Given** the create form, **When** the administrator submits without a name, **Then** the form refuses before sending and says the name is required.
7. **Given** a profile named "Cashier" already exists, **When** the administrator tries to save another profile named "Cashier" or "cashier", **Then** the save is refused, the conflict is explained against the name field, and nothing the administrator typed is lost.
8. **Given** a saved profile, **When** the administrator opens it, **Then** they see its name, description, status, and its permissions across the full list of system objects — ticked where the profile grants something, unticked everywhere else.
9. **Given** a profile open for editing, **When** the administrator changes its name and one permission and saves, **Then** both changes persist and read back on the next open.
10. **Given** a profile with no permissions ticked at all, **When** the administrator saves it, **Then** it is accepted as a valid profile that grants nothing.
11. **Given** a profile no account was provisioned from, **When** the administrator deletes it and confirms, **Then** it disappears from the catalog.
12. **Given** a profile that accounts were provisioned from, **When** the administrator tries to delete it, **Then** the deletion is refused, the refusal explains that accounts still reference it, and the profile remains unchanged.
13. **Given** a profile for a role no longer staffed, **When** the administrator marks it inactive, **Then** it remains readable in the catalog and can no longer be applied to anyone.
14. **Given** a user who is not an administrator, **When** they are signed in, **Then** no navigation entry for profiles is shown and navigating to the profiles address directly is refused the same way any other inaccessible route is.

---

### User Story 2 - Provision an account from a profile (Priority: P1)

An administrator hires a cashier. On the new-user form they pick "Cashier" from the list of profiles instead of walking the permission grid, and the account is created with exactly the permissions that profile describes. Months later the same person moves to the warehouse: the administrator opens their account, applies "Warehouse Clerk", and — after a confirmation that spells out that this replaces every permission they currently hold and ends their active sessions — the account's permissions match the new role.

**Why this priority**: This is the reason the feature exists, and the only part that changes how long provisioning takes. Together with User Story 1 it is the minimum shippable whole: a catalog nobody can apply is inert.

**Independent Test**: With a profile already in the catalog, create a user naming that profile and confirm the new account's permission grid matches the profile — ticked where it grants, unticked everywhere else. Then take an existing account with different permissions, apply the profile to it, and confirm the same. Both halves are testable against the catalog from User Story 1 alone.

**Acceptance Scenarios**:

1. **Given** an administrator creating a user, **When** they open the profile choice, **Then** they can pick from the active profiles, and inactive ones are not offered.
2. **Given** the new-user form with a profile chosen, **When** the administrator saves, **Then** the account is created holding exactly that profile's permissions and recording it as the account's origin.
3. **Given** the new-user form, **When** the administrator chooses no profile, **Then** the account is created exactly as it is today, with no permissions and no recorded origin.
4. **Given** a profile that was retired or removed after the form was opened, **When** the administrator saves a user naming it, **Then** the save is refused with the reason shown, and no account is created.
5. **Given** an existing account open for editing, **When** the administrator chooses to apply a profile, **Then** they are asked to confirm, and the confirmation names the profile and states plainly that every current permission will be replaced and the account's active sessions will end.
6. **Given** that confirmation, **When** the administrator cancels, **Then** nothing is sent and the account is unchanged.
7. **Given** that confirmation, **When** the administrator confirms, **Then** the account's permissions are replaced by the profile's, the screen shows the resulting permissions and the new origin without needing a manual reload, and the administrator is told it succeeded.
8. **Given** an account that held permissions the profile does not grant, **When** a profile is applied, **Then** those permissions are gone — the profile becomes the account's entire permission set.
9. **Given** an apply that fails because the profile is inactive, was removed, or the account no longer exists, **When** the failure comes back, **Then** the reason is shown and what is on screen still reflects the account as it actually stands.
10. **Given** an account open in read-only view, **When** it is displayed, **Then** no apply action is offered.
11. **Given** an administrator applying a profile to their own account, **When** they are asked to confirm, **Then** the confirmation additionally warns that this will end their own session, and after it succeeds they are signed out the same way an expired session signs them out — not shown an error.
12. **Given** an account provisioned from a profile, **When** the administrator afterwards edits individual permissions on it by hand, **Then** the edit works exactly as it does today and the account keeps showing the profile it was provisioned from.
13. **Given** a user who is not an administrator, **When** they use the user screens, **Then** neither the profile choice nor the apply action is offered to them.
14. **Given** an empty profile catalog, **When** the administrator opens the new-user form, **Then** the profile choice makes clear there are no profiles yet rather than appearing broken.

---

### User Story 3 - Find and re-provision the accounts a profile produced (Priority: P2)

An administrator discovers the "Cashier" profile has been granting a permission cashiers should not have. They correct the profile — and nothing happens to the people already provisioned from it, because a profile is a copy, not a link. So they filter the user list by "Cashier", see exactly the accounts that came from it, and apply the corrected profile to each in turn.

**Why this priority**: Without it, a correction can only reach existing accounts by remembering who they are, which defeats the point of having profiles. But it is composed entirely of behaviour from the first two stories plus visibility, so the feature is useful before it lands.

**Independent Test**: Provision two accounts from the same profile, confirm both rows on the user list show that profile, filter the list by it and confirm exactly those two accounts are listed, then edit the profile and confirm neither account changed until it is re-applied.

**Acceptance Scenarios**:

1. **Given** a mix of provisioned and hand-built accounts, **When** the administrator lists users, **Then** each row shows the profile it was provisioned from, and shows nothing where there is none.
2. **Given** accounts provisioned from several profiles, **When** the administrator filters the user list by one profile, **Then** exactly the accounts provisioned from that profile are listed.
3. **Given** a profile filter applied, **When** the administrator reloads or shares the address, **Then** the same filtered list comes back, consistent with every other filter in the application.
4. **Given** a profile filter applied, **When** the administrator clears filters, **Then** the full user list returns.
5. **Given** an account provisioned from a profile, **When** the administrator opens it, **Then** the account shows which profile it was provisioned from, presented as where it came from rather than as a live link to what it currently holds.
6. **Given** an account whose permissions were hand-edited after being provisioned, **When** the administrator re-applies the profile, **Then** the hand-edits are discarded and the account matches the profile again.

---

### Edge Cases

- **A profile grants nothing.** Every permission unticked is a valid profile — a legitimate way to express a suspended role. Saving it must not be mistaken for an incomplete form, and applying it must deny the account everything.
- **A profile covers only a handful of system objects.** The catalog stores only what a profile grants, but the permission grid shows every system object. A thin profile must render as "ticked here, unticked everywhere else", never as a partially-loaded grid.
- **An account is provisioned, then hand-edited.** The recorded origin now points at a profile the account no longer matches. The interface must not imply the account still matches it, and must not offer any "out of sync" indicator — comparing an account against its origin is out of scope.
- **The origin profile is inactive.** An account can point at a retired profile. Its name still shows on the account and the user list; the profile is still readable in the catalog; it simply cannot be applied to anyone new.
- **A profile is retired between loading a form and submitting it.** Both the create-with-profile path and the apply path can be refused for this reason after the choice was made. The refusal must be shown for what it is, and the account left as it was.
- **Applying with unsaved edits on the user form.** The apply replaces permissions server-side and returns the result; whatever the form was showing before must not silently overwrite it afterwards.
- **The administrator applies a profile to their own account.** Their session ends. The confirmation says so beforehand, and the sign-out that follows is handled as an expiry, not a crash.
- **A signed-in user has a profile applied by someone else.** Their session stops being accepted; they are signed out on their next action like any other expiry. No new behaviour is required, but nothing may assume a session outlives an apply.
- **Deleting a referenced profile.** Refused, with the refusal naming that accounts still reference it. Retirement, not deletion, is the way to take a role out of use.
- **Duplicate name differing only in case.** "cashier" conflicts with "Cashier". The conflict must be reported against the name field, with the administrator's other input preserved.
- **An empty catalog.** The profile list, and the profile choice on the user form, must both read as "none yet" and point at creating one, rather than as an error or an empty control.
- **A very long profile name or description.** Neither may break the list layout, the user list column, or the confirmation text.

## Requirements *(mandatory)*

### Functional Requirements

**Profile catalog**

- **FR-001**: Administrators MUST be able to browse a paginated list of user profiles showing each profile's name, description and status, using the same list, pagination and empty-state presentation the application's other catalogs use.
- **FR-002**: The profile list MUST support searching by name.
- **FR-003**: The profile list MUST offer a status filter using the same status filter control the other catalogs use, and MUST NOT apply any status filter by default.
- **FR-004**: The profile list's search, status filter and page MUST be carried in the address, so a filtered view survives a reload and can be shared, consistent with every other list in the application.
- **FR-005**: Administrators MUST be able to open a profile read-only and see its name, description, status and its permissions across the full set of system objects.
- **FR-006**: Administrators MUST be able to create a profile with a required name, an optional description, a status, and any set of create/read/update/delete permissions per system object.
- **FR-007**: Administrators MUST be able to edit an existing profile's name, description, status and permissions.
- **FR-008**: Administrators MUST be able to delete a profile, after an explicit confirmation.
- **FR-009**: The profile permission editor MUST present the same create/read/update/delete choice per system object that the user permission editor presents, so an administrator recognises it as the same thing.
- **FR-010**: A profile MUST be saved carrying only the system objects it grants something on; objects left entirely unticked MUST NOT be sent as entries.
- **FR-011**: A profile with no permissions ticked MUST be accepted and saved as a valid profile.
- **FR-012**: When a profile is read back, every system object it does not name MUST be shown as granting nothing, so the editor always presents a complete picture.
- **FR-013**: A refused save caused by a duplicate name — compared without regard to case — MUST be reported against the name field, and MUST NOT discard anything the administrator entered.
- **FR-014**: A refused delete caused by accounts still referencing the profile MUST be reported with the reason the server gives, and the profile MUST remain in the catalog unchanged.
- **FR-015**: An administrator MUST be able to retire a profile by setting its status to inactive, which leaves it readable but no longer applyable.

**Provisioning an account from a profile**

- **FR-016**: The new-user form MUST offer an optional profile choice, listing only profiles that can actually be applied — that is, active ones.
- **FR-017**: Creating a user with a profile chosen MUST produce an account holding that profile's permissions; creating one with no profile chosen MUST behave exactly as it does today.
- **FR-018**: A user creation refused because the chosen profile is missing or inactive MUST report the reason, and the form MUST remain filled so the administrator can choose again.
- **FR-019**: The user detail screen, when editing an existing account, MUST offer an action to apply a profile, choosing from active profiles.
- **FR-020**: Applying a profile MUST require an explicit confirmation that names the chosen profile and states two consequences plainly: every permission the account currently holds is replaced, and the account's active sessions end.
- **FR-021**: Cancelling the confirmation MUST send nothing and leave the account untouched.
- **FR-022**: On a successful apply, the screen MUST show the account's resulting permissions and its newly recorded origin profile without requiring a manual reload, and MUST confirm the action succeeded.
- **FR-023**: A failed apply MUST report the reason and leave the screen showing the account as it actually stands, never a partially applied state.
- **FR-024**: When an administrator applies a profile to their own account, the confirmation MUST additionally warn that their own session will end, and the sign-out that follows MUST be handled as an ordinary session expiry rather than surfaced as an error.
- **FR-025**: The apply action MUST NOT be offered when the account is being viewed read-only, nor when creating a new account (where the profile choice serves that purpose).
- **FR-026**: Per-user permission editing MUST continue to work exactly as it does today on every account, including accounts provisioned from a profile, and MUST NOT clear an account's recorded origin.

**Seeing where an account came from**

- **FR-027**: The user list MUST show each account's origin profile, left empty for accounts that have none.
- **FR-028**: The user list MUST offer a filter that narrows it to the accounts provisioned from a chosen profile, carried in the address like every other filter.
- **FR-029**: The user detail screen MUST show the account's origin profile, presented as where the account was provisioned from rather than as a live description of what it currently holds.
- **FR-030**: Nothing in the interface may claim or imply that an account's current permissions still match its origin profile, and no comparison between the two may be offered.

**Access control and presentation**

- **FR-031**: Every profile capability — browsing the catalog, creating, editing, deleting, and applying — MUST be available only to administrators, matching what the backend enforces.
- **FR-032**: The profile catalog MUST be reachable at `/user-profiles`, and navigating there without administrator rights MUST be refused the same way any other inaccessible route is.
- **FR-033**: The navigation entry for profiles MUST sit beside the Users entry in the same navigation group, and MUST be hidden from users who are not administrators.
- **FR-034**: The profile choice on the new-user form and the apply action on the user form MUST be hidden from users who are not administrators.
- **FR-035**: All text introduced by this feature MUST be available in both supported locales, with Spanish as the default, and all currency and dates formatted through the application's existing formatting rules.

### Key Entities

- **User Profile**: A named, reusable permission template. Carries a name unique without regard to case, an optional description, an active/inactive status, and a set of permissions. Exists independently of any account — a profile is meaningful whether or not it has ever been applied.
- **Profile Permission**: One entry within a profile — a system object and what the profile grants on it, drawn from the same create/read/update/delete vocabulary already used for user permissions. A profile holds entries only for the objects it grants something on; every other object is denied.
- **User** *(existing, extended)*: Gains an optional record of the profile it was last provisioned from, shown on the user list and the user detail screen. The record is history, not authority: no permission decision reads it, and hand-editing an account's permissions does not clear it.
- **System Object** *(existing, unchanged)*: The catalog of things permissions are granted on. The same fixed list the user permission editor already walks; profiles use it unchanged.
- **User Permission** *(existing, unchanged)*: An account's permission on one system object, and still the only thing that decides what an account may do. Applying a profile writes into these; nothing else about them changes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An administrator can give a new account a complete permission set by choosing one profile, replacing the per-object walk through more than a hundred system objects that provisioning requires today.
- **SC-002**: Provisioning permissions for a new account takes under one minute, measured from opening the new-user form to a saved account.
- **SC-003**: Two accounts provisioned from the same profile, neither hand-edited afterwards, show identical permissions on every system object when opened side by side.
- **SC-004**: After an apply, the permissions shown on screen match the applied profile on every system object — granted where the profile names it, denied everywhere else — with zero discrepancies and with no manual reload.
- **SC-005**: Every irreversible profile action — applying a profile and deleting one — states its consequences before it happens, in 100% of cases.
- **SC-006**: Given a profile, an administrator can list every account provisioned from it in a single filter action, without keeping a list outside the system.
- **SC-007**: A user who is not an administrator encounters no path to profiles anywhere: no navigation entry, no reachable address, no profile choice on the user form, and no apply action.
- **SC-008**: Nothing changes for accounts that have never had a profile applied — the existing user management flows behave exactly as before, and the existing user tests pass unmodified.
- **SC-009**: All text this feature introduces reads correctly in both supported locales, with no untranslated strings.

## Assumptions

- **Administrator gating is a deliberate departure from the route-guard convention.** Every route today is gated on a system object and an access right; profiles have no system object of their own, because the backend gates them on the administrator flag instead. Gating them under the users permission would show the screens to someone holding `users:read` who is then refused by every request. The route guard is extended to express "administrator only"; an administrator already short-circuits to full access everywhere else, so this narrows nothing that was previously open.
- **Applying happens one account at a time.** Applying one profile to many accounts in a single action is not offered; re-provisioning a set of accounts is done one at a time from the filtered user list.
- **Profiles are authored directly, never captured.** "Save this account's permissions as a new profile" is a plausible convenience and is not part of this feature.
- **Drift between an account and its origin profile is not detected or shown.** The recorded origin says where an account came from, not whether it still matches. Defining and displaying "still matches" is a separate concern.
- **Existing accounts are not migrated.** No attempt is made to guess which profile existing accounts resemble; they keep their permissions and show no origin.
- **The apply action lives on the user detail screen, not as a row action on the user list.** The confirmation needs to name the account and show what happens to it, and the detail screen is where an account's permissions are already visible.
- **The permission editor is shared with users, not rebuilt.** Profiles present the same per-object create/read/update/delete editor the user form already uses, so the two read as the same concept.
- **The full list of system objects comes from the client, as it does today.** The backend returns only what a profile grants, and offers no catalog of system objects; the application already holds that list for the user permission editor.
- **Retirement, not deletion, is how a role is taken out of use.** Deletion is refused while any account references a profile, so an administrator retiring a staffed role sets it inactive.
- **A user signed out by someone else's apply needs no new handling.** Their session simply stops being accepted, which the application already handles as an expiry.

## Out of Scope

- Applying a profile to several accounts at once.
- Creating a profile from an existing account's permissions.
- Detecting or displaying whether an account still matches the profile it came from.
- Migrating existing accounts onto profiles.
- Changing how per-user permission editing behaves; it keeps its current semantics, which differ from an apply by design.
- Per-facility or otherwise scoped profiles; the catalog is global.
- Any change to how permissions are enforced or to what the permission vocabulary contains.

## Verbatim Constraints

The route the profile catalog must be reachable at, and the field names the user record carries, are pinned:

- Route: `/user-profiles`
- User fields carrying the recorded origin: `profile_id`, `profile_name`
- The user list's filter parameter for the origin profile: `profile_id`
