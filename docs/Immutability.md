# Immutability

## Purpose

Immutability ensures that historical financial data cannot be altered or
deleted once recorded.

In a financial system, correctness depends not only on producing the
right result, but on preserving an accurate and complete history of how
that result was produced.

---

## Definition

A record is considered immutable if, once created, it is never modified
or deleted.

Corrections and adjustments are performed by adding new records rather
than altering existing ones.

---

## Immutable Data

The following data is considered strictly immutable:

- Ledger entries
- Completed transactions

These records represent historical financial facts and must never be
changed after creation.

---

## Conditionally Mutable Data

Some records represent system state rather than historical facts and may
change in controlled ways:

- Transactions (status transitions only)
- Wallets (status changes such as active or frozen)
- Users (KYC and account lifecycle status)

Such changes must preserve historical correctness and auditability.

---

## Ledger Entries

Ledger entries are append-only.

They must never be updated or deleted under any circumstances.

If a mistake occurs, the system records compensating ledger entries as
part of a new transaction, preserving the original history.

---

## Transactions

Transactions represent business intent and progress through a lifecycle.

Once a transaction reaches a completed state, it becomes immutable.

Reversals or corrections are handled by creating new transactions rather
than modifying existing ones.

---

## Database Enforcement

Where possible, immutability is enforced at the database level using
constraints and triggers.

However, immutability is primarily a system-level guarantee enforced
through design, application logic, and operational discipline.

---

## Design Rationale

Immutability provides:

- auditability and traceability
- resistance to silent data corruption
- clear reconstruction of balances over time
- alignment with accounting best practices

This approach is standard in production financial systems.
