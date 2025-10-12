-- BEGIN;

-- UPDATE torders SET amount = amount + 50 WHERE id = 1;

-- SAVEPOINT before_second_update;

-- UPDATE torders SET amount = amount / 0 WHERE id = 2;

-- ROLLBACK TO SAVEPOINT before_second_update;

-- UPDATE torders SET amount = amount + 20 WHERE id = 2;

-- COMMIT;

SELECT * FROM torders;