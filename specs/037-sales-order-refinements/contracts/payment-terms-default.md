# Contract: Payment Terms Default on Customer Attach

**Feature**: 037-sales-order-refinements | Covers FR-006 – FR-010a, US2

Supersedes spec 023 `contracts/capture-surface.md` §1's rule that the terms control never writes
except by the cashier's explicit choice. That rule is withdrawn here, deliberately and only for the
customer-attach trigger; everything else it said about the control still holds.

## C1 — The trigger

Payment terms are defaulted **when and only when a customer is attached to a sale**, through
`CustomerBar`'s picker (`onSelected`). No other event applies a default — not a re-price, not a
terms edit, not any `OrderHeaderPanel` field, not opening a screen.

The trigger is the same on both surfaces. `CustomerBar` is shared, and this contract belongs to the
bar, not to either screen.

## C2 — The three routes to the right terms

Which request carries the terms depends on state the client already knows. All three routes are
required; none is a fallback for another.

### C2.1 — No sale open yet → send nothing

The existing spec-036 fast path (`sale_editing.dart:93-108`) issues `open(customer:, salesperson:)`,
a single POST, and mbe-api derives the terms itself: credit when the customer's limit is above zero
and the customer is not the configured walk-in default, immediate otherwise.

**The client MUST NOT add `paymentTerms` to this call.** Doing so disqualifies the fast path and
turns one POST into POST + PUT, to reach a state the single POST already reaches (research R1).

### C2.2 — Sale open, customer has no credit line → bundle immediate

The attach write carries `paymentTerms: immediate` alongside the customer.

This is what makes FR-007 true: without it, an order raised on credit for a previous customer stays
on credit after being switched to a cash customer, because mbe-api never revisits terms on update.

Bundling is safe here because immediate is never validated against — it cannot be refused, so it
cannot take the customer attach down with it.

### C2.3 — Sale open, customer has a credit line → attach, then a separate write

Two writes, in order:

1. the attach write, **unchanged** — no terms in the payload;
2. a follow-up `updateHeader(paymentTerms: credit)`.

They are separate because credit **is** validated, on grounds the client cannot see (C3).

## C3 — Refusal handling

mbe-api refuses credit terms when the customer is the walk-in default, when the credit limit is not
above zero, **or when the customer has overdue completed-and-unpaid orders**. The client can predict
the first two; it cannot predict the third.

Therefore, on a refusal of the C2.3 follow-up write:

- the refusal is **swallowed** — not surfaced as an error banner;
- the customer stays attached, since it was attached by an earlier, successful write;
- the order stays on immediate terms;
- the terms control renders immediate, which is the truth about what the server will accept.

This is not error-hiding. The user asked for a customer, and got the customer. The default is a
convenience that did not apply, and the control still reports the real state and still lets them
select credit explicitly — at which point they get the same refusal message they get today.

**A retry that catches 422 broadly is explicitly forbidden.** The refusal is prose-only with no
machine-readable code, and our network layer currently discards that prose entirely, so a broad
catch would silently swallow unrelated validation failures (research R3).

## C4 — What the user can still do

- Both terms remain selectable for a customer with a credit line, exactly as today (FR-009).
  Restricting immediate for credit customers is a separate, deferred ask.
- A terms choice the user makes themselves holds. Nothing re-applies the default while the same
  customer stays attached (FR-008); only attaching a customer triggers it again.

## C5 — Surface parity

POS and back-office behave identically, because the rule lives in the shared bar and both screens'
controllers mix in the same `SaleEditing` implementation.

Observable difference between them, and it is a difference of *starting state*, not of rule: the
register opens its sale on the first scan, before any customer, so it always arrives at C2.2/C2.3;
the back-office screen cannot open a sale before a customer exists, so a new order always arrives at
C2.1 and an existing one at C2.2/C2.3.

## Verification

| Case | Expect |
|---|---|
| Back-office, new order, credit customer | one POST; order on credit; **no PUT** |
| Back-office, new order, cash customer | one POST; order on immediate |
| POS, scan then attach credit customer | attach write, then a terms write; order on credit |
| POS, scan then attach cash customer | one attach write carrying immediate; order on immediate |
| Existing order on credit, switch to cash customer | attach write carrying immediate; order on immediate |
| Existing order, attach credit customer the server refuses | customer attached; order on immediate; **no error banner** |
| User sets terms, then edits comment/currency/priority | terms unchanged by those writes |
