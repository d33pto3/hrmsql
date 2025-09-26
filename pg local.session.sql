--- Using Joining
SELECT c.customer_id, c.customer_name
FROM customers AS c
LEFT JOIN orders AS o 
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

--- Using Subquery
SELECT customer_id, customer_name FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);

