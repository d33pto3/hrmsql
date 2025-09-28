--- using EXCEPT
SELECT * 
FROM testproducts
WHERE testproduct_id IN (
    SELECT testproduct_id 
    FROM testproducts
    EXCEPT
    SELECT product_id
    FROM order_details
);


--- using NOT  IN
SELECT tp.testproduct_id, tp.product_name, tp.category_id
FROM testproducts tp
WHERE tp.testproduct_id NOT IN (
    SELECT DISTINCT od.product_id
    FROM order_details od
);

-- using LEFT JOIN
SELECT 
    tp.testproduct_id, 
    tp.product_name, 
    tp.category_id
FROM testproducts tp
LEFT JOIN order_details od
    ON tp.testproduct_id = od.product_id
WHERE od.product_id IS NULL;
