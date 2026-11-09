SELECT order_id, amount,
CASE 
WHEN amount >= 200 THEN 'Large'
WHEN amount >= 100 THEN 'Medium'
ELSE 'Small'
END AS order_size
FROM  orders;

SELECT
CASE
WHEN amount>= 200 THEN 'Large'
WHEN amount >= 100 THEN 'Medium'
ELSE 'Small'
END AS order_size,
COUNT(*) AS num_orders,
SUM(amount) AS total_amount
FROM orders
GROUP BY order_size
ORDER BY total_amount DESC;

SELECT order_id, amount,
CASE 
WHEN amount >=100 THEN 'Medium'
WHEN amount >=200 THEN 'Large'
ELSE 'Small'
END AS order_size
FROM orders;

SELECT order_id, amount,
CASE 
WHEN amount >=200 THEN 'Large'
WHEN amount >=100 THEN 'Medium'
END AS order_size
FROM orders;


SELECT id, education, income,
CASE 
WHEN income IS NULL THEN 'No income recorded'
WHEN income < 30000 THEN 'Low'
WHEN income < 60000 THEN 'Medium'
ELSE 'High'
END AS income_level
FROM marketing_campaign
ORDER BY income DESC NULLS LAST;


SELECT
CASE 
WHEN income IS NULL THEN 'No income recorded'
WHEN income < 30000 THEN 'Low'
WHEN income < 60000 THEN 'Medium'
ELSE 'High'
END AS income_level,
COUNT (*) num_customers,
SUM(income) AS total_income,
ROUND(AVG(income),2) AS avg_income
FROM marketing_campaign
GROUP BY income_level
ORDER BY MIN(income);

SELECT AVG(income)                AS avg_ignoring_nulls,
       AVG(COALESCE(income, 0))   AS avg_nulls_as_zero,
       COUNT(income)              AS counted_plain,
       COUNT(COALESCE(income, 0)) AS counted_coalesced
FROM marketing_campaign;


SELECT c.name, c.customer_id,
COALESCE (SUM(o.amount),0) AS total_spend
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.name, c.customer_id;

SELECT round(AVG(income),2) AS avg_income,
COUNT(income) AS cutomers_with_income,
COUNT(*) - COUNT(income) AS customers_without_income
FROM marketing_campaign;

SELECT 5/2, 5/2.0, CAST(5 AS NUMERIC)/2, 5::NUMERIC/2, 1/3, 1.0/3;

SELECT CAST (COUNT(*) AS NUMERIC) / (SELECT COUNT(*) FROM marketing_campaign) AS pct
FROM marketing_campaign
WHERE income IS NULL;


SELECT
CASE 
WHEN income IS NULL THEN 'No income recorded'
WHEN income < 30000 THEN 'Low'
WHEN income < 60000 THEN 'Medium'
ELSE 'High'
END AS income_level,
COUNT (*) num_customers,
SUM(income) AS total_income,
ROUND(AVG(income),2) AS avg_income,
ROUND(100.0 * COUNT(*)/ (SELECT COUNT(*) FROM marketing_campaign),2) AS pct_of_customers
FROM marketing_campaign
GROUP BY income_level
ORDER BY MIN(income) NULLS LAST;