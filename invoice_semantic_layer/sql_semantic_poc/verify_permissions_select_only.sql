-- ========================================
-- PERMISSION VERIFICATION (SELECT-only version)
-- This version uses only SELECT statements and can run all at once
-- For SHOW GRANTS commands, see verify_permissions.sql
-- ========================================

USE CATALOG cfascdodev_primary;

-- ========================================
-- 1. VERIFY SEMANTIC VIEWS ARE ACCESSIBLE
-- ========================================
SELECT
  '1. SEMANTIC VIEWS ACCESS CHECK' as check_section,
  'Testing if semantic views are queryable' as test_description,
  COUNT(*) as row_count,
  CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;

-- ========================================
-- 2. CHECK ALL SEMANTIC VIEWS EXIST
-- ========================================
SELECT
  '2. SEMANTIC VIEWS INVENTORY' as check_section,
  table_name,
  table_type,
  'Should see 6 semantic views starting with v_' as expected_result
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'v_%'
ORDER BY table_name;

-- ========================================
-- 3. VERIFY GOLD TABLES EXIST (May fail for analysts)
-- ========================================
SELECT
  '3. GOLD TABLES INVENTORY' as check_section,
  table_name,
  table_type,
  'Admins see 6 tables | Analysts may get permission error' as expected_result
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_gold_semantic_poc'
ORDER BY table_name;

-- ========================================
-- 4. CHECK CURRENT USER INFO
-- ========================================
SELECT
  '4. CURRENT USER INFO' as check_section,
  current_user() as current_user,
  current_catalog() as current_catalog,
  current_schema() as current_schema;

-- ========================================
-- 5. DETAILED VIEW GRANTS (from system catalog)
-- ========================================
SELECT
  '5. SEMANTIC VIEW GRANTS' as check_section,
  table_schema,
  table_name,
  privilege_type,
  grantee,
  is_grantable
FROM system.information_schema.table_privileges
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'v_%'
ORDER BY table_name, grantee;

-- ========================================
-- 6. CHECK SCHEMA GRANTS (from system catalog)
-- ========================================
SELECT
  '6. SCHEMA PRIVILEGES' as check_section,
  schema_name,
  privilege_type,
  grantee,
  is_grantable
FROM system.information_schema.schema_privileges
WHERE catalog_name = 'cfascdodev_primary'
  AND schema_name IN ('invoice_semantic_poc', 'invoice_gold_semantic_poc')
ORDER BY schema_name, grantee;

-- ========================================
-- 7. TEST DATA ACCESS - SEMANTIC VIEW
-- ========================================
SELECT
  '7. SEMANTIC VIEW DATA SAMPLE' as check_section,
  supplier_name,
  SUM(total_cost) as total_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_name
ORDER BY total_spend DESC
LIMIT 5;

-- ========================================
-- 8. TEST DATA ACCESS - GOLD TABLE (May fail for analysts)
-- ========================================
-- Comment this out if you're testing as an analyst
SELECT
  '8. GOLD TABLE DATA SAMPLE' as check_section,
  COUNT(*) as row_count,
  'Admins: Should see data | Analysts: Should FAIL' as expected_result
FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc;

-- ========================================
-- VERIFICATION SUMMARY
-- ========================================
-- ✓ Section 1: PASS = Semantic views are accessible
-- ✓ Section 2: Should show 6 semantic views
-- ✓ Section 3: Should show 6 gold tables (or fail for analysts)
-- ✓ Section 4: Shows your current user
-- ✓ Section 5: Shows who can access semantic views
-- ✓ Section 6: Shows schema-level permissions
-- ✓ Section 7: Sample data from semantic view (should work)
-- ✓ Section 8: Sample data from gold table (may fail for analysts)
-- ========================================
