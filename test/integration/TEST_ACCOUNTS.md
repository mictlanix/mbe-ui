# Integration-test accounts

The live integration tests in this directory authenticate as real mbe-api
accounts, named by the `MBE_*_USERNAME`/`MBE_*_PASSWORD` pairs in `.env` (see
`.env.template`). A database restore wipes them, and the failure is easy to
misread — the tests report `AppError.auth(Invalid username or password)`, which
looks like a code regression rather than a missing row.

This file records what each account must be so it can be recreated. It is the
seed contract, not a description of one particular database.

> Values in `privileges` are the `AccessRight` bitmask
> (`create=1, read=2, update=4, delete=8`), and `system_object` is the numeric
> `SystemObject` value — both mirror `lib/core/access/`.

## Accounts

`python3 tool/seed_test_accounts.py` creates or repairs every non-administrator
account below and writes its credentials to `.env`. **Run it after every
database reset.** The table in that script is the source of truth; this file
explains why each account is shaped the way it is.

| `.env` pair | Username | Administrator | Required privileges |
|---|---|---|---|
| `MBE_ADMIN_*` | `admin` | **yes** | none needed — `require_admin` and `AccessControlService.isAdministrator` short-circuit every check |
| `MBE_TEST_*` | `qanoaccess` | no | **none at all** — every privilege denied (`0`); no facility |
| `MBE_READONLY_*` | `qareadonly` | no | `products` (0) = **2** (read)<br>`users` (92) = **2** (read); no facility |
| `MBE_NOQUOTES_*` | `qa053noquotes` | no | read (2) on `products` (0) and `salesOrders` (7) only — **no** `salesQuotes` (30) (spec 053) |
| `MBE_QA054_*` | `qa054payments` | no | facility set (the admin's); read (2) on `customerPayments` (8), `customers` (2), `employees` (6), `salesOrders` (7), `facilities` (29), `paymentMethodOptions` (84). **No** `paymentsEditor` (100) and **no** `pos` (44) |
| `MBE_QA033_*` | `qa033pricingro` | no | facility set (the admin's); read (2) only on `pricing` (106), `products` (0), `labels` (1), `suppliers` (3), `priceLists` (5). **No** update anywhere and **no** `salesOrders` — the read-only pricing grid (spec 033 US5) and the no-Sales-Orders user of the spec 044 walkthrough |
| `MBE_CREATE_TEST_*` | `admin` | yes | needs `products` create + read + update + delete |
| `MBE_CATALOG_TEST_*` | `admin` | yes | needs create + delete on `customers` (2), `priceLists` (5), `employees` (6), `taxpayerRecipients` (54) |
| `MBE_CASH_SESSION_*` | `admin` | yes | needs `pos` (44) read + create, `cashSessionClose` (111) update, and at least one visible cash drawer |
| `MBE_POS_*` | `admin` | yes | needs an **already open cash session** on its point of sale |

The last four point at `admin`, which satisfies them by short-circuiting rather
than by holding the listed privileges. Every `qa…` account must be a
non-administrator: the assertions they back are *negative* ones
(`expect(..., isFalse)`), and an administrator would pass every check and make
those tests vacuous. The script refuses to touch an account that is an
administrator, and sets each one's privileges to exactly the listed set, so a
grant added by hand is undone on the next run.

### Why these exact privileges

Each row is forced by an assertion, not chosen for tidiness. `qanoaccess` is
the **negative control**: its whole purpose is to hold nothing, so that every
"this user is denied" assertion has an account that genuinely is.

- **`qanoaccess` must have no `products` privilege** —
  `product_catalog_flow_test.dart` scenario 4 asserts `can(products, read)` is
  false, covering FR-012/SC-004. US3 scenario 3 and US4 scenario 4 then assert
  `update` and `delete` are denied.
- **`qanoaccess` must have no `users` privilege** — `auth_flow_test.dart`
  scenario 6 asserts `can(users, read)` is false, covering FR-007 (a module
  with no privilege row is fully inaccessible).
- **`qareadonly` must have `users.read` but not update/delete** —
  `catalog_consistency_flow_test.dart` US2 scenario 1 asserts exactly that
  triple, standing in for a row whose Edit/Delete actions are omitted.
- **`qareadonly` must have `products.read`** — `product_photo_flow_test.dart`
  reads a photo as this account to show that viewing needs no write privilege.

Granting `qanoaccess` anything makes those assertions vacuous rather than
failing loudly, so err toward denying it.

These two replaced `agonzalez` and `augusto` on 2026-10-27. Those had drifted
to read on 106 system objects, which silently turned every negative assertion
above into a pass, and were deleted from the dev tenant.

### A note on the photo tests

`product_photo_flow_test.dart` used to run its upload/replace/remove scenarios
as `MBE_TEST_*`, which cannot work: those endpoints require `PRODUCTS.UPDATE`
(mbe-api `app/api/v1/endpoints/products.py`), while three other scenarios
require the same account to hold no `products` privilege at all. They now run
as `MBE_CREATE_TEST_*`, matching how every other write-capable fixture in this
directory is wired.

The trade-off: `MBE_CREATE_TEST_*` is `admin`, and an administrator
short-circuits privilege checks, so those scenarios prove photo CRUD works but
prove nothing about *privilege enforcement* on photos. Enforcement is covered
separately by the read-only scenario. If you ever want the stronger version,
seed a dedicated non-administrator with `products` = `6` (read + update) and
point the photo scenarios at it instead.

## Recreating them

Requires mbe-api reachable and the `MBE_ADMIN_*` account intact (only an
administrator may create users), with the admin's facility set. From the
repository root:

```bash
python3 tool/seed_test_accounts.py
```

For each account it creates the user if missing, otherwise resets its password
to the one in `.env` when that no longer logs in (through the admin
password-recovery endpoints). It then sets privileges, facility, active status
and `must_change_password = false`, logs in as the account, and checks that
the server reports exactly the expected privileges. It is idempotent. A
missing password is generated and written to `.env`; credentials are never
printed.

`user_id` must be 4–20 alphanumeric characters (mbe-api `UserCreate`).

## Non-account prerequisites

These are separate from the accounts and also lost or drifted on a restore.
Each is recorded in `.env.template` next to the test that needs it:

- `MBE_KNOWN_USER_ID`, `MBE_KNOWN_PRODUCT_CODE`, `MBE_KNOWN_PRODUCT_NAME_PART`
- `MBE_WITH_PHOTO_PRODUCT_ID`, `MBE_NO_PHOTO_PRODUCT_ID`, `MBE_MUTABLE_PRODUCT_ID`
- `MBE_POS_PRODUCT_PATTERN` — must match a **priced, in-stock** product in the
  POS account's warehouse. The default `a` is too broad to find anything on
  most dev datasets, which makes the POS sale/resume tests skip rather than
  fail.
- An **open cash session** on the `MBE_POS_*` account's point of sale.
