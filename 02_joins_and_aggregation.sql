/*
============================================================
NORTHWIND SQL ANALYSIS
02 - JOINS AND AGGREGATION
============================================================

Topics:
- INNER JOIN
- Multi-table JOIN
- GROUP BY
- Aggregate functions
- UNION
- Date-based aggregation

============================================================
*/


/*
============================================================
Q10. PRODUCTS WITH SUPPLIER AND CATEGORY
============================================================

Show:
- Product name
- Supplier company name
- Category name

Tables:
products
suppliers
categories
*/

SELECT
    p.product_name,
    s.company_name,
    c.category_name
FROM products p
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
JOIN categories c
    ON p.category_id = c.category_id;


/*
============================================================
Q11. AVERAGE PRODUCT PRICE BY CATEGORY
============================================================

Show each category and its average product unit price.

Round the average to 2 decimal places.
*/

SELECT
    c.category_name,
    ROUND(AVG(p.unit_price), 2) AS average_unit_price
FROM categories c
JOIN products p
    ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY average_unit_price DESC;


/*
============================================================
Q12. CUSTOMERS AND SUPPLIERS
============================================================

Combine customers and suppliers into one result.

Create a relationship column identifying whether each row
comes from customers or suppliers.
*/

SELECT
    city,
    company_name,
    contact_name,
    'customers' AS relationship
FROM customers

UNION

SELECT
    city,
    company_name,
    contact_name,
    'suppliers' AS relationship
FROM suppliers;


/*
============================================================
Q13. MONTHLY ORDER VOLUME
============================================================

Show the total number of orders for every year/month.

Sort chronologically.
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
