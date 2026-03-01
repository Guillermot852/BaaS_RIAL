# Execution Flows

## Overview

The execution flows demonstrates in which order things(transactions) occur within the database. 

## Execution Flow 1: Internal Transfer (User → User)

### Scenario

- User A sends $10 to User B
- Both users have USD wallets
- Both wallets have a user_wallet ledger account

### Preconditions (must already be true)

- Sender wallet exists and is active
- Receiver wallet exists and is active
- Sender ledger account exists
- Receiver ledger account exists
- Sender has sufficient balance (computed from ledger entries)

If any of these fail → abort before writing anything

### Step-by-step execution (this is the core)

#### Begin Database Transaction
BEGIN;

#### Create Transactions Record
INSERT INTO transactions (
    transaction_type,
    amount,
    currency,
    status
)
VALUES (
    'internal_transfer',
    10.00,
    'USD',
    'pending'
)
RETURNING transaction_id;

#### Write Ledger Entries
-- Debit sender
INSERT INTO ledger_entries (
    transaction_id,
    account_id,
    direction,
    amount
)
VALUES (
    :tx_id,
    :sender_account_id,
    'debit',
    10.00
);
-- Credit receiver
INSERT INTO ledger_entries (
    transaction_id,
    account_id,
    direction,
    amount
)
VALUES (
    :tx_id,
    :receiver_account_id,
    'credit',
    10.00
);

#### Mark Transactions as completed
UPDATE transactions
SET status = 'completed',
    completed_at = now()
WHERE transaction_id = :tx_id;

### Commit database transaction
COMMIT;
- Only at this point does this transaction officially exist

### Failure Handling
ROLLBACK;
