
USE NorthwindIntegration;
GO

-- Create a schema for our SSIS demonstration
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'demo'
)
BEGIN
    EXEC('CREATE SCHEMA demo');
END;
GO

-- Table 1: Valid products
IF OBJECT_ID('demo.ValidProducts', 'U') IS NULL
BEGIN
    CREATE TABLE demo.ValidProducts
    (
        ProductID NVARCHAR(20),
        ProductName NVARCHAR(100),
        Category NVARCHAR(60),
        UnitPrice DECIMAL(19,4),
        UnitsInStock INT
    );
END;
GO

-- Table 2: Rejected products
IF OBJECT_ID('demo.RejectedProducts', 'U') IS NULL
BEGIN
    CREATE TABLE demo.RejectedProducts
    (
        ProductID NVARCHAR(20),
        ProductName NVARCHAR(100),
        Category NVARCHAR(60),
        UnitPrice NVARCHAR(40),
        UnitsInStock NVARCHAR(40),
        RejectReason NVARCHAR(100) NULL,
        ErrorCode INT NULL,
        ErrorColumn INT NULL
    );
END;
GO



USE NorthwindIntegration;
GO

SELECT COUNT(*) AS ValidRecords
FROM demo.ValidProducts;

SELECT COUNT(*) AS RejectedRecords
FROM demo.RejectedProducts;
