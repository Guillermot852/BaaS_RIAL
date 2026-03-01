# Reversals and Refunds

## Purpose

Reversals and refunds provide a mechanism to correct or compensate
financial transactions without modifying or deleting historical data.

They preserve immutability while allowing the system to handle errors,
disputes, and business-driven corrections.

---

## Core Principle

Financial history is never altered.

All corrections are performed by creating new transactions with
compensating ledger entries.

---

## Reversals

### Definition

A reversal corrects a transaction that should not have occurred due to
system error, duplication, or internal mistake.

The goal of a reversal is to neutralize the financial effect of the
original transaction.

---

### Reversal Mechanics

A reversal is implemented as a new transaction whose ledger entries are
the exact inverse of the original transaction’s ledger entries.

- debits become credits
- credits become debits
- amounts remain unchanged

The original transaction remains intact and immutable.

---

### Reversal Use Cases

- duplicate execution
- internal processing error
- failed external settlement after internal posting

---

## Refunds

### Definition

A refund compensates a transaction that occurred correctly but must be
undone for business reasons.

Refunds represent new economic events and are user-visible.

---

### Refund Mechanics

A refund is implemented as a new transaction with ledger entries that
transfer funds back to the user from the appropriate platform account.

Unlike reversals, refunds do not imply that the original transaction was
incorrect.

---

### Refund Use Cases

- user complaints
- fee reimbursements
- service-level compensation

---

## Transaction Linking

Reversals and refunds may reference the original transaction using a
`related_transaction_id`.

This creates an explicit audit trail linking corrections to their
originating events.

---

## Immutability and Auditability

Neither reversals nor refunds modify existing ledger entries or
transactions.

All historical data remains intact, allowing complete reconstruction of
account balances and transaction history at any point in time.

---

## Design Rationale

This model ensures:

- strict immutability of financial records
- clear separation between errors and business adjustments
- full auditability and traceability
- alignment with standard accounting practices

Reversals and refunds are essential components of a robust financial
system.
