-- Week 1 Session 1: SELECT, WHERE, ORDER BY, LIMIT
-- Table: campaign_customers

DROP TABLE IF EXISTS campaign_customers;
CREATE TABLE campaign_customers( 
customer_id serial PRIMARY KEY,
name varchar (50),
country varchar(30),
age int,
income numeric(10,2),
signup_date date,
campaign_response boolean
);

INSERT INTO campaign_customers(name, country, age, income, signup_date, campaign_response) VALUES
('Amal',   'Sri Lanka', 34, 52000, '2023-01-15', TRUE),
('Sarah',  'UK',        29, 61000, '2023-03-02', FALSE),
('John',   'USA',       45, 88000, '2022-11-20', TRUE),
('Priya',  'India',     38, 47000, '2023-06-11', FALSE),
('Liam',   'UK',        52, 95000, '2021-08-05', TRUE),
('Mei',    'China',     27, 43000, '2024-02-18', FALSE),
('Carlos', 'Spain',     41, 72000, '2022-05-30', TRUE),
('Nadia',  'Sri Lanka', 31, 39000, '2024-04-09', FALSE),
('Tom',    'USA',       36, 67000, '2023-09-23', TRUE),
('Emma',   'UK',        24, 35000, '2024-07-01', FALSE);

SELECT * FROM campaign_customers;
SELECT name, country FROM campaign_customers;
SELECT DISTINCT country FROM campaign_customers;
SELECT name, income *12 AS annual_income FROM campaign_customers;

SELECT * FROM campaign_customers WHERE country = 'UK';
SELECT * FROM campaign_customers WHERE age >= 35 AND income > 60000;
SELECT * FROM campaign_customers WHERE country = 'USA' OR country = 'Spain';
SELECT * FROM campaign_customers WHERE country IN ('UK', 'India', 'China');
SELECT * FROM campaign_customers WHERE age BETWEEN 30 AND 40;
SELECT * FROM campaign_customers WHERE name LIKE 'S%';
SELECT * FROM campaign_customers WHERE campaign_response = TRUE;
SELECT * FROM campaign_customers WHERE country <> 'UK';
SELECT * FROM campaign_customers ORDER BY income DESC;
SELECT * FROM campaign_customers ORDER BY country ASC, income DESC;
SELECT name, income FROM campaign_customers ORDER BY income DESC limit 3;


--Exercise 1: Sri Lankan Customers
SELECT name, age FROM campaign_customers WHERE country = 'Sri Lanka';
--Exercise 2: Responded and income over 50000
SELECT name, income, campaign_response FROM campaign_customers WHERE income > 50000 AND campaign_response = TRUE;
--Exercise 3: 3 Youngest
SELECT name, age FROM campaign_customers ORDER BY age ASC limit 3;
--Exercise 4: All customers who signed up in 2023
SELECT * FROM campaign_customers WHERE signup_date BETWEEN '2023-01-01' AND '2023-12-31';
--Exercise 5: Name contains "a"
SELECT * FROM campaign_customers WHERE name ilike '%a%';
--Exercise 6: Names of top 4 earning Non-UK customers
SELECT name, income FROM campaign_customers WHERE country <> 'UK' ORDER BY income DESC LIMIT 4;
--Exercise 7: Three countries with high-earning customers
SELECT distinct country FROM campaign_customers WHERE income > 60000;
--Exercise 8a: Respondents from UK and USA
SELECT * FROM campaign_customers WHERE country IN ('UK', 'USA') AND campaign_response = TRUE;
--Exercise 8b: Respondents from UK and USA with or without parentheses, AND runs first, so all UK rows return.
SELECT * FROM campaign_customers WHERE country = 'UK' OR country = 'USA' AND campaign_response = TRUE;
--Exercise 8c: Respondents from UK and USA with parentheses
SELECT * FROM campaign_customers WHERE (country = 'UK' OR country = 'USA') AND campaign_response = TRUE;
--Exercise 9: Customers didn't respond over 30, sorted income high to low
SELECT * FROM campaign_customers WHERE age >= 30 AND campaign_response = FALSE ORDER BY income DESC;
--Exercise 10: Top earners signed up after 2022-12-31
SELECT name, country, income FROM campaign_customers WHERE signup_date > '2022-12-31' ORDER BY income DESC LIMIT 2;
--Exercise 11: Names end with "a"
SELECT * FROM campaign_customers WHERE name ilike '%a';
