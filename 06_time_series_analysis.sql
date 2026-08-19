/*
============================================================
NORTHWIND SQL ANALYSIS
06 - TIME SERIES ANALYSIS
============================================================

Topics:
- Yearly sales
- Monthly sales
- MoM growth
- YoY growth
- Running yearly sales
- Moving averages
- Year-over-year monthly comparison
============================================================
*/


/*
============================================================
Q1. Total orders by year
============================================================
*/

SELECT
    YEAR(order_date) AS order_year,
    COUNT(*) AS total_orders

FROM orders

GROUP BY YEAR(order_date)

ORDER BY order_year;


/*
============================================================
Q2. Total orders by year and month
============================================================
*/

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS total_orders

FROM orders

GROUP BY
    YEAR(order_date),
    MONTH(order_date)

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q3. Monthly net sales
============================================================
*/

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


/*
============================================================
Q4. Yearly net sales
============================================================
*/

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


/*
============================================================
Q5. Monthly net sales with previous month
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
Q6. Month-over-month sales growth
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

FROM sales_comparison

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q7. Year-over-year sales growth
============================================================
*/

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

sales_comparison AS
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
    order_year,

    ROUND(net_sales, 2) AS net_sales,

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

FROM sales_comparison

ORDER BY order_year;


/*
============================================================
Q8. Three-month moving average
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


/*
============================================================
Q9. Cumulative sales within each year
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
    ) AS cumulative_yearly_sales

FROM monthly_sales

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q10. Compare each month's sales with the same month
     of the previous year
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

    ROUND(net_sales, 2) AS current_month_sales,

    ROUND(
        LAG(net_sales, 12) OVER (
            ORDER BY order_year, order_month
        ),
        2
    ) AS same_month_previous_year

FROM monthly_sales

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q11. Monthly YoY growth percentage
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

year_comparison AS
(
    SELECT
        order_year,
        order_month,
        net_sales,

        LAG(net_sales, 12) OVER (
            ORDER BY order_year, order_month
        ) AS previous_year_sales

    FROM monthly_sales
)

SELECT
    order_year,
    order_month,

    ROUND(net_sales, 2) AS net_sales,

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

FROM year_comparison

ORDER BY
    order_year,
    order_month;


/*
============================================================
Q12. Highest-sales month for each year
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

ranked_months AS
(
    SELECT
        order_year,
        order_month,
        net_sales,

        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY net_sales DESC
        ) AS sales_rank

    FROM monthly_sales
)

SELECT
    order_year,
    order_month,

    ROUND(net_sales, 2) AS net_sales,

    sales_rank

FROM ranked_months

WHERE sales_rank = 1

ORDER BY order_year;


/*
============================================================
Q13. Lowest-sales month for each year
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

ranked_months AS
(
    SELECT
        order_year,
        order_month,
        net_sales,

        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY net_sales ASC
        ) AS sales_rank

    FROM monthly_sales
)

SELECT
    order_year,
    order_month,

    ROUND(net_sales, 2) AS net_sales,

    sales_rank

FROM ranked_months

WHERE sales_rank = 1

ORDER BY order_year;
