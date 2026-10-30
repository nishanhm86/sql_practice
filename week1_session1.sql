-- Week 1 Session 1: SELECT, WHERE, ORDER BY, LIMIT
-- Table: campaign_customers

DROP TABLE IF EXISTS campaign_customers;
create table campaign_customers( 
customer_id serial primary key,
name varchar (50),
country varchar(30),
age int,
income numeric(10,2),
signup_date date,
campaign_response boolean
);

insert into campaign_customers(name, country, age, income, signup_date, campaign_response) values
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

select * from campaign_customers;
select name, country from campaign_customers;
select distinct country from campaign_customers;
select name, income *12 as annual_income from campaign_customers;

select * from campaign_customers where country = 'UK';
select * from campaign_customers where age >= 35 and income > 60000;
select * from campaign_customers where country = 'USA' or country = 'Spain';
select * from campaign_customers where country in ('UK', 'India', 'China');
select * from campaign_customers where age between 30 and 40;
select * from campaign_customers where name like 'S%';
select * from campaign_customers where campaign_response = TRUE;
select * from campaign_customers where country <> 'UK';

select * from campaign_customers order by income DESC;
select * from campaign_customers order by country ASC, income DESC;
select name, income from campaign_customers order by income DESC limit 3;


--Exercise 1: Sri Lankan Customers
select name, age from campaign_customers where country = 'Sri Lanka';
--Exercise 2: Responded and income over 50000
select name, income, campaign_response from campaign_customers where income > 50000 and campaign_response = TRUE;
--Exercise 3: 3 Youngest
select name, age from campaign_customers order by age ASC limit 3;
--Exercise 4: All customers who signed up in 2023
select * from campaign_customers where signup_date between '2023-01-01' AND '2023-12-31';
--Exercise 5: Name contains "a"
select * from campaign_customers where name ilike '%a%';
--Exercise 6: Names of top 4 earning Non-UK customers
select name, income from campaign_customers where country <> 'UK' order by income DESC limit 4;
--Exercise 7: Three countries with high-earning customers
select distinct country from campaign_customers where income > 60000;
--Exercise 8a: Respondents from UK and USA
select * from campaign_customers where country in ('UK', 'USA') and campaign_response = TRUE;
--Exercise 8b: Respondents from UK and USA with or without parentheses, AND runs first, so all UK rows return.
select * from campaign_customers where country = 'UK' or country = 'USA' and campaign_response = TRUE;
--Exercise 8c: Respondents from UK and USA with parentheses
select * from campaign_customers where (country = 'UK' or country = 'USA') and campaign_response = TRUE;
--Exercise 9: Customers didn't respond over 30, sorted income high to low
select * from campaign_customers where age >= 30 and campaign_response = FALSE ORDER BY income DESC;
--Exercise 10: Top earners signed up after 2022-12-31
select name, country, income from campaign_customers where signup_date > '2022-12-31' ORDER BY income DESC limit 2;
--Exercise 11: Names end with "a"
select * from campaign_customers where name ilike '%a';
