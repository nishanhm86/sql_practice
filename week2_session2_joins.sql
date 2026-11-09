-- Week 2, Session 2 review: INNER, LEFT, RIGHT, and FULL JOIN on small practice tables

DROP TABLE IF EXISTS items_ordered, items_received;
CREATE TABLE items_ordered (item text);
CREATE TABLE items_received (item text);

INSERT INTO items_ordered VALUES ('Pen'), ('Ink'), ('Paper'), ('Stapler');
INSERT INTO items_received VALUES ('Ink'), ('Paper'), ('Tape'), ('Glue');

-- INNER JOIN: only items in both lists -> 2 rows (Ink, Paper)
SELECT o.item AS ordered,
r.item AS received
FROM items_ordered AS o
INNER JOIN items_received AS r
ON o.item = r.item;

-- LEFT JOIN: all ordered items -> 4 rows (Pen and Stapler have NULL received)
SELECT o.item AS ordered,
r.item AS received
FROM items_ordered AS o
LEFT JOIN items_received AS r
ON o.item = r.item;

-- RIGHT JOIN: all received items -> 4 rows (Tape and Glue have NULL ordered)
SELECT o.item AS ordered,
r.item AS received
FROM items_ordered AS o
RIGHT JOIN items_received AS r
ON o.item = r.item;

-- FULL JOIN: everything from both lists -> 6 rows
SELECT o.item AS ordered,
r.item AS received
FROM items_ordered AS o
FULL JOIN items_received AS r
ON o.item = r.item;

SELECT o.item AS ordered,
r.item AS received
FROM items_ordered AS o
LEFT JOIN items_received AS r
ON o.item = r.item
WHERE o.item IS NULL;

-- WRONG anti-join: tests the preserved table (o), so it returns 0 rows.
-- Correct version tests the other table: WHERE r.item IS NULL (next query).


-- Rows in items_ordered with no match in items_received -> Pen, Stapler
SELECT o.item AS ordered,
r.item AS received
FROM items_ordered AS o
LEFT JOIN items_received AS r
ON o.item = r.item
WHERE r.item IS NULL;

-- Rows in items_received with no match in items_ordered -> Tape, Glue
SELECT o.item AS ordered,
r.item AS received
FROM items_ordered AS o
RIGHT JOIN items_received AS r
ON o.item = r.item
WHERE o.item IS NULL;

DROP TABLE IF EXISTS students, submissions;
CREATE TABLE students    (student TEXT);
CREATE TABLE submissions (student TEXT, score INT);

INSERT INTO students    VALUES ('Anna'), ('Ben'), ('Chloe'), ('Dev');
INSERT INTO submissions VALUES ('Ben', 70), ('Chloe', 85), ('Chloe', 90), ('Eli', 60);

-- LEFT JOIN: 5 rows. Chloe appears twice because she has two submissions.
-- Anna and Dev have NULL submissions.
SELECT s.student AS student,
su.student AS submitted
FROM students AS s
LEFT JOIN submissions AS su
ON s.student = su.student;


-- RIGHT JOIN: 4 rows. Eli has a NULL student because she is not on the students list.
SELECT s.student AS student,
su.student AS submitted
FROM students AS s
RIGHT JOIN submissions AS su
ON s.student = su.student;

-- Rows in students with no match in submissions -> Anna, Dev
SELECT s.student AS student,
su.student AS submitted
FROM students AS s
LEFT JOIN submissions AS su
ON s.student = su.student
WHERE su.student IS NULL;

-- Rows in submissions with no match in students -> Eli
SELECT s.student AS student,
su.student AS submitted
FROM students AS s
RIGHT JOIN submissions AS su
ON s.student = su.student
WHERE s.student IS NULL;

-- FULL JOIN: customers and orders (reconciliation)
-- Status count: Matched 7, No order 2, Orphan order 1 (total 10)
SELECT
CASE
WHEN c.customer_id IS NULL THEN 'Orphan order'
WHEN o.order_id IS NULL THEN 'No order'
ELSE 'Matched'
END AS match_status,
COUNT(*) AS num_rows
FROM customers AS c
FULL JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY match_status
ORDER BY num_rows DESC;

-- Full anti-join: unmatched rows from both sides -> Dinesh, Farhan, order 108 (3 rows)
SELECT c.customer_id, o.order_id, o.amount
FROM customers AS c
FULL JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL OR o.order_id IS NULL;


-- SELF JOIN: employees and their managers
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (emp_id INT PRIMARY KEY, name TEXT, manager_id INT);
INSERT INTO employees VALUES
(1, 'Kamal', NULL), (2, 'Nimali', 1), (3, 'Ruwan', 1),
(4, 'Sachini', 2), (5, 'Tharindu', 2), (6, 'Udara', 3);

-- e = the employee, m = their manager.
-- INNER JOIN: 5 rows. Kamal is missing because his manager_id is NULL.
SELECT e.name AS employee, m.name AS manager
FROM employees AS e
INNER JOIN employees AS m
ON e.manager_id = m.emp_id;

-- LEFT JOIN: 6 rows. Kamal appears with 'No manager'.
SELECT e.name AS employee, COALESCE(m.name, 'No manager') AS manager
FROM employees AS e
LEFT JOIN employees AS m
ON e.manager_id = m.emp_id;

-- Direct reports per manager -> Kamal 2, Nimali 2, Ruwan 1
SELECT m.emp_id, m.name AS manager, COUNT(e.emp_id) AS direct_reports
FROM employees AS e
INNER JOIN employees AS m
ON e.manager_id = m.emp_id
GROUP BY m.emp_id, m.name
ORDER BY direct_reports DESC, manager;

-- Rows in e with no match in m (who has no manager) -> Kamal
SELECT e.emp_id, e.name AS has_no_manager
FROM employees AS e
LEFT JOIN employees AS m
ON e.manager_id = m.emp_id
WHERE m.emp_id IS NULL;

-- Rows in r with no match in e (who manages nobody) -> Sachini, Tharindu, Udara
SELECT r.emp_id, r.name AS manages_nobody
FROM employees AS r
LEFT JOIN employees AS e
ON e.manager_id = r.emp_id
WHERE e.emp_id IS NULL;
