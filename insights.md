# Northwind SQL Analytics — Business Insights

This document summarizes the business findings identified from the
Northwind SQL analysis.

The insights should be based on the actual query results rather than
assumptions.

---

## 1. Sales Performance

### Annual Sales

**Query:** `04_sales_analysis.sql`

Key observations:

- Identify the year with the highest total sales.
- Identify the year with the lowest total sales.
- Compare gross sales with net sales.
- Measure the impact of discounts on overall sales.

### Monthly Sales

**Query:** `06_time_series_analysis.sql`

Key observations:

- Identify the strongest sales months.
- Identify periods of declining sales.
- Identify recurring seasonal patterns if present.

---

## 2. Product Performance

**Queries:**
- `04_sales_analysis.sql`
- `05_window_functions.sql`
- `07_advanced_analytical_sql.sql`

Key observations:

- Identify the highest-revenue products.
- Identify the top products within each category.
- Identify products contributing significantly to category revenue.
- Identify products with weak or limited sales performance.

---

## 3. Category Performance

**Queries:**
- `04_sales_analysis.sql`
- `07_advanced_analytical_sql.sql`

Key observations:

- Identify the highest-performing category.
- Identify the lowest-performing category.
- Measure each category's percentage contribution to total sales.
- Determine whether sales are concentrated in a small number of categories.

---

## 4. Customer Analysis

**Queries:**
- `02_joins_and_aggregation.sql`
- `03_subqueries_and_ctes.sql`
- `07_advanced_analytical_sql.sql`

Key observations:

- Identify the highest-value customers.
- Identify customers with the highest number of orders.
- Identify repeat customers.
- Identify customers active across multiple years.
- Identify customers who have never placed an order.

---

## 5. Employee Performance

**Queries:**
- `04_sales_analysis.sql`
- `07_advanced_analytical_sql.sql`

Key observations:

- Identify employees generating the highest sales.
- Identify the top-performing employee by year.
- Compare employee sales performance.
- Identify employees associated with higher late-shipment percentages.

---

## 6. Shipping & Operational Performance

**Query:** `07_advanced_analytical_sql.sql`

Key observations:

- Identify shippers with the highest average shipping delay.
- Identify employees with high late-shipment percentages.
- Identify countries with high average freight costs.
- Compare freight performance between shippers.

---

## 7. Time-Series Analysis

**Query:** `06_time_series_analysis.sql`

Key observations:

- Measure month-over-month sales growth.
- Measure year-over-year sales growth.
- Identify periods of accelerated growth.
- Identify periods of declining performance.
- Compare monthly sales with moving averages.
- Analyze cumulative yearly sales.

---

## 8. Advanced Analytical Findings

**Query:** `07_advanced_analytical_sql.sql`

The advanced analysis demonstrates:

- Ranking within groups.
- Top-N analysis.
- Above-average analysis.
- Percentage-of-total calculations.
- Percentage-of-category calculations.
- Running totals.
- Moving averages.
- First-event analysis.
- Anti-joins using `NOT EXISTS`.
- Multi-stage CTE analysis.

---

## 9. Key Business Takeaways

After executing the SQL queries, summarize the most important findings here.

### Sales

- Highest-performing period:
- Lowest-performing period:
- Overall sales trend:

### Products

- Best-performing product:
- Best-performing category:
- Most important products by category:

### Customers

- Highest-value customer:
- Most frequent customers:
- Customer concentration:

### Employees

- Top-performing employee:
- Employee operational concern:

### Shipping

- Best-performing shipper:
- Highest-delay shipper:
- Highest-freight country:

---

## 10. Business Opportunities

Based on the SQL findings, potential opportunities may include:

- Focus sales efforts on high-performing product categories.
- Investigate declining products and categories.
- Strengthen relationships with high-value customers.
- Investigate customers with declining purchasing activity.
- Review shipping performance where delays are consistently high.
- Investigate countries with unusually high freight costs.
- Use historical sales trends for inventory and sales planning.

Only retain opportunities that are supported by the actual query results.

---

## 11. SQL Skills Demonstrated

This project demonstrates practical use of:

- SELECT / WHERE
- ORDER BY
- GROUP BY / HAVING
- Aggregate functions
- INNER JOIN
- LEFT JOIN
- UNION
- CASE WHEN
- Subqueries
- CTEs
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- PARTITION BY
- LAG()
- LEAD()
- Running totals
- Moving averages
- MoM analysis
- YoY analysis
- Top-N analysis
- Percentage contribution
- Anti-joins
- NOT EXISTS
- Multi-table analytical queries
- Business-oriented SQL problem solving

---

## 12. Conclusion

The Northwind project progresses from basic relational querying to
advanced analytical SQL.

The analysis demonstrates the ability to:

1. Understand an unfamiliar relational database.
2. Identify relationships between tables.
3. Understand data grain.
4. Translate business requirements into SQL.
5. Build multi-table queries.
6. Use CTEs for complex analytical problems.
7. Apply window functions for ranking and comparisons.
8. Perform time-series analysis.
9. Calculate business metrics.
10. Convert query results into business insights.

The project focuses on practical SQL analysis rather than isolated
syntax exercises.
