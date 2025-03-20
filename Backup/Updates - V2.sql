SELECT * FROM Bookings;
SELECT * FROM Customer_Details;
SELECT * FROM Menu;
SELECT * FROM Order_Delivery_Status;
SELECT * FROM Order_Items;
SELECT * FROM Orders;
SELECT * FROM Staff_Information;
SELECT * FROM Tables;


# Query to have a single view to track all bookings and orders within a range - due to be turned into a Table View.
SELECT 
    b.BookingID,
    b.BookingDate,
    c.FirstName AS Customer_FirstName,
    c.LastName AS Customer_LastName,
    t.TableNumber,
    b.Status AS BookingStatus,
    o.OrderID,
    o.OrderDate,
    o.TotalCost,
    s.FirstName AS Staff_FirstName,
    s.LastName AS Staff_LastName,
    d.Status AS DeliveryStatus
FROM Bookings b
LEFT JOIN Customer_Details c ON b.CustomerID = c.CustomerID
LEFT JOIN Tables t ON b.TableID = t.TableID
LEFT JOIN Orders o ON b.BookingID = o.BookingID
LEFT JOIN Staff_Information s ON o.StaffID = s.StaffID
LEFT JOIN Order_Delivery_Status d ON o.OrderID = d.OrderID
WHERE b.BookingDate BETWEEN '2025-03-15' AND '2025-03-16'
ORDER BY b.BookingDate ASC, o.OrderDate ASC;


#Procedure - AddMultipleItemsToOrder

/*
This procedure:
	•	Accepts OrderID, MenuIDs, and Quantities as comma-separated strings.
	•	Iterates through each MenuID and its corresponding Quantity.
	•	Inserts them into Order_Items in a single call.
*/

DELIMITER $$

CREATE PROCEDURE AddMultipleItemsToOrder(
    IN p_OrderID INT,
    IN p_MenuIDs TEXT,
    IN p_Quantities TEXT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_MenuID INT;
    DECLARE v_Quantity INT;
    DECLARE v_ItemPrice DECIMAL(10,2);
    DECLARE menu_cursor CURSOR FOR 
        SELECT menu_id, quantity FROM (
            SELECT 
                SUBSTRING_INDEX(SUBSTRING_INDEX(p_MenuIDs, ',', numbers.n), ',', -1) AS menu_id,
                SUBSTRING_INDEX(SUBSTRING_INDEX(p_Quantities, ',', numbers.n), ',', -1) AS quantity
            FROM 
                (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 
                 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) numbers
            WHERE CHAR_LENGTH(p_MenuIDs) - CHAR_LENGTH(REPLACE(p_MenuIDs, ',', '')) >= numbers.n - 1
        ) AS temp_data;

    -- Handler for cursor loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN menu_cursor;

    read_loop: LOOP
        FETCH menu_cursor INTO v_MenuID, v_Quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Get the price from the Menu table
        SELECT Price INTO v_ItemPrice FROM Menu WHERE MenuID = v_MenuID;

        -- Insert the order item
        INSERT INTO Order_Items (OrderID, MenuID, Quantity, ItemPrice)
        VALUES (p_OrderID, v_MenuID, v_Quantity, v_ItemPrice);

    END LOOP;

    CLOSE menu_cursor;

    -- Update order status to 'Preparing'
    UPDATE Order_Delivery_Status
    SET Status = 'Preparing'
    WHERE OrderID = p_OrderID AND Status = 'New Order';

END $$

DELIMITER ;
 
SHOW TRIGGERS LIKE 'Order_Items';

SHOW CREATE TABLE Order_Items;


DELIMITER $$

CREATE PROCEDURE CancelBooking(
    IN booking_id INT,
    IN performed_by VARCHAR(100)  -- Track who performed the action
)
BEGIN
    DECLARE bookingExists INT;
    DECLARE bookingStatus VARCHAR(20);
    DECLARE errorMessage VARCHAR(255);

    -- Start a transaction for atomicity
    START TRANSACTION;

    -- Check if the booking exists and retrieve its status
    SELECT COUNT(*), Status INTO bookingExists, bookingStatus
    FROM Bookings
    WHERE BookingID = booking_id;

    -- If booking does not exist, call ErrorHandler and exit
    IF bookingExists = 0 THEN
        SET errorMessage = 'Error: Booking ID not found';
        CALL ErrorHandler(errorMessage, performed_by);
    END IF;

    -- Prevent cancelling an already cancelled booking
    IF bookingStatus = 'Cancelled' THEN
        SET errorMessage = 'Error: Booking is already cancelled';
        CALL ErrorHandler(errorMessage, performed_by);
    END IF;

    -- Cancel any associated orders by setting their status to 'Cancelled'
    UPDATE Orders o
    JOIN Order_Delivery_Status ods ON o.OrderID = ods.OrderID
    SET ods.Status = 'Cancelled'
    WHERE o.BookingID = booking_id;

    -- Mark the booking as cancelled
    UPDATE Bookings
    SET Status = 'Cancelled'
    WHERE BookingID = booking_id;

    -- Log the cancellation in Audit_Log
    INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
    VALUES ('Bookings', 'UPDATE', booking_id, 'Status: New Booking', 'Status: Cancelled', performed_by);

    -- Commit the transaction
    COMMIT;

    -- Return success message
    SELECT CONCAT('Booking ID ', booking_id, ' has been successfully cancelled.') AS Message;
END$$

DELIMITER ;

DROP PROCEDURE AddValidBooking;

DELIMITER $$

CREATE PROCEDURE AddValidBooking(
    IN p_BookingDate DATE,      -- The date the booking is requested for
    IN p_TableID INT,           -- The table ID to be booked
    IN p_CustomerID INT,        -- The ID of the customer making the booking
    IN p_PerformedBy VARCHAR(100) -- The user performing the booking
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;  -- Track if the table is already booked
    DECLARE newBookingID INT;             -- Store the new booking ID after insertion
    DECLARE tableValid INT DEFAULT 0;     -- Track if the table exists
    DECLARE errorMessage VARCHAR(255);    -- Store error messages

    -- Start a transaction to ensure atomicity
    START TRANSACTION;

    -- Check if the table exists in the Tables table
    SELECT COUNT(*)
    INTO tableValid
    FROM Tables
    WHERE TableID = p_TableID;

    -- If the table does not exist, rollback
    IF tableValid = 0 THEN
        SET errorMessage = CONCAT('Booking declined: Table ', p_TableID, ' does not exist.');
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
    ELSE
        -- Check if the table is already booked on the given date
        SELECT COUNT(*)
        INTO bookingExists
        FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableID = p_TableID;

        -- If the table is already booked, rollback
        IF bookingExists > 0 THEN
            SET errorMessage = CONCAT('Booking declined: Table ', p_TableID, ' is already booked on ', p_BookingDate);
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = errorMessage;
        ELSE
            -- If available, insert the booking into the Bookings table
            INSERT INTO Bookings (BookingDate, TableID, CustomerID, Status)
            VALUES (p_BookingDate, p_TableID, p_CustomerID, 'New Booking');

            -- Get the ID of the newly inserted booking
            SET newBookingID = LAST_INSERT_ID();

            -- Log the insertion action in the Audit_Log table
            INSERT INTO Audit_Log (TableName, ActionType, RecordID, NewData, PerformedBy)
            VALUES ('Bookings', 'INSERT', newBookingID, 
                    CONCAT('Date: ', p_BookingDate, ', Table: ', p_TableID, ', Customer: ', p_CustomerID), 
                    p_PerformedBy);

            -- Commit the transaction, making all changes permanent
            COMMIT;

            -- Return a success message
            SELECT CONCAT('Booking confirmed for Table ', p_TableID, ' on ', p_BookingDate) AS BookingStatus;
        END IF;
    END IF;
END $$

DELIMITER ;
