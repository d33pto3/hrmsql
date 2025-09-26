### Section 1: Basic Queries & Operators

1.

```
SELECT * FROM customers
WHERE country IN ('USA', 'Canada') AND
postal_code LIKE '9%';
```

2.

```
SELECT * FROM products
WHERE price > (
    SELECT  AVG(price) FROM products
);
```

3.

```
SELECT orders.order_id, customers.customer_name FROM orders
LEFT JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.order_date BETWEEN '2023-01-01' AND '2023-06-30'
AND customers.city = 'London';
```

4.

```
SELECT * FROM categories
WHERE category_name NOT ILIKE '%food%';
```

5.

```
SELECT * FROM products
WHERE price % 10 = 0
AND
unit ILIKE '%kg%';
```

6.

```
SELECT DISTINCT customer_id, COUNT(order_id) FROM orders
GROUP BY customer_id ORDER BY count desc;
```

7.

```
SELECT category_id, ROUND(AVG(price), 2) FROM products
GROUP BY category_id ORDER BY category_id;
```

8.

```
SELECT customer_id, COUNT(order_id) AS count FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 5
ORDER BY count;
```

9.

```
SELECT products.product_id, SUM(order_details.quantity * products.price) as revenue FROM order_details
LEFT JOIN products ON order_details.product_id = products.product_id
GROUP BY products.product_id
ORDER BY products.product_id;
```

10.

```
SELECT category_id, count FROM
    (SELECT category_id, COUNT(product_id) FROM products
    GROUP BY category_id
    ORDER BY count desc)
LIMIT 1;
```

11.

- Using subquery

```
SELECT product_name FROM products
WHERE product_id IN (
    SELECT product_id FROM order_details
    WHERE order_id IN (
        SELECT order_id FROM orders
        WHERE customer_id IN (
            SELECT customer_id FROM customers
            WHERE customer_name ILIKE '%fran%'
        )
    )
) ORDER BY product_name;
```

--- Using Joining (better approach)

```
SELECT DISTINCT p.product_name FROM products AS p
LEFT JOIN order_details AS od ON p.product_id = od.product_id
LEFT JOIN orders AS o ON o.order_id = od.order_id
LEFT JOIN customers AS c ON c.customer_id = o.customer_id
WHERE c.customer_name ILIKE '%fran%'
ORDER BY p.product_name;
```

12.
