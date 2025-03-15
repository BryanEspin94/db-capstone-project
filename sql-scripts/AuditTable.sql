CREATE TABLE Audit_Log (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(50) NOT NULL,
    ActionType ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    RecordID INT NOT NULL,
    OldData TEXT NULL,
    NewData TEXT NULL,
    ActionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PerformedBy VARCHAR(100) NOT NULL
);

#Trigggers for automatically logging update and deletion of records

#Add DELETE Trigger for Bookingd
DELIMITER $$

CREATE TRIGGER log_delete_booking
AFTER DELETE ON Bookings
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
    VALUES ('Bookings', 'DELETE', OLD.BookingID, 
            CONCAT('Date: ', OLD.BookingDate, ', Table: ', OLD.TableNumber), 
            CURRENT_USER());
END $$

DELIMITER ;

#Add UPDATE Trigger for Order_Delivery_Status
DELIMITER $$

CREATE TRIGGER log_update_order_status
AFTER UPDATE ON Order_Delivery_Status
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', OLD.OrderID, 
            CONCAT('Old Status: ', OLD.Status), 
            CONCAT('New Status: ', NEW.Status), 
            CURRENT_USER());
END $$

DELIMITER ;

#Add INSERT for logs when a new order is placed
DELIMITER $$

CREATE TRIGGER log_insert_order
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
    VALUES ('Orders', 'INSERT', NEW.OrderID, 
            CONCAT('Customer: ', NEW.CustomerID, ', Staff: ', NEW.StaffID, ', Date: ', NEW.OrderDate, ', Total Cost: ', NEW.TotalCost), 
            CURRENT_USER());
END $$

DELIMITER ;

#Add UPDATE for logs when a booking is updated
DELIMITER $$

CREATE TRIGGER log_update_booking
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Bookings', 'UPDATE', OLD.BookingID, 
            CONCAT('Old Date: ', OLD.BookingDate, ', Old Table: ', OLD.TableNumber), 
            CONCAT('New Date: ', NEW.BookingDate, ', New Table: ', NEW.TableNumber), 
            CURRENT_USER());
END $$

DELIMITER ;

SHOW TRIGGERS FROM LittleLemonDB;

#Test 1
UPDATE Bookings 
SET BookingDate = '2025-03-15' 
WHERE BookingID = 2;
SELECT * FROM Audit_Log ORDER BY ActionTimestamp DESC;

#Test 2
DELETE FROM Bookings WHERE BookingID = 3;
SELECT * FROM Audit_Log ORDER BY ActionTimestamp DESC;

#Test 3
UPDATE Order_Delivery_Status
SET Status = 'Out for Delivery'
WHERE OrderID = 5;
SELECT * FROM Audit_Log ORDER BY ActionTimestamp DESC;

#Test 4
INSERT INTO Order_Items (OrderID, MenuID, Quantity, ItemPrice)
VALUES (6, 3, 2, 15.00);
SELECT OrderID, TotalCost FROM Orders WHERE OrderID = 6;

#Test 5
INSERT INTO Orders (CustomerID, StaffID, OrderDate, TotalCost)
VALUES (4, 3, '2025-03-12', 75.00);
SELECT * FROM Audit_Log ORDER BY ActionTimestamp DESC;

SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'LittleLemonDB';

CREATE INDEX idx_TableNumber ON Bookings (TableNumber);
CREATE INDEX idx_ActionType ON Audit_Log (ActionType);
CREATE INDEX idx_OrderStatus ON Order_Delivery_Status (Status);
CREATE INDEX idx_OrderDate ON Orders (OrderDate);

SHOW INDEX FROM Order_Delivery_Status;
DROP INDEX idx_Status ON Order_Delivery_Status;

SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'LittleLemonDB';

DROP INDEX MenuID_idx ON Order_Items;
DROP INDEX OrderID_idx ON Order_Items;