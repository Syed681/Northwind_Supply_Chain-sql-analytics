````markdown
# Northwind Database Documentation

## Overview

Northwind is a transactional sales database used to analyze customers,
orders, products, employees, suppliers, categories, and shipping operations.

The database follows a relational structure where orders connect customers,
employees, shippers, and order details. Order details connect individual
products to each order.

---

## Core Tables

### customers

Stores customer information.

Primary Key:
- customer_id

Important columns:
- company_name
- contact_name
- city
- country

---

### orders

Stores customer orders.

Primary Key:
- order_id

Foreign Keys:
- customer_id → customers.customer_id
- employee_id → employees.employee_id
- ship_via → shippers.shipper_id

Important columns:
- order_date
- required_date
- shipped_date
- freight
- ship_country

---

### order_details

Stores individual products included in each order.

Foreign Keys:
- order_id → orders.order_id
- product_id → products.product_id

Important columns:
- quantity
- discount
- unit_price

> Note: `unit_price` is required for sales/revenue calculations and is
> present in the working Northwind database used for this project.

---

### products

Stores product information.

Primary Key:
- product_id

Foreign Keys:
- supplier_id → suppliers.supplier_id
- category_id → categories.category_id

Important columns:
- product_name
- unit_price
- units_in_stock
- units_on_order
- reorder_level
- discontinued

---

### categories

Stores product categories.

Primary Key:
- category_id

Important columns:
- category_name
- description

---

### suppliers

Stores supplier information.

Primary Key:
- supplier_id

Important columns:
- company_name
- contact_name
- city
- country

---

### employees

Stores employee information.

Primary Key:
- employee_id

Foreign Keys:
- reports_to → employees.employee_id

The `reports_to` relationship is self-referencing.

---

### shippers

Stores shipping company information.

Primary Key:
- shipper_id

---

### employee_territories

Bridge table connecting employees and territories.

Foreign Keys:
- employee_id → employees.employee_id
- territory_id → territories.territory_id

---

### territories

Stores territory information.

Primary Key:
- territory_id

Foreign Key:
- region_id → regions.region_id

---

### regions

Stores regional information.

Primary Key:
- region_id

---

# Main Relationships

customers
↓
orders
↓
order_details
↓
products
↓
categories

products
↓
suppliers

orders
↓
employees

orders
↓
shippers

employees
↓
employee_territories
↓
territories
↓
regions

employees
↓
employees
(reports_to)

---

# Sales Data Flow

The main analytical sales path is:

orders
→ order_details
→ products
→ categories

Customer analysis:

customers
→ orders
→ order_details

Employee analysis:

employees
→ orders
→ order_details

Shipping analysis:

shippers
→ orders

---

# Sales Calculation

For each order detail:

### Gross Sales

```text
unit_price × quantity
````

### Discount Amount

```text
unit_price × quantity × discount
```

### Net Sales

```text
unit_price × quantity × (1 - discount)
```

Historical transaction price should be taken from:

```text
order_details.unit_price
```

rather than the current `products.unit_price`.

---

# Important SQL Concepts Demonstrated

This database supports analysis involving:

* Filtering
* Aggregation
* Joins
* Subqueries
* CTEs
* CASE expressions
* Window functions
* Ranking
* Time-series analysis
* Running totals
* Moving averages
* MoM growth
* YoY growth
* Customer analysis
* Product analysis
* Employee performance
* Shipping analysis
* Business metrics

---

# Data Grain

## orders

One row represents one customer order.

## order_details

One row represents one product line within an order.

Therefore:

```text
One order
    ↓
Multiple order_detail rows
    ↓
Each row represents one product within that order
```
