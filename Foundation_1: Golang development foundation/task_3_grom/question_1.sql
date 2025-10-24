//
INSERT INTO students (name,age,grade)
VALUES ("Zhang San",20,"year 3");
//
Select * From students
where age > 18;
//
UPDATE students
SET year = "year 4"
WHERE name = "Zhang San";
//
DELETE FROM students
WHERE age < 15;
//