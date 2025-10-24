START TRANSACTION;

-- 1. Check if account A has enough balance
SELECT balance INTO @balance FROM accounts WHERE id = 'A';

-- 2. If not enough balance, roll back
IF @balance < 100 THEN
    ROLLBACK;
ELSE
    -- 3. Deduct 100 from account A
    UPDATE accounts
    SET balance = balance - 100
    WHERE id = 'A';

    -- 4. Add 100 to account B
    UPDATE accounts
    SET balance = balance + 100
    WHERE id = 'B';

    -- 5. Record the transaction
    INSERT INTO transactions (from_account_id, to_account_id, amount)
    VALUES ('A', 'B', 100);

    -- 6. Commit the transaction
    COMMIT;
END IF;
