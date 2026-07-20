-- Integracion para Gold Layer
SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

SELECT * FROM silver.erp_cust_az12 WHERE cid = 'AW00025441'
SELECT * FROM silver.erp_cust_az12 WHERE cid = 'AW00029483'

SELECT * FROM bronze.crm_cust_info WHERE cst_key = 'AW00028543'
SELECT * FROM bronze.erp_cust_az12 WHERE cid LIKE '%28543%'


SELECT cst_id, COUNT(*) FROM
    (SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
    ON         ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
    ON         ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1

SELECT * FROM silver.crm_cust_info;
SELECT * FROM silver.erp_cust_az12;
SELECT * FROM silver.erp_loc_a101;


-- campo cst_gndr y gen
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender Info
       ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
order by 1,2;

-- Creacion de la view
CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender Info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

SELECT * FROM gold.dim_customers;
SELECT distinct gender from gold.dim_customers;
