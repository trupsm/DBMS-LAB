-- ===============================
-- DATABASE & TABLE CREATION
-- ===============================

DROP DATABASE IF EXISTS sailors_db;
CREATE DATABASE sailors_db;
USE sailors_db;

-- Create SAILORS table
CREATE TABLE sailors (
    sid INT PRIMARY KEY,
    sname VARCHAR(50),
    rating DECIMAL(3,1),
    age INT
);

-- Create BOAT table
CREATE TABLE boat (
    bid INT PRIMARY KEY,
    bname VARCHAR(50),
    color VARCHAR(50)
);

-- Create RESERVES table
CREATE TABLE reserves (
    sid INT,
    bid INT,
    rdate DATE,
    FOREIGN KEY (sid) REFERENCES sailors(sid),
    FOREIGN KEY (bid) REFERENCES boat(bid)
);

-- ===============================
-- INSERT DATA
-- ===============================

INSERT INTO sailors VALUES
(1, 'Albert', 8, 41),
(2, 'Bob', 9, 45),
(3, 'Charlie', 9, 49),
(4, 'David', 8, 54),
(5, 'Eve', 7, 59);

SELECT * FROM sailors;

INSERT INTO boat VALUES
(101, 'Boat1', 'Red'),
(102, 'Boat2', 'Blue'),
(103, 'Boat3', 'Green'),
(104, 'Boat4', 'Yellow'),
(105, 'Boat5', 'White');

SELECT * FROM boat;

INSERT INTO reserves VALUES
(1, 101, '2023-01-01'),
(1, 102, '2023-02-01'),
(1, 103, '2023-03-01'),
(1, 104, '2023-04-01'),
(1, 105, '2023-05-01'),
(2, 101, '2023-02-01'),
(3, 101, '2023-03-01'),
(4, 101, '2023-04-01'),
(5, 101, '2023-05-01'),
(2, 102, '2023-02-01'),
(3, 103, '2023-03-01'),
(4, 104, '2023-04-01'),
(5, 105, '2023-05-01');

SELECT * FROM reserves;

-- ==================================================
-- QUERY 1: Colors of boats reserved by Albert
-- ==================================================

SELECT DISTINCT b.color
FROM boat b, sailors s, reserves r
WHERE s.sid = r.sid
  AND r.bid = b.bid
  AND s.sname = 'Albert';

-- ==================================================
-- QUERY 2: Sailor IDs with rating >= 8 OR reserved boat 103
-- ==================================================

SELECT sid
FROM sailors
WHERE rating >= 8

UNION

SELECT sid
FROM reserves
WHERE bid = 103;

-- ==================================================
-- QUERY 3: Sailors who did NOT reserve a "storm" boat
-- ==================================================

SELECT sname
FROM sailors
WHERE sid NOT IN (
    SELECT r.sid
    FROM boat b, reserves r
    WHERE b.bid = r.bid
      AND b.bname LIKE '%storm%'
)
ORDER BY sname;

-- ==================================================
-- QUERY 4: Sailors who reserved ALL boats
-- ==================================================

SELECT sname
FROM sailors s, reserves r
WHERE s.sid = r.sid
GROUP BY s.sid, s.sname
HAVING COUNT(DISTINCT r.bid) = (SELECT COUNT(*) FROM boat);

-- ==================================================
-- QUERY 5: Oldest sailor
-- ==================================================

SELECT sname, age
FROM sailors
WHERE age = (SELECT MAX(age) FROM sailors);

-- ==================================================
-- QUERY 6: Boats reserved by >= 5 sailors aged >= 40
-- ==================================================

SELECT bid, AVG(age) AS avg_age
FROM reserves NATURAL JOIN sailors
WHERE age >= 40
GROUP BY bid
HAVING COUNT(sid) >= 5;

-- ==================================================
-- QUERY 7: View for boats reserved by sailors with rating = 8
-- ==================================================

CREATE OR REPLACE VIEW boatrating8 AS
SELECT DISTINCT b.bname, b.color
FROM sailors s, reserves r, boat b
WHERE s.sid = r.sid
  AND r.bid = b.bid
  AND s.rating = 8;

-- Check view output
SELECT * FROM boatrating8;

-- ==================================================
-- QUERY 8: Trigger to prevent deleting boats with reservations
-- ==================================================

DELIMITER //

CREATE TRIGGER prevent_delete_active_reservations
BEFORE DELETE ON boat
FOR EACH ROW
BEGIN
    DECLARE reservation_count INT;

    SELECT COUNT(*)
    INTO reservation_count
    FROM reserves
    WHERE bid = OLD.bid;

    IF reservation_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete a boat with active reservations';
    END IF;
END;
//

DELIMITER ;

-- ==================================================
-- TRIGGER TEST
-- ==================================================

DELETE FROM boat WHERE bid = 103;
