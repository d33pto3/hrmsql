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
