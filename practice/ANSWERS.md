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

### Section 2: Aggregates & Grouping

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

### Section 3: Joins & Subqueries

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

```
--- Using Joining
SELECT c.customer_id, c.customer_name
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

--- Using Subquery
SELECT customer_id, customer_name
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);
```

13. Retrieve all orders along with total order value.

```
--- Using Joining
SELECT
    o.order_id,
    SUM(od.quantity * p.price) AS total_order_value
FROM order_details AS od
LEFT JOIN orders AS o
    ON o.order_id = od.order_id
LEFT JOIN products as p
    ON od.product_id = p.product_id
GROUP BY o.order_id
ORDER BY o.order_id;

--- Using Subquery + Joining (At least one join nedded)
SELECT
    od.order_id,
    SUM(newt.price * od.quantity) AS total_order_value
FROM order_details AS od
LEFT JOIN (
    SELECT product_id, price
    FROM products
    WHERE product_id IN
        ( SELECT product_id FROM order_details)
) AS newt
ON newt.product_id = od.product_id
GROUP BY order_id
ORDER BY order_id;

```

14. Find products that appear in more than 20 orders.

```
SELECT p.product_name, od.product_id, COUNT(od.product_id) AS cnt FROM order_details AS od
LEFT JOIN products AS p
ON p.product_id = od.product_id
GROUP BY p.product_name, od.product_id
HAVING COUNT(od.product_id) > 20
ORDER BY cnt;
```

15. List customers who ordered half the products from categroy_id = 2

```
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
```

### Section 4: Advanced Queries

16. Find the second most expensive product

```
SELECT price
FROM products
ORDER BY price DESC
LIMIT 1 OFFSET 1;
```

17. Get the latest order for each customer.

```
SELECT
    o.customer_id,
    c.customer_name,
    MAX(o.order_date)
FROM orders o
LEFT JOIN customers c
    ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name
ORDER BY o.customer_id;
```

18. List products whose price is higher than at least 50% of other products.

```
-- Using window function
SELECT *
FROM (
    SELECT *, NTILE(2) OVER (ORDER BY price) AS half
    FROM products
) AS t
WHERE half = 2;


-- Using a subquery for median price
SELECT *
FROM products
WHERE price > (
    SELECT PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY price)
    FROM products
)
ORDER BY price DESC;


-- Using Subquery with Limit
SELECT *
FROM products
ORDER BY price DESC
LIMIT (
    SELECT COUNT(*)
    FROM products
) / 2;
```

19. Find customers whose total order quantity exceeds 100 units.

```
SELECT
    o.customer_id,
    SUM(od.quantity) AS sum
FROM orders o
LEFT JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY o.customer_id
HAVING SUM(od.quantity) > 100
ORDER BY o.customer_id;
```

### Section 5: Views, Indexes & Sequences

21. Create a view showing customer_name, total_orders, total_spent.

22. Create an index on orders(order_date) and explain how it improves performance.

23. Create a sequence for order_detail_id and use it in an insert statement.

24. Drop a view named vw_customer_summary.

25. Explain the difference between B-Tree and Hash indexes with examples.

### Section 6: Functions & Procedures

26. Write a function that calculates discounted price given product_id and discount %.

27. Write a procedure that archives orders older than 2024-01-01 into another table.

28. Create a function to return the number of orders per customer.

29. Explain the difference between a function and procedure in PostgreSQL.

30. Write a function to check if a product exists in orders (return true/false).

### Section 7: Transactions & Concurrency

31. Write a transaction to transfer 100 units from one product stock to another, ensuring atomicity.

32. Demonstrate rollback if the transfer cannot be completed.

33. Explain isolation levels and give an example of phantom read.

34. Using SAVEPOINT, partially rollback a transaction updating two orders.

35. Explain how MVCC works in PostgreSQL.
