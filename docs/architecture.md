# System Architecture Overview
This document describes the high-level architecture of the BaaS_RIAL backend.
The system is designed as a database-first fintech backend that supports
USD-denominated wallets, internal transfers, and future integration with
Banking-as-a-Service (BaaS) providers.

## Purpose

This project explores the design of a BaaS-style neobank backend,
focused on USD-denominated wallets and internal transfers within Venezuela.

The goal is to design a production-grade financial data model
that separates:
- user identity
- wallet ownership
- money representation
- external banking infrastructure (BaaS)

## High-Level Components

- PostgreSQL database (source of financial truth)
- Dockerized infrastructure
- Internal ledger system (double-entry, upcoming)
- BaaS partner integration (planned)

## Core Architectural Principles

1. Database-first design 
   The database is the authoritative source of truth. Application logic
   must conform to database constraints, not the other way around.

2. Separation of concerns 
   - Users represent identity
   - Wallets represent ownership and currency context
   - Ledgers represent money

3. No balance mutation 
   Account balances are derived from ledger entries, never stored directly.

4. Auditability by design
   All financial state changes must be reconstructable from historical data.

5. Clear custody boundaries 
   The system does not act as a bank and does not custody funds directly.


## Conceptual Data Model

At a high level:

- A User represents a person using the system.
- A User owns one Wallet per currency.
- A Wallet defines currency context and control (e.g. frozen state).
- Money is represented through Ledger Accounts associated with wallets.
- All monetary changes are recorded as Ledger Entries.
