/*
============================================================
NORTHWIND SQL ANALYSIS
04 - SALES ANALYSIS
============================================================

Topics:
- Transaction-level sales calculations
- Gross sales
- Discount amount
- Net sales
- Sales by year
- Sales by category
- Sales by product
- Sales by customer
- Sales by employee
- Top-N analysis

Sales formula:

Gross Sales
= unit_price * quantity

Discount Amount
= unit_price * quantity * discount

Net Sales
= unit_price * quantity * (1 - discount)

============================================================
*/


/*
============================================================
Q26. SALES VALUE FOR EACH ORDER DETAIL
============================================================

Calculate gross sales, discount amount and net sales for
every order-detail line.
*/

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
        od.unit_price
        * od.quantity
        * (1 - od.discount),
        2
    ) AS net_sales

FROM order_details od;


/*
============================================================
Q27. TOTAL SALES BY YEAR
============================================================

Calculate gross sales, discount amount and net sales
for every year.
*/

SELECT
    YEAR(o.order_date) AS order_year,

    ROUND(
        SUM(
            od.unit_price * od.quantity
        ),
        2
    ) AS gross_sales,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * od.discount
        ),
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


/*
============================================================
Q28. SALES BY CATEGORY
============================================================

Calculate net sales for every product category.
*/

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


/*
============================================================
Q29. SALES BY PRODUCT
============================================================

Calculate total quantity sold and net sales for every
product.
*/

SELECT
    p.product_id,
    p.product_name,

    SUM(od.quantity) AS total_quantity_sold,

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

ORDER BY net_sales DESC;


/*
============================================================
Q30. TOP 10 PRODUCTS BY NET SALES
============================================================
*/

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


/*
============================================================
Q31. SALES BY CUSTOMER
============================================================

Calculate total orders, quantity purchased and net sales
for each customer.
*/

SELECT
    c.customer_id,
    c.company_name,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(od.quantity) AS total_quantity,

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


/*
============================================================
Q32. SALES BY EMPLOYEE
============================================================

Calculate total orders and net sales handled by each
employee.
*/

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


/*
============================================================
Q33. DISCOUNT AMOUNT BY YEAR
============================================================

Calculate the total value given away through discounts
for each year.
*/

SELECT
    YEAR(o.order_date) AS order_year,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * od.discount
        ),
        2
    ) AS discount_amount

FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

GROUP BY YEAR(o.order_date)

ORDER BY order_year DESC;


/*
============================================================
Q34. AVERAGE ORDER VALUE
============================================================

Calculate the average net sales value per order.

Important:
First aggregate order-detail rows to order level.
Then calculate the average across orders.
*/

WITH order_sales AS
(
    SELECT
        o.order_id,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS order_value

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY o.order_id
)

SELECT
    ROUND(
        AVG(order_value),
        2
    ) AS average_order_value

FROM order_sales;


/*
============================================================
Q35. CUSTOMER AVERAGE ORDER VALUE
============================================================

Calculate the average order value for every customer.
*/

WITH order_sales AS
(
    SELECT
        o.order_id,
        o.customer_id,

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
        o.customer_id
)

SELECT
    c.customer_id,
    c.company_name,

    COUNT(os.order_id) AS total_orders,

    ROUND(
        AVG(os.order_value),
        2
    ) AS average_order_value

FROM customers c

JOIN order_sales os
    ON c.customer_id = os.customer_id

GROUP BY
    c.customer_id,
    c.company_name

ORDER BY average_order_value DESC;


/*
============================================================
Q36. CATEGORY DISCOUNT RATE
============================================================

Calculate gross sales, discount amount and effective
discount percentage for every category.
*/

SELECT
    c.category_id,
    c.category_name,

    ROUND(
        SUM(
            od.unit_price * od.quantity
        ),
        2
    ) AS gross_sales,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * od.discount
        ),
        2
    ) AS discount_amount,

    ROUND(
        SUM(
            od.unit_price
            * od.quantity
            * od.discount
        ) * 100.0
        / NULLIF(
            SUM(
                od.unit_price * od.quantity
            ),
            0
        ),
        2
    ) AS discount_percentage

FROM categories c

JOIN products p
    ON c.category_id = p.category_id

JOIN order_details od
    ON p.product_id = od.product_id

GROUP BY
    c.category_id,
    c.category_name

ORDER BY discount_percentage DESC;


/*
============================================================
Q37. TOP 10 CUSTOMERS BY NET SALES
============================================================
*/

SELECT
    c.customer_id,
    c.company_name,

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

ORDER BY net_sales DESC

LIMIT 10;


/*
============================================================
Q38. SALES BY COUNTRY
============================================================

Calculate total customers, orders and net sales by
customer country.
*/

SELECT
    c.country,

    COUNT(DISTINCT c.customer_id) AS total_customers,

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


/*
============================================================
Q39. MONTHLY SALES
============================================================

Calculate monthly net sales in chronological order.
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
Q40. HIGHEST-VALUE ORDER
============================================================

Find the order with the highest net sales value.

First aggregate order-detail rows to order level.
*/

WITH order_sales AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        SUM(
            od.unit_price
            * od.quantity
            * (1 - od.discount)
        ) AS net_sales

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
)

SELECT
    order_id,
    customer_id,
    order_date,

    ROUND(
        net_sales,
        2
    ) AS net_sales

FROM order_sales

ORDER BY net_sales DESC

LIMIT 1;
