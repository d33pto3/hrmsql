SELECT 
    o.customer_id, 
    SUM(od.quantity) AS sum
FROM orders o
LEFT JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY o.customer_id
HAVING SUM(od.quantity) > 100
ORDER BY o.customer_id;