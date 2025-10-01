SELECT * FROM orders_archive_past_2024
ORDER BY order_id;

-- DELETE FROM orders_archive_past_2024
-- WHERE order_id NOT IN(
--     SELECT MIN(order_id)
--     FROM orders_archive_past_2024
--     GROUP BY customer_id, order_date
-- );