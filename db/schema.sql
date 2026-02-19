-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =========================
-- USERS
-- =========================

CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    email TEXT NOT NULL UNIQUE,
    phone TEXT UNIQUE,

    password_hash TEXT NOT NULL,

    kyc_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (kyc_status IN ('pending', 'approved', 'rejected')),

    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'suspended', 'closed')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- updated_at trigger for users
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS users_updated_at_trigger ON users;

CREATE TRIGGER users_updated_at_trigger
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================
-- WALLETS
-- =========================

CREATE TABLE IF NOT EXISTS wallets (
    wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    currency CHAR(3) NOT NULL DEFAULT 'USD'
        CHECK (currency = 'USD'),

    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'frozen')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One wallet per user per currency
CREATE UNIQUE INDEX IF NOT EXISTS unique_user_currency_wallet
ON wallets (user_id, currency);

-- =========================
-- LEDGER ACCOUNTS
-- =========================

CREATE TABLE IF NOT EXISTS ledger_accounts (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID
        REFERENCES wallets(wallet_id)
        ON DELETE CASCADE,

    account_type TEXT NOT NULL
        CHECK (account_type IN (
            'user_wallet',
            'platform_revenue',
            'platform_clearing',
            'baas_custody',
            'suspense'
        )),

    currency CHAR(3) NOT NULL DEFAULT 'USD'
        CHECK (currency = 'USD'),

    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'frozen')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One ledger account per wallet per type
CREATE UNIQUE INDEX IF NOT EXISTS unique_wallet_account_type
ON ledger_accounts (wallet_id, account_type)
WHERE wallet_id IS NOT NULL;

-- One platform revenue account per currency
CREATE UNIQUE INDEX IF NOT EXISTS unique_platform_revenue_account
ON ledger_accounts (account_type, currency)
WHERE account_type = 'platform_revenue';

-- One BaaS custody account per currency
CREATE UNIQUE INDEX IF NOT EXISTS unique_baas_custody_account
ON ledger_accounts (account_type, currency)
WHERE account_type = 'baas_custody';

-- =========================
-- LEDGER ENTRIES
-- =========================

CREATE TABLE IF NOT EXISTS ledger_entries (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    transaction_id UUID NOT NULL,

    account_id UUID NOT NULL
        REFERENCES ledger_accounts(account_id),

    direction TEXT NOT NULL
        CHECK (direction IN ('debit', 'credit')),

    amount NUMERIC(18,2) NOT NULL
        CHECK (amount > 0),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_transaction
ON ledger_entries (transaction_id);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_account
ON ledger_entries (account_id);

