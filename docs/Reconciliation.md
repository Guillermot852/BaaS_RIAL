# Reconciliation

## Purpose

Reconciliation ensures that the system’s internal ledger state matches
the external financial reality maintained by the BaaS provider.

It is a critical operational process used to detect discrepancies,
timing differences, and settlement issues without modifying historical
financial data.

---

## Definition

Reconciliation is the process of comparing internally recorded balances
and transactions with external provider statements as of a specific
point in time.

Reconciliation is a read-only process and does not mutate ledger data.

---

## Sources of Truth

- **Internal source of truth**: ledger entries and ledger accounts
- **External source of truth**: BaaS provider balances and transaction
  reports

Internal and external records are expected to converge over time but may
temporarily diverge due to settlement delays or processing differences.

---

## Reconciliation Scope

Reconciliation is performed at multiple levels:

### Balance Reconciliation

Compares internal aggregate balances (e.g. BaaS custody accounts) with
external provider balances.

### Transaction Reconciliation

Compares internal transactions with externally reported transactions to
identify missing, duplicated, or mismatched events.

### Timing Reconciliation

Accounts for differences caused by settlement delays or reporting
cutoffs.

---

## Internal Balance Calculation

Internal balances are computed by aggregating ledger entries:

- credits increase balances
- debits decrease balances

Balances are calculated as of a defined reconciliation cutoff time.

---

## Discrepancy Handling

When discrepancies are detected:

1. The discrepancy is classified (timing, missing, duplicate, mismatch).
2. The underlying cause is investigated.
3. Resolution is performed through compensating transactions,
   reversals, refunds, or operational intervention.

Historical ledger data is never modified.

---

## Suspense Accounts

Suspense ledger accounts may be used to temporarily hold funds associated
with unresolved discrepancies.

This allows the system to isolate uncertainty without affecting user
balances or historical records.

---

## Design Rationale

Reconciliation provides:

- early detection of inconsistencies
- operational visibility into settlement issues
- protection against silent financial drift
- a clear separation between detection and correction

This process is essential for operating a reliable financial system.
