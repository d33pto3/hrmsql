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

20. List products never ordered but present in the testproducts table.

```
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

```

### Section 5: Views, Indexes & Sequences

21. Create a view showing customer_name, total_orders, total_spent.

```
CREATE VIEW
customer_orders
AS
SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(od.quantity) AS total_product_purchased,
    SUM(od.quantity * p.price) AS total_spent
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN order_details od
    ON o.order_id = od.order_id
LEFT JOIN products p
    ON p.product_id = od.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

```

22. Create an index on orders(order_date) and explain how it improves performance.

```
CREATE INDEX idx_orders_order_date
ON orders(order_date);
```

- An index is like a "lookup table" that the db builds to speed up searches
- Internally RDBMS implement indexes using a B-tree.
- W/o the index
  - The db must scan the entire order table (sequential scan)
- With the index
  - The db looks into the B-tree index on order_date
  - It jumps directly to rows matching date or range
  - Sorting by order_date also becomes faster because the index is already ordered

23. Create a sequence for order_detail_id and use it in an insert statement.

```
CREATE SEQUENCE order_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE order_id_seq
    START WITH 10000
    INCREMENT BY 1
    MINVALUE 10000
    NO MAXVALUE
    CACHE 1;

CREATE TABLE order_details_dup (
    order_detail_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL
);

INSERT INTO order_details_dup
(
    order_detail_id,
    order_id,
    product_id,
    quantity
) VALUES (
    nextval('order_detail_id_seq'),
    nextval('order_id_seq'),
    201,
    10
);

SELECT * FROM order_details_dup;
```

24. Drop a view named vw_customer_summary.

```
DROP VIEW IF EXISTS vw_customer_summary; --- If exists

DROP VIEW vw_customer_summary CASCADE; --- If the VIEW is dependent on by other objects (like another VIEW) [good for dev/testing, but risky in prod]

DROP VIEW vw_customer_summary RESTRICT; --- If we want accidental drop of dependent objects
```

25. Explain the difference between B-Tree and Hash indexes with examples.

**B-TREE**

- B-tree is the default index type in most RDBMS.
- Store the data in sorted, hierarchical tree structure.
- Efficient for range queries, equality and sorting.

**How it works?**

- Each node stores key values and pointers to child nodes.
- Search is like binary search in a tree.

example scenario: Table: orders(order_id, customer_id, order_date, total_amount);

Create B-tree index:

```
CREATE INDEX idx_orders_order_date
ON orders(order_date);
```

Queries that benefit:

1. Equality check:

```
SELECT * FROM orders WHERE order_date = '2025-09-01';
```

2. Range Query:

```
SELECT * FROM orders WHERE order_date BETWEEN '2025-01-01' AND '2025-09-01';
```

3. ORDER BY:

```
SELECT * FROM orders ORDER BY order_date DESC LIMIT 10;
```

**Hash Index**

- Hash index stores data in a hash table (key->bucket).
- Very fast for equality searches (=) but not suitable for range queries (<, >, BETWEEN).

**How it works**

- The index computes a hash value for each key and stores it back in a bucket.
- Searching involves computing the hash and directly looking in the corresponding bucket.

Example scenario: Table: customers(customer_id, customer_name)

Create Hash index:

```
CREATE INDEX idx_customers_name_hash
ON customers USING HASH (customer_name);
```

Queries that benefit:

```
SELECT * FROM customers WHERE customer_name = 'Alice';
```

**_Practical_**:

- Use B-tree for almost all cases - range queries, ordering, equality checks;
- Use hash index for very frequent equality searches in a column.

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
