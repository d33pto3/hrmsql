ROLLBACK;
SELECT * FROM testproducts ORDER BY testproduct_id;

-- START TRANSACTION;

-- UPDATE testproducts t
-- SET stock = t.stock - 20
-- WHERE t.testproduct_id = 1;

-- UPDATE testproducts t
-- SET stock = t.stock + 20
-- WHERE t.testproduct_id = 2;

-- COMMIT;