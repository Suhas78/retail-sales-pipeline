/* =====================================================================
   Retail Sales Pipeline - Sample Seed Data
   Description: Small hand-written dataset so you can test the schema
                and stored procedure immediately, before building the
                SSIS package. NOT the same as the raw CSV used in
                Phase 2 - that file should intentionally contain messy
                data (bad formats, blanks, wrong types) to prove SSIS
                cleans it correctly.
   ===================================================================== */

USE RetailSalesDW;
GO

-- Clear existing data (children first because of FKs)
DELETE FROM dbo.Fact_Sales;
DELETE FROM dbo.Dim_Customers;
DELETE FROM dbo.Dim_Products;
GO

-- Note: we deliberately do NOT hardcode or reseed identity key numbers here.
-- SQL Server's identity numbering can start at 0 instead of 1 on a table
-- that has never had rows (a known quirk), so Fact_Sales below looks up
-- CustomerKey/ProductKey by their natural business ID instead of assuming
-- specific numbers. This is also safer general practice.

-- ---------------------------------------------------------------------
-- Products
-- ---------------------------------------------------------------------
INSERT INTO dbo.Dim_Products (ProductID, ProductName, Category, Price) VALUES
('P001', 'Wireless Mouse',      'Electronics', 19.99),
('P002', '4K Monitor',          'Electronics', 249.99),
('P003', 'Office Chair',        'Furniture',   129.50),
('P004', 'Standing Desk',       'Furniture',   349.00),
('P005', 'Notebook Pack',       'Stationery',  4.99),
('P006', 'Ballpoint Pen Set',   'Stationery',  6.49);
GO

-- ---------------------------------------------------------------------
-- Customers
-- ---------------------------------------------------------------------
INSERT INTO dbo.Dim_Customers (CustomerID, CustomerName, Region) VALUES
('C001', 'Aarav Sharma',    'South'),
('C002', 'Priya Nair',      'South'),
('C003', 'Rahul Verma',     'North'),
('C004', 'Sneha Iyer',      'West'),
('C005', 'Karan Mehta',     'West'),
('C006', 'Divya Reddy',     'East');
GO

-- ---------------------------------------------------------------------
-- Sales transactions
-- ---------------------------------------------------------------------
-- Staging table of "raw" transaction data using natural business keys
-- (this mirrors what a real CSV feed would look like before SSIS/lookup)
DECLARE @RawSales TABLE
(
    TransactionID VARCHAR(30),
    CustomerID    VARCHAR(20),
    ProductID     VARCHAR(20),
    SalesDate     DATE,
    Quantity      INT,
    TotalAmount   DECIMAL(12,2)
);

INSERT INTO @RawSales (TransactionID, CustomerID, ProductID, SalesDate, Quantity, TotalAmount) VALUES
('T1001', 'C001', 'P001', '2025-01-15', 2,  39.98),
('T1002', 'C002', 'P002', '2025-01-16', 1,  249.99),
('T1003', 'C003', 'P003', '2025-02-02', 1,  129.50),
('T1004', 'C004', 'P004', '2025-02-10', 1,  349.00),
('T1005', 'C005', 'P005', '2025-03-05', 10, 49.90),
('T1006', 'C006', 'P006', '2025-03-06', 5,  32.45),
('T1007', 'C001', 'P003', '2026-01-11', 2,  259.00),
('T1008', 'C002', 'P004', '2026-01-20', 1,  349.00),
('T1009', 'C003', 'P001', '2026-02-14', 4,  79.96),
('T1010', 'C004', 'P002', '2026-02-15', 1,  249.99);

-- Resolve natural keys (CustomerID/ProductID) to surrogate keys
-- (CustomerKey/ProductKey) at insert time -- this is exactly what an
-- SSIS Lookup transformation will do in Phase 2.
INSERT INTO dbo.Fact_Sales (TransactionID, CustomerKey, ProductKey, SalesDate, Quantity, TotalAmount)
SELECT
    r.TransactionID,
    c.CustomerKey,
    p.ProductKey,
    r.SalesDate,
    r.Quantity,
    r.TotalAmount
FROM @RawSales r
INNER JOIN dbo.Dim_Customers c ON r.CustomerID = c.CustomerID
INNER JOIN dbo.Dim_Products  p ON r.ProductID  = p.ProductID;
GO

PRINT 'Sample data inserted successfully.';

-- Quick sanity check
EXEC dbo.usp_GetSalesByCategoryAndRegion;
