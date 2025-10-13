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

**Where is a PostgreSQL function stored?**

- When we create a function in PostgreSQL (using CREATE FUNCTION), the function definition is stored in PostgreSQL’s system catalog tables.

- Specifically, functions are stored in the table pg_proc (procedure/function metadata).

- Any SQL or procedural language (PL/pgSQL, PL/Python, PL/Perl, etc.) function we write is compiled/interpreted and stored in the database itself, not in a file on disk like in traditional programming.

**How is a function executed?**

- When we call the function (e.g., SELECT my_function(123); or CALL my_procedure();), PostgreSQL’s executor looks up the function definition from pg_proc.

- If it’s a SQL function → it substitutes and runs the SQL statements defined inside.

- If it’s a PL/pgSQL function → it runs inside PostgreSQL’s built-in PL/pgSQL interpreter.

- If it’s an extension language function (like PL/Python) → PostgreSQL hands control over to that language’s interpreter, which is integrated with PostgreSQL.

26. Write a function that calculates discounted price given product_id and discount %.

```
CREATE OR REPLACE FUNCTION calculate_discount(id INT, percent REAL)
RETURNS REAL
LANGUAGE plpgsql
AS
$$
DECLARE
    original_price REAL;
    discounted_price REAL;
BEGIN
    SELECT price
    INTO original_price
    FROM products
    WHERE product_id = id;

    discounted_price := original_price - (original_price * percent / 100);

    RETURN discounted_price;
END;
$$;

SELECT  calculate_discount(1, 10);

SELECT
    p.product_id,
    p.product_name,
    p.price,
    calculate_discount(p.product_id, 25) AS discounted_price
FROM products p;

--- TO DROP: DROP FUNCTION IF EXISTS calculate_discount(INT, REAL);
```

Self Returning function

```
CREATE OR REPLACE FUNCTION get_all_discounts(percent NUMERIC)
RETURNS TABLE (
    product_id INT,
    original_price NUMERIC,
    discounted_price NUMERIC
)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
    SELECT
        p.product_id,
        p.price,
        ROUND(p.price - (p.price * percent / 100), 2)
    FROM products p;
END;
$$;
```

27. Write a procedure that archives orders older than 2022-01-01 into another table.

```
CREATE OR REPLACE PROCEDURE archive_orders(date DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Insert old orders into archive table (VALUES keyword omitted here)
    INSERT INTO orders_archive_past_2024 (order_id, customer_id, order_date)
    SELECT
            o.order_id,
            o.customer_id,
            o.order_date
    FROM orders o
    WHERE order_date < date;
END;

    -- 2. Delete from the orders table
    -- DELETE FROM orders
    -- WHERE order_date < date;
$$;
```

28. Create a function to return the number of orders per customer.

```
-- Using language plpgsql
CREATE OR REPLACE FUNCTION get_number_of_orders(p_customer_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    order_count INTEGER;
BEGIN
    SELECT COUNT(o.order_id)
    INTO order_count
    FROM orders o
    WHERE o.customer_id = p_customer_id;

    RETURN order_count;
END;
$$;

-- Using sql (don't need 'semicolon(;)' or BEGIN-END syntax)
CREATE OR REPLACE FUNCTION get_number_of_orders(p_customer_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
BEGIN
    SELECT COUNT(*)
    FROM orders o
    WHERE o.customer_id = p_customer_id;
END;
$$;

SELECT
    o.customer_id,
    get_number_of_orders(o.customer_id) AS orders
FROM orders o
GROUP BY o.customer_id,
ORDER BY o.customer_id;

-- Return table
CREATE OR REPLACE FUNCTION get_order_per_customer_table()
RETURNS TABLE(
    customer_id INT,
    order_count INT
)
LANGUAGE sql
AS
$$
    SELECT customer_id, COUNT(*)
    FROM orders
    GROUP BY customer_id
$$;

SELECT * FROM get_order_per_customer_table();
```

29. Explain the difference between a function and procedure in PostgreSQL.

**Function in postgresql**

- Return a value (scalar, record or table)
- Can be used inside SQL queries
- Are meant for computations or query encapsulation
- Can be written in SQL, PL/pgSQL, or other supported languages.
- Must have a return clause.
- Use in queries: SELECT fn()

**Procedures in postgresql**

- Do not return values directly (but can modify data, call other procedures, or return via OUT parameters/cursors)
- Cannot be used inside SQL queries (we must call them with call)
- Are meant for actions (side-effects) like inserts, updates, deletes, archives, batch jobs.
- Introduced in PostgreSQL 11.
- Use in queries: CALL proc()

30. Write a function to check if a product exists in orders (return true/false).

### Section 7: Transactions & Concurrency

31. Write a transaction to transfer 100 units from one product stock to another, ensuring atomicity.

```
START TRANSACTION;

UPDATE testproducts t
SET stock = t.stock - 20
WHERE t.testproduct_id = 1;

UPDATE testproducts t
SET stock = t.stock + 20
WHERE t.testproduct_id = 2;

-- COMMIT ONCE SURE. ONCE COMMITED CANNOT BE ROLLBACKED.
COMMIT;

-- ROLLBACK TO UNDO
ROLLBACK;
```

32. Demonstrate rollback if the transfer cannot be completed.

```
-- Begin transaction
START TRANSACTION;

-- Step 1: Deduct 100 units from Product A
UPDATE testproducts
SET stock = stock - 100
WHERE product_id = 1;

-- Step 2: Check if Product A has gone negative
-- (simulate validation)
SELECT stock FROM testproducts WHERE product_id = 1;
-- Suppose it now shows -50 ❌

-- Step 3: Since stock < 0, rollback the transaction
ROLLBACK;

-- Step 4: Verify that no changes were made
SELECT * FROM testproducts;
```

33. Explain isolation levels and give an example of phantom read.

Isolation levels control how visible the changes of one transaction are to other concurrent tarnsactions. They balance data consistency vs concurrent performance.

| Isolation Level  | Description                                          | Can See Changes from Other Transactions?                | Notes                                                         |
| ---------------- | ---------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------- |
| READ UNCOMMITTED | Reads even uncommitted changes (dirty reads)         | Yes                                                     | PostgreSQL treats this as READ COMMITTED internally           |
| READ COMMITTED   | Default                                              | Sees only committed data at the start of each statement | Non-repeatable reads and phantom reads possible               |
| REPEATABLE READ  | All statements see the same snapshot of data         | Only committed data as of transaction start             | Prevents non-repeatable reads, phantom reads may occur        |
| SERIALIZABLE     | Transactions behave as if executed one after another | No uncommitted or new rows appear                       | Prevents dirty reads, non-repeatable reads, and phantom reads |

**Phanthom Reads**

A transaction re-executes a query and sees new rows added or deleted by another commited transaction.

Example Scenario

Suppose we have a _products_ table
|id|name|stock|
|---|---|-----|
|1|Product A|50|
|2|Product B|20|

Step 1: Transaction 1 starts

```
-- Transaction 1
START TRANSACTION ISOLATION LEVEL REPETABLE READ;

SELECT * FROM products WHERE stock >= 20;
-- Result: Product A (50), Product B (20)
```

STEP 2: Transaction 2 instert a new row

```
START TRANSACTION;
INSERT INTO products (id, name, stock) VALUES (3, 'Product C', 30);
COMMIT;
```

STEP 3: Transaction 1 queries again

```
SELECT * FROM products WHERE stock >= 20;
-- Result: Product A (50), Product B (20), Product C (30)
```

New row, "Product C" appears - this is phanthom read.

How Isolation Levels affect Phanthom reads

| Level           | Phanthom Read?                                                      |
| --------------- | ------------------------------------------------------------------- |
| READ COMMITTED  | ✅ Yes                                                              |
| REPEATABLE READ | ✅ Yes (snapshot prevents old row changes, but new rows may appear) |
| SERIALIZABLE    | ❌ No                                                               |

SERIALIZABLE ensures transactions behave as if executed one after another — no phantom rows ever appear.

🔹 Key Takeaways

- Isolation levels control how transactions see each other’s changes.

- Phantom reads happen when new rows appear or disappear between queries inside the same transaction.

- SERIALIZABLE is the only level that completely prevents phantom reads.

🔹 Why Isolation Levels Matter in Real Life?

Databases often handle many users or processes at the same time.
Without proper isolation, data can get corrupted or inconsistent, which can cause real-world problems.

1️⃣ Banking / Financial Transactions

**Scenario**: Two people transfer money from the same account at the same time.

**Problem**: Without isolation, the account balance might be overdrawn or incorrectly updated.

**Solution**:

- Use REPEATABLE READ or SERIALIZABLE to prevent lost updates or phantom reads.

- Guarantees that your balance calculations are accurate.

2️⃣ E-commerce / Inventory Management

**Scenario**: Two users buy the last item of a product at the same time.

**Problem**: Stock might go negative, or multiple users “buy” the same item.

**Solution**:

- Transactions + proper isolation (e.g., SERIALIZABLE) prevent overselling.

- Phantom reads can occur if new rows are inserted (like a new product appearing during a promotion).

3️⃣ Reporting / Analytics

**Scenario**: Running a long sales report while sales data is being updated.

**Problem**: Non-repeatable reads or phantom rows can make reports inconsistent.

**Solution**:

- Use REPEATABLE READ to get a consistent snapshot of the data for the entire report.

4️⃣ Booking Systems (Hotels, Flights, Events)

**Scenario**: Two customers try to book the same seat or room at the same time.

**Problem**: Double booking can happen without proper isolation.

**Solution**:

SERIALIZABLE isolation ensures only one booking succeeds; the other gets a rollback or retry.

34. Using SAVEPOINT, partially rollback a transaction updating two orders.

```
CREATE TABLE torders (
  id SERIAL PRIMARY KEY,
  customer_id INT,
  amount NUMERIC
);
```

```
INSERT INTO torders (customer_id, amount)
VALUES (1, 200), (2, 300);
```

```
BEGIN;

-- Step 1: Update first order
UPDATE torders SET amount = amount + 50 WHERE id = 1;

-- Create a savepoint (like a checkpoint)
SAVEPOINT before_second_update;

-- Step 2: Try updating second order (suppose this fails)
UPDATE torders SET amount = amount / 0 WHERE id = 2; -- ❌ Division by zero error

-- If error occurs, rollback only to the savepoint
ROLLBACK TO SAVEPOINT before_second_update;

-- Continue safely after rollback
UPDATE torders SET amount = amount + 20 WHERE id = 2;

-- Commit the successful changes
COMMIT;
```

35. Explain how MVCC works in PostgreSQL.

MVCC = Multi-Version Concurrency Control

IT means PostgreSQL keeps multiple versions of a row in the database, so:

- Readers don't block writers and
- Writers don't block readers.

Each transaction sees a snapshot of the database as it existed when it started, even if other transactions are updating the same rows concurrently.

How it works?

Each row in PostgreSQL has two hidden system columns:

| Column | Meaning                                                      |
| ------ | ------------------------------------------------------------ |
| xmin   | The transaction ID that created this row version             |
| xmax   | The transaction ID that deleted or replaced this row version |

**Example**

Let's say we have a products table

```
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT,
  stock INT
);

INSERT INTO products (name, stock) VALUES ('Laptop', 10);
```

Transaction 1 starts:

```
BEGIN;
SELECT * FROM products;
```

It sees:

| id  | name   | stock |
| --- | ------ | ----- |
| 1   | Laptop | 10    |

Transaction 2 starts and updates:

```
BEGIN;
UPDATE products SET stock = 8 WHERE id = 1;
COMMIT;
```

Now postgres does not overwrite the old row.

It creates a new version of that row:
| id | name | stock | xmin| xmax |
| --- | ------ | ----- | ---| ---|
| 1 | Laptop | 10 | 100 | 101 |
| 1 | Laptop | 10 | 101 | null |

✅ Readers (old transactions) still see the old version (10)

✅ New readers see the new version (8)

_Note: Every transaction in PostgreSQL gets a unique transaction ID (XID) — an ever-increasing integer_

Transaction 1 continues and runs again:

```
COMMIT;
SELECT * FROM products;
```

Now it sees stock = 8 (the latest committed version).

⚙️ Internally, PostgreSQL:

- Uses transaction IDs (XIDs) to mark row visibility.

- Keeps old row versions in the heap (table) until VACUUM cleans them up.

- MVCC snapshots define what each transaction can “see.”

🔒 Why MVCC is Awesome

- No read locks (Readers don't block writes)
- No dirty reads (Readers never see uncommited data)
- Consistent snapshots (Each transcation sees a stable view of the DB)
- High consistency (Multiple users can safely read/write at once)

⚠️ Important Notes

- Old row versions accumulate → PostgreSQL uses VACUUM to clean them.

- Transaction ID wraparound can occur if you don’t vacuum often.

- MVCC plays a key role in isolation levels (especially READ COMMITTED and REPEATABLE READ).

🔍 Real-Life Analogy

Imagine a Google Docs history:

- Each edit creates a new version of the document.

- We can open the doc as it was 5 minutes ago (snapshot).

- Other users can keep editing newer versions.

That’s exactly what PostgreSQL does with rows!

### Section 8: Constraints & Data Integrity

36. Add a foreign key constraint from products.category_id → categories.category_id.

```
ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category_id)
REFERENCES categories(category_id);
```

37. Add a unique constraint on customers(contact_name, city).

```
ALTER TABLE customers
ADD CONSTRAINT unique_contact_city
UNIQUE(contact_name, city);
```

38. Modify the orders table to disallow NULL customer_id.

```
ALTER TABLE orders
ALTER COLUMN customer_id SET NOT NULL;
```

39. Add a CHECK constraint that product price > 0.

```
ALTER TABLE products
ADD CONSTRAINT check_price_positive
CHECK (price > 0);
```

40. Explain how deferred constraints work with an example

In PostgreSQL, a deferred constraint is a constraint (like foreign key, unique, or check) that is not enforced immediately when a statement runs, but instead checked at the end of the transaction.

Normally, constraints are immediate, meaning PostgreSQL checks them after each SQL statement.

With deferred constraints, you can temporarily violate the constraint within a transaction as long as the final state of the data (when you commit) satisfies the constraint.

ex:

```
CREATE TABLE parent (
    id SERIAL PRIMARY KEY,
    name TEXT
);

CREATE TABLE child (
    id SERIAL PRIMARY KEY,
    parent_id INT,
    CONSTRAINT fk_parent FOREIGN KEY (parent_id)
        REFERENCES parent(id) DEFERRABLE INITIALLY DEFERRED
);
```

**How it works**

1. Start the transaction

```
BEGIN;
```

2. Insert a child row that references a parent row later in the transaction

```
INSERT INTO child (id, parent_id) VALUES (1, 100);
```

3. Insert the corresponding parent row later in the transaction:

```
INSERT INTO parent (id, name) VALUES (100, 'Alice');
```

4. Commit the transaction:

```
COMMIT;
```

### SECTION 9: Extras

41. Delete duplicates from order table.

````

```

```
````
