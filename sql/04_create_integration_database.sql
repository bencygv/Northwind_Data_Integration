-----------------------------------
-- Create Database
-----------------------------------

USE master;
GO

IF DB_ID ('NorthwindIntegration') IS NULL
	CREATE DATABASE NorthwindIntegration;
GO

-- Verify DATABASE
SELECT name
FROM sys.databases
WHERE name = 'NorthwindIntegration';
