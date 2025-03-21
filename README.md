# Little Lemon Database Project

## Project Overview
This repository contains the database design, SQL scripts, and documentation for the **Little Lemon Database**, created as part of the **Meta Database Engineer Capstone Project** on Coursera.

**Little Lemon** is a growing restaurant that requires a robust relational database to manage its daily operations, including:
- Customer bookings
- Order management
- Delivery status tracking
- Menu items and pricing
- Staff information

## Project Structure
```
little-lemon-database/
├── er-diagram/           # ER diagram snapshots and design files
├── sql-scripts/          # SQL scripts for table creation, inserts, procedures, and queries
├── reports/              # Placeholder for any generated reports (if needed in future)
├── Backup/               # Stores previous versions of scripts and database exports
├── Python Scripts/       # Jupyter notebooks and Python scripts for database testing
├── README.md             # This project overview file
```

## Files Explained
| Folder | Description |
|---|---|
| `er-diagram/` | Contains the entity-relationship diagram (ERD) defining the data model for Little Lemon. |
| `sql-scripts/` | Includes all SQL scripts related to this project, including table creation, data insertion, stored procedures, and queries. |
| `reports/` | Placeholder directory for storing any analytical reports derived from the data. |
| `Backup/` | Stores previous versions of database scripts and schemas for reference. |
| `Python Scripts/` | Contains Jupyter notebooks and Python scripts for testing stored procedures and queries. |
| `README.md` | This file, providing project background and navigation. |

## Key Features Implemented
- ✅ Fully normalized relational model (1NF, 2NF, 3NF)  
- ✅ Stored procedures to manage order statuses and bookings  
- ✅ Prepared statements for secure querying (prevents SQL injection)  
- ✅ Git version control for project tracking and collaboration  
- ✅ Triggers to maintain data integrity and automate actions  
- ✅ New procedure: `CancelBooking` – allows canceling individual bookings  
- ✅ Enhanced audit logging using comprehensive trigger coverage  

## Database Design Highlights
The database consists of the following tables:
- **Customer_Details**: Stores customer information (name, phone, email).
- **Bookings**: Captures table reservations.
- **Staff_Information**: Holds staff roles and salaries.
- **Menu**: Lists all available food and drink items.
- **Orders**: Captures each order made.
- **Order_Items**: Records items in each order, along with quantity and pricing.
- **Order_Delivery_Status**: Tracks delivery progress for each order (e.g., Preparing, Delivered, Cancelled).

## Stored Procedures & Triggers
This project includes stored procedures and triggers for automating tasks and maintaining consistency:

### Stored Procedures
| Procedure Name            | Description |
|--------------------------|-------------|
| `AddValidBooking`         | Adds a booking while ensuring the table is available. |
| `CancelAllBookingsForDate` | Cancels all bookings for a given date. |
| `CancelBooking`           | Cancels a specific booking by updating its status and logging the action. |
| `ChangeBookingTable`      | Moves a booking to a different table if available. |
| `CheckBooking`            | Checks if a table is booked on a given date. |
| `ErrorHandler`            | Handles and logs errors during transactional procedures. |
| `FindAvailableTables`     | Finds all available tables on a specific date. |
| `GetBookingsForDate`      | Returns all bookings for a specific date. |
| `GetMaxQuantity`          | Returns the highest quantity ordered across all items. |
| `UpdateBooking`           | Updates an existing booking's date with logging. |
| `UpdateOrderStatus`       | Updates the status of an order and logs the change. |
| `AddMultipleItemsToOrder` | Adds multiple items to an order based on comma-separated inputs. |
| `CreateOrder`             | Creates a new order based on a booking and assigns a staff member. |

### Triggers
| Trigger Name              | Description |
|--------------------------|-------------|
| `log_delete_booking`      | Logs when a booking is deleted. |
| `log_insert_booking`      | Logs when a new booking is made. |
| `log_update_booking`      | Logs changes to existing bookings. |
| `log_insert_order`        | Logs when a new order is placed. |
| `log_update_order_status` | Logs when an order status changes. |
| `after_order_cancelled`   | Automatically cancels bookings if an order is marked as 'Cancelled'. |
| `log_insert_order_items`  | Logs when new order items are added. |
| `log_delete_order_items`  | Logs when order items are removed. |
| `log_update_order_items`  | Logs updates to order item quantity or price. |
| `update_order_total`      | Automatically updates the total cost of an order when new items are added. |

## Work in Progress: Database Setup Instructions
The setup instructions for deploying this database are currently **a work in progress**. Future updates will include:
- Database schema creation
- Data population
- Running stored procedures
- Querying data efficiently

Stay tuned for upcoming documentation!

## Author
👨‍💻 **Bryan Espin**  
🎓 Created as part of the **Meta Database Engineer Capstone Project**

## License
This project is for **educational purposes** only and was built as part of a coursework requirement for the Meta Database Engineer Professional Certificate.


