-- ============================================================
-- Week 2, Session 3: CASE, COALESCE, NULL handling, integer division
-- Tables: orders, customers (Week 2, Session 1)
--         marketing_campaign (Week 1, Session 3)
-- ============================================================


-- ------------------------------------------------------------
-- Part 1: CASE on orders
-- Bands: Large = 200 or more, Medium = 100 to 199.99, Small = under 100
-- ------------------------------------------------------------

-- Label every order with a size band
SELECT order_id,
amount,
CASE
WHEN amount >= 200 THEN 'Large'
WHEN amount >= 100 THEN 'Medium'
ELSE 'Small'
END AS order_size
FROM orders;

-- Orders and total amount per size band
SELECT CASE
WHEN amount >= 200 THEN 'Large'
WHEN amount >= 100 THEN 'Medium'
ELSE 'Small'
END AS order_size,
COUNT(*)    AS num_orders,
SUM(amount) AS total_amount
FROM orders
GROUP BY order_size
ORDER BY total_amount DESC;

-- WRONG order: CASE returns the first match, so every amount >= 100
-- becomes 'Medium' and 'Large' never appears
SELECT order_id,
amount,
CASE
WHEN amount >= 100 THEN 'Medium'
WHEN amount >= 200 THEN 'Large'
ELSE 'Small'
END AS order_size
FROM orders;

-- No ELSE: orders under 100 return NULL instead of 'Small'
SELECT order_id,
amount,
CASE
WHEN amount >= 200 THEN 'Large'
WHEN amount >= 100 THEN 'Medium'
END AS order_size
FROM orders;


-- ------------------------------------------------------------
-- Part 2: CASE on marketing_campaign (income bands)
-- Bands: Low = under 30,000 | Medium = 30,000 to 59,999 | High = 60,000+
-- NULL is tested first so missing incomes do not fall into 'High'
-- Note: the 666,666 outlier sits in 'High' and inflates its totals and average
-- ------------------------------------------------------------

-- Label each customer with an income band (NULLs shown last)
SELECT id,
education,
income,
CASE
WHEN income IS NULL THEN 'No income recorded'
WHEN income < 30000 THEN 'Low'
WHEN income < 60000 THEN 'Medium'
ELSE 'High'
END AS income_level
FROM marketing_campaign
ORDER BY income DESC NULLS LAST;

-- Customers, total income and average income per band
SELECT CASE
WHEN income IS NULL THEN 'No income recorded'
WHEN income < 30000 THEN 'Low'
WHEN income < 60000 THEN 'Medium'
ELSE 'High'
END AS income_level,
COUNT(*) AS num_customers,
SUM(income) AS total_income,
ROUND(AVG(income), 2) AS avg_income
FROM marketing_campaign
GROUP BY income_level
ORDER BY MIN(income) NULLS LAST;


-- ------------------------------------------------------------
-- Part 3: NULL handling and COALESCE
-- ------------------------------------------------------------

-- AVG skips NULLs; turning NULLs into 0 pulls the average down
-- counted_plain = 2,216 (rows with income), counted_coalesced = 2,240 (all rows)
SELECT AVG(income) AS avg_ignoring_nulls,
AVG(COALESCE(income, 0)) AS avg_nulls_as_zero,
COUNT(income) AS counted_plain,
COUNT(COALESCE(income, 0)) AS counted_coalesced
FROM marketing_campaign;

-- Total spend per customer, 0 instead of NULL for customers with no orders
SELECT c.name,
c.customer_id,
COALESCE(SUM(o.amount), 0) AS total_spend
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.name, c.customer_id
ORDER BY total_spend DESC, c.name;

-- Customers with and without income (2,216 + 24 = 2,240)
SELECT ROUND(AVG(income), 2) AS avg_income,
COUNT(income) AS customers_with_income,
COUNT(*) - COUNT(income) AS customers_without_income
FROM marketing_campaign;


-- ------------------------------------------------------------
-- Part 4: Integer division
-- ------------------------------------------------------------

-- Two integers give an integer: 5/2 = 2 and 1/3 = 0
-- Make one side decimal to get the real result: 5/2.0 = 2.5 and 1.0/3 = 0.333...
SELECT 5/2,
5/2.0,
CAST(5 AS NUMERIC)/2,
5::NUMERIC/2,
1/3,
1.0/3;

-- Share of customers with missing income (24 of 2,240, about 1.07%)
-- 100.0 * avoids integer division and gives a percent, not a fraction
SELECT ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM marketing_campaign), 2) AS pct_missing_income
FROM marketing_campaign
WHERE income IS NULL;

-- Income bands with each band's share of all customers
-- Check: num_customers adds up to 2,240 and pct_of_customers adds up to 100
SELECT CASE
WHEN income IS NULL THEN 'No income recorded'
WHEN income < 30000 THEN 'Low'
WHEN income < 60000 THEN 'Medium'
ELSE 'High'
END AS income_level,
COUNT(*)                AS num_customers,
SUM(income)             AS total_income,
ROUND(AVG(income), 2)   AS avg_income,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM marketing_campaign), 2) AS pct_of_customers
FROM marketing_campaign
GROUP BY income_level
ORDER BY MIN(income) NULLS LAST;


-- ============================================================
-- Key findings
-- 1. CASE returns the first match, so put the strictest condition first.
-- 2. Without ELSE, unmatched rows return NULL.
-- 3. COUNT(*) counts rows; COUNT(column) skips NULLs.
-- 4. Turning NULLs into 0 changes averages (2,216 vs 2,240 rows counted).
-- 5. Use 100.0 * to avoid integer division and get a real percent.
-- ============================================================
