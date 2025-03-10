###################################################
##### Create a virtual table to summarize data ####
###################################################


#################
##### TASK 1 ####
#################

#Create Trigger when rows are inserted into Order_Items, the TotalCost in Orders are automatically updated.

DELIMITER $$

CREATE TRIGGER update_order_total
AFTER INSERT ON Order_Items
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

#Update exising data in orders table - this is a one time fix

UPDATE Orders o
JOIN (
    SELECT OrderID, SUM(TotalItemCost) AS TotalCost
    FROM Order_Items
    GROUP BY OrderID
) calc ON o.OrderID = calc.OrderID
SET o.TotalCost = calc.TotalCost;

SELECT *
FROM Orders;

SELECT *
FROM Order_Items;

#Create virtual table to see all orders with a greater quantity than 2

CREATE VIEW OrdersView AS
SELECT o.OrderID,
	   SUM(oi.Quantity) AS TotalQuantity,
       SUM(oi.TotalItemCost) AS TotalCost
FROM Order_Items AS oi
INNER JOIN Orders AS o
ON oi.OrderID = o.OrderID
GROUP BY oi.OrderID
HAVING TotalQuantity > 2;

SELECT * 
FROM OrdersView;


#################
##### TASK 2 ####
#################

#Information on customers with orders more than $10

SELECT
    cd.CustomerID,
    CONCAT(cd.FirstName, ' ', cd.LastName) AS FullName,
    o.OrderID,
    o.TotalCost,
    GROUP_CONCAT(m.ItemName SEPARATOR ', ') AS ItemsOrdered
FROM Orders AS o
INNER JOIN Customer_Details AS cd
ON o.CustomerID = cd.CustomerID
INNER JOIN Order_Items AS oi
ON o.OrderID = oi.OrderID
INNER JOIN Menu AS m
ON oi.MenuID = m.MenuID
WHERE o.TotalCost > 10
GROUP BY o.OrderID
ORDER BY o.TotalCost ASC;

#################
##### TASK 3 ####
#################

#Information on all order items for which more than 2 orders have been placed.

SELECT m.ItemName
FROM Menu AS m
WHERE m.MenuID = ANY (
    SELECT oi.MenuID
    FROM Order_Items AS oi
    WHERE oi.Quantity > 2
);


##############################################################
##### Create Optimized queries to manage and analyze data ####
##############################################################

#################
##### TASK 1 ####
#################

#Create a procedure that displays the maximum ordered quantity form the Orders Table

DELIMITER $$

DROP PROCEDURE IF EXISTS GetMaxQuantity $$

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT CONCAT('The maximum quantity ordered is: ', MAX(Quantity)) AS Max_Qty_In_Order
    FROM Order_Items;
END $$

DELIMITER ;

CALL GetMaxQuantity();


#################
##### TASK 2 ####
#################

#Create a prepared statement called GetOrderDetails of a customer

-- Step 1: Define the SQL as a string, using a placeholder `?` for CustomerID
SET @sql = '
    SELECT 
        o.OrderID,
        SUM(oi.Quantity) AS TotalQuantity,
        o.TotalCost
    FROM Orders AS o
    INNER JOIN Order_Items AS oi
    ON o.OrderID = oi.OrderID
    WHERE o.CustomerID = ?
    GROUP BY o.OrderID
';

-- Step 2: Prepare the statement
PREPARE GetOrderDetail FROM @sql;

-- Step 3: Set the CustomerID variable
SET @id = 1;

-- Step 4: Execute the prepared statement, passing in the CustomerID
EXECUTE GetOrderDetail USING @id;


#################
##### TASK 3 ####
#################

/*
The CancelOrder procedure updates the delivery status of a specified order to ‘Cancelled’ in the Order_Delivery_Status table. 
This allows Little Lemon to preserve the order history while marking the order as no longer active. 
This is a soft cancel approach, meaning the order data is retained for future reporting, audits, or customer service purposes.
*/

SELECT *
FROM Order_Delivery_Status;

DELIMITER $$

CREATE PROCEDURE CancelOrder(IN order_id INT)
BEGIN
    UPDATE Order_Delivery_Status
    SET Status = 'Cancelled'
    WHERE OrderID = order_id;

    SELECT CONCAT('Order ', order_id, ' has been cancelled') AS Confirmation;
END $$

DELIMITER ;

CALL CancelOrder(8);

################################
##### ADDITIONAL PROCEDURES ####
################################


DELIMITER $$

/* 
Procedure: SetOrderPreparing
Description:
    Updates the delivery status of a specified order to 'Preparing'.
    This is used when the kitchen begins preparing the order.
Input:
    - order_id (INT): The ID of the order to update.
Output:
    - Confirmation message indicating the status update.
*/
CREATE PROCEDURE SetOrderPreparing(IN order_id INT)
BEGIN
    UPDATE Order_Delivery_Status
    SET Status = 'Preparing'
    WHERE OrderID = order_id;

    SELECT CONCAT('Order ', order_id, ' status updated to Preparing') AS Confirmation;
END $$


/* 
Procedure: SetOrderOutForDelivery
Description:
    Updates the delivery status of a specified order to 'Out for Delivery'.
    This is used when the order leaves the kitchen and is on its way to the customer.
Input:
    - order_id (INT): The ID of the order to update.
Output:
    - Confirmation message indicating the status update.
*/
CREATE PROCEDURE SetOrderOutForDelivery(IN order_id INT)
BEGIN
    UPDATE Order_Delivery_Status
    SET Status = 'Out for Delivery'
    WHERE OrderID = order_id;

    SELECT CONCAT('Order ', order_id, ' status updated to Out for Delivery') AS Confirmation;
END $$

DELIMITER ;

DROP PROCEDURE SetOrderDelivered;




