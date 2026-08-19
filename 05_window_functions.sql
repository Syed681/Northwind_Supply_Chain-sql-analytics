/*
============================================================
NORTHWIND - WINDOW FUNCTIONS
============================================================

Purpose:
Demonstrate analytical SQL using window functions.

Key Concepts:
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- PARTITION BY
- LAG()
- Running totals
- Moving averages
- Top-N analysis
- MoM analysis
- YoY analysis

============================================================
*/


-- Q1. Rank products by total net sales.

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
)

SELECT
    product_id,
    product_name,

    ROUND(net_sales, 2) AS net_sales,

    RANK() OVER (
        ORDER BY net_sales DESC
    ) AS sales_rank

FROM product_sales

ORDER BY sales_rank;


-- Q2. Rank products within each category.

WITH product_sales AS
(
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM products p

    JOIN categories c
        ON p.category_id = c.category_id

    JOIN order_details od
        ON p.product_id = od.product_id

    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
)

SELECT
    category_name,
    product_id,
    product_name,

    ROUND(net_sales, 2) AS net_sales,

    DENSE_RANK() OVER (
        PARTITION BY category_name
        ORDER BY net_sales DESC
    ) AS category_rank

FROM product_sales

ORDER BY
    category_name,
    category_rank;


-- Q3. Top 3 products within each category.

WITH product_sales AS
(
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM products p

    JOIN categories c
        ON p.category_id = c.category_id

    JOIN order_details od
        ON p.product_id = od.product_id

    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
),

ranked_products AS
(
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY category_name
            ORDER BY net_sales DESC
        ) AS category_rank

    FROM product_sales
)

SELECT
    category_name,
    product_id,
    product_name,

    ROUND(net_sales, 2) AS net_sales,

    category_rank

FROM ranked_products

WHERE category_rank <= 3

ORDER BY
    category_name,
    category_rank;


-- Q4. Rank customers by spending within each country.

WITH customer_sales AS
(
    SELECT
        c.customer_id,
        c.company_name,
        c.country,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS total_spending

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        c.customer_id,
        c.company_name,
        c.country
)

SELECT
    country,
    customer_id,
    company_name,

    ROUND(
        total_spending,
        2
    ) AS total_spending,

    DENSE_RANK() OVER (
        PARTITION BY country
        ORDER BY total_spending DESC
    ) AS country_rank

FROM customer_sales

ORDER BY
    country,
    country_rank;


-- Q5. Assign a sequential number to customers
-- based on their total spending.

WITH customer_sales AS
(
    SELECT
        c.customer_id,
        c.company_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS total_spending

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        c.customer_id,
        c.company_name
)

SELECT
    customer_id,
    company_name,

    ROUND(
        total_spending,
        2
    ) AS total_spending,

    ROW_NUMBER() OVER (
        ORDER BY total_spending DESC
    ) AS customer_number

FROM customer_sales

ORDER BY customer_number;


-- Q6. Monthly sales with previous month's sales.

WITH monthly_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(net_sales, 2) AS net_sales,

    ROUND(
        LAG(net_sales) OVER (
            ORDER BY order_year, order_month
        ),
        2
    ) AS previous_month_sales

FROM monthly_sales

ORDER BY year, month;


-- Q7. Month-over-month sales growth.

WITH monthly_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
),

sales_with_previous AS
(
    SELECT
        order_year,
        order_month,
        net_sales,

        LAG(net_sales) OVER (
            ORDER BY order_year, order_month
        ) AS previous_month_sales

    FROM monthly_sales
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(net_sales, 2) AS net_sales,

    ROUND(
        previous_month_sales,
        2
    ) AS previous_month_sales,

    ROUND(
        (
            (net_sales - previous_month_sales)
            / NULLIF(previous_month_sales, 0)
        ) * 100,
        2
    ) AS mom_growth_percentage

FROM sales_with_previous

ORDER BY year, month;


-- Q8. Year-over-year sales growth.

WITH yearly_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY YEAR(o.order_date)
),

sales_with_previous AS
(
    SELECT
        order_year,
        net_sales,

        LAG(net_sales) OVER (
            ORDER BY order_year
        ) AS previous_year_sales

    FROM yearly_sales
)

SELECT
    order_year AS year,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    ROUND(
        previous_year_sales,
        2
    ) AS previous_year_sales,

    ROUND(
        (
            (net_sales - previous_year_sales)
            / NULLIF(previous_year_sales, 0)
        ) * 100,
        2
    ) AS yoy_growth_percentage

FROM sales_with_previous

ORDER BY year;


-- Q9. Running total of monthly sales.

WITH monthly_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(
        net_sales,
        2
    ) AS monthly_sales,

    ROUND(
        SUM(net_sales) OVER (
            ORDER BY order_year, order_month
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
        ),
        2
    ) AS running_total_sales

FROM monthly_sales

ORDER BY year, month;


-- Q10. Running yearly sales.
-- The running total resets at the beginning of each year.

WITH monthly_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(
        net_sales,
        2
    ) AS monthly_sales,

    ROUND(
        SUM(net_sales) OVER (
            PARTITION BY order_year
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
        ),
        2
    ) AS running_yearly_sales

FROM monthly_sales

ORDER BY year, month;


-- Q11. Three-month moving average of sales.

WITH monthly_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(
        net_sales,
        2
    ) AS monthly_sales,

    ROUND(
        AVG(net_sales) OVER (
            ORDER BY order_year, order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average

FROM monthly_sales

ORDER BY year, month;


-- Q12. Percentage contribution of each product
-- to total sales.

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
)

SELECT
    product_id,
    product_name,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    ROUND(
        net_sales * 100.0
        / SUM(net_sales) OVER (),
        2
    ) AS percentage_of_total_sales

FROM product_sales

ORDER BY percentage_of_total_sales DESC;


-- Q13. Percentage contribution of each product
-- within its category.

WITH product_sales AS
(
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS product_sales

    FROM products p

    JOIN categories c
        ON p.category_id = c.category_id

    JOIN order_details od
        ON p.product_id = od.product_id

    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
)

SELECT
    category_name,
    product_id,
    product_name,

    ROUND(
        product_sales,
        2
    ) AS product_sales,

    ROUND(
        product_sales * 100.0
        / SUM(product_sales) OVER (
            PARTITION BY category_name
        ),
        2
    ) AS percentage_of_category_sales

FROM product_sales

ORDER BY
    category_name,
    percentage_of_category_sales DESC;


-- Q14. Highest-selling product for each year.

WITH yearly_product_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        p.product_id,
        p.product_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN products p
        ON od.product_id = p.product_id

    GROUP BY
        YEAR(o.order_date),
        p.product_id,
        p.product_name
),

ranked_products AS
(
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY net_sales DESC
        ) AS product_rank

    FROM yearly_product_sales
)

SELECT
    order_year AS year,
    product_id,
    product_name,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    product_rank

FROM ranked_products

WHERE product_rank = 1

ORDER BY year;


-- Q15. Top employee by sales in each year.

WITH employee_yearly_sales AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        e.employee_id,

        CONCAT(
            e.first_name,
            ' ',
            e.last_name
        ) AS employee_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN employees e
        ON o.employee_id = e.employee_id

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        YEAR(o.order_date),
        e.employee_id,
        e.first_name,
        e.last_name
),

ranked_employees AS
(
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY net_sales DESC
        ) AS sales_rank

    FROM employee_yearly_sales
)

SELECT
    order_year AS year,
    employee_id,
    employee_name,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    sales_rank

FROM ranked_employees

WHERE sales_rank = 1

ORDER BY year;
