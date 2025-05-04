CREATE OR REPLACE FUNCTION transfer(
    p_from_wallet TEXT,
    p_to_wallet TEXT,
    p_amount NUMERIC,
    p_external_id TEXT
) RETURNS VOID AS $$
DECLARE
    v_hold_exists BOOLEAN;
    v_hold_amount NUMERIC;
BEGIN
    -- Lock wallets to prevent concurrent modifications
--    PERFORM 1 FROM wallet 
--    WHERE walletid IN (p_from_wallet, p_to_wallet, '0') 
--    FOR UPDATE;

    -- Check if hold record exists with status NEW
    SELECT EXISTS (
        SELECT 1 
        FROM hold 
        WHERE external_id = p_external_id AND status = 'NEW'
    ) INTO v_hold_exists;

    IF v_hold_exists THEN
        -- Verify hold amount and status
        SELECT amount INTO v_hold_amount
        FROM hold
        WHERE external_id = p_external_id AND status = 'NEW';
--        FOR UPDATE; -- Lock the hold record

        IF v_hold_amount IS NULL THEN
            RAISE EXCEPTION 'Hold record with external_id % and status NEW not found', p_external_id;
        END IF;

        -- Step 1: Transfer from wallet '0' to from_wallet
        UPDATE wallet
        SET deposit = deposit - v_hold_amount
        WHERE walletid = '0'
        AND deposit >= v_hold_amount; -- Ensure sufficient funds

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Insufficient funds in wallet 0 for external_id %', p_external_id;
        END IF;

        UPDATE wallet
        SET deposit = deposit + v_hold_amount
        WHERE walletid = p_from_wallet;

        -- Update hold status to COMPLETED
        UPDATE hold
        SET status = 'COMPLETED'
        WHERE external_id = p_external_id;

        -- Pause for 100ms (use with caution due to concurrency risks)
        PERFORM pg_sleep(5.0); -- 100ms

        -- Step 2: Transfer from from_wallet to to_wallet
        UPDATE wallet
        SET deposit = deposit - p_amount
        WHERE walletid = p_from_wallet
        AND deposit >= p_amount; -- Ensure sufficient funds

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Insufficient funds in wallet % for external_id %', p_from_wallet, p_external_id;
        END IF;

        UPDATE wallet
        SET deposit = deposit + p_amount
        WHERE walletid = p_to_wallet;

        -- Log the transaction
        INSERT INTO transaction (external_id, from_wallet, to_wallet, amount)
        VALUES (p_external_id, p_from_wallet, p_to_wallet, p_amount);

    ELSE
        -- Direct transfer from from_wallet to to_wallet
        UPDATE wallet
        SET deposit = deposit - p_amount
        WHERE walletid = p_from_wallet
        AND deposit >= p_amount; -- Ensure sufficient funds

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Insufficient funds in wallet % for external_id %', p_from_wallet, p_external_id;
        END IF;

        UPDATE wallet
        SET deposit = deposit + p_amount
        WHERE walletid = p_to_wallet;

        -- Log the transaction
        INSERT INTO transaction (external_id, from_wallet, to_wallet, amount)
        VALUES (p_external_id, p_from_wallet, p_to_wallet, p_amount);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Roll back all changes on error
        RAISE EXCEPTION 'Transfer failed for external_id %: %', p_external_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON FUNCTION transfer IS 'Transfers funds between wallets, optionally using a hold record. Atomic within a transaction.';