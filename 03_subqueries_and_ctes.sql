/*
============================================================
NORTHWIND SQL ANALYSIS
03 - SUBQUERIES AND CTEs
============================================================

Topics:
- Scalar subqueries
- Correlated subqueries
- Common Table Expressions (CTEs)
- Multi-step analysis
- Comparing entities against averages
- EXISTS / NOT EXISTS

============================================================
*/


/*
============================================================
Q16. PRODUCTS ABOVE THE OVERALL AVERAGE PRICE
============================================================

Find products whose unit price is greater than the average
unit price of all products.
*/

SELECT
    product_id,
    product_name,
    unit_price
FROM products
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM products
)
ORDER BY unit_price DESC;


/*
============================================================
Q17. CUSTOMERS WITH MORE ORDERS THAN THE AVERAGE CUSTOMER
============================================================

First calculate the number of orders for each customer.

Then return customers whose order count is greater than
the average customer order count.
*/

WITH customer_orders AS
(
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
),

average_orders AS
(
    SELECT
        AVG(total_orders) AS average_order_count
    FROM customer_orders
)

SELECT
    co.customer_id,
    co.total_orders,
    ao.average_order_count
FROM customer_orders co
CROSS JOIN average_orders ao
WHERE co.total_orders > ao.average_order_count
ORDER BY co.total_orders DESC;


/*
============================================================
Q18. CUSTOMERS WITH AT LEAST 3 ORDERS
============================================================

Use a CTE to calculate customer order counts and return
customers with three or more orders.
*/

WITH customer_orders AS
(
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_orders
FROM customer_orders
WHERE total_orders >= 3
ORDER BY total_orders DESC;


/*
============================================================
Q19. PRODUCTS THAT HAVE NEVER BEEN ORDERED
============================================================

Use NOT EXISTS to identify products that do not appear
in order_details.
*/

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


/*
============================================================
Q20. CUSTOMERS WHO HAVE NEVER PLACED AN ORDER
============================================================

Use NOT EXISTS to identify customers who have no matching
record in orders.
*/

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


/*
============================================================
Q21. CATEGORY WITH THE HIGHEST AVERAGE PRODUCT PRICE
============================================================

Calculate average product price for every category and
return the category with the highest average.
*/

WITH category_prices AS
(
    SELECT
        c.category_id,
        c.category_name,
        AVG(p.unit_price) AS average_price
    FROM categories c
    JOIN products p
        ON c.category_id = p.category_id
    GROUP BY
        c.category_id,
        c.category_name
)

SELECT
    category_id,
    category_name,
    ROUND(average_price, 2) AS average_price
FROM category_prices
ORDER BY average_price DESC
LIMIT 1;


/*
============================================================
Q22. CUSTOMER FIRST AND LAST ORDER
============================================================

Use a CTE to calculate the first and latest order date
for every customer.
*/

WITH customer_order_dates AS
(
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS latest_order_date
    FROM orders
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.company_name,
    cod.first_order_date,
    cod.latest_order_date
FROM customers c
JOIN customer_order_dates cod
    ON c.customer_id = cod.customer_id
ORDER BY cod.latest_order_date DESC;


/*
============================================================
Q23. CUSTOMERS WHO ORDERED IN MULTIPLE YEARS
============================================================

Identify customers who placed orders in at least three
different calendar years.
*/

WITH customer_years AS
(
    SELECT
        customer_id,
        COUNT(DISTINCT YEAR(order_date)) AS active_years
    FROM orders
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.company_name,
    cy.active_years
FROM customers c
JOIN customer_years cy
    ON c.customer_id = cy.customer_id
WHERE cy.active_years >= 3
ORDER BY cy.active_years DESC;


/*
============================================================
Q24. PRODUCTS ABOVE THEIR CATEGORY AVERAGE PRICE
============================================================

Compare every product against the average price of its
own category.
*/

WITH category_average AS
(
    SELECT
        category_id,
        AVG(unit_price) AS average_category_price
    FROM products
    GROUP BY category_id
)

SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price,
    ROUND(ca.average_category_price, 2)
        AS average_category_price
FROM products p
JOIN category_average ca
    ON p.category_id = ca.category_id
WHERE p.unit_price > ca.average_category_price
ORDER BY
    p.category_id,
    p.unit_price DESC;


/*
============================================================
Q25. EMPLOYEES WITH ABOVE-AVERAGE ORDER VOLUME
============================================================

Calculate total orders handled by each employee.

Return employees whose order count is above the average
employee order count.
*/

WITH employee_orders AS
(
    SELECT
        employee_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY employee_id
),

average_employee_orders AS
(
    SELECT
        AVG(total_orders) AS average_orders
    FROM employee_orders
)

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    eo.total_orders,
    ROUND(aeo.average_orders, 2)
        AS average_employee_orders
FROM employee_orders eo
JOIN employees e
    ON eo.employee_id = e.employee_id
CROSS JOIN average_employee_orders aeo
WHERE eo.total_orders > aeo.average_orders
ORDER BY eo.total_orders DESC;
