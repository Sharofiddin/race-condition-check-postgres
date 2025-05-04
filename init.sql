CREATE TABLE wallet (
    walletid TEXT PRIMARY KEY,
    deposit NUMERIC NOT NULL CHECK (deposit >= 0)
);

CREATE TABLE hold (
    external_id TEXT PRIMARY KEY,
    amount NUMERIC NOT NULL CHECK (amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('NEW', 'COMPLETED'))
);

CREATE TABLE transaction (
    external_id TEXT PRIMARY KEY,
    from_wallet TEXT NOT NULL REFERENCES wallet(walletid),
    to_wallet TEXT NOT NULL REFERENCES wallet(walletid),
    amount NUMERIC NOT NULL CHECK (amount >= 0)
);