# Invoice Analytics Semantic Layer POC - Quick Start Guide

## 5-Minute Quick Start for Stakeholders

This guide provides the fastest path to deploying and exploring the Invoice Analytics Semantic Layer POC on Databricks.

---

## What This POC Demonstrates

The Invoice Analytics Semantic Layer POC showcases:

- **Governed Metrics**: Consistent business metrics across all teams
- **Self-Service Analytics**: Business users can query data without SQL expertise
- **Unified Data Access**: Single source of truth for invoice analytics
- **Natural Language Queries**: Ask questions in plain English using Databricks Genie

**Environment**: Databricks Unity Catalog (`cfascdodev_primary` catalog)

---

## Prerequisites (2 minutes)

Before starting, verify access to:

1. **Databricks Workspace**: Access to `cfascdodev_primary` catalog
2. **SQL Warehouse**: `General Purpose` warehouse (or equivalent)
3. **Permissions**:
   - CREATE SCHEMA on catalog
   - USE CATALOG on `cfascdodev_primary`
   - Admin or power user role

**Verify access**:
```sql
-- Run this in Databricks SQL Editor
SELECT current_catalog(), current_user();
USE CATALOG cfascdodev_primary;
```

If this succeeds, proceed to deployment.

---

## Deployment Options

### Option 1: Automated Deployment (Recommended - 5 minutes)

**For DevOps/Platform Engineers**:

```bash
# 1. Clone repository
git clone https://github.com/adarch-gif/semantic_layer_poc.git
cd semantic_layer_poc/infra

# 2. Deploy using Databricks Asset Bundle
databricks bundle deploy

# 3. Run deployment job
databricks bundle run semantic_layer_deploy
```

**Expected result**: All 22 objects created automatically (2 schemas, 6 gold tables, 6 semantic views, 5 metric views, 3 registries).

📖 **Detailed guide**: [08_DAB_FLOW.md](08_DAB_FLOW.md)

---

### Option 2: Manual UI Deployment (15 minutes)

**For Business Analysts/Data Engineers**:

1. **Open Databricks SQL Editor**
2. **Set catalog**:
   ```sql
   USE CATALOG cfascdodev_primary;
   ```

3. **Run scripts in order** (copy/paste from `/sql_semantic_poc/`):

| Script | Purpose | Time |
|--------|---------|------|
| `01_create_schema_gold_semantic_poc.sql` | Create gold schema | 10s |
| `02_fact_invoice_line_semantic_poc.sql` | Create fact table | 30s |
| `03_dim_supplier_semantic_poc.sql` | Create supplier dimension | 20s |
| `04_dim_item_semantic_poc.sql` | Create item dimension | 20s |
| `05_dim_restaurant_semantic_poc.sql` | Create restaurant dimension | 20s |
| `06_dim_distribution_center_semantic_poc.sql` | Create DC dimension | 20s |
| `07_dim_calendar_semantic_poc.sql` | Create calendar dimension | 20s |
| `08_create_schema_semantic_poc.sql` | Create semantic schema | 10s |
| `09_semantic_views_semantic_poc.sql` | Create 6 semantic views | 1min |
| `10_metric_views_semantic_poc.sql` | Create 5 metric views | 1min |
| `11_metadata_registries_semantic_poc.sql` | Create metadata registries | 30s |
| `12_permissions_semantic_poc.sql` | Set permissions | 30s |

**Total time**: ~6 minutes

📖 **Detailed walkthrough**: [04_DEPLOYMENT_WALKTHROUGH.md](04_DEPLOYMENT_WALKTHROUGH.md)

---

## Verification (2 minutes)

After deployment, verify everything works:

### 1. Check Schemas Exist

```sql
USE CATALOG cfascdodev_primary;

-- Should show 2 schemas
SHOW SCHEMAS LIKE '*semantic_poc*';
```

**Expected result**:
- `invoice_gold_semantic_poc`
- `invoice_semantic_poc`

### 2. Check Semantic Views Exist

```sql
-- Should show 6 views (v_invoice_*)
SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc LIKE 'v_%';
```

**Expected views**:
- `v_invoice_supplier_semantic_poc`
- `v_invoice_item_semantic_poc`
- `v_invoice_restaurant_semantic_poc`
- `v_invoice_dc_semantic_poc`
- `v_invoice_calendar_semantic_poc`
- `v_invoice_gold_complete_semantic_poc`

### 3. Query Semantic View (Returns Data)

```sql
-- Query supplier view - should return ~12 rows
SELECT
  invoice_date,
  supplier_name,
  SUM(invoice_amount) as total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY invoice_date, supplier_name
ORDER BY invoice_date, total_spend DESC;
```

**Expected result**: Rows showing invoice data from 2024-01-05 to 2024-01-08 for 3 suppliers (Fresh Farms, Ocean Catch, Spice Route).

### 4. Check Metric Views Exist

```sql
-- Should show 5 metric views (mv_invoice_*)
SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc LIKE 'mv_%';
```

**Expected metric views**:
- `mv_invoice_supplier_semantic_poc`
- `mv_invoice_item_semantic_poc`
- `mv_invoice_restaurant_semantic_poc`
- `mv_invoice_dc_semantic_poc`
- `mv_invoice_calendar_semantic_poc`

### 5. Query Metric View (Returns Data)

```sql
-- Query metric view using friendly names
SELECT
  `Invoice Date`,
  `Supplier Name`,
  `Total Invoice Amount`,
  `Invoice Line Count`
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
WHERE `Invoice Date` >= '2024-01-05'
ORDER BY `Invoice Date`, `Total Invoice Amount` DESC;
```

**Expected result**: Aggregated metrics with friendly column names.

---

## Important: CREATE VIEW vs SELECT FROM View

**Common confusion**: Running a CREATE VIEW statement shows "No rows returned" - this is **correct and expected**.

### Why "No rows returned" is Normal

```sql
-- This CREATES the view (defines a recipe) - returns NO DATA
CREATE OR REPLACE VIEW my_view AS
SELECT * FROM table;
-- Result: "No rows returned" ✓ EXPECTED

-- This QUERIES the view (uses the recipe) - returns DATA
SELECT * FROM my_view LIMIT 10;
-- Result: Actual rows ✓ EXPECTED
```

**Analogy**:
- `CREATE VIEW` = Writing down a recipe (no food produced)
- `SELECT FROM view` = Cooking the recipe (food is produced)

📖 **Complete explanation**: [00_UNDERSTANDING_VIEWS_AND_QUERIES.md](00_UNDERSTANDING_VIEWS_AND_QUERIES.md)

---

## Sample Queries to Explore

### Query 1: Top Suppliers by Spend

```sql
SELECT
  supplier_name,
  SUM(invoice_amount) as total_spend,
  COUNT(*) as invoice_count
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY total_spend DESC;
```

### Query 2: Daily Spend Trends

```sql
SELECT
  invoice_date,
  SUM(invoice_amount) as daily_spend,
  COUNT(DISTINCT supplier_id) as supplier_count
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY invoice_date
ORDER BY invoice_date;
```

### Query 3: Restaurant Spend by Region

```sql
SELECT
  restaurant_region,
  restaurant_name,
  SUM(invoice_amount) as region_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc
GROUP BY restaurant_region, restaurant_name
ORDER BY restaurant_region, region_spend DESC;
```

### Query 4: Using Metric View Friendly Names

```sql
SELECT
  `Supplier Name`,
  `Total Net Spend`,
  `Total Invoice Amount`,
  `Invoice Line Count`
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
ORDER BY `Total Invoice Amount` DESC;
```

---

## Sample Data Overview

The POC includes realistic sample data:

| Dimension | Count | Examples |
|-----------|-------|----------|
| **Suppliers** | 3 | Fresh Farms, Ocean Catch, Spice Route |
| **Items** | 3 | Lettuce (produce), Salmon (seafood), Cumin (spice) |
| **Restaurants** | 3 | Atlanta, Dallas, Los Angeles |
| **Distribution Centers** | 3 | ATL, DFW, LAX |
| **Date Range** | 4 days | 2024-01-05 to 2024-01-08 |
| **Invoice Lines** | ~12 rows | Realistic transaction data |

**Total Objects Created**: 22 (2 schemas, 6 gold tables, 6 semantic views, 5 metric views, 3 registries)

---

## Databricks Genie Setup (Optional - 10 minutes)

To enable natural language queries:

1. **Create Genie Space** in Databricks UI
2. **Add semantic views** as data sources:
   - `v_invoice_supplier_semantic_poc`
   - `v_invoice_item_semantic_poc`
   - `v_invoice_restaurant_semantic_poc`
3. **Upload metadata registries**:
   - Relationships registry
   - Metrics registry
   - Synonyms registry

📖 **Detailed setup**: [07_GENIE_SPACE_SETUP.md](07_GENIE_SPACE_SETUP.md)

**Example Genie questions**:
- "What is total spend by supplier?"
- "Show me invoice trends over time"
- "Which restaurant has the highest spend?"

---

## Architecture Overview

The POC implements a three-layer architecture:

```
┌─────────────────────────────────────────────────────────┐
│  CONSUMPTION LAYER (Self-Service Analytics)             │
│  - Dashboards (PowerBI, Tableau)                        │
│  - Genie Natural Language Queries                       │
│  - Ad-hoc SQL Queries                                   │
└─────────────────────────────────────────────────────────┘
                          ▲
                          │ Query
                          │
┌─────────────────────────────────────────────────────────┐
│  SEMANTIC LAYER (invoice_semantic_poc schema)           │
│  - 6 Semantic Views (SQL) - Flexible querying           │
│  - 5 Metric Views (YAML) - Governed metrics             │
│  - 3 Metadata Registries - Genie context                │
└─────────────────────────────────────────────────────────┘
                          ▲
                          │ Read
                          │
┌─────────────────────────────────────────────────────────┐
│  GOLD LAYER (invoice_gold_semantic_poc schema)          │
│  - 1 Fact Table: fact_invoice_line                      │
│  - 5 Dimension Tables: supplier, item, restaurant, etc. │
│  - Star Schema Design                                   │
└─────────────────────────────────────────────────────────┘
```

📖 **Detailed architecture**: [01_ARCHITECTURE_OVERVIEW.md](01_ARCHITECTURE_OVERVIEW.md)

---

## Key Concepts

### Semantic Views (SQL)
- **Purpose**: Flexible ad-hoc analytics
- **Technology**: Standard SQL CREATE VIEW
- **Use case**: Data analysts exploring data
- **Example**: `v_invoice_supplier_semantic_poc`

### Metric Views (YAML)
- **Purpose**: Governed, consistent metrics
- **Technology**: Databricks YAML metric views
- **Use case**: Dashboards and executive reporting
- **Example**: `mv_invoice_supplier_semantic_poc`

📖 **Complete comparison**: [11_METRIC_VIEWS_EXPLAINED.md](11_METRIC_VIEWS_EXPLAINED.md)

---

## Permissions Model

The POC implements a governed security model:

| User Role | Gold Tables | Semantic Views | Metric Views |
|-----------|-------------|----------------|--------------|
| **Business Analysts** | ❌ No access | ✅ SELECT | ✅ SELECT |
| **Data Engineers** | ✅ Full access | ✅ Full access | ✅ Full access |
| **Executives** | ❌ No access | ✅ SELECT | ✅ SELECT |

**Design principle**: Users access curated semantic layer, not raw gold tables.

📖 **Permission verification**: Run [verify_permissions.sql](../sql_semantic_poc/verify_permissions.sql)

---

## Success Criteria

The POC deployment is successful when:

- ✅ All 22 objects created without errors
- ✅ Semantic views return data when queried
- ✅ Metric views return data when queried
- ✅ Permissions properly restrict gold table access
- ✅ Genie can answer benchmark questions
- ✅ Comment coverage ≥95% on all objects

**Run comprehensive validation**: [00_UNDERSTANDING_VIEWS_AND_QUERIES.md](00_UNDERSTANDING_VIEWS_AND_QUERIES.md) - Section "Complete Verification"

---

## Common Issues

### Issue: "No rows returned" after CREATE VIEW
**Solution**: This is expected. Use `SELECT * FROM view_name` to see data.

### Issue: "Table or view not found"
**Solution**: Verify schema exists and use fully qualified names:
```sql
SELECT * FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;
```

### Issue: "Permission denied"
**Solution**: Verify permissions using [verify_permissions.sql](../sql_semantic_poc/verify_permissions.sql)

### Issue: YAML parsing errors in metric views
**Solution**: Check [13_METRIC_VIEWS_TROUBLESHOOTING.md](13_METRIC_VIEWS_TROUBLESHOOTING.md)

---

## Cleanup (If Needed)

To remove all POC objects and start fresh:

```sql
USE CATALOG cfascdodev_primary;

-- Drop both schemas and all contained objects
DROP SCHEMA IF EXISTS invoice_semantic_poc CASCADE;
DROP SCHEMA IF EXISTS invoice_gold_semantic_poc CASCADE;

-- Verify cleanup
SHOW SCHEMAS LIKE '*semantic_poc*';
```

📖 **Complete cleanup guide**: [14_CLEANUP_AND_REDEPLOY_GUIDE.md](14_CLEANUP_AND_REDEPLOY_GUIDE.md)

---

## Next Steps

After completing this quick start:

1. **Business Stakeholders**: Read [01_ARCHITECTURE_OVERVIEW.md](01_ARCHITECTURE_OVERVIEW.md) for strategic context
2. **Data Analysts**: Explore [11_METRIC_VIEWS_EXPLAINED.md](11_METRIC_VIEWS_EXPLAINED.md) to understand querying options
3. **Data Engineers**: Review [02_ARCHITECTURE_DETAILED.md](02_ARCHITECTURE_DETAILED.md) for technical details
4. **Platform Engineers**: Study [08_DAB_FLOW.md](08_DAB_FLOW.md) for automation

---

## Getting Help

### Documentation Resources

- **Master Navigation**: [00_README_START_HERE.md](00_README_START_HERE.md)
- **Understanding Views**: [00_UNDERSTANDING_VIEWS_AND_QUERIES.md](00_UNDERSTANDING_VIEWS_AND_QUERIES.md)
- **Deployment Guide**: [04_DEPLOYMENT_WALKTHROUGH.md](04_DEPLOYMENT_WALKTHROUGH.md)
- **SQL Reference**: [06_SQL_RUNBOOK.md](06_SQL_RUNBOOK.md)
- **Troubleshooting**: [13_METRIC_VIEWS_TROUBLESHOOTING.md](13_METRIC_VIEWS_TROUBLESHOOTING.md)

### External Resources

- **Databricks Documentation**: https://docs.databricks.com/
- **Metric Views**: https://docs.databricks.com/aws/en/metric-views/create/sql
- **Unity Catalog**: https://docs.databricks.com/data-governance/unity-catalog/
- **Genie**: https://docs.databricks.com/genie/

---

## Summary: What Was Accomplished

After completing this quick start, the following has been deployed:

**Infrastructure**:
- 2 schemas (gold and semantic)
- 1 fact table with ~12 invoice line rows
- 5 dimension tables (supplier, item, restaurant, DC, calendar)

**Semantic Layer**:
- 6 semantic views for flexible analytics
- 5 metric views with governed metrics
- 3 metadata registries for Genie integration

**Capabilities Enabled**:
- ✅ Self-service analytics for business users
- ✅ Governed metrics for consistent reporting
- ✅ Natural language queries via Genie (optional)
- ✅ Role-based access control

**Time Investment**:
- Automated deployment: 5 minutes
- Manual deployment: 15 minutes
- Verification: 2 minutes
- Total: **7-17 minutes** to full working POC

---

**Document Version**: 1.0
**Last Updated**: 2025-01-20
**Intended Audience**: All stakeholders (Business, Technical, Executive)

---

**Ready to dive deeper?** Return to [00_README_START_HERE.md](00_README_START_HERE.md) for complete documentation navigation.
