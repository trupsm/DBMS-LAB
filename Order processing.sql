
/* ================================
   ORDER PROCESSING DATABASE
   ================================ */

-- Drop and create database
DROP DATABASE IF EXISTS Order_processing;
CREATE DATABASE Order_processing;
USE Order_processing;

-- ================================
-- CUSTOMER TABLE
-- ================================
CREATE TABLE Customer (
    cust INT PRIMARY KEY,
    cname VARCHAR(100),
    city VARCHAR(100)
);

-- ================================
-- ORDER TABLE
-- ================================
CREATE TABLE Order_ (
    order_ INT PRIMARY KEY,
    odate DATE,
    cust INT,
    order_amt INT,
    FOREIGN KEY (cust)REFERENCES Customer(cust)
    ON DELETE CASCADE
);

-- ================================
-- ITEM TABLE
-- ================================
CREATE TABLE Item (
    item INT PRIMARY KEY,
    unitprice INT
);

-- ================================
-- ORDERITEM (CONNECTOR ENTITY)
-- ================================
CREATE TABLE OrderItem (
    order_ INT,
    item INT,
    qty INT,
    PRIMARY KEY (order_, item),
    FOREIGN KEY (order_)REFERENCES Order_(order_)
        ON DELETE CASCADE,
    FOREIGN KEY (item)REFERENCES Item(item)
        ON DELETE CASCADE
);

-- ================================
-- WAREHOUSE TABLE
-- ================================
CREATE TABLE Warehouse (
    warehouse INT PRIMARY KEY,
    city VARCHAR(100)
);

-- ================================
-- SHIPMENT TABLE
-- ================================
CREATE TABLE Shipment (
    order_ INT,
    warehouse INT,
    ship_date DATE,
    PRIMARY KEY (order_, warehouse),
    FOREIGN KEY (order_)REFERENCES Order_(order_)
        ON DELETE CASCADE,
    FOREIGN KEY (warehouse)REFERENCES Warehouse(warehouse)
        ON DELETE CASCADE
);

-- ================================
-- INSERT DATA INTO CUSTOMER
-- ================================
INSERT INTO Customer VALUES
(101, 'Kumar', 'Bangalore'),
(102, 'Peter', 'Chennai'),
(103, 'James', 'Mumbai'),
(104, 'Kevin', 'Delhi'),
(105, 'Harry', 'Pune');

-- ================================
-- INSERT DATA INTO ORDER
-- ================================
INSERT INTO Order_ VALUES
(201, '2023-04-11', 101, 1500),
(202, '2023-04-12', 102, 2500),
(203, '2023-04-13', 103, 3500),
(204, '2023-04-14', 104, 4500),
(205, '2023-04-15', 105, 5500);

-- ================================
-- INSERT DATA INTO ITEM
-- ================================
INSERT INTO Item VALUES
(1001, 100),
(1002, 200),
(1003, 300),
(1004, 400),
(1005, 500);

-- ================================
-- INSERT DATA INTO ORDERITEM
-- ================================
INSERT INTO OrderItem VALUES
(201, 1001, 10),
(202, 1002, 5),
(203, 1003, 7),
(204, 1004, 3),
(205, 1005, 11);

-- ================================
-- INSERT DATA INTO WAREHOUSE
-- ================================
INSERT INTO Warehouse VALUES
(1, 'Bangalore'),
(2, 'Chennai'),
(3, 'Mumbai'),
(4, 'Delhi'),
(5, 'Pune');

-- ================================
-- INSERT DATA INTO SHIPMENT
-- ================================
INSERT INTO Shipment VALUES
(201, 1, '2023-05-01'),
(202, 2, '2023-05-02'),
(203, 3, '2023-05-03'),
(204, 4, '2023-05-04'),
(205, 5, '2023-05-05');

-- ================================
-- QUERY 1: List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
-- ================================
SELECT order_, ship_date
FROM Shipment
WHERE warehouse = 2;

-- ================================
-- QUERY 2: List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#.
-- ================================
SELECT o.order_, s.warehouse
FROM Order_ o
JOIN Shipment s ON o.order_ = s.order_
JOIN Customer c ON o.cust = c.cust
WHERE c.cname = 'Kumar';

-- ================================
-- QUERY 3: Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer and the last column is the average order amount for that customer. (Use aggregate functions) 
-- ================================
SELECT c.cname,
      COUNT(o.order_) AS no_of_orders,
      AVG(o.order_amt) AS avg_order_amt
FROM Customer c
JOIN Order_ o ON c.cust = o.cust
GROUP BY c.cname;

-- ================================
-- QUERY 4: Delete all orders for customer named "Kumar". 
-- ================================
DELETE FROM Order_
WHERE cust = (
    SELECT cust FROM Customer WHERE cname = 'Kumar'
);

-- ================================
-- QUERY 5:Find the item with the maximum unit price. 
-- ================================
SELECT item, unitprice
FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

-- ================================
-- QUERY 6: A trigger that updates order_amout based on quantity and unitprice of order_item
-- ================================
DELIMITER //

CREATE TRIGGER update_order_amount
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    UPDATE Order_
    SET order_amt =
        NEW.qty * (SELECT unitprice FROM Item WHERE item = NEW.item)
    WHERE order_ = NEW.order_;
END;
//

DELIMITER ;

-- ==========================================
-- TESTING THE TRIGGER
-- ==========================================

-- Insert a new item
INSERT INTO Item (item, unitprice)
VALUES (1006, 600);

-- Insert a new order (order_amt will be updated by trigger)
INSERT INTO Order_ (order_, odate, cust, order_amt)
VALUES (206, '2023-04-16', 102, NULL);

-- Insert order item (this fires the trigger)
INSERT INTO OrderItem (order_, item, qty)
VALUES (206, 1006, 5);

-- Verify the updated order amount
SELECT *
FROM Order_;

-- ================================
-- QUERY 7:Create a view to display orderID and shipment date of all orders shipped from a warehouse 5.
-- ================================
CREATE OR REPLACE VIEW OrdersFromWarehouse5 AS
SELECT order_, ship_date
FROM Shipment
WHERE warehouse = 5;

SELECT * FROM OrdersFromWarehouse5;


