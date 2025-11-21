-- ========================================
-- COMPREHENSIVE PERMISSION VERIFICATION
-- Run this after script 08_permissions to verify security model
-- ========================================
-- IMPORTANT: Run each section separately in Databricks SQL Editor
-- SHOW GRANTS statements cannot be used in subqueries
-- ========================================

USE CATALOG cfascdodev_primary;

-- ========================================
-- 1. CATALOG-LEVEL PERMISSIONS
-- ========================================
-- Run this separately:
SHOW GRANTS ON CATALOG cfascdodev_primary;
-- Expected: Admins/Engineers should have MANAGE/OWNERSHIP

-- ========================================
-- 2. SEMANTIC SCHEMA PERMISSIONS (Should be accessible)
-- ========================================
-- Run this separately:
SHOW GRANTS ON SCHEMA cfascdodev_primary.invoice_semantic_poc;
-- Expected: account users should have USAGE + SELECT

-- ========================================
-- 3. GOLD SCHEMA PERMISSIONS (Should be restricted)
-- ========================================
-- Run this separately:
SHOW GRANTS ON SCHEMA cfascdodev_primary.invoice_gold_semantic_poc;
-- Expected: account users should NOT have SELECT (or very limited)

-- ========================================
-- 4. VERIFY SEMANTIC VIEWS ARE ACCESSIBLE
-- ========================================
SELECT
  '4. SEMANTIC VIEWS ACCESS CHECK' as check_section,
  'Testing if semantic views are queryable' as test_description,
  COUNT(*) as row_count,
  'Should return >0 if accessible' as expected_result
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;

-- ========================================
-- 5. VERIFY GOLD TABLES ACCESS (Should depend on role)
-- ========================================
-- This will succeed for admins, fail for regular analysts
SELECT
  '5. GOLD TABLES ACCESS CHECK' as check_section,
  'Testing if gold tables are accessible' as test_description,
  COUNT(*) as row_count,
  'Admins: >0 | Analysts: Should FAIL with permission error' as expected_result
FROM cfascdodev_primary.invoice_gold_semantic_poc.fact_invoice_line_semantic_poc;

-- ========================================
-- 6. CHECK CURRENT USER INFO
-- ========================================
SELECT
  '6. CURRENT USER INFO' as check_section,
  current_user() as current_user,
  current_catalog() as current_catalog,
  current_schema() as current_schema,
  'Verify you are testing with correct user' as expected_result;

-- ========================================
-- 7. DETAILED VIEW GRANTS
-- ========================================
SELECT
  '7. SEMANTIC VIEW GRANTS' as check_section,
  table_schema,
  table_name,
  privilege_type,
  grantee,
  'All semantic views should grant SELECT to account users' as expected_result
FROM system.information_schema.table_privileges
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'v_%'
ORDER BY table_name, grantee;

-- ========================================
-- 8. CHECK INDIVIDUAL SEMANTIC VIEW PERMISSIONS
-- ========================================
SHOW GRANTS ON VIEW cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;
-- Expected: account users should have SELECT

-- ========================================
-- SUMMARY: EXPECTED SECURITY MODEL
-- ========================================
-- ✓ Catalog: Admins have MANAGE/OWNERSHIP
-- ✓ Semantic Schema: account users have USAGE + SELECT
-- ✓ Gold Schema: account users have NO access (REVOKED)
-- ✓ Semantic Views: account users can SELECT
-- ✓ Gold Tables: Only admins can SELECT
-- ========================================
