# Semantic Layer POC - Cleanup and Redeployment Guide

## Purpose
This guide provides a complete inventory of all objects created by the Semantic Layer POC and step-by-step instructions for cleanup and fresh deployment.

---

## 📊 Complete Object Inventory

### Summary
- **2 Schemas**
- **6 Gold Tables** (fact + 5 dimensions)
- **3 Registry Tables** (metadata)
- **6 Semantic Views**
- **Total: 17 objects** across 2 schemas

---

### 1. Schemas (2)

```
cfascdodev_primary.invoice_gold_semantic_poc
cfascdodev_primary.invoice_semantic_poc
```

---

### 2. Gold Tables (6) - in `invoice_gold_semantic_poc` schema

| # | Table Name | Type | Purpose |
|---|------------|------|---------|
| 1 | `fact_invoice_line_semantic_poc` | Fact | Invoice line-level transactions with measures |
| 2 | `dim_supplier_semantic_poc` | Dimension | Supplier attributes |
| 3 | `dim_item_semantic_poc` | Dimension | Item/product attributes |
| 4 | `dim_restaurant_semantic_poc` | Dimension | Restaurant location attributes |
| 5 | `dim_dc_semantic_poc` | Dimension | Distribution center attributes |
| 6 | `dim_date_semantic_poc` | Dimension | Calendar/fiscal date attributes |

**Full Paths:**
```
cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc
cfascdodev_primary.invoice_gold_semantic_poc.dim_supplier_semantic_poc
cfascdodev_primary.invoice_gold_semantic_poc.dim_item_semantic_poc
cfascdodev_primary.invoice_gold_semantic_poc.dim_restaurant_semantic_poc
cfascdodev_primary.invoice_gold_semantic_poc.dim_dc_semantic_poc
cfascdodev_primary.invoice_gold_semantic_poc.dim_date_semantic_poc
```

---

### 3. Registry Tables (3) - in `invoice_semantic_poc` schema

| # | Table Name | Purpose |
|---|------------|---------|
| 1 | `relationships_semantic_poc` | Stores fact-to-dimension join metadata for Genie |
| 2 | `metrics_semantic_poc` | Stores KPI definitions and SQL expressions |
| 3 | `synonyms_semantic_poc` | Stores business vocabulary mappings |

**Full Paths:**
```
cfascdodev_primary.invoice_semantic_poc.relationships_semantic_poc
cfascdodev_primary.invoice_semantic_poc.metrics_semantic_poc
cfascdodev_primary.invoice_semantic_poc.synonyms_semantic_poc
```

---

### 4. Semantic Views (6) - in `invoice_semantic_poc` schema

| # | View Name | Purpose |
|---|-----------|---------|
| 1 | `v_invoice_lines_semantic_poc` | Base view with all invoice line measures |
| 2 | `v_invoice_supplier_semantic_poc` | Invoice lines joined with supplier dimension |
| 3 | `v_invoice_item_semantic_poc` | Invoice lines joined with item dimension |
| 4 | `v_invoice_restaurant_semantic_poc` | Invoice lines joined with restaurant dimension |
| 5 | `v_invoice_dc_semantic_poc` | Invoice lines joined with DC dimension |
| 6 | `v_invoice_calendar_semantic_poc` | Invoice lines joined with date dimension |

**Full Paths:**
```
cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc
cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc
cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc
cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc
cfascdodev_primary.invoice_semantic_poc.v_invoice_calendar_semantic_poc
```

---

## 🗑️ CLEANUP SCRIPTS

### Option 1: Complete Cleanup (Recommended for Fresh Start)

Run this in Databricks SQL Editor to completely remove all POC objects:

```sql
-- ========================================
-- COMPLETE SEMANTIC LAYER POC CLEANUP
-- WARNING: This deletes ALL POC objects!
-- ========================================

USE CATALOG cfascdodev_primary;

-- Step 1: Drop all semantic views first (they depend on tables)
DROP VIEW IF EXISTS cfascdodev_primary.invoice_semantic_poc.v_invoice_lines_semantic_poc;
DROP VIEW IF EXISTS cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;
DROP VIEW IF EXISTS cfascdodev_primary.invoice_semantic_poc.v_invoice_item_semantic_poc;
DROP VIEW IF EXISTS cfascdodev_primary.invoice_semantic_poc.v_invoice_restaurant_semantic_poc;
DROP VIEW IF EXISTS cfascdodev_primary.invoice_semantic_poc.v_invoice_dc_semantic_poc;
DROP VIEW IF EXISTS cfascdodev_primary.invoice_semantic_poc.v_invoice_calendar_semantic_poc;

-- Step 2: Drop registry tables
DROP TABLE IF EXISTS cfascdodev_primary.invoice_semantic_poc.relationships_semantic_poc;
DROP TABLE IF EXISTS cfascdodev_primary.invoice_semantic_poc.metrics_semantic_poc;
DROP TABLE IF EXISTS cfascdodev_primary.invoice_semantic_poc.synonyms_semantic_poc;

-- Step 3: Drop gold tables
DROP TABLE IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc;
DROP TABLE IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc.dim_supplier_semantic_poc;
DROP TABLE IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc.dim_item_semantic_poc;
DROP TABLE IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc.dim_restaurant_semantic_poc;
DROP TABLE IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc.dim_dc_semantic_poc;
DROP TABLE IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc.dim_date_semantic_poc;

-- Step 4: Drop schemas (CASCADE will drop any remaining objects)
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_semantic_poc CASCADE;
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc CASCADE;

-- Step 5: Verify cleanup
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
-- Should return empty result
```

---

### Option 2: Schema-Level Cleanup (Fastest Method)

This drops the entire schemas and all contained objects:

```sql
-- ========================================
-- FAST CLEANUP: Drop schemas with CASCADE
-- ========================================

USE CATALOG cfascdodev_primary;

-- Drop semantic schema (includes all views and registry tables)
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_semantic_poc CASCADE;

-- Drop gold schema (includes all fact and dimension tables)
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc CASCADE;

-- Verify cleanup
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
```

---

### Option 3: Data-Only Cleanup (Keep Structure)

If you want to keep the tables/views but clear the data:

```sql
-- ========================================
-- CLEAR DATA ONLY (Keep table structure)
-- ========================================

USE CATALOG cfascdodev_primary;

-- Truncate gold tables (removes data, keeps structure)
TRUNCATE TABLE cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc;
TRUNCATE TABLE cfascdodev_primary.invoice_gold_semantic_poc.dim_supplier_semantic_poc;
TRUNCATE TABLE cfascdodev_primary.invoice_gold_semantic_poc.dim_item_semantic_poc;
TRUNCATE TABLE cfascdodev_primary.invoice_gold_semantic_poc.dim_restaurant_semantic_poc;
TRUNCATE TABLE cfascdodev_primary.invoice_gold_semantic_poc.dim_dc_semantic_poc;
TRUNCATE TABLE cfascdodev_primary.invoice_gold_semantic_poc.dim_date_semantic_poc;

-- Truncate registry tables
TRUNCATE TABLE cfascdodev_primary.invoice_semantic_poc.relationships_semantic_poc;
TRUNCATE TABLE cfascdodev_primary.invoice_semantic_poc.metrics_semantic_poc;
TRUNCATE TABLE cfascdodev_primary.invoice_semantic_poc.synonyms_semantic_poc;

-- Views don't store data, so no action needed
```

---

## ✅ Verification After Cleanup

Run these queries to confirm everything is deleted:

```sql
-- Check schemas are gone
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
-- Expected: Empty result

-- Try to query a table (should fail with "not found")
SELECT * FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc LIMIT 1;
-- Expected: Error - table or view not found

-- Check catalog still exists
SHOW CATALOGS LIKE 'cfascdodev_primary';
-- Expected: Shows catalog (we only deleted schemas, not the catalog)
```

---

## ⚠️ Important Notes Before Cleanup

### 1. Permissions Required
- You need `DROP` privileges on the schemas
- Requires `OWNERSHIP` or `MANAGE` on catalog `cfascdodev_primary`

### 2. No Undo
- `DROP` operations are **permanent**
- Seed data will be deleted (but can be recreated by re-running script 03)
- No production data is in POC schemas, so safe to delete

### 3. Dependencies
- Views must be dropped before tables (cleanup scripts handle this)
- Schemas must be empty before dropping (use CASCADE to force)

### 4. Genie Space Impact
- If you configured a Genie Space pointing to these views, it will break
- You'll need to reconfigure Genie after rebuilding

---

## 🔄 Fresh Start - Complete Redeployment Process

### Step 1: Run Cleanup
```sql
USE CATALOG cfascdodev_primary;
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_semantic_poc CASCADE;
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc CASCADE;
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
```

### Step 2: Verify Clean State
```sql
-- Should return empty
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
```

### Step 3: Choose Deployment Method

#### Option A: Manual Deployment (Step-by-Step Learning)

Run scripts in order from SQL Editor:

1. **01_schemas_semantic_poc.sql** - Create schemas
2. **02_gold_tables_semantic_poc.sql** - Create fact and dimension tables
3. **03_seed_data_semantic_poc.sql** - Load sample data
4. **04_relationship_registry_semantic_poc.sql** - Create relationship registry
5. **05_metrics_registry_semantic_poc.sql** - Create metrics registry
6. **06_synonyms_registry_semantic_poc.sql** - Create synonyms registry
7. **07_semantic_views_semantic_poc.sql** - Create semantic views
8. **08_permissions_semantic_poc.sql** - Apply governance
9. **09_validation_semantic_poc.sql** - Run validation checks

**Verification after each script:**
```sql
-- After script 01
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';

-- After script 02
SHOW TABLES IN cfascdodev_primary.invoice_gold_semantic_poc;

-- After script 03
SELECT COUNT(*) FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc;

-- After script 07
SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc;

-- After script 08
SHOW GRANTS ON SCHEMA cfascdodev_primary.invoice_semantic_poc;
```

---

#### Option B: Automated Deployment (Production-Ready)

```bash
# Navigate to infra directory
cd c:\invoice_semantic_layer\infra

# Authenticate (one-time)
databricks auth login

# Validate bundle configuration
databricks bundle validate

# Deploy the bundle
databricks bundle deploy

# Run the deployment job
databricks bundle run semantic_layer_deploy

# Monitor progress
databricks jobs runs list --job-name "Invoice Analytics Semantic PoC Deploy"
```

**Monitor in UI:**
1. Navigate to **Workflows** → **Jobs**
2. Find **"Invoice Analytics Semantic PoC Deploy"**
3. Click on the latest run
4. Watch each task complete (green checkmarks)

---

### Step 4: Post-Deployment Validation

```sql
-- 1. Verify all schemas exist
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
-- Expected: 2 schemas

-- 2. Verify gold tables
SHOW TABLES IN cfascdodev_primary.invoice_gold_semantic_poc;
-- Expected: 6 tables

-- 3. Verify registry tables
SHOW TABLES IN cfascdodev_primary.invoice_semantic_poc;
-- Expected: 3 tables (relationships, metrics, synonyms)

-- 4. Verify semantic views
SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc;
-- Expected: 6 views

-- 5. Verify data loaded
SELECT
  'fact_invoice_line' as table_name,
  COUNT(*) as row_count
FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc
UNION ALL
SELECT 'dim_supplier', COUNT(*)
FROM cfascdodev_primary.invoice_gold_semantic_poc.dim_supplier_semantic_poc
UNION ALL
SELECT 'dim_item', COUNT(*)
FROM cfascdodev_primary.invoice_gold_semantic_poc.dim_item_semantic_poc
UNION ALL
SELECT 'dim_restaurant', COUNT(*)
FROM cfascdodev_primary.invoice_gold_semantic_poc.dim_restaurant_semantic_poc
UNION ALL
SELECT 'dim_dc', COUNT(*)
FROM cfascdodev_primary.invoice_gold_semantic_poc.dim_dc_semantic_poc
UNION ALL
SELECT 'dim_date', COUNT(*)
FROM cfascdodev_primary.invoice_gold_semantic_poc.dim_date_semantic_poc;
-- Expected: fact ~12 rows, each dimension 3-4 rows

-- 6. Test semantic query
SELECT
  supplier_name,
  SUM(invoice_amount) as total_spend,
  SUM(freight_cost) as total_freight,
  SUM(tax_cost) as total_tax,
  COUNT(*) as invoice_line_count
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY total_spend DESC;
-- Expected: 3 suppliers with spend data

-- 7. Verify permissions
SHOW GRANTS ON SCHEMA cfascdodev_primary.invoice_semantic_poc;
-- Expected: account users has SELECT on views

-- 8. Check validation results
-- Review output from script 09_validation_semantic_poc.sql
-- All checks should show PASS status
```

---

## 📊 Understanding Each Deployment Step

### Script 01: Schemas
- **Creates**: 2 empty schemas
- **Time**: < 5 seconds
- **Safe to re-run**: Yes

### Script 02: Gold Tables
- **Creates**: 6 empty Delta tables with schema definitions
- **Time**: 10-20 seconds
- **Safe to re-run**: Yes (uses CREATE OR REPLACE)
- **Note**: Tables have no data yet

### Script 03: Seed Data
- **Loads**: Sample data into all 6 gold tables
- **Time**: 15-30 seconds
- **Safe to re-run**: Yes (INSERT OVERWRITE replaces data)
- **Data loaded**:
  - 3 suppliers
  - 3 items
  - 3 restaurants
  - 3 distribution centers
  - Date range: 2024-01-05 to 2024-01-08
  - ~12 fact rows

### Script 04: Relationship Registry
- **Creates**: Registry table with 5 fact-to-dimension relationships
- **Time**: 5-10 seconds
- **Safe to re-run**: Yes

### Script 05: Metrics Registry
- **Creates**: Registry with KPI definitions
- **Time**: 5-10 seconds
- **Key metrics**: invoice_amount, total_spend, freight_cost, tax_cost, line_count
- **Safe to re-run**: Yes

### Script 06: Synonyms Registry
- **Creates**: Business vocabulary mappings
- **Time**: 5-10 seconds
- **Examples**: "store" → restaurant_name, "spend" → invoice_amount
- **Safe to re-run**: Yes

### Script 07: Semantic Views
- **Creates**: 6 views joining fact to dimensions
- **Time**: 10-20 seconds
- **Safe to re-run**: Yes (CREATE OR REPLACE)
- **Purpose**: Analyst-facing layer, hides gold complexity

### Script 08: Permissions
- **Grants**: SELECT on semantic views to account users
- **Revokes**: Access to gold tables
- **Time**: 5-10 seconds
- **Requires**: MANAGE/OWNERSHIP on catalog
- **Safe to re-run**: Yes (idempotent)

### Script 09: Validation
- **Checks**: Comment coverage, relationship integrity, metric accuracy
- **Time**: 30-60 seconds
- **Safe to re-run**: Yes (read-only queries)
- **Expected result**: All checks show PASS

---

## 🎯 Quick Reference Commands

### Fastest Cleanup (Copy-Paste Ready)
```sql
USE CATALOG cfascdodev_primary;
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_semantic_poc CASCADE;
DROP SCHEMA IF EXISTS cfascdodev_primary.invoice_gold_semantic_poc CASCADE;
SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
```

### Fastest Verification (Copy-Paste Ready)
```sql
-- All-in-one verification
USE CATALOG cfascdodev_primary;

SHOW SCHEMAS IN cfascdodev_primary LIKE '*semantic_poc*';
SHOW TABLES IN cfascdodev_primary.invoice_gold_semantic_poc;
SHOW TABLES IN cfascdodev_primary.invoice_semantic_poc;
SHOW VIEWS IN cfascdodev_primary.invoice_semantic_poc;

SELECT 'fact' as obj, COUNT(*) as rows FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc
UNION ALL SELECT 'supplier_view', COUNT(*) FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;
```

---

## 🔧 Troubleshooting Common Issues

### Issue: "Insufficient privileges" during cleanup
**Solution:**
```sql
-- Check your privileges
SHOW GRANTS ON CATALOG cfascdodev_primary;
-- Need OWNERSHIP or MANAGE privileges
-- Contact your admin if missing
```

### Issue: "Schema not empty" when dropping
**Solution:**
```sql
-- Use CASCADE to force drop
DROP SCHEMA cfascdodev_primary.invoice_semantic_poc CASCADE;
```

### Issue: Cleanup appears successful but objects still exist
**Solution:**
```sql
-- Check if objects exist in different catalog
SHOW CATALOGS;
USE CATALOG <correct_catalog_name>;
-- Re-run cleanup script
```

### Issue: Redeployment fails at permissions step (script 08)
**Solution:**
```sql
-- Check if you have MANAGE privileges
SHOW GRANTS ON CATALOG cfascdodev_primary;

-- If using different principal than 'account users', edit script 08
-- Replace 'account users' with your group name
```

---

## 📚 Related Documentation

- [08_SQL_RUNBOOK.md](08_SQL_RUNBOOK.md) - Detailed explanation of each SQL script
- [11_DAB_FLOW.md](11_DAB_FLOW.md) - Databricks Asset Bundle automation guide
- [16_GENIE_SPACE_SETUP.md](16_GENIE_SPACE_SETUP.md) - Genie configuration after deployment
- [README.md](README.md) - Complete deployment guide and overview

---

## 💡 Pro Tips

1. **Learning the POC**: Use manual deployment first to understand each step
2. **Repeated deployments**: Switch to automated DAB approach
3. **Testing changes**: Use data-only cleanup (Option 3) to preserve structure
4. **Production promotion**: Use DAB with environment-specific variables
5. **Validation first**: Always review script 09 output before sharing with analysts

---

**Last Updated**: 2025-01-20
**Maintained by**: Data Engineering Team
