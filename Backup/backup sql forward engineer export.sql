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
  `OldData` TEXT NULL DEFAULT NULL,
  `NewData` TEXT NULL DEFAULT NULL,
  `ActionTimestamp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `PerformedBy` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`AuditID`))
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb3;


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

USE `LittleLemonDB` ;

-- -----------------------------------------------------
-- procedure AddValidBooking
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `AddValidBooking`(
    IN p_BookingDate DATE,
    IN p_TableNumber INT,
    IN p_CustomerID INT,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;
    DECLARE newBookingID INT;

    START TRANSACTION;

    -- Check if table is already booked
    SELECT COUNT(*)
    INTO bookingExists
    FROM Bookings
    WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;

    IF bookingExists > 0 THEN
        ROLLBACK;
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked.') AS BookingStatus;
    ELSE
        -- Insert booking
        INSERT INTO Bookings (BookingDate, TableNumber, CustomerID)
        VALUES (p_BookingDate, p_TableNumber, p_CustomerID);

        -- Get new BookingID
        SET newBookingID = LAST_INSERT_ID();

        -- Log Insert
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
        VALUES ('Bookings', 'INSERT', newBookingID, 
                CONCAT('Date: ', p_BookingDate, ', Table: ', p_TableNumber, ', Customer: ', p_CustomerID), 
                p_PerformedBy);

        COMMIT;
        SELECT CONCAT('Booking confirmed for Table ', p_TableNumber, ' on ', p_BookingDate) AS BookingStatus;
    END IF;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancelAllBookingsForDate
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `CancelAllBookingsForDate`(
    IN p_BookingDate DATE
)
BEGIN
    DECLARE bookingsDeleted INT DEFAULT 0;

    -- Count bookings before deletion
    SELECT COUNT(*)
    INTO bookingsDeleted
    FROM Bookings
    WHERE BookingDate = p_BookingDate;

    -- Delete bookings
    DELETE FROM Bookings
    WHERE BookingDate = p_BookingDate;

    -- Return a message
    SELECT CONCAT(bookingsDeleted, ' bookings canceled for ', p_BookingDate) AS CancelStatus;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancelBooking
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `CancelBooking`(
    IN p_BookingID INT,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;
    DECLARE oldData TEXT;
    
    -- Error Handling
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Unable to cancel booking' AS ErrorMessage;
    END;

    -- Start Transaction
    START TRANSACTION;

    -- Check if the booking exists
    SELECT COUNT(*), CONCAT('Date: ', BookingDate, ', Table: ', TableNumber, ', Customer: ', CustomerID)
    INTO bookingExists, oldData
    FROM Bookings
    WHERE BookingID = p_BookingID;

    IF bookingExists > 0 THEN
        -- Log delete before deleting
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
        VALUES ('Bookings', 'DELETE', p_BookingID, oldData, p_PerformedBy);

        -- Perform delete
        DELETE FROM Bookings WHERE BookingID = p_BookingID;

        COMMIT;
        SELECT CONCAT('Booking ', p_BookingID, ' has been canceled successfully.') AS CancelStatus;
    ELSE
        ROLLBACK;
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS CancelStatus;
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
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = order_id;

    SELECT CONCAT('Order ', order_id, ' has been cancelled') AS Confirmation;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ChangeBookingTable
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `ChangeBookingTable`(
    IN p_BookingID INT,
    IN p_NewTableNumber INT
)
BEGIN
    DECLARE existingDate DATE;
    DECLARE tableBooked INT DEFAULT 0;

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

        SELECT CONCAT('Booking ', p_BookingID, ' moved to Table ', p_NewTableNumber) AS ChangeStatus;
    ELSE
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
    IN p_BookingDate DATE,
    IN p_TableNumber INT
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
        SELECT CONCAT('Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
    ELSE
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
    SELECT DISTINCT TableNumber
    FROM Tables -- Assuming there is a 'Tables' table with all possible tables
    WHERE TableNumber NOT IN (
        SELECT TableNumber FROM Bookings WHERE BookingDate = p_BookingDate
    )
    ORDER BY TableNumber;
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
    IN order_id INT,            -- Order to be updated
    IN performed_by VARCHAR(100) -- User performing the update
)
BEGIN
    DECLARE old_status ENUM('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled');

    /* Retrieve the current order status before making the update */
    SELECT Status INTO old_status
    FROM Order_Delivery_Status
    WHERE OrderID = order_id;

    /* Update order status to 'Delivered' */
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
    UPDATE Order_Delivery_Status
    SET Status = 'Out for Delivery'
    WHERE OrderID = order_id;

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
    UPDATE Order_Delivery_Status
    SET Status = 'Preparing'
    WHERE OrderID = order_id;

    SELECT CONCAT('Order ', order_id, ' status updated to Preparing') AS Confirmation;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure UpdateBooking
-- -----------------------------------------------------

DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`BryanEspin`@`%` PROCEDURE `UpdateBooking`(
    IN p_BookingID INT,
    IN p_NewBookingDate DATE,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE oldBookingDate DATE;
    
    -- Error Handling
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Unable to update booking' AS ErrorMessage;
    END;

    -- Start Transaction
    START TRANSACTION;

    -- Check if the booking exists and fetch old data
    SELECT BookingDate INTO oldBookingDate 
    FROM Bookings 
    WHERE BookingID = p_BookingID;

    -- Update booking date
    UPDATE Bookings 
    SET BookingDate = p_NewBookingDate 
    WHERE BookingID = p_BookingID;

    -- Log the update
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Bookings', 'UPDATE', p_BookingID, 
            CONCAT('Old Date: ', oldBookingDate), 
            CONCAT('New Date: ', p_NewBookingDate), 
            p_PerformedBy);

    COMMIT;
    SELECT CONCAT('Booking ', p_BookingID, ' updated to ', p_NewBookingDate) AS Confirmation;
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
USE `LittleLemonDB`;

DELIMITER $$
USE `LittleLemonDB`$$
CREATE
DEFINER=`BryanEspin`@`%`
TRIGGER `LittleLemonDB`.`log_delete_booking`
AFTER DELETE ON `LittleLemonDB`.`Bookings`
FOR EACH ROW
BEGIN
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
    UPDATE Orders
    SET TotalCost = (
        SELECT SUM(TotalItemCost)
        FROM Order_Items
        WHERE OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END$$


DELIMITER ;
