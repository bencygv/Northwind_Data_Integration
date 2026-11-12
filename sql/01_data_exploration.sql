-- ==========================================
-- DATA EXPLORATION
-- ==========================================

---------------------------------------------
-- Products Table Exploration
---------------------------------------------

-- Check total number of products
SELECT COUNT(*) AS TotalProducts
FROM dbo.Products;

-- Examine sample product records
SELECT TOP (10) *
FROM dbo.Products
ORDER BY ProductID;

-- Check all distinct values in Discontinued
SELECT DISTINCT
    Discontinued
FROM dbo.Products
ORDER BY Discontinued;

-- Count products by discontinued status
SELECT
    Discontinued,
    COUNT(*) AS ProductCount
FROM dbo.Products
GROUP BY Discontinued
ORDER BY Discontinued;

-- Explore the range of product prices and stock quantities
SELECT
    MIN(UnitPrice) AS MinimumPrice,
    MAX(UnitPrice) AS MaximumPrice,
    AVG(UnitPrice) AS AveragePrice,

    MIN(UnitsInStock) AS MinimumStock,
    MAX(UnitsInStock) AS MaximumStock,

    MIN(UnitsOnOrder) AS MinimumOnOrder,
    MAX(UnitsOnOrder) AS MaximumOnOrder,

    MIN(ReorderLevel) AS MinimumReorderLevel,
    MAX(ReorderLevel) AS MaximumReorderLevel

FROM dbo.Products;

-- Identify products with a zero reorder level
SELECT
    ProductID,
    ProductName,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    Discontinued
FROM dbo.Products
WHERE ReorderLevel = 0
ORDER BY ProductID;
/*
Total products: 77
Products with ReorderLevel = 0: 24
*/

---------------------------------------------
-- Suppliers Table Exploration
---------------------------------------------

-- Count total suppliers
SELECT
    COUNT(*) AS TotalSuppliers
FROM dbo.Suppliers;

-- Examine sample supplier records
SELECT TOP (10) *
FROM dbo.Suppliers
ORDER BY SupplierID;

---------------------------------------------
-- Categories Table Exploration
---------------------------------------------

-- Total number of categories
SELECT COUNT(*) AS TotalCategories
FROM dbo.Categories;

-- Examine category records
SELECT *
FROM dbo.Categories
ORDER BY CategoryID;

---------------------------------------------
-- Customers Table Exploration
---------------------------------------------

-- Count total customers
SELECT COUNT(*) AS TotalCustomers
FROM dbo.Customers;

-- Examine customer records
SELECT TOP (10) *
FROM dbo.Customers
ORDER BY CustomerID;

---------------------------------------------
-- Orders Table Exploration
---------------------------------------------

-- Count total orders
SELECT COUNT(*) AS TotalOrders
FROM dbo.Orders;

-- Examine sample order records
SELECT TOP (10) *
FROM dbo.Orders
ORDER BY OrderID;

---------------------------------------------
-- Orders Details Table Exploration
---------------------------------------------

-- Count total order detail records
SELECT COUNT(*) AS TotalOrderDetails
FROM dbo.[Order Details];

-- Examine sample records
SELECT TOP (10) *
FROM dbo.[Order Details];

---------------------------------------------
-- Shippers Table Exploration
---------------------------------------------

-- Count total shippers
SELECT COUNT(*) AS TotalShippers
FROM dbo.Shippers;

-- Examine all shipper records

SELECT *          
FROM dbo.Shippers
ORDER BY ShipperID;
