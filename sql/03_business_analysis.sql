-- ==========================================
-- BUSINESS ANALYSIS
-- ==========================================

USE Northwind;
GO

----------------------------------------------
-- Products Business Analysis
----------------------------------------------

-- Classify active products based on inventory status

SELECT
    ProductID,
    ProductName,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,

    CASE
        WHEN UnitsInStock IS NULL
          OR UnitsOnOrder IS NULL
          OR ReorderLevel IS NULL
          OR UnitsInStock < 0
          OR UnitsOnOrder < 0
          OR ReorderLevel < 0
            THEN 'Data Quality Issue'

        WHEN UnitsInStock <= ReorderLevel
             AND UnitsOnOrder = 0
            THEN 'Critical'

        WHEN UnitsInStock <= ReorderLevel
             AND UnitsOnOrder > 0
            THEN 'Reorder Pending'

        WHEN UnitsInStock > ReorderLevel
            THEN 'Healthy'

        ELSE 'Needs Review'
    END AS InventoryStatus

FROM dbo.Products
WHERE Discontinued = 0
ORDER BY ProductID;

-- How many products are in each inventory category?

WITH InventoryStatus AS
(
    SELECT
        ProductID,
        ProductName,

        CASE
            WHEN UnitsInStock <= ReorderLevel
                 AND UnitsOnOrder = 0
                THEN 'Critical'

            WHEN UnitsInStock <= ReorderLevel
                 AND UnitsOnOrder > 0
                THEN 'Reorder Pending'

            WHEN UnitsInStock > ReorderLevel
                THEN 'Healthy'

            ELSE 'Needs Review'
        END AS StockStatus

    FROM dbo.Products
    WHERE Discontinued = 0
)

-- Count products in each classification
SELECT
    StockStatus,
    COUNT(*) AS ProductCount
FROM InventoryStatus
GROUP BY StockStatus
ORDER BY StockStatus;

/*
Inventory Status Distribution

Critical: 1
Reorder Pending: 17
Healthy: 51

17 already have incoming stock orders.
1 has no incoming stock order.

Action:
Identify the critical product and
review its supplier information.
*/

-- Find active products with zero stock
-- and check whether replenishment is pending

SELECT
    ProductID,
    ProductName,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    Discontinued
FROM dbo.Products
WHERE UnitsInStock = 0
  AND Discontinued = 0
ORDER BY ProductID

/*
ProductID: 31
Product: Gorgonzola Telino

UnitsInStock: 0
UnitsOnOrder: 70
ReorderLevel: 20
*/

-- Identify critical products
-- with no incoming replenishment

SELECT
    ProductID,
    ProductName,
    SupplierID,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel
FROM dbo.Products
WHERE Discontinued = 0
  AND UnitsInStock <= ReorderLevel
  AND UnitsOnOrder = 0;

/*
ProductID: 30
Product: Nord-Ost Matjeshering
SupplierID: 13

UnitsInStock: 10
UnitsOnOrder: 0
ReorderLevel: 15

Stock is 5 units below the reorder level,
and no replenishment is currently recorded.

Suggested Action:
Flag the product for purchasing review.
*/

-- Identify products below reorder level
-- that already have incoming stock orders

SELECT
    ProductID,
    ProductName,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    ReorderLevel - UnitsInStock AS StockShortfall
FROM dbo.Products
WHERE Discontinued = 0
  AND UnitsInStock < ReorderLevel
  AND UnitsOnOrder > 0
ORDER BY StockShortfall DESC;
--The largest StockShortFall is for ProductID 31

----------------------------------------------
-- Suppliers Business Analysis
----------------------------------------------

-- Number of products per supplier

SELECT
    s.SupplierID,
    s.CompanyName,
    COUNT(p.ProductID) AS TotalProducts
FROM dbo.Suppliers AS s
LEFT JOIN dbo.Products AS p
    ON s.SupplierID = p.SupplierID
GROUP BY
    s.SupplierID,
    s.CompanyName
ORDER BY TotalProducts DESC;

-- Active and discontinued products per supplier

SELECT
    s.SupplierID,
    s.CompanyName,
    COUNT(p.Discontinued) AS TotalProducts,

    SUM(CASE WHEN p.Discontinued = 0 THEN 1
        ELSE 0
    END) AS ActiveProducts,

    SUM(CASE WHEN p.Discontinued = 1 THEN 1
        ELSE 0
    END) AS DiscontinuedProducts

FROM dbo.Suppliers AS s
LEFT JOIN dbo.Products AS p
    ON s.SupplierID = p.SupplierID

GROUP BY
    s.SupplierID,
    s.CompanyName

ORDER BY ActiveProducts DESC;

-- Inventory replenishment status by supplier

SELECT
    s.SupplierID,
    s.CompanyName,

    SUM(CASE WHEN p.UnitsInStock <= p.ReorderLevel
         AND p.UnitsOnOrder = 0
        THEN 1 ELSE 0
    END) AS CriticalProducts,

    SUM(CASE WHEN p.UnitsInStock <= p.ReorderLevel
         AND p.UnitsOnOrder > 0
        THEN 1 ELSE 0
    END) AS ReorderPendingProducts

FROM dbo.Suppliers AS s
JOIN dbo.Products AS p
    ON s.SupplierID = p.SupplierID

WHERE p.Discontinued = 0
GROUP BY
    s.SupplierID, s.CompanyName
ORDER BY
    CriticalProducts DESC,
    ReorderPendingProducts DESC;

-- Total active inventory value by supplier

SELECT
    s.SupplierID,
    s.CompanyName,
    COALESCE(SUM(p.UnitPrice * p.UnitsInStock), 0) AS TotalInventoryValue
FROM dbo.Suppliers AS s
LEFT JOIN dbo.Products AS p
    ON s.SupplierID = p.SupplierID
    AND p.Discontinued = 0
GROUP BY
    s.SupplierID,
    s.CompanyName
ORDER BY TotalInventoryValue DESC;


USE Northwind;
GO

-- Suppliers with out-of-stock active products

SELECT
    s.SupplierID,
    s.CompanyName,
    p.ProductID,
    p.ProductName,
    p.UnitsInStock,
    p.UnitsOnOrder,
    p.ReorderLevel
FROM dbo.Suppliers AS s
JOIN dbo.Products AS p
    ON s.SupplierID = p.SupplierID
WHERE p.Discontinued = 0
  AND p.UnitsInStock = 0
ORDER BY s.CompanyName;
 -- SupplierID 14 has out of stock Products

 ----------------------------------------------
-- Categories Business Analysis
-----------------------------------------------

-- Number of products per category

SELECT
    c.CategoryID,
    c.CategoryName,
    COUNT(p.ProductID) AS TotalProducts
FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
GROUP BY
    c.CategoryID,
    c.CategoryName
ORDER BY TotalProducts DESC;

-- Active vs discontinued products by category

SELECT
    c.CategoryID,
    c.CategoryName,

    SUM(CASE
        WHEN p.Discontinued = 0 THEN 1
        ELSE 0
    END) AS ActiveProducts,

    SUM(CASE
        WHEN p.Discontinued = 1 THEN 1
        ELSE 0
    END) AS DiscontinuedProducts

FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
GROUP BY
    c.CategoryID,
    c.CategoryName
ORDER BY ActiveProducts DESC;

-- Inventory status by category

SELECT
    c.CategoryID,
    c.CategoryName,

    SUM(CASE WHEN p.UnitsInStock <= p.ReorderLevel
         AND p.UnitsOnOrder = 0
        THEN 1 ELSE 0
    END) AS CriticalProducts,

    SUM(CASE WHEN p.UnitsInStock <= p.ReorderLevel
         AND p.UnitsOnOrder > 0
        THEN 1 ELSE 0
    END) AS ReorderPendingProducts,

    SUM(CASE WHEN p.UnitsInStock > p.ReorderLevel
        THEN 1 ELSE 0
    END) AS HealthyProducts
FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
    AND p.Discontinued = 0
GROUP BY
    c.CategoryID,
    c.CategoryName
ORDER BY
    CriticalProducts DESC,
    ReorderPendingProducts DESC;

-- Estimated inventory value by category

SELECT
    c.CategoryID,
    c.CategoryName,
    COALESCE(
        SUM(p.UnitPrice * p.UnitsInStock), 0
    ) AS TotalInventoryValue

FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
    AND p.Discontinued = 0

GROUP BY
    c.CategoryID,
    c.CategoryName

ORDER BY TotalInventoryValue DESC;

-- Estimated inventory value by category

SELECT
    c.CategoryID,
    c.CategoryName,
    COALESCE(SUM(p.UnitPrice * p.UnitsInStock), 0) AS TotalInventoryValue
FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
    AND p.Discontinued = 0
GROUP BY
    c.CategoryID,c.CategoryName
ORDER BY TotalInventoryValue DESC;

-- Out-of-stock products by category

SELECT
    c.CategoryID,
    c.CategoryName,
    p.ProductID,
    p.ProductName,
    p.UnitsInStock,
    p.UnitsOnOrder,
    p.ReorderLevel
FROM dbo.Categories AS c
JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
WHERE p.Discontinued = 0
  AND p.UnitsInStock = 0
ORDER BY c.CategoryName;

-- How many active products are in each category?
-- How many active products are currently in stock?
-- What is the total stock quantity per category?
-- What is the average unit price per category?

SELECT
    c.CategoryID,
    c.CategoryName,
    COUNT(p.ProductID) AS ActiveProducts,

    SUM(CASE WHEN p.UnitsInStock > 0 THEN 1
        ELSE 0
    END) AS ProductsInStock,

    SUM(p.UnitsInStock) AS TotalStockQuantity,

    ROUND(AVG(p.UnitPrice), 2) AS AverageUnitPrice

FROM dbo.Products AS p
INNER JOIN dbo.Categories AS c
    ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0
GROUP BY
    c.CategoryID, c.CategoryName
ORDER BY TotalStockQuantity DESC;

-- Which categories have the fewest distinct suppliers providing active products?

SELECT
    c.CategoryID,
    c.CategoryName,
    COUNT(DISTINCT p.SupplierID) AS TotalSuppliers
FROM dbo.Products AS p
INNER JOIN dbo.Categories AS c
    ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0
GROUP BY
    c.CategoryID, c.CategoryName
ORDER BY TotalSuppliers ASC;

 ----------------------------------------------
-- Customers Business Analysis
-----------------------------------------------

-- Which customers have placed the most orders?

SELECT
    cu.CustomerID,
    cu.CompanyName,
    COUNT(o.OrderID) AS TotalOrders
FROM dbo.Customers AS cu
LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
GROUP BY cu.CustomerID,cu.CompanyName
ORDER BY TotalOrders DESC;

-- Which customers have generated the highest total sales revenue?

SELECT
    cu.CustomerID,
    cu.CompanyName,
    CAST(COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) AS DECIMAL(18,2)
        ) AS TotalRevenue
FROM dbo.Customers AS cu

LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
LEFT JOIN dbo.[Order Details] AS od
    ON o.OrderID = od.OrderID
GROUP BY cu.CustomerID, cu.CompanyName
ORDER BY TotalRevenue DESC;

-- Which customers have never placed an order?

SELECT
    cu.CustomerID,
    cu.CompanyName,
    cu.Country,
    COUNT(o.OrderID) AS TotalOrders
FROM dbo.Customers AS cu
LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
GROUP BY
    cu.CustomerID,
    cu.CompanyName,
    cu.Country
HAVING COUNT(o.OrderID) = 0
ORDER BY cu.CompanyName;

-- Which countries have the highest number of customers?

SELECT
    cu.Country,
    COUNT(cu.CustomerID) AS TotalCustomers
FROM dbo.Customers AS cu
GROUP BY cu.Country
ORDER BY TotalCustomers DESC;

-- Which customer countries generate the highest total sales revenue?

SELECT
    cu.Country,
    CAST(COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) AS DECIMAL(18,2)
        ) AS TotalRevenue
FROM dbo.Customers AS cu
LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
LEFT JOIN dbo.[Order Details] AS od
    ON o.OrderID = od.OrderID
GROUP BY cu.Country
ORDER BY TotalRevenue DESC;

-- What is the average order value for each customer?

SELECT
    cu.CustomerID,
    cu.CompanyName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,

    CAST(
        COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) AS DECIMAL(18,2)
                ) AS TotalRevenue,

      CAST(
        COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))/ NULLIF(COUNT(DISTINCT o.OrderID), 0),0) AS DECIMAL(18,2)
                ) AS AverageOrderValue

FROM dbo.Customers AS cu
LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
LEFT JOIN dbo.[Order Details] AS od
    ON o.OrderID = od.OrderID
GROUP BY cu.CustomerID, cu.CompanyName
ORDER BY AverageOrderValue DESC;

-- Number of customers with multiple orders

SELECT COUNT(*) AS CustomersWithMultipleOrders
FROM
(
    SELECT cu.CustomerID
    FROM dbo.Customers AS cu
    JOIN dbo.Orders AS o
        ON cu.CustomerID = o.CustomerID
    GROUP BY cu.CustomerID
    HAVING COUNT(o.OrderID) > 1
) AS MultipleOrders;

-- When did each customer last place an order?

SELECT
    cu.CustomerID,
    cu.CompanyName,
    MAX(o.OrderDate) AS LastOrderDate
FROM dbo.Customers AS cu
LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
GROUP BY cu.CustomerID, cu.CompanyName
ORDER BY LastOrderDate DESC;

-- Which customer countries have placed the highest number of orders?

SELECT
    cu.Country,
    COUNT(o.OrderID) AS TotalOrders
FROM dbo.Customers AS cu
LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
GROUP BY cu.Country
ORDER BY TotalOrders DESC;

-- Which customers have purchased the greatest total quantity of products?

SELECT
    cu.CustomerID,
    cu.CompanyName,
    COALESCE(SUM(od.Quantity), 0) AS TotalQuantityPurchased
FROM dbo.Customers AS cu
LEFT JOIN dbo.Orders AS o
    ON cu.CustomerID = o.CustomerID
LEFT JOIN dbo.[Order Details] AS od
    ON o.OrderID = od.OrderID
GROUP BY cu.CustomerID, cu.CompanyName
ORDER BY TotalQuantityPurchased DESC;

 ----------------------------------------------
-- Orders Business Analysis
-----------------------------------------------

-- Monthly Order Trend
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    COUNT(OrderID) AS TotalOrders
FROM dbo.Orders
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY
    OrderYear,
    OrderMonth;

-- Orders by Shipping Country
SELECT
    ShipCountry,
    COUNT(OrderID) AS TotalOrders
FROM dbo.Orders
GROUP BY ShipCountry
ORDER BY TotalOrders DESC;

-- Orders by Shipping Company

SELECT
    s.ShipperID,
    s.CompanyName,
    COUNT(o.OrderID) AS TotalOrders
FROM dbo.Shippers AS s
LEFT JOIN dbo.Orders AS o
    ON s.ShipperID = o.ShipVia
GROUP BY
    s.ShipperID,
    s.CompanyName
ORDER BY TotalOrders DESC;

-- Freight Costs by Shipping Company

SELECT
    s.ShipperID,
    s.CompanyName,
    COUNT(o.OrderID) AS TotalOrders,
    CAST(SUM(o.Freight) AS DECIMAL(18,2)) AS TotalFreight,
    CAST(AVG(o.Freight) AS DECIMAL(18,2)) AS AverageFreight
FROM dbo.Shippers AS s
LEFT JOIN dbo.Orders AS o
    ON s.ShipperID = o.ShipVia
GROUP BY
    s.ShipperID,
    s.CompanyName
ORDER BY TotalFreight DESC;

-- Average Order to Shipment Time

SELECT
    COUNT(OrderID) AS ShippedOrders,
    CAST(
        AVG(
            CAST(DATEDIFF(DAY, OrderDate, ShippedDate) AS DECIMAL(10,2))
        ) AS DECIMAL(10,2)
    ) AS AverageDaysToShip
FROM dbo.Orders
WHERE ShippedDate IS NOT NULL;

-- Orders Shipped After Required Date

SELECT
    COUNT(OrderID) AS ShippedAfterRequiredDate
FROM dbo.Orders
WHERE ShippedDate > RequiredDate AND ShippedDate IS NOT NULL;

-- TOP 10 Orders by Freight

SELECT TOP (10)
    OrderID,
    CustomerID,
    OrderDate,
    ShipCountry,
    Freight
FROM dbo.Orders
ORDER BY Freight DESC;

-- Average Shipping Time by Shipper

SELECT
    s.ShipperID,
    s.CompanyName,
    COUNT(o.OrderID) AS ShippedOrders,
    CAST(
    AVG(
        CAST(DATEDIFF(DAY, o.OrderDate, o.ShippedDate) AS DECIMAL(10,2))
    ) AS DECIMAL(10,2)) AS AverageDaysToShip

FROM dbo.Shippers AS s
JOIN dbo.Orders AS o
    ON s.ShipperID = o.ShipVia
WHERE o.ShippedDate IS NOT NULL
GROUP BY
    s.ShipperID,
    s.CompanyName
ORDER BY AverageDaysToShip DESC;

--Freight Charges by Shipping Company

SELECT
    ShipCountry,
    COUNT(OrderID) AS TotalOrders,
    CAST(SUM(Freight) AS DECIMAL(18,2)) AS TotalFreight,
    CAST(AVG(Freight) AS DECIMAL(18,2)) AS AverageFreight
FROM dbo.Orders
GROUP BY ShipCountry
ORDER BY TotalFreight DESC;

-- Monthly Freight Cost Trend

SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    COUNT(OrderID) AS TotalOrders,
    CAST(SUM(Freight) AS DECIMAL(18,2)) AS TotalFreight
FROM dbo.Orders
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY
    OrderYear,
    OrderMonth;

 ----------------------------------------------
-- Order Details Business Analysis
-----------------------------------------------

-- Overall Sales Performance

SELECT
    COUNT(*) AS TotalOrderLines,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(Quantity) AS TotalQuantitySold,
    CAST(SUM(UnitPrice * Quantity * (1 - Discount)) AS DECIMAL(18,2)
        ) AS TotalRevenue
FROM dbo.[Order Details];

-- TOP 10 Products by Sales Revenue

SELECT TOP (10)
    p.ProductID,
    p.ProductName,
    CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DECIMAL(18,2)
        ) AS TotalRevenue
FROM dbo.Products AS p
JOIN dbo.[Order Details] AS od
    ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY TotalRevenue DESC;

-- TOP 10 Products by Quantuty Sold

SELECT TOP (10)
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantitySold
FROM dbo.Products AS p
JOIN dbo.[Order Details] AS od
    ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY TotalQuantitySold DESC;

-- Sales revenue by Product Category

SELECT
    ca.CategoryID,
    ca.CategoryName,
    CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DECIMAL(18,2)
        ) AS TotalRevenue
FROM dbo.Categories AS ca
JOIN dbo.Products AS p
    ON ca.CategoryID = p.CategoryID
JOIN dbo.[Order Details] AS od
    ON p.ProductID = od.ProductID
GROUP BY
    ca.CategoryID,
    ca.CategoryName
ORDER BY TotalRevenue DESC;

-- Sales and Discount Analysis

SELECT
    CAST(SUM(UnitPrice * Quantity) AS DECIMAL(18,2)
        ) AS GrossSales,

    CAST(SUM(UnitPrice * Quantity * Discount) AS DECIMAL(18,2)
        ) AS TotalDiscount,

    CAST(SUM(UnitPrice * Quantity * (1 - Discount)) AS DECIMAL(18,2)
        ) AS NetSales
FROM dbo.[Order Details];


-- Discount Analysis

SELECT
    COUNT(*) AS TotalOrderLines,
    SUM(CASE WHEN Discount > 0 THEN 1 ELSE 0 END) AS DiscountedOrderLines,
    CAST(AVG(Discount) * 100 AS DECIMAL(10,2)) AS AverageDiscountPercent
FROM dbo.[Order Details];

-- TOP 10 Products by Discount Amount

SELECT TOP (10)
    p.ProductID,
    p.ProductName,
    CAST(SUM(od.UnitPrice * od.Quantity * od.Discount)AS DECIMAL(18,2)
        ) AS TotalDiscountAmount
FROM dbo.Products AS p
JOIN dbo.[Order Details] AS od
    ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY TotalDiscountAmount DESC;

-- TOP 10 Orders by Sales Revenue

SELECT TOP (10)
    o.OrderID,
    o.CustomerID,
    CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DECIMAL(18,2)
        ) AS TotalRevenue
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od
    ON o.OrderID = od.OrderID
GROUP BY
    o.OrderID,
    o.CustomerID
ORDER BY TotalRevenue DESC;

-- Monthly Sales Revenue Trend

SELECT
    YEAR(o.OrderDate) AS OrderYear,
    MONTH(o.OrderDate) AS OrderMonth,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,

    CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DECIMAL(18,2)
        ) AS TotalRevenue
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od
    ON o.OrderID = od.OrderID
GROUP BY
    YEAR(o.OrderDate),
    MONTH(o.OrderDate)
ORDER BY
    OrderYear,
    OrderMonth;

-- What are the average number of product lines and total units per order?

SELECT
    COUNT(DISTINCT OrderID) AS TotalOrders,
    CAST(CAST(COUNT(*) AS DECIMAL(18,2)) / COUNT(DISTINCT OrderID) AS DECIMAL(10,2)
         ) AS AverageProductLinesPerOrder,

    CAST(CAST(SUM(Quantity) AS DECIMAL(18,2))/ COUNT(DISTINCT OrderID) AS DECIMAL(10,2)
    ) AS AverageUnitsPerOrder
FROM dbo.[Order Details];