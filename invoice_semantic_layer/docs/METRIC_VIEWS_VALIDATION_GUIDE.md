# Metric Views Validation Guide

## Overview

This guide provides comprehensive steps to validate that your Databricks metric views are working correctly. Metric views are a Databricks feature that pre-aggregates data for faster dashboarding and analytics.

---

## Prerequisites

Before validating metric views, ensure:

1. ✅ **Databricks Metrics (Preview) is enabled** in your workspace
2. ✅ **Scripts 01-07 have been run** (schemas, tables, data, registries, semantic views)
3. ✅ **Script 10 has been run** (metric views creation script)
4. ✅ You have **SELECT access** to `invoice_semantic_poc` schema

---

## What Are Metric Views?

**Metric Views** are special database objects in Databricks that:
- Store **pre-aggregated** data (like SUM, COUNT, AVG)
- Are defined using **YAML configuration** (Databricks 1.1 schema)
- Appear in the **Databricks Metrics UI** for no-code visualization
- Enable **business users** to create dashboards without SQL

### Difference from Semantic Views

| Feature | Semantic Views | Metric Views |
|---------|---------------|--------------|
| **Purpose** | Detail-level data with relationships | Pre-aggregated metrics |
| **Rows** | One row per fact/transaction | One row per dimension combination |
| **Columns** | All fact + dimension attributes | Dimensions + aggregated measures |
| **Use Case** | Ad-hoc SQL queries | Dashboards & scorecards |
| **UI** | Standard Data Explorer | Databricks Metrics UI |

**Example:**

```sql
-- Semantic View: Returns 12 detailed invoice lines
SELECT * FROM v_invoice_supplier_semantic_poc;

-- Metric View: Returns 3 aggregated supplier totals
SELECT * FROM mv_invoice_supplier_semantic_poc;
```

---

## Validation Steps

### Step 1: Check if Metric Views Exist

**Purpose**: Verify that script 10 ran successfully and created 5 metric views.

**SQL Script**: Run `validate_metric_views.sql` - Section 1

```sql
SELECT
  table_name,
  table_type
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'mv_%'
ORDER BY table_name;
```

**Expected Result**: 5 rows

| table_name | table_type |
|------------|------------|
| mv_invoice_calendar_semantic_poc | TABLE |
| mv_invoice_dc_semantic_poc | TABLE |
| mv_invoice_item_semantic_poc | TABLE |
| mv_invoice_restaurant_semantic_poc | TABLE |
| mv_invoice_supplier_semantic_poc | TABLE |

**If no results**: You need to run [10_metric_views_semantic_poc.sql](../sql_semantic_poc/10_metric_views_semantic_poc.sql)

---

### Step 2: Inspect Metric View Structure

**Purpose**: Verify metric views have the correct columns (dimensions + aggregated measures).

**SQL Script**: Section 2

```sql
DESCRIBE TABLE cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
```

**Expected Columns**:

**Dimensions** (for grouping):
- `supplier_name` - Supplier name
- `supplier_category` - Category (Produce, Dairy, etc.)
- `supplier_country` - Country code
- `supplier_active_flag` - Active status

**Measures** (pre-aggregated):
- `total_invoice_amount` - SUM of invoice amounts
- `total_net_amount` - SUM of net line amounts
- `total_freight_cost` - SUM of freight
- `total_tax_cost` - SUM of tax
- `total_discount_amount` - SUM of discounts
- `invoice_line_count` - COUNT of lines
- `avg_line_quantity` - AVG quantity per line

**What You Should NOT See**:
- ❌ Individual `invoice_id` or `line_id` (these are detail-level)
- ❌ Individual `invoice_date` (use calendar metric view for time-series)

---

### Step 3: Query Metric View Data

**Purpose**: Verify metric views return aggregated data (not detail rows).

**SQL Script**: Section 3

```sql
SELECT
  supplier_name,
  supplier_category,
  total_invoice_amount,
  total_net_amount,
  invoice_line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
ORDER BY total_invoice_amount DESC
LIMIT 10;
```

**Expected Result**: ~3 rows (one per supplier)

| supplier_name | supplier_category | total_invoice_amount | invoice_line_count |
|---------------|-------------------|----------------------|-------------------|
| FreshCo Farms | Produce | 7,245.00 | 5 |
| Dairy Direct | Dairy | 4,890.00 | 4 |
| Global Meats | Meat | 3,120.00 | 3 |

**Key Validation Points**:
- ✅ Each row represents **one supplier** (not individual invoices)
- ✅ Amounts are **totals** across all invoices for that supplier
- ✅ Count shows **total number** of invoice lines

**If you see 12 rows**: You're querying a semantic view, not a metric view!

---

### Step 4: Verify Aggregation Accuracy

**Purpose**: Ensure metric view totals match manual calculations from semantic views.

**SQL Script**: Section 4

```sql
-- Query A: Metric View Totals
SELECT
  'METRIC VIEW' as source,
  SUM(total_invoice_amount) as grand_total
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- Query B: Semantic View Totals (manual aggregation)
SELECT
  'SEMANTIC VIEW' as source,
  SUM(invoice_amount) as grand_total
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;
```

**Expected Result**: Both queries return **identical numbers**

| source | grand_total |
|--------|-------------|
| METRIC VIEW | 15,255.00 |
| SEMANTIC VIEW | 15,255.00 |

**If numbers differ**:
- ❌ Metric view definition is incorrect
- ❌ Review [10_metric_views_semantic_poc.sql](../sql_semantic_poc/10_metric_views_semantic_poc.sql)
- ❌ Check for filtering issues or incorrect aggregation logic

---

### Step 5: Test All 5 Metric Views

**Purpose**: Verify all metric views are queryable without errors.

**SQL Script**: Section 5

```sql
-- Test each metric view
SELECT '5a. SUPPLIER' as test, COUNT(*) as count FROM mv_invoice_supplier_semantic_poc;
SELECT '5b. ITEM' as test, COUNT(*) as count FROM mv_invoice_item_semantic_poc;
SELECT '5c. RESTAURANT' as test, COUNT(*) as count FROM mv_invoice_restaurant_semantic_poc;
SELECT '5d. DC' as test, COUNT(*) as count FROM mv_invoice_dc_semantic_poc;
SELECT '5e. CALENDAR' as test, COUNT(*) as count FROM mv_invoice_calendar_semantic_poc;
```

**Expected Results**:

| test | count |
|------|-------|
| 5a. SUPPLIER | 3 |
| 5b. ITEM | 4 |
| 5c. RESTAURANT | 2 |
| 5d. DC | 2 |
| 5e. CALENDAR | ~12 (depends on date range) |

**If any query fails**:
- Check if underlying semantic views exist (run script 07)
- Check for permissions issues
- Review error message for specific issues

---

### Step 6: Verify Metric View Properties

**Purpose**: Confirm metric views have the correct Databricks metadata.

**SQL Script**: Section 6

```sql
SHOW TBLPROPERTIES cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
```

**Expected Properties**:

| key | value |
|-----|-------|
| `databricks.metricViewVersion` | `1.1` |
| Various other metadata | ... |

**Key Property to Check**:
- ✅ `databricks.metricViewVersion = 1.1` - Confirms it's using the latest metric view schema

**If missing**: The table may not be recognized as a metric view by Databricks Metrics UI

---

### Step 7: Test Filtering on Dimensions

**Purpose**: Verify metric views support WHERE clauses on dimension columns.

**SQL Script**: Section 7

```sql
SELECT
  supplier_name,
  total_invoice_amount,
  invoice_line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
WHERE supplier_category = 'Produce'
ORDER BY total_invoice_amount DESC;
```

**Expected Result**: Only suppliers in "Produce" category

| supplier_name | total_invoice_amount | invoice_line_count |
|---------------|----------------------|-------------------|
| FreshCo Farms | 7,245.00 | 5 |

**Validation**:
- ✅ Filtering works correctly
- ✅ Pre-aggregated totals are preserved
- ✅ No need to re-aggregate after filtering

---

### Step 8: Verify in Databricks Metrics UI ⭐

**Purpose**: Confirm metric views appear in the Databricks Metrics browser for no-code visualization.

**This is a MANUAL step - must be done in the Databricks UI**

#### 8.1 Navigate to Metrics UI

1. Open Databricks workspace
2. Go to **Data** → **Metrics** in left sidebar
3. Or navigate directly to: `https://your-workspace.databricks.com/explore/data/metrics`

#### 8.2 Find Your Metric Views

You should see all 5 metric views listed:
- ✅ mv_invoice_supplier_semantic_poc
- ✅ mv_invoice_item_semantic_poc
- ✅ mv_invoice_restaurant_semantic_poc
- ✅ mv_invoice_dc_semantic_poc
- ✅ mv_invoice_calendar_semantic_poc

#### 8.3 Explore a Metric View

Click on **mv_invoice_supplier_semantic_poc**:

**You should see**:
- **Dimensions** section showing: supplier_name, supplier_category, supplier_country, etc.
- **Measures** section showing: total_invoice_amount, invoice_line_count, etc.
- **Preview** tab showing aggregated data

#### 8.4 Create a Simple Visualization

1. Click **"Create Visualization"** or **"Explore"**
2. Select **Dimension**: `supplier_category`
3. Select **Measure**: `total_invoice_amount`
4. Choose chart type: **Bar Chart**
5. Click **"Visualize"**

**Expected Result**:
- Bar chart showing spend by supplier category
- No SQL required!
- Business users can do this themselves

#### 8.5 Troubleshooting Metrics UI

**If you see "Feature not enabled" error**:
```
Databricks Metrics (Preview) is not enabled for this workspace
```

**Solution**:
1. Contact your Databricks account team
2. Request to enable "Databricks Metrics (Preview)" feature flag
3. This is a workspace-level setting that requires Databricks support

**Alternative**: Use SQL queries from Steps 1-7 until feature is enabled

---

### Step 9: Check Metric View Refresh Status

**Purpose**: Verify metric views were created successfully and see refresh history.

**SQL Script**: Section 9

```sql
DESCRIBE HISTORY cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
LIMIT 5;
```

**Expected Result**: Shows Delta table history

| version | timestamp | operation | userName |
|---------|-----------|-----------|----------|
| 0 | 2025-01-15 10:30:00 | CREATE TABLE | your.name@company.com |

**What This Shows**:
- ✅ When metric view was created
- ✅ Who created it
- ✅ Any refresh operations (if data was updated)

**Note**: Metric views in Databricks typically refresh automatically when underlying data changes

---

### Step 10: Validate Naming Conventions

**Purpose**: Ensure metric views follow best practices for naming.

**SQL Script**: Section 10

```sql
SELECT
  table_name,
  CASE
    WHEN table_name LIKE 'mv_%' THEN 'PASS'
    ELSE 'FAIL'
  END as naming_check
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'mv_%';
```

**Expected**: All rows show "PASS"

**Naming Convention**:
- ✅ Metric views start with `mv_` prefix
- ✅ Semantic views start with `v_` prefix
- ✅ Gold tables have no prefix
- ✅ This makes object types clear at a glance

---

## Validation Checklist

Use this checklist to confirm all validation steps passed:

- [ ] **Step 1**: 5 metric views exist ✓
- [ ] **Step 2**: Metric views have correct column structure ✓
- [ ] **Step 3**: Metric views return aggregated data (not detail rows) ✓
- [ ] **Step 4**: Aggregation totals match semantic view calculations ✓
- [ ] **Step 5**: All 5 metric views are queryable without errors ✓
- [ ] **Step 6**: Metric views have `databricks.metricViewVersion = 1.1` property ✓
- [ ] **Step 7**: Filtering works correctly on dimension columns ✓
- [ ] **Step 8**: Metric views appear in Databricks Metrics UI ✓
- [ ] **Step 9**: Metric view history shows successful creation ✓
- [ ] **Step 10**: All metric views follow `mv_*` naming convention ✓

**If all checks pass**: Your metric views are working correctly! 🎉

---

## Troubleshooting Guide

### Issue 1: No Metric Views Found (Step 1 Fails)

**Symptom**: Query returns 0 rows

**Cause**: Script 10 hasn't been run yet

**Solution**:
```sql
-- Run this script in Databricks SQL Editor
-- File: 10_metric_views_semantic_poc.sql
```

### Issue 2: Metric View Query Fails (Step 3 Fails)

**Error**: `Table or view not found`

**Cause**: Underlying semantic views don't exist

**Solution**:
1. Check if semantic views exist: `SHOW VIEWS IN invoice_semantic_poc LIKE 'v_%'`
2. If empty, run script 07: `07_semantic_views_semantic_poc.sql`
3. Then re-run script 10

### Issue 3: Totals Don't Match (Step 4 Fails)

**Symptom**: Metric view totals ≠ Semantic view totals

**Cause**: Incorrect aggregation logic in metric view definition

**Solution**:
1. Review [10_metric_views_semantic_poc.sql](../sql_semantic_poc/10_metric_views_semantic_poc.sql)
2. Check GROUP BY clause includes correct dimensions
3. Verify SUM/COUNT expressions are correct
4. Drop and recreate the problematic metric view

### Issue 4: Metrics UI Shows "Feature Not Enabled" (Step 8 Fails)

**Symptom**: Cannot access Metrics UI or see metric views

**Cause**: Databricks Metrics (Preview) not enabled for workspace

**Solution**:
- **Short-term**: Use SQL queries (Steps 1-7) to validate
- **Long-term**: Contact Databricks support to enable feature flag
- **Alternative**: Use standard dashboarding tools (SQL, notebooks, BI tools)

### Issue 5: Permission Denied

**Error**: `User does not have SELECT privilege`

**Cause**: Insufficient permissions on schema or views

**Solution**:
1. Run permissions script: `08_permissions_semantic_poc.sql`
2. Verify grants: `SHOW GRANTS ON SCHEMA invoice_semantic_poc`
3. Ensure your user/group has SELECT access

---

## Performance Testing (Bonus)

Want to see the benefit of metric views? Compare query performance:

### Query A: Using Metric View (Fast ⚡)

```sql
-- Pre-aggregated - should be very fast
SELECT
  supplier_category,
  SUM(total_invoice_amount) as category_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY supplier_category
ORDER BY category_spend DESC;
```

### Query B: Using Semantic View (Slower 🐢)

```sql
-- Aggregates on the fly - slower with large datasets
SELECT
  supplier_category,
  SUM(invoice_amount) as category_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_category
ORDER BY category_spend DESC;
```

**Expected Result**:
- Both return **identical numbers**
- Query A (metric view) is **faster** - especially with millions of rows
- Query B must scan all detail rows and aggregate every time

**Performance Difference**:
- Small dataset (12 rows): Minimal difference
- Large dataset (millions of rows): Metric views can be **10-100x faster**

---

## Next Steps

After validating your metric views:

1. **Set up Genie Space**: See [16_GENIE_SPACE_SETUP.md](16_GENIE_SPACE_SETUP.md)
2. **Create Dashboards**: Use Databricks Metrics UI or SQL dashboards
3. **Train Business Users**: Show them how to explore metric views without SQL
4. **Monitor Performance**: Track query times and optimize if needed
5. **Expand Metrics**: Add more metric views for other business questions

---

## Related Documentation

- [12_METRIC_VIEWS_EXPLAINED.md](12_METRIC_VIEWS_EXPLAINED.md) - Deep dive into metric view concepts
- [13_METRIC_VIEWS_YAML_GUIDE.md](13_METRIC_VIEWS_YAML_GUIDE.md) - How to author metric views
- [14_METRIC_VIEWS_TROUBLESHOOTING.md](14_METRIC_VIEWS_TROUBLESHOOTING.md) - Common issues and solutions
- [validate_metric_views.sql](../sql_semantic_poc/validate_metric_views.sql) - SQL validation script

---

## Summary

**Metric views are working correctly when**:
- ✅ All 5 metric views exist and are queryable
- ✅ They return **aggregated** data (not detail rows)
- ✅ Totals match manual calculations from semantic views
- ✅ They appear in Databricks Metrics UI (if feature enabled)
- ✅ Business users can create visualizations without SQL

**The validation script provides a comprehensive test suite to verify all aspects of your metric view implementation.**
