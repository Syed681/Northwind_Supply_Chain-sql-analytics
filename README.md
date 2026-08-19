````markdown
# Northwind SQL Analytics Portfolio

SQL analytics portfolio built using the **Northwind database**.

This project demonstrates intermediate and advanced SQL skills through
business-oriented problems involving sales, customers, products,
employees, categories, and shipping operations.

---

## Project Objective

The objective of this project is to demonstrate the ability to:

- Understand an unfamiliar relational database
- Understand table relationships and foreign keys
- Identify the correct data grain
- Write multi-table SQL queries
- Translate business questions into SQL
- Perform aggregations and comparative analysis
- Use CTEs and subqueries
- Use window functions for analytical problems
- Perform time-series analysis
- Rank entities within groups
- Calculate business metrics
- Extract actionable business insights

---

## Database

The project uses the **Northwind** relational database.

Northwind represents a fictional trading company and contains information
about:

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

---

## Database Structure

The core transaction flow is:

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

Orders are also connected to:

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

Complete schema documentation is available in:

```text
database_schema.md
```

---

## Important Data Grain

Understanding table grain is critical for this analysis.

### Orders

One row represents:

```text
One customer order
```

### Order Details

One row represents:

```text
One product line within an order
```

Therefore:

```text
Orders
1
|
|------ many
           |
           v
     Order Details
```

When `orders` is joined with `order_details`, one order can produce
multiple rows.

For sales analysis, the relevant transaction-level grain is generally:

```text
order_id + product_id
```

---

## Sales Calculation

Sales calculations are performed at the `order_details` level.

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

The transaction-level `unit_price` from `order_details` is used for sales
analysis rather than relying on the current product master price.

---

## SQL Topics Covered

### Basic SQL

* SELECT
* WHERE
* ORDER BY
* LIKE
* IN
* BETWEEN
* IS NULL
* Filtering

### Joins and Aggregation

* INNER JOIN
* LEFT JOIN
* Multi-table joins
* UNION
* GROUP BY
* HAVING
* COUNT
* SUM
* AVG
* MIN
* MAX

### Subqueries and CTEs

* Scalar subqueries
* Correlated subqueries
* Common Table Expressions
* Multi-stage analytical queries
* Above-average analysis
* Anti-join logic
* NOT EXISTS

### Window Functions

* ROW_NUMBER()
* RANK()
* DENSE_RANK()
* LAG()
* PARTITION BY
* Running totals
* Moving averages
* Percentage contribution

### Time-Series Analysis

* Monthly sales
* Yearly sales
* Month-over-month growth
* Year-over-year growth
* Running yearly sales
* Three-month moving averages

### Advanced Analytical SQL

* Top-N analysis
* Top-N within groups
* Customer ranking
* Product ranking
* Employee ranking
* Percentage of total
* Percentage of category sales
* Above-average entities
* First-event analysis
* Customer retention/activity analysis
* Shipping performance
* Freight analysis

---

## Repository Structure

```text
northwind-sql-analytics/
│
├── README.md
├── database_schema.md
│
├── 01_basic_queries.sql
├── 02_joins_and_aggregation.sql
├── 03_subqueries_and_ctes.sql
├── 04_sales_analysis.sql
├── 05_window_functions.sql
├── 06_time_series_analysis.sql
├── 07_advanced_analytical_sql.sql
│
└── insights.md
```

---

## Analysis Progression

The SQL analysis progresses from fundamental querying to advanced
business analysis:

```text
Basic SQL
    ↓
Joins & Aggregation
    ↓
Subqueries & CTEs
    ↓
Window Functions
    ↓
Time-Series Analysis
    ↓
Advanced Analytical SQL
    ↓
Business Insights
```

---

## Business Questions

The project addresses questions such as:

### Sales

* What are the highest-selling products?
* What are the yearly and monthly sales trends?
* What is the month-over-month sales growth?
* What is the year-over-year sales growth?
* What percentage of total sales comes from each category?

### Customers

* Who are the highest-spending customers?
* Which customers place the most orders?
* Which customers have been active across multiple years?
* Which customers have never placed an order?
* What was the first product purchased by each customer?

### Products

* Which products generate the most sales?
* What are the top products within each category?
* Which products have never been ordered?
* Which products perform above average?
* Which products contribute significantly to category sales?

### Employees

* Which employee generates the most sales each year?
* Which employees handle the most orders?
* Which employees have the highest late-shipment percentage?

### Shipping

* Which shippers have the highest average shipping delay?
* Which countries have the highest average freight?
* How does shipping performance vary between employees and shippers?

---

## Portfolio Focus

This repository is focused on **SQL problem solving**, not dashboard
development.

The primary goal is to demonstrate:

```text
Schema Understanding
        ↓
Data Grain
        ↓
SQL Logic
        ↓
Analytical Techniques
        ↓
Business Interpretation
```

---

## Key Skills Demonstrated

* Relational database analysis
* Business-oriented SQL
* Analytical SQL
* CTE-based problem solving
* Window functions
* Time-series analysis
* Ranking techniques
* Multi-table data analysis
* Data grain reasoning
* Business metric calculation
* Translating business requirements into SQL

---

## Insights

The final business observations and findings from the queries are
documented separately in:

```text
insights.md
```

Only findings supported by the actual Northwind query results are
included.

---

## Project Status

**Completed SQL analysis portfolio**

The repository contains:

* Original Northwind SQL exercises
* Advanced analytical SQL problems
* Database schema documentation
* Business analysis framework
* SQL-driven business insights

