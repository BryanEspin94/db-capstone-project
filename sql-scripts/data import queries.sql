-- ===================================================
-- 1. Inserting Customer Data
-- ===================================================
INSERT INTO Customer_Details (FirstName, LastName, PhoneNumber, Email)
VALUES
    ('John', 'Doe', '555-0001', 'john.doe@example.com'),
    ('Jane', 'Doe', '555-0002', 'jane.doe@example.com'),
    ('Bob', 'Smith', '555-0003', 'bob.smith@example.com'),
    ('Alice', 'Johnson', '555-0004', 'alice.johnson@example.com'),
    ('Charlie', 'Brown', '555-0005', 'charlie.brown@example.com'),
    ('David', 'Taylor', '555-0006', 'david.taylor@example.com'),
    ('Emily', 'White', '555-0007', 'emily.white@example.com'),
    ('Frank', 'Miller', '555-0008', 'frank.miller@example.com'),
    ('Grace', 'Wilson', '555-0009', 'grace.wilson@example.com'),
    ('Hannah', 'Moore', '555-0010', 'hannah.moore@example.com');

-- ===================================================
-- 2. Inserting Table Data
-- ===================================================
INSERT INTO `Tables` (TableNumber, Capacity, IsAvailable) 
VALUES 
    (1, 4, 1), (2, 4, 1), (3, 2, 1), (4, 2, 1), (5, 4, 1),
    (6, 4, 1), (7, 2, 1), (8, 2, 1), (9, 4, 1), (10, 4, 1),
    (11, 2, 1), (12, 2, 1), (13, 4, 1), (14, 4, 1), (15, 2, 1),
    (16, 2, 1), (17, 4, 1), (18, 4, 1), (19, 2, 1), (20, 2, 1),
    (21, 4, 1), (22, 4, 1), (23, 2, 1), (24, 2, 1), (25, 4, 1),
    (26, 4, 1), (27, 2, 1), (28, 2, 1), (29, 4, 1), (30, 4, 1),
    (31, 2, 1), (32, 2, 1), (33, 4, 1), (34, 4, 1), (35, 2, 1),
    (36, 2, 1), (37, 4, 1), (38, 4, 1), (39, 2, 1), (40, 2, 1),
    (41, 4, 1), (42, 4, 1), (43, 2, 1), (44, 2, 1), (45, 4, 1),
    (46, 4, 1), (47, 2, 1), (48, 2, 1), (49, 4, 1), (50, 4, 1);

-- ===================================================
-- 3. Inserting Staff Data
-- ===================================================
INSERT INTO Staff_Information (FirstName, LastName, Role, Salary)
VALUES
    ('John', 'Doe', 'Waiter', 1500.00),
    ('Jane', 'Smith', 'Chef', 2000.00),
    ('Bob', 'Johnson', 'Manager', 2500.00),
    ('Alice', 'Williams', 'Waiter', 1500.00),
    ('Charlie', 'Brown', 'Chef', 2000.00),
    ('David', 'Taylor', 'Cleaner', 1200.00),
    ('Emily', 'White', 'Waiter', 1500.00),
    ('Frank', 'Miller', 'Manager', 2500.00),
    ('Grace', 'Wilson', 'Waiter', 1500.00),
    ('Hannah', 'Moore', 'Chef', 2000.00);

-- ===================================================
-- 4. Inserting Bookings
-- ===================================================
INSERT INTO Bookings (CustomerID, BookingDate, TableID, Status)
VALUES
    (9, '2025-03-15', 1, 'New Booking'),
    (10, '2025-03-15', 2, 'New Booking'),
    (11, '2025-03-15', 3, 'New Booking'),
    (12, '2025-03-16', 4, 'New Booking'),
    (13, '2025-03-16', 5, 'New Booking');

-- ===================================================
-- 5. Inserting Orders from Bookings
-- ===================================================
INSERT INTO Orders (CustomerID, StaffID, OrderDate, TotalCost, BookingID)
SELECT 
    b.CustomerID, 
    CASE 
        WHEN b.BookingID % 2 = 0 THEN 13  -- Assign to Emily White
        ELSE 25  -- Assign to Grace Wilson
    END AS Assigned_Staff,
    CURDATE() AS OrderDate, 
    0.00 AS TotalCost, 
    b.BookingID
FROM Bookings b
LEFT JOIN Orders o ON b.BookingID = o.BookingID
WHERE b.BookingDate = CURDATE() 
AND o.OrderID IS NULL;  -- Ensures no duplicate orders

-- ===================================================
-- 6. Adding Order Items Using AddMultipleItemsToOrder Procedure
-- ===================================================
CALL AddMultipleItemsToOrder(153, '12,14,18', '2,1,3');
CALL AddMultipleItemsToOrder(154, '22,26,35', '1,2,1');
CALL AddMultipleItemsToOrder(155, '41,45,52', '1,1,2');
CALL AddMultipleItemsToOrder(156, '30,32,38', '1,3,2');
CALL AddMultipleItemsToOrder(157, '19,25,43', '2,1,1');
CALL AddMultipleItemsToOrder(158, '11,13,16', '1,1,1');

-- ===================================================
-- 7. Updating Order Status
-- ===================================================
CALL UpdateOrderStatus(153, 'Delivered', 'John Doe');
CALL UpdateOrderStatus(154, 'Delivered', 'John Doe');
CALL UpdateOrderStatus(155, 'Delivered', 'John Doe');
CALL UpdateOrderStatus(156, 'Delivered', 'John Doe');
CALL UpdateOrderStatus(157, 'Delivered', 'Emily White');
CALL UpdateOrderStatus(158, 'Delivered', 'Grace Wilson');


/*
How to Use This Script
	1.	Run the script in sequence – Insert customers first, then tables, staff, bookings, orders, and finally, order items.
	2.	Stored Procedures – Ensure that the AddMultipleItemsToOrder and UpdateOrderStatus procedures exist before running this script.
	3.	Check Data After Execution
	•	SELECT * FROM Orders; to verify that orders have been created.
	•	SELECT * FROM Order_Items; to ensure items were added correctly.
	•	SELECT * FROM Bookings; to confirm booking data.
*/
