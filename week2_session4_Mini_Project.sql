-- ============================================================
-- Week 2 Mini Project: customer_profile view
-- Goal: one clean view (education group, marital group, age band,
--       income level, total spend, response) for later analysis
-- Tables: marketing_campaign (Week 1, Session 3)
--         education_lookup   (Week 2, Session 1 setup)
--         marital_lookup     (created below)
-- Age = 2014 - year_birth (data collected c. 2014)
-- ============================================================


-- ------------------------------------------------------------
-- Part 1: Check the data
-- ------------------------------------------------------------
-- Column names and data types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'marketing_campaign'
ORDER BY ordinal_position;

-- Is id unique? Expect 2,240 total and 2,240 distinct
SELECT COUNT(*) AS total_count,
COUNT(DISTINCT id) AS id_count
FROM marketing_campaign;

-- Marital status values (Alone, Absurd and YOLO have only a handful of customers)
SELECT marital_status,
COUNT(*) AS customers
FROM marketing_campaign
GROUP BY marital_status
ORDER BY customers DESC;

-- Missing values in the spend columns
-- Expect all zeros, so total_spend is safe to add up
SELECT 
COUNT(*) - COUNT(mntwines) AS nullwines,
COUNT(*) - COUNT(mntfruits) AS nullfruits,
COUNT(*) - COUNT(mntmeatproducts) AS nullmeatproducts,
COUNT(*) - COUNT(mntfishproducts) AS nullfishproducts,
COUNT(*) - COUNT(mntsweetproducts) AS nullsweetproducts,
COUNT(*) - COUNT(mntgoldprods) AS nullgoldprods
FROM marketing_campaign;

-- Response column: how many responded vs not
SELECT responsetest,
COUNT(*) AS customers
FROM marketing_campaign
GROUP BY responsetest;

-- Birth year and signup date ranges
SELECT 
MIN(year_birth) AS min_birth,
MAX(year_birth) AS max_birth,
MIN(dt_customer) AS first_signup,
MAX(dt_customer) AS last_signup
FROM marketing_campaign;

-- Unrealistic birth years (before 1950)
SELECT year_birth,
COUNT(*) AS customers
FROM marketing_campaign
WHERE year_birth < 1950
GROUP BY year_birth
ORDER BY year_birth;


-- ------------------------------------------------------------
-- Part 2: Lookup tables
-- ------------------------------------------------------------
DROP TABLE IF EXISTS marital_lookup;
CREATE TABLE marital_lookup (
marital_status TEXT,
marital_group  TEXT
);

INSERT INTO marital_lookup VALUES
('Married',  'Partnered'),
('Together', 'Partnered'),
('Single',   'Single'),
('Divorced', 'Single'),
('Widow',    'Single'),
('Alone',    'Single');
-- Absurd and YOLO are left out on purpose, so they show as 'Unmapped'

-- Customers per marital group
SELECT 
COALESCE(l.marital_group, 'Unmapped') AS marital_group,
COUNT(*) AS customers
FROM marketing_campaign AS m
LEFT JOIN marital_lookup AS l
ON m.marital_status = l.marital_status
GROUP BY COALESCE(l.marital_group, 'Unmapped')
ORDER BY customers DESC;

-- Education values missing from education_lookup (anti-join)
-- Expect one value: the 203 unmapped customers (likely '2n Cycle')
SELECT DISTINCT m.education
FROM marketing_campaign AS m
LEFT JOIN education_lookup AS e
ON m.education = e.education
WHERE e.education IS NULL;

-- FIX: add the missing value to education_lookup, using the same group as 'Master'
-- Check the exact spelling from the query above before running.
-- INSERT INTO education_lookup (education, education_group)
-- SELECT '2n Cycle', education_group
-- FROM education_lookup
-- WHERE education = 'Master';


-- ------------------------------------------------------------
-- Part 3: Check the joins do not add or remove rows
-- ------------------------------------------------------------
-- Expect 2,240: each customer must match at most one row per lookup
SELECT COUNT(*) AS total_rows
FROM marketing_campaign AS m
LEFT JOIN education_lookup AS e
ON m.education = e.education
LEFT JOIN marital_lookup AS ml
ON m.marital_status = ml.marital_status;


-- ------------------------------------------------------------
-- Part 4: Build the view
-- Age bands: Invalid age = over 100, 65 and over, 50 - 64, 35 - 49, Under 35
-- Income levels: Low < 30,000 | Medium < 60,000 | High 60,000+
-- Income outlier (666,666) falls in 'High'
-- ------------------------------------------------------------
DROP VIEW IF EXISTS customer_profile;

CREATE VIEW customer_profile AS
SELECT m.id,
COALESCE(e.education_group, 'Unmapped') AS edu_group,
COALESCE(ml.marital_group, 'Unmapped')  AS marital_group,
2014 - m.year_birth AS age,
CASE
WHEN 2014 - m.year_birth > 100  THEN 'Invalid age'
WHEN 2014 - m.year_birth >= 65  THEN '65 and over'
WHEN 2014 - m.year_birth >= 50  THEN '50 - 64'
WHEN 2014 - m.year_birth >= 35  THEN '35 - 49'
ELSE 'Under 35'
END AS age_band,
CASE
WHEN m.income IS NULL THEN 'No income recorded'
WHEN m.income < 30000 THEN 'Low'
WHEN m.income < 60000 THEN 'Medium'
ELSE 'High'
END AS income_level,
m.mntwines + m.mntfruits + m.mntmeatproducts + m.mntfishproducts + m.mntsweetproducts + m.mntgoldprods AS total_spend,
m.responsetest AS responded
FROM marketing_campaign AS m
LEFT JOIN education_lookup AS e
ON m.education = e.education
LEFT JOIN marital_lookup AS ml
ON m.marital_status = ml.marital_status;


-- ------------------------------------------------------------
-- Part 5: Check the view
-- ------------------------------------------------------------
-- Expect edu_unmapped = 0 after the lookup fix (203 before), responders = 334
-- invalid_age = customers with a birth year before 1914
SELECT SUM(CASE WHEN edu_group = 'Unmapped'   THEN 1 ELSE 0 END) AS edu_unmapped,
SUM(responded::int) AS responders,
SUM(CASE WHEN age_band = 'Invalid age' THEN 1 ELSE 0 END) AS invalid_age
FROM customer_profile;

-- Customers per age band, youngest first
SELECT age_band,
COUNT(*) AS customers
FROM customer_profile
GROUP BY age_band
ORDER BY MIN(age);

-- ------------------------------------------------------------
-- Part 6: Analysis using the view
-- ------------------------------------------------------------
-- Response rate by age band (groups under 30 customers dropped)
SELECT age_band,
COUNT(*) AS customers,
ROUND(100.0 * SUM(responded::int) / COUNT(*), 1)  AS response_rate_pct
FROM customer_profile
GROUP BY age_band
HAVING COUNT(*) >= 30
ORDER BY response_rate_pct DESC;

-- Response rate and average spend by income level (groups under 30 dropped)
SELECT income_level,
COUNT(*) AS customers,
ROUND(100.0 * SUM(responded::int) / COUNT(*), 1) AS response_rate_pct,
ROUND(AVG(total_spend), 2) AS avg_spend
FROM customer_profile
GROUP BY income_level
HAVING COUNT(*) >= 30
ORDER BY response_rate_pct DESC;


-- ============================================================
-- Key findings
-- 1. A view keeps the cleaning rules (bands, lookups) in one place.
-- 2. LEFT JOIN + COALESCE keeps unmapped customers visible as 'Unmapped'.
-- 3. The 203 unmapped education customers came from one missing lookup value.
-- 4. Birth years before 1914 give invalid ages, so they get their own band.
-- 5. Drop small groups with HAVING COUNT(*) >= 30.
-- ============================================================
