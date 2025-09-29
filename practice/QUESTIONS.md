### Section 1: Basic Queries & Operators

1. Select all customers living in either 'USA' or 'Canada', whose postal codes start with '9'.

2. List products whose price is greater than the average price of all products.

3. Find all orders placed between '2025-01-01' and '2025-06-30' for customers in 'London'.

4. Select all categories not containing the word 'food' in their description.

5. Find all products whose price modulo 10 is 0 and unit contains 'kg'.

### Section 2: Aggregates & Grouping

6. Count the number of orders for each customer.

7. Find the average product price for each category.

8. List customers who have placed more than 5 orders.

9. Find the total revenue per product (quantity × price).

10. Find the category with the highest number of products.

### Section 3: Joins & Subqueries

11. List all products ordered by customer 'Alice'.

12. Find all customers who never placed an order.

13. Retrieve all orders along with total order value.

14. Find products that appear in more than 20 orders.

15. List customers who ordered half the products from category_id = 2.

### Section 4: Advanced Queries

16. Find the second most expensive product.

17. Get the latest order for each customer.

18. List products whose price is higher than at least 50% of other products.

19. Find customers whose total order quantity exceeds 100 units.

20. List products never ordered but present in the testproducts table.

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
