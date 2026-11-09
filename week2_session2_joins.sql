create table items_ordered (item text);
create table items_received (item text);

insert into items_ordered values ('Pen'), ('Ink'), ('Paper'), ('Stapler');
insert into items_received values ('Ink'), ('Paper'), ('Tape'), ('Glue');

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

CREATE TABLE students    (student TEXT);
CREATE TABLE submissions (student TEXT, score INT);

INSERT INTO students    VALUES ('Anna'), ('Ben'), ('Chloe'), ('Dev');
INSERT INTO submissions VALUES ('Ben', 70), ('Chloe', 85), ('Chloe', 90), ('Eli', 60);

-- LEFT JOIN: 5 rows. Chloe appears twice because she has two submissions
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

