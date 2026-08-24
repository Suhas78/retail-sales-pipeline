/* =====================================================================
   Retail Sales Pipeline - Phase 3: Top Selling Products
   Description: Returns products ranked by total sales amount, used
                by the SSRS bar chart. @TopN controls how many rows
                come back (default 10).
   ===================================================================== */

USE RetailSalesDW;
GO

IF OBJECT_ID('dbo.usp_GetTopSellingProducts', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetTopSellingProducts;
GO

CREATE PROCEDURE dbo.usp_GetTopSellingProducts
    @TopN INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        p.ProductName,
        p.Category,
        SUM(fs.Quantity)    AS TotalQuantity,
        SUM(fs.TotalAmount) AS TotalSales
    FROM dbo.Fact_Sales fs
    INNER JOIN dbo.Dim_Products p ON fs.ProductKey = p.ProductKey
    GROUP BY
        p.ProductName,
        p.Category
    ORDER BY
        TotalSales DESC;
END
GO

-- Example usage:
--   EXEC dbo.usp_GetTopSellingProducts;              -- top 10 by default
--   EXEC dbo.usp_GetTopSellingProducts @TopN = 5;     -- top 5 only

PRINT 'Stored procedure usp_GetTopSellingProducts created successfully.';

-- Quick sanity check
EXEC dbo.usp_GetTopSellingProducts;
