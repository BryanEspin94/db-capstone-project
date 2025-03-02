# 📊 Little Lemon Database Project

## 📖 Project Overview
This repository contains the database design, SQL scripts, and documentation for the **Little Lemon Database**, created as part of the **Meta Database Engineer Capstone Project** on Coursera.

**Little Lemon** is a growing restaurant that needs a robust relational database to manage its daily operations, including:
- 📅 Customer bookings
- 🛒 Order management
- 📦 Delivery status tracking
- 🍽️ Menu items and pricing
- 💼 Staff information

## 🏗️ Project Structure
```
little-lemon-database/
├── er-diagram/           # Contains ER diagram snapshots and design files
├── sql-scripts/           # SQL scripts for table creation, inserts, views, procedures, and queries
├── reports/                # Placeholder for any generated reports (if needed in future)
├── README.md               # This project overview file
```

## 📂 Files Explained
| Folder | Description |
|---|---|
| `er-diagram/` | Contains the entity-relationship diagram (ERD) that defines the data model for Little Lemon. |
| `sql-scripts/` | Contains all SQL scripts related to this project, including:<br> - Table creation <br> - Data insertion <br> - Views, procedures, and queries. |
| `reports/` | Placeholder directory to store any analytical reports derived from the data. |
| `README.md` | This file — provides project background and navigation. |

## 📜 Database Design Highlights
The database consists of the following tables:
- **Customer_Details**: Stores customer information such as name, phone, and email.
- **Bookings**: Captures table reservations.
- **Staff_Information**: Holds staff roles and salaries.
- **Menu**: Lists all available food and drink items.
- **Orders**: Captures each order made.
- **Order_Items**: Records items in each order, along with quantity and pricing.
- **Order_Delivery_Status**: Tracks delivery progress for each order (e.g., Preparing, Delivered, Cancelled).

## 💡 Key Features Implemented
✅ Fully normalized relational model (1NF, 2NF, 3NF)  
✅ Use of **views** to create virtual summary tables  
✅ Use of **stored procedures** to manage order statuses  
✅ Use of **prepared statements** for secure querying (prevents SQL injection)  
✅ Git version control for project tracking and collaboration

## 📚 How to Use
### To Set Up the Database:
1. Clone this repository:
    ```
    git clone https://github.com/BryanEspin94/db-capstone-project.git
    ```
2. Open MySQL Workbench and create a schema called `LittleLemonDB`.
3. Run all the scripts in `sql-scripts/` in the correct order:
    - `create_tables.sql`
    - `insert_data.sql`
    - `views_and_procedures.sql`
4. Call procedures, run queries, and generate reports as needed.

## 📧 Author
👨‍💻 **Bryan Espin**  
🎓 Created as part of the **Meta Database Engineer Capstone Project**

## 📜 License
This project is for **educational purposes** only and was built as part of a coursework requirement for the Meta Database Engineer Professional Certificate.

