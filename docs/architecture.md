# System Architecture Overview

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

## Core Design Principles

1. Database-first design
2. Money is represented via ledger entries, not balances
3. Wallets are containers, not accounts
4. Strong referential integrity and auditability
5. Separation between internal state and external banking rails
