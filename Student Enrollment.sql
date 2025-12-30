/* =====================================================
   STUDENT ENROLLMENT DATABASE
   ===================================================== */

-- -----------------------------------------------------
-- 1. DATABASE CREATION
-- -----------------------------------------------------
DROP DATABASE IF EXISTS Student_enrollment;
CREATE DATABASE Student_enrollment;
USE Student_enrollment;

-- -----------------------------------------------------
-- 2. TABLE CREATION
-- -----------------------------------------------------

CREATE TABLE STUDENT (
    regno VARCHAR(40) PRIMARY KEY,
    name VARCHAR(100),
    major VARCHAR(100),
    bdate DATE
);

CREATE TABLE COURSE (
    course INT PRIMARY KEY,
    cname VARCHAR(100),
    dept VARCHAR(100)
);

CREATE TABLE TEXT (
    book_ISBN INT PRIMARY KEY,
    title VARCHAR(100),
    publisher VARCHAR(100),
    author VARCHAR(100)
);

CREATE TABLE ENROLL (
    regno VARCHAR(40),
    course INT,
    sem INT,
    marks INT,
    FOREIGN KEY (regno) REFERENCES STUDENT(regno),
    FOREIGN KEY (course) REFERENCES COURSE(course)
);

CREATE TABLE BOOK_ADOPTION (
    course INT,
    sem INT,
    book_ISBN INT,
    FOREIGN KEY (course) REFERENCES COURSE(course),
    FOREIGN KEY (book_ISBN) REFERENCES TEXT(book_ISBN)
);

-- -----------------------------------------------------
-- 3. INSERT SAMPLE DATA
-- -----------------------------------------------------

INSERT INTO STUDENT VALUES
('01HF235','Student_1','CSE','2001-05-15'),
('01HF354','Student_2','Literature','2002-06-10'),
('01HF254','Student_3','Philosophy','2000-04-04'),
('01HF653','Student_4','History','2003-10-12'),
('01HF234','Student_5','Computer Economics','2001-10-10');

INSERT INTO COURSE VALUES
(1,'DBMS','CS'),
(2,'Literature','English'),
(3,'Philosophy','Philosophy'),
(4,'History','Social Science'),
(5,'Computer Economics','CS');

INSERT INTO TEXT VALUES
(241563,'Operating Systems','Pearson','Silberschatz'),
(532678,'Complete Works of Shakespeare','Oxford','Shakespeare'),
(453723,'Immanuel Kant','Delphi Classics','Immanuel Kant'),
(278345,'History of the World','The Times','Richard Overy'),
(426784,'Behavioural Economics','Pearson','David Orrel'),
(469691,'Code with Fun','Pearson','David Warner');

INSERT INTO ENROLL VALUES
('01HF235',1,5,85),
('01HF354',2,6,87),
('01HF254',3,3,95),
('01HF653',4,3,80),
('01HF234',5,5,75);

INSERT INTO BOOK_ADOPTION VALUES
(1,5,241563),
(1,5,426784),
(1,5,469691),
(2,6,532678),
(3,3,453723),
(4,3,278345);

-- -----------------------------------------------------
-- QUERY 1: Demonstrate how you add a new text book to the database and make this book be adopted by some department. 
-- -----------------------------------------------------
INSERT INTO TEXT VALUES
(987654,'New Textbook','Delphi Classics','New Author');

INSERT INTO BOOK_ADOPTION VALUES
(3,3,987654);

-- -----------------------------------------------------
-- QUERY 2:  Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical order for courses offered by the ‘CS’ department that use more than two books.
-- -----------------------------------------------------
SELECT BA.course, BA.book_ISBN, T.title
FROM BOOK_ADOPTION BA
JOIN COURSE C ON BA.course = C.course
JOIN TEXT T ON BA.book_ISBN = T.book_ISBN
WHERE C.dept = 'CS'
AND BA.course IN (
    SELECT course
    FROM BOOK_ADOPTION
    GROUP BY course
    HAVING COUNT(book_ISBN) > 2
)
ORDER BY T.title;

-- -----------------------------------------------------
-- QUERY 3: List any department that has all its adopted books published by a specific publisher.
-- -----------------------------------------------------
SELECT DISTINCT dept
FROM COURSE
WHERE dept IN (
    SELECT dept
    FROM COURSE
    JOIN BOOK_ADOPTION USING(course)
    JOIN TEXT USING(book_ISBN)
    WHERE publisher = 'Delphi Classics'
)
AND dept NOT IN (
    SELECT dept
    FROM COURSE
    JOIN BOOK_ADOPTION USING(course)
    JOIN TEXT USING(book_ISBN)
    WHERE publisher <> 'Delphi Classics'
);

-- -----------------------------------------------------
-- QUERY 4: List the students who have scored maximum marks in ‘DBMS’ course.

-- -----------------------------------------------------
SELECT S.regno, S.name, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course = C.course
WHERE C.cname = 'DBMS'
ORDER BY E.marks DESC
LIMIT 1;

-- -----------------------------------------------------
-- QUERY 5:. Create a view to display all the courses opted by a student along with marks obtained.
-- -----------------------------------------------------
CREATE OR REPLACE VIEW StudentCourses AS
SELECT S.regno, S.name, C.cname, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course = C.course;

SELECT * FROM StudentCourses;

-- -----------------------------------------------------
-- QUERY 6:  Create a trigger that prevents a student from enrolling in a course if the marks prerequisite is less than 40. 

-------------------------------------------------------

DELIMITER //

CREATE TRIGGER PreventEnrollment
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    -- Check marks condition
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Marks prerequisite not met for enrollment';
    END IF;
END;
//

-- Reset delimiter back to default
DELIMITER ;

---------------------------------------------------------
-- TESTING THE TRIGGER
---------------------------------------------------------

-- Insert a new student
INSERT INTO STUDENT (regno, name, major, bdate)
VALUES ('01HF999', 'John Doe', 'Computer Science', '2000-01-01');

-- Attempt to enroll student with marks < 40
-- This insertion will FAIL due to trigger
INSERT INTO ENROLL (regno, course, sem, marks)
VALUES ('01HF999', 1, 7, 32);

