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

| `.env` pair | Username | Administrator | Required privileges |
|---|---|---|---|
| `MBE_ADMIN_*` | `admin` | **yes** | none needed — `require_admin` and `AccessControlService.isAdministrator` short-circuit every check |
| `MBE_TEST_*` | `agonzalez` | no | **none at all** — every privilege denied (`0`) |
| `MBE_READONLY_*` | `augusto` | no | `products` (0) = **2** (read)<br>`users` (92) = **2** (read) |
| `MBE_CREATE_TEST_*` | `admin` | yes | needs `products` create + read + update + delete |
| `MBE_CATALOG_TEST_*` | `admin` | yes | needs create + delete on `customers` (2), `priceLists` (5), `employees` (6), `taxpayerRecipients` (54) |
| `MBE_CASH_SESSION_*` | `admin` | yes | needs `pos` (44) read + create, `cashSessionClose` (111) update, and at least one visible cash drawer |
| `MBE_POS_*` | `admin` | yes | needs an **already open cash session** on its point of sale |

The last four currently point at `admin`, which satisfies them by
short-circuiting rather than by holding the listed privileges. Only
`agonzalez` and `augusto` must be non-administrators — every assertion they
back is a *negative* one (`expect(..., isFalse)`), and an administrator would
pass every check and make those tests vacuous.

### Why these exact privileges

Each row is forced by an assertion, not chosen for tidiness. `agonzalez` is
the **negative control**: its whole purpose is to hold nothing, so that every
"this user is denied" assertion has an account that genuinely is.

- **`agonzalez` must have no `products` privilege** —
  `product_catalog_flow_test.dart` scenario 4 asserts `can(products, read)` is
  false, covering FR-012/SC-004. US3 scenario 3 and US4 scenario 4 then assert
  `update` and `delete` are denied.
- **`agonzalez` must have no `users` privilege** — `auth_flow_test.dart`
  scenario 6 asserts `can(users, read)` is false, covering FR-007 (a module
  with no privilege row is fully inaccessible).
- **`augusto` must have `users.read` but not update/delete** —
  `catalog_consistency_flow_test.dart` US2 scenario 1 asserts exactly that
  triple, standing in for a row whose Edit/Delete actions are omitted.
- **`augusto` must have `products.read`** — `product_photo_flow_test.dart`
  reads a photo as this account to show that viewing needs no write privilege.

Granting `agonzalez` anything makes those assertions vacuous rather than
failing loudly, so err toward denying it.

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
administrator may create users). Run from the repository root:

```bash
set -a && . ./.env && set +a
B=${MBE_API_BASE_URL:-http://127.0.0.1:8000}

T=$(curl -s -X POST "$B/api/v1/auth/login" \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -d "username=$MBE_ADMIN_USERNAME&password=$MBE_ADMIN_PASSWORD" \
    | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')

# `employee_id` is required and NOT NULL since mbe-api migration 012 (#127).
# Employee 1 ("Administrador del Sistema") is a system record, not a real
# person, and is not unique-constrained — both accounts may share it.
create() {  # create <username> <password> <email>
  curl -s -o /dev/null -w "create $1 -> %{http_code}\n" \
    -X POST "$B/api/v1/users" -H "Authorization: Bearer $T" \
    -H 'Content-Type: application/json' \
    -d "{\"user_id\":\"$1\",\"password\":\"$2\",\"email\":\"$3\",\"employee_id\":1,\"administrator\":false,\"status\":0}"
}

# New users are created with one denied (`privileges: 0`) row per SystemObject,
# so PUT only needs to name what is granted.
grant() {  # grant <username> <json privileges array>
  curl -s -o /dev/null -w "grant $1 -> %{http_code}\n" \
    -X PUT "$B/api/v1/users/$1" -H "Authorization: Bearer $T" \
    -H 'Content-Type: application/json' -d "{\"privileges\":$2}"
}

create "$MBE_TEST_USERNAME"     "$MBE_TEST_PASSWORD"     "agonzalez@mictlanix.test"
create "$MBE_READONLY_USERNAME" "$MBE_READONLY_PASSWORD" "augusto@mictlanix.test"

# agonzalez needs no `grant` at all — creation already denies everything, and
# that is exactly its role. It is listed here only to make the intent explicit.
grant "$MBE_READONLY_USERNAME" '[{"system_object":0,"privileges":2},{"system_object":92,"privileges":2}]'
```

`user_id` must be 4–20 alphanumeric characters (mbe-api `UserCreate`), so both
names are used verbatim from `.env`.

## Verifying

This prints the effective privileges the tests actually assert on:

```bash
set -a && . ./.env && set +a
B=${MBE_API_BASE_URL:-http://127.0.0.1:8000}

for pair in "$MBE_TEST_USERNAME:$MBE_TEST_PASSWORD" \
            "$MBE_READONLY_USERNAME:$MBE_READONLY_PASSWORD"; do
  u=${pair%%:*}; p=${pair#*:}
  t=$(curl -s -X POST "$B/api/v1/auth/login" \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -d "username=$u&password=$p" \
      | python3 -c 'import sys,json;print(json.load(sys.stdin).get("access_token",""))')
  [ -z "$t" ] && { echo "$u: LOGIN FAILED"; continue; }
  echo "$u:"
  curl -s -H "Authorization: Bearer $t" "$B/api/v1/auth/me" | python3 -c '
import sys, json
d = json.load(sys.stdin)
pr = {p["system_object"]: p for p in d.get("privileges", [])}
def f(o, k): return bool(pr.get(o) and pr[o][k])
print("  administrator =", d["administrator"])
print("  products: read=%s update=%s create=%s delete=%s" % (
    f(0,"allow_read"), f(0,"allow_update"), f(0,"allow_create"), f(0,"allow_delete")))
print("  users:    read=%s update=%s delete=%s" % (
    f(92,"allow_read"), f(92,"allow_update"), f(92,"allow_delete")))
'
done
```

Expected:

```
agonzalez:
  administrator = False
  products: read=False update=False create=False delete=False
  users:    read=False update=False delete=False
augusto:
  administrator = False
  products: read=True update=False create=False delete=False
  users:    read=True update=False delete=False
```

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
