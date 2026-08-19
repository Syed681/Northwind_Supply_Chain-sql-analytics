/*
============================================================
NORTHWIND SQL ANALYSIS
01 - BASIC QUERIES
============================================================

Topics:
- SELECT
- WHERE
- NOT IN
- DATE filtering
- NULL handling
- LIKE
- ORDER BY
- LIMIT
- Arithmetic filtering
- Aggregate functions

============================================================
*/


/*
============================================================
Q1. CATEGORY INFORMATION
============================================================

Show category_name and description from the categories
table, sorted alphabetically by category_name.
*/

SELECT
    category_name,
    description
FROM categories
ORDER BY category_name;


/*
============================================================
Q2. CUSTOMERS EXCLUDING SPECIFIC COUNTRIES
============================================================

Show contact_name, address and city for customers who are
not from Germany, Mexico or Spain.
*/

SELECT
    contact_name,
    address,
    city
FROM customers
WHERE country NOT IN ('Germany', 'Mexico', 'Spain');


/*
============================================================
Q3. ORDERS PLACED ON A SPECIFIC DATE
============================================================

Show order_date, shipped_date, customer_id and freight
for orders placed on 2018-02-26.
*/

SELECT
    order_date,
    shipped_date,
    customer_id,
    freight
FROM orders
WHERE order_date = '2018-02-26';


/*
============================================================
Q4. ORDERS SHIPPED AFTER REQUIRED DATE
============================================================

Identify orders where the actual shipment occurred after
the required shipment date.
*/

SELECT
    employee_id,
    order_id,
    customer_id,
    required_date,
    shipped_date
FROM orders
WHERE shipped_date > required_date;


/*
============================================================
Q5. EVEN-NUMBERED ORDERS
============================================================

Show all even-numbered order IDs.
*/

SELECT
    order_id
FROM orders
WHERE order_id % 2 = 0;


/*
============================================================
Q6. CUSTOMERS FROM CITIES CONTAINING 'L'
============================================================

Show city, company_name and contact_name for customers whose
city contains the letter L.

Sort by contact_name.
*/

SELECT
    city,
    company_name,
    contact_name
FROM customers
WHERE city LIKE '%L%'
ORDER BY contact_name;


/*
============================================================
Q7. CUSTOMERS WITH A FAX NUMBER
============================================================

Show customers where the fax number is available.
*/

SELECT
    company_name,
    contact_name,
    fax
FROM customers
WHERE fax IS NOT NULL;


/*
============================================================
Q8. MOST RECENTLY HIRED EMPLOYEE
============================================================

Return the employee with the most recent hire date.
*/

SELECT
    first_name,
    last_name,
    hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 1;


/*
============================================================
Q9. PRODUCT SUMMARY
============================================================

Calculate:
- Average unit price
- Total units in stock
- Total discontinued products

Average price should be rounded to 2 decimal places.
*/

SELECT
    ROUND(AVG(unit_price), 2) AS average_price,
    SUM(units_in_stock) AS total_stock,
    SUM(discontinued) AS total_discontinued
FROM products;
