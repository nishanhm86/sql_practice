-- ============================================================
-- Week 2, Session 1: JOINs (IJ = inner, LJ = left, JMC = joins on marketing_campaign)
-- Tables: customers, orders, marketing_campaign, education
-- ============================================================

-- Order 108 is orphaned.
-- 203 customers have no education group.
-- Filters on the right table go in ON, not WHERE.

-- INNER JOIN

SELECT c.name, o.order_id, o.amount
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id;

-- Exercise 1 (IJ) - Show name, city, order_date, amount, sorted by order_date.

SELECT c.name, c.city, o.order_date, o.amount
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
ORDER BY o.order_date ASC;

-- Exercise 2 (IJ) - Only orders over 100.

SELECT c.name, c.city, o.order_date, o.amount
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE o.amount > 100;

-- Exercise 3 (IJ) -Total amount spent per customer, group by name.

SELECT c.name,
c.customer_id,
COUNT(*) AS num_orders,
MAX(o.order_date) AS last_order_date,
SUM(o.amount) AS total_amount
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Exercise 4 (IJ) - Customers with a total spend over 150

SELECT c.customer_id,
c.name,
COUNT(*) AS num_orders,
MAX(o.order_date) AS last_order_date,
SUM(o.amount) AS total_amount
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING SUM(o.amount)>150;

-- Exercise 5 (IJ) - Total sales per city.

SELECT c.city,
COUNT(*) AS num_orders,
MAX(o.order_date) AS last_order_date,
SUM(o.amount) AS total_amount
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.city;

-- LEFT JOIN

SELECT c.name, o.order_id, o.amount
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id;


-- Exercise 1 (LJ) - Swap the tables (orders LEFT JOIN customers). What changes? Explain why in one sentence.

SELECT c.name, o.order_id, o.amount
FROM orders AS o
LEFT JOIN customers AS c
ON c.customer_id = o.customer_id;

-- Changes: Farhan and Dinesh are missing, and there is a NULL name for order ID 108. 
-- This preserves every row of the left table (orders), so all 8 orders survive and customers with no orders drop out.

-- Exercise 2 (LJ) - Count orders per customer, including customers with zero. Work out why the difference matters.

SELECT c.name,
COUNT(o.order_id) AS num_orders
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.name;

-- why matters: COUNT(o.order_id) counts only order_id's skip null values. Whereas COUNT(*) counts all rows; 
-- thus, NULL values are included and can produce incorrect results.

SELECT c.name,
COUNT(*) AS num_orders
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.name;

-- After a LEFT JOIN, Dinesh still has one row with NULL order columns, so COUNT(*) reports 1 order for him instead of 0

-- Exercise 3 (LJ) - Anti-join: list only the customers who have never ordered.

SELECT c.name, c.customer_id
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Exercise 4 (LJ) - Show total spend per customer, with 0 instead of NULL for non-buyers.

SELECT c.name,
c.customer_id,
MAX(o.order_date) AS last_order_date,
COALESCE(SUM(o.amount),0) AS total_spend
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.name, c.customer_id;

SELECT c.name,
c.customer_id,
MAX(o.order_date) AS last_order_date,
COALESCE(SUM(o.amount),0) AS spend_on_orders_over_100
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE o.amount > 100
GROUP BY c.name, c.customer_id;

-- WHERE version: Dinesh and Farhan have no orders, and Eshani has no order over 100.
-- WHERE removes these rows before grouping, so they are missing from the result.

SELECT c.name,
c.customer_id,
MAX(o.order_date) AS last_order_date,
COALESCE(SUM(o.amount),0) AS total_spend_over_100
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id AND o.amount > 100
GROUP BY c.name, c.customer_id;

-- Dinesh, Farhan, and Eshani all show 0 as the value, as they are not in the qualified list. 
-- But this data is misleading the decision-makers, as Eshani has spent 60 on her purchases.


-- Exercise 1 (JMC) - INNER JOIN marketing_campaign to education_lookup. How many rows come back versus the full 2,240?

SELECT COUNT(*) FROM
marketing_campaign AS m
INNER JOIN education_lookup AS e
ON m.education = e.education;

-- This displays 2037 records.

-- Exercise 2 (JMC) - LEFT JOIN the same two. Which customers now have a NULL group, and how many are there?

SELECT COUNT (*) FROM
marketing_campaign AS m
LEFT JOIN education_lookup AS e
ON m.education = e.education
WHERE e.education IS NULL;

-- This provides 203 records.

-- Exercise 3 (JMC) - Use the anti-join pattern to find the missing education value.

SELECT DISTINCT m.education FROM
marketing_campaign AS m
LEFT JOIN education_lookup AS e
ON m.education = e.education
WHERE e.education IS NULL;

-- Exercise 4 (JMC) - Average income and total customers per education_group.

SELECT e.education_group,
COUNT(m.id) AS total_customers,
ROUND(AVG(m.income),2) AS avg_income
FROM marketing_campaign AS m
LEFT JOIN education_lookup AS e
ON m.education = e.education
GROUP BY e.education_group;

SELECT e.education_group,
COUNT(m.id) AS total_customers,
ROUND(AVG(m.income),2) AS avg_income
FROM marketing_campaign AS m
INNER JOIN education_lookup AS e
ON m.education = e.education
GROUP BY e.education_group;
