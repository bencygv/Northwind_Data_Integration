
USE NorthwindIntegration;
GO

-- Check valid records
SELECT *
FROM demo.ValidProducts
ORDER BY ProductID;

-- Check rejected records
SELECT *
FROM demo.RejectedProducts
ORDER BY ProductID;

-- Check record counts
SELECT
    (SELECT COUNT(*)
     FROM demo.ValidProducts) AS ValidRecords,

    (SELECT COUNT(*)
     FROM demo.RejectedProducts) AS RejectedRecords;


USE NorthwindIntegration;
GO

SELECT
    ProductID,
    ProductName,
    UnitPrice,
    UnitsInStock
FROM demo.ValidProducts
ORDER BY ProductID;


SELECT
    ProductID,
    ProductName,
    UnitPrice,
    UnitsInStock,
    RejectReason,
    ErrorCode,
    ErrorColumn
FROM demo.RejectedProducts
ORDER BY ProductID;


USE NorthwindIntegration;
GO

SELECT 'Valid' AS RecordType,
       COUNT(*) AS TotalRecords
FROM demo.ValidProducts

UNION ALL

SELECT 'Rejected',
       COUNT(*)
FROM demo.RejectedProducts;

-- Check for duplicate rejected ProductIDs
SELECT ProductID, COUNT(*) AS Occurrences
FROM demo.RejectedProducts
GROUP BY ProductID
HAVING COUNT(*) > 1;


USE NorthwindIntegration;
GO

SELECT 'Valid' AS RecordType,
       COUNT(*) AS TotalRecords
FROM demo.ValidProducts

UNION ALL

SELECT 'Rejected',
       COUNT(*)
FROM demo.RejectedProducts;


-- Check duplicates across both demo tables

SELECT ProductID, COUNT(*) AS Occurrences
FROM
(
    SELECT ProductID FROM demo.ValidProducts
    UNION ALL
    SELECT ProductID FROM demo.RejectedProducts
) AS AllProducts
GROUP BY ProductID
HAVING COUNT(*) > 1;


USE NorthwindIntegration;
GO

SELECT
    ProductID,
    ProductName,
    UnitPrice,
    UnitsInStock,
    RejectReason
FROM demo.RejectedProducts
ORDER BY ProductID;


USE NorthwindIntegration;
GO

SELECT
    (SELECT COUNT(*)
     FROM demo.ValidProducts) AS ValidRecords,

    (SELECT COUNT(*)
     FROM demo.RejectedProducts) AS RejectedRecords;

     
USE NorthwindIntegration;
GO

TRUNCATE TABLE demo.ValidProducts;
TRUNCATE TABLE demo.RejectedProducts;

SELECT COUNT(*) AS ValidRecords
FROM demo.ValidProducts;

SELECT COUNT(*) AS RejectedRecords
FROM demo.RejectedProducts;
