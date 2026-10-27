# Feature Specification: Credit Notes

**Feature Branch**: `056-credit-notes`
**Created**: 2026-10-27
**Status**: Draft
**Input**: Credit notes (credit payments). Covers mictlanix/mbe-roadmap#28 (mbe-api docs/specs 02 §2.7; server: mbe-api spec 011 User Story 6, FR-070/FR-070a).

A credit note is store credit a refund leaves with a customer. It is backed by a payment of type "credit note". Spending it means applying that payment to another order, like any other payment. This feature lets a cashier spend credit notes while collecting a sale, and lets staff see which notes exist and what is left on each.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pay a sale with the customer's credit notes (Priority: P1)

A cashier is collecting a sale for a named customer who holds store credit. Next to the payment methods, the payment step shows the customer's credit-note balance. The cashier spends it in one action. The notes are used oldest first, up to the sale's balance. The sale's balance falls by the amount used, and the cashier finishes the rest with any other method.

**Why this priority**: Store credit that can't be spent is money the business owes and can't settle. Legacy's "Refunds: $X" button is how cashiers spend it today.

**Independent Test**: Use a customer holding an open credit note. Start a POS sale for them and open the payment step. Spend the credit. Check that the sale's balance and the note's remaining amount both fell by the same amount.

**Acceptance Scenarios**:

1. **Given** a named customer whose open notes total 300.00 and a sale with a balance of 1,000.00, **When** the cashier spends the credit, **Then** 300.00 is applied, the sale's balance becomes 700.00, and the notes show 0.00 remaining.
2. **Given** a named customer whose open notes total 1,500.00 and a sale with a balance of 1,000.00, **When** the cashier spends the credit, **Then** exactly 1,000.00 is applied, oldest note first, the sale is fully paid, and 500.00 stays spendable on the newest notes. No change is due.
3. **Given** a named customer with no spendable credit, **When** the payment step opens, **Then** no credit-note option is shown.
4. **Given** the cashier enters an amount before spending the credit, **When** they spend it, **Then** only that amount is applied, still capped at the credit available and the sale's balance.

---

### User Story 2 - Redeem a walk-in customer's credit-note ticket (Priority: P2)

A walk-in customer brings back a credit-note ticket. The sale is under the general-public customer, so there is no customer balance to offer. The cashier chooses to redeem a credit note and scans or types the number printed under the ticket's barcode. The app shows what is left on that note. The cashier applies it to the sale.

**Why this priority**: When a walk-in refund is issued as store credit, the ticket is the only proof of ownership. Without this, those notes can never be spent. It comes after P1 because it serves fewer sales.

**Independent Test**: Use an open credit note issued to the general-public customer. Start a walk-in sale, redeem the note by its ticket number, and check that the sale's balance and the note's remaining amount both fell by the same amount.

**Acceptance Scenarios**:

1. **Given** an open note with 200.00 remaining and a sale with a balance of 500.00, **When** the cashier enters the note's ticket number, **Then** the app shows the note's remaining 200.00. **When** they confirm, **Then** 200.00 is applied and the sale's balance becomes 300.00.
2. **Given** a ticket number that matches no credit note, **When** the cashier enters it, **Then** the app says no credit note has that number and applies nothing.
3. **Given** a note with nothing left, **When** the cashier enters its number, **Then** the app says it has been fully used and applies nothing.
4. **Given** a note already applied to this same sale, **When** the cashier enters its number again, **Then** the app refuses because the note is already on this sale.
5. **Given** a note issued to a named customer, **When** the cashier enters its number on a walk-in sale, **Then** the app refuses and says the note belongs to that customer, so the sale should be made out to them.

---

### User Story 3 - See which credit notes exist and what is left (Priority: P3)

A supervisor or cashier opens "Notas de crédito" to answer "does this customer have store credit, and where did it come from?" They filter by customer and can limit the list to notes with something left. Each row shows the customer, the date, the amount issued, the amount remaining, and its origin: the refund and the order it came from. Opening a row shows the backing payment on the existing payment detail screen, including every order it was applied to.

**Why this priority**: It's a read-only aid. Redemption (P1, P2) works without it, but staff need it to answer customer questions and to check a redemption.

**Independent Test**: Open the screen and filter to a customer holding notes. Check the issued and remaining figures against the backing payments. Open a row and confirm it lands on that note's payment.

**Acceptance Scenarios**:

1. **Given** a customer with three notes, one of them fully used, **When** the list is filtered to that customer, **Then** all three are shown, newest first, each with issued, remaining, date, refund and source order.
2. **Given** the same customer, **When** "only with balance" is turned on, **Then** only the two notes with something left are shown, and the count matches.
3. **Given** a user without read access to credit notes, **When** they look for the screen, **Then** it isn't in their navigation, and a direct link shows the standard no-access state.

---

### Edge Cases

- **Credit already on this sale.** A note already applied to the sale is left out of the balance offered in Story 1, and Story 2 refuses it. Legacy refused a second application of the same note to the same order.
- **Sale cancelled or already fully paid.** Credit is not offered, and a note can't be redeemed against it.
- **Note cashed out at a register.** A note marked with the cash session it was paid out in is not spendable. Legacy left these out of the spendable pool. The server is asked to confirm this rule in mbe-api#277.
- **Two registers spend the same note at once.** The server bounds every application by the note's remaining amount, so the second application fails. The app shows that failure and re-reads the sale's balance and the customer's credit. It never shows a balance it didn't read back.
- **Spending several notes partly fails.** If the first notes apply and a later one is refused, the applied ones stay applied. They're ordinary payments the cashier can see on the sale. The app reports how much was applied and re-reads the remaining credit.
- **A sale's customer changes after credit was applied.** Applied credit stays on the sale. Undoing it belongs to the payments editor (roadmap#26), not this feature.
- **Legacy notes report nothing left (server defect).** Today mbe-api reports 0.00 remaining for 982 of the dev tenant's 984 notes, because legacy writes 0 in the field the server reads (mbe-api#277). Until #277 ships, the app shows what the server reports and offers no credit for those notes. It doesn't work out its own figure.
- **The "only with balance" list misreports its count (server defect).** mbe-api#278 drops notes after paging, so pages come back short or empty while the count still includes every note. The screen must not stop at an empty page or show the server's count as the number of open notes until #278 ships.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When a POS sale for a named customer reaches the payment step, the app MUST show that customer's spendable credit-note balance. It MUST leave out notes with nothing remaining, notes cashed out at a register, and notes already applied to this sale. When that balance is zero, it MUST NOT show the credit-note option.
- **FR-002**: Spending a named customer's credit MUST apply their spendable notes oldest first. The total MUST NOT exceed, in this order of precedence, the amount the cashier entered (when they entered one), the sale's balance, and the spendable credit. Each note MUST contribute no more than its own remaining amount.
- **FR-003**: A credit-note application MUST NOT produce change.
- **FR-004**: The general-public customer's notes MUST NOT appear as a customer credit balance.
- **FR-005**: On a POS sale under the general-public customer, the cashier MUST be able to redeem a single credit note by the number printed under its ticket barcode, typed or scanned. The app MUST show the note's remaining amount before applying it.
- **FR-006**: Redeeming by number MUST refuse, with a message naming the reason, when the number matches no credit note, when the note has nothing remaining, when it was cashed out at a register, or when it is already applied to this sale.
- **FR-006a**: Redeeming by number MUST refuse a note issued to a different customer than the sale's, saying who the note belongs to. mbe-api refuses any application across customers, so a named customer's note is spent through FR-001 on their own sale, and a walk-in note only on a walk-in sale.
- **FR-007**: The app MUST NOT offer or perform credit-note redemption on a sale that is cancelled or has no balance left.
- **FR-008**: After every redemption attempt, whether it succeeded, partly succeeded or failed, the app MUST re-read the sale's balance, its applied payments, and the customer's remaining credit from the server before showing them.
- **FR-009**: A redemption MUST appear among the sale's applied payments as a credit-note payment, with the amount applied.
- **FR-010**: Users with read access to credit payments MUST be able to open a "Notas de crédito" list. Each row MUST show the customer, date, amount issued, amount remaining, and the refund and source order the note came from. Rows MUST be newest first.
- **FR-011**: The list MUST filter by customer and offer an "only with balance" toggle that keeps only notes with something remaining.
- **FR-012**: Selecting a row MUST open the backing payment on the existing payment detail screen.
- **FR-013**: The list MUST be hidden from navigation for users without read access to credit payments. A direct link MUST show the standard no-access state.
- **FR-014**: The credit-note option and redeem-by-number MUST be shown only to users who can both read credit payments and record customer payments.
- **FR-015**: Amounts issued and remaining MUST be shown exactly as the server reports them. The app MUST NOT compute its own remaining balance.

### Key Entities

- **Credit note**: store credit a refund leaves with a customer. It carries the customer, the refund and source order it came from, the date, the amount issued, and the amount remaining. It may also carry the cash session it was paid out in. The remaining amount is what is left after every active application of its backing payment.
- **Backing payment**: the customer payment, of type "credit note", that a credit note stands for. Its id is the number printed under the ticket's barcode. Spending the note means applying this payment.
- **Application**: an amount of a payment applied to one sale. A redemption is an ordinary application. It shows on the sale like any other payment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A cashier can spend a named customer's whole spendable credit on a sale with at most two actions from the payment step.
- **SC-002**: A cashier can redeem a walk-in ticket in under 30 seconds: scan or type the number, confirm.
- **SC-003**: In every acceptance scenario, the sale's balance falls by exactly the amount the credit notes' remaining amounts fall. No scenario leaves the two out of step.
- **SC-004**: No redemption ever exceeds the sale's balance or a note's remaining amount, including when two registers try to spend the same note.
- **SC-005**: For any customer, the list's issued and remaining figures match the backing payments' amounts and active applications in 100% of the notes checked.

## Assumptions

- **Redemption is POS-only.** The scoping decision placed redemption in "the existing order payment dialogs". The back-office Pedidos workspace takes no payment (spec 029 kept it to capture and confirm), so the POS payment step is the only such dialog. Adding a payment step to Pedidos would be its own feature.
- **Walk-in notes pay walk-in sales only.** Legacy let a ticket be redeemed on any order. mbe-api refuses applications across customers, and this spec follows the server rather than asking for a carve-out.
- **Ticket number = backing payment id.** That is what legacy's credit-note ticket prints under its barcode and what legacy's redeem-by-number looks up.
- **Remaining figures depend on mbe-api#277 and #278.** Until they ship, legacy notes show 0.00 remaining and can't be spent. On the dev tenant, live testing is limited to the one note that does report a balance (note 158, customer 9284, 1,025.00) and to notes the API issues itself.
- **The cashed-out rule follows legacy.** Notes carrying a cash session are not spendable. mbe-api#277 asks the server to confirm. If the server drops the rule, the app follows the server.
- **No credit-note tickets are printed.** Printing is out of scope, so a walk-in redemption relies on tickets legacy already printed or notes issued by a future refunds screen.

### Out of scope

- Issuing credit notes. Refunds issue them (roadmap#29).
- Reversing or moving an application. That is the payments editor (roadmap#26).
- CFDI (fiscal) credit notes (roadmap#56).
- Printing a credit-note ticket.
- A payment step in the back-office Pedidos workspace.
