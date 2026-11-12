USE Northwind;
GO

-- ==========================================
-- DATA QUALITY CHECKS
-- ==========================================
---------------------------------------------
-- Products Table
---------------------------------------------

-- Check missing values in important product columns

SELECT
    COUNT(*) AS TotalProducts,

    SUM(CASE WHEN ProductID IS NULL
        THEN 1 ELSE 0 END) AS MissingProductID,

    SUM(CASE WHEN ProductName IS NULL OR TRIM(ProductName) = ''
        THEN 1 ELSE 0 END) AS MissingProductName,

    SUM(CASE WHEN SupplierID IS NULL
        THEN 1 ELSE 0 END) AS MissingSupplierID,

    SUM(CASE WHEN CategoryID IS NULL
        THEN 1 ELSE 0 END) AS MissingCategoryID,

    SUM(CASE WHEN QuantityPerUnit IS NULL OR TRIM(QuantityPerUnit) = ''
        THEN 1 ELSE 0 END) AS MissingQuantityPerUnit,

    SUM(CASE WHEN UnitPrice IS NULL
        THEN 1 ELSE 0 END) AS MissingUnitPrice,

    SUM(CASE WHEN UnitsInStock IS NULL
        THEN 1 ELSE 0 END) AS MissingUnitsInStock,

    SUM(CASE WHEN UnitsOnOrder IS NULL
        THEN 1 ELSE 0 END) AS MissingUnitsOnOrder,

    SUM(CASE WHEN ReorderLevel IS NULL
        THEN 1 ELSE 0 END) AS MissingReorderLevel,

    SUM(CASE WHEN Discontinued IS NULL
        THEN 1 ELSE 0 END) AS MissingDiscontinued
FROM dbo.Products;

-- Identify duplicate ProductIDs
SELECT
    ProductID,
    COUNT(*) AS DuplicateCount
FROM dbo.Products
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Check for invalid negative numeric values
-- in the Products table
SELECT
    ProductID,
    ProductName,
    UnitPrice,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel
FROM dbo.Products
WHERE UnitPrice < 0
   OR UnitsInStock < 0
   OR UnitsOnOrder < 0
   OR ReorderLevel < 0;

-- Check if products referencing to a supplier actually exists
SELECT
    p.ProductID,
    p.ProductName,
    p.SupplierID
FROM dbo.Products AS p
LEFT JOIN dbo.Suppliers AS s
    ON p.SupplierID = s.SupplierID
WHERE p.SupplierID IS NOT NULL
  AND s.SupplierID IS NULL;

--  Check if products referencing to a category actually exists
SELECT
    p.ProductID,
    p.ProductName,
    p.CategoryID
FROM dbo.Products AS p
LEFT JOIN dbo.Categories AS c
    ON p.CategoryID = c.CategoryID
WHERE p.CategoryID IS NOT NULL
  AND c.CategoryID IS NULL;

-- Check whitespace issues in Products
SELECT
    SUM(CASE
        WHEN DATALENGTH(ProductName) <>
             DATALENGTH(TRIM(ProductName))
        THEN 1 ELSE 0
    END) AS ProductName_OuterSpaces,

    SUM(CASE
        WHEN ProductName LIKE N'%  %'
        THEN 1 ELSE 0
    END) AS ProductName_DoubleSpaces,

    SUM(CASE
        WHEN DATALENGTH(QuantityPerUnit) <>
             DATALENGTH(TRIM(QuantityPerUnit))
        THEN 1 ELSE 0
    END) AS QuantityPerUnit_OuterSpaces,

    SUM(CASE
        WHEN QuantityPerUnit LIKE N'%  %'
        THEN 1 ELSE 0
    END) AS QuantityPerUnit_DoubleSpaces
FROM dbo.Products;
-- 1 QuantityPerUnit there is double space

-- Identify products containing double spaces in QuantityPerUnit
SELECT
    ProductID,
    ProductName,
    QuantityPerUnit
FROM dbo.Products
WHERE QuantityPerUnit LIKE N'%  %';

/*
Table: dbo.Products
Column: QuantityPerUnit
ProductID: 36

Original value: 24 - 250 g  jars
Proposed value: 24 - 250 g jars

Issue: Double internal whitespace
Action: Standardize during SSIS cleansing
*/

-- Identify blank or whitespace-only text values
SELECT
    ProductID,
    ProductName,
    QuantityPerUnit
FROM dbo.Products
WHERE TRIM(ProductName) = N''
   OR TRIM(QuantityPerUnit) = N'';

---------------------------------------------
-- Suppliers Table
---------------------------------------------

-- Check missing values
SELECT
    COUNT(*) AS TotalSuppliers,

    SUM(CASE WHEN SupplierID IS NULL
        THEN 1 ELSE 0 END) AS MissingSupplierID,

    SUM(CASE WHEN CompanyName IS NULL OR TRIM(CompanyName) = ''
        THEN 1 ELSE 0 END) AS MissingCompanyName,

    SUM(CASE WHEN ContactName IS NULL OR TRIM(ContactName) = ''
        THEN 1 ELSE 0 END) AS MissingContactName,

    SUM(CASE WHEN ContactTitle IS NULL OR TRIM(ContactTitle) = ''
        THEN 1 ELSE 0 END) AS MissingContactTitle,

    SUM(CASE WHEN Address IS NULL OR TRIM(Address) = ''
        THEN 1 ELSE 0 END) AS MissingAddress,

    SUM(CASE WHEN City IS NULL OR TRIM(City) = ''
        THEN 1 ELSE 0 END) AS MissingCity,

    SUM(CASE WHEN Region IS NULL OR TRIM(Region) = ''
        THEN 1 ELSE 0 END) AS MissingRegion,

    SUM(CASE WHEN PostalCode IS NULL OR TRIM(PostalCode) = ''
        THEN 1 ELSE 0 END) AS MissingPostalCode,

    SUM(CASE WHEN Country IS NULL OR TRIM(Country) = ''
        THEN 1 ELSE 0 END) AS MissingCountry,

    SUM(CASE WHEN Phone IS NULL OR TRIM(Phone) = ''
        THEN 1 ELSE 0 END) AS MissingPhone,

    SUM(CASE WHEN Fax IS NULL OR TRIM(Fax) = ''
        THEN 1 ELSE 0 END) AS MissingFax,

    SUM(CASE WHEN HomePage IS NULL OR TRIM(CAST(HomePage AS NVARCHAR(MAX))) = N''
        THEN 1 ELSE 0 END) AS MissingHomePage
FROM dbo.Suppliers;
/*
20 MissingRegion - verify
16 MissingFax - optional 
24 MissingHomePage - optional 
*/

-- Check duplicate supplier identifiers
SELECT
    SupplierID,
    COUNT(*) AS DuplicateCount
FROM dbo.Suppliers
GROUP BY SupplierID
HAVING COUNT(*) > 1;

-- Identify duplicate supplier names

SELECT
    UPPER(TRIM(CompanyName)) AS StandardizedCompanyName,
    COUNT(*) AS DuplicateCount
FROM dbo.Suppliers
GROUP BY UPPER(TRIM(CompanyName))
HAVING COUNT(*) > 1;

 -- Check extra spaces in supplier text columns

SELECT
    SUM(CASE WHEN DATALENGTH(CompanyName) <>
                  DATALENGTH(TRIM(CompanyName))
        THEN 1 ELSE 0 END) AS CompanyName_OuterSpaces,
    
    SUM(CASE WHEN CompanyName LIKE N'%  %'
        THEN 1 ELSE 0 END) AS CompanyName_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ContactName) <>
                  DATALENGTH(TRIM(ContactName))
        THEN 1 ELSE 0 END) AS ContactName_OuterSpaces,
    
    SUM(CASE WHEN ContactName LIKE N'%  %'
        THEN 1 ELSE 0 END) AS ContactName_DoubleSpaces,

   SUM(CASE WHEN DATALENGTH(ContactTitle) <>
                  DATALENGTH(TRIM(ContactTitle))
        THEN 1 ELSE 0 END) AS ContactTitle_OuterSpaces,

    SUM(CASE WHEN ContactTitle LIKE N'%  %'
        THEN 1 ELSE 0 END) AS ContactTitle_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(Address) <>
                  DATALENGTH(TRIM(Address))
        THEN 1 ELSE 0 END) AS Address_OuterSpaces,

    SUM(CASE WHEN Address LIKE N'%  %'
        THEN 1 ELSE 0 END) AS Address_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(City) <>
                  DATALENGTH(TRIM(City))
        THEN 1 ELSE 0 END) AS City_OuterSpaces,

    SUM(CASE WHEN City LIKE N'%  %'
        THEN 1 ELSE 0 END) AS City_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(Region) <>
                  DATALENGTH(TRIM(Region))
        THEN 1 ELSE 0 END) AS Region_OuterSpaces,

    SUM(CASE WHEN Region LIKE N'%  %'
        THEN 1 ELSE 0 END) AS Region_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(PostalCode) <>
                  DATALENGTH(TRIM(PostalCode))
        THEN 1 ELSE 0 END) AS PostalCode_OuterSpaces,

    SUM(CASE WHEN PostalCode LIKE N'%  %'
        THEN 1 ELSE 0 END) AS PostalCode_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(Country) <>
                  DATALENGTH(TRIM(Country))
        THEN 1 ELSE 0 END) AS Country_OuterSpaces,

    SUM(CASE WHEN Country LIKE N'%  %'
        THEN 1 ELSE 0 END) AS Country_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(Phone) <>
                  DATALENGTH(TRIM(Phone))
        THEN 1 ELSE 0 END) AS Phone_OuterSpaces,

    SUM(CASE WHEN Phone LIKE N'%  %'
        THEN 1 ELSE 0 END) AS Phone_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(Fax) <>
                  DATALENGTH(TRIM(Fax))
        THEN 1 ELSE 0 END) AS Fax_OuterSpaces,

    SUM(CASE WHEN Fax LIKE N'%  %'
        THEN 1 ELSE 0 END) AS Fax_DoubleSpaces,

        SUM(CASE WHEN DATALENGTH(CAST(HomePage AS NVARCHAR(MAX))) <>
                      DATALENGTH(TRIM(CAST(HomePage AS NVARCHAR(MAX))))
            THEN 1 ELSE 0 END) AS HomePage_OuterSpaces,

        SUM(CASE WHEN CAST(HomePage AS NVARCHAR(MAX)) LIKE N'%  %'
            THEN 1 ELSE 0 END) AS HomePage_DoubleSpaces
FROM dbo.Suppliers;

-- Check country consistency

SELECT
    Country,
    COUNT(*) AS SupplierCount
FROM dbo.Suppliers
GROUP BY Country
ORDER BY Country;

-- Check city and country consistency

SELECT
    City,
    Country,
    COUNT(*) AS SupplierCount
FROM dbo.Suppliers
GROUP BY City, Country
ORDER BY Country, City;

-- Check Region and PostalCode consistency

SELECT
    SupplierID,
    City,
    Region,
    PostalCode,
    Country
FROM dbo.Suppliers
ORDER BY Country, City;

/*
-- Australian suppliers use Victoria (full name) and NSW (abbreviation) 
    - standardize these for reporting
--Values such as M14 GSD (UK) and 9999 ZZ (Netherlands) 
    - further verification against country-specific postal rules.
*/

-- Check products with invalid supplier references

SELECT
    p.ProductID,
    p.ProductName,
    p.SupplierID
FROM dbo.Products AS p
LEFT JOIN dbo.Suppliers AS s
    ON p.SupplierID = s.SupplierID
WHERE s.SupplierID IS NULL;

---------------------------------------------
-- Categories Table
---------------------------------------------

-- Check missing values

SELECT
    COUNT(*) AS TotalCategories,

    SUM(CASE WHEN CategoryID IS NULL
        THEN 1 ELSE 0 END) AS MissingCategoryID,

    SUM(CASE WHEN CategoryName IS NULL
                  OR TRIM(CategoryName) = ''
        THEN 1 ELSE 0 END) AS MissingCategoryName,

    SUM(CASE WHEN Description IS NULL
                  OR TRIM(CAST(Description AS NVARCHAR(MAX))) = ''
        THEN 1 ELSE 0 END) AS MissingDescription,

    SUM(CASE WHEN Picture IS NULL
        THEN 1 ELSE 0 END) AS MissingPicture
FROM dbo.Categories;

-- Check duplicate CategoryIDs

SELECT
    CategoryID,
    COUNT(*) AS DuplicateCount
FROM dbo.Categories
GROUP BY CategoryID
HAVING COUNT(*) > 1;

-- Check duplicate category names

SELECT
    UPPER(TRIM(CategoryName)) AS CategoryName,
    COUNT(*) AS DuplicateCount
FROM dbo.Categories
GROUP BY UPPER(TRIM(CategoryName))
HAVING COUNT(*) > 1;

-- Check whitespace in category text columns

SELECT
    SUM(CASE WHEN DATALENGTH(CategoryName) <>
                  DATALENGTH(TRIM(CategoryName))
        THEN 1 ELSE 0
    END) AS CategoryName_OuterSpaces,

    SUM(CASE WHEN CategoryName LIKE N'%  %'
        THEN 1 ELSE 0
    END) AS CategoryName_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(CAST(Description AS NVARCHAR(MAX))) <>
                  DATALENGTH(TRIM(CAST(Description AS NVARCHAR(MAX))))
        THEN 1 ELSE 0
    END) AS Description_OuterSpaces,

    SUM(CASE WHEN CAST(Description AS NVARCHAR(MAX)) LIKE N'%  %'
        THEN 1 ELSE 0
    END) AS Description_DoubleSpaces
FROM dbo.Categories;

-- Find categories without products

SELECT
    c.CategoryID,
    c.CategoryName
FROM dbo.Categories AS c
LEFT JOIN dbo.Products AS p
    ON c.CategoryID = p.CategoryID
WHERE p.ProductID IS NULL;

---------------------------------------------
-- Customers Table
---------------------------------------------

-- Check missing and blank values

SELECT
    COUNT(*) AS TotalCustomers,

    SUM(CASE WHEN CustomerID IS NULL OR TRIM(CustomerID) = ''
        THEN 1 ELSE 0 END) AS MissingCustomerID,

    SUM(CASE WHEN CompanyName IS NULL OR TRIM(CompanyName) = ''
        THEN 1 ELSE 0 END) AS MissingCompanyName,

    SUM(CASE WHEN ContactName IS NULL OR TRIM(ContactName) = ''
        THEN 1 ELSE 0 END) AS MissingContactName,

    SUM(CASE WHEN ContactTitle IS NULL OR TRIM(ContactTitle) = ''
        THEN 1 ELSE 0 END) AS MissingContactTitle,

    SUM(CASE WHEN Address IS NULL OR TRIM(Address) = ''
        THEN 1 ELSE 0 END) AS MissingAddress,

    SUM(CASE WHEN City IS NULL OR TRIM(City) = ''
        THEN 1 ELSE 0 END) AS MissingCity,

    SUM(CASE WHEN Region IS NULL OR TRIM(Region) = ''
        THEN 1 ELSE 0 END) AS MissingRegion,

    SUM(CASE WHEN PostalCode IS NULL OR TRIM(PostalCode) = ''
        THEN 1 ELSE 0 END) AS MissingPostalCode,

    SUM(CASE WHEN Country IS NULL OR TRIM(Country) = ''
        THEN 1 ELSE 0 END) AS MissingCountry,

    SUM(CASE WHEN Phone IS NULL OR TRIM(Phone) = ''
        THEN 1 ELSE 0 END) AS MissingPhone,

    SUM(CASE WHEN Fax IS NULL OR TRIM(Fax) = ''
        THEN 1 ELSE 0 END) AS MissingFax

FROM dbo.Customers;

/*
Total Customer = 91
MissingRegion = 60,
MissingPostalCode = 1,
MissingFFax = 22
*/

-- Identify customers with missing postal codes

SELECT *
FROM dbo.Customers
WHERE PostalCode IS NULL
   OR TRIM(PostalCode) = '';
-- CustomerID HUNGO Ireland has a missing PostalCode

-- Check duplicate CustomerIDs
SELECT
    CustomerID,
    COUNT(*) AS DuplicateCount
FROM dbo.Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;


-- Check duplicate company names
SELECT
    UPPER(TRIM(CompanyName)) AS StandardizedCompanyName,
    COUNT(*) AS DuplicateCount
FROM dbo.Customers
GROUP BY UPPER(TRIM(CompanyName))
HAVING COUNT(*) > 1;

-- Check whitespace in customer text columns

SELECT
    SUM(CASE WHEN DATALENGTH(CustomerID) <>
                  DATALENGTH(TRIM(CustomerID))
        THEN 1 ELSE 0 END) AS CustomerID_OuterSpaces,

    SUM(CASE WHEN DATALENGTH(CompanyName) <>
                  DATALENGTH(TRIM(CompanyName))
        THEN 1 ELSE 0 END) AS CompanyName_OuterSpaces,

    SUM(CASE WHEN CompanyName LIKE N'%  %'
        THEN 1 ELSE 0 END) AS CompanyName_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ContactName) <>
                  DATALENGTH(TRIM(ContactName))
        THEN 1 ELSE 0 END) AS ContactName_OuterSpaces,

    SUM(CASE WHEN ContactName LIKE N'%  %'
        THEN 1 ELSE 0 END) AS ContactName_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ContactTitle) <>
                  DATALENGTH(TRIM(ContactTitle))
        THEN 1 ELSE 0 END) AS ContactTitle_OuterSpaces,

    SUM(CASE WHEN DATALENGTH(Address) <>
                  DATALENGTH(TRIM(Address))
        THEN 1 ELSE 0 END) AS Address_OuterSpaces,

    SUM(CASE WHEN Address LIKE N'%  %'
        THEN 1 ELSE 0 END) AS Address_DoubleSpaces,

    SUM(CASE WHEN DATALENGTH(City) <>
                  DATALENGTH(TRIM(City))
        THEN 1 ELSE 0 END) AS City_OuterSpaces,

    SUM(CASE WHEN DATALENGTH(Region) <>
                  DATALENGTH(TRIM(Region))
        THEN 1 ELSE 0 END) AS Region_OuterSpaces,

    SUM(CASE WHEN DATALENGTH(PostalCode) <>
                  DATALENGTH(TRIM(PostalCode))
        THEN 1 ELSE 0 END) AS PostalCode_OuterSpaces,

    SUM(CASE WHEN DATALENGTH(Country) <>
                  DATALENGTH(TRIM(Country))
        THEN 1 ELSE 0 END) AS Country_OuterSpaces,

    SUM(CASE WHEN DATALENGTH(Phone) <>
                  DATALENGTH(TRIM(Phone))
        THEN 1 ELSE 0 END) AS Phone_OuterSpaces,

    SUM(CASE WHEN DATALENGTH(Fax) <>
                  DATALENGTH(TRIM(Fax))
        THEN 1 ELSE 0 END) AS Fax_OuterSpaces

FROM dbo.Customers;
-- One CompanyName has DoubleSpaces, Three Address have DoubleSpaces

-- Identify customers with double spaces in company names or addresses

SELECT
    CustomerID,
    CompanyName,
    Address,
    City,
    Country
FROM dbo.Customers
WHERE CompanyName LIKE N'%  %'
   OR Address LIKE N'%  %';

-- Check country consistency

SELECT
    Country,
    COUNT(*) AS TotalCustomers
FROM dbo.Customers
GROUP BY Country
ORDER BY Country;

-- Check city and country consistency

SELECT
    City,
    Country,
    COUNT(*) AS TotalCustomers
FROM dbo.Customers
GROUP BY
    City, Country
ORDER BY
    Country,City;

-- Check orders without a matching customer

SELECT
    o.OrderID,
    o.CustomerID
FROM dbo.Orders AS o
LEFT JOIN dbo.Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

---------------------------------------------
-- Orders Table
---------------------------------------------

-- Check missing and blank values

SELECT
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN OrderID IS NULL
        THEN 1 ELSE 0 END) AS MissingOrderID,

    SUM(CASE WHEN CustomerID IS NULL
                  OR TRIM(CustomerID) = ''
        THEN 1 ELSE 0 END) AS MissingCustomerID,

    SUM(CASE WHEN EmployeeID IS NULL
        THEN 1 ELSE 0 END) AS MissingEmployeeID,

    SUM(CASE WHEN OrderDate IS NULL
        THEN 1 ELSE 0 END) AS MissingOrderDate,

    SUM(CASE WHEN RequiredDate IS NULL
        THEN 1 ELSE 0 END) AS MissingRequiredDate,

    SUM(CASE WHEN ShippedDate IS NULL
        THEN 1 ELSE 0 END) AS MissingShippedDate,

    SUM(CASE WHEN ShipVia IS NULL
        THEN 1 ELSE 0 END) AS MissingShipVia,

    SUM(CASE WHEN Freight IS NULL
        THEN 1 ELSE 0 END) AS MissingFreight,

    SUM(CASE WHEN ShipName IS NULL OR TRIM(ShipName) = ''
        THEN 1 ELSE 0 END) AS MissingShipName,

    SUM(CASE WHEN ShipAddress IS NULL OR TRIM(ShipAddress) = ''
        THEN 1 ELSE 0 END) AS MissingShipAddress,

    SUM(CASE WHEN ShipCity IS NULL OR TRIM(ShipCity) = ''
        THEN 1 ELSE 0 END) AS MissingShipCity,

    SUM(CASE WHEN ShipRegion IS NULL OR TRIM(ShipRegion) = ''
        THEN 1 ELSE 0 END) AS MissingShipRegion,

    SUM(CASE WHEN ShipPostalCode IS NULL OR TRIM(ShipPostalCode) = ''
        THEN 1 ELSE 0 END) AS MissingShipPostalCode,

    SUM(CASE WHEN ShipCountry IS NULL OR TRIM(ShipCountry) = ''
        THEN 1 ELSE 0 END) AS MissingShipCountry

FROM dbo.Orders;
-- 21 MissingShippedDate, 507 MissingShipRegion, 19 MissingPostalCode

-- Which orders have no recorded shipping date?

SELECT *
FROM dbo.Orders
WHERE ShippedDate IS NULL
ORDER BY OrderDate;
-- 1998-04-08 to 1998-05-06 orderdate missing shippeddate

-- Identify orders with missing or blank postal codes

SELECT *
FROM dbo.Orders
WHERE ShipPostalCode IS NULL
   OR TRIM(ShipPostalCode) = ''
ORDER BY ShipCountry, OrderID;
-- All 19 missing shipping postal codes belong to the same customer: HUNGO

-- Identify duplicate OrderIDs

SELECT
    OrderID,
    COUNT(*) AS DuplicateCount
FROM dbo.Orders
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- Check for invalid date sequences

SELECT
    OrderID,
    OrderDate,
    RequiredDate,
    ShippedDate
FROM dbo.Orders
WHERE ShippedDate < OrderDate
   OR RequiredDate < OrderDate
ORDER BY OrderID;

-- Check negative and zero freight charges

SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE WHEN Freight < 0
        THEN 1 ELSE 0 END) AS NegativeFreight,

    SUM(CASE WHEN Freight = 0
        THEN 1 ELSE 0 END) AS ZeroFreight,

    MIN(Freight) AS MinimumFreight,
    MAX(Freight) AS MaximumFreight,
    AVG(Freight) AS AverageFreight

FROM dbo.Orders;

-- CHECK EXTRA SPACES

SELECT
    SUM(CASE WHEN DATALENGTH(ShipName) <>
                  DATALENGTH(TRIM(ShipName))
        THEN 1 ELSE 0 END) AS ShipNameOuterSpaces,

    SUM(CASE WHEN ShipName LIKE '%  %'
        THEN 1 ELSE 0 END) AS ShipNameDoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ShipAddress) <>
                  DATALENGTH(TRIM(ShipAddress))
        THEN 1 ELSE 0 END) AS ShipAddressOuterSpaces,

    SUM(CASE WHEN ShipAddress LIKE '%  %'
        THEN 1 ELSE 0 END) AS ShipAddressDoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ShipCity) <>
                  DATALENGTH(TRIM(ShipCity))
        THEN 1 ELSE 0 END) AS ShipCityOuterSpaces,

    SUM(CASE WHEN ShipCity LIKE '%  %'
        THEN 1 ELSE 0 END) AS ShipCityDoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ShipRegion) <>
                  DATALENGTH(TRIM(ShipRegion))
        THEN 1 ELSE 0 END) AS ShipRegionOuterSpaces,

    SUM(CASE WHEN ShipRegion LIKE '%  %'
        THEN 1 ELSE 0 END) AS ShipRegionDoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ShipPostalCode) <>
                  DATALENGTH(TRIM(ShipPostalCode))
        THEN 1 ELSE 0 END) AS ShipPostalCodeOuterSpaces,

    SUM(CASE WHEN ShipPostalCode LIKE '%  %'
        THEN 1 ELSE 0 END) AS ShipPostalCodeDoubleSpaces,

    SUM(CASE WHEN DATALENGTH(ShipCountry) <>
                  DATALENGTH(TRIM(ShipCountry))
        THEN 1 ELSE 0 END) AS ShipCountryOuterSpaces,

    SUM(CASE WHEN ShipCountry LIKE '%  %'
        THEN 1 ELSE 0 END) AS ShipCountryDoubleSpaces

FROM dbo.Orders;
-- 28 ShipAddressDoubleSpaces

-- INVESTIGATE SHIPADDRESS DOUBLE SPACES

SELECT
    OrderID,
    CustomerID,
    ShipAddress
FROM dbo.Orders
WHERE ShipAddress LIKE '%  %'
ORDER BY CustomerID, OrderID;

-- SHIPPER REFERENCE VALIDATION

SELECT
    o.OrderID,
    o.ShipVia
FROM dbo.Orders AS o
LEFT JOIN dbo.Shippers AS s
    ON o.ShipVia = s.ShipperID
WHERE s.ShipperID IS NULL;

-- ORDER DETAILS REFERENCE CHECK

SELECT
    od.OrderID,
    od.ProductID
FROM dbo.[Order Details] AS od
LEFT JOIN dbo.Orders AS o
    ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;

-- ORDERS WITHOUT ORDER DETAILS

SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate
FROM dbo.Orders AS o
LEFT JOIN dbo.[Order Details] AS od
    ON o.OrderID = od.OrderID
WHERE od.OrderID IS NULL;

---------------------------------------------
-- Order Details Table
---------------------------------------------

-- CHECK MISSING VALUES

SELECT
    COUNT(*) AS TotalRecords,

    SUM(CASE WHEN OrderID IS NULL
        THEN 1 ELSE 0 END) AS MissingOrderID,

    SUM(CASE WHEN ProductID IS NULL
        THEN 1 ELSE 0 END) AS MissingProductID,

    SUM(CASE WHEN UnitPrice IS NULL
        THEN 1 ELSE 0 END) AS MissingUnitPrice,

    SUM(CASE WHEN Quantity IS NULL
        THEN 1 ELSE 0 END) AS MissingQuantity,

    SUM(CASE WHEN Discount IS NULL
        THEN 1 ELSE 0 END) AS MissingDiscount
FROM dbo.[Order Details];

-- CHECK DUPLICATE IDS

SELECT
    OrderID,
    ProductID,
    COUNT(*) AS DuplicateCount
FROM dbo.[Order Details]
GROUP BY
    OrderID,
    ProductID
HAVING COUNT(*) > 1;

-- Unit Price, Quantity and Discount Validation

SELECT
    COUNT(*) AS TotalRecords,

    SUM(CASE WHEN UnitPrice < 0 THEN 1 ELSE 0 END) AS NegativePrices,

    SUM(CASE WHEN Quantity <= 0 THEN 1 ELSE 0 END) AS InvalidQuantities,

    SUM(CASE WHEN Discount < 0 OR Discount > 1 THEN 1 ELSE 0 END) AS InvalidDiscounts
FROM dbo.[Order Details];

-- PRODUCT REFERENCE VALIDATION

SELECT
    od.OrderID,
    od.ProductID
FROM dbo.[Order Details] AS od
LEFT JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

-- PRODUCTS WITHOUT ORDER DETAILS

SELECT
    p.ProductID,
    p.ProductName
FROM dbo.Products AS p
LEFT JOIN dbo.[Order Details] AS od
    ON p.ProductID = od.ProductID
WHERE od.ProductID IS NULL;

---------------------------------------------
-- Shippers Table
---------------------------------------------

-- CHECK MISSING VALUES

SELECT
    COUNT(*) AS TotalShippers,

    SUM(CASE WHEN ShipperID IS NULL
        THEN 1 ELSE 0 END) AS MissingShipperID,

    SUM(CASE WHEN CompanyName IS NULL
                  OR TRIM(CompanyName) = ''
        THEN 1 ELSE 0 END) AS MissingCompanyName,

    SUM(CASE WHEN Phone IS NULL
                  OR TRIM(Phone) = ''
        THEN 1 ELSE 0 END) AS MissingPhone
FROM dbo.Shippers;

-- CHECK EXTRA SPACES

SELECT
    SUM(CASE WHEN DATALENGTH(CompanyName) <>
                  DATALENGTH(TRIM(CompanyName))
        THEN 1 ELSE 0
    END) AS CompanyNameOuterSpaces,

    SUM(CASE WHEN CompanyName LIKE '%  %'
        THEN 1 ELSE 0
    END) AS CompanyNameDoubleSpaces,

    SUM(CASE WHEN DATALENGTH(Phone) <>
                  DATALENGTH(TRIM(Phone))
        THEN 1 ELSE 0
    END) AS PhoneOuterSpaces,

    SUM(CASE WHEN Phone LIKE '%  %'
        THEN 1 ELSE 0
    END) AS PhoneDoubleSpaces
FROM dbo.Shippers;

-- Check duplicate ShipperIDs

SELECT
    ShipperID,
    COUNT(*) AS DuplicateCount
FROM dbo.Shippers
GROUP BY ShipperID
HAVING COUNT(*) > 1;


-- Check duplicate CompanyNames

SELECT
    CompanyName,
    COUNT(*) AS DuplicateCount
FROM dbo.Shippers
GROUP BY CompanyName
HAVING COUNT(*) > 1;
