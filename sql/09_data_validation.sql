--------------------------------------------
-- VALIDATE STAGING TABLES
--------------------------------------------

USE NorthwindIntegration;
GO

-- VALIDATE SHIPPERS STAGING LOAD

SELECT COUNT(*) AS TotalShippers
FROM staging.Shippers;

SELECT *
FROM staging.Shippers;

-- VALIDATE CATEGORIES STAGING LOAD

SELECT
    COUNT(*) AS TotalCategories
FROM staging.Categories;

SELECT
    CategoryID,
    CategoryName
FROM staging.Categories
ORDER BY CategoryID;

-- VALIDATE SUPPLIERS STAGING LOAD

SELECT COUNT(*) AS TotalSuppliers
FROM staging.Suppliers;

SELECT
    SupplierID,
    CompanyName,
    Country
FROM staging.Suppliers
ORDER BY SupplierID;

-- VALIDATE PRODUCTS STAGING LOAD

SELECT COUNT(*) AS TotalProducts
FROM staging.Products;

SELECT
    ProductID,
    ProductName,
    SupplierID,
    CategoryID,
    UnitPrice,
    UnitsInStock,
    Discontinued
FROM staging.Products
ORDER BY ProductID;

-- VALIDATE CUSTOMERS STAGING LOAD

SELECT COUNT(*) AS TotalCustomers
FROM staging.Customers;

SELECT
    CustomerID,
    CompanyName,
    ContactName,
    City,
    Country
FROM staging.Customers
ORDER BY CustomerID;

-- VALIDATE ORDERS STAGING LOAD

SELECT COUNT(*) AS TotalOrders
FROM staging.Orders;

SELECT TOP 10
    OrderID,
    CustomerID,
    EmployeeID,
    OrderDate,
    RequiredDate,
    ShippedDate,
    ShipVia,
    Freight
FROM staging.Orders
ORDER BY OrderID;

-- VALIDATE ORDER DETAILS STAGING LOAD

SELECT COUNT(*) AS TotalOrderDetails
FROM staging.OrderDetails;

SELECT TOP 10
    OrderID,
    ProductID,
    UnitPrice,
    Quantity,
    Discount
FROM staging.OrderDetails
ORDER BY OrderID, ProductID;

-- VALIDATE ALL STAGING TABLE ROW COUNTS
-- ==========================================

SELECT 'Shippers' AS TableName,
       COUNT(*) AS TotalRows
FROM staging.Shippers

UNION ALL

SELECT 'Categories', COUNT(*)
FROM staging.Categories

UNION ALL

SELECT 'Suppliers', COUNT(*)
FROM staging.Suppliers

UNION ALL

SELECT 'Products', COUNT(*)
FROM staging.Products

UNION ALL

SELECT 'Customers', COUNT(*)
FROM staging.Customers

UNION ALL

SELECT 'Orders', COUNT(*)
FROM staging.Orders

UNION ALL

SELECT 'OrderDetails', COUNT(*)
FROM staging.OrderDetails;



-- VALIDATE ALL STAGING TABLE ROW COUNTS

SELECT 'Shippers' AS TableName,
       COUNT(*) AS TotalRows
FROM staging.Shippers

UNION ALL

SELECT 'Categories', COUNT(*)
FROM staging.Categories

UNION ALL

SELECT 'Suppliers', COUNT(*)
FROM staging.Suppliers

UNION ALL

SELECT 'Products', COUNT(*)
FROM staging.Products

UNION ALL

SELECT 'Customers', COUNT(*)
FROM staging.Customers

UNION ALL

SELECT 'Orders', COUNT(*)
FROM staging.Orders

UNION ALL

SELECT 'OrderDetails', COUNT(*)
FROM staging.OrderDetails;

-- Check records before loading cleaned.Shippers

SELECT COUNT(*) AS TotalCleanedShippers
FROM cleaned.Shippers;

SELECT
    ShipperID,
    CompanyName,
    Phone
FROM cleaned.Shippers
ORDER BY ShipperID;

-- Validate cleaned Shippers load

SELECT COUNT(*) AS TotalCleanedShippers
FROM cleaned.Shippers;

SELECT
    ShipperID,
    CompanyName,
    Phone
FROM cleaned.Shippers
ORDER BY ShipperID;

-- Validate cleaned Shippers after UPSERT

SELECT COUNT(*) AS TotalCleanedShippers
FROM cleaned.Shippers;

SELECT
    ShipperID,
    CompanyName,
    Phone
FROM cleaned.Shippers
ORDER BY ShipperID;

-- Check staging and cleaned Categories

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalCategories
FROM staging.Categories

UNION ALL

SELECT
    'Cleaned' AS TableLayer,
    COUNT(*) AS TotalCategories
FROM cleaned.Categories;

-- Validate Categories staging and cleaned counts

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalCategories
FROM staging.Categories

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Categories;

-- View cleaned category records

SELECT
    CategoryID,
    CategoryName,
    Description
FROM cleaned.Categories
ORDER BY CategoryID;

-- Check staging and cleaned Suppliers

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalSuppliers
FROM staging.Suppliers

UNION ALL

SELECT
    'Cleaned' AS TableLayer,
    COUNT(*) AS TotalSuppliers
FROM cleaned.Suppliers;

-- VALIDATE CLEANED SUPPLIERS LOAD

-- Compare staging and cleaned row counts
SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalSuppliers
FROM staging.Suppliers

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Suppliers;

-- Check supplier details
SELECT
    SupplierID,
    CompanyName,
    ContactName,
    Country
FROM cleaned.Suppliers
ORDER BY SupplierID;

--Validate Product 36 in Products Table

SELECT
    ProductID,
    ProductName,
    QuantityPerUnit AS OriginalValue,
    REPLACE(
        QuantityPerUnit,
        '  ',
        ' '
    ) AS CleanedValue
FROM staging.Products
WHERE ProductID = 36;


-- Check Products before loading

SELECT
    'Staging Products' AS TableName,
    COUNT(*) AS TotalRows
FROM staging.Products

UNION ALL

SELECT
    'Cleaned Products',
    COUNT(*)
FROM cleaned.Products

UNION ALL

SELECT
    'Cleaned Suppliers',
    COUNT(*)
FROM cleaned.Suppliers

UNION ALL

SELECT
    'Cleaned Categories',
    COUNT(*)
FROM cleaned.Categories;


-- Check loaded Products
SELECT COUNT(*) AS TotalCleanedProducts
FROM cleaned.Products;

-- Verify correction for ProductID 36
SELECT
    s.ProductID,
    s.QuantityPerUnit AS OriginalValue,
    c.QuantityPerUnit AS CleanedValue
FROM staging.Products AS s
INNER JOIN cleaned.Products AS c
    ON s.ProductID = c.ProductID
WHERE s.ProductID = 36;


-- Confirm that no duplicate products were inserted

SELECT COUNT(*) AS TotalCleanedProducts
FROM cleaned.Products;

-- Check for duplicate ProductIDs

SELECT
    ProductID,
    COUNT(*) AS DuplicateCount
FROM cleaned.Products
GROUP BY ProductID
HAVING COUNT(*) > 1;


-- Preview CustomerName and Address cleaning

SELECT
    CustomerID,
    CompanyName AS OriginalCompanyName,
    REPLACE(CompanyName, '  ', ' ')
        AS CleanedCompanyName,
    Address AS OriginalAddress,
    REPLACE(Address, '  ', ' ')
        AS CleanedAddress
FROM staging.Customers
WHERE CustomerID IN
(
    'WOLZA',
    'ANTON',
    'BERGS',
    'CONSH'
)
ORDER BY CustomerID;


-- Check cleaned Customers table structure

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'cleaned'
  AND TABLE_NAME = 'Customers'
ORDER BY ORDINAL_POSITION;


USE NorthwindIntegration;
GO

EXEC cleaned.usp_UpsertCustomers;
GO


SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalCustomers
FROM staging.Customers

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Customers;


SELECT
    s.CustomerID,
    s.CompanyName AS OriginalCompanyName,
    c.CompanyName AS CleanedCompanyName,
    s.Address AS OriginalAddress,
    c.Address AS CleanedAddress
FROM staging.Customers AS s
INNER JOIN cleaned.Customers AS c
    ON s.CustomerID = c.CustomerID
WHERE s.CustomerID IN
(
    'WOLZA',
    'ANTON',
    'BERGS',
    'CONSH'
)
ORDER BY s.CustomerID;


SELECT
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END)
        AS MissingRegion,
    SUM(CASE WHEN Fax IS NULL THEN 1 ELSE 0 END)
        AS MissingFax,
    SUM(CASE WHEN PostalCode IS NULL THEN 1 ELSE 0 END)
        AS MissingPostalCode
FROM cleaned.Customers;


USE NorthwindIntegration;
GO

-- Compare staging and cleaned Customers

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalCustomers
FROM staging.Customers

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Customers;


-- Check staging and cleaned Orders

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalOrders
FROM staging.Orders

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Orders;


-- Check missing values in important Orders columns

SELECT
    SUM(CASE WHEN OrderID IS NULL THEN 1 ELSE 0 END)
        AS MissingOrderID,

    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END)
        AS MissingCustomerID,

    SUM(CASE WHEN ShippedDate IS NULL THEN 1 ELSE 0 END)
        AS MissingShippedDate,

    SUM(CASE WHEN ShipRegion IS NULL THEN 1 ELSE 0 END)
        AS MissingShipRegion,

    SUM(CASE WHEN ShipPostalCode IS NULL THEN 1 ELSE 0 END)
        AS MissingShipPostalCode
FROM staging.Orders;


-- Check whether Orders reference
-- customers that do not exist

SELECT COUNT(*) AS InvalidCustomerReferences
FROM staging.Orders AS o
LEFT JOIN cleaned.Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE o.CustomerID IS NOT NULL
  AND c.CustomerID IS NULL;


-- Check whether Orders reference
-- shippers that do not exist

SELECT COUNT(*) AS InvalidShipperReferences
FROM staging.Orders AS o
LEFT JOIN cleaned.Shippers AS s
    ON o.ShipVia = s.ShipperID
WHERE o.ShipVia IS NOT NULL
  AND s.ShipperID IS NULL;

  
-- Check the structure of cleaned.Orders

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'cleaned'
  AND TABLE_NAME = 'Orders'
ORDER BY ORDINAL_POSITION;


USE NorthwindIntegration;
GO

-- Execute the Orders UPSERT
EXEC cleaned.usp_UpsertOrders;
GO


-- Compare staging and cleaned Orders

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalOrders
FROM staging.Orders

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Orders;


-- Compare missing ShippedDate values

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS MissingShippedDates
FROM staging.Orders
WHERE ShippedDate IS NULL

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Orders
WHERE ShippedDate IS NULL;


USE NorthwindIntegration;
GO

-- Compare staging and cleaned Orders
SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalOrders
FROM staging.Orders

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Orders;


USE NorthwindIntegration;
GO

-- 1. Compare staging and cleaned counts
SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalRows
FROM staging.OrderDetails

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.OrderDetails;


-- 2. Check duplicate OrderID + ProductID pairs
SELECT
    OrderID,
    ProductID,
    COUNT(*) AS DuplicateCount
FROM staging.OrderDetails
GROUP BY OrderID, ProductID
HAVING COUNT(*) > 1;


-- 3. Check missing key values
SELECT
    SUM(CASE WHEN OrderID IS NULL THEN 1 ELSE 0 END)
        AS MissingOrderID,
    SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END)
        AS MissingProductID
FROM staging.OrderDetails;


USE NorthwindIntegration;
GO

-- ==========================================
-- VALIDATE ORDERDETAILS FOREIGN KEYS
-- ==========================================

-- Check OrderIDs without a matching order
SELECT COUNT(*) AS InvalidOrderReferences
FROM staging.OrderDetails AS od
LEFT JOIN cleaned.Orders AS o
    ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;


-- Check ProductIDs without a matching product
SELECT COUNT(*) AS InvalidProductReferences
FROM staging.OrderDetails AS od
LEFT JOIN cleaned.Products AS p
    ON od.ProductID = p.ProductID
WHERE p.ProductID IS NULL;


USE NorthwindIntegration;
GO

-- Compare staging and cleaned OrderDetails
SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalRows
FROM staging.OrderDetails

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.OrderDetails;


USE NorthwindIntegration;
GO

-- Final row-count validation
-- Compare all 7 staging and cleaned tables

SELECT
    'Shippers' AS TableName,
    (SELECT COUNT(*) FROM staging.Shippers) AS StagingRows,
    (SELECT COUNT(*) FROM cleaned.Shippers) AS CleanedRows

UNION ALL

SELECT
    'Categories',
    (SELECT COUNT(*) FROM staging.Categories),
    (SELECT COUNT(*) FROM cleaned.Categories)

UNION ALL

SELECT
    'Suppliers',
    (SELECT COUNT(*) FROM staging.Suppliers),
    (SELECT COUNT(*) FROM cleaned.Suppliers)

UNION ALL

SELECT
    'Products',
    (SELECT COUNT(*) FROM staging.Products),
    (SELECT COUNT(*) FROM cleaned.Products)

UNION ALL

SELECT
    'Customers',
    (SELECT COUNT(*) FROM staging.Customers),
    (SELECT COUNT(*) FROM cleaned.Customers)

UNION ALL

SELECT
    'Orders',
    (SELECT COUNT(*) FROM staging.Orders),
    (SELECT COUNT(*) FROM cleaned.Orders)

UNION ALL

SELECT
    'OrderDetails',
    (SELECT COUNT(*) FROM staging.OrderDetails),
    (SELECT COUNT(*) FROM cleaned.OrderDetails);


USE NorthwindIntegration;
GO

-- Verify all 7 cleaned tables after
-- executing the Master SSIS Package

SELECT 'Shippers' AS TableName,
       COUNT(*) AS TotalRows
FROM cleaned.Shippers

UNION ALL
SELECT 'Categories', COUNT(*)
FROM cleaned.Categories

UNION ALL
SELECT 'Suppliers', COUNT(*)
FROM cleaned.Suppliers

UNION ALL
SELECT 'Products', COUNT(*)
FROM cleaned.Products

UNION ALL
SELECT 'Customers', COUNT(*)
FROM cleaned.Customers

UNION ALL
SELECT 'Orders', COUNT(*)
FROM cleaned.Orders

UNION ALL
SELECT 'OrderDetails', COUNT(*)
FROM cleaned.OrderDetails;


USE NorthwindIntegration;
GO

-- ==========================================
-- PRODUCTS VALIDATION
-- Required Fields
-- ==========================================

SELECT
    COUNT(*) AS TotalProducts,

    SUM(CASE WHEN ProductID IS NULL
        THEN 1 ELSE 0 END) AS MissingProductID,

    SUM(CASE WHEN ProductName IS NULL
        THEN 1 ELSE 0 END) AS MissingProductName,

    SUM(CASE WHEN Discontinued IS NULL
        THEN 1 ELSE 0 END) AS MissingDiscontinued

FROM staging.Products;

USE NorthwindIntegration;
GO

-- ==========================================
-- PRODUCTS VALIDATION
-- Duplicate Primary Keys
-- ==========================================

SELECT
    ProductID,
    COUNT(*) AS DuplicateCount
FROM staging.Products
GROUP BY ProductID
HAVING COUNT(*) > 1;


USE NorthwindIntegration;
GO

-- ==========================================
-- PRODUCTS VALIDATION
-- Foreign-Key References
-- ==========================================

-- Check invalid SupplierID references
SELECT
    COUNT(*) AS InvalidSupplierReferences
FROM staging.Products AS p
LEFT JOIN cleaned.Suppliers AS s
    ON p.SupplierID = s.SupplierID
WHERE p.SupplierID IS NOT NULL
  AND s.SupplierID IS NULL;


-- Check invalid CategoryID references
SELECT
    COUNT(*) AS InvalidCategoryReferences
FROM staging.Products AS p
LEFT JOIN cleaned.Categories AS c
    ON p.CategoryID = c.CategoryID
WHERE p.CategoryID IS NOT NULL
  AND c.CategoryID IS NULL;

  
USE NorthwindIntegration;
GO

-- ==========================================
-- PRODUCTS VALIDATION
-- Whitespace Transformation
-- ==========================================

SELECT
    s.ProductID,
    s.QuantityPerUnit AS OriginalValue,
    c.QuantityPerUnit AS CleanedValue
FROM staging.Products AS s
INNER JOIN cleaned.Products AS c
    ON s.ProductID = c.ProductID
WHERE s.ProductID = 36;

-- Check remaining double spaces
-- in cleaned QuantityPerUnit

SELECT
    ProductID,
    QuantityPerUnit
FROM cleaned.Products
WHERE QuantityPerUnit LIKE '%  %';
