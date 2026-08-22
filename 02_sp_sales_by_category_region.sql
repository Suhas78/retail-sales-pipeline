/* =====================================================================
   Retail Sales Pipeline - Phase 1: Stored Procedure
   Description: Returns total sales aggregated by Category and Region.
                Optional @Year and @Region parameters let SSRS drive
                dropdown filters (Phase 3) without changing the query.
   ===================================================================== */

USE RetailSalesDW;
GO

IF OBJECT_ID('dbo.usp_GetSalesByCategoryAndRegion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetSalesByCategoryAndRegion;
GO

CREATE PROCEDURE dbo.usp_GetSalesByCategoryAndRegion
    @Year   INT          = NULL,   -- NULL = all years
    @Region VARCHAR(50)  = NULL    -- NULL = all regions
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        YEAR(fs.SalesDate)     AS SalesYear,
        c.Region,
        p.Category,
        SUM(fs.Quantity)       AS TotalQuantity,
        SUM(fs.TotalAmount)    AS TotalSales,
        COUNT(DISTINCT fs.TransactionID) AS TransactionCount
    FROM dbo.Fact_Sales fs
    INNER JOIN dbo.Dim_Customers c ON fs.CustomerKey = c.CustomerKey
    INNER JOIN dbo.Dim_Products  p ON fs.ProductKey  = p.ProductKey
    WHERE (@Year IS NULL   OR YEAR(fs.SalesDate) = @Year)
      AND (@Region IS NULL OR c.Region = @Region)
    GROUP BY
        YEAR(fs.SalesDate),
        c.Region,
        p.Category
    ORDER BY
        SalesYear, c.Region, p.Category;
END
GO

-- ---------------------------------------------------------------------
-- Example usage:
--   EXEC dbo.usp_GetSalesByCategoryAndRegion;                       -- all data
--   EXEC dbo.usp_GetSalesByCategoryAndRegion @Year = 2025;          -- one year
--   EXEC dbo.usp_GetSalesByCategoryAndRegion @Region = 'West';      -- one region
--   EXEC dbo.usp_GetSalesByCategoryAndRegion @Year = 2025, @Region = 'West';
-- ---------------------------------------------------------------------

PRINT 'Stored procedure usp_GetSalesByCategoryAndRegion created successfully.';
