# End-to-End Retail Sales Data Pipeline & Dashboard

## 📌 Project Overview
This project is an end-to-end Data Engineering and Business Intelligence solution. It extracts raw retail sales data, transforms and loads it into a custom data warehouse using an ETL pipeline, and visualizes the insights through an interactive, parameter-driven dashboard.

## 🛠️ Technology Stack
* **Database:** Microsoft SQL Server (`SQLEXPRESS`)
* **ETL Tool:** SQL Server Integration Services (SSIS)
* **BI & Reporting:** SQL Server Reporting Services (SSRS) & Visual Studio 2022

## 🚀 Project Phases

### Phase 1: Data Warehouse Architecture (SQL Server)
* Designed a relational data warehouse (`RetailSalesDW`) to store transactional sales data.
* Developed optimized Stored Procedures (e.g., `sp_sales_by_category_region`) to aggregate data for reporting, enabling dynamic filtering by Year and Region.

### Phase 2: ETL Pipeline (SSIS)
* Built an automated Integration Services package to extract raw data.
* Applied data transformations, cleaned the data, and loaded it into the SQL Server staging and production tables.

### Phase 3: Interactive Dashboard (SSRS)
* Developed a reporting dashboard connecting directly to the live SQL database.
* **Matrix Report:** Built a dynamic cross-tab matrix to display `Total Sales` pivoting on `Region` and `Category`, grouped by `Sales Year`.
* **Visual Analytics:** Integrated a bar chart to highlight the "Top 10 Selling Products" based on performance.
* **Parameters:** Implemented user-facing parameters allowing users to filter the entire dashboard by `Year` and `Region`.

## 📸 Dashboard Preview

<img width="1919" height="942" alt="Screenshot 2026-08-24 183037" src="https://github.com/user-attachments/assets/63b73f30-42a4-4bbd-8355-e08181391bfe" />


## 📸 ETL Pipeline Preview

<img width="1915" height="1023" alt="Screenshot 2026-08-24 125816" src="https://github.com/user-attachments/assets/958ab33c-8ba0-4f02-ba51-001701dd3e13" />


---
**Author:** Suhas
