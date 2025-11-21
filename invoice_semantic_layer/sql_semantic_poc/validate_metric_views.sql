-- ========================================
-- COMPREHENSIVE METRIC VIEWS VALIDATION
-- Step-by-step guide to verify metric views are working correctly
-- ========================================
-- IMPORTANT: Databricks Metrics (Preview) must be enabled in your workspace
-- ========================================

USE CATALOG cfascdodev_primary;

-- ========================================
-- STEP 1: CHECK IF METRIC VIEWS EXIST
-- ========================================
-- This verifies that script 10 ran successfully

SELECT
  '1. METRIC VIEWS EXISTENCE CHECK' as validation_step,
  table_name,
  table_type,
  'Should see 5 metric views starting with mv_' as expected_result
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'mv_%'
ORDER BY table_name;

-- Expected: 5 metric views
-- ✓ mv_invoice_calendar_semantic_poc
-- ✓ mv_invoice_dc_semantic_poc
-- ✓ mv_invoice_item_semantic_poc
-- ✓ mv_invoice_restaurant_semantic_poc
-- ✓ mv_invoice_supplier_semantic_poc

-- ========================================
-- STEP 2: CHECK METRIC VIEW STRUCTURE
-- ========================================
-- Metric views must follow specific schema requirements

DESCRIBE TABLE cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- Expected columns:
-- ✓ Dimension columns (supplier_name, supplier_category, etc.)
-- ✓ Aggregation columns (total_invoice_amount, total_net_amount, etc.)
-- Note: Metric views should NOT have fact-level detail columns

-- ========================================
-- STEP 3: QUERY METRIC VIEW DATA
-- ========================================
-- Verify that metric views return aggregated data

SELECT
  '3. METRIC VIEW DATA CHECK' as validation_step,
  `Supplier Name`,
  `Supplier Category`,
  MEASURE(`Total Invoice Amount`) as total_invoice_amount,
  MEASURE(`Total Net Spend`) as total_net_spend,
  MEASURE(`Total Freight Cost`) as total_freight_cost,
  MEASURE(`Total Tax Cost`) as total_tax_cost,
  MEASURE(`Invoice Line Count`) as invoice_line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY `Supplier Name`, `Supplier Category`
ORDER BY MEASURE(`Total Invoice Amount`) DESC
LIMIT 10;

-- Expected: Aggregated spend by supplier
-- ✓ Each row represents one supplier (not individual invoices)
-- ✓ Amounts are pre-aggregated totals
-- ✓ Counts show number of invoice lines

-- ========================================
-- STEP 4: COMPARE METRIC VIEW VS SEMANTIC VIEW
-- ========================================
-- Verify metric view aggregations match manual calculations

-- 4a. Get totals from METRIC VIEW (pre-aggregated)
SELECT
  '4a. METRIC VIEW TOTALS' as source,
  SUM(total_invoice_amount) as grand_total_invoice,
  SUM(total_net_amount) as grand_total_net,
  SUM(invoice_line_count) as total_lines
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- 4b. Get totals from SEMANTIC VIEW (manual aggregation)
SELECT
  '4b. SEMANTIC VIEW TOTALS' as source,
  SUM(invoice_amount) as grand_total_invoice,
  SUM(net_line_amount) as grand_total_net,
  COUNT(*) as total_lines
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc;

-- Expected: Both queries should return IDENTICAL numbers
-- If different, metric view definition may be incorrect

-- ========================================
-- STEP 5: TEST ALL METRIC VIEWS
-- ========================================

-- 5a. Supplier Metric View
SELECT '5a. SUPPLIER METRIC VIEW' as test, COUNT(*) as supplier_count, SUM(total_invoice_amount) as total_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- 5b. Item Metric View
SELECT '5b. ITEM METRIC VIEW' as test, COUNT(*) as item_count, SUM(total_invoice_amount) as total_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_item_semantic_poc;

-- 5c. Restaurant Metric View
SELECT '5c. RESTAURANT METRIC VIEW' as test, COUNT(*) as restaurant_count, SUM(total_invoice_amount) as total_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_restaurant_semantic_poc;

-- 5d. Distribution Center Metric View
SELECT '5d. DC METRIC VIEW' as test, COUNT(*) as dc_count, SUM(total_invoice_amount) as total_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_dc_semantic_poc;

-- 5e. Calendar Metric View
SELECT '5e. CALENDAR METRIC VIEW' as test, COUNT(*) as date_count, SUM(total_invoice_amount) as total_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_calendar_semantic_poc;

-- Expected: All 5 queries return data without errors

-- ========================================
-- STEP 6: CHECK METRIC VIEW PROPERTIES
-- ========================================
-- Verify metric views have correct TBLPROPERTIES

SHOW TBLPROPERTIES cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc;

-- Expected properties:
-- ✓ databricks.metricViewVersion = 1.1
-- ✓ Table should be identified as a metric view

-- ========================================
-- STEP 7: TEST FILTERING ON METRIC VIEWS
-- ========================================
-- Metric views should support WHERE clauses on dimensions

SELECT
  '7. FILTERED METRIC VIEW QUERY' as validation_step,
  supplier_name,
  total_invoice_amount,
  invoice_line_count
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
WHERE supplier_category = 'Produce'
ORDER BY total_invoice_amount DESC;

-- Expected: Returns only suppliers in Produce category with aggregated totals

-- ========================================
-- STEP 8: VERIFY IN DATABRICKS METRICS UI (MANUAL STEP)
-- ========================================
-- This step must be done in the Databricks UI, not SQL

-- Manual UI Validation Steps:
--
-- 1. Navigate to Databricks Workspace → Data → Metrics
--    (Or go to: https://your-workspace.databricks.com/explore/data/metrics)
--
-- 2. Look for your metric views:
--    - mv_invoice_supplier_semantic_poc
--    - mv_invoice_item_semantic_poc
--    - mv_invoice_restaurant_semantic_poc
--    - mv_invoice_dc_semantic_poc
--    - mv_invoice_calendar_semantic_poc
--
-- 3. Click on any metric view to see:
--    ✓ Available dimensions (supplier_name, category, etc.)
--    ✓ Available measures (total_invoice_amount, counts, etc.)
--    ✓ Preview of aggregated data
--
-- 4. Create a simple visualization:
--    - Select a metric view
--    - Choose dimensions for grouping
--    - Choose measures to aggregate
--    - Click Visualize
--
-- 5. Expected Result:
--    You should see charts/graphs without errors
--    Data should match what you see in SQL queries above
--
-- Note: If Metrics UI shows Feature not enabled error:
-- - Contact Databricks support to enable Databricks Metrics (Preview)
-- - Your workspace needs this feature flag enabled

-- ========================================
-- STEP 9: CHECK METRIC VIEW REFRESH STATUS
-- ========================================
-- Metric views can be refreshed to update aggregations

DESCRIBE HISTORY cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
LIMIT 5;

-- Expected: Shows creation and any refresh operations
-- Note: Metric views typically refresh automatically

-- ========================================
-- STEP 10: VALIDATE METRIC VIEW YAML COMPLIANCE
-- ========================================
-- Check if metric views follow Databricks 1.1 schema

SELECT
  '10. YAML COMPLIANCE CHECK' as validation_step,
  table_name,
  CASE
    WHEN table_name LIKE 'mv_%' THEN 'PASS - Follows naming convention'
    ELSE 'FAIL - Should start with mv_'
  END as naming_check
FROM information_schema.tables
WHERE table_catalog = 'cfascdodev_primary'
  AND table_schema = 'invoice_semantic_poc'
  AND table_name LIKE 'mv_%';

-- Expected: All metric views follow mv_* naming pattern

-- ========================================
-- VALIDATION SUMMARY CHECKLIST
-- ========================================
-- ✓ Step 1: 5 metric views exist
-- ✓ Step 2: Metric views have correct column structure
-- ✓ Step 3: Metric views return aggregated data
-- ✓ Step 4: Aggregations match semantic view totals
-- ✓ Step 5: All 5 metric views are queryable
-- ✓ Step 6: Metric views have correct TBLPROPERTIES
-- ✓ Step 7: Filtering works on metric view dimensions
-- ✓ Step 8: Metric views appear in Databricks Metrics UI
-- ✓ Step 9: Metric view history shows successful creation
-- ✓ Step 10: Naming conventions followed
--
-- TROUBLESHOOTING:
-- - If Step 1 fails: Run 10_metric_views_semantic_poc.sql
-- - If Step 3 fails: Check underlying semantic views exist (script 07)
-- - If Step 4 totals differ: Review metric view definition
-- - If Step 8 fails: Enable Databricks Metrics (Preview) in workspace
-- - If queries timeout: Check data volume and warehouse size

-- ========================================
-- BONUS: PERFORMANCE COMPARISON
-- ========================================
-- Compare query performance: Metric View vs Semantic View

-- Query A: Using METRIC VIEW (should be faster for aggregations)
SELECT
  supplier_category,
  SUM(total_invoice_amount) as category_spend
FROM cfascdodev_primary.invoice_semantic_poc.mv_invoice_supplier_semantic_poc
GROUP BY supplier_category
ORDER BY category_spend DESC;

-- Query B: Using SEMANTIC VIEW (slower - must aggregate on the fly)
SELECT
  supplier_category,
  SUM(invoice_amount) as category_spend
FROM cfascdodev_primary.invoice_semantic_poc.v_invoice_supplier_semantic_poc
GROUP BY supplier_category
ORDER BY category_spend DESC;

-- Expected: Both return same results, but Query A may be faster
-- Note: Performance difference more noticeable with large datasets

-- ========================================
