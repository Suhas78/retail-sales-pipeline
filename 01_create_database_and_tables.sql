/* =====================================================================
   Retail Sales Pipeline - Phase 1: Database & Table Creation
   Author: <Your Name>
   Description: Creates the RetailSalesDW database and the star-schema
                tables (2 dimensions + 1 fact table) used by the
                SSIS pipeline (Phase 2) and SSRS reports (Phase 3).
   ===================================================================== */

-- ---------------------------------------------------------------------
-- 0. Create the database
-- ---------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'RetailSalesDW')
BEGIN
    CREATE DATABASE RetailSalesDW;
END
GO

USE RetailSalesDW;
GO

-- ---------------------------------------------------------------------
-- 1. Dim_Products
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.Dim_Products', 'U') IS NOT NULL
    DROP TABLE dbo.Dim_Products;
GO

CREATE TABLE dbo.Dim_Products
(
    ProductKey      INT IDENTITY(1,1)   NOT NULL,   -- surrogate key
    ProductID       VARCHAR(20)         NOT NULL,   -- natural/business key from source CSV
    ProductName     VARCHAR(100)        NOT NULL,
    Category        VARCHAR(50)         NOT NULL,
    Price           DECIMAL(10,2)       NOT NULL CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    CreatedDate     DATETIME2           NOT NULL CONSTRAINT DF_Products_CreatedDate DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_Dim_Products PRIMARY KEY CLUSTERED (ProductKey),
    CONSTRAINT UQ_Dim_Products_ProductID UNIQUE (ProductID)
);
GO

-- ---------------------------------------------------------------------
-- 2. Dim_Customers
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.Dim_Customers', 'U') IS NOT NULL
    DROP TABLE dbo.Dim_Customers;
GO

CREATE TABLE dbo.Dim_Customers
(
    CustomerKey     INT IDENTITY(1,1)   NOT NULL,   -- surrogate key
    CustomerID      VARCHAR(20)         NOT NULL,   -- natural/business key from source CSV
    CustomerName    VARCHAR(100)        NOT NULL,
    Region          VARCHAR(50)         NOT NULL,
    CreatedDate     DATETIME2           NOT NULL CONSTRAINT DF_Customers_CreatedDate DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_Dim_Customers PRIMARY KEY CLUSTERED (CustomerKey),
    CONSTRAINT UQ_Dim_Customers_CustomerID UNIQUE (CustomerID)
);
GO

-- ---------------------------------------------------------------------
-- 3. Fact_Sales
--    Only keys + measures live here (star-schema discipline).
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.Fact_Sales', 'U') IS NOT NULL
    DROP TABLE dbo.Fact_Sales;
GO

CREATE TABLE dbo.Fact_Sales
(
    SalesKey        BIGINT IDENTITY(1,1)   NOT NULL,   -- surrogate key
    TransactionID   VARCHAR(30)            NOT NULL,   -- natural key from source CSV
    CustomerKey     INT                    NOT NULL,
    ProductKey      INT                    NOT NULL,
    SalesDate       DATE                   NOT NULL,
    Quantity        INT                    NOT NULL CONSTRAINT CK_Sales_Quantity CHECK (Quantity > 0),
    TotalAmount     DECIMAL(12,2)          NOT NULL CONSTRAINT CK_Sales_TotalAmount CHECK (TotalAmount >= 0),
    LoadDate        DATETIME2              NOT NULL CONSTRAINT DF_Sales_LoadDate DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_Fact_Sales PRIMARY KEY CLUSTERED (SalesKey),
    CONSTRAINT UQ_Fact_Sales_TransactionID UNIQUE (TransactionID),
    CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerKey) REFERENCES dbo.Dim_Customers (CustomerKey),
    CONSTRAINT FK_Sales_Product  FOREIGN KEY (ProductKey)  REFERENCES dbo.Dim_Products (ProductKey)
);
GO

-- ---------------------------------------------------------------------
-- 4. Indexes to support common reporting queries
--    (SSRS matrix filters/groups by Region, Category, Year)
-- ---------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Sales_SalesDate ON dbo.Fact_Sales (SalesDate);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerKey ON dbo.Fact_Sales (CustomerKey) INCLUDE (TotalAmount, Quantity);
CREATE NONCLUSTERED INDEX IX_Sales_ProductKey ON dbo.Fact_Sales (ProductKey) INCLUDE (TotalAmount, Quantity);
GO

PRINT 'RetailSalesDW schema created successfully.';
