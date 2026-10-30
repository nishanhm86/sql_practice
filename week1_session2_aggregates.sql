-- Number of rows
SELECT count(*) FROM campaign_customers;
-- Average income
SELECT AVG(income) FROM campaign_customers;
-- Minimum and maximum values
SELECT MIN(age), MAX(age) FROM campaign_customers;
-- Calculating total of a column
SELECT SUM(income) AS total_income FROM campaign_customers;
-- Average income with 2 decimals
SELECT round(AVG(income),2) AS avg_income FROM campaign_customers;
-- Average income by a particular country
SELECT avg(income) FROM campaign_customers WHERE country = 'UK';

-- GROUP BY runs the aggregate once per group instead of once for the whole table:
SELECT country, COUNT(*) AS customers
FROM campaign_customers
GROUP BY country ORDER BY customers DESC;

SELECT  country, round(AVG(income),2) AS avg_income
FROM campaign_customers
GROUP BY country
ORDER BY avg_income DESC;

-- HAVING: WHERE filters rows before grouping. HAVING filters groups after aggregating:

SELECT country, COUNT(*) AS customers
from campaign_customers
GROUP BY country
HAVING COUNT(*)>=2;

-- Response Rate
SELECT country, COUNT(*) AS customers,
SUM(campaign_response :: int) AS resoponders,
round(100.0 * SUM(campaign_response:: int) / COUNT(*),1) AS respond_rate_pct
FROM campaign_customers
GROUP BY country
ORDER BY respond_rate_pct DESC;

--Exercise 1 - How many customers are there in total, and what is the average age?
SELECT COUNT(*) AS total_customers,
round(AVG(age),0) AS ave_age 
FROM campaign_customers;


--Exercise 2 - Average income per country, highest first.
SELECT country, COUNT(*) AS customers,
round(AVG(income),2) AS avg_country_income
FROM campaign_customers
GROUP BY country
ORDER BY avg_country_income DESC;


--Exercise 3 - Number of customers who responded versus those who didn’t
SELECT campaign_response, COUNT(*) AS customers FROM campaign_customers
GROUP BY campaign_response;


-- Exercise 4 - Countries with more than one customer and an average income above 50,000
SELECT country, COUNT(*) AS customers,
round(AVG(income),2) as avg_income
FROM campaign_customers
GROUP BY country
HAVING COUNT(*)>=2 AND avg(income) > 50000;


-- Exercise 5 - Total income of responders versus non-responders.
SELECT campaign_response, COUNT(*) AS customers,
SUM(income) AS total_income_campaign_response
FROM campaign_customers
GROUP BY campaign_response;


-- Exercise 6 - Which signup year had the most customers?
SELECT EXTRACT (YEAR FROM signup_date) AS signup_year, COUNT(*) AS customers
FROM campaign_customers
GROUP BY EXTRACT (YEAR FROM signup_date) 
ORDER BY customers DESC, signup_year DESC;


-- Exercise 7 - Which country has the best response rate, and is it reliable with so few customers?
SELECT country,
COUNT(*) AS customers,
SUM(campaign_response::int) AS responders,
round(100.0 * SUM(campaign_response::int) / COUNT(*), 1) AS response_rate_pct
FROM campaign_customers
GROUP BY country
ORDER BY response_rate_pct DESC, customers DESC, country ASC;

-- USA and Spain tie at 100%, but Spain has only 1 customer. Samples this small are
-- too unreliable to act on; add a minimum sample size and collect more data.