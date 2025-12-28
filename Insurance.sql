-- =========================================
-- Create Tables
-- =========================================

CREATE TABLE person (
    driver_id VARCHAR(255) PRIMARY KEY,
    driver_name TEXT NOT NULL,
    address TEXT NOT NULL
);

CREATE TABLE car (
    reg_no VARCHAR(255) PRIMARY KEY,
    model TEXT NOT NULL,
    c_year INT
);

CREATE TABLE accident (
    report_no INT PRIMARY KEY,
    accident_date DATE,
    location TEXT
);

CREATE TABLE owns (
    driver_id VARCHAR(255),
    reg_no VARCHAR(255),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE participated (
    driver_id VARCHAR(255),
    reg_no VARCHAR(255),
    report_no INT,
    damage_amount FLOAT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id),
    FOREIGN KEY (reg_no) REFERENCES car(reg_no),
    FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

-- =========================================
-- Insert Data
-- =========================================

INSERT INTO person (driver_id, driver_name, address) VALUES
('D111', 'Driver_1', 'Kuvempunagar, Mysuru'),
('D222', 'Smith', 'JP Nagar, Mysuru'),
('D333', 'Driver_3', 'Udaygiri, Mysuru'),
('D444', 'Driver_4', 'Rajivnagar, Mysuru'),
('D555', 'Driver_5', 'Vijayanagar, Mysore');

SELECT * FROM person;

INSERT INTO car (reg_no, model, c_year) VALUES
('KA-20-AB-4223', 'Swift', 2020),
('KA-20-BC-5674', 'Mazda', 2017),
('KA-21-AC-5473', 'Alto', 2015),
('KA-21-BD-4728', 'Triber', 2019),
('KA-09-MA-1234', 'Tiago', 2018);

SELECT * FROM car;

INSERT INTO accident (report_no, accident_date, location) VALUES
(43627, '2020-04-05', 'Nazarbad, Mysuru'),
(56345, '2019-12-16', 'Gokulam, Mysuru'),
(63744, '2020-05-14', 'Vijaynagar, Mysuru'),
(54634, '2019-08-30', 'Kuvempunagar, Mysuru'),
(65738, '2021-01-21', 'JSS Layout, Mysuru'),
(66666, '2021-01-21', 'JSS Layout, Mysuru'),
(45562, '2024-04-05', 'Mandya'),
(49999, '2024-04-05', 'Kolkatta');

SELECT * FROM accident;

INSERT INTO owns (driver_id, reg_no) VALUES
('D111', 'KA-20-AB-4223'),
('D222', 'KA-20-BC-5674'),
('D333', 'KA-21-AC-5473'),
('D444', 'KA-21-BD-4728'),
('D222', 'KA-09-MA-1234');

SELECT * FROM owns;

INSERT INTO participated (driver_id, reg_no, report_no, damage_amount) VALUES
('D111', 'KA-20-AB-4223', 43627, 20000),
('D222', 'KA-20-BC-5674', 56345, 49500),
('D333', 'KA-21-AC-5473', 63744, 15000),
('D444', 'KA-21-BD-4728', 54634, 5000),
('D222', 'KA-09-MA-1234', 65738, 25000),
('D222', 'KA-21-BD-4728', 45562, 50000),
('D222', 'KA-21-BD-4728', 49999, 50000);

SELECT * FROM participated;

-- =========================================
-- Query 1: Total number of people involved in accidents in 2021
-- =========================================

SELECT COUNT(*)
FROM accident
JOIN participated USING (report_no)
WHERE accident_date = 2021;


-- =========================================
-- Query 2: Number of accidents involving Smith's cars
-- =========================================

SELECT COUNT(*)
FROM accident
JOIN participated USING (report_no)
JOIN person USING (driver_id)
WHERE person.driver_name = 'Smith';

-- =========================================
-- Query 3: Add a new accident
-- =========================================

INSERT INTO accident VALUES
(46969, '2024-04-05', 'Mandya');

-- =========================================
-- Query 4: Delete Mazda belonging to Smith
-- =========================================

DELETE FROM car
WHERE model = 'Mazda'
AND reg_no IN (
    SELECT reg_no
    FROM owns
    JOIN person USING (driver_id)
    WHERE driver_name = 'Smith'
);

-- =========================================
-- Query 5: Update damage amount
-- =========================================

UPDATE participated
SET damage_amount = 2000
WHERE reg_no = 'KA-09-MA-1234'
AND report_no = 65738;

-- =========================================
-- Query 6: View showing cars involved in accidents
-- =========================================

CREATE OR REPLACE VIEW AccidentCars AS
SELECT DISTINCT model, c_year
FROM car
JOIN participated USING (reg_no);


SELECT * FROM AccidentCars;

-- =========================================
-- Query 7: Trigger to limit accidents per driver per year
-- =========================================

DELIMITER //

CREATE TRIGGER PreventParticipation
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN
    DECLARE acc_count INT;

    SELECT COUNT(*)
    INTO acc_count
    FROM participated p
    JOIN accident a ON p.report_no = a.report_no
    WHERE p.driver_id = NEW.driver_id
      AND YEAR(a.accident_date) = (
            SELECT YEAR(accident_date)
            FROM accident
            WHERE report_no = NEW.report_no
        );

    IF acc_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver already involved in 3 accidents in this year';
    END IF;
END;
//

DELIMITER ;


--check trigger 
INSERT INTO accident VALUES
(99999, '2024-04-05', 'Kolkata');


--check trigger 
INSERT INTO participated VALUES
('D222', 'KA-20-AB-4223', 99999, 20000);
