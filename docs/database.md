# Database Design

## Overview

The database is designed to support a fintech-style system where:
- users own wallets
- wallets define currency context
- money movements are recorded via a ledger (double-entry)

The database is the source of truth for all financial state.

---

## Users Table

The `users` table represents end users of the system.

### Responsibilities
- Identity and authentication reference
- KYC status tracking
- Account lifecycle status

### Key Fields
- user_id (UUID, primary key)
- email (unique)
- phone (optional, unique)
- kyc_status (pending, approved, rejected)
- status (active, suspended, closed)

### Notes
- Passwords are stored only as secure hashes
- No financial data is stored on the user record

---

## Wallets Table

The `wallets` table represents a logical container for funds.

### Responsibilities
- Associate a user with a currency
- Provide a freeze control mechanism
- Act as a parent for ledger accounts

### Key Design Decisions
- Wallets do NOT store balances
- One wallet per user per currency
- USD-only enforced via constraint

### Relationships
- wallets.user_id → users.user_id (FK)

---

## Ledger Accounts Table

Ledger accounts represent accounting entities used for double-entry bookkeeping.

They do not store balances directly. All monetary state is derived from
ledger entries.

Account types:
- user_wallet
- platform_revenue
- platform_clearing
- baas_custody
- suspense

---

## Transactions

Transactions represent business-level financial events.

They group one or more ledger entries and define the lifecycle
of a financial action (pending, completed, failed).

Transactions do not store accounting state directly.

---

## Ledger Entries

The `ledger_entries` table represents atomic accounting movements within the system.
It is the foundation of the internal double-entry bookkeeping model.

Each ledger entry:
- belongs to exactly one transaction
- applies to exactly one ledger account
- represents either a debit or a credit
- is immutable once created

Ledger entries do not store balances.
All balances are derived by aggregating ledger entries over time.

## Purpose

The purpose of ledger entries is to provide:
- a complete audit trail of all monetary movements
- strong accounting guarantees
- the ability to reconstruct balances at any point in time

This design follows standard double-entry accounting principles used in
production financial systems.

## Key Fields

- **entry_id** 
  Unique identifier for the ledger entry.

- **transaction_id** 
  References the transaction that caused the accounting movement.
  All ledger entries with the same transaction_id together represent
  a single business action.

- **account_id** 
  References the ledger account affected by this entry.

- **direction** 
  Indicates whether the entry is a debit or a credit.
  Amounts are always stored as positive values; the direction determines
  how the entry affects balances.

- **amount** 
  The monetary amount of the entry.
  Must always be greater than zero.

- **created_at** 
  Timestamp indicating when the entry was recorded.
  Ledger entries are append-only and never updated.

## Accounting Invariant

For every completed transaction, the following invariant must hold:

> The sum of all debit amounts equals the sum of all credit amounts.

This invariant is enforced at the application level by ensuring that
ledger entries are always written in balanced pairs (or sets) within
a single database transaction.

## Relationship to Other Tables

- `ledger_entries.transaction_id` → `transactions.transaction_id`
- `ledger_entries.account_id` → `ledger_accounts.account_id`

The `transactions` table represents business intent,
while `ledger_entries` represent the accounting consequences of that intent.

## Balance Calculation

Balances are not stored in the database.
They are computed dynamically by aggregating ledger entries:

- credits increase a balance
- debits decrease a balance

This approach ensures consistency, auditability, and resistance to
data corruption.

