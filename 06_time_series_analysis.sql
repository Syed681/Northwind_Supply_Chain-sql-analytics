/*
============================================================
NORTHWIND - TIME SERIES ANALYSIS
============================================================

Purpose:
Analyze sales trends over time.

Key Concepts:
- Yearly analysis
- Monthly analysis
- Quarterly analysis
- MoM growth
- YoY growth
- Running totals
- Moving averages
- Period comparison

============================================================
*/


-- Q1. Total sales by year.

SELECT
    YEAR(o.order_date) AS order_year,

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


-- Q2. Total sales by year and month.

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


-- Q3. Total sales by quarter.

SELECT
    YEAR(o.order_date) AS order_year,
    QUARTER(o.order_date) AS quarter_number,

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
    QUARTER(o.order_date)

ORDER BY
    order_year,
    quarter_number;


-- Q4. Month-over-month sales growth.

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
            ORDER BY
                order_year,
                order_month
        ) AS previous_month_sales

    FROM monthly_sales
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

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

ORDER BY
    year,
    month;


-- Q5. Year-over-year sales growth.

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


-- Q6. Running total of monthly sales.

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
            ORDER BY
                order_year,
                order_month
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
        ),
        2
    ) AS cumulative_sales

FROM monthly_sales

ORDER BY
    year,
    month;


-- Q7. Running sales within each year.

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
    ) AS yearly_running_sales

FROM monthly_sales

ORDER BY
    year,
    month;


-- Q8. Three-month moving average.

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
            ORDER BY
                order_year,
                order_month
            ROWS BETWEEN 2 PRECEDING
                 AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average

FROM monthly_sales

ORDER BY
    year,
    month;


-- Q9. Compare each month's sales against
-- the average sales for that year.

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
            PARTITION BY order_year
        ),
        2
    ) AS yearly_average_sales,

    ROUND(
        net_sales
        - AVG(net_sales) OVER (
            PARTITION BY order_year
        ),
        2
    ) AS difference_from_yearly_average

FROM monthly_sales

ORDER BY
    year,
    month;


-- Q10. Identify the highest-sales month in each year.

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

ranked_months AS
(
    SELECT
        order_year,
        order_month,
        net_sales,

        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY net_sales DESC
        ) AS month_rank

    FROM monthly_sales
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    month_rank

FROM ranked_months

WHERE month_rank = 1

ORDER BY year;


-- Q11. Identify the lowest-sales month in each year.

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

ranked_months AS
(
    SELECT
        order_year,
        order_month,
        net_sales,

        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY net_sales
        ) AS month_rank

    FROM monthly_sales
)

SELECT
    order_year AS year,
    order_month AS month,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    month_rank

FROM ranked_months

WHERE month_rank = 1

ORDER BY year;


-- Q12. Calculate yearly sales and the difference
-- from the previous year.

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
)

SELECT
    order_year AS year,

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    ROUND(
        LAG(net_sales) OVER (
            ORDER BY order_year
        ),
        2
    ) AS previous_year_sales,

    ROUND(
        net_sales
        - LAG(net_sales) OVER (
            ORDER BY order_year
        ),
        2
    ) AS sales_difference

FROM yearly_sales

ORDER BY year;
