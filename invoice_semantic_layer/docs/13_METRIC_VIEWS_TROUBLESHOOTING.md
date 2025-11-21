# Metric Views Troubleshooting Guide

## Common Issues and Solutions

This document covers common errors when creating Databricks metric views using YAML syntax.

---

## Issue 1: "Unrecognized field 'timestamp'" Error

### Error Message:
```
[METRIC_VIEW_INVALID_VIEW_DEFINITION] The metric view definition is invalid.
Reason: Failed to parse YAML: Unrecognized field "timestamp"
(class com.databricks.sql.serde.v11.MetricView),
not marked as ignorable (8 known properties: "measures", "version", "joins",
"source", "dimensions", "comment", "filter", "materialization")
```

### Root Cause:
The `timestamp` field is not supported in the current Databricks YAML metric view schema (version 1.1). This field may have been documented in preview documentation but is not yet available in production.

### Solution:
Instead of using `timestamp:` as a top-level field, add the date/time column as a **dimension**:

#### ❌ Incorrect (causes error):
```yaml
CREATE OR REPLACE VIEW mv_invoice_supplier_semantic_poc
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
timestamp: invoice_date  # ← This causes the error
dimensions:
  - name: Supplier Name
    expr: supplier_name
```

#### ✅ Correct (works):
```yaml
CREATE OR REPLACE VIEW mv_invoice_supplier_semantic_poc
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
dimensions:
  - name: Invoice Date  # ← Add date as first dimension
    expr: invoice_date
  - name: Supplier Name
    expr: supplier_name
```

### Impact:
- **Time-series functionality**: Still works - Invoice Date can be used for filtering and grouping
- **Metrics UI**: Date appears as a selectable dimension
- **Performance**: No impact - dates work the same way as dimensions

### Fixed in Commit:
`98fe5ff` - "Fix metric views YAML: remove unsupported timestamp field"

---

## Issue 2: "Unrecognized field 'owners'" or "'tags'" Error

### Error Message:
```
[METRIC_VIEW_INVALID_VIEW_DEFINITION] The metric view definition is invalid.
Reason: Failed to parse YAML: Unrecognized field "owners"
(class com.databricks.sql.serde.v11.MetricView),
not marked as ignorable (8 known properties: "measures", "version", "joins",
"source", "dimensions", "comment", "filter", "materialization")
```

### Root Cause:
The `owners` and `tags` fields are not supported in the current Databricks YAML metric view schema (version 1.1), despite being shown in some documentation examples.

### Solution:
Remove `owners:` and `tags:` blocks from the YAML:

#### ❌ Incorrect (causes error):
```yaml
measures:
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))
  - name: Invoice Line Count
    expr: COUNT(1)
owners:              # ← This causes the error
  - name: Finance Analytics
    email: finance.analytics@example.com
tags:                # ← This also causes the error
  - supplier-insights
$$;
```

#### ✅ Correct (works):
```yaml
measures:
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))
  - name: Invoice Line Count
    expr: COUNT(1)
$$;              # ← End immediately after measures
```

### Impact:
- **Metadata**: Owners and tags cannot be stored in metric view YAML (use external documentation or Unity Catalog tagging)
- **Governance**: Document ownership in comments or separate governance registry

### Fixed in Commit:
`4f92743` - "Remove unsupported owners and tags fields from metric views"

---

## Issue 3: YAML Indentation Errors

### Error Message:
```
Failed to parse YAML: while parsing a block mapping
 in 'string', line X, column Y:
```

### Root Cause:
YAML is whitespace-sensitive. Incorrect indentation breaks parsing.

### Solution:
Use exactly **2 spaces** for each indentation level (no tabs):

#### ❌ Incorrect:
```yaml
dimensions:
- name: Supplier Name    # ← Missing 2-space indent
  expr: supplier_name
measures:
    - name: Total Spend  # ← 4 spaces instead of 2
      expr: SUM(invoice_amount)
```

#### ✅ Correct:
```yaml
dimensions:
  - name: Supplier Name  # ← 2-space indent
    expr: supplier_name
measures:
  - name: Total Spend    # ← 2-space indent
    expr: SUM(invoice_amount)
```

---

## Issue 4: Missing Aggregation in Measures

### Error Message:
```
Metric expressions must include aggregation functions
```

### Root Cause:
Measures must contain aggregation functions (SUM, COUNT, AVG, MIN, MAX).

### Solution:

#### ❌ Incorrect:
```yaml
measures:
  - name: Invoice Amount
    expr: invoice_amount  # ← Missing aggregation
```

#### ✅ Correct:
```yaml
measures:
  - name: Total Invoice Amount
    expr: SUM(COALESCE(invoice_amount, 0))  # ← Has aggregation
```

---

## Issue 5: Source View Does Not Exist

### Error Message:
```
Table or view not found: cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
```

### Root Cause:
Metric views depend on semantic views. If the source view doesn't exist, metric view creation fails.

### Solution:
Ensure semantic views are created **before** metric views:

```sql
-- Step 1: Create semantic view (script 07)
CREATE OR REPLACE VIEW v_invoice_supplier_semantic_poc AS ...

-- Step 2: Create metric view (script 10)
CREATE OR REPLACE VIEW mv_invoice_supplier_semantic_poc
WITH METRICS ...
AS $$
source: cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
```

**Deployment order matters:**
1. ✅ `07_semantic_views_semantic_poc.sql` (creates source views)
2. ✅ `10_metric_views_semantic_poc.sql` (creates metric views)

---

## Issue 6: Invalid Expression Syntax

### Error Message:
```
Invalid expression: [SQL error details]
```

### Root Cause:
The `expr` field must contain valid SQL expressions that work against the source view.

### Solution:

#### ❌ Incorrect:
```yaml
dimensions:
  - name: Supplier Name
    expr: suppliers.supplier_name  # ← Table alias from source not visible
```

#### ✅ Correct:
```yaml
dimensions:
  - name: Supplier Name
    expr: supplier_name  # ← Use column as exposed by source view
```

**Rule**: Reference columns **as they appear in the source view**, not the underlying tables.

---

## Issue 7: Friendly Names with Special Characters

### Error Message:
```
Invalid dimension/measure name
```

### Root Cause:
Friendly names with special characters need proper quoting in queries.

### Solution:

Use backticks when querying metric views with spaces in names:

```sql
-- Friendly names in YAML
dimensions:
  - name: Supplier Name  # ← Has space
    expr: supplier_name

-- Querying (use backticks)
SELECT
  `Supplier Name`,      -- ← Backticks required
  `Total Invoice Amount`
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
```

---

## Issue 8: Version Mismatch

### Error Message:
```
Unsupported metric view version: X.X
```

### Root Cause:
Wrong version number specified in YAML.

### Solution:
Always use `version: 1.1` for current Databricks implementations:

```yaml
version: 1.1  # ← Use this version
comment: "Description"
source: catalog.schema.view
```

---

## Supported YAML Fields (Version 1.1)

Based on the error message, these are the **only** supported fields:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `version` | Yes | String | Must be "1.1" |
| `source` | Yes | String | Full path to source view (catalog.schema.view) |
| `dimensions` | No | Array | Attributes for grouping/filtering |
| `measures` | Yes | Array | Aggregated metrics (must include aggregation) |
| `comment` | No | String | Description shown in Metrics UI |
| `filter` | No | String | Optional WHERE clause applied to all queries |
| `joins` | No | Array | Join definitions (advanced usage) |
| `materialization` | No | Object | Materialization settings (advanced usage) |

### Fields NOT Supported (as of this POC):
- ❌ `timestamp` - Use as a dimension instead (causes parse error if included)
- ❌ `owners` - Not supported (causes parse error if included)
- ❌ `tags` - Not supported (causes parse error if included)

**Important**: Do NOT include `timestamp`, `owners`, or `tags` in the YAML - they will cause "Unrecognized field" errors and prevent metric view creation.

---

## Validation Checklist

Before running `10_metric_views_semantic_poc.sql`:

- [ ] Semantic views exist (run `07_semantic_views_semantic_poc.sql` first)
- [ ] YAML uses 2-space indentation
- [ ] No `timestamp:` field (use dimension instead)
- [ ] All measures include aggregation functions (SUM, COUNT, AVG, etc.)
- [ ] Version is set to `1.1`
- [ ] Source view path is correct and fully qualified
- [ ] Column expressions match source view column names
- [ ] Friendly names don't conflict with reserved keywords

---

## Testing a Metric View

After creating a metric view, test it:

```sql
-- 1. Verify it exists
SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc LIKE 'mv_%';

-- 2. Describe the metric view
DESCRIBE METRIC VIEW cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- 3. Query the metric view
SELECT
  `Invoice Date`,
  `Supplier Name`,
  `Total Invoice Amount`
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
WHERE `Invoice Date` >= '2024-01-01'
GROUP BY `Invoice Date`, `Supplier Name`
ORDER BY `Invoice Date`, `Total Invoice Amount` DESC;
```

---

## Debugging Steps

If metric view creation fails:

1. **Check Databricks version**:
   ```sql
   SELECT version();
   ```
   Ensure YAML metric views are supported

2. **Verify source view exists**:
   ```sql
   DESCRIBE cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;
   ```

3. **Test YAML syntax** by creating a minimal metric view:
   ```sql
   CREATE OR REPLACE VIEW test_mv
   WITH METRICS
   LANGUAGE YAML
   AS $$
   version: 1.1
   source: cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
   dimensions:
     - name: Test Dimension
       expr: supplier_name
   measures:
     - name: Test Measure
       expr: COUNT(1)
   $$;
   ```

4. **Drop and recreate** if needed:
   ```sql
   DROP VIEW IF EXISTS cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;
   -- Then re-run CREATE statement
   ```

---

## Related Documentation

- [11_METRIC_VIEWS_EXPLAINED.md](11_METRIC_VIEWS_EXPLAINED.md) - Complete guide to semantic vs metric views
- [12_METRIC_VIEWS_YAML_GUIDE.md](12_METRIC_VIEWS_YAML_GUIDE.md) - YAML syntax reference
- [06_SQL_RUNBOOK.md](06_SQL_RUNBOOK.md) - Deployment sequence
- [Databricks Docs](https://docs.databricks.com/aws/en/metric-views/create/sql) - Official documentation

---

## Getting Help

If issues persist:

1. Check Databricks workspace version and feature flags
2. Verify Databricks Metrics is enabled (Preview feature)
3. Review SQL execution logs in Databricks UI
4. Consult Databricks support for version-specific YAML schema

---

**Document Version**: 1.0
**Last Updated**: 2025-01-20
**Related Commit**: `98fe5ff`
