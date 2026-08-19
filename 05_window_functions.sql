/*
============================================================
NORTHWIND SQL ANALYSIS
04 - WINDOW FUNCTIONS
============================================================

Topics:
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- PARTITION BY
- LAG()
- Running totals
- Top-N analysis
============================================================
*/


/*
============================================================
Q1. Rank customers by total spending
============================================================
*/

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
    ROUND(total_spending, 2) AS total_spending,

    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank

FROM customer_sales

ORDER BY spending_rank;


/*
============================================================
Q2. Rank products by total sales
============================================================
*/

WITH product_sales AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS total_sales

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
    ROUND(total_sales, 2) AS total_sales,

    DENSE_RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank

FROM product_sales

ORDER BY sales_rank;


/*
============================================================
Q3. Rank products within each category
============================================================
*/

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
        ) AS total_sales

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
    ROUND(total_sales, 2) AS total_sales,

    DENSE_RANK() OVER (
        PARTITION BY category_name
        ORDER BY total_sales DESC
    ) AS category_rank

FROM product_sales

ORDER BY
    category_name,
    category_rank;


/*
============================================================
Q4. Top 3 products in each category
============================================================
*/

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
        ) AS total_sales

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
            ORDER BY total_sales DESC
        ) AS category_rank

    FROM product_sales
)

SELECT
    category_name,
    product_id,
    product_name,
    ROUND(total_sales, 2) AS total_sales,
    category_rank

FROM ranked_products

WHERE category_rank <= 3

ORDER BY
    category_name,
    category_rank;


/*
============================================================
Q5. Number each customer's orders chronologically
============================================================
*/

SELECT
    customer_id,
    order_id,
    order_date,

    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS order_sequence

FROM orders

ORDER BY
    customer_id,
    order_sequence;


/*
============================================================
Q6. Find each customer's first order
============================================================
*/

WITH ranked_orders AS
(
    SELECT
        customer_id,
        order_id,
        order_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS order_sequence

    FROM orders
)

SELECT
    customer_id,
    order_id,
    order_date

FROM ranked_orders

WHERE order_sequence = 1

ORDER BY order_date;


/*
============================================================
Q7. Find each customer's most recent order
============================================================
*/

WITH ranked_orders AS
(
    SELECT
        customer_id,
        order_id,
        order_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS order_sequence

    FROM orders
)

SELECT
    customer_id,
    order_id,
    order_date

FROM ranked_orders

WHERE order_sequence = 1

ORDER BY order_date DESC;


/*
============================================================
Q8. Monthly sales with previous month's sales
============================================================
*/

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
    order_year,
    order_month,

    ROUND(net_sales, 2) AS net_sales,

    ROUND(
        LAG(net_sales) OVER (
            ORDER BY order_year, order_month
        ),
        2
    ) AS previous_month_sales

FROM monthly_sales

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q9. Monthly sales growth percentage
============================================================
*/

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

sales_comparison AS
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
    order_year,
    order_month,

    ROUND(net_sales, 2) AS net_sales,

    ROUND(
        (
            (net_sales - previous_month_sales)
            / NULLIF(previous_month_sales, 0)
        ) * 100,
        2
    ) AS mom_growth_percentage

FROM sales_comparison

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q10. Running total of monthly sales
============================================================
*/

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
    order_year,
    order_month,

    ROUND(net_sales, 2) AS monthly_sales,

    ROUND(
        SUM(net_sales) OVER (
            ORDER BY order_year, order_month
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
        ),
        2
    ) AS running_total_sales

FROM monthly_sales

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q11. Running yearly sales
============================================================
*/

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
    order_year,
    order_month,

    ROUND(net_sales, 2) AS monthly_sales,

    ROUND(
        SUM(net_sales) OVER (
            PARTITION BY order_year
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
        ),
        2
    ) AS yearly_running_total

FROM monthly_sales

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q12. Three-month moving average of sales
============================================================
*/

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
    order_year,
    order_month,

    ROUND(net_sales, 2) AS monthly_sales,

    ROUND(
        AVG(net_sales) OVER (
            ORDER BY order_year, order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average

FROM monthly_sales

ORDER BY
    order_year,
    order_month;
