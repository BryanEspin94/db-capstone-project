-- MySQL Workbench Forward Engineering

-- Disable checks temporarily to avoid issues during table creation
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Create schema (database) if not exists
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `LittleLemonDB` DEFAULT CHARACTER SET utf8mb3;
USE `LittleLemonDB`;

-- -----------------------------------------------------
-- Create Audit_Log table to track database changes
-- -----------------------------------------------------UpdateBooking
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Audit_Log` (
  `AuditID` INT NOT NULL AUTO_INCREMENT,
  `TableName` VARCHAR(50) NOT NULL,
  `ActionType` ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  `RecordID` INT NOT NULL,
  `OldData` TEXT NULL DEFAULT NULL,
  `NewData` TEXT NULL DEFAULT NULL,
  `ActionTimestamp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `PerformedBy` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`AuditID`)
) ENGINE = InnoDB AUTO_INCREMENT = 5 DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Create Customer_Details table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Customer_Details` (
  `CustomerID` INT NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(50) NOT NULL,
  `LastName` VARCHAR(50) NOT NULL,
  `PhoneNumber` VARCHAR(15) NOT NULL,
  `Email` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`CustomerID`),
  UNIQUE INDEX `PhoneNumber_UNIQUE` (`PhoneNumber`),
  UNIQUE INDEX `Email_UNIQUE` (`Email`)
) ENGINE = InnoDB AUTO_INCREMENT = 9 DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Create Bookings table to store booking information
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Bookings` (
  `BookingID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `TableNumber` INT NOT NULL,
  `BookingDate` DATE NOT NULL,
  PRIMARY KEY (`BookingID`),
  INDEX `CustomerID_idx` (`CustomerID`),
  INDEX `idx_BookingDate` (`BookingDate`),
  CONSTRAINT `fk_bookings_CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `LittleLemonDB`.`Customer_Details` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 32 DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Menu`
-- -----------------------------------------------------
-- This table stores menu items, each with a unique MenuID.
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Menu` (
  `MenuID` INT NOT NULL AUTO_INCREMENT, -- Unique ID for each menu item
  `ItemName` VARCHAR(100) NOT NULL, -- Name of the item
  `Category` ENUM('Starters', 'Courses', 'Drinks', 'Desserts') NOT NULL, -- Item category
  `Price` DECIMAL(10,2) NOT NULL, -- Price of the item
  PRIMARY KEY (`MenuID`) -- Primary key for MenuID
) ENGINE = InnoDB AUTO_INCREMENT = 11 DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Staff_Information`
-- -----------------------------------------------------
-- This table stores staff information with unique StaffID.
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Staff_Information` (
  `StaffID` INT NOT NULL AUTO_INCREMENT, -- Unique ID for staff
  `FirstName` VARCHAR(50) NOT NULL, -- Staff first name
  `LastName` VARCHAR(50) NOT NULL, -- Staff last name
  `Role` VARCHAR(45) NOT NULL, -- Staff role in the organization
  `Salary` DECIMAL(10,2) NOT NULL, -- Staff salary
  PRIMARY KEY (`StaffID`) -- Primary key for StaffID
) ENGINE = InnoDB AUTO_INCREMENT = 7 DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Orders`
-- -----------------------------------------------------
-- This table stores order details, linking customers and staff.
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Orders` (
  `OrderID` INT NOT NULL AUTO_INCREMENT, -- Unique ID for each order
  `CustomerID` INT NOT NULL, -- Customer placing the order
  `StaffID` INT NOT NULL, -- Staff handling the order
  `OrderDate` DATE NOT NULL, -- Date of the order
  `TotalCost` DECIMAL(10,2) NOT NULL, -- Total cost of the order
  PRIMARY KEY (`OrderID`), -- Primary key for OrderID
  INDEX `CustomerID_idx` (`CustomerID` ASC) VISIBLE, -- Index for CustomerID
  INDEX `StaffID_idx` (`StaffID` ASC) VISIBLE, -- Index for StaffID
  CONSTRAINT `fk_orders_CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `LittleLemonDB`.`Customer_Details` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE, -- Enforces relationship between Orders and Customer_Details
  CONSTRAINT `StaffID`
    FOREIGN KEY (`StaffID`)
    REFERENCES `LittleLemonDB`.`Staff_Information` (`StaffID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE -- Enforces relationship between Orders and Staff_Information
) ENGINE = InnoDB AUTO_INCREMENT = 10 DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Order_Delivery_Status`
-- -----------------------------------------------------
-- This table tracks the delivery status of orders.
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Order_Delivery_Status` (
  `DeliveryID` INT NOT NULL AUTO_INCREMENT, -- Unique ID for each delivery record
  `OrderID` INT NOT NULL, -- Associated OrderID
  `DeliveryDate` DATE NOT NULL, -- Date of delivery
  `Status` ENUM('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'New Order', -- Current status of the order
  PRIMARY KEY (`DeliveryID`), -- Primary key for DeliveryID
  INDEX `OrderID_idx` (`OrderID` ASC) VISIBLE, -- Index for OrderID
  INDEX `idx_Status` (`Status` ASC) VISIBLE, -- Index for Status
  CONSTRAINT `fk_order_delivery_orderid`
    FOREIGN KEY (`OrderID`)
    REFERENCES `LittleLemonDB`.`Orders` (`OrderID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE -- Enforces relationship between Order_Delivery_Status and Orders
) ENGINE = InnoDB AUTO_INCREMENT = 9 DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Order_Items`
-- -----------------------------------------------------
-- This table stores individual items within an order. Each record links to an order and a menu item.
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Order_Items` (
  `OrderItemID` INT NOT NULL AUTO_INCREMENT, -- Unique ID for each order item
  `OrderID` INT NOT NULL, -- Associated OrderID to link the item to an order
  `MenuID` INT NOT NULL, -- Associated MenuID to link the item to a specific menu item
  `Quantity` INT NOT NULL, -- Quantity of the menu item ordered
  `ItemPrice` DECIMAL(10,2) NOT NULL, -- Price of a single item
  `TotalItemCost` DECIMAL(10,2) GENERATED ALWAYS AS ((`Quantity` * `ItemPrice`)) STORED, -- Total cost for this item (calculated automatically)
  PRIMARY KEY (`OrderItemID`), -- Primary key for OrderItemID
  INDEX `OrderID_idx` (`OrderID` ASC) VISIBLE, -- Index to optimize searches by OrderID
  INDEX `MenuID_idx` (`MenuID` ASC) VISIBLE, -- Index to optimize searches by MenuID
  CONSTRAINT `fk_order_items_menuid`
    FOREIGN KEY (`MenuID`) -- Foreign key constraint to reference Menu table
    REFERENCES `LittleLemonDB`.`Menu` (`MenuID`)
    ON DELETE CASCADE -- When a menu item is deleted, corresponding order items will be deleted
    ON UPDATE CASCADE, -- When a menu item is updated, it will reflect in the order items
  CONSTRAINT `fk_order_items_orderid`
    FOREIGN KEY (`OrderID`) -- Foreign key constraint to reference Orders table
    REFERENCES `LittleLemonDB`.`Orders` (`OrderID`)
    ON DELETE CASCADE -- When an order is deleted, corresponding order items will be deleted
    ON UPDATE CASCADE -- When an order is updated, it will reflect in the order items
) ENGINE = InnoDB AUTO_INCREMENT = 18 DEFAULT CHARACTER SET = utf8mb3;

-- Switching back to the `LittleLemonDB` schema
USE `LittleLemonDB`;

-- -----------------------------------------------------
-- procedure AddValidBooking
-- -----------------------------------------------------
-- This procedure adds a booking for a table, ensuring that the table is available
-- on the requested date. If the table is already booked, it will decline the booking.
-- If the booking is successful, it logs the action in the Audit_Log table.
DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `AddValidBooking`(
    IN p_BookingDate DATE,      -- The date the booking is requested for
    IN p_TableNumber INT,       -- The table number to be booked
    IN p_CustomerID INT,        -- The ID of the customer making the booking
    IN p_PerformedBy VARCHAR(100) -- The user performing the booking
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to track if the table is already booked
    DECLARE newBookingID INT;             -- Variable to store the new booking ID after insertion

    -- Start a transaction to ensure the atomicity of the operation
    START TRANSACTION;

    -- Check if the table is already booked on the given date
    SELECT COUNT(*)
    INTO bookingExists
    FROM Bookings
    WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;

    -- If the table is already booked, rollback the transaction and inform the user
    IF bookingExists > 0 THEN
        ROLLBACK;  -- Undo all changes made during this transaction
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked.') AS BookingStatus;
    ELSE
        -- If the table is available, insert the booking into the Bookings table
        INSERT INTO Bookings (BookingDate, TableNumber, CustomerID)
        VALUES (p_BookingDate, p_TableNumber, p_CustomerID);

        -- Get the ID of the newly inserted booking
        SET newBookingID = LAST_INSERT_ID();

        -- Log the insertion action in the Audit_Log table
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
        VALUES ('Bookings', 'INSERT', newBookingID, 
                CONCAT('Date: ', p_BookingDate, ', Table: ', p_TableNumber, ', Customer: ', p_CustomerID), 
                p_PerformedBy);

        -- Commit the transaction, making all changes permanent
        COMMIT;

        -- Return a success message confirming the booking
        SELECT CONCAT('Booking confirmed for Table ', p_TableNumber, ' on ', p_BookingDate) AS BookingStatus;
    END IF;

END$$

-- -----------------------------------------------------
-- procedure CancelAllBookingsForDate
-- -----------------------------------------------------
-- This procedure cancels all bookings for a specified date.
-- It first counts the number of bookings for that date, deletes them,
-- and then returns the number of bookings canceled.
DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `CancelAllBookingsForDate`(
    IN p_BookingDate DATE  -- The date for which all bookings will be canceled
)
BEGIN
    DECLARE bookingsDeleted INT DEFAULT 0;  -- Variable to store the count of bookings deleted

    -- Count the number of bookings for the specified date before deletion
    SELECT COUNT(*)
    INTO bookingsDeleted
    FROM Bookings
    WHERE BookingDate = p_BookingDate;

    -- Delete all bookings for the specified date
    DELETE FROM Bookings
    WHERE BookingDate = p_BookingDate;

    -- Return the number of bookings canceled for the given date
    SELECT CONCAT(bookingsDeleted, ' bookings canceled for ', p_BookingDate) AS CancelStatus;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancelBooking
-- -----------------------------------------------------
-- This procedure cancels a booking based on its ID. It checks if the booking exists,
-- and if it does, it logs the deletion in the Audit_Log table, deletes the booking,
-- and commits the transaction. If the booking does not exist, it rolls back the transaction.
DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `CancelBooking`(
    IN p_BookingID INT,  -- The ID of the booking to be canceled
    IN p_PerformedBy VARCHAR(100)  -- The user performing the cancellation
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to check if the booking exists
    DECLARE oldData TEXT;  -- Variable to store the old booking data for logging

    -- Error Handling: This block ensures that in case of any SQL exceptions, the transaction is rolled back.
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- Rollback any changes in case of an error
        SELECT 'Error: Unable to cancel booking' AS ErrorMessage;  -- Return an error message
    END;

    -- Start the transaction to ensure atomicity
    START TRANSACTION;

    -- Check if the booking exists
    SELECT COUNT(*), CONCAT('Date: ', BookingDate, ', Table: ', TableNumber, ', Customer: ', CustomerID)
    INTO bookingExists, oldData
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- If the booking exists
    IF bookingExists > 0 THEN
        -- Log the delete operation in the Audit_Log before performing the deletion
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
        VALUES ('Bookings', 'DELETE', p_BookingID, oldData, p_PerformedBy);

        -- Delete the booking from the Bookings table
        DELETE FROM Bookings WHERE BookingID = p_BookingID;

        COMMIT;  -- Commit the transaction to make the changes permanent
        SELECT CONCAT('Booking ', p_BookingID, ' has been canceled successfully.') AS CancelStatus;  -- Return a success message
    ELSE
        ROLLBACK;  -- Rollback the transaction if the booking does not exist
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS CancelStatus;  -- Return a message indicating no booking was found
    END IF;

END$$

-- -----------------------------------------------------
-- procedure CancelOrder
-- -----------------------------------------------------
-- This procedure updates the status of an order to 'Cancelled'.
-- It takes an order ID and changes its status in the Order_Delivery_Status table.
DELIMITER $$

USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `CancelOrder`(IN order_id INT)
BEGIN
    -- Update the status of the order to 'Cancelled'
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = order_id;

    -- Return a confirmation message
    SELECT CONCAT('Order ', order_id, ' has been cancelled') AS Confirmation;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure ChangeBookingTable
-- -----------------------------------------------------
-- This procedure changes the table number for an existing booking.
-- It first checks if the new table is available on the existing booking date,
-- and if available, updates the booking with the new table number.
DELIMITER $$

USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `ChangeBookingTable`(
    IN p_BookingID INT,  -- Booking ID of the reservation to update
    IN p_NewTableNumber INT  -- New table number to be assigned
)
BEGIN
    DECLARE existingDate DATE;  -- Variable to hold the booking date of the current booking
    DECLARE tableBooked INT DEFAULT 0;  -- Variable to check if the new table is already booked

    -- Get the booking date for this booking
    SELECT BookingDate INTO existingDate
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- Check if the new table is already booked on that date
    SELECT COUNT(*)
    INTO tableBooked
    FROM Bookings
    WHERE BookingDate = existingDate
    AND TableNumber = p_NewTableNumber;

    -- If table is available, update the booking
    IF tableBooked = 0 THEN
        UPDATE Bookings
        SET TableNumber = p_NewTableNumber
        WHERE BookingID = p_BookingID;

        -- Return a success message with the new table number
        SELECT CONCAT('Booking ', p_BookingID, ' moved to Table ', p_NewTableNumber) AS ChangeStatus;
    ELSE
        -- Return a message if the table is already booked on the specified date
        SELECT CONCAT('Table ', p_NewTableNumber, ' is already booked on ', existingDate) AS ChangeStatus;
    END IF;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure CheckBooking
-- -----------------------------------------------------
-- This procedure checks if a specific table is available for a given booking date.
-- It returns whether the table is already booked or available on that date.
DELIMITER $$

USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `CheckBooking`(
    IN p_BookingDate DATE,  -- Date of the booking to check
    IN p_TableNumber INT  -- Table number to check availability for
)
BEGIN
    DECLARE bookingCount INT DEFAULT 0;  -- Variable to count bookings found

    -- Query to count how many times this table is booked on the given date
    SELECT COUNT(*)
    INTO bookingCount
    FROM Bookings
    WHERE BookingDate = p_BookingDate
    AND TableNumber = p_TableNumber;

    -- Decision based on the count
    IF bookingCount > 0 THEN
        -- If the table is booked, return a message that it's unavailable
        SELECT CONCAT('Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
    ELSE
        -- If the table is available, return a message confirming availability
        SELECT CONCAT('Table ', p_TableNumber, ' is available on ', p_BookingDate) AS BookingStatus;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure FindAvailableTables
-- -----------------------------------------------------

DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `FindAvailableTables`(
    IN p_BookingDate DATE
)
BEGIN
    -- Create a temporary table to hold all available tables
    CREATE TEMPORARY TABLE AvailableTables (TableNumber INT);

    -- Insert all tables into the temporary table from the 'Tables' table
    INSERT INTO AvailableTables (TableNumber)
    SELECT TableNumber 
    FROM Tables;

    -- Remove tables that are already booked on the given date
    DELETE FROM AvailableTables
    WHERE TableNumber IN (
        SELECT TableNumber
        FROM Bookings
        WHERE BookingDate = p_BookingDate
    );

    -- Return the available tables for the given date
    SELECT TableNumber 
    FROM AvailableTables
    ORDER BY TableNumber;

    -- Drop the temporary table to free up resources after use
    DROP TEMPORARY TABLE AvailableTables;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetBookingsForDate
-- -----------------------------------------------------

DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `GetBookingsForDate`(
    IN p_BookingDate DATE
)
BEGIN
    -- Select and return the booking details for the specified date
    SELECT BookingID, TableNumber, CustomerID
    FROM Bookings
    WHERE BookingDate = p_BookingDate
    ORDER BY TableNumber;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetMaxQuantity
-- -----------------------------------------------------

DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `GetMaxQuantity`()
BEGIN
    -- Get the maximum quantity ordered from the Order_Items table
    SELECT CONCAT('The maximum quantity ordered is: ', MAX(Quantity)) AS Max_Qty_In_Order
    FROM Order_Items;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure SetOrderDelivered
-- -----------------------------------------------------

DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `SetOrderDelivered`(
    IN order_id INT,            -- Order ID to be updated
    IN performed_by VARCHAR(100) -- User performing the update
)
BEGIN
    DECLARE old_status ENUM('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled');

    /* Retrieve the current status of the order before updating */
    SELECT Status INTO old_status
    FROM Order_Delivery_Status
    WHERE OrderID = order_id;

    /* Update the status of the order to 'Delivered' */
    UPDATE Order_Delivery_Status
    SET Status = 'Delivered'
    WHERE OrderID = order_id;

    /* Log the status update in the Audit_Log table */
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', order_id, 
            CONCAT('Old Status: ', old_status), 
            'New Status: Delivered', 
            performed_by);

    /* Return a confirmation message */
    SELECT CONCAT('Order ', order_id, ' status updated to Delivered') AS Confirmation;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure SetOrderOutForDelivery
-- -----------------------------------------------------

DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `SetOrderOutForDelivery`(IN order_id INT)
BEGIN
    /* Update the order status to 'Out for Delivery' */
    UPDATE Order_Delivery_Status
    SET Status = 'Out for Delivery'
    WHERE OrderID = order_id;

    /* Return a confirmation message */
    SELECT CONCAT('Order ', order_id, ' status updated to Out for Delivery') AS Confirmation;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure SetOrderPreparing
-- -----------------------------------------------------

DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `SetOrderPreparing`(IN order_id INT)
BEGIN
    /* Update the order status to 'Preparing' */
    UPDATE Order_Delivery_Status
    SET Status = 'Preparing'
    WHERE OrderID = order_id;

    /* Return a confirmation message */
    SELECT CONCAT('Order ', order_id, ' status updated to Preparing') AS Confirmation;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure UpdateBooking
-- -----------------------------------------------------

DELIMITER $$

USE `LittleLemonDB`$$

CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `UpdateBooking`(
    IN p_BookingID INT,                  -- Booking ID to be updated
    IN p_NewBookingDate DATE,             -- New booking date
    IN p_PerformedBy VARCHAR(100)        -- User performing the update
)
BEGIN
    DECLARE oldBookingDate DATE;         -- Variable to store the old booking date
    
    -- Error Handling: If an exception occurs, the transaction will be rolled back
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Unable to update booking' AS ErrorMessage;
    END;

    -- Start Transaction: Ensures that the changes are atomic
    START TRANSACTION;

    -- Check if the booking exists and fetch the old booking date
    SELECT BookingDate INTO oldBookingDate 
    FROM Bookings 
    WHERE BookingID = p_BookingID;

    -- Update booking date
    UPDATE Bookings 
    SET BookingDate = p_NewBookingDate 
    WHERE BookingID = p_BookingID;

    -- Log the update into Audit_Log for tracking
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Bookings', 'UPDATE', p_BookingID, 
            CONCAT('Old Date: ', oldBookingDate), 
            CONCAT('New Date: ', p_NewBookingDate), 
            p_PerformedBy);

    COMMIT;  -- Commit the transaction

    -- Return confirmation message
    SELECT CONCAT('Booking ', p_BookingID, ' updated to ', p_NewBookingDate) AS Confirmation;
END$$

DELIMITER ;

SELECT o.OrderID, o.CustomerID, o.StaffID, o.OrderDate, o.TotalCost, ods.Status, ods.Date
FROM Orders o
LEFT JOIN Order_Delivery_Status ods
ON o.OrderID = ods.OrderID
WHERE o.OrderID = 152; -- Use the actual orderID

DROP PROCEDURE CancelOrderAndDelete;
DROP PROCEDURE CancelOrder;


DELIMITER $$

CREATE PROCEDURE CancelOrderAndUpdate (
    IN p_OrderID INT
)
BEGIN
    -- Set Order's TotalCost to 0
    UPDATE Orders
    SET TotalCost = 0
    WHERE OrderID = p_OrderID;

    -- Change the status of the Order in the Order Delivery Status
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = p_OrderID;

    -- Optionally, add logging here to capture this cancellation event
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Orders', 'UPDATE', p_OrderID, 'TotalCost > 0', 'TotalCost = 0', CURRENT_USER());
END$$

DELIMITER ;




-- Drop the existing foreign key constraint
ALTER TABLE `Order_Items` DROP FOREIGN KEY fk_order_items_orderid;

-- Add the new foreign key constraint with ON DELETE CASCADE
ALTER TABLE `Order_Items`
ADD CONSTRAINT fk_order_items_orderid FOREIGN KEY (`OrderID`) REFERENCES `Orders`(`OrderID`) ON DELETE CASCADE;

-- Trigger for INSERT operation on Order_Items
DELIMITER $$
CREATE TRIGGER log_insert_order_items
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
    VALUES ('Order_Items', 'INSERT', NEW.OrderItemID, 
            CONCAT('OrderID: ', NEW.OrderID, ', MenuID: ', NEW.MenuID, ', Quantity: ', NEW.Quantity, ', ItemPrice: ', NEW.ItemPrice), 
            CURRENT_USER());
END$$
DELIMITER ;

-- Trigger for UPDATE operation on Order_Items
DELIMITER $$
CREATE TRIGGER log_update_order_items
AFTER UPDATE ON Order_Items
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Items', 'UPDATE', OLD.OrderItemID, 
            CONCAT('Old Quantity: ', OLD.Quantity, ', Old ItemPrice: ', OLD.ItemPrice), 
            CONCAT('New Quantity: ', NEW.Quantity, ', New ItemPrice: ', NEW.ItemPrice), 
            CURRENT_USER());
END$$
DELIMITER ;

-- Trigger for DELETE operation on Order_Items
DELIMITER $$
CREATE TRIGGER log_delete_order_items
AFTER DELETE ON Order_Items
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
    VALUES ('Order_Items', 'DELETE', OLD.OrderItemID, 
            CONCAT('OrderID: ', OLD.OrderID, ', MenuID: ', OLD.MenuID, ', Quantity: ', OLD.Quantity, ', ItemPrice: ', OLD.ItemPrice), 
            CURRENT_USER());
END$$
DELIMITER ;