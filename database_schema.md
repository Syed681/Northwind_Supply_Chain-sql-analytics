````markdown
# Northwind Database Schema

## Overview

Northwind is a transactional relational database representing the
operations of a fictional trading company.

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

The main transaction flow is:

```text
Customers
    |
    v
Orders
    |
    v
Order Details
    |
    v
Products
    |
    +----> Categories
    |
    +----> Suppliers
````

Orders are additionally connected to:

```text
Orders
   |
   +----> Employees
   |
   +----> Shippers
```

Employee geographic relationships:

```text
Employees
    |
    v
Employee Territories
    |
    v
Territories
    |
    v
Regions
```

---

# Tables

## 1. categories

Stores product category information.

| Column        | Type | Key |
| ------------- | ---- | --- |
| category_id   | INT  | PK  |
| category_name | TEXT |     |
| description   | TEXT |     |

---

## 2. products

Stores information about products sold by the company.

| Column            | Type    | Key |
| ----------------- | ------- | --- |
| product_id        | INT     | PK  |
| product_name      | TEXT    |     |
| supplier_id       | INT     | FK  |
| category_id       | INT     | FK  |
| quantity_per_unit | TEXT    |     |
| unit_price        | DECIMAL |     |
| units_in_stock    | INT     |     |
| units_on_order    | INT     |     |
| reorder_level     | INT     |     |
| discontinued      | INT     |     |

### Relationships

```text
products.supplier_id
        ↓
suppliers.supplier_id
```

```text
products.category_id
        ↓
categories.category_id
```

---

## 3. suppliers

Stores supplier information.

| Column        | Type | Key |
| ------------- | ---- | --- |
| supplier_id   | INT  | PK  |
| company_name  | TEXT |     |
| contact_name  | TEXT |     |
| contact_title | TEXT |     |
| address       | TEXT |     |
| city          | TEXT |     |
| region        | TEXT |     |
| postal_code   | TEXT |     |
| country       | TEXT |     |
| phone         | TEXT |     |
| fax           | TEXT |     |
| home_page     | TEXT |     |

---

## 4. customers

Stores customer information.

| Column        | Type | Key |
| ------------- | ---- | --- |
| customer_id   | TEXT | PK  |
| company_name  | TEXT |     |
| contact_name  | TEXT |     |
| contact_title | TEXT |     |
| address       | TEXT |     |
| city          | TEXT |     |
| region        | TEXT |     |
| postal_code   | TEXT |     |
| country       | TEXT |     |
| phone         | TEXT |     |
| fax           | TEXT |     |

---

## 5. orders

Stores order-level transaction information.

| Column           | Type    | Key |
| ---------------- | ------- | --- |
| order_id         | INT     | PK  |
| customer_id      | TEXT    | FK  |
| employee_id      | INT     | FK  |
| order_date       | DATE    |     |
| required_date    | DATE    |     |
| shipped_date     | DATE    |     |
| ship_via         | INT     | FK  |
| freight          | DECIMAL |     |
| ship_name        | TEXT    |     |
| ship_address     | TEXT    |     |
| ship_city        | TEXT    |     |
| ship_region      | TEXT    |     |
| ship_postal_code | TEXT    |     |
| ship_country     | TEXT    |     |

### Relationships

```text
orders.customer_id
        ↓
customers.customer_id
```

```text
orders.employee_id
        ↓
employees.employee_id
```

```text
orders.ship_via
        ↓
shippers.shipper_id
```

---

## 6. order_details

Stores individual product lines within orders.

| Column     | Type    | Key |
| ---------- | ------- | --- |
| order_id   | INT     | FK  |
| product_id | INT     | FK  |
| quantity   | INT     |     |
| unit_price | DECIMAL |     |
| discount   | DECIMAL |     |

### Relationships

```text
order_details.order_id
        ↓
orders.order_id
```

```text
order_details.product_id
        ↓
products.product_id
```

### Important Note

`unit_price` is included because sales analysis requires the actual
transaction-level selling price.

The `order_details` table therefore supports calculations such as:

```text
Gross Sales
= unit_price × quantity
```

```text
Discount Amount
= unit_price × quantity × discount
```

```text
Net Sales
= unit_price × quantity × (1 - discount)
```

---

## 7. employees

Stores employee information.

| Column            | Type | Key |
| ----------------- | ---- | --- |
| employee_id       | INT  | PK  |
| last_name         | TEXT |     |
| first_name        | TEXT |     |
| title             | TEXT |     |
| title_of_courtesy | TEXT |     |
| birth_date        | DATE |     |
| hire_date         | DATE |     |
| address           | TEXT |     |
| city              | TEXT |     |
| region            | TEXT |     |
| postal_code       | TEXT |     |
| country           | TEXT |     |
| home_phone        | TEXT |     |
| extension         | TEXT |     |
| reports_to        | INT  | FK  |

### Self-Referencing Relationship

```text
employees.reports_to
        ↓
employees.employee_id
```

This allows employees to be connected to their managers.

---

## 8. shippers

Stores shipping company information.

| Column       | Type | Key |
| ------------ | ---- | --- |
| shipper_id   | INT  | PK  |
| company_name | TEXT |     |
| phone        | TEXT |     |

Relationship:

```text
orders.ship_via
        ↓
shippers.shipper_id
```

---

## 9. employee_territories

Bridge table connecting employees to territories.

| Column       | Type | Key |
| ------------ | ---- | --- |
| employee_id  | INT  | FK  |
| territory_id | TEXT | FK  |

Relationships:

```text
employee_territories.employee_id
        ↓
employees.employee_id
```

```text
employee_territories.territory_id
        ↓
territories.territory_id
```

---

## 10. territories

Stores territory information.

| Column                | Type | Key |
| --------------------- | ---- | --- |
| territory_id          | TEXT | PK  |
| territory_description | TEXT |     |
| region_id             | INT  | FK  |

Relationship:

```text
territories.region_id
        ↓
regions.region_id
```

---

## 11. regions

Stores regional information.

| Column             | Type | Key |
| ------------------ | ---- | --- |
| region_id          | INT  | PK  |
| region_description | TEXT |     |

---

# Foreign Key Relationships

```text
products.supplier_id
        → suppliers.supplier_id

products.category_id
        → categories.category_id

order_details.order_id
        → orders.order_id

order_details.product_id
        → products.product_id

orders.customer_id
        → customers.customer_id

orders.employee_id
        → employees.employee_id

orders.ship_via
        → shippers.shipper_id

employees.reports_to
        → employees.employee_id

employee_territories.employee_id
        → employees.employee_id

employee_territories.territory_id
        → territories.territory_id

territories.region_id
        → regions.region_id
```

---

# Core Relationship Diagram

```text
                         ┌──────────────┐
                         │  categories  │
                         └──────┬───────┘
                                │
                                │ category_id
                                ▼
┌──────────────┐         ┌──────────────┐
│  suppliers   │◄────────│   products   │
└──────────────┘         └──────┬───────┘
                                │
                                │ product_id
                                ▼
                         ┌──────────────┐
                         │order_details │
                         └──────┬───────┘
                                │
                                │ order_id
                                ▼
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  customers   │────────►│    orders    │◄────────│  employees   │
└──────────────┘         └──────┬───────┘         └──────┬───────┘
                                │                         │
                                │ ship_via                │
                                ▼                         ▼
                         ┌──────────────┐        ┌──────────────────┐
                         │   shippers   │        │employee_territory│
                         └──────────────┘        └────────┬─────────┘
                                                          │
                                                          ▼
                                                  ┌──────────────┐
                                                  │ territories  │
                                                  └──────┬───────┘
                                                         │
                                                         ▼
                                                  ┌──────────────┐
                                                  │   regions    │
                                                  └──────────────┘
```

---

# Data Grain

Understanding grain is critical before writing analytical SQL.

## orders

One row represents:

```text
One customer order
```

Example:

```text
order_id = 10248
```

represents one order.

---

## order_details

One row represents:

```text
One product line within an order
```

Therefore one order can have multiple order-detail rows.

Example:

```text
order_id = 10248

product A
product B
product C
```

creates multiple rows in `order_details`.

---

# Sales Analysis Grain

For detailed sales analysis, the effective grain is:

```text
order_id + product_id
```

This is important because joining:

```text
orders
+
order_details
```

changes the result from:

```text
one row per order
```

to:

```text
one row per order-product line
```

---

# Analytical Join Path

For revenue analysis:

```text
orders
   ↓
order_details
   ↓
products
   ↓
categories
```

For customer sales:

```text
customers
   ↓
orders
   ↓
order_details
   ↓
products
```

For employee sales:

```text
employees
   ↓
orders
   ↓
order_details
```

For shipping analysis:

```text
shippers
   ↓
orders
```

For product-supplier analysis:

```text
suppliers
   ↓
products
```

---

# Important Analytical Considerations

## 1. Order-Level vs Line-Level Data

Do not treat `orders` and `order_details` as having the same grain.

```text
orders
= order-level

order_details
= order-product-level
```

---

## 2. Revenue Calculation

Revenue should be calculated using:

```text
order_details.unit_price
```

rather than simply joining to the current product price.

---

## 3. Discount

The `discount` column represents the discount applied to an order-detail
line.

Net sales:

```text
unit_price × quantity × (1 - discount)
```

---

## 4. Shipping Delay

Shipping performance can be evaluated using:

```text
shipped_date - required_date
```

Positive values indicate late shipment.

Negative values indicate shipment before the required date.

---

# Schema Summary

| Table                | Primary Purpose            |
| -------------------- | -------------------------- |
| categories           | Product categories         |
| products             | Products sold              |
| suppliers            | Product suppliers          |
| customers            | Customers                  |
| orders               | Customer orders            |
| order_details        | Products within orders     |
| employees            | Sales employees            |
| shippers             | Shipping providers         |
| employee_territories | Employee-territory mapping |
| territories          | Sales territories          |
| regions              | Geographic regions         |

---

# Main Analytical Model

```text
                    PRODUCT MASTER
                         │
             ┌───────────┴───────────┐
             │                       │
        Categories              Suppliers
             │                       │
             └───────────┬───────────┘
                         │
                      Products
                         │
                         ▼
                  Order Details
                         │
                         ▼
                       Orders
                    /     |     \
                   /      |      \
                  ▼       ▼       ▼
            Customers Employees Shippers
```

This structure forms the foundation for the SQL analysis contained in
this repository.

````

