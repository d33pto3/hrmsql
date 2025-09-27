SELECT c.customer_id, COUNT(DISTINCT p.product_id) FROM orders AS o
LEFT JOIN order_details AS od
    ON o.order_id = od.order_id
LEFT JOIN products AS p
    ON p.product_id = od.product_id
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE p.category_id = 2
GROUP BY c.customer_id
HAVING COUNT(DISTINCT p.product_id) >= (
    SELECT (COUNT(*) / 2)
    FROM products
    WHERE category_id = 2
)
ORDER BY c.customer_id;


SELECT customer_name FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders
WHERE order_id IN (
SELECT order_id FROM order_details
WHERE product_id IN(
    SELECT product_id FROM products 
    WHERE category_id = 2
)
));


SELECT DISTINCT c.customer_name FROM orders AS o
LEFT JOIN order_details AS od
    ON o.order_id = od.order_id
LEFT JOIN products AS p
    ON p.product_id = od.product_id
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE p.category_id = 2
ORDER BY c.customer_name;