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

