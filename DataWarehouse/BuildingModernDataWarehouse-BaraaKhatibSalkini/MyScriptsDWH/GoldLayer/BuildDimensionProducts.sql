SELECT
  pn.prd_id,
  pn.cat_id,
  pn.prd_key,
  pn.prd_nm,
  pn.prd_cost,
  pn.prd_line,
  pn.prd_start_dt,
  pn.prd_end_dt
FROM silver.crm_prd_info pn

SELECT
  pn.prd_id,
  pn.cat_id,
  pn.prd_key,
  pn.prd_nm,
  pn.prd_cost,
  pn.prd_line,
  pn.prd_start_dt,
  pn.prd_end_dt
FROM silver.crm_prd_info pn


SELECT
  pn.prd_id,
  pn.cat_id,
  pn.prd_key,
  pn.prd_nm,
  pn.prd_cost,
  pn.prd_line,
  pn.prd_start_dt
FROM silver.crm_prd_info pn
WHERE prd_end_dt IS NULL --Filter out all historical data


SELECT
  pn.prd_id,
  pn.cat_id,
  pn.prd_key,
  pn.prd_nm,
  pn.prd_cost,
  pn.prd_line,
  pn.prd_start_dt,
  pc.cat,
  pc.subcat,
  pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all historical data

select * from silver.erp_px_cat_g1v2;
select * from silver.crm_prd_info

-- Comprobacion de unicidad de PK
SELECT prd_key, COUNT(*) FROM (
SELECT
  pn.prd_id,
  pn.cat_id,
  pn.prd_key,
  pn.prd_nm,
  pn.prd_cost,
  pn.prd_line,
  pn.prd_start_dt,
  pc.cat,
  pc.subcat,
  pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all historical data
)t GROUP BY prd_key
HAVING COUNT(*) > 1;

-- Aplicacion de ordenamiento y dar nombres frieldly y creacion de surrogate key y creacion de la vista
CREATE VIEW gold.dim_products AS 
SELECT
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
  pn.prd_id AS product_id,
  pn.prd_key AS product_number,
  pn.prd_nm AS product_name,
  pn.cat_id AS category_id,
  pc.cat AS category,
  pc.subcat AS subcategory,
  pc.maintenance,
  pn.prd_cost AS cost,
  pn.prd_line AS product_line,
  pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all historical dat

SELECT * FROM gold.dim_products
