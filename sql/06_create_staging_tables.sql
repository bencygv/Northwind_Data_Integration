USE NorthwindIntegration;
GO

---------------------------------------------
-- CREATE STAGING TABLES
---------------------------------------------

-- STAGING TABLE 1: SHIPPERS

IF OBJECT_ID('staging.Shippers', 'U') IS NULL
    CREATE TABLE staging.Shippers
    (
        ShipperID INT,
        CompanyName NVARCHAR(40),
        Phone NVARCHAR(24)
    );
GO

--Verify the staging table

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'staging'
  AND TABLE_NAME = 'Shippers';

-- STAGING TABLE 2: CATEGORIES

IF OBJECT_ID('staging.Categories','U') IS NULL
    CREATE TABLE staging.Categories
    (
        CategoryID INT,
        CategoryName NVARCHAR(15),
        Description NVARCHAR(MAX),
        Picture VARBINARY(MAX)
    );

SELECT TABLE_SCHEMA,
       TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'staging'
    AND TABLE_NAME = 'Categories';

-- STAGING TABLE 3: SUPPLIERS

IF OBJECT_ID('staging.Suppliers', 'U') IS NULL
    CREATE TABLE staging.Suppliers
    (
        SupplierID INT,
        CompanyName NVARCHAR(40),
        ContactName NVARCHAR(30),
        ContactTitle NVARCHAR(30),
        Address NVARCHAR(60),
        City NVARCHAR(15),
        Region NVARCHAR(15),
        PostalCode NVARCHAR(10),
        Country NVARCHAR(15),
        Phone NVARCHAR(24),
        Fax NVARCHAR(24),
        HomePage NVARCHAR(MAX)
    );
GO

-- STAGING TABLE 4: PRODUCTS

IF OBJECT_ID('staging.Products', 'U') IS NULL
    CREATE TABLE staging.Products
    (
        ProductID INT,
        ProductName NVARCHAR(40),
        SupplierID INT,
        CategoryID INT,
        QuantityPerUnit NVARCHAR(20),
        UnitPrice MONEY,
        UnitsInStock SMALLINT,
        UnitsOnOrder SMALLINT,
        ReorderLevel SMALLINT,
        Discontinued BIT
    );
GO

-- STAGING TABLE 5: CUSTOMERS

IF OBJECT_ID('staging.Customers', 'U') IS NULL
    CREATE TABLE staging.Customers
    (
        CustomerID NCHAR(5),
        CompanyName NVARCHAR(40),
        ContactName NVARCHAR(30),
        ContactTitle NVARCHAR(30),
        Address NVARCHAR(60),
        City NVARCHAR(15),
        Region NVARCHAR(15),
        PostalCode NVARCHAR(10),
        Country NVARCHAR(15),
        Phone NVARCHAR(24),
        Fax NVARCHAR(24)
    );
GO

-- STAGING TABLE 6: ORDERS

IF OBJECT_ID('staging.Orders', 'U') IS NULL
    CREATE TABLE staging.Orders
    (
        OrderID INT,
        CustomerID NCHAR(5),
        EmployeeID INT,
        OrderDate DATETIME,
        RequiredDate DATETIME,
        ShippedDate DATETIME,
        ShipVia INT,
        Freight MONEY,
        ShipName NVARCHAR(40),
        ShipAddress NVARCHAR(60),
        ShipCity NVARCHAR(15),
        ShipRegion NVARCHAR(15),
        ShipPostalCode NVARCHAR(10),
        ShipCountry NVARCHAR(15)
    );
GO

-- STAGING TABLE 7: ORDER DETAILS

IF OBJECT_ID('staging.OrderDetails', 'U') IS NULL
    CREATE TABLE staging.OrderDetails
    (
        OrderID INT,
        ProductID INT,
        UnitPrice MONEY,
        Quantity SMALLINT,
        Discount REAL
    );
GO