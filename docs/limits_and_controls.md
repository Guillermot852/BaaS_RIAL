# Limits and Controls

## Purpose

Limits and controls prevent unsafe or unauthorized financial actions
from being executed, even if they are technically valid.

They serve as a risk-management layer that protects users, the platform,
and external partners.

---

## Definition

Limits and controls are pre-execution checks applied to financial
transactions before any ledger entries are written.

If a limit or control is violated, the transaction is rejected and no
financial state is changed.

---

## Scope

Limits and controls apply to all financial actions that move funds,
including transfers, deposits, and withdrawals.

They do not apply to read-only operations or balance inspection.

---

## User-Level Controls

### KYC Gating

Only users with an approved KYC status may initiate financial
transactions.

Users in pending or rejected states are blocked from moving funds.

---

### Per-Transaction Limits

Individual transactions may not exceed a configured maximum amount.

This protects against accidental large transfers and abuse.

---

### Volume Limits

Users may be subject to rolling volume limits, such as daily or weekly
caps on transferred amounts.

These limits are evaluated using aggregated ledger data.

---

## Wallet-Level Controls

### Wallet Status

Only wallets in an active state may participate in financial
transactions.

Frozen wallets are prevented from sending or receiving funds.

---

## Balance Controls

### Sufficient Funds

Before execution, the system verifies that the source ledger account has
sufficient available balance to cover the transaction amount.

Balances are computed from ledger entries.

---

## Platform-Level Controls

Platform-wide limits may restrict total exposure or daily outflows to
manage liquidity and operational risk.

These controls are evaluated using platform ledger accounts.

---

## Enforcement Model

Limits and controls are enforced in the service layer before transaction
execution.

They are evaluated using read-only queries within the same database
transaction as execution to ensure consistency.

---

## Failure Behavior

When a limit or control is violated:

- the transaction is not created
- no ledger entries are written
- an explicit error is returned

This prevents partial execution and preserves audit clarity.

---

## Design Rationale

This model ensures:

- prevention of catastrophic or abusive behavior
- clear separation between policy and accounting
- flexibility to evolve risk rules without modifying ledger logic
- alignment with standard fintech risk practices
