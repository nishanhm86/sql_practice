SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'marketing_campaign'
ORDER BY ordinal_position;

SELECT COUNT(*) AS total_count,
COUNT (DISTINCT id) AS id_count
FROM marketing_campaign;

SELECT marital_status, COUNT(*) AS customers
FROM marketing_campaign
GROUP BY marital_status
ORDER BY customers DESC;

-- CREATE TABLE marital_lookup (
-- marital_status TEXT,
-- marital_group TEXT);

-- INSERT INTO marital_lookup VALUES
-- ('Married',  'Partnered'),
-- ('Together', 'Partnered'),
-- ('Single',   'Single'),
-- ('Divorced', 'Single'),
-- ('Widow',    'Single'),
-- ('Alone',    'Single');

SELECT COALESCE (l.marital_group, 'Unmapped') AS marital_group,
COUNT (*) AS customers
FROM marketing_campaign AS m
LEFT JOIN marital_lookup AS l
ON m.marital_status = l.marital_status
GROUP BY marital_group
ORDER BY customers DESC;

SELECT MIN(year_birth),
MAX(year_birth)
FROM marketing_campaign;


SELECT responsetest, COUNT(*) AS customers
FROM marketing_campaign
GROUP BY responsetest;


SELECT 
COUNT(*) - COUNT(mntwines) AS nullwines,
COUNT(*) - COUNT(mntfruits) AS nullfruits,
COUNT(*) - COUNT(mntmeatproducts) AS nullmeatproducts,
COUNT(*) - COUNT(mntfishproducts) AS nullfishproducts,
COUNT(*) - COUNT(mntsweetproducts) AS nullsweetproducts,
COUNT(*) - COUNT(mntgoldprods) AS nullgoldprods
FROM marketing_campaign;


SELECT MIN(year_birth) AS min_birth, MAX(year_birth) AS max_birth,
       MIN(dt_customer) AS first_signup, MAX(dt_customer) AS last_signup
FROM marketing_campaign;

SELECT year_birth, COUNT(*) AS customers
FROM marketing_campaign
WHERE year_birth < 1950
GROUP BY year_birth
ORDER BY year_birth;


SELECT m.education, m.marital_status
FROM marketing_campaign AS m
LEFT JOIN education_lookup AS e
ON m.education = e.education
LEFT JOIN marital_lookup AS ml
ON m.marital_status = ml.marital_status;

-- DROP VIEW IF EXISTS customer_profile;


-- CREATE VIEW customer_profile AS
-- SELECT m.id,
-- COALESCE (e.education_group, 'Unmapped') AS edu_group,
-- COALESCE (ml.marital_group, 'Unmapped') AS marital_group,
-- CASE 
-- WHEN 2014 - m.year_birth > 100 THEN 'Invalid age'
-- WHEN 2014 - m.year_birth >= 65 THEN '65 and over'
-- WHEN 2014 - m.year_birth >= 50 THEN '50 - 64'
-- WHEN 2014 - m.year_birth >= 35 THEN '35 - 49'
-- ELSE 'Under 35'
-- END AS age_band,
-- CASE 
-- WHEN m.income IS NULL THEN 'Income_not_declared'
-- WHEN m.income < 30000 THEN 'Low'
-- WHEN m.income < 60000 THEN 'Medium'
-- ELSE 'High'
-- END AS income_level,
-- m.mntwines + m.mntfruits + m.mntmeatproducts + m.mntfishproducts + m.mntsweetproducts + m.mntgoldprods AS total_spend,
-- m.responsetest AS responded
-- FROM marketing_campaign AS m
-- LEFT JOIN education_lookup AS e
-- ON m.education = e.education
-- LEFT JOIN marital_lookup AS ml
-- ON m.marital_status = ml.marital_status;

SELECT
    SUM(CASE WHEN edu_group = 'Unmapped'   THEN 1 ELSE 0 END) AS edu_unmapped,
    SUM(responded)                                            AS responders,
    SUM(CASE WHEN age_band = 'Invalid age' THEN 1 ELSE 0 END) AS invalid_age
FROM customer_profile;

SELECT age_band, COUNT(*) AS customers
FROM customer_profile
GROUP BY age_band
ORDER BY customers DESC;