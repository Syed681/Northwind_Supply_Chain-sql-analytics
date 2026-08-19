/*
============================================================
NORTHWIND - ADVANCED ANALYTICAL SQL
============================================================

Purpose:
Solve higher-level business problems using advanced SQL.

Concepts:
- CTEs
- Window functions
- Ranking
- Top-N analysis
- Anti-joins
- NOT EXISTS
- Above-average analysis
- Percentage contribution
- Customer analysis
- Product analysis
- Employee analysis
- Shipping analysis

============================================================
*/


-- Q1. Top 10 customers by total spending.

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
    ) AS total_spending

FROM customer_sales

ORDER BY total_spending DESC

LIMIT 10;


-- Q2. Top 3 customers within each country.

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
),

ranked_customers AS
(
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_spending DESC
        ) AS customer_rank

    FROM customer_sales
)

SELECT
    country,
    customer_id,
    company_name,

    ROUND(
        total_spending,
        2
    ) AS total_spending,

    customer_rank

FROM ranked_customers

WHERE customer_rank <= 3

ORDER BY
    country,
    customer_rank;


-- Q3. Customers whose spending is above
-- the average customer spending.

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
),

average_spending AS
(
    SELECT
        AVG(total_spending) AS avg_spending

    FROM customer_sales
)

SELECT
    cs.customer_id,
    cs.company_name,

    ROUND(
        cs.total_spending,
        2
    ) AS total_spending,

    ROUND(
        a.avg_spending,
        2
    ) AS average_customer_spending

FROM customer_sales cs

CROSS JOIN average_spending a

WHERE cs.total_spending > a.avg_spending

ORDER BY cs.total_spending DESC;


-- Q4. Customers who have never placed an order.

SELECT
    c.customer_id,
    c.company_name,
    c.country

FROM customers c

WHERE NOT EXISTS
(
    SELECT 1

    FROM orders o

    WHERE o.customer_id = c.customer_id
)

ORDER BY c.company_name;


-- Q5. Products that have never been ordered.

SELECT
    p.product_id,
    p.product_name

FROM products p

WHERE NOT EXISTS
(
    SELECT 1

    FROM order_details od

    WHERE od.product_id = p.product_id
)

ORDER BY p.product_name;


-- Q6. Top 3 products within each category.

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

    ROUND(
        net_sales,
        2
    ) AS net_sales,

    category_rank

FROM ranked_products

WHERE category_rank <= 3

ORDER BY
    category_name,
    category_rank;


-- Q7. Products whose sales are above
-- the average product sales.

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
        AVG(net_sales) AS avg_sales

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
        a.avg_sales,
        2
    ) AS average_product_sales

FROM product_sales ps

CROSS JOIN average_sales a

WHERE ps.net_sales > a.avg_sales

ORDER BY ps.net_sales DESC;


-- Q8. Category contribution to total sales.

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


-- Q9. Products contributing more than 5%
-- of their category's sales.

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
),

category_totals AS
(
    SELECT
        *,
        SUM(product_sales) OVER (
            PARTITION BY category_name
        ) AS category_total_sales

    FROM product_sales
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
        category_total_sales,
        2
    ) AS category_total_sales,

    ROUND(
        product_sales * 100.0
        / NULLIF(category_total_sales, 0),
        2
    ) AS category_sales_percentage

FROM category_totals

WHERE product_sales * 100.0
      / NULLIF(category_total_sales, 0) > 5

ORDER BY
    category_name,
    category_sales_percentage DESC;


-- Q10. Highest-selling product in each year.

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


-- Q11. Top employee by sales in each year.

WITH employee_sales AS
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

    FROM employee_sales
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


-- Q12. Employee late-shipment percentage.

SELECT
    e.employee_id,

    CONCAT(
        e.first_name,
        ' ',
        e.last_name
    ) AS employee_name,

    COUNT(o.order_id) AS total_orders,

    SUM(
        CASE
            WHEN o.shipped_date > o.required_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN o.shipped_date > o.required_date
                THEN 1
                ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(o.order_id), 0),
        2
    ) AS late_percentage

FROM employees e

JOIN orders o
    ON e.employee_id = o.employee_id

GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name

ORDER BY late_percentage DESC;


-- Q13. Average shipping delay by shipper.

SELECT
    s.shipper_id,
    s.company_name AS shipper,

    COUNT(o.order_id) AS total_orders,

    ROUND(
        AVG(
            DATEDIFF(
                o.shipped_date,
                o.required_date
            )
        ),
        2
    ) AS average_delay_days

FROM shippers s

JOIN orders o
    ON s.shipper_id = o.ship_via

WHERE o.shipped_date IS NOT NULL

GROUP BY
    s.shipper_id,
    s.company_name

ORDER BY average_delay_days DESC;


-- Q14. Countries with the highest average freight.

SELECT
    ship_country,

    COUNT(order_id) AS total_orders,

    ROUND(
        AVG(freight),
        2
    ) AS average_freight

FROM orders

GROUP BY ship_country

ORDER BY average_freight DESC;


-- Q15. Customers active in at least 3 different years.

SELECT
    c.customer_id,
    c.company_name,

    COUNT(
        DISTINCT YEAR(o.order_date)
    ) AS active_years

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.company_name

HAVING COUNT(
    DISTINCT YEAR(o.order_date)
) >= 3

ORDER BY active_years DESC;


-- Q16. Customers with more than 5 orders.

SELECT
    c.customer_id,
    c.company_name,

    COUNT(o.order_id) AS total_orders

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.company_name

HAVING COUNT(o.order_id) > 5

ORDER BY total_orders DESC;


-- Q17. First and most recent order for each customer.

SELECT
    c.customer_id,
    c.company_name,

    MIN(o.order_date) AS first_order_date,

    MAX(o.order_date) AS latest_order_date

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.company_name

ORDER BY latest_order_date DESC;


-- Q18. First product purchased by each customer.

WITH customer_products AS
(
    SELECT
        c.customer_id,
        c.company_name,
        o.order_id,
        o.order_date,
        p.product_id,
        p.product_name,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY
                o.order_date,
                o.order_id,
                p.product_id
        ) AS purchase_sequence

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN products p
        ON od.product_id = p.product_id
)

SELECT
    customer_id,
    company_name,
    order_id,
    order_date,
    product_id,
    product_name

FROM customer_products

WHERE purchase_sequence = 1

ORDER BY company_name;


-- Q19. Products ordered by the highest number
-- of different customers.

SELECT
    p.product_id,
    p.product_name,

    COUNT(
        DISTINCT o.customer_id
    ) AS unique_customers

FROM products p

JOIN order_details od
    ON p.product_id = od.product_id

JOIN orders o
    ON od.order_id = o.order_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY unique_customers DESC;


-- Q20. Customers who purchased products
-- from at least 3 different categories.

SELECT
    c.customer_id,
    c.company_name,

    COUNT(
        DISTINCT p.category_id
    ) AS categories_purchased

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_details od
    ON o.order_id = od.order_id

JOIN products p
    ON od.product_id = p.product_id

GROUP BY
    c.customer_id,
    c.company_name

HAVING COUNT(
    DISTINCT p.category_id
) >= 3

ORDER BY categories_purchased DESC;


-- Q21. Average order value by year.

WITH order_values AS
(
    SELECT
        o.order_id,
        YEAR(o.order_date) AS order_year,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS order_value

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        o.order_id,
        YEAR(o.order_date)
)

SELECT
    order_year AS year,

    ROUND(
        AVG(order_value),
        2
    ) AS average_order_value

FROM order_values

GROUP BY order_year

ORDER BY year;


-- Q22. Highest-value order for each year.

WITH order_values AS
(
    SELECT
        o.order_id,
        YEAR(o.order_date) AS order_year,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS order_value

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        o.order_id,
        YEAR(o.order_date)
),

ranked_orders AS
(
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY order_value DESC
        ) AS order_rank

    FROM order_values
)

SELECT
    order_year AS year,
    order_id,

    ROUND(
        order_value,
        2
    ) AS order_value,

    order_rank

FROM ranked_orders

WHERE order_rank = 1

ORDER BY year;


-- Q23. Customers whose first order occurred
-- before the overall average first-order date.

WITH customer_first_orders AS
(
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date

    FROM orders

    GROUP BY customer_id
),

average_first_order AS
(
    SELECT
        AVG(
            DATEDIFF(
                first_order_date,
                '1990-01-01'
            )
        ) AS average_days

    FROM customer_first_orders
)

SELECT
    cfo.customer_id,
    cfo.first_order_date

FROM customer_first_orders cfo

CROSS JOIN average_first_order a

WHERE DATEDIFF(
    cfo.first_order_date,
    '1990-01-01'
) < a.average_days

ORDER BY cfo.first_order_date;


-- Q24. Orders containing more than 3 different products.

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,

    COUNT(
        DISTINCT od.product_id
    ) AS different_products

FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date

HAVING COUNT(
    DISTINCT od.product_id
) > 3

ORDER BY different_products DESC;


-- Q25. Products responsible for more than 50%
-- of their category's total sales.

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
),

category_totals AS
(
    SELECT
        *,
        SUM(product_sales) OVER (
            PARTITION BY category_name
        ) AS category_total_sales

    FROM product_sales
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
        category_total_sales,
        2
    ) AS category_total_sales,

    ROUND(
        product_sales * 100.0
        / NULLIF(category_total_sales, 0),
        2
    ) AS category_contribution_percentage

FROM category_totals

WHERE product_sales * 100.0
      / NULLIF(category_total_sales, 0) > 50

ORDER BY
    category_name,
    category_contribution_percentage DESC;
