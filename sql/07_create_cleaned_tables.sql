USE NorthwindIntegration;
GO

---------------------------------------------
-- CREATE CLEANED TABLES
---------------------------------------------

-- CLEANED TABLE 1: SHIPPERS

IF OBJECT_ID('cleaned.Shippers', 'U') IS NULL
    CREATE TABLE cleaned.Shippers
    (
        ShipperID INT NOT NULL PRIMARY KEY,
        CompanyName NVARCHAR(40) NOT NULL,
        Phone NVARCHAR(24)
    );
GO

-- CLEANED TABLE 2: CATEGORIES

IF OBJECT_ID('cleaned.Categories', 'U') IS NULL
    CREATE TABLE cleaned.Categories
    (
        CategoryID INT NOT NULL PRIMARY KEY,
        CategoryName NVARCHAR(15) NOT NULL,
        Description NVARCHAR(MAX),
        Picture VARBINARY(MAX)
    );
GO

-- CLEANED TABLE 3: SUPPLIERS

IF OBJECT_ID('cleaned.Suppliers', 'U') IS NULL
    CREATE TABLE cleaned.Suppliers
    (
        SupplierID INT NOT NULL PRIMARY KEY,
        CompanyName NVARCHAR(40) NOT NULL,
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

-- CLEANED TABLE 4: PRODUCTS

IF OBJECT_ID('cleaned.Products', 'U') IS NULL
    CREATE TABLE cleaned.Products
    (
        ProductID INT NOT NULL PRIMARY KEY,
        ProductName NVARCHAR(40) NOT NULL,
        SupplierID INT,
        CategoryID INT,
        QuantityPerUnit NVARCHAR(20),
        UnitPrice DECIMAL(19,4),
        UnitsInStock SMALLINT,
        UnitsOnOrder SMALLINT,
        ReorderLevel SMALLINT,
        Discontinued BIT NOT NULL,

        -- Foreign Key: Products to Suppliers
        CONSTRAINT FK_Products_Suppliers
            FOREIGN KEY (SupplierID)
            REFERENCES cleaned.Suppliers(SupplierID),

        -- Foreign Key: Products to Categories
        CONSTRAINT FK_Products_Categories
            FOREIGN KEY (CategoryID)
            REFERENCES cleaned.Categories(CategoryID),

        -- Validate product price
        CONSTRAINT CK_Products_UnitPrice
            CHECK (UnitPrice >= 0),

        -- Validate inventory quantities
        CONSTRAINT CK_Products_UnitsInStock
            CHECK (UnitsInStock >= 0),

        CONSTRAINT CK_Products_UnitsOnOrder
            CHECK (UnitsOnOrder >= 0),

        CONSTRAINT CK_Products_ReorderLevel
            CHECK (ReorderLevel >= 0)
    );
GO

-- CLEANED TABLE 5: CUSTOMERS

IF OBJECT_ID('cleaned.Customers', 'U') IS NULL
    CREATE TABLE cleaned.Customers
    (
        CustomerID NCHAR(5) NOT NULL PRIMARY KEY,
        CompanyName NVARCHAR(40) NOT NULL,
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

-- CLEANED TABLE 6: ORDERS

IF OBJECT_ID('cleaned.Orders', 'U') IS NULL
    CREATE TABLE cleaned.Orders
    (
        OrderID INT NOT NULL PRIMARY KEY,
        CustomerID NCHAR(5),
        EmployeeID INT,
        OrderDate DATETIME,
        RequiredDate DATETIME,
        ShippedDate DATETIME,
        ShipVia INT,
        Freight DECIMAL(19,4),
        ShipName NVARCHAR(40),
        ShipAddress NVARCHAR(60),
        ShipCity NVARCHAR(15),
        ShipRegion NVARCHAR(15),
        ShipPostalCode NVARCHAR(10),
        ShipCountry NVARCHAR(15),

        -- Foreign key: Orders to Customers
        CONSTRAINT FK_Orders_Customers
            FOREIGN KEY (CustomerID)
            REFERENCES cleaned.Customers(CustomerID),

        -- Foreign key: Orders to Shippers
        CONSTRAINT FK_Orders_Shippers
            FOREIGN KEY (ShipVia)
            REFERENCES cleaned.Shippers(ShipperID),

        -- Freight cannot be negative
        CONSTRAINT CK_Orders_Freight
            CHECK (Freight >= 0),

        -- Required date cannot be before order date
        CONSTRAINT CK_Orders_RequiredDate
            CHECK (RequiredDate >= OrderDate),

        -- Shipment cannot occur before order placement
        CONSTRAINT CK_Orders_ShippedDate
            CHECK (ShippedDate >= OrderDate)
    );
GO

-- CLEANED TABLE 7: ORDER DETAILS

IF OBJECT_ID('cleaned.OrderDetails', 'U') IS NULL
    CREATE TABLE cleaned.OrderDetails
    (
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        UnitPrice DECIMAL(19,4) NOT NULL,
        Quantity SMALLINT NOT NULL,
        Discount DECIMAL(5,4) NOT NULL,

        -- Composite Primary Key
        CONSTRAINT PK_OrderDetails
            PRIMARY KEY (OrderID, ProductID),

        -- Foreign Key: OrderDetails to Orders
        CONSTRAINT FK_OrderDetails_Orders
            FOREIGN KEY (OrderID)
            REFERENCES cleaned.Orders(OrderID),

        -- Foreign Key: OrderDetails to Products
        CONSTRAINT FK_OrderDetails_Products
            FOREIGN KEY (ProductID)
            REFERENCES cleaned.Products(ProductID),

        -- Validation constraints
        CONSTRAINT CK_OrderDetails_UnitPrice
            CHECK (UnitPrice >= 0),

        CONSTRAINT CK_OrderDetails_Quantity
            CHECK (Quantity > 0),

        CONSTRAINT CK_OrderDetails_Discount
            CHECK (Discount >= 0 AND Discount <= 1)
    );
GO