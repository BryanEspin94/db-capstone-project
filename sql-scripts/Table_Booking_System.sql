SHOW TABLES;

SELECT * FROM Bookings;
SELECT * FROM Customer_Details;
SELECT * FROM Menu;
SELECT * FROM Order_Delivery_Status;
SELECT * FROM Order_Items;
SELECT * FROM Orders;
SELECT * FROM Staff_Information;


###############################
##### Table Booking System ####
###############################

#Task 1 - replicate list of records by adding them to the booking table

INSERT INTO Bookings (BookingDate, TableNumber, CustomerID) VALUES
('2025-03-09', 5, 1),
('2025-03-10', 3, 3),
('2025-03-11', 2, 2),
('2025-03-12', 2, 1);

/*
The data entered in the above code mimics:
- Table 2 being booked twice (BookingID 11 & 12)
- Customer 1 making two bookings (BookingID 9 & 12)
*/


#Task 2 - Create a stored procedure called CheckBooking to check whether a table in the restaurant is already booked.

/*For your second task, Little Lemon need you to create a stored procedure called CheckBooking to check whether a table in the restaurant is already booked. 
reating this procedure helps to minimize the effort involved in repeatedly coding the same SQL statements.
The procedure should have two input parameters in the form of booking date and table number. You can also create a variable in the procedure to check the status of each table.
*/

DELIMITER $$

/*
Procedure: CheckBooking
Description:
    This procedure checks if a specific table is already booked on a given date.
    It helps prevent double bookings for the same table on the same day.
Input:
    - p_BookingDate (DATE): The date for which the booking is being checked.
    - p_TableNumber (INT): The table number to check.
Output:
    - A message indicating whether the table is available or already booked.
*/

CREATE PROCEDURE CheckBooking(
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
END $$

DELIMITER ;

CALL CheckBooking('2025-03-01', 5);


#Task 3 - Create a stored procedure to verify a booking, and decline any reservations for tables that are already booked under another name.

DELIMITER $$

/*
Procedure: AddValidBooking
Description:
    Attempts to insert a new booking into the Bookings table.
    Uses a transaction to ensure integrity:
    - If the table is already booked on the specified date under a different customer, the transaction is rolled back.
    - If the table is available, the transaction is committed.
Input:
    - p_BookingDate (DATE): The date the customer wants to book.
    - p_TableNumber (INT): The table the customer wants to book.
    - p_CustomerID (INT): The ID of the customer making the booking.
Output:
    - A message indicating whether the booking was successful or declined.
*/

CREATE PROCEDURE AddValidBooking(
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

END $$

DELIMITER ;

#DELETE FROM Bookings
#WHERE BookingID BETWEEN 25 AND 29;

CALL AddValidBooking('2025-03-01', 5, 1);


DELIMITER $$


/*
Procedure: UpdateBooking
Description:
    Updates the booking date for an existing booking in the Bookings table.
    Ensures that a valid BookingID is provided before updating.
Input:
    - p_BookingID (INT): The ID of the booking to be updated.
    - p_NewBookingDate (DATE): The new date for the booking.
Output:
    - A message confirming whether the update was successful or if the booking ID was not found.
*/

CREATE PROCEDURE UpdateBooking(
    IN p_BookingID INT,
    IN p_NewBookingDate DATE,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;
    DECLARE oldBookingDate DATE;

    -- Check if booking exists
    SELECT COUNT(*), BookingDate
    INTO bookingExists, oldBookingDate
    FROM Bookings
    WHERE BookingID = p_BookingID;

    IF bookingExists > 0 THEN
        -- Log Old Data
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldData, NewData, PerformedBy)
        VALUES ('Bookings', 'UPDATE', p_BookingID, 
                CONCAT('Old Date: ', oldBookingDate), 
                CONCAT('New Date: ', p_NewBookingDate), 
                p_PerformedBy);

        -- Perform update
        UPDATE Bookings
        SET BookingDate = p_NewBookingDate
        WHERE BookingID = p_BookingID;

        SELECT CONCAT('Booking ', p_BookingID, ' updated to ', p_NewBookingDate) AS UpdateStatus;
    ELSE
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS UpdateStatus;
    END IF;

END $$


DELIMITER ;

CALL UpdateBooking(3, '2025-04-10');

DELIMITER $$


/*
Procedure: CancelBooking
Description:
    Cancels (deletes) an existing booking from the Bookings table.
    Ensures the booking exists before deleting it.
Input:
    - p_BookingID (INT): The ID of the booking to be canceled.
Output:
    - A message confirming whether the booking was canceled or if no matching ID was found.
*/

CREATE PROCEDURE CancelBooking(
    IN p_BookingID INT,
    IN p_PerformedBy VARCHAR(100)
)
BEGIN
    DECLARE bookingExists INT DEFAULT 0;
    DECLARE oldData TEXT;

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

        SELECT CONCAT('Booking ', p_BookingID, ' has been canceled successfully.') AS CancelStatus;
    ELSE
        SELECT CONCAT('No booking found with ID: ', p_BookingID) AS CancelStatus;
    END IF;

END $$


DELIMITER ;

CALL CancelBooking(4);

SELECT * FROM Bookings; #BookingID 4 is cancelled

DELIMITER $$

/*
Procedure: GetBookingsForDate
Description:
    Retrieves all bookings for a given date.
Input:
    - p_BookingDate (DATE): The date to retrieve bookings for.
Output:
    - A list of bookings including BookingID, TableNumber, and CustomerID.
*/

CREATE PROCEDURE GetBookingsForDate(
    IN p_BookingDate DATE
)
BEGIN
    SELECT BookingID, TableNumber, CustomerID
    FROM Bookings
    WHERE BookingDate = p_BookingDate
    ORDER BY TableNumber;
END $$

DELIMITER ;


DELIMITER $$

/*
Procedure: FindAvailableTables
Description:
    Finds tables that are NOT booked on a given date.
Input:
    - p_BookingDate (DATE): The date to check for available tables.
Output:
    - A list of available table numbers.
*/

CREATE PROCEDURE FindAvailableTables(
    IN p_BookingDate DATE
)
BEGIN
    SELECT DISTINCT TableNumber
    FROM Tables -- Assuming there is a 'Tables' table with all possible tables
    WHERE TableNumber NOT IN (
        SELECT TableNumber FROM Bookings WHERE BookingDate = p_BookingDate
    )
    ORDER BY TableNumber;
END $$

DELIMITER ;


DELIMITER $$

/*
Procedure: ChangeBookingTable
Description:
    Changes a customer's booking to a different table if available.
Input:
    - p_BookingID (INT): The booking ID to update.
    - p_NewTableNumber (INT): The new table number.
Output:
    - A message confirming success or failure.
*/

CREATE PROCEDURE ChangeBookingTable(
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
END $$

DELIMITER ;


DELIMITER $$

/*
Procedure: CancelAllBookingsForDate
Description:
    Cancels (deletes) all bookings for a given date.
Input:
    - p_BookingDate (DATE): The date to cancel all bookings for.
Output:
    - A message confirming how many bookings were deleted.
*/

CREATE PROCEDURE CancelAllBookingsForDate(
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
END $$

DELIMITER ;
