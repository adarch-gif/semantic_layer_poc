# Metric Views Query Guide

## ⚠️ DEPRECATION NOTICE

**This document contains outdated syntax that will cause errors.**

**Please use the updated guide instead:**
- **[METRIC_VIEWS_CORRECT_SYNTAX.md](METRIC_VIEWS_CORRECT_SYNTAX.md)** ← **Use this for correct query syntax**

**Key difference**: Metric view measures require `MEASURE()` function, not `SUM()` or other aggregation functions.

```sql
-- ❌ WRONG (this document shows):
SUM(`Total Invoice Amount`)

-- ✅ CORRECT (use instead):
MEASURE(`Total Invoice Amount`)
```

**This document is kept for historical reference only. Do not follow the query examples below.**

---

## Quick Reference for Querying Databricks Metric Views (OUTDATED)

---

## Two Key Rules

### 1. **Use Backticks for Column Names with Spaces**
```sql
-- ✅ CORRECT
`Supplier Name`

-- ❌ WRONG
Supplier Name
supplier_name
```

### 2. **Measures Require Aggregation Functions**
```sql
-- ✅ CORRECT
SUM(`Total Invoice Amount`)

-- ❌ WRONG
`Total Invoice Amount`
```

---

## Column Types

### **Dimensions** (can use directly)
- `Invoice Date`
- `Supplier ID`
- `Supplier Name`
- `Supplier Category`
- `Supplier Country`
- `Supplier Active Flag`
- `Currency Code`

### **Measures** (must aggregate)
- `Total Net Spend`
- `Total Invoice Amount`
- `Total Line Quantity`
- `Total Freight Cost`
- `Total Tax Cost`
- `Total Discount Amount`
- `Invoice Line Count`

---

## Query Pattern

```sql
SELECT
  -- Dimensions: select directly
  `Dimension 1`,
  `Dimension 2`,

  -- Measures: must aggregate
  SUM(`Measure 1`) as alias1,
  AVG(`Measure 2`) as alias2,
  MAX(`Measure 3`) as alias3

FROM mv_metric_view_name
WHERE `Dimension 1` = 'filter value'  -- Optional filter
GROUP BY `Dimension 1`, `Dimension 2`
ORDER BY alias1 DESC;
```

---

## Common Query Examples

### Example 1: Total Spend by Supplier

```sql
SELECT
  `Supplier Name`,
  SUM(`Total Invoice Amount`) as total_spend,
  SUM(`Invoice Line Count`) as line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Name`
ORDER BY total_spend DESC;
```

### Example 2: Spend by Category

```sql
SELECT
  `Supplier Category`,
  SUM(`Total Invoice Amount`) as category_spend,
  SUM(`Total Freight Cost`) as freight_cost,
  SUM(`Total Tax Cost`) as tax_cost
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Category`
ORDER BY category_spend DESC;
```

### Example 3: Filtered Query (Produce Suppliers Only)

```sql
SELECT
  `Supplier Name`,
  SUM(`Total Invoice Amount`) as spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
WHERE `Supplier Category` = 'Produce'
GROUP BY `Supplier Name`
ORDER BY spend DESC;
```

### Example 4: Multiple Dimensions

```sql
SELECT
  `Supplier Category`,
  `Supplier Country`,
  SUM(`Total Invoice Amount`) as total_spend,
  AVG(`Total Invoice Amount`) as avg_spend_per_supplier,
  COUNT(DISTINCT `Supplier Name`) as supplier_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Category`, `Supplier Country`
ORDER BY total_spend DESC;
```

### Example 5: Grand Total (No Grouping)

```sql
SELECT
  SUM(`Total Invoice Amount`) as grand_total,
  SUM(`Invoice Line Count`) as total_lines,
  COUNT(DISTINCT `Supplier Name`) as total_suppliers
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
```

---

## All 5 Metric Views

### 1. Supplier Metric View
```sql
SELECT
  `Supplier Name`,
  `Supplier Category`,
  SUM(`Total Invoice Amount`) as spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Name`, `Supplier Category`
ORDER BY spend DESC;
```

### 2. Item Metric View
```sql
SELECT
  `Item Name`,
  `Item Category`,
  SUM(`Total Invoice Amount`) as spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_item_semantic_poc
GROUP BY `Item Name`, `Item Category`
ORDER BY spend DESC;
```

### 3. Restaurant Metric View
```sql
SELECT
  `Restaurant Name`,
  `Restaurant Region`,
  SUM(`Total Invoice Amount`) as spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_restaurant_semantic_poc
GROUP BY `Restaurant Name`, `Restaurant Region`
ORDER BY spend DESC;
```

### 4. Distribution Center Metric View
```sql
SELECT
  `Distribution Center Name`,
  `Distribution Center Region`,
  SUM(`Total Invoice Amount`) as spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_dc_semantic_poc
GROUP BY `Distribution Center Name`, `Distribution Center Region`
ORDER BY spend DESC;
```

### 5. Calendar Metric View
```sql
SELECT
  `Invoice Date`,
  SUM(`Total Invoice Amount`) as daily_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_calendar_semantic_poc
GROUP BY `Invoice Date`
ORDER BY `Invoice Date`;
```

---

## Common Errors & Solutions

### Error 1: Column Not Found
```
Error: A column with name 'supplier_name' cannot be resolved
```

**Cause**: Using snake_case instead of display name with spaces

**Solution**: Use backticks and exact YAML name
```sql
-- ✅ CORRECT
`Supplier Name`
```

### Error 2: Measure Function Required
```
Error: The usage of measure column [Total Invoice Amount] requires a MEASURE() function
```

**Cause**: Trying to select measure directly without aggregation

**Solution**: Wrap in aggregation function
```sql
-- ✅ CORRECT
SUM(`Total Invoice Amount`)

-- ❌ WRONG
`Total Invoice Amount`
```

### Error 3: Must Use GROUP BY
```
Error: Measure must be used with GROUP BY
```

**Cause**: Selecting dimensions without GROUP BY when using aggregations

**Solution**: Add GROUP BY clause
```sql
-- ✅ CORRECT
SELECT `Supplier Name`, SUM(`Total Invoice Amount`)
FROM metric_view
GROUP BY `Supplier Name`;

-- ❌ WRONG
SELECT `Supplier Name`, SUM(`Total Invoice Amount`)
FROM metric_view;
```

---

## Aggregation Functions

Use these functions with measures:

| Function | Purpose | Example |
|----------|---------|---------|
| `SUM()` | Total across rows | `SUM(\`Total Invoice Amount\`)` |
| `AVG()` | Average value | `AVG(\`Total Invoice Amount\`)` |
| `MAX()` | Maximum value | `MAX(\`Total Invoice Amount\`)` |
| `MIN()` | Minimum value | `MIN(\`Total Invoice Amount\`)` |
| `COUNT()` | Count of rows | `COUNT(DISTINCT \`Supplier Name\`)` |

---

## Comparison: Metric View vs Semantic View

### Semantic View (Detail Level)
```sql
-- Returns ~12 rows (one per invoice line)
SELECT
  supplier_name,
  invoice_amount
FROM v_invoice_supplier_semantic_poc;
```

### Metric View (Aggregated)
```sql
-- Returns ~3 rows (one per supplier)
SELECT
  `Supplier Name`,
  SUM(`Total Invoice Amount`) as total
FROM mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Name`;
```

**Key Difference**: Metric views are pre-aggregated, semantic views have detail-level data.

---

## Quick Validation Query

Test if your metric view is working:

```sql
-- Should return one row with grand total
SELECT
  'VALIDATION' as test,
  SUM(`Total Invoice Amount`) as grand_total,
  SUM(`Invoice Line Count`) as total_lines,
  COUNT(DISTINCT `Supplier Name`) as supplier_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
```

**Expected Output**:
| test | grand_total | total_lines | supplier_count |
|------|-------------|-------------|----------------|
| VALIDATION | 15255.00 | 12 | 3 |

---

## Related Documentation

- [METRIC_VIEWS_VALIDATION_GUIDE.md](METRIC_VIEWS_VALIDATION_GUIDE.md) - Complete validation steps
- [12_METRIC_VIEWS_EXPLAINED.md](12_METRIC_VIEWS_EXPLAINED.md) - Concepts and theory
- [13_METRIC_VIEWS_YAML_GUIDE.md](13_METRIC_VIEWS_YAML_GUIDE.md) - How to create metric views
- [14_METRIC_VIEWS_TROUBLESHOOTING.md](14_METRIC_VIEWS_TROUBLESHOOTING.md) - Common issues

---

## Summary

**Remember these two rules:**

1. **Backticks**: Always use `` `Column Name` `` for names with spaces
2. **Aggregations**: Always use `SUM()`, `AVG()`, etc. for measure columns

**Basic query template:**
```sql
SELECT
  `Dimension Column`,
  SUM(`Measure Column`) as alias
FROM metric_view_name
GROUP BY `Dimension Column`;
```

That's it! You're now ready to query metric views successfully.
