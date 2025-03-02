
-- Insert into Customer_Details
INSERT INTO Customer_Details (FirstName, LastName, PhoneNumber, Email) VALUES
('David', 'Miller', '555-1122', 'david.miller@example.com'),
('Sophia', 'Taylor', '555-3344', 'sophia.taylor@example.com'),
('Ethan', 'Wilson', '555-5566', 'ethan.wilson@example.com'),
('Olivia', 'Martinez', '555-7788', 'olivia.martinez@example.com'),
('Lucas', 'Anderson', '555-9900', 'lucas.anderson@example.com');

-- Insert into Staff_Information
INSERT INTO Staff_Information (FirstName, LastName, Role, Salary) VALUES
('Grace', 'Hall', 'Waitress', 25000.00),
('James', 'Young', 'Chef', 42000.00),
('Mia', 'King', 'Manager', 52000.00);

-- Insert into Bookings
INSERT INTO Bookings (CustomerID, TableNumber, BookingDate) VALUES
(4, 6, '2025-03-04'),
(5, 7, '2025-03-05'),
(6, 8, '2025-03-06'),
(7, 9, '2025-03-07'),
(8, 10, '2025-03-08');

-- Insert into Menu
INSERT INTO Menu (ItemName, Category, Price) VALUES
('Garlic Bread', 'Starters', 4.99),
('Tiramisu', 'Desserts', 6.50),
('Margarita Pizza', 'Courses', 11.99),
('Coke', 'Drinks', 2.99),
('Mushroom Risotto', 'Courses', 13.50);

-- Insert into Orders
INSERT INTO Orders (CustomerID, StaffID, OrderDate, TotalCost) VALUES
(4, 1, '2025-03-04', 0.00),
(5, 2, '2025-03-05', 0.00),
(6, 3, '2025-03-06', 0.00),
(7, 1, '2025-03-07', 0.00),
(8, 2, '2025-03-08', 0.00);

-- Insert into Order_Items
INSERT INTO Order_Items (OrderID, MenuID, Quantity, ItemPrice) VALUES
(4, 1, 3, 6.99),
(4, 4, 2, 5.99),
(5, 2, 1, 12.99),
(5, 5, 4, 3.99),
(6, 6, 2, 4.99),
(6, 7, 1, 6.50),
(7, 8, 2, 11.99),
(7, 9, 3, 2.99),
(8, 10, 1, 13.50);

-- Insert into Order_Delivery_Status
INSERT INTO Order_Delivery_Status (OrderID, DeliveryDate, Status) VALUES
(4, '2025-03-04', 'Preparing'),
(5, '2025-03-05', 'Delivered'),
(6, '2025-03-06', 'New Order'),
(7, '2025-03-07', 'Delivered'),
(8, '2025-03-08', 'Preparing');

