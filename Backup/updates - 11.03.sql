USE LittleLemonDB;


ALTER TABLE `LittleLemonDB`.`Audit_Log`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  
  
DESCRIBE `LittleLemonDB`.`Audit_Log`;
SHOW CREATE TABLE `LittleLemonDB`.`Audit_Log`;

SHOW PROCEDURE STATUS WHERE Db = 'LittleLemonDB' AND Name = 'AddValidBooking';
SHOW CREATE PROCEDURE `LittleLemonDB`.`AddValidBooking`;

CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Tables` (
    `TableID` INT NOT NULL AUTO_INCREMENT,  -- Unique identifier for each table
    `TableNumber` INT NOT NULL,             -- The actual table number
    `Capacity` INT NOT NULL,                -- Maximum number of people the table can accommodate
    `IsAvailable` BOOLEAN DEFAULT TRUE,     -- To track if the table is available
    PRIMARY KEY (`TableID`),
    UNIQUE INDEX `TableNumber_UNIQUE` (`TableNumber`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARACTER SET = utf8mb3;

DROP PROCEDURE AddValidBooking;

DELIMITER $$

USE `LittleLemonDB`$$

CREATE PROCEDURE `AddValidBooking`(
    IN p_BookingDate DATE,      -- The date the booking is requested for
    IN p_TableNumber INT,       -- The table number to be booked
    IN p_CustomerID INT,        -- The ID of the customer making the booking
    IN p_PerformedBy VARCHAR(100) -- The user performing the booking
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to track if the table is already booked
    DECLARE newBookingID INT;             -- Variable to store the new booking ID after insertion
    DECLARE tableValid INT DEFAULT 0;     -- Variable to track if the table exists

    -- Start a transaction to ensure the atomicity of the operation
    START TRANSACTION;

    -- Check if the table number exists in the Tables table
    SELECT COUNT(*)
    INTO tableValid
    FROM Tables
    WHERE TableNumber = p_TableNumber;

    -- If the table number does not exist, inform the user and rollback
    IF tableValid = 0 THEN
        ROLLBACK;  -- Rollback the transaction
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' does not exist.') AS BookingStatus;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*)
        INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;

        -- If the table is already booked, rollback the transaction and inform the user
        IF bookingExists > 0 THEN
            ROLLBACK;  -- Undo all changes made during this transaction
            SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
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

DROP PROCEDURE AddValidBooking;

DELIMITER $$

USE `LittleLemonDB`$$

CREATE PROCEDURE `AddValidBooking`(
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

DROP PROCEDURE FindAvailableTables;

DELIMITER $$

USE `LittleLemonDB`$$

CREATE PROCEDURE `FindAvailableTables`(
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

-- Create the foreign key constraint to link TableID with Tables
ALTER TABLE `Bookings`
    ADD CONSTRAINT `fk_bookings_tableid`
    FOREIGN KEY (`TableID`)
    REFERENCES `Tables` (`TableID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
DESCRIBE Bookings;

ALTER TABLE `Bookings`
    ADD COLUMN `TableID` INT NOT NULL;
    
ALTER TABLE `Bookings`
    ADD CONSTRAINT `fk_bookings_tableid`
    FOREIGN KEY (`TableID`)
    REFERENCES `Tables` (`TableID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
    
DROP PROCEDURE AddValidBooking;

DELIMITER $$

USE `LittleLemonDB`$$
CREATE PROCEDURE `AddValidBooking`(
    IN p_BookingDate DATE,      -- The date the booking is requested for
    IN p_TableNumber INT,       -- The table number to be booked
    IN p_CustomerID INT,        -- The ID of the customer making the booking
    IN p_PerformedBy VARCHAR(100) -- The user performing the booking
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to track if the table is already booked
    DECLARE newBookingID INT;             -- Variable to store the new booking ID after insertion
    DECLARE tableValid INT DEFAULT 0;     -- Variable to track if the table exists
    DECLARE tableID INT;                 -- Variable to store the corresponding TableID

    -- Start a transaction to ensure the atomicity of the operation
    START TRANSACTION;

    -- Check if the table number exists in the Tables table and get TableID
    SELECT TableID
    INTO tableID
    FROM Tables
    WHERE TableNumber = p_TableNumber;

    -- If the table number does not exist, inform the user and rollback
    IF tableID IS NULL THEN
        ROLLBACK;  -- Rollback the transaction
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' does not exist.') AS BookingStatus;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*)
        INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableID = tableID;

        -- If the table is already booked, rollback the transaction and inform the user
        IF bookingExists > 0 THEN
            ROLLBACK;  -- Undo all changes made during this transaction
            SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
        ELSE
            -- If the table is available, insert the booking into the Bookings table
            INSERT INTO Bookings (BookingDate, TableID, TableNumber, CustomerID)
            VALUES (p_BookingDate, tableID, p_TableNumber, p_CustomerID);

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

DROP PROCEDURE AddValidBooking;

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
    DECLARE tableID INT;                 -- Variable to store the corresponding TableID

    -- Start a transaction to ensure the atomicity of the operation
    START TRANSACTION;

    -- Check if the table number exists in the Tables table and get TableID
    SELECT TableID
    INTO tableID
    FROM Tables
    WHERE TableNumber = p_TableNumber;

    -- If the table number does not exist, inform the user and rollback
    IF tableID IS NULL THEN
        ROLLBACK;  -- Rollback the transaction
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' does not exist.') AS BookingStatus;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*)
        INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableID = tableID;

        -- If the table is already booked, rollback the transaction and inform the user
        IF bookingExists > 0 THEN
            ROLLBACK;  -- Undo all changes made during this transaction
            SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
        ELSE
            -- If the table is available, insert the booking into the Bookings table
            INSERT INTO Bookings (BookingDate, TableID, TableNumber, CustomerID)
            VALUES (p_BookingDate, tableID, p_TableNumber, p_CustomerID);

            -- Get the ID of the newly inserted booking
            SET newBookingID = LAST_INSERT_ID();

            -- Log the insertion action in the Audit_Log table
            INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
            VALUES ('Bookings', 'INSERT', newBookingID, 
                    CONCAT('Date: ', p_BookingDate, ', Table: ', p_TableNumber, ', Customer: ', p_CustomerID), 
                    p_PerformedBy);

            -- Update the table availability to 'unavailable' (IsAvailable = 0)
            UPDATE Tables
            SET IsAvailable = 0
            WHERE TableID = tableID;

            -- Commit the transaction, making all changes permanent
            COMMIT;

            -- Return a success message confirming the booking
            SELECT CONCAT('Booking confirmed for Table ', p_TableNumber, ' on ', p_BookingDate) AS BookingStatus;
        END IF;
    END IF;

END$$

DELIMITER ;

DROP PROCEDURE CancelBooking;

DELIMITER $$

USE `LittleLemonDB`$$

CREATE PROCEDURE `CancelBooking`(
    IN p_BookingID INT,  -- The ID of the booking to be canceled
    IN p_PerformedBy VARCHAR(100)  -- The user performing the cancellation
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to check if the booking exists
    DECLARE oldData TEXT;  -- Variable to store the old booking data for logging
    DECLARE tableID INT;  -- Variable to store the TableID for the canceled booking

    -- Error Handling: This block ensures that in case of any SQL exceptions, the transaction is rolled back.
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- Rollback any changes in case of an error
        SELECT 'Error: Unable to cancel booking' AS ErrorMessage;  -- Return an error message
    END;

    -- Start the transaction to ensure atomicity
    START TRANSACTION;

    -- Check if the booking exists and get the tableID
    SELECT COUNT(*), CONCAT('Date: ', BookingDate, ', Table: ', TableNumber, ', Customer: ', CustomerID), TableID
    INTO bookingExists, oldData, tableID
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- If the booking exists
    IF bookingExists > 0 THEN
        -- Log the delete operation in the Audit_Log before performing the deletion
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
        VALUES ('Bookings', 'DELETE', p_BookingID, oldData, p_PerformedBy);

        -- Delete the booking from the Bookings table
        DELETE FROM Bookings WHERE BookingID = p_BookingID;

        -- Update the table availability to 'available' (IsAvailable = 1)
        UPDATE Tables
        SET IsAvailable = 1
        WHERE TableID = tableID;

        COMMIT;  -- Commit the transaction to make the changes permanent
        SELECT CONCAT('Booking ', p_BookingID, ' has been canceled successfully.') AS CancelStatus;  -- Return a success message
    ELSE
        ROLLBACK;  -- Rollback the transaction if the booking does not exist
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS CancelStatus;  -- Return a message indicating no booking was found
    END IF;

END$$

DELIMITER ;

ALTER TABLE `Bookings`
DROP COLUMN `TableNumber`;



-- Add index on ActionTimestamp in the Audit_Log table (if necessary)
CREATE INDEX idx_action_timestamp ON Audit_Log (ActionTimestamp);

-- Add foreign key constraints to the Audit_Log table
ALTER TABLE `Audit_Log`
    ADD CONSTRAINT `fk_audit_log_bookings`
    FOREIGN KEY (`RecordID`) 
    REFERENCES `Bookings`(`BookingID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE `Audit_Log`
    ADD CONSTRAINT `fk_audit_log_orders`
    FOREIGN KEY (`RecordID`) 
    REFERENCES `Orders`(`OrderID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
DELIMITER $$

USE `LittleLemonDB`$$
CREATE PROCEDURE `ErrorHandler`(
    IN p_ErrorMessage VARCHAR(255),  -- Custom error message
    IN p_PerformedBy VARCHAR(100)    -- User who performed the action
)
BEGIN
    DECLARE errorMessage VARCHAR(255);

    -- Log the error to the Audit_Log
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('ErrorLog', 'ERROR', NULL, NULL, p_ErrorMessage, p_PerformedBy);

    -- Rollback the current transaction
    ROLLBACK;

    -- Raise a custom error message
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_ErrorMessage;
END$$

DELIMITER ;

DROP PROCEDURE CancelAllBookingsForDate;

DELIMITER $$

CREATE PROCEDURE `CancelAllBookingsForDate`(
    IN p_BookingDate DATE  -- The date for which all bookings will be canceled
)
BEGIN
    DECLARE bookingsDeleted INT DEFAULT 0;  -- Variable to store the count of bookings deleted
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: Ensure the date is valid and no error with data input
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

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

DROP PROCEDURE CancelOrder;

DELIMITER $$

CREATE PROCEDURE `CancelOrder`(IN order_id INT)
BEGIN
    DECLARE old_status ENUM('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled');
    DECLARE errorMessage VARCHAR(255);

    -- Error Handling: Ensure the order exists before attempting to cancel
    IF order_id IS NULL THEN
        SET errorMessage = 'Order ID cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

    -- Retrieve the current status of the order before updating
    SELECT Status INTO old_status
    FROM Order_Delivery_Status
    WHERE OrderID = order_id;

    -- Update the status of the order to 'Cancelled'
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = order_id;

    -- Log the status update in the Audit_Log table
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', order_id, 
            CONCAT('Old Status: ', old_status), 
            'New Status: Cancelled', 
            CURRENT_USER());

    -- Return a confirmation message
    SELECT CONCAT('Order ', order_id, ' has been cancelled') AS Confirmation;
END$$

DELIMITER ;

DROP PROCEDURE ChangeBookingTable;

DELIMITER $$

CREATE PROCEDURE `ChangeBookingTable`(
    IN p_BookingID INT,  -- Booking ID of the reservation to update
    IN p_NewTableNumber INT  -- New table number to be assigned
)
BEGIN
    DECLARE existingDate DATE;  -- Variable to hold the booking date of the current booking
    DECLARE tableBooked INT DEFAULT 0;  -- Variable to check if the new table is already booked
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: Ensure the booking ID exists before updating
    IF p_BookingID IS NULL OR p_NewTableNumber IS NULL THEN
        SET errorMessage = 'Booking ID or Table Number cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

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
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' is already booked on ', existingDate);
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;
END$$

DELIMITER ;

DROP PROCEDURE FindAvailableTables;

DELIMITER $$

CREATE PROCEDURE `FindAvailableTables`(
    IN p_BookingDate DATE
)
BEGIN
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: Ensure the date is valid and no error with data input
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

    -- Check if there are available tables on the given date
    SELECT t.TableNumber
    FROM Tables t
    LEFT JOIN Bookings b ON t.TableNumber = b.TableNumber AND b.BookingDate = p_BookingDate
    WHERE b.TableNumber IS NULL  -- This means the table is not booked
    ORDER BY t.TableNumber;
END$$

DELIMITER ;

DROP PROCEDURE UpdateBooking;

DELIMITER $$

CREATE PROCEDURE `UpdateBooking`(
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

DROP PROCEDURE FindAvailableTables;

DELIMITER $$

CREATE PROCEDURE `FindAvailableTables`(
    IN p_BookingDate DATE
)
BEGIN
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: Ensure the date is valid and no error with data input
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

    -- Optimized query to find available tables using NOT EXISTS
    SELECT t.TableNumber
    FROM Tables t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Bookings b
        WHERE b.TableNumber = t.TableNumber
        AND b.BookingDate = p_BookingDate
    )
    ORDER BY t.TableNumber;
END$$

DELIMITER ;

ALTER TABLE `LittleLemonDB`.`Tables`
ADD COLUMN `LastUpdated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESCRIBE `LittleLemonDB`.`Tables`;

DESCRIBE Bookings;

DROP PROCEDURE ChangeBookingTable;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChangeBookingTable`(
    IN p_BookingID INT,         -- Booking ID of the reservation to update
    IN p_NewTableNumber INT     -- New table number to be assigned
)
BEGIN
    DECLARE existingDate DATE;  -- Variable to hold the booking date of the current booking
    DECLARE tableBooked INT DEFAULT 0;  -- Variable to check if the new table is already booked
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message
    DECLARE newTableID INT;           -- Variable to store the new TableID

    -- Error Handling: Ensure the booking ID and Table Number are valid before proceeding
    IF p_BookingID IS NULL OR p_NewTableNumber IS NULL THEN
        SET errorMessage = 'Booking ID or Table Number cannot be NULL.';
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;

    -- Check if the new table exists in the Tables table and get TableID
    SELECT TableID INTO newTableID
    FROM Tables
    WHERE TableNumber = p_NewTableNumber;

    -- If the table does not exist, raise an error
    IF newTableID IS NULL THEN
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' does not exist.');
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;

    -- Get the booking date for this booking
    SELECT BookingDate INTO existingDate
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- Check if the new table is already booked on that date
    SELECT COUNT(*)
    INTO tableBooked
    FROM Bookings
    WHERE BookingDate = existingDate
    AND TableID = newTableID;

    -- If table is available, update the booking
    IF tableBooked = 0 THEN
        UPDATE Bookings
        SET TableID = newTableID
        WHERE BookingID = p_BookingID;

        -- Return a success message with the new table number
        SELECT CONCAT('Booking ', p_BookingID, ' moved to Table ', p_NewTableNumber) AS ChangeStatus;
    ELSE
        -- Return a message if the table is already booked on the specified date
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' is already booked on ', existingDate);
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;
END$$

DELIMITER ;

DROP PROCEDURE AddValidBooking;

DELIMITER $$

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
    DECLARE tableID INT;                 -- Variable to store the corresponding TableID
    DECLARE errorMessage VARCHAR(255);    -- Error message variable

    -- Error Handling: Ensure the booking date is not in the past
    IF p_BookingDate < CURDATE() THEN
        SET errorMessage = 'Booking date cannot be in the past.';
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;

    -- Start a transaction to ensure the atomicity of the operation
    START TRANSACTION;

    -- Check if the table number exists in the Tables table and get TableID
    SELECT TableID
    INTO tableID
    FROM Tables
    WHERE TableNumber = p_TableNumber;

    -- If the table number does not exist, inform the user and rollback
    IF tableID IS NULL THEN
        ROLLBACK;  -- Rollback the transaction
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' does not exist.') AS BookingStatus;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*)
        INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableID = tableID;

        -- If the table is already booked, rollback the transaction and inform the user
        IF bookingExists > 0 THEN
            ROLLBACK;  -- Undo all changes made during this transaction
            SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
        ELSE
            -- If the table is available, insert the booking into the Bookings table
            INSERT INTO Bookings (BookingDate, TableID, TableNumber, CustomerID)
            VALUES (p_BookingDate, tableID, p_TableNumber, p_CustomerID);

            -- Get the ID of the newly inserted booking
            SET newBookingID = LAST_INSERT_ID();

            -- Log the insertion action in the Audit_Log table
            INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
            VALUES ('Bookings', 'INSERT', newBookingID, 
                    CONCAT('Date: ', p_BookingDate, ', Table: ', p_TableNumber, ', Customer: ', p_CustomerID), 
                    p_PerformedBy);

            -- Update the table availability to 'unavailable' (IsAvailable = 0)
            UPDATE Tables
            SET IsAvailable = 0
            WHERE TableID = tableID;

            -- Commit the transaction, making all changes permanent
            COMMIT;

            -- Return a success message confirming the booking
            SELECT CONCAT('Booking confirmed for Table ', p_TableNumber, ' on ', p_BookingDate) AS BookingStatus;
        END IF;
    END IF;

END$$

DELIMITER ;

DROP PROCEDURE CancelBooking;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelBooking`(
    IN p_BookingID INT,  -- The ID of the booking to be canceled
    IN p_PerformedBy VARCHAR(100)  -- The user performing the cancellation
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to check if the booking exists
    DECLARE oldData TEXT;  -- Variable to store the old booking data for logging
    DECLARE tableID INT;  -- Variable to store the TableID for the canceled booking
    DECLARE futureBookings INT;  -- Variable to check if any future bookings exist for the table
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: This block ensures that in case of any SQL exceptions, the transaction is rolled back.
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- Rollback any changes in case of an error
        SELECT 'Error: Unable to cancel booking' AS ErrorMessage;  -- Return an error message
    END;

    -- Start the transaction to ensure atomicity
    START TRANSACTION;

    -- Check if the booking exists and get the tableID
    SELECT COUNT(*), CONCAT('Date: ', BookingDate, ', Table: ', TableNumber, ', Customer: ', CustomerID), TableID
    INTO bookingExists, oldData, tableID
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- If the booking exists
    IF bookingExists > 0 THEN
        -- Log the delete operation in the Audit_Log before performing the deletion
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
        VALUES ('Bookings', 'DELETE', p_BookingID, oldData, p_PerformedBy);

        -- Delete the booking from the Bookings table
        DELETE FROM Bookings WHERE BookingID = p_BookingID;

        -- Check if there are any future bookings for this table
        SELECT COUNT(*)
        INTO futureBookings
        FROM Bookings
        WHERE TableID = tableID AND BookingDate > CURDATE();

        -- If no future bookings exist, set the table back to available
        IF futureBookings = 0 THEN
            UPDATE Tables
            SET IsAvailable = 1
            WHERE TableID = tableID;
        END IF;

        COMMIT;  -- Commit the transaction to make the changes permanent
        SELECT CONCAT('Booking ', p_BookingID, ' has been canceled successfully.') AS CancelStatus;  -- Return a success message
    ELSE
        ROLLBACK;  -- Rollback the transaction if the booking does not exist
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS CancelStatus;  -- Return a message indicating no booking was found
    END IF;

END$$

DELIMITER ;

-- Drop existing foreign key constraints
ALTER TABLE `Audit_Log`
  DROP FOREIGN KEY `fk_audit_log_bookings`,
  DROP FOREIGN KEY `fk_audit_log_orders`;

-- Add new foreign key constraints
ALTER TABLE `Audit_Log`
  ADD CONSTRAINT `fk_audit_log_bookings`
    FOREIGN KEY (`RecordID`)
    REFERENCES `LittleLemonDB`.`Bookings` (`BookingID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_audit_log_orders`
    FOREIGN KEY (`RecordID`)
    REFERENCES `LittleLemonDB`.`Orders` (`OrderID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

DROP PROCEDURE IF EXISTS `AddValidBooking`;

DELIMITER $$

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
    DECLARE tableID INT;                 -- Variable to store the corresponding TableID
    DECLARE errorMessage VARCHAR(255);    -- Error message variable

    -- Error Handling: Ensure the booking date is not in the past
    IF p_BookingDate < CURDATE() THEN
        SET errorMessage = 'Booking date cannot be in the past.';
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;

    -- Start a transaction to ensure the atomicity of the operation
    START TRANSACTION;

    -- Check if the table number exists in the Tables table and get TableID
    SELECT TableID
    INTO tableID
    FROM Tables
    WHERE TableNumber = p_TableNumber;

    -- If the table number does not exist, inform the user and rollback
    IF tableID IS NULL THEN
        ROLLBACK;  -- Rollback the transaction
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' does not exist.') AS BookingStatus;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*)
        INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableID = tableID;

        -- If the table is already booked, rollback the transaction and inform the user
        IF bookingExists > 0 THEN
            ROLLBACK;  -- Undo all changes made during this transaction
            SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
        ELSE
            -- If the table is available, insert the booking into the Bookings table
            INSERT INTO Bookings (BookingDate, TableID, TableNumber, CustomerID)
            VALUES (p_BookingDate, tableID, p_TableNumber, p_CustomerID);

            -- Get the ID of the newly inserted booking
            SET newBookingID = LAST_INSERT_ID();

            -- Log the insertion action in the Audit_Log table
            INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
            VALUES ('Bookings', 'INSERT', newBookingID, 
                    CONCAT('Date: ', p_BookingDate, ', Table: ', p_TableNumber, ', Customer: ', p_CustomerID), 
                    p_PerformedBy);

            -- Update the table availability to 'unavailable' (IsAvailable = 0)
            UPDATE Tables
            SET IsAvailable = 0
            WHERE TableID = tableID;

            -- Commit the transaction, making all changes permanent
            COMMIT;

            -- Return a success message confirming the booking
            SELECT CONCAT('Booking confirmed for Table ', p_TableNumber, ' on ', p_BookingDate) AS BookingStatus;
        END IF;
    END IF;

END$$

DROP PROCEDURE IF EXISTS `CancelAllBookingsForDate`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelAllBookingsForDate`(
    IN p_BookingDate DATE  -- The date for which all bookings will be canceled
)
BEGIN
    DECLARE bookingsDeleted INT DEFAULT 0;  -- Variable to store the count of bookings deleted
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: Ensure the date is valid and no error with data input
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

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


DROP PROCEDURE IF EXISTS `CancelBooking`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelBooking`(
    IN p_BookingID INT,  -- The ID of the booking to be canceled
    IN p_PerformedBy VARCHAR(100)  -- The user performing the cancellation
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Variable to check if the booking exists
    DECLARE oldData TEXT;  -- Variable to store the old booking data for logging
    DECLARE tableID INT;  -- Variable to store the TableID for the canceled booking
    DECLARE futureBookings INT;  -- Variable to check if any future bookings exist for the table
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: This block ensures that in case of any SQL exceptions, the transaction is rolled back.
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- Rollback any changes in case of an error
        SELECT 'Error: Unable to cancel booking' AS ErrorMessage;  -- Return an error message
    END;

    -- Start the transaction to ensure atomicity
    START TRANSACTION;

    -- Check if the booking exists and get the tableID
    SELECT COUNT(*), CONCAT('Date: ', BookingDate, ', Table: ', TableNumber, ', Customer: ', CustomerID), TableID
    INTO bookingExists, oldData, tableID
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- If the booking exists
    IF bookingExists > 0 THEN
        -- Log the delete operation in the Audit_Log before performing the deletion
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
        VALUES ('Bookings', 'DELETE', p_BookingID, oldData, p_PerformedBy);

        -- Delete the booking from the Bookings table
        DELETE FROM Bookings WHERE BookingID = p_BookingID;

        -- Check if there are any future bookings for this table
        SELECT COUNT(*)
        INTO futureBookings
        FROM Bookings
        WHERE TableID = tableID AND BookingDate > CURDATE();

        -- If no future bookings exist, set the table back to available
        IF futureBookings = 0 THEN
            UPDATE Tables
            SET IsAvailable = 1
            WHERE TableID = tableID;
        END IF;

        COMMIT;  -- Commit the transaction to make the changes permanent
        SELECT CONCAT('Booking ', p_BookingID, ' has been canceled successfully.') AS CancelStatus;  -- Return a success message
    ELSE
        ROLLBACK;  -- Rollback the transaction if the booking does not exist
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS CancelStatus;  -- Return a message indicating no booking was found
    END IF;

END$$

DROP PROCEDURE IF EXISTS `CancelOrder`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelOrder`(IN order_id INT)
BEGIN
    DECLARE old_status ENUM('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled');
    DECLARE errorMessage VARCHAR(255);

    -- Error Handling: Ensure the order exists before attempting to cancel
    IF order_id IS NULL THEN
        SET errorMessage = 'Order ID cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

    -- Retrieve the current status of the order before updating
    SELECT Status INTO old_status
    FROM Order_Delivery_Status
    WHERE OrderID = order_id;

    -- Update the status of the order to 'Cancelled'
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = order_id;

    -- Log the status update in the Audit_Log table
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', order_id, 
            CONCAT('Old Status: ', old_status), 
            'New Status: Cancelled', 
            CURRENT_USER());

    -- Return a confirmation message
    SELECT CONCAT('Order ', order_id, ' has been cancelled') AS Confirmation;
END$$


DROP PROCEDURE IF EXISTS `ChangeBookingTable`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChangeBookingTable`(
    IN p_BookingID INT,         -- Booking ID of the reservation to update
    IN p_NewTableNumber INT     -- New table number to be assigned
)
BEGIN
    DECLARE existingDate DATE;  -- Variable to hold the booking date of the current booking
    DECLARE tableBooked INT DEFAULT 0;  -- Variable to check if the new table is already booked
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message
    DECLARE newTableID INT;           -- Variable to store the new TableID

    -- Error Handling: Ensure the booking ID and Table Number are valid before proceeding
    IF p_BookingID IS NULL OR p_NewTableNumber IS NULL THEN
        SET errorMessage = 'Booking ID or Table Number cannot be NULL.';
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;

    -- Check if the new table exists in the Tables table and get TableID
    SELECT TableID INTO newTableID
    FROM Tables
    WHERE TableNumber = p_NewTableNumber;

    -- If the table does not exist, raise an error
    IF newTableID IS NULL THEN
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' does not exist.');
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;

    -- Get the booking date for this booking
    SELECT BookingDate INTO existingDate
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- Check if the new table is already booked on that date
    SELECT COUNT(*)
    INTO tableBooked
    FROM Bookings
    WHERE BookingDate = existingDate
    AND TableID = newTableID;

    -- If table is available, update the booking
    IF tableBooked = 0 THEN
        UPDATE Bookings
        SET TableID = newTableID
        WHERE BookingID = p_BookingID;

        -- Return a success message with the new table number
        SELECT CONCAT('Booking ', p_BookingID, ' moved to Table ', p_NewTableNumber) AS ChangeStatus;
    ELSE
        -- Return a message if the table is already booked on the specified date
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' is already booked on ', existingDate);
        CALL ErrorHandler(errorMessage, CURRENT_USER());  -- Call the ErrorHandler stored procedure
    END IF;
END$$


DROP PROCEDURE IF EXISTS `CheckBooking`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckBooking`(
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

DROP PROCEDURE IF EXISTS `ErrorHandler`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ErrorHandler`(
    IN p_ErrorMessage VARCHAR(255),  -- Custom error message
    IN p_PerformedBy VARCHAR(100)    -- User who performed the action
)
BEGIN
    DECLARE errorMessage VARCHAR(255);

    -- Log the error to the Audit_Log
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('ErrorLog', 'ERROR', NULL, NULL, p_ErrorMessage, p_PerformedBy);

    -- Rollback the current transaction
    ROLLBACK;

    -- Raise a custom error message
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_ErrorMessage;
END$$

DROP PROCEDURE IF EXISTS `FindAvailableTables`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FindAvailableTables`(
    IN p_BookingDate DATE
)
BEGIN
    DECLARE errorMessage VARCHAR(255);  -- Variable for error message

    -- Error Handling: Ensure the date is valid and no error with data input
    IF p_BookingDate IS NULL THEN
        SET errorMessage = 'Booking date cannot be NULL.';
        CALL ErrorHandler(errorMessage);  -- Call the ErrorHandler stored procedure
    END IF;

    -- Optimized query to find available tables using NOT EXISTS
    SELECT t.TableNumber
    FROM Tables t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Bookings b
        WHERE b.TableNumber = t.TableNumber
        AND b.BookingDate = p_BookingDate
    )
    ORDER BY t.TableNumber;
END$$

DROP PROCEDURE IF EXISTS `GetBookingsForDate`;

DELIMITER $$

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

DROP PROCEDURE IF EXISTS `GetMaxQuantity`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMaxQuantity`()
BEGIN
    -- Get the maximum quantity ordered from the Order_Items table
    SELECT CONCAT('The maximum quantity ordered is: ', MAX(Quantity)) AS Max_Qty_In_Order
    FROM Order_Items;
END$$

DROP PROCEDURE IF EXISTS `SetOrderDelivered`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SetOrderDelivered`(
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

DROP PROCEDURE IF EXISTS `SetOrderOutForDelivery`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SetOrderOutForDelivery`(IN order_id INT)
BEGIN
    /* Update the order status to 'Out for Delivery' */
    UPDATE Order_Delivery_Status
    SET Status = 'Out for Delivery'
    WHERE OrderID = order_id;

    /* Return a confirmation message */
    SELECT CONCAT('Order ', order_id, ' status updated to Out for Delivery') AS Confirmation;
END$$

DROP PROCEDURE IF EXISTS `SetOrderPreparing`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SetOrderPreparing`(IN order_id INT)
BEGIN
    /* Update the order status to 'Preparing' */
    UPDATE Order_Delivery_Status
    SET Status = 'Preparing'
    WHERE OrderID = order_id;

    /* Return a confirmation message */
    SELECT CONCAT('Order ', order_id, ' status updated to Preparing') AS Confirmation;
END$$

DROP PROCEDURE IF EXISTS `UpdateBooking`;

DELIMITER $$

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

DROP TRIGGER IF EXISTS `log_delete_booking`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `log_delete_booking`
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


DROP TRIGGER IF EXISTS `log_update_booking`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `log_update_booking`
AFTER UPDATE ON `LittleLemonDB`.`Bookings`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after a booking is updated
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    SELECT 'Bookings', 'UPDATE', OLD.BookingID, 
           CONCAT('Old Date: ', OLD.BookingDate, ', Old Table: ', tOld.TableNumber), 
           CONCAT('New Date: ', NEW.BookingDate, ', New Table: ', tNew.TableNumber),
           CURRENT_USER()
    FROM Tables tOld
    JOIN Tables tNew ON tNew.TableID = NEW.TableID
    WHERE tOld.TableID = OLD.TableID;
END$$

DROP TRIGGER IF EXISTS `log_insert_order`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `log_insert_order`
AFTER INSERT ON `LittleLemonDB`.`Orders`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after a new order is created
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
    VALUES ('Orders', 'INSERT', NEW.OrderID, 
            CONCAT('Customer: ', NEW.CustomerID, ', Staff: ', NEW.StaffID, ', Date: ', NEW.OrderDate, ', Total Cost: ', NEW.TotalCost), 
            CURRENT_USER());
END$$

DROP TRIGGER IF EXISTS `log_update_order_status`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `log_update_order_status`
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

DROP TRIGGER IF EXISTS `update_order_total`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `update_order_total`
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

CREATE VIEW OrdersView AS
SELECT o.OrderID,
       oi.Quantity,
       (oi.ItemPrice * oi.Quantity) AS Cost
FROM Order_Items oi
JOIN Orders o ON oi.OrderID = o.OrderID
WHERE oi.Quantity > 2;

SELECT
    cd.CustomerID,
    CONCAT(cd.FirstName, ' ', cd.LastName) AS FullName,
    o.OrderID,
    o.TotalCost,
    m.ItemName AS MenuName  -- Changed from MenuName to ItemName
FROM Orders AS o
INNER JOIN Customer_Details AS cd
    ON o.CustomerID = cd.CustomerID
INNER JOIN Order_Items AS oi
    ON o.OrderID = oi.OrderID
INNER JOIN Menu AS m
    ON oi.MenuID = m.MenuID
WHERE o.TotalCost > 150
ORDER BY o.TotalCost ASC;

SELECT m.ItemName AS MenuName
FROM Menu AS m
WHERE m.MenuID = ANY (
    SELECT oi.MenuID
    FROM Order_Items AS oi
    WHERE oi.Quantity > 2
    GROUP BY oi.MenuID
)
ORDER BY m.ItemName;

SHOW VARIABLES LIKE 'have_prepared_statements';

PREPARE GetOrderDetail FROM 
'SELECT o.OrderID, oi.Quantity, o.TotalCost 
 FROM Orders o
 INNER JOIN Order_Items oi ON o.OrderID = oi.OrderID
 WHERE o.CustomerID = ?';

DROP VIEW OrdersView;

DROP PROCEDURE AddValidBooking;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddValidBooking`(
    IN p_BookingDate DATE,
    IN p_TableNumber INT,
    IN p_CustomerID INT,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;
    DECLARE newBookingID INT;
    DECLARE tableID INT;
    DECLARE errorMessage VARCHAR(255);

    -- Error Handling: Ensure the booking date is not in the past
    IF p_BookingDate < CURDATE() THEN
        SET errorMessage = 'Booking date cannot be in the past.';
        CALL ErrorHandler(errorMessage, CURRENT_USER());
    END IF;

    -- Check if the TableNumber is valid (between 1 and 50)
    IF p_TableNumber < 1 OR p_TableNumber > 50 THEN
        SET errorMessage = 'Invalid TableNumber. Only table numbers between 1 and 50 are allowed.';
        CALL ErrorHandler(errorMessage, CURRENT_USER());
    END IF;

    -- Check if the table exists
    SELECT TableID INTO tableID
    FROM Tables
    WHERE TableNumber = p_TableNumber;

    -- If table number does not exist, inform the user and rollback
    IF tableID IS NULL THEN
        ROLLBACK;
        SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' does not exist.') AS BookingStatus;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*) INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableID = tableID;

        -- If the table is already booked, inform the user
        IF bookingExists > 0 THEN
            ROLLBACK;
            SELECT CONCAT('Booking declined: Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS BookingStatus;
        ELSE
            -- If the table is available, insert the booking
            INSERT INTO Bookings (BookingDate, TableID, CustomerID)
            VALUES (p_BookingDate, tableID, p_CustomerID);

            -- Get the new Booking ID
            SET newBookingID = LAST_INSERT_ID();

            -- Log the booking in the Audit Log
            INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
            VALUES ('Bookings', 'INSERT', newBookingID, CONCAT('Booking for table ', p_TableNumber, ' on ', p_BookingDate), p_PerformedBy);

            -- Update the table availability
            UPDATE Tables SET IsAvailable = 0 WHERE TableID = tableID;

            COMMIT;

            SELECT CONCAT('Booking confirmed for Table ', p_TableNumber, ' on ', p_BookingDate) AS BookingStatus;
        END IF;
    END IF;
END$$

DELIMITER ;

DROP PROCEDURE CancelBooking;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelBooking`(
    IN p_BookingID INT,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;
    DECLARE oldData TEXT;
    DECLARE tableID INT;
    DECLARE futureBookings INT;
    DECLARE errorMessage VARCHAR(255);

    -- Check if booking exists
    SELECT COUNT(*), CONCAT('Date: ', BookingDate, ', Table: ', TableNumber), TableID
    INTO bookingExists, oldData, tableID
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- If booking exists
    IF bookingExists > 0 THEN
        -- Log the deletion
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, PerformedBy)
        VALUES ('Bookings', 'DELETE', p_BookingID, oldData, p_PerformedBy);

        -- Delete booking
        DELETE FROM Bookings WHERE BookingID = p_BookingID;

        -- Check if there are any future bookings for the table
        SELECT COUNT(*) INTO futureBookings
        FROM Bookings
        WHERE TableID = tableID AND BookingDate > CURDATE();

        -- If no future bookings, mark table as available
        IF futureBookings = 0 THEN
            UPDATE Tables SET IsAvailable = 1 WHERE TableID = tableID;
        END IF;

        COMMIT;
        SELECT CONCAT('Booking ', p_BookingID, ' canceled successfully.') AS CancelStatus;
    ELSE
        ROLLBACK;
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS CancelStatus;
    END IF;
END$$

DELIMITER ;

DROP TRIGGER IF EXISTS `LittleLemonDB`.`log_insert_booking`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `LittleLemonDB`.`log_insert_booking`
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
            CONCAT('Table Number: ', NEW.TableID, ', CustomerID: ', NEW.CustomerID, ', Booking Date: ', NEW.BookingDate), 
            CURRENT_USER());
END$$

DELIMITER ;

SELECT * FROM Customer_Details;
SELECT * FROM Staff_Information;

DELIMITER $$

CREATE TRIGGER update_order_total
AFTER INSERT ON `Order_Items`
FOR EACH ROW
BEGIN
    -- Update the TotalCost of the associated order by summing the total costs of the order items
    UPDATE Orders
    SET TotalCost = (
        SELECT SUM(TotalItemCost)
        FROM Order_Items
        WHERE OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END$$

DELIMITER ;

-- Temporarily drop the foreign key for `audit_log` referencing `Orders`
ALTER TABLE `Audit_Log` DROP FOREIGN KEY `fk_audit_log_orders`;


SHOW CREATE TABLE `Audit_Log`;
DESCRIBE Audit_log;

DROP TRIGGER log_insert_booking;


ALTER TABLE `LittleLemonDB`.`Bookings`
ADD COLUMN `Status` ENUM('New Booking', 'Cancelled') NOT NULL DEFAULT 'New Booking';


DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `LittleLemonDB`.`log_insert_booking`
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

DELIMITER ;


DROP TRIGGER log_insert_order;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `LittleLemonDB`.`log_insert_order`
AFTER INSERT ON `LittleLemonDB`.`Orders`
FOR EACH ROW
BEGIN
    -- Insert into Audit_Log after a new order is created
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
    VALUES ('Orders', 'INSERT', NEW.OrderID, 
            CONCAT('Customer: ', NEW.CustomerID, ', Staff: ', NEW.StaffID, ', Date: ', NEW.OrderDate, ', Total Cost: ', NEW.TotalCost), 
            CURRENT_USER());
END$$

DELIMITER ;

DROP TRIGGER log_update_booking;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `LittleLemonDB`.`log_update_booking`
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

DELIMITER ;

DROP PROCEDURE CancelBooking;

DELIMITER $$

CREATE PROCEDURE `CancelBooking`(
    IN p_BookingID INT,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;
    DECLARE oldStatus VARCHAR(50);
    DECLARE errorMessage VARCHAR(255);

    -- Check if booking exists and get the old status
    SELECT COUNT(*), Status
    INTO bookingExists, oldStatus
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- If booking exists
    IF bookingExists > 0 THEN
        -- Update booking status to 'Cancelled'
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = p_BookingID;

        -- Log the cancellation in the Audit_Log
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
        VALUES ('Bookings', 'UPDATE', p_BookingID,
                CONCAT('Old Status: ', oldStatus),
                'New Status: Cancelled',
                p_PerformedBy);

        -- Return a confirmation message
        SELECT CONCAT('Booking ', p_BookingID, ' has been canceled and status updated to Cancelled.') AS CancelStatus;
    ELSE
        -- If booking does not exist, call ErrorHandler procedure
        SET errorMessage = CONCAT('No booking found with ID: ', p_BookingID);
        CALL ErrorHandler(errorMessage, p_PerformedBy);  -- Call the ErrorHandler procedure
    END IF;
END$$

DELIMITER ;

ALTER TABLE Order_Delivery_Status
CHANGE COLUMN `DeliveryDate` `Date` DATE;

DELIMITER $$

CREATE TRIGGER log_new_order_status
AFTER INSERT ON `Orders`
FOR EACH ROW
BEGIN
    -- Insert initial status for the new order
    INSERT INTO `Order_Delivery_Status` (OrderID, Date, Status)
    VALUES (NEW.OrderID, CURDATE(), 'New Order');
END$$

DELIMITER ;

INSERT INTO `Order_Delivery_Status` (OrderID, Date, Status)
VALUES (151, CURDATE(), 'New Order');

SELECT o.OrderID, o.CustomerID, o.OrderDate, d.Status, d.Date
FROM Orders o
LEFT JOIN Order_Delivery_Status d ON o.OrderID = d.OrderID;

UPDATE Order_Delivery_Status
SET Status = 'Cancelled', Date = CURDATE()
WHERE OrderID = 151;

SELECT * FROM Order_Items WHERE OrderID = 151;

DELETE FROM Order_Items WHERE OrderID = 151;

SELECT * FROM Order_Delivery_Status WHERE OrderID = 151

DELIMITER $$

CREATE PROCEDURE CancelOrderAndDelete(
    IN p_OrderID INT
)
BEGIN
    -- Update the status of the order to 'Cancelled'
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled', Date = CURDATE()
    WHERE OrderID = p_OrderID;
    
    -- Delete all associated order items
    DELETE FROM Order_Items
    WHERE OrderID = p_OrderID;

    -- Optionally, you could also delete the order itself if needed
    DELETE FROM Orders WHERE OrderID = p_OrderID;

    SELECT CONCAT('Order ', p_OrderID, ' and its associated data have been cancelled and deleted.') AS StatusMessage;
END $$

DELIMITER ;

DROP PROCEDURE CancelOrderAndDelete;
DELIMITER $$

CREATE PROCEDURE CancelOrderAndDelete(
    IN p_OrderID INT
)
BEGIN
    -- Update the status of the order to 'Cancelled' in the Order_Delivery_Status table
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled', Date = CURDATE()
    WHERE OrderID = p_OrderID;

    -- Delete all associated order items from the Order_Items table
    DELETE FROM Order_Items
    WHERE OrderID = p_OrderID;

    -- Delete the order itself from the Orders table
    DELETE FROM Orders
    WHERE OrderID = p_OrderID;

    -- Return a confirmation message
    SELECT CONCAT('Order ', p_OrderID, ' and its associated data have been cancelled and deleted.') AS StatusMessage;
END $$

DELIMITER ;


SELECT o.OrderID, o.CustomerID, o.StaffID, o.OrderDate, o.TotalCost, ods.Status, ods.Date
FROM Orders o
LEFT JOIN Order_Delivery_Status ods
ON o.OrderID = ods.OrderID
WHERE o.OrderID = 152; -- Use the actual orderID



ALTER TABLE `Audit_Log`
DROP FOREIGN KEY `fk_audit_log_bookings`;

DELETE FROM Order_Items WHERE OrderID = 152;

ALTER TABLE Orders
ADD COLUMN BookingID INT NULL,
ADD CONSTRAINT fk_orders_bookings
FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
ON DELETE SET NULL ON UPDATE CASCADE;

DROP PROCEDURE CancelOrderAndUpdate;

DELIMITER $$

CREATE PROCEDURE CancelOrderAndUpdate(IN p_OrderID INT)
BEGIN
    DECLARE booking_id INT;

    -- Get BookingID related to this order
    SELECT BookingID INTO booking_id FROM Orders WHERE OrderID = p_OrderID;

    -- Cancel the order
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = p_OrderID;

    -- If this order is linked to a booking, cancel the booking too
    IF booking_id IS NOT NULL THEN
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = booking_id;
    END IF;

    -- Log the cancellation
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', p_OrderID, 'Status: Active', 'Status: Cancelled', CURRENT_USER());

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_order_cancelled
AFTER UPDATE ON Order_Delivery_Status
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = (SELECT BookingID FROM Orders WHERE OrderID = NEW.OrderID);
    END IF;
END;

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_order_cancelled
AFTER UPDATE ON Order_Delivery_Status
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = (SELECT BookingID FROM Orders WHERE OrderID = NEW.OrderID);
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER before_booking_cancel
BEFORE UPDATE ON Bookings
FOR EACH ROW
BEGIN
    DECLARE active_orders INT;

    -- Count active orders linked to this booking
    SELECT COUNT(*) INTO active_orders
    FROM Orders o
    JOIN Order_Delivery_Status ods ON o.OrderID = ods.OrderID
    WHERE o.BookingID = OLD.BookingID 
    AND ods.Status NOT IN ('Cancelled', 'Delivered');

    -- Prevent cancellation if there are active orders
    IF active_orders > 0 AND NEW.Status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot cancel booking: Active orders exist!';
    END IF;
END$$

DELIMITER ;
DROP TRIGGER before_booking_cancel;
DROP TRIGGER after_order_cancelled;
DROP PROCEDURE CancelBooking;


DELIMITER $$

CREATE TRIGGER after_order_cancelled
AFTER UPDATE ON Order_Delivery_Status
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = (SELECT BookingID FROM Orders WHERE OrderID = NEW.OrderID)
        AND BookingID IS NOT NULL;
    END IF;
END$$

DELIMITER ;


DROP PROCEDURE CancelOrderAndUpdate;

DELIMITER $$

CREATE PROCEDURE CancelOrderAndUpdate(IN p_OrderID INT)
BEGIN
    DECLARE booking_id INT;

    -- Get BookingID related to this order
    SELECT BookingID INTO booking_id FROM Orders WHERE OrderID = p_OrderID;

    -- Cancel the order
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = p_OrderID;

    -- If this order is linked to a booking, cancel the booking too
    IF booking_id IS NOT NULL THEN
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = booking_id;
    END IF;

    -- Log the cancellation
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Orders', 'UPDATE', p_OrderID, 'Status: Active', 'Status: Cancelled', CURRENT_USER());

END$$

DELIMITER ;

DROP TRIGGER after_order_cancelled;

DELIMITER $$

CREATE TRIGGER after_order_cancelled
AFTER UPDATE ON Order_Delivery_Status
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Bookings
        SET Status = 'Cancelled'
        WHERE BookingID = (SELECT BookingID FROM Orders WHERE OrderID = NEW.OrderID)
        AND BookingID IS NOT NULL;
    END IF;
END$$

DELIMITER ;

DROP PROCEDURE CancelOrderAndUpdate;
DROP PROCEDURE SetOrderDelivered;
DROP PROCEDURE SetOrderOutForDelivery;
DROP PROCEDURE SetOrderPreparing;


DELIMITER $$

CREATE PROCEDURE UpdateOrderStatus(
    IN order_id INT,
    IN new_status VARCHAR(20), -- Using VARCHAR instead of ENUM
    IN performed_by VARCHAR(100)
)
BEGIN
    DECLARE old_status VARCHAR(20); -- Change ENUM to VARCHAR

    -- Validate new_status input
    IF new_status NOT IN ('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid order status!';
    END IF;

    -- Retrieve the current status of the order before updating
    SELECT Status INTO old_status
    FROM Order_Delivery_Status
    WHERE OrderID = order_id;

    -- Ensure the order exists before updating
    IF old_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order not found!';
    END IF;

    -- Update the status of the order
    UPDATE Order_Delivery_Status
    SET Status = new_status
    WHERE OrderID = order_id;

    -- Log the status update in the Audit_Log table
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', order_id,
            CONCAT('Old Status: ', old_status),
            CONCAT('New Status: ', new_status),
            performed_by);

    -- Return a confirmation message
    SELECT CONCAT('Order ', order_id, ' status updated to ', new_status) AS Confirmation;
END$$

DELIMITER ;


