SELECT
  sd.sls_ord_num,
  sd.sls_prd_key,
  sd.sls_cust_id,
  sd.sls_order_dt,
  sd.sls_ship_dt,
  sd.sls_due_dt,
  sd.sls_sales,
  sd.sls_quantity,
  sd.sls_price
FROM silver.crm_sales_details sd
SELECT * FROM silver.crm_sales_details sd

-- Le añadimos la SK, columns friendly, nos aseguramos que esten bien en sort columns y creamos la view
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
  sd.sls_ord_num AS order_number,
  pr.product_key,
  cu.customer_key,
  sd.sls_order_dt AS order_date,
  sd.sls_ship_dt AS shipping_date,
  sd.sls_due_dt AS due_date,
  sd.sls_sales AS sales_amount,
  sd.sls_quantity AS quanity,
  sd.sls_price price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id

SELECT name, type_desc, SCHEMA_NAME(schema_id) AS esquema
FROM sys.objects
WHERE name = 'fact_sales'

-- Quality Check of the Gold Table
SELECT * FROM gold.fact_sales

-- Foreign Key Integrity (Dimensions)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL

-- Foreign Key Integrity (Dimensions)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key 
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL

-- Para checkear si algun customer tiene venta (justificacion del opcional)
SELECT c.*
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales f
ON c.customer_key = f.customer_key
WHERE f.customer_key IS NULL