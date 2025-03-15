-- MySQL Script generated by MySQL Workbench
-- Tue Mar 11 20:03:09 2025
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
  PRIMARY KEY (`AuditID`))
ENGINE = InnoDB
AUTO_INCREMENT = 5
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
AUTO_INCREMENT = 9
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Bookings` (
  `BookingID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `TableNumber` INT NOT NULL,
  `BookingDate` DATE NOT NULL,
  PRIMARY KEY (`BookingID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  INDEX `idx_BookingDate` (`BookingDate` ASC) VISIBLE,
  CONSTRAINT `fk_bookings_CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `LittleLemonDB`.`Customer_Details` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 32
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
AUTO_INCREMENT = 11
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
AUTO_INCREMENT = 7
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
  PRIMARY KEY (`OrderID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  INDEX `StaffID_idx` (`StaffID` ASC) VISIBLE,
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
AUTO_INCREMENT = 10
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Order_Delivery_Status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Order_Delivery_Status` (
  `DeliveryID` INT NOT NULL AUTO_INCREMENT,
  `OrderID` INT NOT NULL,
  `DeliveryDate` DATE NOT NULL,
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
AUTO_INCREMENT = 9
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
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 18
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Tables`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Tables` (
  `TableID` INT NOT NULL AUTO_INCREMENT,
  `TableNumber` INT NOT NULL,
  `Capacity` INT NOT NULL,
  `IsAvailable` TINYINT(1) NULL DEFAULT '1',
  PRIMARY KEY (`TableID`),
  UNIQUE INDEX `TableNumber_UNIQUE` (`TableNumber` ASC) VISIBLE)
ENGINE = InnoDB
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

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancelOrder
-- -----------------------------------------------------

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
CREATE DEFINER=`root`@`localhost` PROCEDURE `FindAvailableTables`(
    IN p_BookingDate DATE
)
BEGIN
    DECLARE availableCount INT DEFAULT 0;
    DECLARE errorMessage VARCHAR(255);

    -- Error Handling: Ensure the date is valid and no error with data input
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    -- Check if there are available tables on the given date
    -- The query finds tables that are not booked on the specified date
    SELECT t.TableNumber
    FROM Tables t
    LEFT JOIN Bookings b ON t.TableNumber = b.TableNumber AND b.BookingDate = p_BookingDate
    WHERE b.TableNumber IS NULL  -- This means the table is not booked
    ORDER BY t.TableNumber;

    -- Check if any available tables are returned
    IF NOT FOUND THEN
        SET errorMessage = CONCAT('No available tables for the date ', p_BookingDate);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

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
USE `LittleLemonDB`;

DELIMITER $$
USE `LittleLemonDB`$$
CREATE
DEFINER=`BryanEspin`@`%`
TRIGGER `LittleLemonDB`.`log_delete_booking`
AFTER DELETE ON `LittleLemonDB`.`Bookings`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after a booking is deleted
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
    VALUES ('Bookings', 'DELETE', OLD.BookingID, 
            CONCAT('Date: ', OLD.BookingDate, ', Table: ', OLD.TableNumber), 
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`BryanEspin`@`%`
TRIGGER `LittleLemonDB`.`log_update_booking`
AFTER UPDATE ON `LittleLemonDB`.`Bookings`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after a booking is updated
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Bookings', 'UPDATE', OLD.BookingID, 
            CONCAT('Old Date: ', OLD.BookingDate, ', Old Table: ', OLD.TableNumber), 
            CONCAT('New Date: ', NEW.BookingDate, ', New Table: ', NEW.TableNumber), 
            CURRENT_USER());
END$$

USE `LittleLemonDB`$$
CREATE
DEFINER=`BryanEspin`@`%`
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
DEFINER=`BryanEspin`@`%`
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
DEFINER=`BryanEspin`@`%`
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
