#!/usr/bin/env python3
"""Creates or repairs the non-administrator test accounts on a dev mbe-api.

Run it after every database reset, from the repository root:

    python3 tool/seed_test_accounts.py

It logs in as `MBE_ADMIN_*` from `.env` and, for each account in ACCOUNTS:

- creates the user if it is missing;
- otherwise resets its password to the one in `.env`, when that no longer
  logs in;
- sets its privileges to exactly the listed set (every other system object
  is set to 0, so drift is undone, not merged);
- sets or clears its facility, clears `must_change_password`, activates it;
- logs in as it and checks the privileges the server reports.

Usernames and passwords are written back to `.env` (a password is generated
when the pair has none). Credentials are never printed. The roles, and the
tests that need each one, are in test/integration/TEST_ACCOUNTS.md.
"""

import json
import os
import re
import secrets
import sys
import urllib.error
import urllib.parse
import urllib.request

ENV_PATH = '.env'

# System-object codes, as in lib/core/access/system_object.dart.
PRODUCTS, LABELS, CUSTOMERS, SUPPLIERS, PRICE_LISTS = 0, 1, 2, 3, 5
EMPLOYEES, SALES_ORDERS, CUSTOMER_PAYMENTS = 6, 7, 8
FACILITIES, PAYMENT_METHOD_OPTIONS, USERS, PRICING = 29, 84, 92, 106
READ = 2

# (.env prefix, username, {system object: privileges}, needs a facility)
ACCOUNTS = [
    # Negative control: holds nothing at all.
    ('MBE_TEST', 'qanoaccess', {}, False),
    ('MBE_READONLY', 'qareadonly', {PRODUCTS: READ, USERS: READ}, False),
    ('MBE_NOQUOTES', 'qa053noquotes', {PRODUCTS: READ, SALES_ORDERS: READ}, False),
    ('MBE_QA054', 'qa054payments', {
        CUSTOMER_PAYMENTS: READ, CUSTOMERS: READ, EMPLOYEES: READ,
        SALES_ORDERS: READ, FACILITIES: READ, PAYMENT_METHOD_OPTIONS: READ,
    }, True),
    ('MBE_QA033', 'qa033pricingro', {
        PRICING: READ, PRODUCTS: READ, LABELS: READ, SUPPLIERS: READ,
        PRICE_LISTS: READ,
    }, True),
]


def read_env():
    values = {}
    with open(ENV_PATH) as f:
        for line in f:
            m = re.match(r'^([A-Z0-9_]+)=(.*)$', line.rstrip('\n'))
            if m:
                values[m.group(1)] = m.group(2)
    return values


def write_env(updates):
    with open(ENV_PATH) as f:
        lines = f.read().split('\n')
    pending = dict(updates)
    for i, line in enumerate(lines):
        m = re.match(r'^([A-Z0-9_]+)=', line)
        if m and m.group(1) in pending:
            lines[i] = f'{m.group(1)}={pending.pop(m.group(1))}'
    if pending:
        while lines and lines[-1] == '':
            lines.pop()
        lines.append('')
        lines.extend(f'{k}={v}' for k, v in pending.items())
        lines.append('')
    with open(ENV_PATH, 'w') as f:
        f.write('\n'.join(lines))


class Api:
    def __init__(self, base):
        self.base = base.rstrip('/') + '/api/v1'
        self.token = None

    def call(self, method, path, body=None, form=None, token=None):
        headers = {}
        data = None
        if form is not None:
            data = urllib.parse.urlencode(form).encode()
            headers['Content-Type'] = 'application/x-www-form-urlencoded'
        elif body is not None:
            data = json.dumps(body).encode()
            headers['Content-Type'] = 'application/json'
        bearer = token or self.token
        if bearer:
            headers['Authorization'] = f'Bearer {bearer}'
        req = urllib.request.Request(
            self.base + path, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=30) as res:
                raw = res.read()
                return res.status, (json.loads(raw) if raw else None)
        except urllib.error.HTTPError as e:
            raw = e.read()
            try:
                return e.code, json.loads(raw)
            except ValueError:
                return e.code, raw.decode(errors='replace')

    def login(self, username, password):
        status, body = self.call(
            'POST', '/auth/login',
            form={'username': username, 'password': password})
        return body['access_token'] if status == 200 else None


def seed(api, admin_facility, env, prefix, username, grants, needs_facility):
    password = env.get(f'{prefix}_PASSWORD') or ''
    if env.get(f'{prefix}_USERNAME') != username or not password:
        password = f'Qa-{secrets.token_hex(8)}-9z'
    status, user = api.call('GET', f'/users/{username}')
    if status == 404:
        status, body = api.call('POST', '/users', body={
            'user_id': username,
            'password': password,
            'email': f'{username}@example.invalid',
            # Employee 1 is the system record; accounts may share it.
            'employee_id': 1,
            'administrator': False,
            'status': 0,
        })
        if status not in (200, 201):
            raise SystemExit(f'{username}: create failed ({status}): {body}')
        action = 'created'
        status, user = api.call('GET', f'/users/{username}')
    elif status == 200:
        action = 'updated'
        if api.login(username, password) is None:
            status, body = api.call('POST', f'/users/{username}/recover-password')
            if status != 200:
                raise SystemExit(f'{username}: recovery failed ({status})')
            status, body = api.call('POST', '/auth/recover', body={
                'recovery_token': body['recovery_token'],
                'new_password': password,
            })
            if status != 204:
                raise SystemExit(f'{username}: password reset failed ({status}): {body}')
            action = 'updated, password reset'
    else:
        raise SystemExit(f'{username}: lookup failed ({status}): {user}')

    if user.get('administrator'):
        raise SystemExit(f'{username}: is an administrator; refusing to touch it')

    # Every row the server holds, set to the grant or to 0.
    objects = {p['system_object'] for p in user.get('privileges', [])} | set(grants)
    privileges = [
        {'system_object': o, 'privileges': grants.get(o, 0)} for o in sorted(objects)
    ]
    status, body = api.call('PUT', f'/users/{username}', body={
        'administrator': False,
        'status': 0,
        'must_change_password': False,
        'privileges': privileges,
        'settings': {
            'facility_id': admin_facility if needs_facility else None,
            'point_sale_id': None,
            'cash_drawer_id': None,
        },
    })
    if status != 200:
        raise SystemExit(f'{username}: update failed ({status}): {body}')

    token = api.login(username, password)
    if token is None:
        raise SystemExit(f'{username}: cannot log in after seeding')
    status, me = api.call('GET', '/auth/me', token=token)
    held = {}
    for p in me.get('privileges', []):
        value = (p.get('privileges') if 'privileges' in p else
                 (1 if p.get('allow_create') else 0) | (2 if p.get('allow_read') else 0) |
                 (4 if p.get('allow_update') else 0) | (8 if p.get('allow_delete') else 0))
        if value:
            held[p['system_object']] = value
    if held != grants or me.get('administrator'):
        raise SystemExit(f'{username}: server reports {held}, expected {grants}')

    env[f'{prefix}_USERNAME'] = username
    env[f'{prefix}_PASSWORD'] = password
    facility = f', facility {admin_facility}' if needs_facility else ''
    print(f'{prefix}_* = {username}: {action}; {len(grants)} grant(s){facility}; verified')


def main():
    if not os.path.exists(ENV_PATH):
        raise SystemExit('Run from the repository root; .env not found.')
    env = read_env()
    base = env.get('API_BASE_URL') or 'http://127.0.0.1:8000'
    api = Api(base)
    admin_user = env.get('MBE_ADMIN_USERNAME')
    admin_pass = env.get('MBE_ADMIN_PASSWORD')
    if not admin_user or not admin_pass:
        raise SystemExit('MBE_ADMIN_USERNAME/_PASSWORD must be set in .env.')
    api.token = api.login(admin_user, admin_pass)
    if api.token is None:
        raise SystemExit(f'Cannot log in to {base} as the MBE_ADMIN_* account.')
    status, me = api.call('GET', '/auth/me')
    admin_facility = (me.get('settings') or {}).get('facility_id')
    if admin_facility is None:
        raise SystemExit('The MBE_ADMIN_* account has no facility to give the '
                         'facility-scoped accounts.')

    for prefix, username, grants, needs_facility in ACCOUNTS:
        seed(api, admin_facility, env, prefix, username, grants, needs_facility)
    write_env({k: v for k, v in env.items()
               if any(k.startswith(p + '_') for p, *_ in ACCOUNTS)})
    print(f'.env updated ({len(ACCOUNTS)} accounts).')


if __name__ == '__main__':
    sys.exit(main())
