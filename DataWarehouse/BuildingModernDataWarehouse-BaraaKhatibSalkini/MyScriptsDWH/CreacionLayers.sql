-- Create Database 'DataWarehouse'
USE master;

CREATE DATABASE DataWarehouse;
SELECT name FROM sys.databases;
USE DataWarehouse;
GO
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;