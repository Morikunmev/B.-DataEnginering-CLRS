SELECT * FROM gold.dim_products;
SELECT DISTINCT category FROM gold.dim_products
SELECT DISTINCT sales_amount FROM gold.fact_sales
SELECT DISTINCT * FROM gold.fact_sales
-- etc

-------------- Database Exploration --------------
-- Explore ALL Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore ALL Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

-------------------------------------------------
-------------- Dimension Exploration --------------
-------------------------------------------------

SELECT * FROM gold.dim_customers
SELECT * FROM gold.dim_products
SELECT * FROM gold.fact_sales

-- Explore all countries our customers come from
SELECT DISTINCT country FROM gold.dim_customers

--- Explore All Categories "the major Divisions"
SELECT DISTINCT category from gold.dim_products


SELECT DISTINCT category, subcategory from gold.dim_products

SELECT DISTINCT category, subcategory, product_name 
from gold.dim_products ORDER BY 1,2,3

-------------------------------------------------
-------------- Date Exploration --------------
-------------------------------------------------


-- Find the date of the first and last order
SELECT
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales

-- Find the date of the first and last order
SELECT
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales


-- Find the youngest and the oldest c
SELECT 
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(year,MIN(birthdate),GETDATE()) AS oldest_age,
MAX(birthdate) AS youngest_birthdate,
DATEDIFF(year,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers

-- Rango de fechas de creación de productos
SELECT
    MIN(start_date) AS primer_producto_creado,
    MAX(start_date) AS ultimo_producto_creado,
    DATEDIFF(year, MIN(start_date), MAX(start_date)) AS rango_en_anios
FROM gold.dim_products

-- Antigüedad del producto más viejo y más nuevo (en años desde hoy)
SELECT
    MIN(start_date) AS producto_mas_antiguo,
    DATEDIFF(year, MIN(start_date), GETDATE()) AS antiguedad_mas_vieja,
    MAX(start_date) AS producto_mas_nuevo,
    DATEDIFF(year, MAX(start_date), GETDATE()) AS antiguedad_mas_nueva
FROM gold.dim_products

-------------------------------------------------
-------------- Measure Exploration --------------
-------------------------------------------------


SELECT * FROM gold.fact_sales;
-- 1. Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;

-- 2. Find how many items are sold
SELECT SUM (quanity) AS total_quantity FROM gold.fact_sales

-- 3. Find the average selling price
SELECT avg (price) AS avg_price FROM gold.fact_sales

-- 4. Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales
SELECT * FROM gold.fact_sales;

-- 5. Find the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_products
SELECT COUNT(DISTINCT product_name) AS total_products FROM gold.dim_products

SELECT * FROM gold.dim_products

-- 6. Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

SELECT * FROM gold.dim_customers

-- 7. Find the total number of customers that has placed an order
SELECT COUNT(customer_key) AS total_customers FROM gold.fact_sales

SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales

-- Comparacion entre fact_sales y dim_customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales


-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quanity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers


-------------------------------------------------
-------------- Magnitude Analysis --------------
-------------------------------------------------

-- 1. Find total customers by countries
SELECT * FROM gold.dim_customers;

SELECT country, COUNT(customer_key) AS total_customers
FROM gold.dim_customers 
GROUP BY country 
ORDER BY total_customers DESC;




-- 2. Find total customers by gender
SELECT gender, COUNT(customer_key) AS total_customers
FROM gold.dim_customers 
GROUP BY gender
ORDER BY total_customers DESC;





-- 3. Find total products by category
SELECT category, COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC



-- 4. What is the average costs in each category?
SELECT category,
AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs



-- 5. What is the total revenue generated for each category?
SELECT
p.category,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC




-- 6. Find total revenue is generated by each customer
SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC





-- 7. What is the distribution of sold items across countries?
SELECT * FROM gold.fact_sales;

SELECT 
c.country,
SUM(f.quanity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.country
ORDER BY total_sold_items DESC



-------------------------------------------------
-------------- Ranking Analysis --------------
-------------------------------------------------
-- Wich 5 products generate the highest revenue?

SELECT TOP 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- What are the 5 worst-performing products in terms of sales?

SELECT TOP 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue 

-- ¿Mejores subcategories de nuestros datos?
SELECT TOP 5
p.subcategory,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC

-- ¿Peores 5 subcategories de ventas?
SELECT TOP 5
p.subcategory,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue


-- Wich 5 products generate the highest revenue? - ROW_NUMBER()
SELECT * 
FROM (
    SELECT
    p.product_name,
    SUM(f.sales_amount) total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
    GROUP BY p.product_name)t
WHERE rank_products <=5

-- Se puede usar el RANK
SELECT * 
FROM (
    SELECT
    p.product_name,
    SUM(f.sales_amount) total_revenue,
    RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
    GROUP BY p.product_name)t
WHERE rank_products <=5


-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC



-- The 3 customers with the fewest orders placed
select * from gold.fact_sales WHERE order_number = 'SO58845'
select count(order_number) from gold.fact_sales
select count(DISTINCT order_number) from gold.fact_sales


SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders

