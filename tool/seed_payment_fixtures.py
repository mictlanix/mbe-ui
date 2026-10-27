#!/usr/bin/env python3
"""Seeds the payment the Pagos walkthrough needs on a dev mbe-api (spec 055).

Run it after every database reset, from the repository root:

    python3 tool/seed_payment_fixtures.py

The walkthrough (integration_test/payments_quickstart_test.dart, step 5b)
follows a payment's application to a back-office order, and the app cannot
create one yet (mictlanix/mbe-roadmap#26), so the data has to come from the
API. It logs in as `MBE_ADMIN_*` from `.env` and:

1. looks for a payment already applied to a completed back-office order in the
   admin's facility. If there is one, it prints it and writes nothing, so the
   script is safe to run again;
2. otherwise takes the first completed back-office order that still has a
   balance, creates a CREDIT_PAYMENT for its customer (reference `QA055-SEED`,
   at most 1.00, in the order's currency) and applies it to that order.

A credit payment is also what the walkthrough's ticket step needs. If the
server refuses either call, the script stops and prints the status and the
server's own message, without trying other types or amounts. Credentials are
never printed.
"""

import json
import os
import sys
from decimal import Decimal

# `tool/` is not a package; reuse the account seeder's helpers.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from seed_test_accounts import ENV_PATH, Api, read_env  # noqa: E402

BACK_OFFICE = 1  # sales_order.origin
CREDIT_PAYMENT = 2  # customer_payment.payment_type
CASH = 1  # customer_payment.method, SAT forma de pago "Efectivo"
SEED_REFERENCE = 'QA055-SEED'
MAX_AMOUNT = Decimal('1.00')


def fail(message):
    raise SystemExit(message)


def detail(body):
    if isinstance(body, dict):
        return body.get('detail') or json.dumps(body)
    return str(body)


def back_office_orders(api, facility):
    status, page = api.call(
        'GET',
        f'/sales-orders?origin={BACK_OFFICE}&status=completed'
        f'&facility={facility}&limit=100')
    if status != 200:
        fail(f'Listing back-office orders failed: {status} {detail(page)}')
    return page['items']


def existing_application(api, orders):
    for order in orders:
        status, applications = api.call(
            'GET', f"/sales-orders/{order['sales_order_id']}/payments")
        if status != 200:
            fail(f"Reading the payments of order {order['sales_order_id']} "
                 f'failed: {status} {detail(applications)}')
        for application in applications:
            if not application['cancelled']:
                return order, application
    return None


def main():
    if not os.path.exists(ENV_PATH):
        fail('Run from the repository root; .env not found.')
    env = read_env()
    base = env.get('API_BASE_URL') or 'http://127.0.0.1:8000'
    api = Api(base)
    admin_user = env.get('MBE_ADMIN_USERNAME')
    admin_pass = env.get('MBE_ADMIN_PASSWORD')
    if not admin_user or not admin_pass:
        fail('MBE_ADMIN_USERNAME/_PASSWORD must be set in .env.')
    api.token = api.login(admin_user, admin_pass)
    if api.token is None:
        fail(f'Cannot log in to {base} as the MBE_ADMIN_* account.')
    status, me = api.call('GET', '/auth/me')
    facility = (me.get('settings') or {}).get('facility_id')
    if facility is None:
        fail('The MBE_ADMIN_* account has no facility to scope the orders to.')

    orders = back_office_orders(api, facility)
    found = existing_application(api, orders)
    if found:
        order, application = found
        print(f"Already seeded: payment {application['customer_payment']} is "
              f"applied to back-office order {order['sales_order_id']}. "
              'Nothing written.')
        return

    target = next(
        (o for o in orders if Decimal(o['balance']) > 0), None)
    if target is None:
        fail(f'No completed back-office order with a balance in facility '
             f'{facility} ({len(orders)} completed). Complete one in the app '
             'first, then run this again.')

    amount = min(Decimal(target['balance']), MAX_AMOUNT)
    status, payment = api.call('POST', '/customer-payments', body={
        'customer': target['customer'],
        'amount': str(amount),
        'method': CASH,
        'currency': target['currency'],
        'reference': SEED_REFERENCE,
        'payment_type': CREDIT_PAYMENT,
    })
    if status not in (200, 201):
        fail(f'Creating the payment was refused: {status} {detail(payment)}')
    payment_id = payment['customer_payment_id']

    status, applied = api.call(
        'POST', f'/customer-payments/{payment_id}/applications',
        body={'sales_order': target['sales_order_id'], 'amount': str(amount)})
    if status not in (200, 201):
        fail(f'Payment {payment_id} was created, but applying it to order '
             f"{target['sales_order_id']} was refused: {status} "
             f'{detail(applied)}')

    print(f'Seeded: credit payment {payment_id} ({amount}, {SEED_REFERENCE}) '
          f"applied to back-office order {target['sales_order_id']}.")


if __name__ == '__main__':
    sys.exit(main())
