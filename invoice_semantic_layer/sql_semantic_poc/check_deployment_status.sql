-- ========================================
-- DEPLOYMENT STATUS CHECK
-- Run this to see what has been created so far
-- ========================================

USE CATALOG cfascdodev_primary;

-- ========================================
-- 1. CHECK IF SCHEMAS EXIST
-- ========================================
SELECT 
  '1. SCHEMAS' as check_section,
  schema_name,
  schema_owner,
  comment
FROM information_schema.schemata
WHERE catalog_name = 'cfascdodev_primary'
  AND schema_name LIKE '%semantic_poc%'
ORDER BY schema_name;

-- Expected: 2 schemas
-- - invoice_gold_semantic_poc
-- - invoice_semantic_poc

-- ========================================
-- 2. CHECK GOLD TABLES
-- ========================================
SELECT 
  '2. GOLD TABLES' as check_section,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_gold_semantic_poc'
ORDER BY table_name;

-- Expected: 6 tables
-- - fact_invoice_line_semantic_poc
-- - dim_supplier_semantic_poc
-- - dim_item_semantic_poc
-- - dim_restaurant_semantic_poc
-- - dim_dc_semantic_poc
-- - dim_date_semantic_poc

-- ========================================
-- 3. CHECK SEMANTIC VIEWS
-- ========================================
SELECT 
  '3. SEMANTIC VIEWS' as check_section,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'v_%'
ORDER BY table_name;

-- Expected: 6 views
-- - v_invoice_lines_semantic_poc
-- - v_invoice_supplier_semantic_poc
-- - v_invoice_item_semantic_poc
-- - v_invoice_restaurant_semantic_poc
-- - v_invoice_dc_semantic_poc
-- - v_invoice_calendar_semantic_poc

-- ========================================
-- 4. CHECK REGISTRY TABLES
-- ========================================
SELECT 
  '4. REGISTRY TABLES' as check_section,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE '%_semantic_poc'
  AND table_name NOT LIKE 'v_%'
  AND table_name NOT LIKE 'mv_%'
ORDER BY table_name;

-- Expected: 3 tables
-- - relationships_semantic_poc
-- - metrics_semantic_poc
-- - synonyms_semantic_poc

-- ========================================
-- 5. CHECK METRIC VIEWS
-- ========================================
SELECT 
  '5. METRIC VIEWS' as check_section,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'mv_%'
ORDER BY table_name;

-- Expected: 5 metric views
-- - mv_invoice_supplier_semantic_poc
-- - mv_invoice_item_semantic_poc
-- - mv_invoice_restaurant_semantic_poc
-- - mv_invoice_dc_semantic_poc
-- - mv_invoice_calendar_semantic_poc

-- ========================================
-- 6. CHECK DATA IN GOLD TABLES
-- ========================================
SELECT 
  '6. DATA CHECK - FACT TABLE' as check_section,
  COUNT(*) as row_count,
  'Should have ~12 rows of sample data' as expected_result
FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc;

-- ========================================
-- DEPLOYMENT SUMMARY
-- ========================================
-- ✓ Section 1: Should show 2 schemas
-- ✓ Section 2: Should show 6 gold tables
-- ✓ Section 3: Should show 6 semantic views (YOUR ISSUE IS HERE)
-- ✓ Section 4: Should show 3 registry tables
-- ✓ Section 5: Should show 5 metric views
-- ✓ Section 6: Should show ~12 rows of data
--
-- If any section returns no rows, you need to run the corresponding script:
-- - No schemas → Run 01_schemas_semantic_poc.sql
-- - No gold tables → Run 02_gold_tables_semantic_poc.sql
-- - No data → Run 03_seed_data_semantic_poc.sql
-- - No registries → Run 04, 05, 06 (relationships, metrics, synonyms)
-- - No semantic views → Run 07_semantic_views_semantic_poc.sql ← YOUR ISSUE
-- - No metric views → Run 10_metric_views_semantic_poc.sql
-- ========================================
