/*
============================================================
NORTHWIND - SALES ANALYSIS
============================================================

Purpose:
Analyze sales performance across orders, products,
customers, categories, and employees.

Key Concepts:
- Revenue calculation
- Discount analysis
- Sales aggregation
- Product performance
- Customer performance
- Category performance
- Employee performance

Sales Formula:

Gross Sales
= unit_price * quantity

Discount Amount
= unit_price * quantity * discount

Net Sales
= unit_price * quantity * (1 - discount)

============================================================
*/


-- Q1. Calculate gross sales, discount amount and net sales
-- for every order detail.

SELECT
    od.order_id,
    od.product_id,
    od.quantity,
    od.unit_price,
    od.discount,

    ROUND(
        od.unit_price * od.quantity,
        2
    ) AS gross_sales,

    ROUND(
        od.unit_price * od.quantity * od.discount,
        2
    ) AS discount_amount,

    ROUND(
        od.unit_price * od.quantity * (1 - od.discount),
        2
    ) AS net_sales

FROM order_details od;


-- Q2. Total gross sales, discount amount and net sales by year.

SELECT
    YEAR(o.order_date) AS order_year,

    ROUND(
        SUM(od.unit_price * od.quantity),
        2
    ) AS gross_sales,

    ROUND(
        SUM(od.unit_price * od.quantity * od.discount),
        2
    ) AS discount_amount,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ),
        2
    ) AS net_sales

FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

GROUP BY YEAR(o.order_date)

ORDER BY order_year;


-- Q3. Monthly net sales.

SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ),
        2
    ) AS net_sales

FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)

ORDER BY
    order_year,
    order_month;


-- Q4. Top 10 products by net sales.

SELECT
    p.product_id,
    p.product_name,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ),
        2
    ) AS net_sales

FROM products p

JOIN order_details od
    ON p.product_id = od.product_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY net_sales DESC

LIMIT 10;


-- Q5. Sales by category.

SELECT
    c.category_id,
    c.category_name,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ),
        2
    ) AS net_sales

FROM categories c

JOIN products p
    ON c.category_id = p.category_id

JOIN order_details od
    ON p.product_id = od.product_id

GROUP BY
    c.category_id,
    c.category_name

ORDER BY net_sales DESC;


-- Q6. Sales by customer.

SELECT
    c.customer_id,
    c.company_name,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ),
        2
    ) AS net_sales

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_details od
    ON o.order_id = od.order_id

GROUP BY
    c.customer_id,
    c.company_name

ORDER BY net_sales DESC;


-- Q7. Sales by employee.

SELECT
    e.employee_id,

    CONCAT(
        e.first_name,
        ' ',
        e.last_name
    ) AS employee_name,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ),
        2
    ) AS net_sales

FROM employees e

JOIN orders o
    ON e.employee_id = o.employee_id

JOIN order_details od
    ON o.order_id = od.order_id

GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name

ORDER BY net_sales DESC;


-- Q8. Sales by country.

SELECT
    c.country,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ),
        2
    ) AS net_sales

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_details od
    ON o.order_id = od.order_id

GROUP BY c.country

ORDER BY net_sales DESC;


-- Q9. Products with sales above the average product sales.

WITH product_sales AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM products p

    JOIN order_details od
        ON p.product_id = od.product_id

    GROUP BY
        p.product_id,
        p.product_name
),

average_sales AS
(
    SELECT
        AVG(net_sales) AS avg_product_sales

    FROM product_sales
)

SELECT
    ps.product_id,
    ps.product_name,

    ROUND(
        ps.net_sales,
        2
    ) AS net_sales,

    ROUND(
        a.avg_product_sales,
        2
    ) AS average_product_sales

FROM product_sales ps

CROSS JOIN average_sales a

WHERE ps.net_sales > a.avg_product_sales

ORDER BY ps.net_sales DESC;


-- Q10. Category contribution to total sales.

WITH category_sales AS
(
    SELECT
        c.category_id,
        c.category_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM categories c

    JOIN products p
        ON c.category_id = p.category_id

    JOIN order_details od
        ON p.product_id = od.product_id

    GROUP BY
        c.category_id,
        c.category_name
)

SELECT
    category_id,
    category_name,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    ROUND(
        net_sales * 100.0
        / SUM(net_sales) OVER (),
        2
    ) AS percentage_of_total_sales

FROM category_sales

ORDER BY percentage_of_total_sales DESC;
