-- CREATING BLANK TABLES 
--1
CREATE TABLE seller(
	seller_id TEXT PRIMARY KEY,
	seller_zip_code INT,
	seller_city VARCHAR(100),
	seller_state CHAR(2)
);
SELECT * FROM seller ;

--2
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status VARCHAR(100),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);
SELECT * FROM orders;

--3
CREATE TABLE payments (
    order_id TEXT,
    payment_sequential INT,
    payment_type VARCHAR(100),
    payment_installments INT,
    payment_value NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);
SELECT * FROM payments;

--4
CREATE TABLE review (
    review_id TEXT,
    order_id TEXT,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

SELECT * FROM review;

DROP TABLE review;

--5
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
SELECT * FROM customers;

--6
CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
SELECT * FROM products;

--7
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC(15,13),
    geolocation_lng NUMERIC(15,13),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);
SELECT * FROM geolocation;

--8
DROP TABLE items;
CREATE TABLE items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    product_category VARCHAR(100),
    delivery_status VARCHAR(20),
    PRIMARY KEY (order_id, order_item_id)
);
SELECT * FROM items;

--9
CREATE TABLE translations (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);
SELECT * FROM translations;

--CRITICAL IMPROVEMENTS IN THE CODE 
ALTER TABLE geolocation
ALTER COLUMN geolocation_lat TYPE NUMERIC(10,7),
ALTER COLUMN geolocation_lng TYPE NUMERIC(10,7);

SELECT * FROM orders LIMIT 1;
ALTER TABLE orders
ADD COLUMN customer_state CHAR(2),
ADD COLUMN delivery_status VARCHAR(20);

SELECT COUNT(*) FROM review;


-- INSERTING VALUES IN THE BLANK TABLES 
--DONE 

--QUERIES
--1. Which seller generates the highest and lowest total sales?
--a) HIGHEST 
SELECT seller_id, SUM(price) AS total_sales
FROM items
GROUP BY seller_id
ORDER BY total_sales DESC
LIMIT 1;

--b)LOWEST 
SELECT seller_id, SUM(price) AS total_sales
FROM items
GROUP BY seller_id
ORDER BY total_sales ASC
LIMIT 1;

--2. Which product category generates the highest and lowest sales?
--a)HIGHEST
SELECT product_category, SUM(price) AS total_sales
FROM items
GROUP BY product_category
ORDER BY total_sales DESC
LIMIT 1;

--b) LOWEST
SELECT product_category, SUM(price) AS total_sales
FROM items
GROUP BY product_category
ORDER BY total_sales ASC
LIMIT 1;

--3. Which customer state has the highest and lowest number of orders?
--a)HIGHEST
SELECT c.customer_state, COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC
LIMIT 1;

--b)LOWEST
SELECT c.customer_state, COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders ASC
LIMIT 1;

--4. Which payment method is the most and least used?
--a) MOST
SELECT payment_type, COUNT(order_id) AS count_of_id
FROM payments
GROUP BY payment_type
ORDER BY count_of_id DESC
LIMIT 1;

--b) LEAST
SELECT payment_type, COUNT(order_id) AS count_of_id
FROM payments
GROUP BY payment_type
ORDER BY count_of_id DESC
LIMIT 1;

--5. Which payment method generates the highest total payment value?
SELECT payment_type, SUM(payment_value) AS total_value
FROM payments
GROUP BY payment_type
ORDER BY total_value DESC;

--6. Which product category has the highest number of late deliveries?
SELECT product_category, COUNT(DISTINCT order_id) AS late_orders
FROM items
WHERE delivery_status = 'Late'
GROUP BY product_category
ORDER BY late_orders DESC
LIMIT 1;

--7. What percentage of orders were delivered late?
SELECT 
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) * 100.0 / COUNT(*) AS late_order_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

--8. Which customer state generates the highest and lowest sales?
--a) HIGHEST
SELECT 
    c.customer_state,
    SUM(i.price) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN items i
    ON o.order_id = i.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;

--b) LOWEST
SELECT 
    c.customer_state,
    SUM(i.price) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN items i ON o.order_id = i.order_id
GROUP BY c.customer_state
ORDER BY total_sales ASC
LIMIT 1;

--9. Which products have the highest and lowest number of items sold?
--a) HIGHEST
SELECT product_id, COUNT(*) AS total_items_sold
FROM items
GROUP BY product_id
ORDER BY total_items_sold DESC
LIMIT 1;

--b) LOWEST
SELECT product_id, COUNT(*) AS total_items_sold
FROM items
GROUP BY product_id
ORDER BY total_items_sold ASC
LIMIT 1;

--10. What is the average order value?
SELECT AVG(order_total) AS average_order_value
FROM (
    SELECT 
        order_id,
        SUM(price) AS order_total
    FROM items
    GROUP BY order_id
) AS orders;

--11. What is the average review score?
SELECT AVG(review_score) AS avg_review_score
FROM review;

--12. What percentage of total sales comes from the top 10 sellers?
SELECT 
    SUM(total_sales) / (SELECT SUM(price) FROM items) * 100 
        AS top_10_sales_percentage
FROM (
    SELECT 
        seller_id,
        SUM(price) AS total_sales
    FROM items
    GROUP BY seller_id
    ORDER BY total_sales DESC
    LIMIT 10
) AS top_sellers;

--END