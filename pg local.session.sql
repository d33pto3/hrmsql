SELECT * FROM orders AS o
LEFT JOIN order_details AS od
    ON o.order_id = od.order_id;