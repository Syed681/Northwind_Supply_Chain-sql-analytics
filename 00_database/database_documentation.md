````markdown
# Northwind Database Documentation

## 1. Database Overview

Northwind is a relational database representing a business that sells products to customers through orders.

The database contains information about:

- Customers
- Orders
- Order details
- Products
- Categories
- Suppliers
- Employees
- Shippers
- Territories
- Regions

The database is suitable for practicing SQL joins, aggregations, subqueries, CTEs, window functions, ranking, time-series analysis, and business analytics.

---

# 2. Database Schema

## Categories

| Column | Data Type | Key |
|---|---|---|
| category_id | INT | PK |
| category_name | TEXT | |
| description | TEXT | |

---

## Products

| Column | Data Type | Key |
|---|---|---|
| product_id | INT | PK |
| product_name | TEXT | |
| supplier_id | INT | FK |
| category_id | INT | FK |
| quantity_per_unit | TEXT | |
| unit_price | DECIMAL | |
| units_in_stock | INT | |
| units_on_order | INT | |
| reorder_level | INT | |
| discontinued | INT | |

### Relationships

```text
products.supplier_id
        ↓
suppliers.supplier_id

products.category_id
        ↓
categories.category_id
````

---

## Suppliers

| Column        | Data Type | Key |
| ------------- | --------- | --- |
| supplier_id   | INT       | PK  |
| company_name  | TEXT      |     |
| contact_name  | TEXT      |     |
| contact_title | TEXT      |     |
| address       | TEXT      |     |
| city          | TEXT      |     |
| region        | TEXT      |     |
| postal_code   | TEXT      |     |
| country       | TEXT      |     |
| phone         | TEXT      |     |
| fax           | TEXT      |     |
| home_page     | TEXT      |     |

---

## Customers

| Column        | Data Type | Key |
| ------------- | --------- | --- |
| customer_id   | TEXT      | PK  |
| company_name  | TEXT      |     |
| contact_name  | TEXT      |     |
| contact_title | TEXT      |     |
| address       | TEXT      |     |
| city          | TEXT      |     |
| region        | TEXT      |     |
| postal_code   | TEXT      |     |
| country       | TEXT      |     |
| phone         | TEXT      |     |
| fax           | TEXT      |     |

---

## Orders

| Column           | Data Type | Key |
| ---------------- | --------- | --- |
| order_id         | INT       | PK  |
| customer_id      | TEXT      | FK  |
| employee_id      | INT       | FK  |
| order_date       | DATE      |     |
| required_date    | DATE      |     |
| shipped_date     | DATE      |     |
| ship_via         | INT       | FK  |
| freight          | DECIMAL   |     |
| ship_name        | TEXT      |     |
| ship_address     | TEXT      |     |
| ship_city        | TEXT      |     |
| ship_region      | TEXT      |     |
| ship_postal_code | TEXT      |     |
| ship_country     | TEXT      |     |

### Relationships

```text
orders.customer_id
        ↓
customers.customer_id

orders.employee_id
        ↓
employees.employee_id

orders.ship_via
        ↓
shippers.shipper_id
```

---

## Order Details

| Column     | Data Type | Key               |
| ---------- | --------- | ----------------- |
| order_id   | INT       | FK                |
| product_id | INT       | FK                |
| unit_price | DECIMAL   | Transaction price |
| quantity   | INT       |                   |
| discount   | DECIMAL   |                   |

### Relationships

```text
order_details.order_id
        ↓
orders.order_id

order_details.product_id
        ↓
products.product_id
```

> Note: `unit_price` is required for the sales-analysis queries in this repository. It represents the price recorded for the product on the order-detail transaction.

---

## Employees

| Column            | Data Type | Key |
| ----------------- | --------- | --- |
| employee_id       | INT       | PK  |
| last_name         | TEXT      |     |
| first_name        | TEXT      |     |
| title             | TEXT      |     |
| title_of_courtesy | TEXT      |     |
| birth_date        | DATE      |     |
| hire_date         | DATE      |     |
| address           | TEXT      |     |
| city              | TEXT      |     |
| region            | TEXT      |     |
| postal_code       | TEXT      |     |
| country           | TEXT      |     |
| home_phone        | TEXT      |     |
| extension         | TEXT      |     |
| reports_to        | INT       | FK  |

### Self-Referencing Relationship

```text
employees.reports_to
        ↓
employees.employee_id
```

This represents the employee-management hierarchy.

---

## Shippers

| Column       | Data Type | Key |
| ------------ | --------- | --- |
| shipper_id   | INT       | PK  |
| company_name | TEXT      |     |
| phone        | TEXT      |     |

---

## Employee Territories

| Column       | Data Type | Key |
| ------------ | --------- | --- |
| employee_id  | INT       | FK  |
| territory_id | TEXT      | FK  |

### Relationships

```text
employee_territories.employee_id
        ↓
employees.employee_id

employee_territories.territory_id
        ↓
territories.territory_id
```

---

## Territories

| Column                | Data Type | Key |
| --------------------- | --------- | --- |
| territory_id          | TEXT      | PK  |
| territory_description | TEXT      |     |
| region_id             | INT       | FK  |

### Relationship

```text
territories.region_id
        ↓
regions.region_id
```

---

## Regions

| Column             | Data Type | Key |
| ------------------ | --------- | --- |
| region_id          | INT       | PK  |
| region_description | TEXT      |     |

---

# 3. Entity Relationship Overview

```text
                    ┌──────────────┐
                    │  categories  │
                    └──────┬───────┘
                           │
                           │
                    ┌──────▼───────┐
                    │   products   │
                    └──────┬───────┘
                           │
                           │
                    ┌──────▼─────────┐
                    │ order_details  │
                    └──────┬─────────┘
                           │
                           │
                    ┌──────▼───────┐
                    │    orders    │
                    └──┬────┬───┬──┘
                       │    │   │
             ┌─────────┘    │   └──────────┐
             │              │              │
             ▼              ▼              ▼
       customers       employees       shippers
                            │
                            │
                     ┌──────▼──────────────┐
                     │ employee_territories│
                     └──────────┬─────────┘
                                │
                                ▼
                           territories
                                │
                                ▼
                             regions

products ───────────────► suppliers
```

---

# 4. Important Analytical Grain

Understanding table grain is important before writing analytical SQL.

## Orders

Approximate grain:

```text
One row = one customer order
```

Primary identifier:

```text
order_id
```

---

## Order Details

Approximate grain:

```text
One row = one product line within an order
```

Logical identifier:

```text
order_id + product_id
```

This is the main transactional table used for sales analysis.

---

## Products

```text
One row = one product
```

Primary identifier:

```text
product_id
```

---

## Customers

```text
One row = one customer
```

Primary identifier:

```text
customer_id
```

---

## Employees

```text
One row = one employee
```

Primary identifier:

```text
employee_id
```

---

# 5. Sales Calculation

For analytical sales queries, transaction-level sales are calculated using `order_details`.

### Gross Sales

```text
unit_price × quantity
```

### Discount Amount

```text
unit_price × quantity × discount
```

### Net Sales

```text
unit_price × quantity × (1 - discount)
```

SQL example:

```sql
SELECT
    ROUND(
        SUM(
            unit_price
            * quantity
            * (1 - discount)
        ),
        2
    ) AS net_sales
FROM order_details;
```

---

# 6. Main Analytical Join Path

The most important sales-analysis path is:

```text
customers
    ↓
orders
    ↓
order_details
    ↓
products
    ↓
categories
```

Example:

```sql
SELECT
    c.company_name,
    o.order_id,
    p.product_name,
    od.quantity,
    od.unit_price,
    od.discount
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_details od
    ON o.order_id = od.order_id
JOIN products p
    ON od.product_id = p.product_id;
```

---

# 7. Employee Sales Path

```text
employees
    ↓
orders
    ↓
order_details
```

This allows analysis of:

* Sales by employee
* Orders handled by employee
* Yearly employee performance
* Employee rankings
* Late shipment percentage

---

# 8. Shipping Analysis Path

```text
shippers
    ↓
orders
```

This allows analysis of:

* Orders handled by each shipper
* Freight
* Shipping delays
* Late shipment percentage
* Average freight by shipper

---

# 9. Product Analysis Path

```text
categories
    ↓
products
    ↓
order_details
```

This allows analysis of:

* Product sales
* Category sales
* Top products
* Top products within categories
* Product contribution to category sales
* Unsold products

---

# 10. Customer Analysis Path

```text
customers
    ↓
orders
    ↓
order_details
```

This allows analysis of:

* Total customer spending
* Number of orders
* Customer ranking
* Repeat customers
* Customer activity by year
* First and latest orders
* Customers with no orders

---

# 11. SQL Concepts Demonstrated

This project covers:

### Basic SQL

* SELECT
* WHERE
* ORDER BY
* LIMIT
* LIKE
* IN
* BETWEEN
* IS NULL

### Aggregation

* COUNT
* SUM
* AVG
* MIN
* MAX
* GROUP BY
* HAVING

### Joins

* INNER JOIN
* LEFT JOIN
* Multi-table joins
* Self joins

### Set Operations

* UNION

### Conditional Logic

* CASE WHEN

### Subqueries

* Scalar subqueries
* Correlated subqueries
* NOT EXISTS

### CTEs

* Single CTE
* Multiple CTEs
* Multi-stage analytical queries

### Window Functions

* ROW_NUMBER()
* RANK()
* DENSE_RANK()
* LAG()
* SUM() OVER()
* AVG() OVER()

### Analytical Techniques

* Top-N
* Top-N within groups
* Ranking
* Running totals
* Moving averages
* MoM growth
* YoY growth
* Percentage of total
* Percentage of category
* Above-average analysis
* First-event analysis
* Anti-joins

---

# 12. Repository Purpose

The purpose of this database documentation is to make the schema understandable before solving SQL problems.

The analytical process followed in this repository is:

```text
Understand Schema
      ↓
Identify Relationships
      ↓
Understand Table Grain
      ↓
Translate Business Question
      ↓
Choose Required Tables
      ↓
Join Tables
      ↓
Aggregate / Transform
      ↓
Apply Analytical Logic
      ↓
Validate Result
      ↓
Document Business Insight
```
