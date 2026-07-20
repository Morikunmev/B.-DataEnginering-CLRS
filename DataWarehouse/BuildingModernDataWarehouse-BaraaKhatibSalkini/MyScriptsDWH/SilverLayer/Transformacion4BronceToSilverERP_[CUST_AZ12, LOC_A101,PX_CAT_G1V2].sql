USE DataWarehouse;
------------------ erp_cust_az12 ------------------
INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
    ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
     ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;

SELECT * FROM [silver].[crm_cust_info]

-- Aplicacion de filtro de integridad referencial - CAMPO cid
SELECT
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info )

SELECT
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE cid NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info )


-- Checkit de bdate:
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Check it 'gen' Data Standarization & Consistency
SELECT DISTINCT
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
     ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

-- Checkeo de calidad de erp_cust_az12
-- Identify Out-of-Range Dates
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency
SELECT DISTINCT
gen
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12



------------------ erp_loc_a101------------------
INSERT INTO silver.erp_loc_a101
(cid,cntry)
SELECT
REPLACE(cid,'-','') cid,
CASE WHEN TRIM(cntry) =  'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;

SELECT cst_key FROM silver.crm_cust_info

--Checkeo de integridad referencial:
SELECT
REPLACE(cid, '-', '') cid,
cntry
FROM bronze.erp_loc_a101 WHERE REPLACE(cid, '-', '')  NOT IN
(SELECT cst_key FROM silver.crm_cust_info)
-- Check de integridad referencial de formato
SELECT
REPLACE(cid, '-', '') cid,
cntry
FROM bronze.erp_loc_a101 WHERE cid NOT IN
(SELECT cst_key FROM silver.crm_cust_info)

-- Data Standardization & Consistency
SELECT DISTINCT cntry FROM bronze.erp_loc_a101 ORDER BY cntry

SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) =  'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101

SELECT DISTINCT 
cntry AS old_cntry,
CASE WHEN TRIM(cntry) =  'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

-- Checkit Information
SELECT DISTINCT cntry FROM silver.erp_loc_a101
ORDER BY cntry 

SELECT * FROM silver.erp_loc_a101

-------------- Checkit erp_px_cat_g1v2--------------
INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2

select * from silver.crm_prd_info

-- Check for unwated Spaces
SELECT * FROM bronze.erp_px_cat_g1v2;

SELECT * FROM bronze.erp_px_cat_g1v2 WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2

-- Checkit data
SELECT * FROM silver.erp_px_cat_g1v2;

