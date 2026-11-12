USE NorthwindIntegration;
GO

---------------------------
-- CREATE DATABASE SCHEMAS
---------------------------

-- Create staging schema
IF SCHEMA_ID('staging') IS NULL
    EXEC('CREATE SCHEMA staging');
GO

-- Create cleaned schema
IF SCHEMA_ID('cleaned') IS NULL
    EXEC('CREATE SCHEMA cleaned');
GO

-- Create reporting schema
IF SCHEMA_ID('reporting') IS NULL
    EXEC('CREATE SCHEMA reporting');
GO

-- Verify the three schemas

SELECT
    name AS SchemaName
FROM sys.schemas
WHERE name IN ('staging', 'cleaned', 'reporting')
ORDER BY name;
