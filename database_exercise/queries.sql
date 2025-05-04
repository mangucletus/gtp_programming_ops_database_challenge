-- Top Customers by Spending
SELECT c.customer_id, c.name, SUM(oi.unit_price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;


-- Monthly Sales Report (Only Shipped/Delivered)
SELECT 
  DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
  SUM(oi.unit_price * oi.quantity) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status IN ('Shipped', 'Delivered')
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;


-- Products Never Ordered
SELECT p.name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- Average Order Value by Country
SELECT country, AVG(order_total) AS avg_order_value
FROM (
  SELECT c.country, o.order_id,
         SUM(oi.unit_price * oi.quantity) AS order_total
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.order_id, c.country
) AS sub
GROUP BY country;


-- Frequent Buyers (More Than One Order)
SELECT c.name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING COUNT(o.order_id) > 1;

