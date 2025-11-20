-- ========================================
-- COMPREHENSIVE PERMISSION VERIFICATION
-- Run this after script 08_permissions to verify security model
-- ========================================

USE CATALOG cfascdodev_primary;

-- ========================================
-- 1. CATALOG-LEVEL PERMISSIONS
-- ========================================
SELECT
  '1. CATALOG PERMISSIONS' as check_section,
  principal,
  action_type,
  'Admins/Engineers should have MANAGE/OWNERSHIP' as expected_result
FROM (
  SHOW GRANTS ON CATALOG cfascdodev_primary
)
WHERE principal NOT LIKE 'd392185a%' -- Filter out system IDs for readability
ORDER BY principal;

-- ========================================
-- 2. SEMANTIC SCHEMA PERMISSIONS (Should be accessible)
-- ========================================
SELECT
  '2. SEMANTIC SCHEMA PERMISSIONS' as check_section,
  principal,
  action_type,
  object_type,
  'account users should have USAGE + SELECT on views' as expected_result
FROM (
  SHOW GRANTS ON SCHEMA cfascdodev_primary.invoice_semantic_poc
);

-- ========================================
-- 3. GOLD SCHEMA PERMISSIONS (Should be restricted)
-- ========================================
SELECT
  '3. GOLD SCHEMA PERMISSIONS' as check_section,
  principal,
  action_type,
  object_type,
  'account users should NOT have SELECT (or very limited)' as expected_result
FROM (
  SHOW GRANTS ON SCHEMA cfascdodev_primary.invoice_gold_semantic_poc
);

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
-- 6. CHECK CURRENT USER ROLE
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
-- 8. VERIFY NO FUTURE GRANTS ON GOLD TABLES
-- ========================================
SELECT
  '8. FUTURE GRANTS CHECK' as check_section,
  principal,
  action_type,
  'Future grants on gold tables should be REVOKED for account users' as expected_result
FROM (
  SHOW GRANTS ON SCHEMA cfascdodev_primary.invoice_gold_semantic_poc
)
WHERE principal = 'account users';

-- ========================================
-- SUMMARY: EXPECTED SECURITY MODEL
-- ========================================
-- ✓ Catalog: Admins have MANAGE/OWNERSHIP
-- ✓ Semantic Schema: account users have USAGE + SELECT on views
-- ✓ Gold Schema: account users have NO access (REVOKED)
-- ✓ Semantic Views: account users can SELECT
-- ✓ Gold Tables: Only admins can SELECT
-- ========================================
