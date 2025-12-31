
/* ============================================================
   DATABASE CREATION
   ============================================================ */

DROP DATABASE IF EXISTS company;
CREATE DATABASE company;
USE company;


/* ============================================================
   TABLE CREATION
   ============================================================ */

/* ------------------------------------------------------------
   EMPLOYEE TABLE
   - SSN : Primary Key
   - SuperSSN : Supervisor SSN
   - DNo : Department Number
   ------------------------------------------------------------ */
CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY,
    EName VARCHAR(100),
    Address VARCHAR(100),
    Sex VARCHAR(10),
    Salary DECIMAL(10,2),
    SuperSSN INT,
    DNo INT
);


/* ------------------------------------------------------------
   DEPARTMENT TABLE
   - DNo : Primary Key
   - MgrSSN : Manager SSN (FK → EMPLOYEE)
   ------------------------------------------------------------ */
CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(100),
    MgrSSN INT,
    MgrStartDate DATE,
    FOREIGN KEY (MgrSSN)
        REFERENCES EMPLOYEE(SSN)
        ON DELETE CASCADE
);


/* ------------------------------------------------------------
   DLOCATION TABLE
   - Stores department locations
   ------------------------------------------------------------ */
CREATE TABLE DLOCATION (
    DNo INT PRIMARY KEY,
    DLoc VARCHAR(200),
    FOREIGN KEY (DNo)
        REFERENCES DEPARTMENT(DNo)
        ON DELETE CASCADE
);


/* ------------------------------------------------------------
   PROJECT TABLE
   - Each project is controlled by one department
   ------------------------------------------------------------ */
CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(50),
    PLocation VARCHAR(100),
    DNo INT,
    FOREIGN KEY (DNo)
        REFERENCES DEPARTMENT(DNo)
        ON DELETE CASCADE
);


/* ------------------------------------------------------------
   WORKS_ON TABLE
   - Represents M:N relationship between EMPLOYEE and PROJECT
   ------------------------------------------------------------ */
CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours DECIMAL(6,2),
    FOREIGN KEY (SSN)
        REFERENCES EMPLOYEE(SSN)
        ON DELETE CASCADE,
    FOREIGN KEY (PNo)
        REFERENCES PROJECT(PNo)
        ON DELETE CASCADE
);


/* ============================================================
   DATA INSERTION
   ============================================================ */

/* EMPLOYEE DATA */
INSERT INTO EMPLOYEE VALUES
(111,'Scott','1st Main','Male',700000,112,1),
(112,'Emma','2nd Main','Female',700000,NULL,1),
(113,'Starc','3rd Main','Male',700000,112,1),
(114,'Sophie','4th Main','Female',700000,112,1),
(115,'Smith','5th Main','Female',700000,112,1),
(116,'David','1st Main','Male',60000,112,2),
(117,'Tom','2nd Main','Female',150000,NULL,3),
(118,'Tim','3rd Main','Male',70000,112,4),
(119,'Yash','4th Main','Female',80000,112,5),
(110,'Smriti','5th Main','Female',90000,112,6);


/* DEPARTMENT DATA */
INSERT INTO DEPARTMENT VALUES
(1,'Accounts',113,'2020-01-10'),
(2,'Finance',114,'2020-02-10'),
(3,'Research',115,'2020-03-10'),
(4,'Sales',115,'2020-04-10'),
(5,'Production',112,'2020-05-10'),
(6,'Services',114,'2020-07-20');


/* DLOCATION DATA */
INSERT INTO DLOCATION VALUES
(1,'London'),
(2,'USA'),
(3,'Qatar'),
(4,'South Africa'),
(5,'Australia');


/* PROJECT DATA */
INSERT INTO PROJECT VALUES
(701,'Project1','London',1),
(702,'Project2','USA',2),
(703,'IoT','Qatar',3),
(704,'Internet','South Africa',4),
(705,'Project5','Australia',5);


/* WORKS_ON DATA */
INSERT INTO WORKS_ON VALUES
(111,701,120.1),
(112,702,130.21),
(113,703,130.41),
(114,704,150.21),
(115,705,90.89);


/* ============================================================
   QUERIES
   ============================================================ */

/* ------------------------------------------------------------
   1. List project numbers for projects that involve an employee
      named 'Scott' either as:
      - A worker, OR
      - Manager of controlling department
   ------------------------------------------------------------ */
SELECT DISTINCT P.PNo, P.PName
FROM PROJECT P
JOIN DEPARTMENT D ON P.DNo = D.DNo
JOIN EMPLOYEE E ON E.DNo = D.DNo
WHERE E.EName = 'Scott'
   OR D.MgrSSN = (SELECT SSN FROM EMPLOYEE WHERE EName = 'Scott');

/* ------------------------------------------------------------
   2. Give 10% salary raise to employees working on 'IoT' project
   ------------------------------------------------------------ */
UPDATE EMPLOYEE
SET Salary = Salary * 1.1
WHERE SSN IN (
    SELECT SSN
    FROM WORKS_ON
    WHERE PNo = (SELECT PNo FROM PROJECT WHERE PName = 'IoT' )
);
/* ------------------------------------------------------------
   3. Salary statistics of 'Accounts' department
      - SUM, MAX, MIN, AVG
   ------------------------------------------------------------ */
SELECT
    SUM(E.Salary) AS TotalSalary,
    MAX(E.Salary) AS MaxSalary,
    MIN(E.Salary) AS MinSalary,
    AVG(E.Salary) AS AvgSalary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
WHERE D.DName = 'Accounts';


/* ------------------------------------------------------------
   4. Employees who work on ALL projects of department 5
      (Using NOT EXISTS)
   ------------------------------------------------------------ */
SELECT E.EName
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo
    FROM PROJECT P
    WHERE P.DNo = 5
      AND NOT EXISTS (
          SELECT W.PNo
          FROM WORKS_ON W
          WHERE W.SSN = E.SSN
            AND W.PNo = P.PNo
      )
);


/* ------------------------------------------------------------
   5. Departments having >= 5 employees
      earning more than Rs. 6,00,000
   ------------------------------------------------------------ */
SELECT DNo, COUNT(*) AS EmpCount
FROM EMPLOYEE
WHERE Salary > 600000
GROUP BY DNo
HAVING COUNT(*) >= 5;


/* ------------------------------------------------------------
   6. View showing employee name, department name and location
   ------------------------------------------------------------ */
CREATE OR REPLACE VIEW EmployeeView AS
SELECT E.EName, D.DName AS Department, DL.DLoc AS Location
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo=D.DNo
JOIN DLOCATION DL ON D.DNo=DL.DNo;

/* ------------------------------------------------------------
   7. Trigger to prevent deleting a project
      if employees are working on it
   ------------------------------------------------------------ */
DELIMITER //

CREATE TRIGGER Prevent_Project_Delete
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM WORKS_ON WHERE PNo = OLD.PNo) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='Project cannot be deleted as employees are assigned';
    END IF;
END;
//

DELIMITER ;