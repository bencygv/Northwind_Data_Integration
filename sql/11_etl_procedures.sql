
USE NorthwindIntegration;
GO

CREATE OR ALTER PROCEDURE cleaned.usp_UpsertProducts
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- STEP 1: UPDATE changed products
        UPDATE c
        SET
            c.ProductName = s.ProductName,
            c.SupplierID = s.SupplierID,
            c.CategoryID = s.CategoryID,
            c.QuantityPerUnit =
                REPLACE(s.QuantityPerUnit, '  ', ' '),
            c.UnitPrice = s.UnitPrice,
            c.UnitsInStock = s.UnitsInStock,
            c.UnitsOnOrder = s.UnitsOnOrder,
            c.ReorderLevel = s.ReorderLevel,
            c.Discontinued = s.Discontinued
        FROM cleaned.Products AS c
        INNER JOIN staging.Products AS s
            ON c.ProductID = s.ProductID
        WHERE EXISTS
        (
            SELECT
                c.ProductName, c.SupplierID,
                c.CategoryID, c.QuantityPerUnit,
                c.UnitPrice, c.UnitsInStock,
                c.UnitsOnOrder, c.ReorderLevel,
                c.Discontinued
            EXCEPT
            SELECT
                s.ProductName, s.SupplierID,
                s.CategoryID,
                REPLACE(s.QuantityPerUnit, '  ', ' '),
                s.UnitPrice, s.UnitsInStock,
                s.UnitsOnOrder, s.ReorderLevel,
                s.Discontinued
        );

        -- STEP 2: INSERT new products
        INSERT INTO cleaned.Products
        (
            ProductID,
            ProductName,
            SupplierID,
            CategoryID,
            QuantityPerUnit,
            UnitPrice,
            UnitsInStock,
            UnitsOnOrder,
            ReorderLevel,
            Discontinued
        )
        SELECT
            s.ProductID,
            s.ProductName,
            s.SupplierID,
            s.CategoryID,
            REPLACE(s.QuantityPerUnit, '  ', ' '),
            s.UnitPrice,
            s.UnitsInStock,
            s.UnitsOnOrder,
            s.ReorderLevel,
            s.Discontinued
        FROM staging.Products AS s
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM cleaned.Products AS c
            WHERE c.ProductID = s.ProductID
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO



USE NorthwindIntegration;
GO

-- Execute the Products UPSERT procedure
EXEC cleaned.usp_UpsertProducts;
GO


-- Compare staging and cleaned records

SELECT
    'Staging' AS TableLayer,
    COUNT(*) AS TotalProducts
FROM staging.Products

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM cleaned.Products;


SELECT
    s.ProductID,
    s.QuantityPerUnit AS OriginalValue,
    c.QuantityPerUnit AS CleanedValue
FROM staging.Products AS s
INNER JOIN cleaned.Products AS c
    ON s.ProductID = c.ProductID
WHERE s.ProductID = 36;



USE NorthwindIntegration;
GO

CREATE OR ALTER PROCEDURE cleaned.usp_UpsertCustomers
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- STEP 1: Update existing customers
        -- only when their details have changed

        UPDATE c
        SET
            c.CompanyName =
                REPLACE(s.CompanyName, '  ', ' '),
            c.ContactName = s.ContactName,
            c.ContactTitle = s.ContactTitle,
            c.Address =
                REPLACE(s.Address, '  ', ' '),
            c.City = s.City,
            c.Region = s.Region,
            c.PostalCode = s.PostalCode,
            c.Country = s.Country,
            c.Phone = s.Phone,
            c.Fax = s.Fax
        FROM cleaned.Customers AS c
        INNER JOIN staging.Customers AS s
            ON c.CustomerID = s.CustomerID
        WHERE EXISTS
        (
            SELECT
                c.CompanyName,
                c.ContactName,
                c.ContactTitle,
                c.Address,
                c.City,
                c.Region,
                c.PostalCode,
                c.Country,
                c.Phone,
                c.Fax

            EXCEPT

            SELECT
                REPLACE(s.CompanyName, '  ', ' '),
                s.ContactName,
                s.ContactTitle,
                REPLACE(s.Address, '  ', ' '),
                s.City,
                s.Region,
                s.PostalCode,
                s.Country,
                s.Phone,
                s.Fax
        );

        -- STEP 2: Insert new customers

        INSERT INTO cleaned.Customers
        (
            CustomerID,
            CompanyName,
            ContactName,
            ContactTitle,
            Address,
            City,
            Region,
            PostalCode,
            Country,
            Phone,
            Fax
        )
        SELECT
            s.CustomerID,
            REPLACE(s.CompanyName, '  ', ' '),
            s.ContactName,
            s.ContactTitle,
            REPLACE(s.Address, '  ', ' '),
            s.City,
            s.Region,
            s.PostalCode,
            s.Country,
            s.Phone,
            s.Fax
        FROM staging.Customers AS s
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM cleaned.Customers AS c
            WHERE c.CustomerID = s.CustomerID
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


USE NorthwindIntegration;
GO

CREATE OR ALTER PROCEDURE cleaned.usp_UpsertOrders
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- STEP 1: UPDATE existing Orders
        -- only when their values have changed

        UPDATE c
        SET
            c.CustomerID = s.CustomerID,
            c.EmployeeID = s.EmployeeID,
            c.OrderDate = s.OrderDate,
            c.RequiredDate = s.RequiredDate,
            c.ShippedDate = s.ShippedDate,
            c.ShipVia = s.ShipVia,
            c.Freight = s.Freight,
            c.ShipName = s.ShipName,
            c.ShipAddress = s.ShipAddress,
            c.ShipCity = s.ShipCity,
            c.ShipRegion = s.ShipRegion,
            c.ShipPostalCode = s.ShipPostalCode,
            c.ShipCountry = s.ShipCountry

        FROM cleaned.Orders AS c
        INNER JOIN staging.Orders AS s
            ON c.OrderID = s.OrderID

        WHERE EXISTS
        (
            SELECT
                c.CustomerID,
                c.EmployeeID,
                c.OrderDate,
                c.RequiredDate,
                c.ShippedDate,
                c.ShipVia,
                c.Freight,
                c.ShipName,
                c.ShipAddress,
                c.ShipCity,
                c.ShipRegion,
                c.ShipPostalCode,
                c.ShipCountry

            EXCEPT

            SELECT
                s.CustomerID,
                s.EmployeeID,
                s.OrderDate,
                s.RequiredDate,
                s.ShippedDate,
                s.ShipVia,
                s.Freight,
                s.ShipName,
                s.ShipAddress,
                s.ShipCity,
                s.ShipRegion,
                s.ShipPostalCode,
                s.ShipCountry
        );

        -- STEP 2: INSERT new Orders

        INSERT INTO cleaned.Orders
        (
            OrderID,
            CustomerID,
            EmployeeID,
            OrderDate,
            RequiredDate,
            ShippedDate,
            ShipVia,
            Freight,
            ShipName,
            ShipAddress,
            ShipCity,
            ShipRegion,
            ShipPostalCode,
            ShipCountry
        )
        SELECT
            s.OrderID,
            s.CustomerID,
            s.EmployeeID,
            s.OrderDate,
            s.RequiredDate,
            s.ShippedDate,
            s.ShipVia,
            s.Freight,
            s.ShipName,
            s.ShipAddress,
            s.ShipCity,
            s.ShipRegion,
            s.ShipPostalCode,
            s.ShipCountry
        FROM staging.Orders AS s
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM cleaned.Orders AS c
            WHERE c.OrderID = s.OrderID
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO



USE NorthwindIntegration;
GO

CREATE OR ALTER PROCEDURE cleaned.usp_UpsertOrderDetails
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- STEP 1: UPDATE existing order details
        -- only when their values have changed

        UPDATE c
        SET
            c.UnitPrice = s.UnitPrice,
            c.Quantity = s.Quantity,
            c.Discount = s.Discount
        FROM cleaned.OrderDetails AS c
        INNER JOIN staging.OrderDetails AS s
            ON c.OrderID = s.OrderID
           AND c.ProductID = s.ProductID
        WHERE EXISTS
        (
            SELECT
                c.UnitPrice,
                c.Quantity,
                c.Discount

            EXCEPT

            SELECT
                s.UnitPrice,
                s.Quantity,
                s.Discount
        );

        -- STEP 2: INSERT new order details

        INSERT INTO cleaned.OrderDetails
        (
            OrderID,
            ProductID,
            UnitPrice,
            Quantity,
            Discount
        )
        SELECT
            s.OrderID,
            s.ProductID,
            s.UnitPrice,
            s.Quantity,
            s.Discount
        FROM staging.OrderDetails AS s
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM cleaned.OrderDetails AS c
            WHERE c.OrderID = s.OrderID
              AND c.ProductID = s.ProductID
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


USE NorthwindIntegration;
GO

-- Execute the OrderDetails UPSERT
EXEC cleaned.usp_UpsertOrderDetails;
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


-- Check duplicate OrderID + ProductID pairs
-- in the cleaned table

SELECT
    OrderID,
    ProductID,
    COUNT(*) AS DuplicateCount
FROM cleaned.OrderDetails
GROUP BY OrderID, ProductID
HAVING COUNT(*) > 1;
