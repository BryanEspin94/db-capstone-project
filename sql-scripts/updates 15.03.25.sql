DROP PROCEDURE CheckBooking;

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

DROP PROCEDURE FindAvailableTables;

DELIMITER $$

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

DROP PROCEDURE CancelAllBookingsForDate;

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


DROP PROCEDURE ChangeBookingTable;


DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ChangeBookingTable`(
    IN p_BookingID INT,  
    IN p_NewTableNumber INT  
)
BEGIN
    DECLARE existingDate DATE;  
    DECLARE tableBooked INT DEFAULT 0;  
    DECLARE errorMessage VARCHAR(255);  
    DECLARE newTableID INT;  

    -- Ensure valid input
    IF p_BookingID IS NULL OR p_NewTableNumber IS NULL THEN
        SET errorMessage = 'Booking ID or Table Number cannot be NULL.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    -- Get TableID from TableNumber
    SELECT TableID INTO newTableID FROM Tables WHERE TableNumber = p_NewTableNumber;

    -- If table does not exist, return error
    IF newTableID IS NULL THEN
        SET errorMessage = CONCAT('Table ', p_NewTableNumber, ' does not exist.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    END IF;

    -- Get existing booking date
    SELECT BookingDate INTO existingDate FROM Bookings WHERE BookingID = p_BookingID;

    -- Check if new table is already booked on that date (excluding cancelled bookings)
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


DROP PROCEDURE UpdateOrderStatus;


DELIMITER $$
USE `LittleLemonDB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateOrderStatus`(
    IN order_id INT,
    IN new_status VARCHAR(20), -- Using VARCHAR instead of ENUM
    IN performed_by VARCHAR(100)
)
BEGIN
    DECLARE old_status VARCHAR(20); 
    DECLARE orderExists INT;

    -- Validate new_status input
    IF new_status NOT IN ('New Order', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid order status!';
    END IF;

    -- Check if the order exists
    SELECT COUNT(*) INTO orderExists FROM Order_Delivery_Status WHERE OrderID = order_id;
    IF orderExists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found!';
    END IF;

    -- Retrieve the current status
    SELECT Status INTO old_status FROM Order_Delivery_Status WHERE OrderID = order_id;

    -- Update the status
    UPDATE Order_Delivery_Status SET Status = new_status WHERE OrderID = order_id;

    -- Log the status update
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Order_Delivery_Status', 'UPDATE', order_id,
            CONCAT('Old Status: ', old_status),
            CONCAT('New Status: ', new_status),
            performed_by);

    -- Confirmation message
    SELECT CONCAT('Order ', order_id, ' status updated to ', new_status) AS Confirmation;
END$$

DELIMITER ;


DROP PROCEDURE CancelAllBookingsForDate;

DELIMITER $$

CREATE PROCEDURE CancelAllBookingsForDate(
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


DROP PROCEDURE UpdateOrderStatus;

DELIMITER $$

CREATE PROCEDURE UpdateOrderStatus(
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


DROP PROCEDURE ChangeBookingTable;


DELIMITER $$

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


DROP PROCEDURE FindAvailableTables;

DELIMITER $$

CREATE PROCEDURE FindAvailableTables(
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
    WHERE b.TableID IS NULL OR b.Status = 'Cancelled'
    AND t.IsAvailable = 1
    ORDER BY t.TableNumber;
END$$

DELIMITER ;


DROP PROCEDURE ErrorHandler;


DELIMITER $$

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



