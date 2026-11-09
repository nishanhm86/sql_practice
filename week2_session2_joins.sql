-- A RIGHT JOIN is the mirror of a LEFT JOIN: 
-- It keeps every row from the right table and fills the left side with NULLs where nothing matches.

SELECT c.name, o.order_id, o.amount
FROM customers AS c
RIGHT JOIN orders AS o
ON c.customer_id = o.customer_id;

-- Exercise 1 (RJ) - Rewrite the query as a LEFT JOIN that returns the same rows.


SELECT c.name, o.order_id, o.amount
FROM orders AS o
LEFT JOIN customers AS c
ON c.customer_id = o.customer_id;

-- Exercise 2 (RJ) - Find the orphan orders, meaning orders with no matching customer, using the anti-join pattern.

SELECT o.order_id, o.customer_id, o.order_date, o.amount
FROM customers AS c
RIGHT JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Exercise 3 (RJ) - Calculate the total amount of orphan orders.

SELECT COUNT(*),
SUM(o.amount) AS total_amount
FROM customers AS c
RIGHT JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE c.name IS NULL;