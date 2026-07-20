-----------------------------------------------------------
-----------------Change Over Time Analysis-----------------
-----------------------------------------------------------


-- Analyze Sales Performance Over Time

-- Vista rápida de la tabla de hechos
SELECT * FROM gold.fact_sales

-- Ventas, clientes y cantidad total por año
SELECT 
YEAR(order_date) as order_year,
SUM(sales_amount) as total_Sales,-- ventas
COUNT(DISTINCT customer_key) as total_customers, -- clientes
SUM(quanity) as total_quantity -- cantidad total
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

-- Ventas, clientes y cantidad total por mes (agregado de todos los años)
SELECT 
MONTH(order_date) as order_year,
SUM(sales_amount) as total_Sales, -- ventas
COUNT(DISTINCT customer_key) as total_customers, -- clientes
SUM(quanity) as total_quantity -- cantidad total
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date) -- por mes 
ORDER BY MONTH(order_date) -- por mes 

-- Ventas, clientes y cantidad total por año y mes
SELECT 
YEAR(order_date) as order_year,
MONTH(order_date) as order_month, 
SUM(sales_amount) as total_Sales, --ventas
COUNT(DISTINCT customer_key) as total_customers, --clientes
SUM(quanity) as total_quantity --cantidad total 
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date) -- por año y mes
ORDER BY YEAR(order_date), MONTH(order_date) -- por año y mes


-- Ventas, clientes y cantidad total por año usando DATETRUNC
SELECT 
DATETRUNC(year, order_date) as order_date,
SUM(sales_amount) as total_Sales, --ventas
COUNT(DISTINCT customer_key) as total_customers, --clientes
SUM(quanity) as total_quantity -- cantidad total
FROM gold.fact_sales 
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(year, order_date) -- por año
ORDER BY DATETRUNC(year, order_date)

-- Ventas, clientes y cantidad total por año-mes usando FORMAT
SELECT 
FORMAT(order_date, 'yyyy-MMM') as order_date,
SUM(sales_amount) as total_Sales, -- ventas
COUNT(DISTINCT customer_key) as total_customers, -- clientes
SUM(quanity) as total_quantity -- cantidad total
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY FORMAT(order_date, 'yyyy-MMM') -- año-mes usando FORMAT
ORDER BY FORMAT(order_date, 'yyyy-MMM') -- año-mes usando FORMAT




-----------------------------------------------------------
-----------------Cumulative Analysis-----------------------
-----------------------------------------------------------

-- Calculate the total sales per year

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
SELECT 
DATETRUNC(year,order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year,order_date))t

-- Calculate the total sales, media price per year

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
SELECT 
DATETRUNC(year,order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year,order_date))t




-----------------------------------------------------------
-----------------Performance Analysis ---------------------
-----------------------------------------------------------

/* Analyze the early performance of products by comparing their sales
to both the average sales performance of the product and the 
previous year's sales */

WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) AS order_year,
p.product_name,
SUM (f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
YEAR(f.order_date),
p.product_name
) 
SELECT 
order_year, product_name, current_sales,
-- Year-over-year Anaysis
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) as diff_avg,
CASE WHEN current_sales -  AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales -  AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
     WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'Avg'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year




-----------------------------------------------------------
-----------------Part-to-Whole Analysis  ------------------
-----------------------------------------------------------

/* Wich categories contribute the most to overrall sales? */


WITH category_sales AS (
SELECT category, SUM (sales_amount) total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY category)

SELECT
category,
total_sales,
SUM(total_sales) OVER() overall_sales,
CONCAT(ROUND((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER ())*100,2),'%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC





-----------------------------------------------------------
-----------------Data Segmentation-------------------------
-----------------------------------------------------------

/* Segment products into cost ranges and count 
how many products fall into each segment */

WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
FROM gold.dim_products) 
SELECT 
cost_range, COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC


/* Group customers into three segments based on their spending behavior
- VIP: at least 12 months of history and spending more than $5.000
- Regular: at least 12 months of history but spending $5.000 or less.
- New: lifespan less than 12 months

And find the total number of customers by each group
*/
SELECT * FROM gold.fact_sales
SELECT MIN (create_date) FROM gold.dim_customers


SELECT MIN(order_date),MAX(order_date) FROM gold.fact_sales

WITH customer_spending AS (
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
    FROM (
    SELECT
    customer_key,
    CASE WHEN lifespan >= 12 AND total_spending >5000 THEN 'VIP'
         WHEN lifespan >= 12 AND total_spending <=5000 THEN 'Regular'
         ELSE 'New'
    END customer_segment
    FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC;


WITH customer_spending AS (
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
    FROM (
    SELECT
    customer_key,
    CASE WHEN lifespan >= 18 AND total_spending > 4500 THEN 'VIP'
         WHEN lifespan >= 6 AND total_spending > 1500 THEN 'Regular'
         ELSE 'New'
    END customer_segment
    FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC

/*
==========================================================================================
Customer Report
==========================================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
==========================================================================================
*/

CREATE VIEW gold.report_customers AS
WITH base_query AS(
/*------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
------------------------------------------------------------------------*/
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quanity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
DATEDIFF(year,c.birthdate,GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)
,customer_aggregation AS (
/*------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
------------------------------------------------------------------------*/
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quanity) AS total_quanity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age)

SELECT
customer_key,
customer_number,
customer_name,
age,
CASE 
    WHEN age < 20 THEN 'Under 20'
    WHEN age between 20 and 29 THEN '20-29'
    WHEN age between 30 and 39 THEN '30-39'
    WHEN age between 40 and 49 THEN '40-49'
    ELSE '50 and above'
END AS age_group,
CASE
    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END AS customer_segment,
total_orders,
DATEDIFF(month,last_order_date,GETDATE()) as recency,
total_sales,
total_quanity,
total_products,
lifespan,
-- Compuate average order value (AVO)
CASE WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders 
END AS avg_order_value,

-- Compuate average monthly
CASE WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation


SELECT * FROM gold.report_customers

-- Query at Report 1 
SELECT
age_group,
COUNT(customer_number) AS total_customers,
SUM(total_sales) total_sales
FROM gold.report_customers
GROUP BY age_group

-- Query at Report 2 
SELECT
customer_segment,
COUNT(customer_number) AS total_customers,
SUM(total_sales) total_sales
FROM gold.report_customers
GROUP BY customer_segment


/*
===================================================================================================
Product Report
===================================================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue
===================================================================================================
*/

SELECT * FROM gold.dim_products
SELECT * FROM gold.fact_sales

CREATE VIEW gold.report_products AS
WITH base_query AS (
/*----------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
----------------------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quanity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
/*----------------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
----------------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quanity) AS total_quanity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quanity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*----------------------------------------------------------------------------------
3) Final Query: Combines all product results into one output
----------------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quanity,
    total_customers,
    avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregations


SELECT * FROM gold.report_products

-- Query 1: Ingresos totales por segmento de producto
SELECT
product_segment,
COUNT(product_key) AS total_products,
SUM(total_sales) AS total_sales
FROM gold.report_products
GROUP BY product_segment
ORDER BY total_sales DESC

-- Query 2: Rendimiento por categoría (ventas, clientes, precio promedio)
SELECT
category,
COUNT(product_key) AS total_products,
SUM(total_sales) AS total_sales,
SUM(total_customers) AS total_customers,
ROUND(SUM(total_sales) / NULLIF(SUM(total_quanity), 0), 1) AS avg_price_by_category
FROM gold.report_products
GROUP BY category
ORDER BY total_sales DESC

-- Query 3: Productos inactivos (sin ventas recientes) por categoría
SELECT
category,
COUNT(product_key) AS inactive_products
FROM gold.report_products
WHERE recency_in_months > 6
GROUP BY category
ORDER BY inactive_products DESC


