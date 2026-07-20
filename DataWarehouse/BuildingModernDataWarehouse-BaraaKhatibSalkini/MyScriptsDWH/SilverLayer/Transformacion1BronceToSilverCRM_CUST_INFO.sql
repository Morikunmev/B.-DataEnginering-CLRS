USE DataWarehouse;

SELECT * FROM bronze.crm_cust_info

SELECT cst_id, COUNT(*) FROM bronze.crm_cust_info 
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL

SELECT * FROM bronze.crm_cust_info WHERE cst_id = 29466;


SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info;

SELECT
*
FROM (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
)t WHERE flag_last =1 

SELECT cst_id, COUNT(*) FROM bronze.crm_cust_info 
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL

SELECT
*
FROM (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
)t WHERE flag_last =1 AND cst_id = 29466

-- 2do Check 
SELECT * FROM bronze.crm_cust_info

-- Check for unwated Spaces
-- Expectation: No Results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- La aplicamos a la futura transformacion
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
FROM (
    SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1

-- Data Stardardization & Consistency: crm_cust_info
SELECT DISTINCT cst_gndr FROM bronze.crm_cust_info

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
     WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
     ELSE 'n/a'
END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
     ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM (
    SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1


-- Data Stardardization & Consistency: cst_marital_status
SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info


-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
-- silver.crm_cust_info
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info


-- Quality Checks
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT *
FROM silver.crm_prd_info
