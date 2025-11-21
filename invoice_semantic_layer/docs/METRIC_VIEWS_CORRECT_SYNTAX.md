# Correct Metric Views Query Syntax

## ✅ The MEASURE() Function is Required!

**CRITICAL**: Databricks metric view measures MUST be wrapped in the `MEASURE()` function, not `SUM()`, `AVG()`, etc.

---

## Three Key Rules

### 1. **Dimensions: Select Directly**
```sql
`Supplier Name`          -- ✅ CORRECT
`Supplier Category`      -- ✅ CORRECT
```

### 2. **Measures: Wrap in MEASURE()**
```sql
MEASURE(`Total Invoice Amount`)  -- ✅ CORRECT
SUM(`Total Invoice Amount`)      -- ❌ WRONG - causes error
`Total Invoice Amount`           -- ❌ WRONG - causes error
```

### 3. **ORDER BY: Also Use MEASURE()**
```sql
ORDER BY MEASURE(`Total Invoice Amount`) DESC  -- ✅ CORRECT
ORDER BY total_invoice_amount DESC             -- ❌ WRONG - may not work
```

---

## Complete Query Pattern

```sql
SELECT
  -- Dimensions: use directly
  `Dimension 1`,
  `Dimension 2`,

  -- Measures: wrap in MEASURE()
  MEASURE(`Measure 1`) as alias1,
  MEASURE(`Measure 2`) as alias2,
  MEASURE(`Measure 3`) as alias3

FROM metric_view_name

WHERE `Dimension 1` = 'value'  -- Filter on dimensions

GROUP BY `Dimension 1`, `Dimension 2`  -- Group by dimensions

ORDER BY MEASURE(`Measure 1`) DESC;  -- Order using MEASURE()
```

---

## Working Examples

### Example 1: Spend by Supplier

```sql
SELECT
  `Supplier Name`,
  `Supplier Category`,
  MEASURE(`Total Invoice Amount`) as total_spend,
  MEASURE(`Invoice Line Count`) as line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Name`, `Supplier Category`
ORDER BY MEASURE(`Total Invoice Amount`) DESC
LIMIT 10;
```

**Result**: Aggregated totals by supplier

| Supplier Name | Supplier Category | total_spend | line_count |
|---------------|-------------------|-------------|------------|
| Ocean Catch | Seafood | 464.23 | 1 |
| Fresh Farms | Produce | 401.83 | 2 |
| Spice Route | Dry Goods | 67.80 | 1 |

### Example 2: Spend by Category

```sql
SELECT
  `Supplier Category`,
  MEASURE(`Total Invoice Amount`) as category_spend,
  MEASURE(`Total Freight Cost`) as freight,
  MEASURE(`Total Tax Cost`) as tax,
  MEASURE(`Invoice Line Count`) as lines
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Category`
ORDER BY MEASURE(`Total Invoice Amount`) DESC;
```

### Example 3: Filtered Query (Produce Only)

```sql
SELECT
  `Supplier Name`,
  MEASURE(`Total Invoice Amount`) as spend,
  MEASURE(`Invoice Line Count`) as line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
WHERE `Supplier Category` = 'Produce'
GROUP BY `Supplier Name`
ORDER BY MEASURE(`Total Invoice Amount`) DESC;
```

### Example 4: Multiple Measures

```sql
SELECT
  `Supplier Name`,
  MEASURE(`Total Invoice Amount`) as invoice_total,
  MEASURE(`Total Net Spend`) as net_amount,
  MEASURE(`Total Freight Cost`) as freight,
  MEASURE(`Total Tax Cost`) as tax,
  MEASURE(`Total Discount Amount`) as discounts
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Name`
ORDER BY MEASURE(`Total Invoice Amount`) DESC;
```

### Example 5: Grand Totals (No GROUP BY)

```sql
SELECT
  MEASURE(`Total Invoice Amount`) as grand_total,
  MEASURE(`Invoice Line Count`) as total_lines
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
```

**Result**: Single row with overall totals

| grand_total | total_lines |
|-------------|-------------|
| 933.86 | 4 |

### Example 6: Item Analysis

```sql
SELECT
  `Item Name`,
  `Item Category`,
  MEASURE(`Total Invoice Amount`) as spend,
  MEASURE(`Total Line Quantity`) as quantity
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_item_semantic_poc
GROUP BY `Item Name`, `Item Category`
ORDER BY MEASURE(`Total Invoice Amount`) DESC
LIMIT 10;
```

### Example 7: Restaurant Spend

```sql
SELECT
  `Restaurant Name`,
  `Restaurant Region`,
  MEASURE(`Total Invoice Amount`) as spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_restaurant_semantic_poc
GROUP BY `Restaurant Name`, `Restaurant Region`
ORDER BY MEASURE(`Total Invoice Amount`) DESC;
```

### Example 8: Daily Trend (Calendar View)

```sql
SELECT
  `Invoice Date`,
  MEASURE(`Total Invoice Amount`) as daily_spend,
  MEASURE(`Invoice Line Count`) as line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_calendar_semantic_poc
GROUP BY `Invoice Date`
ORDER BY `Invoice Date`;
```

### Example 9: Distribution Center Analysis

```sql
SELECT
  `Distribution Center Name`,
  `Distribution Center Region`,
  MEASURE(`Total Invoice Amount`) as spend,
  MEASURE(`Total Freight Cost`) as freight
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_dc_semantic_poc
GROUP BY `Distribution Center Name`, `Distribution Center Region`
ORDER BY MEASURE(`Total Invoice Amount`) DESC;
```

---

## All 5 Metric Views - Quick Reference

### 1. **mv_invoice_supplier_semantic_poc**

**Dimensions:**
- `Invoice Date`, `Supplier ID`, `Supplier Name`, `Supplier Category`, `Supplier Country`, `Supplier Active Flag`, `Currency Code`

**Measures:**
- `Total Net Spend`, `Total Invoice Amount`, `Total Line Quantity`, `Total Freight Cost`, `Total Tax Cost`, `Total Discount Amount`, `Invoice Line Count`

**Example:**
```sql
SELECT
  `Supplier Category`,
  MEASURE(`Total Invoice Amount`) as spend
FROM mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Category`;
```

### 2. **mv_invoice_item_semantic_poc**

**Dimensions:**
- `Invoice Date`, `Item ID`, `Item Name`, `Item Category`, `Unit of Measure`, `Brand`, `Item Active Flag`, `Currency Code`

**Measures:**
- `Total Net Spend`, `Total Invoice Amount`, `Total Line Quantity`, `Total Discount Amount`, `Total Freight Cost`, `Total Tax Cost`, `Invoice Line Count`

**Example:**
```sql
SELECT
  `Item Category`,
  MEASURE(`Total Invoice Amount`) as spend
FROM mv_invoice_item_semantic_poc
GROUP BY `Item Category`;
```

### 3. **mv_invoice_restaurant_semantic_poc**

**Dimensions:**
- `Invoice Date`, `Restaurant ID`, `Restaurant Name`, `Location Number`, `Restaurant Region`, `Restaurant Timezone`, `Restaurant Active Flag`, `Currency Code`

**Measures:**
- Same as above

**Example:**
```sql
SELECT
  `Restaurant Region`,
  MEASURE(`Total Invoice Amount`) as spend
FROM mv_invoice_restaurant_semantic_poc
GROUP BY `Restaurant Region`;
```

### 4. **mv_invoice_dc_semantic_poc**

**Dimensions:**
- `Invoice Date`, `Distribution Center ID`, `Distribution Center Name`, `Distribution Center Code`, `Distribution Center Region`, `Distribution Center Timezone`, `Distribution Center Active Flag`, `Currency Code`

**Measures:**
- Same as above

**Example:**
```sql
SELECT
  `Distribution Center Region`,
  MEASURE(`Total Invoice Amount`) as spend
FROM mv_invoice_dc_semantic_poc
GROUP BY `Distribution Center Region`;
```

### 5. **mv_invoice_calendar_semantic_poc**

**Dimensions:**
- `Invoice Date`, `Year`, `Quarter`, `Month`, `Week`, `Day of Week`

**Measures:**
- Same as above

**Example:**
```sql
SELECT
  `Month`,
  MEASURE(`Total Invoice Amount`) as monthly_spend
FROM mv_invoice_calendar_semantic_poc
GROUP BY `Month`
ORDER BY `Month`;
```

---

## Common Errors & Solutions

### Error 1: "measure column requires a MEASURE() function"

**Error Message:**
```
The usage of measure column [Total Invoice Amount] requires a MEASURE() function
```

**Cause**: Using `SUM()` or direct selection instead of `MEASURE()`

**Solution:**
```sql
-- ❌ WRONG
SUM(`Total Invoice Amount`)

-- ✅ CORRECT
MEASURE(`Total Invoice Amount`)
```

### Error 2: Column name not found

**Error Message:**
```
A column with name 'total_invoice_amount' cannot be resolved
```

**Cause**: Using snake_case or wrong column name

**Solution:**
```sql
-- ❌ WRONG
MEASURE(total_invoice_amount)

-- ✅ CORRECT
MEASURE(`Total Invoice Amount`)
```

### Error 3: Must use GROUP BY

**Error Message:**
```
Measure must be used with GROUP BY
```

**Cause**: Selecting dimensions without GROUP BY

**Solution:**
```sql
-- ❌ WRONG
SELECT `Supplier Name`, MEASURE(`Total Invoice Amount`)
FROM metric_view;

-- ✅ CORRECT
SELECT `Supplier Name`, MEASURE(`Total Invoice Amount`)
FROM metric_view
GROUP BY `Supplier Name`;
```

---

## Quick Validation Test

Run this to verify your metric view works:

```sql
-- Should return one row with totals
SELECT
  MEASURE(`Total Invoice Amount`) as grand_total,
  MEASURE(`Invoice Line Count`) as total_lines
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
```

**Expected**: Single row with aggregated totals across all suppliers

---

## Key Differences: MEASURE() vs SUM()

| Feature | Metric View (MEASURE) | Semantic View (SUM) |
|---------|----------------------|---------------------|
| **Function** | `MEASURE(column)` | `SUM(column)` |
| **Data** | Pre-aggregated | Detail-level |
| **Performance** | Faster (pre-computed) | Slower (aggregates on query) |
| **Use Case** | Dashboards, reports | Ad-hoc analysis |
| **GROUP BY** | Required for dimensions | Required for aggregation |

---

## Summary

**Three critical rules for metric views:**

1. ✅ **Dimensions**: Select directly with backticks: `` `Supplier Name` ``
2. ✅ **Measures**: Wrap in `MEASURE()`: `MEASURE(\`Total Invoice Amount\`)`
3. ✅ **ORDER BY**: Use `MEASURE()` for sorting: `ORDER BY MEASURE(\`Total Invoice Amount\`) DESC`

**Basic template:**
```sql
SELECT
  `Dimension Column`,
  MEASURE(`Measure Column`) as alias
FROM metric_view_name
GROUP BY `Dimension Column`
ORDER BY MEASURE(`Measure Column`) DESC;
```

---

## Related Documentation

- [12_METRIC_VIEWS_EXPLAINED.md](12_METRIC_VIEWS_EXPLAINED.md) - Concepts and theory
- [13_METRIC_VIEWS_YAML_GUIDE.md](13_METRIC_VIEWS_YAML_GUIDE.md) - How to create metric views
- [validate_metric_views.sql](../sql_semantic_poc/validate_metric_views.sql) - Validation script
- [14_METRIC_VIEWS_TROUBLESHOOTING.md](14_METRIC_VIEWS_TROUBLESHOOTING.md) - Common issues

---

**Now you can successfully query all metric views using the correct `MEASURE()` syntax!**
