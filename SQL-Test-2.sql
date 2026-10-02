/*STUDENT NAME : Muhammad Sabih
STUDENT ID : 874738
BATCH : MCDE - 06
DATE : 27-Sep-2026*/

USE bikestores;

SELECT
o.order_id,
o.order_date,
c.first_name + ' ' + c.last_name AS customer_full_name,
s.store_name,
st.first_name + ' ' + st.last_name AS staff_full_name,
p.product_name,
cat.category_name,
b.brand_name,
oi.quantity,
oi.list_price,
oi.discount,
oi.quantity * oi.list_price * (1 - oi.discount)
AS net_line_revenue
FROM sales.orders AS o
INNER JOIN sales.customers AS c
ON o.customer_id = c.customer_id
INNER JOIN sales.stores AS s
ON o.store_id = s.store_id
INNER JOIN sales.staffs AS st
ON o.staff_id = st.staff_id
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
INNER JOIN production.categories AS cat
ON p.category_id = cat.category_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
WHERE o.order_status = 4
ORDER BY o.order_date DESC;

/* TASK 2 - Store Performance Summary */

SELECT
s.store_name,
COUNT(DISTINCT o.order_id) AS number_of_distinct_orders,
SUM(oi.quantity) AS total_units_sold,
SUM(
oi.quantity * oi.list_price * (1 - oi.discount)
) AS total_net_revenue,
CAST(
SUM(
oi.quantity * oi.list_price * (1 - oi.discount)
)
/ NULLIF(COUNT(DISTINCT o.order_id), 0)
AS DECIMAL(12, 2)
) AS average_order_value
FROM sales.stores AS s
LEFT JOIN sales.orders AS o
ON s.store_id = o.store_id
AND o.order_status = 4
LEFT JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
GROUP BY
s.store_id,
s.store_name
ORDER BY
total_net_revenue DESC;
GO

/* TASK 3 - High-Value Customers */

WITH customer_spending AS
(
SELECT
c.customer_id,
c.first_name + ' ' + c.last_name AS customer_name,
COUNT(DISTINCT o.order_id) AS completed_order_count,
SUM(
oi.quantity * oi.list_price * (1 - oi.discount)
) AS total_spending
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY
c.customer_id,
c.first_name,
c.last_name
)

SELECT
customer_id,
customer_name,
completed_order_count,
total_spending
FROM customer_spending
WHERE total_spending >
(
SELECT AVG(total_spending)
FROM customer_spending
)
ORDER BY
total_spending DESC;
GO

/* TASK 4 - Inventory Risk Report */

SELECT
p.product_name,
s.store_name,
st.quantity AS current_quantity,
c.category_name,
b.brand_name
FROM production.stocks AS st
INNER JOIN production.products AS p
ON st.product_id = p.product_id
INNER JOIN sales.stores AS s
ON st.store_id = s.store_id
INNER JOIN production.categories AS c
ON p.category_id = c.category_id
INNER JOIN production.brands AS b
ON p.brand_id = b.brand_id
WHERE st.quantity < 5
ORDER BY
st.quantity ASC,
p.product_name;
GO


