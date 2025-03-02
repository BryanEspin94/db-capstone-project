USE LittleLemonDB;

SHOW TABLES;

#Step 1 - Insert data into Customer_details Table
INSERT INTO Customer_Details (FirstName, LastName, PhoneNumber, Email) VALUES
('Alice', 'Johnson', '555-1234', 'alice@example.com'),
('Bob', 'Smith', '555-5678', 'bob@example.com'),
('Charlie', 'Brown', '555-8765', 'charlie@example.com');

SELECT *
FROM Customer_Details;

#Step 2 - Insert Data into Staff_Information Table
INSERT INTO Staff_Information (FirstName, LastName, Role, Salary) VALUES
('John', 'Doe', 'Waiter', 25000.00),
('Emma', 'White', 'Chef', 40000.00),
('Liam', 'Black', 'Manager', 50000.00);

#Step 3 - Insert Data into Bookings Table
INSERT INTO Bookings (CustomerID, TableNumber, BookingDate) VALUES
(1, 5, '2025-03-01'),
(2, 3, '2025-03-02'),
(3, 1, '2025-03-03');

#Step 4 - Insert Data into Menu Table
INSERT INTO Menu (ItemName, Category, Price) VALUES
('Caesar Salad', 'Starters', 6.99),
('Grilled Chicken', 'Courses', 12.99),
('Spaghetti Carbonara', 'Courses', 10.99),
('Chocolate Cake', 'Desserts', 5.99),
('Espresso', 'Drinks', 3.99);

SELECT *
FROM Menu;

#Step 5 - Insert Data into Orders Table
INSERT INTO Orders (CustomerID, StaffID, OrderDate, TotalCost) VALUES
(1, 1, '2025-03-01', 0.00),
(2, 2, '2025-03-02', 0.00),
(3, 3, '2025-03-03', 0.00);

#Step 6 - Insert Data into Order_Items Table
INSERT INTO Order_Items (OrderID, MenuID, Quantity, ItemPrice) VALUES
(1, 1, 2, 6.99),  /* 2 Caesar Salads */
(1, 3, 1, 10.99), /* 1 Spaghetti Carbonara */
(2, 2, 1, 12.99), /* 1 Grilled Chicken */
(2, 4, 1, 5.99),  /* 1 Chocolate Cake */
(3, 5, 2, 3.99);  /* 2 Espressos */

#Step 7 - Insert Data into Order_Items Table
INSERT INTO Order_Delivery_Status (OrderID, DeliveryDate, Status) VALUES
(1, '2025-03-01', 'New Order'),
(2, '2025-03-02', 'Preparing'),
(3, '2025-03-03', 'Delivered');

SELECT * FROM Customer_Details;
SELECT * FROM Staff_Information;
SELECT * FROM Bookings;
SELECT * FROM Menu;
SELECT * FROM Orders;
SELECT * FROM Order_Items;
SELECT * FROM Order_Delivery_Status;





