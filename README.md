# 📊 Little Lemon Database Project

## 📚 Project Overview
This repository contains the database design, SQL scripts, and documentation for the **Little Lemon Database**, created as part of the **Meta Database Engineer Capstone Project** on Coursera.

**Little Lemon** is a growing restaurant that needs a robust relational database to manage its daily operations, including:
- 📅 Customer bookings
- 🛍️ Order management
- 📦 Delivery status tracking
- 🍽️ Menu items and pricing
- 💼 Staff information

## 🏰 Project Structure
```
little-lemon-database/
├── er-diagram/           # Contains ER diagram snapshots and design files
├── sql-scripts/           # SQL scripts for table creation, inserts, views, procedures, and queries
├── reports/                # Placeholder for any generated reports (if needed in future)
├── Backup/                # Stores previous versions of scripts and database exports
├── README.md               # This project overview file
```

## 📂 Files Explained
| Folder | Description |
|---|---|
| `er-diagram/` | Contains the entity-relationship diagram (ERD) that defines the data model for Little Lemon. |
| `sql-scripts/` | Contains all SQL scripts related to this project, including:<br> - Table creation <br> - Data insertion <br> - Views, procedures, and queries. |
| `reports/` | Placeholder directory to store any analytical reports derived from the data. |
| `Backup/` | Stores previous versions of database scripts and schemas for reference. |
| `README.md` | This file — provides project background and navigation. |

## 🌟 Key Features Implemented
✅ Fully normalized relational model (1NF, 2NF, 3NF)  
✅ Use of **views** to create virtual summary tables  
✅ Use of **stored procedures** to manage order statuses  
✅ Use of **prepared statements** for secure querying (prevents SQL injection)  
✅ Git version control for project tracking and collaboration  
✅ Triggers to maintain data integrity and automate actions

## 📘 Database Design Highlights
The database consists of the following tables:
- **Customer_Details**: Stores customer information such as name, phone, and email.
- **Bookings**: Captures table reservations.
- **Staff_Information**: Holds staff roles and salaries.
- **Menu**: Lists all available food and drink items.
- **Orders**: Captures each order made.
- **Order_Items**: Records items in each order, along with quantity and pricing.
- **Order_Delivery_Status**: Tracks delivery progress for each order (e.g., Preparing, Delivered, Cancelled).

## 🔄 Stored Procedures & Triggers
The project includes stored procedures and triggers for automating tasks and maintaining consistency:

### **Stored Procedures**
| Procedure Name | Description |
|---|---|
| `AddValidBooking` | Adds a booking while ensuring the table is available. |
| `CancelAllBookingsForDate` | Cancels all bookings for a given date. |
| `CancelBooking` | Cancels a specific booking by updating its status. |
| `ChangeBookingTable` | Moves a booking to a different table if available. |
| `CheckBooking` | Checks if a table is booked on a given date. |
| `FindAvailableTables` | Finds all tables available on a specific date. |
| `UpdateBooking` | Updates an existing booking date. |
| `UpdateOrderStatus` | Changes the status of an order and logs changes. |

### **Triggers**
| Trigger Name | Description |
|---|---|
| `log_delete_booking` | Logs when a booking is deleted. |
| `log_insert_booking` | Logs when a new booking is made. |
| `log_update_booking` | Logs changes to existing bookings. |
| `log_insert_order` | Logs when a new order is placed. |
| `log_update_order_status` | Logs when an order status changes. |
| `log_insert_order_items` | Logs when new order items are added. |
| `log_delete_order_items` | Logs when order items are removed. |
| `update_order_total` | Updates the total cost of an order when new items are added. |

## 🛠️ Work in Progress: Database Setup Instructions
The setup instructions for deploying this database are currently **a work in progress**. Future updates will include step-by-step setup instructions, including:
- Database schema creation
- Data population
- Running stored procedures
- Querying data efficiently

Stay tuned for upcoming documentation!

## 👤 Author
👨‍💻 **Bryan Espin**  
🎓 Created as part of the **Meta Database Engineer Capstone Project**

## 📚 License
This project is for **educational purposes** only and was built as part of a coursework requirement for the Meta Database Engineer Professional Certificate.


