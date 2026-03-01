# Idempotency

## Purpose

Idempotency ensures that retrying the same financial intent does not
result in duplicate money movements.

In a financial system, clients may retry requests due to timeouts,
network failures, or crashes. The system must guarantee that executing
the same intent multiple times has the same effect as executing it once.

---

## Definition

An operation is considered idempotent if repeated execution of the same
financial intent results in at most one completed transaction.

Idempotency is defined at the transaction level, not at the request or
API level.

---

## Idempotency Key

Each financial transaction may include an `idempotency_key`, which
uniquely identifies a specific financial intent.

The idempotency key is supplied by the client or calling service and must
remain stable across retries of the same intent.

Examples of idempotency keys include:
- client-generated UUIDs
- deterministic hashes of transaction intent
- request identifiers from upstream systems

---

## Database Enforcement

The `transactions` table enforces idempotency using a unique constraint
on the `idempotency_key` field.

This guarantees that at most one transaction may exist for a given
idempotency key.

The database serves as the final safeguard against duplicate execution.

---

## Idempotent Execution Flow

When processing a financial request with an idempotency key, the system
follows this flow:

1. Begin a database transaction.
2. Check for an existing transaction with the same idempotency key.
3. If no transaction exists:
   - create a new transaction record
   - write the corresponding ledger entries
   - mark the transaction as completed
4. If a completed transaction exists:
   - do not execute the operation again
   - return the existing transaction result
5. If a pending transaction exists:
   - do not execute the operation again
   - return a processing or retry-safe response
6. Commit or rollback the database transaction.

At no point should the same idempotency key result in multiple sets of
ledger entries.

---

## Failure Handling

If execution fails after the transaction record is created but before
completion, the transaction remains in a failed or pending state.

The idempotency key is considered consumed and must not be reused for a
new financial intent.

Clients must generate a new idempotency key for subsequent attempts.

---

## Design Rationale

Idempotency is enforced at the transaction layer to ensure:

- safety under retries and partial failures
- prevention of duplicate money movements
- clear auditability of financial intent
- separation between client behavior and accounting correctness

This approach follows patterns used in production financial systems.
