# Database Design

## Overview

The database is designed to support a fintech system where:

- users represent the identity and lifecycle state of system participants
- wallets represent user-owned fund containers scoped to a specific currency
- ledger accounts represent internal accounting entities used for bookkeeping
- ledger entries record all monetary changes using double-entry accounting

The database is the authoritative source of truth for all financial state.
No balances are stored directly; all balances are derived from ledger data.

---

## Users

### Purpose

The `users` table represents end users of the system.

### Responsibilities

- Store identity and authentication references
- Track KYC status
- Track account lifecycle state

### Key Design Decisions

- Passwords are stored only as secure hashes
- No financial data is stored at the user level
- User state is separated from financial state

### Relationships

- A user may own one or more wallets

---

## Wallets

### Purpose

The `wallets` table represents a logical container that associates a user
with a specific currency.

### Responsibilities

- Define ownership of funds
- Define currency context
- Provide a control point for freezing activity
- Act as the parent entity for user ledger accounts

### Key Design Decisions

- Wallets do **not** store balances
- One wallet per user per currency
- Currency is constrained to USD
- Wallets are structural, not accounting entities

### Relationships

- `wallets.user_id` → `users.user_id`
- A wallet may be associated with one or more ledger accounts

---

## Ledger Accounts

### Purpose

The `ledger_accounts` table represents accounting entities used for
double-entry bookkeeping.

Ledger accounts are where money conceptually “lives” in the system.

### Responsibilities

- Represent user and platform accounting entities
- Serve as targets for ledger entries
- Define accounting boundaries between users and the platform

### Key Design Decisions

- Ledger accounts do not store balances
- Balances are derived exclusively from ledger entries
- Some ledger accounts are associated with wallets, others are platform-level

### Account Types

- `user_wallet` — user-owned wallet account
- `platform_revenue` — platform income
- `platform_clearing` — internal clearing account
- `baas_custody` — mirror of funds held by the BaaS provider
- `suspense` — holding account for errors or investigations

### Relationships

- `ledger_accounts.wallet_id` → `wallets.wallet_id` (nullable)
- Ledger accounts are referenced by ledger entries

---

## Transactions

### Purpose

The `transactions` table represents business-level financial events.

A transaction expresses *intent*, not accounting state.

### Responsibilities

- Represent financial actions such as transfers, deposits, or withdrawals
- Track transaction lifecycle (pending, completed, failed, reversed)
- Group ledger entries that belong to the same business event
- Support idempotency and auditability

### Key Design Decisions

- Transactions do not store debits or credits
- Transactions do not store balances
- Ledger entries are the accounting consequences of transactions

### Relationships

- A transaction may be associated with one or more ledger entries

---

## Ledger Entries

### Purpose

The `ledger_entries` table represents atomic accounting movements.
It is the foundation of the internal double-entry bookkeeping system.

### Responsibilities

- Record all monetary movements
- Provide a complete audit trail
- Enable balance reconstruction at any point in time

### Key Design Decisions

- Ledger entries are immutable and append-only
- Amounts are always positive; direction determines sign
- Balances are never stored directly

### Entry Semantics

Each ledger entry:

- belongs to exactly one transaction
- applies to exactly one ledger account
- represents either a debit or a credit

### Accounting Invariant

For every completed transaction, the following invariant must hold:

> The sum of all debit amounts equals the sum of all credit amounts.

This invariant is enforced at the application level by writing balanced
sets of ledger entries within a single database transaction.

### Relationships

- `ledger_entries.transaction_id` → `transactions.transaction_id`
- `ledger_entries.account_id` → `ledger_accounts.account_id`

### Balance Calculation

Balances are computed dynamically by aggregating ledger entries:

- credits increase balances
- debits decrease balances

This approach ensures auditability, consistency, and resistance to data corruption.

### Idempotency

Transactions may include an optional `idempotency_key`, which uniquely
identifies a specific financial intent.

The database enforces a uniqueness constraint on the idempotency key,
ensuring that at most one transaction exists for a given intent.

Idempotency semantics and retry behavior are defined at the execution
layer and documented at Idempotency.md.

### Immutability

Ledger entries are immutable and append-only. Updates or deletions are
not permitted.

### Reversals

Transactions may reference a related transaction to support reversals
and refunds without modifying historical data.

### Reconciliations

Suspense accounts are used to isolate funds involved in unresolved
reconciliation discrepancies.
