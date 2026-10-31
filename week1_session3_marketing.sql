-- Data quality issues.
-- 1. The income of 666,666.00 is much higher than the second-highest income of 162,397.00
-- 2. There are 24 missing incomes
-- 3. The oldest person's age is 121, which is unrealistic.
-- 4. There are odd marital-status values: Alone, Absurd, and YOLO, as they are less than 10.

-- Exercise 1 - How many customers are in the dataset?
SELECT COUNT (*) AS total_customers
FROM marketing_campaign;
-- Total customers: 2240

-- Exercise 2 - Who are the 10 highest-income customers (id, income)?
SELECT id, income AS top_10_income_customers FROM marketing_campaign
WHERE income IS NOT NULL
ORDER BY income DESC, id ASC LIMIT 10;
-- Top value recorded as 666,666.00. This is much higher than the second-highest income of 162,397.00, likely due to a data entry error.

--Exercise 3 - How many customers have missing income?
SELECT count(*) AS missing_income FROM marketing_campaign
WHERE income IS NULL;
-- There are 24 customers with NULL income

--Exercise 4 -  Average income by education level.
SELECT education, 
count(*) AS customers,
round(AVG(income),2) AS avg_income
FROM marketing_campaign
GROUP BY education
ORDER BY avg_income DESC;
-- Top avg income earners are PhD holders, while basic level qualification remains at the bottom


--Exercise 5 - Number of customers by marital status, highest first.

SELECT marital_status, count(*) AS customers
FROM marketing_campaign
GROUP BY marital_status
ORDER BY customers DESC;

-- Married customers are leading the table; however, Alone, Absurd, and YOLO have only a handful of customers each.

--Exercise 6 - Average age, using 2014 - year_birth (compare with the oldest and youngest).
SELECT MIN(2014-year_birth) AS youngest,
MAX(2014-year_birth) AS oldest,
round(AVG(2014-year_birth),1) AS mean_age,
percentile_cont(0.5) WITHIN GROUP (ORDER BY 2014-year_birth) AS median_age
FROM marketing_campaign;

--Youngest 18, oldest 121, mean age 45.2, and median age 44.
--Oldest age of 121 is implausible (birth year ~1893); a few records are bad data


--Exercise 7 - Average spend on wine and on meat across all customers.
select round(avg(mntwines),2) as avg_spend_wine,
round(avg(mntmeatproducts),2) as avg_spend_meat
from marketing_campaign;

-- Wine 303.94 and meat 166.95

-- Exercise 8 - Overall response rate (use responsetest).
select COUNT(*) AS customers,
SUM(responsetest::int) AS responders,
round(100.0 * sum(responsetest::int)/COUNT(*),1) as overall_response_rate
FROM marketing_campaign;

-- Responders - 334, rate 14.9
-- Baseline: about 1 in 7 customers responded.

-- Exercise 9 - Response rate by education, with customer counts.

SELECT education, COUNT(*) AS customers,
SUM(responsetest::int) AS responders,
round(100.0 * sum(responsetest::int)/COUNT(*),1) as response_rate_pct
FROM marketing_campaign
GROUP BY education
ORDER BY response_rate_pct DESC;
-- PhD has the highest response rate (20.8%); Basic is the lowest at 3.7%,
-- but that is only 2 responders out of 54, so treat it as indicative, not firm.


-- Exercise 10 - Response rate by marital status, drop tiny groups.
select marital_status, COUNT(*) AS customers,
SUM(responsetest::int) AS responders,
round(100.0 * sum(responsetest::int)/COUNT(*),1) as response_rate_pct
FROM marketing_campaign
GROUP BY marital_status
HAVING COUNT(*)>= 30
ORDER BY response_rate_pct DESC;

-- Widows have the highest rate (24.7%) but on a small group (n = 77); 
-- Together is the lowest at 10.3% (n = 580). The low rate for Together is the more reliable result.
-- Alone, Absurd, and YOLO are excluded by HAVING (fewer than 30 customers each).

-- Exercise 11 - Do customers with children at home (kidhome > 0) respond less?

SELECT CASE WHEN kidhome > 0 THEN 'Has kids' ELSE 'No kids' END AS household, 
COUNT(*) AS customers,
SUM(responsetest::int) AS responders,
round(100.0 * sum(responsetest::int)/COUNT(*),1) as response_rate_pct
FROM marketing_campaign
GROUP BY household
ORDER BY response_rate_pct DESC;

-- No kids: 17.2% (n = 1,293 customers, 222 responders) vs. Has kids: 11.8%
-- (n = 947 customers, 112 responders), a gap of 5.4 percentage points.
-- This is an association only; it doesn't show that kids cause lower response.

-- Exercise 12 - Show top 10 total spending customers

SELECT id, (mntwines + mntfishproducts + mntfruits + mntmeatproducts + mntsweetproducts + mntgoldprods) AS total_spend
FROM marketing_campaign
ORDER BY total_spend DESC, id ASC LIMIT 10;

-- 2 customers spend $ 2525/- tops the table.

-- Exercise 13 - purchases by channel.

SELECT SUM(numwebpurchases) AS web_purchase_total,
SUM(numcatalogpurchases) AS catalog_purchase_total,
SUM(numstorepurchases) AS store_purchase_total
FROM marketing_campaign;

-- Store is the biggest channel, at roughly 46% of purchases


-- Exercise 14 - Responders versus non-responders.

SELECT responsetest, COUNT(*) AS customers,
round(AVG(income),2) AS avg_income,
round(AVG(mntwines + mntfishproducts + mntfruits + mntmeatproducts + mntsweetproducts + mntgoldprods),2) AS avg_total_spent
FROM marketing_campaign
WHERE income < 600000
GROUP BY responsetest;

-- Average income of non-responded customers is 50,511.91, and they spend an average amount of 540.38.
-- Average income of responded customers is 60,209.68, and they spend an average amount of 985.66.
-- WHERE income < 600000 removes the 666,666 outlier, but it also drops the 24 customers with NULL income, because a NULL never satisfies a comparison.

-- Exercise 15 - Recommendation.

SELECT education,
CASE WHEN kidhome > 0 THEN 'Has kids' ELSE 'No kids' END AS household,
COUNT (*) AS customers,
round(AVG(income),2) AS avg_income,
round(AVG(mntwines + mntfishproducts + mntfruits + mntmeatproducts + mntsweetproducts + mntgoldprods),2) AS avg_total_spent,
SUM(responsetest::int) AS responders,
round(100.0 * SUM(responsetest::int) / COUNT(*), 1) AS response_rate_pct
FROM marketing_campaign
GROUP BY education, household
HAVING COUNT(*) >= 30
ORDER BY avg_total_spent DESC, response_rate_pct ASC;

-- RECOMMENDATION
-- Primary target: PhD, no kids (24.8% response vs 17.2% no-kids baseline, n = 303).
-- Secondary: Graduation and Master, no kids. Spend is high (>900), and volume is large,
-- but response (15.1%, 15.6%) is below the no-kids baseline, so expect ROI to come from spend, not response.
-- Borderline: 2nd Cycle (no kids) has the 4th-highest spend (>750) but a 14.7% response rate, just below baseline.
-- Excluded: Graduation with kids (n = 477, 21% of customers) - avg spend < 250, response 11.3%.
-- Caveat: associations from one campaign; no-kids customers may have higher income. Test on a small mailing first.
