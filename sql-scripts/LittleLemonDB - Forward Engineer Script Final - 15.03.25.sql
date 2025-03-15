-- MySQL Script generated by MySQL Workbench
-- Sat Mar 15 16:22:33 2025
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema LittleLemonDB
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema LittleLemonDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `LittleLemonDB` DEFAULT CHARACTER SET utf8mb3 ;
USE `LittleLemonDB` ;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Audit_Log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Audit_Log` (
  `AuditID` INT NOT NULL AUTO_INCREMENT,
  `TableName` VARCHAR(50) NOT NULL,
  `ActionType` ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  `RecordID` INT NOT NULL,
  `OldData` MEDIUMTEXT NULL DEFAULT NULL,
  `NewData` MEDIUMTEXT NULL DEFAULT NULL,
  `ActionTimestamp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `PerformedBy` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`AuditID`),
  INDEX `idx_action_timestamp` (`ActionTimestamp` ASC) VISIBLE,
  INDEX `fk_audit_log_orders` (`RecordID` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 73
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Customer_Details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Customer_Details` (
  `CustomerID` INT NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(50) NOT NULL,
  `LastName` VARCHAR(50) NOT NULL,
  `PhoneNumber` VARCHAR(15) NOT NULL,
  `Email` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`CustomerID`),
  UNIQUE INDEX `PhoneNumber_UNIQUE` (`PhoneNumber` ASC) VISIBLE,
  UNIQUE INDEX `Email_UNIQUE` (`Email` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 109
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Tables`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Tables` (
  `TableID` INT NOT NULL AUTO_INCREMENT,
  `TableNumber` INT NOT NULL,
  `Capacity` INT NOT NULL,
  `IsAvailable` TINYINT(1) NULL DEFAULT '1',
  `LastUpdated` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`TableID`),
  UNIQUE INDEX `TableNumber_UNIQUE` (`TableNumber` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 51
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Bookings` (
  `BookingID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `BookingDate` DATE NOT NULL,
  `TableID` INT NOT NULL,
  `Status` ENUM('New Booking', 'Cancelled') NOT NULL DEFAULT 'New Booking',
  PRIMARY KEY (`BookingID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  INDEX `idx_BookingDate` (`BookingDate` ASC) VISIBLE,
  INDEX `fk_bookings_tableid` (`TableID` ASC) VISIBLE,
  CONSTRAINT `fk_bookings_CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `LittleLemonDB`.`Customer_Details` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_bookings_tableid`
    FOREIGN KEY (`TableID`)
    REFERENCES `LittleLemonDB`.`Tables` (`TableID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 195
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Menu`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Menu` (
  `MenuID` INT NOT NULL AUTO_INCREMENT,
  `ItemName` VARCHAR(100) NOT NULL,
  `Category` ENUM('Starters', 'Courses', 'Drinks', 'Desserts') NOT NULL,
  `Price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`MenuID`))
ENGINE = InnoDB
AUTO_INCREMENT = 60
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Staff_Information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Staff_Information` (
  `StaffID` INT NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(50) NOT NULL,
  `LastName` VARCHAR(50) NOT NULL,
  `Role` VARCHAR(45) NOT NULL,
  `Salary` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`StaffID`))
ENGINE = InnoDB
AUTO_INCREMENT = 89
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Orders` (
  `OrderID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `StaffID` INT NOT NULL,
  `OrderDate` DATE NOT NULL,
  `TotalCost` DECIMAL(10,2) NOT NULL,
  `BookingID` INT NULL DEFAULT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  INDEX `StaffID_idx` (`StaffID` ASC) VISIBLE,
  INDEX `fk_orders_bookings` (`BookingID` ASC) VISIBLE,
  CONSTRAINT `fk_orders_bookings`
    FOREIGN KEY (`BookingID`)
    REFERENCES `LittleLemonDB`.`Bookings` (`BookingID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `LittleLemonDB`.`Customer_Details` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `StaffID`
    FOREIGN KEY (`StaffID`)
    REFERENCES `LittleLemonDB`.`Staff_Information` (`StaffID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 153
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Order_Delivery_Status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Order_Delivery_Status` (
  `DeliveryID` INT NOT NULL AUTO_INCREMENT,
  `OrderID` INT NOT NULL,
  `Date` DATE NULL DEFAULT NULL,
  `Status` ENUM('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'New Order',
  PRIMARY KEY (`DeliveryID`),
  INDEX `OrderID_idx` (`OrderID` ASC) VISIBLE,
  INDEX `idx_Status` (`Status` ASC) VISIBLE,
  CONSTRAINT `fk_order_delivery_orderid`
    FOREIGN KEY (`OrderID`)
    REFERENCES `LittleLemonDB`.`Orders` (`OrderID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 11
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Order_Items`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Order_Items` (
  `OrderItemID` INT NOT NULL AUTO_INCREMENT,
  `OrderID` INT NOT NULL,
  `MenuID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `ItemPrice` DECIMAL(10,2) NOT NULL,
  `TotalItemCost` DECIMAL(10,2) GENERATED ALWAYS AS ((`Quantity` * `ItemPrice`)) STORED,
  PRIMARY KEY (`OrderItemID`),
  INDEX `OrderID_idx` (`OrderID` ASC) VISIBLE,
  INDEX `MenuID_idx` (`MenuID` ASC) VISIBLE,
  CONSTRAINT `fk_order_items_menuid`
    FOREIGN KEY (`MenuID`)
    REFERENCES `LittleLemonDB`.`Menu` (`MenuID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_orderid`
    FOREIGN KEY (`OrderID`)
    REFERENCES `LittleLemonDB`.`Orders` (`OrderID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 134
DEFAULT CHARACTER SET = utf8mb3;

USE `LittleLemonDB` ;

-- -----------------------------------------------------
-- procedure AddValidBooking
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddValidBooking`(
    IN p_BookingDate DATE,      -- The date the booking is requested for
    IN p_TableNumber INT,       -- The table number to be booked
    IN p_CustomerID INT,        -- The ID of the customer making the booking
    IN p_PerformedBy VARCHAR(100) -- The user performing the booking
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to track if the table is already booked
    DECLARE newBookingID INT;             -- Variable to store the new booking ID after insertion
    DECLARE tableValid INT DEFAULT 0;     -- Variable to track if the table exists
    DECLARE errorMessage VARCHAR(255);    -- Variable to hold the error message

    -- Start a transaction to ensure the atomicity of the operation
    START TRANSACTION;

    -- Check if the table number exists in the Tables table
    SELECT COUNT(*)
    INTO tableValid
    FROM Tables
    WHERE TableNumber = p_TableNumber;

    -- If the table number does not exist, inform the user and rollback
    IF tableValid = 0 THEN
        SET errorMessage = CONCAT('Booking declined: Table ', p_TableNumber, ' does not exist.');
        ROLLBACK;  -- Rollback the transaction
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*)
        INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;

        -- If the table is already booked, rollback the transaction and inform the user
        IF bookingExists > 0 THEN
            SET errorMessage = CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked on ', p_BookingDate);
            ROLLBACK;  -- Undo all changes made during this transaction
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
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
    END IF;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancelAllBookingsForDate
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelAllBookingsForDate`(
    IN p_BookingDate DATE
)
BEGIN
    DECLARE bookingsDeleted INT DEFAULT 0;
    DECLARE errorMessage VARCHAR(255);

    -- Ensure the date is valid
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    -- Count bookings for the specified date
    SELECT COUNT(*) INTO bookingsDeleted
    FROM Bookings
    WHERE BookingDate = p_BookingDate;

    -- If no bookings exist, return an error
    IF bookingsDeleted = 0 THEN
        SET errorMessage = CONCAT('No bookings found for ', DATE_FORMAT(p_BookingDate, '%Y-%m-%d'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    -- Delete all bookings for the specified date
    DELETE FROM Bookings WHERE BookingDate = p_BookingDate;

    -- Confirmation message
    SELECT CONCAT(bookingsDeleted, ' bookings canceled for ', DATE_FORMAT(p_BookingDate, '%Y-%m-%d')) AS CancelStatus;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ChangeBookingTable
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ChangeBookingTable`(
    IN p_BookingID INT,  
    IN p_NewTableNumber INT  
)
BEGIN
    DECLARE existingTableNumber INT;
    DECLARE existingDate DATE;
    DECLARE tableBooked INT DEFAULT 0;
    DECLARE errorMessage VARCHAR(255);
    DECLARE newTableID INT;

    -- Ensure valid input
    IF p_BookingID IS NULL OR p_NewTableNumber IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking ID or Table Number cannot be NULL.';
    END IF;

    -- Get current table ID and booking date
    SELECT TableID, BookingDate INTO existingTableNumber, existingDate
    FROM Bookings WHERE BookingID = p_BookingID;

    -- Ensure booking exists
    IF existingTableNumber IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking ID does not exist.';
    END IF;

    -- Prevent booking to the same table
    IF existingTableNumber = (SELECT TableID FROM Tables WHERE TableNumber = p_NewTableNumber) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot move booking to the same table.';
    END IF;

    -- Get TableID from TableNumber
    SELECT TableID INTO newTableID FROM Tables WHERE TableNumber = p_NewTableNumber;

    -- If table does not exist, return error
    IF newTableID IS NULL THEN
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' does not exist.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    -- Check if new table is already booked on that date
    SELECT COUNT(*) INTO tableBooked 
    FROM Bookings 
    WHERE BookingDate = existingDate 
    AND TableID = newTableID
    AND Status != 'Cancelled';

    -- If available, update the booking
    IF tableBooked = 0 THEN
        UPDATE Bookings SET TableID = newTableID WHERE BookingID = p_BookingID;
        SELECT CONCAT('Booking ', p_BookingID, ' moved to Table ', p_NewTableNumber) AS ChangeStatus;
    ELSE
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' is already booked on ', existingDate);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CheckBooking
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckBooking`(
    IN p_BookingDate DATE,  
    IN p_TableNumber INT  
)
BEGIN
    DECLARE bookingCount INT DEFAULT 0;  

    -- Check if the table is booked
    SELECT COUNT(*) INTO bookingCount
    FROM Bookings
    WHERE BookingDate = p_BookingDate
    AND TableID = (SELECT TableID FROM Tables WHERE TableNumber = p_TableNumber);

    -- Return status based on booking count
    IF bookingCount > 0 THEN
        SELECT CONCAT('Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
    ELSE
        SELECT CONCAT('Table ', p_TableNumber, ' is available on ', p_BookingDate) AS BookingStatus;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ErrorHandler
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ErrorHandler`(
    IN p_ErrorMessage VARCHAR(255),
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    -- Log the error to the Audit_Log
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('ErrorLog', 'ERROR', NULL, NULL, p_ErrorMessage, p_PerformedBy);

    -- Rollback the transaction (assumes it is only called in an active transaction)
    ROLLBACK;

    -- Raise a custom error message
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_ErrorMessage;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure FindAvailableTables
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FindAvailableTables`(
    IN p_BookingDate DATE
)
BEGIN
    DECLARE errorMessage VARCHAR(255);

    -- Ensure valid booking date
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    -- Find tables that are NOT booked or were previously cancelled
    SELECT t.TableNumber
    FROM Tables t
    LEFT JOIN Bookings b 
        ON t.TableID = b.TableID 
        AND b.BookingDate = p_BookingDate
    WHERE (b.TableID IS NULL OR b.Status = 'Cancelled') 
    AND t.IsAvailable = 1
    ORDER BY t.TableNumber;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetBookingsForDate
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBookingsForDate`(
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMaxQuantity`()
BEGIN
    -- Get the maximum quantity ordered from the Order_Items table
    SELECT CONCAT('The maximum quantity ordered is: ', MAX(Quantity)) AS Max_Qty_In_Order
    FROM Order_Items;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure UpdateBooking
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateBooking`(
    IN p_BookingID INT,                  -- Booking ID to be updated
    IN p_NewBookingDate DATE,             -- New booking date
    IN p_PerformedBy VARCHAR(100)        -- User performing the update
)
BEGIN
    DECLARE oldBookingDate DATE;         -- Variable to store the old booking date
    DECLARE errorMessage VARCHAR(255);    -- Variable for error message

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

    -- Error Handling: Ensure booking exists before updating
    IF oldBookingDate IS NULL THEN
        SET errorMessage = 'Booking ID does not exist.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

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

-- -----------------------------------------------------
-- procedure UpdateOrderStatus
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateOrderStatus`(
    IN order_id INT,
    IN new_status VARCHAR(20),
    IN performed_by VARCHAR(100)
)
BEGIN
    DECLARE old_status VARCHAR(20);
    DECLARE orderExists INT;

    -- Validate new_status input
    IF new_status NOT IN ('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid order status!';
    END IF;

    -- Check if the order exists
    SELECT COUNT(*) INTO orderExists FROM Order_Delivery_Status WHERE OrderID = order_id;
    IF orderExists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found!';
    END IF;

    -- Retrieve the current status
    SELECT Status INTO old_status FROM Order_Delivery_Status WHERE OrderID = order_id;

    -- Prevent unnecessary updates
    IF old_status <> new_status THEN
        UPDATE Order_Delivery_Status 
        SET Status = new_status 
        WHERE OrderID = order_id;

        -- Log the status update
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
        VALUES ('Order_Delivery_Status', 'UPDATE', order_id,
                CONCAT('Old Status: ', old_status),
                CONCAT('New Status: ', new_status),
                performed_by);

        -- Confirmation message
        SELECT CONCAT('Order ', order_id, ' status updated to ', new_status) AS Confirmation;
    ELSE
        SELECT 'No update performed: Status is already the same' AS Confirmation;
    END IF;
END$$

DELIMITER ;
USE `LittleLemonDB`;

DELIMITER $$
USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_delete_booking`
AFTER DELETE ON `LittleLemonDB`.`Bookings`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after a booking is deleted
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
    SELECT 'Bookings', 'DELETE', OLD.BookingID, 
           CONCAT('Date: ', OLD.BookingDate, ', Table: ', t.TableNumber), 
           CURRENT_USER()
    FROM Tables t
    WHERE t.TableID = OLD.TableID;
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_insert_booking`
AFTER INSERT ON `LittleLemonDB`.`Bookings`
FOR EACH ROW
BEGIN
    -- Ensure valid TableNumber is being inserted
    IF NEW.TableID NOT BETWEEN 1 AND 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid TableID. Only tables between 1 and 50 are allowed.';
    END IF;

    -- Log the insertion in the Audit_Log
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
    VALUES ('Bookings', 'INSERT', NEW.BookingID,
            CONCAT('Table Number: ', NEW.TableID, ', CustomerID: ', NEW.CustomerID, ', Booking Date: ', NEW.BookingDate, ', Status: ', NEW.Status),
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_update_booking`
AFTER UPDATE ON `LittleLemonDB`.`Bookings`
FOR EACH ROW
BEGIN
    -- Log the update in the Audit_Log, capturing changes to status and other fields
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Bookings', 'UPDATE', OLD.BookingID, 
            CONCAT('Old Status: ', OLD.Status, ', Old Table: ', OLD.TableID, ', Old CustomerID: ', OLD.CustomerID),
            CONCAT('New Status: ', NEW.Status, ', New Table: ', NEW.TableID, ', New CustomerID: ', NEW.CustomerID),
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_insert_order`
AFTER INSERT ON `LittleLemonDB`.`Orders`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after a new order is created
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
    VALUES ('Orders', 'INSERT', NEW.OrderID, 
            CONCAT('Customer: ', NEW.CustomerID, ', Staff: ', NEW.StaffID, ', Date: ', NEW.OrderDate, ', Total Cost: ', NEW.TotalCost), 
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_new_order_status`
AFTER INSERT ON `LittleLemonDB`.`Orders`
FOR EACH ROW
BEGIN
    -- Insert initial status for the new order
    INSERT INTO `Order_Delivery_Status` (OrderID, Date, Status)
    VALUES (NEW.OrderID, CURDATE(), 'New Order');
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`after_order_cancelled`
AFTER UPDATE ON `LittleLemonDB`.`Order_Delivery_Status`
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = (SELECT BookingID FROM Orders WHERE OrderID = NEW.OrderID)
        AND BookingID IS NOT NULL;
    END IF;
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_update_order_status`
AFTER UPDATE ON `LittleLemonDB`.`Order_Delivery_Status`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after an order status is updated
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', OLD.OrderID, 
            CONCAT('Old Status: ', OLD.Status), 
            CONCAT('New Status: ', NEW.Status), 
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_delete_order_items`
AFTER DELETE ON `LittleLemonDB`.`Order_Items`
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
    VALUES ('Order_Items', 'DELETE', OLD.OrderItemID, 
            CONCAT('OrderID: ', OLD.OrderID, ', MenuID: ', OLD.MenuID, ', Quantity: ', OLD.Quantity, ', ItemPrice: ', OLD.ItemPrice), 
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_insert_order_items`
AFTER INSERT ON `LittleLemonDB`.`Order_Items`
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
    VALUES ('Order_Items', 'INSERT', NEW.OrderItemID, 
            CONCAT('OrderID: ', NEW.OrderID, ', MenuID: ', NEW.MenuID, ', Quantity: ', NEW.Quantity, ', ItemPrice: ', NEW.ItemPrice), 
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`log_update_order_items`
AFTER UPDATE ON `LittleLemonDB`.`Order_Items`
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Items', 'UPDATE', OLD.OrderItemID, 
            CONCAT('Old Quantity: ', OLD.Quantity, ', Old ItemPrice: ', OLD.ItemPrice), 
            CONCAT('New Quantity: ', NEW.Quantity, ', New ItemPrice: ', NEW.ItemPrice), 
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `LittleLemonDB`.`update_order_total`
AFTER INSERT ON `LittleLemonDB`.`Order_Items`
FOR EACH ROW
BEGIN
    -- Update the total cost of the order whenever an item is added
    UPDATE Orders
    SET TotalCost = (
        SELECT SUM(TotalItemCost)
        FROM Order_Items
        WHERE OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
